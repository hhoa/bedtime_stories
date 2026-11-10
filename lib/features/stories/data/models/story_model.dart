import 'package:json_annotation/json_annotation.dart';
import 'package:bedtime_stories/core/models/child_profile.dart';
import 'package:bedtime_stories/features/stories/domain/entities/story.dart';

part 'story_model.g.dart';

/// Text in every [AppLanguage], e.g. `{"vi": "...", "en": "..."}`.
typedef LocalText = Map<String, String>;

String _pick(LocalText text, AppLanguage language, String where) {
  final value = text[language.name];
  if (value == null || value.trim().isEmpty) {
    throw FormatException('$where has no "${language.name}" text');
  }
  return value;
}

@JsonSerializable(fieldRename: FieldRename.snake)
final class ChoiceOptionModel {
  const ChoiceOptionModel({
    required this.id,
    required this.kind,
    required this.icon,
    required this.label,
    required this.next,
  });

  factory ChoiceOptionModel.fromJson(Map<String, dynamic> json) =>
      _$ChoiceOptionModelFromJson(json);

  final String id;
  final String kind;
  final String icon;
  final LocalText label;
  final String next;

  Map<String, dynamic> toJson() => _$ChoiceOptionModelToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
final class CueModel {
  const CueModel({
    required this.word,
    required this.part,
    required this.action,
    this.pose,
    this.to,
    this.at,
  });

  factory CueModel.fromJson(Map<String, dynamic> json) =>
      _$CueModelFromJson(json);

  final String word;
  final String part;
  final String action;

  /// Pose name, for action `pose`.
  final String? pose;

  /// `[x, y]` fractions of the picture, for action `move`.
  final List<double>? to;

  /// When the word is said, as a fraction (0–1) of its clip, measured from
  /// the recording by `tool/cue_times.py`. Without it the word's place in
  /// the text is used.
  final double? at;

  Map<String, dynamic> toJson() => _$CueModelToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
final class StoryNodeModel {
  const StoryNodeModel({
    required this.id,
    required this.type,
    required this.image,
    required this.text,
    this.next,
    this.offerRewindTo,
    this.options,
    this.sticker,
    this.ambient,
    this.ambientOrigin,
    this.cues,
    this.poses,
  });

  factory StoryNodeModel.fromJson(Map<String, dynamic> json) =>
      _$StoryNodeModelFromJson(json);

  final String id;
  final String type;
  final String image;
  final LocalText text;
  final String? next;
  final String? offerRewindTo;
  final List<ChoiceOptionModel>? options;
  final String? sticker;

  /// One of [Ambient] names; omitted = none.
  final String? ambient;

  /// `[x, y]` fractions of the picture where the effect starts.
  final List<double>? ambientOrigin;

  /// Picture parts that move when a word is read, per language (the words
  /// differ): `{"vi": [...], "en": [...]}`.
  final Map<String, List<CueModel>>? cues;

  /// Starting pose per part kind, e.g. `{"hero": "chew"}`.
  final Map<String, String>? poses;

  Map<String, dynamic> toJson() => _$StoryNodeModelToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
final class StoryModel {
  const StoryModel({
    required this.id,
    required this.theme,
    required this.hero,
    required this.title,
    required this.cover,
    required this.start,
    required this.nodes,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) =>
      _$StoryModelFromJson(json);

  final String id;
  final String theme;

  /// [StoryHero] name: who the pictures show.
  final String hero;
  final LocalText title;
  final String cover;
  final String start;
  final List<StoryNodeModel> nodes;

  Map<String, dynamic> toJson() => _$StoryModelToJson(this);

  /// Converts to the domain entity in [language], resolving asset paths
  /// against [baseDir] and validating that every link points at an existing
  /// node. Every language must be complete (text, labels, `{name}` rule), so
  /// a story is rejected even when only the other language is broken.
  /// Throws [FormatException] on invalid data.
  ///
  /// [layers] is the optional `images/layers.json` manifest (cut parts,
  /// poses); [hotspots] the optional `images/hotspots.json`.
  Story toEntity({
    required String baseDir,
    required AppLanguage language,
    Map<String, dynamic>? layers,
    Map<String, dynamic>? hotspots,
  }) {
    _checkLanguages();
    final storyHero = _byName(StoryHero.values, hero, 'hero');
    String text(StoryNodeModel n) => _pick(n.text, language, 'Node "${n.id}"');

    String asset(String relative) => '$baseDir/$relative';
    String required(String? value, String field, String nodeId) {
      if (value == null || value.isEmpty) {
        throw FormatException('Node "$nodeId" is missing "$field"');
      }
      return value;
    }

    Ambient ambientOf(StoryNodeModel n) {
      final name = n.ambient;
      if (name == null) return Ambient.none;
      for (final a in Ambient.values) {
        if (a.name == name) return a;
      }
      throw FormatException('Node "${n.id}" has unknown ambient "$name"');
    }

    AmbientOrigin? originOf(StoryNodeModel n) {
      final o = n.ambientOrigin;
      if (o == null) return null;
      if (o.length != 2 || o.any((v) => v < 0 || v > 1)) {
        throw FormatException(
          'Node "${n.id}" ambient_origin must be [x, y] within 0..1',
        );
      }
      return (x: o[0], y: o[1]);
    }

    List<StoryCue> cuesOf(StoryNodeModel n) {
      final out = <StoryCue>[];
      var from = 0;
      final nodeText = text(n);
      for (final c in n.cues?[language.name] ?? const <CueModel>[]) {
        final at = nodeText.indexOf(c.word, from);
        if (c.word.isEmpty || at < 0) {
          throw FormatException(
            'Node "${n.id}" cue word "${c.word}" not found in order in text',
          );
        }
        from = at + c.word.length;
        final action = _byName(PartAction.values, c.action, 'cue action');
        final pose = c.pose;
        if (action == PartAction.pose && (pose == null || pose.isEmpty)) {
          throw FormatException(
            'Node "${n.id}" pose cue "${c.word}" needs "pose"',
          );
        }
        final to = c.to;
        if (action == PartAction.move &&
            (to == null || to.length != 2 || to.any((v) => v < 0 || v > 1))) {
          throw FormatException(
            'Node "${n.id}" move cue "${c.word}" needs "to": [x, y] in 0..1',
          );
        }
        final when = c.at;
        if (when != null && (when < 0 || when > 1)) {
          throw FormatException(
            'Node "${n.id}" cue "${c.word}" needs "at" in 0..1',
          );
        }
        out.add(
          StoryCue(
            word: c.word,
            part: c.part,
            action: action,
            pose: action == PartAction.pose ? pose : null,
            to: action == PartAction.move ? (x: to![0], y: to[1]) : null,
            at: when,
          ),
        );
      }
      return out;
    }

    final byId = <String, StoryNode>{};
    for (final n in nodes) {
      if (byId.containsKey(n.id)) {
        throw FormatException('Duplicate node id "${n.id}"');
      }
      byId[n.id] = switch (n.type) {
        'scene' => StoryNode.scene(
          id: n.id,
          imageAsset: asset(n.image),
          text: text(n),
          nextId: required(n.next, 'next', n.id),
          offerRewindTo: n.offerRewindTo,
          ambient: ambientOf(n),
          ambientOrigin: originOf(n),
          cues: cuesOf(n),
          poses: n.poses ?? const {},
        ),
        'choice' => StoryNode.choice(
          id: n.id,
          imageAsset: asset(n.image),
          text: text(n),
          options: [
            for (final o in n.options ?? const <ChoiceOptionModel>[])
              ChoiceOption(
                id: o.id,
                kind: ChoiceKind.values.byName(o.kind),
                iconAsset: asset(o.icon),
                label: _pick(o.label, language, 'Option "${n.id}.${o.id}"'),
                nextId: o.next,
              ),
          ],
          ambient: ambientOf(n),
          ambientOrigin: originOf(n),
          cues: cuesOf(n),
          poses: n.poses ?? const {},
        ),
        'ending' => StoryNode.ending(
          id: n.id,
          imageAsset: asset(n.image),
          text: text(n),
          stickerAsset: asset(required(n.sticker, 'sticker', n.id)),
          ambient: ambientOf(n),
          ambientOrigin: originOf(n),
          cues: cuesOf(n),
          poses: n.poses ?? const {},
        ),
        _ => throw FormatException('Unknown node type "${n.type}"'),
      };
    }

    void checkLink(String from, String? to) {
      if (to != null && !byId.containsKey(to)) {
        throw FormatException('Node "$from" links to missing node "$to"');
      }
    }

    checkLink('start', start);
    for (final node in byId.values) {
      switch (node) {
        case SceneNode(:final id, :final nextId, :final offerRewindTo):
          checkLink(id, nextId);
          checkLink(id, offerRewindTo);
          if (offerRewindTo != null && byId[offerRewindTo] is! ChoiceNode) {
            throw FormatException('Node "$id" rewinds to a non-choice node');
          }
        case ChoiceNode(:final id, :final options):
          if (options.length < 2) {
            throw FormatException('Choice "$id" needs at least 2 options');
          }
          for (final o in options) {
            checkLink(id, o.nextId);
          }
        case EndingNode():
          break;
      }
    }
    if (!byId.values.any((n) => n is EndingNode)) {
      throw const FormatException('Story has no ending node');
    }

    final parsedLayers = layers == null
        ? const <String, List<SceneLayer>>{}
        : parseLayers(layers, '$baseDir/images');
    for (final node in byId.values) {
      _checkPoses(node, parsedLayers[node.imageAsset] ?? const []);
    }

    return Story(
      id: id,
      theme: theme,
      language: language,
      hero: storyHero,
      title: _pick(title, language, 'Title'),
      coverAsset: asset(cover),
      startId: start,
      nodes: byId,
      audioDir: asset('audio/${language.name}'),
      layers: parsedLayers,
      hotspots: hotspots == null
          ? const {}
          : parseHotspots(hotspots, '$baseDir/images'),
    );
  }

  /// Every language has its text, and `{name}` opens or closes its sentence.
  void _checkLanguages() {
    for (final lang in AppLanguage.values) {
      _pick(title, lang, 'Title');
      for (final n in nodes) {
        final where = 'Node "${n.id}" (${lang.name})';
        final error = namePlacementError(_pick(n.text, lang, 'Node "${n.id}"'));
        if (error != null) throw FormatException('$where: $error');
        var from = 0;
        final nodeText = n.text[lang.name]!;
        for (final c in n.cues?[lang.name] ?? const <CueModel>[]) {
          final at = c.word.isEmpty ? -1 : nodeText.indexOf(c.word, from);
          if (at < 0) {
            throw FormatException('$where cue "${c.word}" not found in order');
          }
          from = at + c.word.length;
        }
        for (final o in n.options ?? const <ChoiceOptionModel>[]) {
          final label = _pick(o.label, lang, 'Option "${n.id}.${o.id}"');
          if (label.contains(namePlaceholder)) {
            throw FormatException(
              'Option "${n.id}.${o.id}": no {name} in labels',
            );
          }
        }
      }
    }
  }
}

/// Every pose a node names (start poses and pose cues) must exist on a
/// part of that kind in the node's picture.
void _checkPoses(StoryNode node, List<SceneLayer> layers) {
  void need(String part, String pose, String what) {
    final ok = layers.any((l) => l.kind == part && l.hasPose(pose));
    if (!ok) {
      throw FormatException(
        'Node "${node.id}" $what: no "$part" layer with pose "$pose"',
      );
    }
  }

  for (final MapEntry(:key, :value) in node.poses.entries) {
    need(key, value, 'start pose');
  }
  for (final c in node.cues) {
    if (c.action == PartAction.pose) need(c.part, c.pose!, 'cue "${c.word}"');
  }
}

T _byName<T extends Enum>(List<T> values, String name, String what) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  throw FormatException('Unknown $what "$name"');
}

/// Parses `images/layers.json` (see `tool/cutout.py`). Keys are scene file
/// names under `images/`; result keys are full node image paths.
CanvasPoint _point(Object? v) {
  final l = (v! as List).cast<num>();
  return (x: l[0].toDouble(), y: l[1].toDouble());
}

CanvasBox _box(Object? v) {
  final l = (v! as List).cast<num>();
  return (
    x: l[0].toDouble(),
    y: l[1].toDouble(),
    w: l[2].toDouble(),
    h: l[3].toDouble(),
  );
}

/// Parses `images/hotspots.json`: tappable areas of flat AI pictures.
/// Keys are scene file names under `images/`.
Map<String, List<SceneHotspot>> parseHotspots(
  Map<String, dynamic> json,
  String imagesDir,
) => {
  for (final MapEntry(:key, :value) in json.entries)
    '$imagesDir/$key': [
      for (final raw in value as List)
        if (raw case final Map<String, dynamic> h)
          SceneHotspot(
            kind: h['kind'] as String,
            box: _box(h['box']),
            burst: h['burst'] == null
                ? Burst.sparkles
                : _byName(Burst.values, h['burst'] as String, 'burst'),
          ),
    ],
};

PartAction _tapOf(String name) {
  final a = _byName(PartAction.values, name, 'tap');
  if (!a.isTapReaction) throw FormatException('Tap cannot be "$name"');
  return a;
}

Map<String, List<SceneLayer>> parseLayers(
  Map<String, dynamic> json,
  String imagesDir,
) {
  const point = _point;
  const box = _box;

  return {
    for (final MapEntry(:key, :value) in json.entries)
      '$imagesDir/$key': [
        for (final raw in value as List)
          if (raw case final Map<String, dynamic> l)
            SceneLayer(
              asset: '$imagesDir/${l['file']}',
              blinkAsset: l['blink'] == null
                  ? null
                  : '$imagesDir/${l['blink']}',
              kind: l['kind'] as String?,
              pivot: l['pivot'] == null ? (x: 0.5, y: 0.5) : point(l['pivot']),
              box: l['box'] == null ? null : box(l['box']),
              rect: l['rect'] == null ? null : box(l['rect']),
              idle: l['idle'] == null
                  ? PartIdle.none
                  : _byName(PartIdle.values, l['idle'] as String, 'idle'),
              tap: l['tap'] == null ? null : _tapOf(l['tap'] as String),
              poses: {
                for (final MapEntry(:key, :value)
                    in ((l['poses'] as Map<String, dynamic>?) ?? const {})
                        .entries)
                  if (key != defaultPose) key: '$imagesDir/$value',
              },
            ),
      ],
  };
}
