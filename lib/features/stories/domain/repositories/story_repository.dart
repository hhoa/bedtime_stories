import 'package:dartz/dartz.dart';
import 'package:bedtime_stories/core/models/child_profile.dart';
import 'package:bedtime_stories/core/models/failures.dart';
import 'package:bedtime_stories/features/stories/domain/entities/story.dart';

abstract interface class StoryRepository {
  /// Stories the kid may see (phase 1: everything bundled), in [language].
  Future<Either<Failure, List<Story>>> getStories(AppLanguage language);

  Future<Either<Failure, Story>> getStory(String id, AppLanguage language);
}
