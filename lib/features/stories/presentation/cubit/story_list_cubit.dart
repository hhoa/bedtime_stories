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
  /// Lists only [section]'s stories when given (a section page), else all
  /// (profile sticker book).
  StoryListCubit({required this._repository, this.section})
    : super(const StoryListState.loading());

  final StoryRepository _repository;
  final StorySection? section;

  /// (Re)loads in [language]; home calls it again when the language flips.
  /// A reload keeps the current cards on screen (no spinner, no cover
  /// reload) until the new list arrives.
  Future<void> load(AppLanguage language) async {
    if (state is! StoryListLoaded) emit(const StoryListState.loading());
    final result = await _repository.getStories(language, section: section);
    if (isClosed) return;
    emit(
      result.fold(
        (f) => StoryListState.failure(f.message),
        StoryListState.loaded,
      ),
    );
  }
}
