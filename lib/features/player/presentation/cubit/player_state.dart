import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:bedtime_stories/features/stories/domain/entities/story.dart';

part 'player_state.freezed.dart';

enum PlayerPhase {
  loading,

  /// Scene or ending text is being read.
  narrating,

  /// Choice on screen; options may still be read aloud one by one.
  choosing,

  /// After a "learn" path: ask whether to go back and try the other option.
  rewindOffer,

  /// Ending narration done; screen moves to the ending page.
  finished,
  failure,
}

@freezed
abstract class PathStep with _$PathStep {
  const factory PathStep({
    required String nodeId,
    required String optionId,
    required ChoiceKind kind,
  }) = _PathStep;
}

/// A narration cue firing now. [seq] grows with every cue, so the same cue
/// twice in a row still plays twice.
@freezed
abstract class PartCue with _$PartCue {
  const factory PartCue({
    required String part,
    required PartAction action,
    required int seq,

    /// See [StoryCue.pose] and [StoryCue.to].
    String? pose,
    CanvasPoint? to,
  }) = _PartCue;
}

@freezed
abstract class PlayerState with _$PlayerState {
  const PlayerState._();

  const factory PlayerState({
    @Default(PlayerPhase.loading) PlayerPhase phase,
    Story? story,
    String? nodeId,

    /// Option being read aloud right now (glows on screen).
    int? highlightedOption,

    /// Option just tapped (plays a short celebration before moving on).
    String? selectedOptionId,
    @Default(<PathStep>[]) List<PathStep> path,

    /// First option kind picked at each choice node (kept across rewinds).
    @Default(<String, ChoiceKind>{}) Map<String, ChoiceKind> firstPicks,

    /// Latest narration cue (picture part to move).
    PartCue? cue,
    String? errorMessage,
  }) = _PlayerState;

  StoryNode? get node {
    final id = nodeId;
    return id == null ? null : story?.nodes[id];
  }

  /// Good answers = choices whose first pick was kind. One sticker each.
  int get goodCount =>
      firstPicks.values.where((k) => k == ChoiceKind.kind).length;
}
