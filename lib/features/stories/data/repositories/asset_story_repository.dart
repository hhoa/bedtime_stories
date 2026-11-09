import 'dart:convert';
import 'dart:developer';

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:bedtime_stories/core/models/child_profile.dart';
import 'package:bedtime_stories/core/models/failures.dart';
import 'package:bedtime_stories/core/utils/app_constants.dart';
import 'package:bedtime_stories/features/stories/data/models/story_model.dart';
import 'package:bedtime_stories/features/stories/domain/entities/story.dart';
import 'package:bedtime_stories/features/stories/domain/repositories/story_repository.dart';

/// Phase 1: stories bundled under `assets/stories/<id>/story.json`, listed in
/// `assets/stories/index.json`. Replaced by a Firestore repository later.
final class AssetStoryRepository implements StoryRepository {
  AssetStoryRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final Map<String, Story> _cache = {};

  @override
  Future<Either<Failure, List<Story>>> getStories(AppLanguage language) async {
    final List<String> ids;
    try {
      final raw = await _bundle.loadString(AppConstants.storyIndexAsset);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      ids = (json['stories'] as List<dynamic>).cast<String>();
    } catch (e) {
      log('index load failed: $e', name: 'AssetStoryRepository');
      return const Left(NotFoundFailure(AppConstants.storyIndexAsset));
    }

    final stories = <Story>[];
    for (final id in ids) {
      final result = await getStory(id, language);
      // Skip broken stories rather than hiding all of them.
      result.fold(
        (f) => log('skip $id: ${f.message}', name: 'AssetStoryRepository'),
        stories.add,
      );
    }
    return Right(stories);
  }

  @override
  Future<Either<Failure, Story>> getStory(
    String id,
    AppLanguage language,
  ) async {
    final cacheKey = '$id/${language.name}';
    final cached = _cache[cacheKey];
    if (cached != null) return Right(cached);

    final baseDir = '${AppConstants.storiesRoot}/$id';
    final String raw;
    try {
      raw = await _bundle.loadString('$baseDir/story.json');
    } catch (e) {
      return Left(NotFoundFailure('$baseDir/story.json'));
    }

    // Optional: without them every picture is drawn flat and inert.
    final layers = await _optionalJson('$baseDir/images/layers.json');
    final hotspots = await _optionalJson('$baseDir/images/hotspots.json');

    try {
      final model = await compute(_parseStory, raw);
      final story = model.toEntity(
        baseDir: baseDir,
        language: language,
        layers: layers,
        hotspots: hotspots,
      );
      _cache[cacheKey] = story;
      return Right(story);
    } on FormatException catch (e) {
      return Left(ParseFailure('$id: ${e.message}'));
    } catch (e) {
      return Left(ParseFailure('$id: $e'));
    }
  }

  Future<Map<String, dynamic>?> _optionalJson(String path) async {
    try {
      return jsonDecode(await _bundle.loadString(path)) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}

StoryModel _parseStory(String raw) =>
    StoryModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
