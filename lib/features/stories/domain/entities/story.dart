import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:bedtime_stories/core/models/child_profile.dart';
import 'package:bedtime_stories/core/models/story_section.dart';
import 'package:bedtime_stories/core/utils/app_constants.dart';
import 'package:bedtime_stories/features/stories/domain/entities/math.dart';

export 'package:bedtime_stories/core/models/story_section.dart';
export 'package:bedtime_stories/features/stories/domain/entities/math.dart';

part 'story.freezed.dart';

const namePlaceholder = '{name}';

/// Who the story's pictures show. Each story picks one; the kid's own
/// gender only changes their avatar.
enum StoryHero { girl, boy, kid }

/// Splits narration text into sentences (after `.`, `!`, `?`, `…`, with an
/// optional closing quote).
List<String> splitSentences(String text) => text
    .split(RegExp(r'(?<=[.!?…]["”»]?)\s+'))
    .map((s) => s.trim())
    .where((s) => s.isNotEmpty)
    .toList();

/// Why [text] breaks the `{name}` rule, or null when it is fine.
///
/// `{name}` may appear at most once in a scene, choice or ending line, and
/// only as the first or last word of the whole line (quotes and punctuation
/// ignored), so the line is recorded as name + one clip, never
/// clip + name + clip.
String? namePlacementError(String text) {
  final count = namePlaceholder.allMatches(text).length;
  if (count == 0) return null;
  if (count > 1) return '{name} more than once in the line';
  final core = text
      .trim()
      .replaceFirst(RegExp(r'^["“«\s]+'), '')
      .replaceFirst(RegExp(r'[.!?…,"”»\s]+$'), '');
  if (!core.startsWith(namePlaceholder) && !core.endsWith(namePlaceholder)) {
    return '"$text": {name} must be the first or last word of the line';
  }
  return null;
}

/// False for text that is only punctuation or spaces (e.g. the "!" after
/// `{name}`): no audio clip is made for it.
bool isSpeakable(String text) =>
    RegExp(r'[\p{L}\p{N}]', unicode: true).hasMatch(text);

/// `kind` = the gentle, positive choice. `learn` = the choice that leads to a
/// natural consequence (never "wrong").
enum ChoiceKind { kind, learn }

/// Gentle looping effect drawn over a node's picture.
enum Ambient { none, stars, sparkles, zzz, motes }

/// A point on the picture, as fractions (0–1) of its width and height.
typedef CanvasPoint = ({double x, double y});

/// A box on the picture, as fractions (0–1) of its width and height.
typedef CanvasBox = ({double x, double y, double w, double h});

/// Where an [Ambient] effect starts.
typedef AmbientOrigin = CanvasPoint;

/// Looping motion of a picture part while the scene shows.
enum PartIdle { breathe, float, sway, glow, none }

/// One-shot motion of a picture part: on tap or on a narration cue.
/// [pose] and [move] are cue-only: switch to another pose picture, or
/// travel to a new spot, and hold until the next node. [arrive] (math
/// stories, part = the counter) sends every waiting object to its field
/// spot, one after another.
enum PartAction {
  hop,
  wiggle,
  pulse,
  pose,
  move,
  arrive;

  /// Can be a layer's `tap` reaction (pose, move, arrive need cue data).
  bool get isTapReaction => this != pose && this != move && this != arrive;
}

/// Math stories: which counted objects a node shows. Objects 1…[field] stand
/// on their field spots, the next [wait] on the waiting spots; the rest are
/// hidden. Both are expressions over the story's numbers.
typedef Counted = ({String field, String? wait});

/// Pose name of a layer's own picture ([SceneLayer.asset]).
const defaultPose = 'default';

/// One-shot effect played over a flat picture when the kid taps a hotspot
/// or the narrator reads a cue word.
enum Burst { sparkles, hearts }

/// A tappable area of a flat (AI) picture: no movable part, so a [burst]
/// plays on top of it instead. From `images/hotspots.json`.
@freezed
abstract class SceneHotspot with _$SceneHotspot {
  const factory SceneHotspot({
    /// Same names as layer kinds (`hero`, `lulu`), so cues can name it.
    required String kind,
    required CanvasBox box,
    @Default(Burst.sparkles) Burst burst,
  }) = _SceneHotspot;
}

/// One stacked slice of a scene picture (`tool/cutout.py`,
/// `tool/clock_layer.py`). Static slices have no [kind]; parts (hero, Lulu,
/// props) do.
@freezed
abstract class SceneLayer with _$SceneLayer {
  const SceneLayer._();

  const factory SceneLayer({
    required String asset,

    /// Same part with eyes closed, shown briefly to blink.
    String? blinkAsset,
    String? kind,
    @Default((x: 0.5, y: 0.5)) CanvasPoint pivot,

    /// Where a tap counts as touching this part.
    CanvasBox? box,

    /// Where the picture sits when it is cropped to the part (cut AI
    /// layers, `tool/layer_crop.py`); null = full-canvas picture. Shared
    /// by all [poses].
    CanvasBox? rect,
    @Default(PartIdle.none) PartIdle idle,

    /// Reaction when tapped; null = not tappable.
    PartAction? tap,

    /// Other pictures of the same part in the same spot (name → asset),
    /// switched by `pose` cues. [asset] is [defaultPose].
    @Default(<String, String>{}) Map<String, String> poses,
  }) = _SceneLayer;

  bool get isPart => kind != null;

  bool hasPose(String name) => name == defaultPose || poses.containsKey(name);

  String poseAsset(String name) => poses[name] ?? asset;

  /// Every picture this layer can show.
  List<String> get allAssets => [asset, ?blinkAsset, ...poses.values];
}

/// Makes a picture part move when the narrator reads [word] (first
/// occurrence after the previous cue of the same node).
@freezed
abstract class StoryCue with _$StoryCue {
  const factory StoryCue({
    required String word,

    /// A layer `kind` in the node's picture, e.g. `lulu`, `hero`, `clock`.
    required String part,
    required PartAction action,

    /// With [PartAction.pose]: the pose to switch to.
    String? pose,

    /// With [PartAction.move]: where the part's pivot goes.
    CanvasPoint? to,

    /// When [word] is said, as a fraction of its clip (measured from the
    /// recording); null = guess from the word's place in the text.
    double? at,
  }) = _StoryCue;
}

/// When a cue fires: [clipFraction] of the way through [clip] (the audio
/// file that reads that word), or [textFraction] of a silent scene.
typedef CueTiming = ({
  StoryCue cue,
  String clip,
  double clipFraction,
  double textFraction,
});

/// Fills `{name}` in story text.
String resolveName(String text, ChildProfile profile) =>
    text.replaceAll(namePlaceholder, profile.name);

/// One step of reading a line aloud: a bundled clip or the child's name.
sealed class NarrationPart {
  const NarrationPart();
}

final class ClipPart extends NarrationPart {
  const ClipPart(this.assetPath);

  final String assetPath;

  @override
  bool operator ==(Object other) =>
      other is ClipPart && other.assetPath == assetPath;

  @override
  int get hashCode => assetPath.hashCode;

  @override
  String toString() => 'ClipPart($assetPath)';
}

/// Math stories: one number of a count ("one, two, three…"); the counted
/// object [part] hops (or switches to [pose]) as the number starts.
final class CountPart extends NarrationPart {
  const CountPart(this.assetPath, {required this.part, this.pose});

  final String assetPath;
  final String part;
  final String? pose;

  @override
  bool operator ==(Object other) =>
      other is CountPart &&
      other.assetPath == assetPath &&
      other.part == part &&
      other.pose == pose;

  @override
  int get hashCode => Object.hash(assetPath, part, pose);

  @override
  String toString() => 'CountPart($assetPath, $part, $pose)';
}

final class NamePart extends NarrationPart {
  const NamePart();

  @override
  bool operator ==(Object other) => other is NamePart;

  @override
  int get hashCode => 0;

  @override
  String toString() => 'NamePart()';
}

@freezed
abstract class ChoiceOption with _$ChoiceOption {
  const factory ChoiceOption({
    required String id,
    required ChoiceKind kind,
    required String iconAsset,
    required String label,
    required String nextId,

    /// Math stories: `"c"` (the right answer is the number c) or `"near:c"`
    /// (one more or one less). Resolved into [count] for each play.
    String? answer,

    /// The number this card stands for in this play (math stories): the
    /// card draws that many objects, `{n}` in the label says it.
    int? count,
  }) = _ChoiceOption;
}

@freezed
sealed class StoryNode with _$StoryNode {
  /// Narrated picture. When [offerRewindTo] is set, the kid is asked whether
  /// to go back to that choice and try the other option.
  const factory StoryNode.scene({
    required String id,
    required String imageAsset,
    required String text,
    required String nextId,
    String? offerRewindTo,
    @Default(Ambient.none) Ambient ambient,
    AmbientOrigin? ambientOrigin,
    @Default(<StoryCue>[]) List<StoryCue> cues,

    /// Starting pose per part kind (default otherwise).
    @Default(<String, String>{}) Map<String, String> poses,

    /// Math stories: counted objects shown (see [Counted]).
    Counted? counted,
  }) = SceneNode;

  /// [text] is the question read before the options.
  const factory StoryNode.choice({
    required String id,
    required String imageAsset,
    required String text,
    required List<ChoiceOption> options,
    @Default(Ambient.none) Ambient ambient,
    AmbientOrigin? ambientOrigin,
    @Default(<StoryCue>[]) List<StoryCue> cues,

    /// Starting pose per part kind (default otherwise).
    @Default(<String, String>{}) Map<String, String> poses,

    /// Math stories: counted objects shown (see [Counted]).
    Counted? counted,
  }) = ChoiceNode;

  const factory StoryNode.ending({
    required String id,
    required String imageAsset,
    required String text,
    required String stickerAsset,
    @Default(Ambient.none) Ambient ambient,
    AmbientOrigin? ambientOrigin,
    @Default(<StoryCue>[]) List<StoryCue> cues,

    /// Starting pose per part kind (default otherwise).
    @Default(<String, String>{}) Map<String, String> poses,

    /// Math stories: counted objects shown (see [Counted]).
    Counted? counted,
  }) = EndingNode;
}

@freezed
abstract class Story with _$Story {
  const Story._();

  /// One language of a story file: text, cues and [audioDir] are for
  /// [language]; pictures are shared by every language.
  const factory Story({
    required String id,
    required String theme,
    @Default(StorySection.behavior) StorySection section,
    required AppLanguage language,
    required StoryHero hero,
    required String title,
    required String coverAsset,
    required String startId,
    required Map<String, StoryNode> nodes,
    required String audioDir,

    /// Layered pictures keyed by node `imageAsset`. Pictures not in here
    /// are drawn flat.
    @Default(<String, List<SceneLayer>>{}) Map<String, List<SceneLayer>> layers,

    /// Tappable areas of flat pictures, keyed by node `imageAsset`.
    @Default(<String, List<SceneHotspot>>{})
    Map<String, List<SceneHotspot>> hotspots,

    /// Math stories: numbers drawn per play (see `docs/math.md`).
    MathSpec? math,

    /// This play's numbers (empty until [withNumbers]).
    @Default(<String, int>{}) Map<String, int> values,
  }) = _Story;

  /// A copy for one play: numbers drawn, each math choice's answers
  /// resolved and its cards shuffled (so the right one isn't always first).
  /// Stories without `math` come back unchanged.
  Story withNumbers(Random random) {
    final spec = math;
    if (spec == null) return this;
    final drawn = spec.draw(random);
    return copyWith(
      values: drawn,
      nodes: {
        for (final MapEntry(:key, :value) in nodes.entries)
          key: switch (value) {
            ChoiceNode(:final options)
                when options.any((o) => o.answer != null) =>
              value.copyWith(
                options: [
                  for (final o in options)
                    o.copyWith(count: _answer(o.answer, drawn, spec, random)),
                ]..shuffle(random),
              ),
            _ => value,
          },
      },
    );
  }

  static int? _answer(
    String? answer,
    Map<String, int> values,
    MathSpec spec,
    Random random,
  ) {
    if (answer == null) return null;
    if (answer.startsWith('near:')) {
      return nearMiss(evalMath(answer.substring(5), values), spec.max, random);
    }
    return evalMath(answer, values);
  }

  /// [text] as shown on screen: numbers written out (`{name}` kept).
  String spell(String text) =>
      values.isEmpty ? text : spellNumbers(text, language, values);

  /// An option's label as shown (its `{n}` = the card's number).
  String optionLabel(ChoiceOption option) =>
      spellNumbers(option.label, language, {...values, 'n': ?option.count});

  /// Math stories: where each counted object of [nodeId] starts (part kind →
  /// spot), null = hidden. Empty when the node has no `counted`.
  Map<String, CanvasPoint?> placements(String nodeId) {
    final spec = math;
    final counted = nodes[nodeId]?.counted;
    if (spec == null || counted == null || values.isEmpty) return const {};
    final field = evalMath(counted.field, values);
    final waitExpr = counted.wait;
    final wait = waitExpr == null ? 0 : evalMath(waitExpr, values);
    return {
      for (var k = 1; k <= spec.max; k++)
        spec.part(k): k <= field
            ? spec.field[k - 1]
            : k <= field + wait && k - field - 1 < spec.wait.length
            ? spec.wait[k - field - 1]
            : null,
    };
  }

  /// Math stories: the waiting objects of [nodeId] and where each goes when
  /// an `arrive` cue fires (part kind → field spot), in order.
  List<(String, CanvasPoint)> arrivals(String nodeId) {
    final spec = math;
    final counted = nodes[nodeId]?.counted;
    final waitExpr = counted?.wait;
    if (spec == null || counted == null || waitExpr == null) return const [];
    final field = evalMath(counted.field, values);
    final wait = evalMath(waitExpr, values);
    return [
      for (var k = field + 1; k <= field + wait && k <= spec.max; k++)
        (spec.part(k), spec.field[k - 1]),
    ];
  }

  /// The story's sticker (from its ending node).
  String? get stickerAsset {
    for (final node in nodes.values) {
      if (node is EndingNode) return node.stickerAsset;
    }
    return null;
  }

  /// Clips for a node's text. Must match `tool/gen_audio.py`:
  /// `<node>[_<option>][_p<i>].m4a`. `_p<i>` appears only when the text has
  /// `{name}`, which splits it into parts with the name read in between.
  List<NarrationPart> nodeNarration(String nodeId) =>
      _narration(nodes[nodeId]!.text, nodeId);

  List<NarrationPart> optionNarration(String nodeId, String optionId) {
    final node = nodes[nodeId]! as ChoiceNode;
    final option = node.options.firstWhere((o) => o.id == optionId);
    return _narration(option.label, '${nodeId}_$optionId', {
      ...values,
      'n': ?option.count,
    });
  }

  /// Every narration clip in the story, each once (math stories: plus
  /// every number clip a play can use).
  List<String> get clipPaths => {
    for (final id in nodes.keys) ...nodeClips(id),
    if (math case final spec?)
      for (var n = 1; n <= spec.max; n++) numberClip(n),
  }.toList();

  /// The UI clip that says [n] in this story's language.
  String numberClip(int n) => AppConstants.uiAudio('num_$n', language);

  /// Clips read on entering [nodeId]: its text, plus each option on a choice.
  List<String> nodeClips(String nodeId) {
    final node = nodes[nodeId]!;
    return [
      ..._clips(nodeNarration(nodeId)),
      if (node is ChoiceNode)
        for (final o in node.options) ..._clips(optionNarration(nodeId, o.id)),
    ];
  }

  /// Nodes the kid can reach straight from [nodeId]. Used to preload the
  /// next pictures and clips while the current one plays.
  List<String> nextIds(String nodeId) => switch (nodes[nodeId]!) {
    SceneNode(:final nextId, :final offerRewindTo) => [nextId, ?offerRewindTo],
    ChoiceNode(:final options) => [for (final o in options) o.nextId],
    EndingNode() => const <String>[],
  };

  static Iterable<String> _clips(List<NarrationPart> parts) => [
    for (final p in parts)
      if (p case ClipPart(:final assetPath) || CountPart(:final assetPath))
        assetPath,
  ];

  /// Where each cue of a node lands in its narration. Must match how
  /// [nodeNarration] splits the text into clips (pieces between tokens).
  List<CueTiming> cueTimings(String nodeId) {
    final node = nodes[nodeId]!;
    final text = node.text;
    final base = '$audioDir/$nodeId';
    const ext = AppConstants.audioExt;
    final tokens = tokenize(text);
    // Words pieces with where they start in the text.
    final pieces = <({int start, int end})>[];
    var offset = 0;
    for (final m in tokenPattern.allMatches(text)) {
      pieces.add((start: offset, end: m.start));
      offset = m.end;
    }
    pieces.add((start: offset, end: text.length));
    final out = <CueTiming>[];
    var from = 0;
    for (final cue in node.cues) {
      final at = text.indexOf(cue.word, from);
      if (at < 0) continue;
      from = at + cue.word.length;
      for (var i = 0; i < pieces.length; i++) {
        final p = pieces[i];
        if (at >= p.start && at < p.end) {
          out.add((
            cue: cue,
            clip: tokens.length == 1 ? '$base.$ext' : '${base}_p$i.$ext',
            clipFraction: cue.at ?? (at - p.start) / (p.end - p.start),
            textFraction: at / text.length,
          ));
          break;
        }
      }
    }
    return out;
  }

  /// Splits [text] at its tokens: words pieces are the line's clips
  /// (`<key>_p<i>`, or `<key>` when the line has no token; letter-less
  /// pieces skipped), `{name}` the child's name, numbers and counts the
  /// shared number clips. Must match `tool/gen_audio.py`.
  List<NarrationPart> _narration(
    String text,
    String key, [
    Map<String, int>? numbers,
  ]) {
    final vals = numbers ?? values;
    final base = '$audioDir/$key';
    const ext = AppConstants.audioExt;
    final tokens = tokenize(text);
    if (tokens.length == 1) return [ClipPart('$base.$ext')];
    final out = <NarrationPart>[];
    var piece = 0;
    for (final t in tokens) {
      switch (t) {
        case WordsToken(:final text):
          if (isSpeakable(text)) out.add(ClipPart('${base}_p$piece.$ext'));
          piece++;
        case NameToken():
          out.add(const NamePart());
        case NumberToken(:final variable):
          final n = vals[variable];
          if (n != null && n >= 1 && n <= maxSpokenNumber) {
            out.add(ClipPart(numberClip(n)));
          }
        case CountToken(:final variable, :final pose):
          final spec = math;
          final n = vals[variable] ?? 0;
          if (spec == null) break;
          for (var k = 1; k <= n && k <= maxSpokenNumber; k++) {
            out.add(CountPart(numberClip(k), part: spec.part(k), pose: pose));
          }
      }
    }
    return out;
  }
}
