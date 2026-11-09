import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:bedtime_stories/core/models/child_profile.dart';
import 'package:bedtime_stories/core/utils/app_constants.dart';
import 'package:bedtime_stories/core/services/name_voice.dart';
import 'package:bedtime_stories/core/services/narrator.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/language_cubit.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/profile_cubit.dart';

part 'welcome_cubit.freezed.dart';

enum VoiceStatus { none, recording, saved }

@freezed
abstract class WelcomeState with _$WelcomeState {
  const WelcomeState._();

  const factory WelcomeState({
    Gender? gender,
    @Default('') String name,
    @Default(VoiceStatus.none) VoiceStatus voice,

    /// Mic not allowed: show how to turn it on.
    @Default(false) bool micDenied,

    /// Mic not asked yet: explain the system prompt before it shows.
    @Default(false) bool micExplain,
    @Default(false) bool saving,

    /// Set once the profile is stored; the screen then leaves.
    @Default(false) bool saved,
  }) = _WelcomeState;

  bool get canSave =>
      gender != null &&
      name.trim().isNotEmpty &&
      !saving &&
      voice != VoiceStatus.recording;
}

/// Welcome page form: pick girl/boy, type the name, optionally record it.
/// Prefilled from [ProfileCubit] when editing an existing profile.
///
/// Owns [narrator] and disposes it on close.
class WelcomeCubit extends Cubit<WelcomeState> {
  WelcomeCubit({
    required this._profileCubit,
    required this._nameVoice,
    required this._narrator,
    required this._languageCubit,
  }) : _savedName = _profileCubit.state?.name,
       super(
         WelcomeState(
           gender: _profileCubit.state?.gender,
           name: _profileCubit.state?.name ?? '',
         ),
       );

  final ProfileCubit _profileCubit;
  final NameVoice _nameVoice;
  final Narrator _narrator;
  final LanguageCubit _languageCubit;
  final String? _savedName;

  /// True when the current recording was made on this visit, so it matches
  /// the name typed now.
  bool _recordedNow = false;

  Future<void> init() async {
    final path = await _nameVoice.recordingPath();
    if (isClosed || path == null) return;
    emit(state.copyWith(voice: VoiceStatus.saved));
  }

  void selectGender(Gender gender) => emit(state.copyWith(gender: gender));

  void setName(String name) => emit(state.copyWith(name: name));

  Future<void> toggleRecording() async {
    if (state.voice == VoiceStatus.recording) {
      final ok = await _nameVoice.stopRecording();
      if (isClosed) return;
      _recordedNow = _recordedNow || ok;
      final path = await _nameVoice.recordingPath();
      if (isClosed) return;
      emit(
        state.copyWith(
          voice: path != null ? VoiceStatus.saved : VoiceStatus.none,
        ),
      );
      // Play the take back so the parent hears what stories will use.
      if (ok && path != null) unawaited(_narrator.playFile(path));
      return;
    }
    await _narrator.stop();
    // Cleared first so the next time shows the dialog again.
    if (state.micDenied || state.micExplain) {
      emit(state.copyWith(micDenied: false, micExplain: false));
    }
    switch (await _nameVoice.micStatus()) {
      case MicStatus.granted:
        await _start();
      case MicStatus.ask:
        if (!isClosed) emit(state.copyWith(micExplain: true));
      case MicStatus.blocked:
        if (!isClosed) emit(state.copyWith(micDenied: true));
    }
  }

  /// From the "the phone will ask" dialog: now let the system ask.
  Future<void> startAfterExplain() async {
    emit(state.copyWith(micExplain: false));
    await _start();
  }

  Future<void> _start() async {
    if (isClosed) return;
    final started = await _nameVoice.startRecording();
    if (isClosed) return;
    emit(
      state.copyWith(
        voice: started ? VoiceStatus.recording : state.voice,
        micDenied: !started,
      ),
    );
  }

  /// From the mic help dialog: the app's Settings page (device only).
  Future<void> openMicSettings() => _nameVoice.openMicSettings();

  Future<void> deleteRecording() async {
    await _narrator.stop();
    await _nameVoice.deleteRecording();
    _recordedNow = false;
    if (!isClosed) emit(state.copyWith(voice: VoiceStatus.none));
  }

  /// Plays the name the way stories will say it.
  Future<void> previewName() async {
    final name = state.name.trim();
    if (state.voice == VoiceStatus.recording) return;
    await _narrator.stop();
    final path = await _nameVoice.recordingPath();
    if (path != null && await _narrator.playFile(path)) return;
    if (name.isNotEmpty) {
      await _narrator.play(
        AppConstants.nameFallbackAudio(_languageCubit.state),
      );
    }
  }

  Future<void> save() async {
    final gender = state.gender;
    final name = state.name.trim();
    if (!state.canSave || gender == null) return;
    emit(state.copyWith(saving: true));
    await _narrator.stop();
    // An old recording of a different name would make stories say the
    // wrong name, so drop it unless it was re-recorded just now.
    if (_savedName != null && _savedName != name && !_recordedNow) {
      await _nameVoice.deleteRecording();
    }
    final ok = await _profileCubit.save(
      ChildProfile(name: name, gender: gender),
    );
    if (!isClosed) emit(state.copyWith(saving: false, saved: ok));
  }

  @override
  Future<void> close() async {
    if (state.voice == VoiceStatus.recording) {
      await _nameVoice.cancelRecording();
    }
    await _narrator.stop();
    await _narrator.dispose();
    return super.close();
  }
}
