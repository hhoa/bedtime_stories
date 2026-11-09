import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:bedtime_stories/core/models/child_profile.dart';
import 'package:bedtime_stories/core/models/failures.dart';
import 'package:bedtime_stories/core/services/analytics.dart';
import 'package:bedtime_stories/core/services/name_voice.dart';
import 'package:bedtime_stories/core/services/narrator.dart';
import 'package:bedtime_stories/features/stories/data/models/story_model.dart';
import 'package:bedtime_stories/features/stories/domain/entities/story.dart';
import 'package:bedtime_stories/features/stories/domain/repositories/story_repository.dart';

/// Test-only story (both languages, a cut part with a pose, hotspots).
const fixtureDir = 'test/fixtures/stories/demo';

/// Reads a story straight from disk (tests run from project root).
Story loadStoryFrom(String baseDir, {AppLanguage language = AppLanguage.vi}) {
  final raw = File('$baseDir/story.json').readAsStringSync();
  Map<String, dynamic>? optional(String name) {
    final f = File('$baseDir/images/$name');
    return f.existsSync()
        ? jsonDecode(f.readAsStringSync()) as Map<String, dynamic>
        : null;
  }

  return StoryModel.fromJson(jsonDecode(raw) as Map<String, dynamic>).toEntity(
    baseDir: baseDir,
    language: language,
    layers: optional('layers.json'),
    hotspots: optional('hotspots.json'),
  );
}

Story loadBundledStory(String id, {AppLanguage language = AppLanguage.vi}) =>
    loadStoryFrom('assets/stories/$id', language: language);

Story loadFixtureStory({AppLanguage language = AppLanguage.vi}) =>
    loadStoryFrom(fixtureDir, language: language);

/// Serves fixture files from disk (they are not in pubspec assets), the
/// rest (asset manifest, fonts, real assets) from the app bundle. Wrap
/// widgets with `DefaultAssetBundle`.
final class DiskAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final file = File(key);
    if (!key.startsWith('test/') || !file.existsSync()) {
      return rootBundle.load(key);
    }
    return ByteData.sublistView(await file.readAsBytes());
  }
}

/// Finishes every clip instantly and records what was played.
/// Files show up as `file:<path>`.
final class FakeNarrator implements Narrator {
  final played = <String>[];
  bool disposed = false;

  /// When set, every clip reports and takes this long (so narration cues
  /// can fire). Null = clips end instantly with unknown length.
  Duration? clipDuration;

  @override
  Future<bool> play(
    String assetPath, {
    void Function(Duration? duration)? onStart,
  }) async {
    played.add(assetPath);
    if (!preloaded.contains(assetPath)) notPreloaded.add(assetPath);
    final d = clipDuration;
    onStart?.call(d);
    if (d != null) await Future<void>.delayed(d);
    return true;
  }

  @override
  Future<bool> playFile(String path) async {
    played.add('file:$path');
    return true;
  }

  /// Paths passed to [preload], in order.
  final preloaded = <String>[];

  /// Clips played before anyone asked to preload them.
  final notPreloaded = <String>[];

  @override
  Future<void> preload(List<String> assetPaths) async =>
      preloaded.addAll(assetPaths);

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async => disposed = true;
}

/// In-memory recording. [allowMic] false simulates denied permission.
final class FakeNameVoice implements NameVoice {
  FakeNameVoice({
    this.path,
    this.allowMic = true,
    this.mic = MicStatus.granted,
  });

  /// What [micStatus] reports.
  MicStatus mic;

  String? path;
  bool allowMic;
  bool recording = false;
  bool disposed = false;

  @override
  Future<String?> recordingPath() async => path;

  @override
  Future<MicStatus> micStatus() async => mic;

  @override
  Future<bool> startRecording() async => recording = allowMic;

  @override
  Future<bool> stopRecording() async {
    if (!recording) return false;
    recording = false;
    path = '/docs/child_name.m4a';
    return true;
  }

  @override
  Future<void> cancelRecording() async => recording = false;

  @override
  Future<void> deleteRecording() async => path = null;

  int settingsOpened = 0;

  @override
  Future<bool> openMicSettings() async {
    settingsOpened++;
    return true;
  }

  @override
  Future<void> dispose() async => disposed = true;
}

final class FakeStoryRepository implements StoryRepository {
  FakeStoryRepository(this.stories);

  final Map<String, Story> stories;

  /// Languages asked for, in order.
  final languages = <AppLanguage>[];

  @override
  Future<Either<Failure, List<Story>>> getStories(AppLanguage language) async {
    languages.add(language);
    return Right(stories.values.toList());
  }

  @override
  Future<Either<Failure, Story>> getStory(
    String id,
    AppLanguage language,
  ) async {
    languages.add(language);
    final story = stories[id];
    return story == null ? Left(NotFoundFailure(id)) : Right(story);
  }
}

/// Records events as `name:param/param...` strings.
final class FakeAnalytics implements Analytics {
  final events = <String>[];
  Gender? heroGender;

  @override
  Future<void> storyStart(String storyId, AppLanguage language) async =>
      events.add('story_start:$storyId/${language.name}');

  @override
  Future<void> storyChoice({
    required String storyId,
    required String nodeId,
    required String optionId,
    required ChoiceKind kind,
  }) async =>
      events.add('story_choice:$storyId/$nodeId/$optionId/${kind.name}');

  @override
  Future<void> storyRewind({
    required String storyId,
    required String nodeId,
  }) async => events.add('story_rewind:$storyId/$nodeId');

  @override
  Future<void> storyComplete({
    required String storyId,
    required String endingId,
    required int goodAnswers,
  }) async => events.add('story_complete:$storyId/$endingId/$goodAnswers');

  @override
  Future<void> setHeroGender(Gender gender) async => heroGender = gender;
}

/// Lets queued microtasks and zero-length timers run.
Future<void> settle() async {
  for (var i = 0; i < 50; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}
