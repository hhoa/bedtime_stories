import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:bedtime_stories/core/models/child_profile.dart';
import 'package:bedtime_stories/core/utils/app_constants.dart';

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
/// travel to a new spot, and hold until the next node.
enum PartAction {
  hop,
  wiggle,
  pulse,
  pose,
  move;

  /// Can be a layer's `tap` reaction (pose and move need cue data).
  bool get isTapReaction => this != pose && this != move;
}

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
  }) = _Story;

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
    return _narration(option.label, '${nodeId}_$optionId');
  }

  /// Every narration clip in the story, each once.
  List<String> get clipPaths =>
      {for (final id in nodes.keys) ...nodeClips(id)}.toList();

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

  static Iterable<String> _clips(List<NarrationPart> parts) =>
      parts.whereType<ClipPart>().map((p) => p.assetPath);

  /// Where each cue of a node lands in its narration. Must match how
  /// [nodeNarration] splits the text into clips.
  List<CueTiming> cueTimings(String nodeId) {
    final node = nodes[nodeId]!;
    final text = node.text;
    final base = '$audioDir/$nodeId';
    const ext = AppConstants.audioExt;
    final pieces = text.split(namePlaceholder);
    final out = <CueTiming>[];
    var from = 0;
    for (final cue in node.cues) {
      final at = text.indexOf(cue.word, from);
      if (at < 0) continue;
      from = at + cue.word.length;
      // Find the piece (between names) holding the word.
      var start = 0;
      for (var i = 0; i < pieces.length; i++) {
        final end = start + pieces[i].length;
        if (at < end) {
          out.add((
            cue: cue,
            clip: pieces.length == 1 ? '$base.$ext' : '${base}_p$i.$ext',
            clipFraction: cue.at ?? (at - start) / pieces[i].length,
            textFraction: at / text.length,
          ));
          break;
        }
        start = end + namePlaceholder.length;
      }
    }
    return out;
  }

  List<NarrationPart> _narration(String text, String key) {
    final base = '$audioDir/$key';
    final pieces = text.split(namePlaceholder);
    const ext = AppConstants.audioExt;
    if (pieces.length == 1) return [ClipPart('$base.$ext')];
    return [
      for (var i = 0; i < pieces.length; i++) ...[
        if (i > 0) const NamePart(),
        if (isSpeakable(pieces[i])) ClipPart('${base}_p$i.$ext'),
      ],
    ];
  }
}
