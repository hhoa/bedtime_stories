import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bedtime_stories/core/models/child_profile.dart';
import 'package:bedtime_stories/core/services/analytics.dart';
import 'package:bedtime_stories/core/services/name_voice.dart';
import 'package:bedtime_stories/core/services/narrator.dart';
import 'package:bedtime_stories/core/utils/app_constants.dart';
import 'package:bedtime_stories/features/player/presentation/cubit/player_state.dart';
import 'package:bedtime_stories/features/stories/domain/entities/story.dart';
import 'package:bedtime_stories/features/stories/domain/repositories/story_repository.dart';

/// Drives one story playthrough: narration, choices, rewinds.
///
/// Every node entry bumps [_token]. Async narration chains check it after each
/// await and stop if the kid has already moved on (tap, choice, language
/// rewind), so stale audio never advances the story.
///
/// Lines containing `{name}` are read as clip + name (or name + clip). The
/// name comes from the parent's recording when there is one, else a bundled
/// "bé" / "sweetie" clip in the story's language.
///
/// The first option picked at each choice is kept ([PlayerState.firstPicks]):
/// one sticker per choice whose first pick was kind. Trying again after a
/// rewind doesn't change it.
///
/// Owns [narrator] and disposes it on close.
class PlayerCubit extends Cubit<PlayerState> {
  PlayerCubit({
    required this._repository,
    required this._narrator,
    required this._storyId,
    required this._language,
    required this._nameVoice,
    required this._analytics,
    this._autoAdvanceDelay = AppConstants.autoAdvanceDelay,
    this._silentSceneDuration = AppConstants.silentSceneDuration,
    this._choiceCelebrateDelay = AppConstants.choiceCelebrateDelay,
    this._choiceOptionGap = AppConstants.choiceOptionGap,
  }) : super(const PlayerState());

  final StoryRepository _repository;
  final Narrator _narrator;
  final String _storyId;
  final AppLanguage _language;
  final NameVoice _nameVoice;
  final Analytics _analytics;
  final Duration _autoAdvanceDelay;
  final Duration _silentSceneDuration;
  final Duration _choiceCelebrateDelay;
  final Duration _choiceOptionGap;

  int _token = 0;
  Timer? _timer;
  final List<Timer> _cueTimers = [];
  int _cueSeq = 0;
  String? _nameRecording;

  /// Token of the node whose narration (or rewind question) is still being
  /// read. Null once it ends, so taps only replay a line that has finished.
  int? _speakingToken;

  bool get _speaking => _speakingToken != null && _speakingToken == _token;

  void _doneSpeaking(int token) {
    if (_speakingToken == token) _speakingToken = null;
  }

  Future<void> load() async {
    _nameRecording = await _nameVoice.recordingPath();
    final result = await _repository.getStory(_storyId, _language);
    if (isClosed) return;
    await result.fold<Future<void>>(
      (failure) async => emit(
        state.copyWith(
          phase: PlayerPhase.failure,
          errorMessage: failure.message,
        ),
      ),
      (story) async {
        emit(state.copyWith(story: story));
        unawaited(_analytics.storyStart(story.id, _language));
        await _preload(story);
        if (isClosed) return;
        _enter(story.startId);
      },
    );
  }

  /// Fetches the first node's clips (plus the rewind line and the name) before
  /// starting, so the first line never waits on the network (matters on web).
  /// Later clips load one step ahead in [_enter]. Capped so a slow connection
  /// still starts the story.
  Future<void> _preload(Story story) async {
    try {
      await _narrator
          .preload([
            ...story.nodeClips(story.startId),
            AppConstants.uiAudio('rewind', _language),
            _nameRecording ?? AppConstants.nameFallbackAudio(_language),
          ])
          .timeout(AppConstants.preloadTimeout);
    } on TimeoutException {
      // Start anyway; clips still loading finish in the background.
    }
  }

  /// Skip ahead (next arrow) on a scene.
  void next() {
    final node = state.node;
    if (node is! SceneNode) return;
    if (state.phase == PlayerPhase.rewindOffer) {
      keepGoing();
    } else if (node.offerRewindTo != null) {
      _bump();
      _offerRewind();
    } else {
      _enter(node.nextId);
    }
  }

  void choose(String optionId) {
    final node = state.node;
    if (node is! ChoiceNode || state.selectedOptionId != null) return;
    final option = node.options.firstWhere((o) => o.id == optionId);
    final token = _bump();
    unawaited(
      _analytics.storyChoice(
        storyId: _storyId,
        nodeId: node.id,
        optionId: option.id,
        kind: option.kind,
      ),
    );
    emit(
      state.copyWith(
        selectedOptionId: optionId,
        highlightedOption: null,
        path: [
          ...state.path,
          PathStep(nodeId: node.id, optionId: option.id, kind: option.kind),
        ],
        firstPicks: state.firstPicks.containsKey(node.id)
            ? state.firstPicks
            : {...state.firstPicks, node.id: option.kind},
      ),
    );
    _timer = Timer(_choiceCelebrateDelay, () {
      if (token == _token) _enter(option.nextId);
    });
  }

  /// Go back to the choice named by the current scene's `offerRewindTo`.
  void rewind() {
    final node = state.node;
    final target = node is SceneNode ? node.offerRewindTo : null;
    if (target == null) return;
    unawaited(_analytics.storyRewind(storyId: _storyId, nodeId: target));
    final cut = state.path.lastIndexWhere((s) => s.nodeId == target);
    emit(
      state.copyWith(path: cut < 0 ? state.path : state.path.sublist(0, cut)),
    );
    _enter(target);
  }

  void keepGoing() {
    final node = state.node;
    if (node is SceneNode) _enter(node.nextId);
  }

  /// Re-read the current node from the start, once its narration has
  /// finished. Taps while a line is still being read (or a pick is being
  /// celebrated) are ignored, so the kid never cuts the sentence off.
  void replay() {
    final id = state.nodeId;
    if (id == null ||
        state.phase == PlayerPhase.finished ||
        state.selectedOptionId != null ||
        _speaking) {
      return;
    }
    _enter(id);
  }

  // ---------------------------------------------------------------------------

  int _bump() {
    _timer?.cancel();
    _cancelCues();
    _narrator.stop();
    return ++_token;
  }

  void _enter(String nodeId) {
    final token = _bump();
    final story = state.story;
    final node = story?.nodes[nodeId];
    if (story == null || node == null) return;
    // Load what can play next while this node is read.
    unawaited(
      _narrator.preload([
        for (final id in story.nextIds(nodeId)) ...story.nodeClips(id),
      ]),
    );
    emit(
      state.copyWith(
        nodeId: nodeId,
        phase: node is ChoiceNode
            ? PlayerPhase.choosing
            : PlayerPhase.narrating,
        highlightedOption: null,
        selectedOptionId: null,
      ),
    );
    unawaited(_narrate(node, token));
  }

  bool _stale(int token) => isClosed || token != _token;

  Future<void> _narrate(StoryNode node, int token) async {
    final story = state.story;
    if (story == null) return;
    _speakingToken = token;
    final cues = story.cueTimings(node.id);
    Future<bool> readNode(String id) =>
        _playParts(story.nodeNarration(id), token, cues: cues);
    Future<void> silentPause() async {
      _scheduleSilentCues(cues, token);
      await Future<void>.delayed(_silentSceneDuration);
    }

    switch (node) {
      case SceneNode(:final id, :final offerRewindTo, :final nextId):
        final played = await readNode(id);
        if (_stale(token)) return;
        _doneSpeaking(token);
        if (!played) await silentPause();
        if (_stale(token)) return;
        if (offerRewindTo != null) {
          _offerRewind();
        } else {
          _timer = Timer(_autoAdvanceDelay, () {
            if (!_stale(token)) _enter(nextId);
          });
        }

      case ChoiceNode(:final id, :final options):
        await readNode(id);
        for (var i = 0; i < options.length; i++) {
          // A breath after the question and between options, so the kid
          // hears each one on its own.
          await Future<void>.delayed(_choiceOptionGap);
          if (_stale(token)) return;
          emit(state.copyWith(highlightedOption: i));
          await _playParts(story.optionNarration(id, options[i].id), token);
        }
        if (_stale(token)) return;
        _doneSpeaking(token);
        emit(state.copyWith(highlightedOption: null));

      case EndingNode(:final id):
        final played = await readNode(id);
        if (_stale(token)) return;
        _doneSpeaking(token);
        if (!played) await silentPause();
        if (_stale(token)) return;
        unawaited(
          _analytics.storyComplete(
            storyId: _storyId,
            endingId: id,
            goodAnswers: state.goodCount,
          ),
        );
        emit(state.copyWith(phase: PlayerPhase.finished));
    }
  }

  /// Plays [parts] in order. True when at least one story clip played, so a
  /// line whose audio is missing still falls back to silent pacing.
  Future<bool> _playParts(
    List<NarrationPart> parts,
    int token, {
    List<CueTiming> cues = const [],
  }) async {
    var played = false;
    for (final part in parts) {
      if (_stale(token)) return played;
      switch (part) {
        case ClipPart(:final assetPath):
          final clipCues = [
            for (final c in cues)
              if (c.clip == assetPath) c,
          ];
          played =
              await _narrator.play(
                assetPath,
                onStart: clipCues.isEmpty
                    ? null
                    : (d) => _scheduleCues(clipCues, d, token),
              ) ||
              played;
        case NamePart():
          await _sayName();
      }
    }
    return played;
  }

  Future<void> _sayName() async {
    final recording = _nameRecording;
    if (recording != null && await _narrator.playFile(recording)) return;
    await _narrator.play(AppConstants.nameFallbackAudio(_language));
  }

  /// Fires each cue at its spot in the clip that just started.
  void _scheduleCues(List<CueTiming> cues, Duration? clip, int token) {
    if (clip == null || _stale(token)) return;
    for (final c in cues) {
      _cueAfter(clip * c.clipFraction, c.cue, token);
    }
  }

  /// No audio: spread cues over the silent pause like the text would be.
  void _scheduleSilentCues(List<CueTiming> cues, int token) {
    for (final c in cues) {
      _cueAfter(_silentSceneDuration * c.textFraction, c.cue, token);
    }
  }

  void _cueAfter(Duration delay, StoryCue cue, int token) {
    _cueTimers.add(
      Timer(delay, () {
        if (_stale(token)) return;
        emit(
          state.copyWith(
            cue: PartCue(
              part: cue.part,
              action: cue.action,
              seq: ++_cueSeq,
              pose: cue.pose,
              to: cue.to,
            ),
          ),
        );
      }),
    );
  }

  void _cancelCues() {
    for (final t in _cueTimers) {
      t.cancel();
    }
    _cueTimers.clear();
  }

  void _offerRewind() {
    final token = _token;
    _speakingToken = token;
    emit(state.copyWith(phase: PlayerPhase.rewindOffer));
    unawaited(
      _narrator
          .play(AppConstants.uiAudio('rewind', _language))
          .whenComplete(() => _doneSpeaking(token)),
    );
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    _cancelCues();
    _token++;
    await _narrator.stop();
    await _narrator.dispose();
    return super.close();
  }
}
