import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:bedtime_stories/core/models/child_profile.dart';
import 'package:bedtime_stories/features/stories/domain/entities/story.dart';
import 'package:bedtime_stories/features/stories/domain/repositories/story_repository.dart';

part 'story_list_cubit.freezed.dart';

@freezed
sealed class StoryListState with _$StoryListState {
  const factory StoryListState.loading() = StoryListLoading;
  const factory StoryListState.loaded(List<Story> stories) = StoryListLoaded;
  const factory StoryListState.failure(String message) = StoryListFailure;
}

class StoryListCubit extends Cubit<StoryListState> {
  StoryListCubit({required this._repository})
    : super(const StoryListState.loading());

  final StoryRepository _repository;

  /// (Re)loads in [language]; home calls it again when the language flips.
  Future<void> load(AppLanguage language) async {
    emit(const StoryListState.loading());
    final result = await _repository.getStories(language);
    if (isClosed) return;
    emit(
      result.fold(
        (f) => StoryListState.failure(f.message),
        StoryListState.loaded,
      ),
    );
  }
}
