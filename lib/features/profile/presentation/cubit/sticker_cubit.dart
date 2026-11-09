import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bedtime_stories/features/profile/data/sticker_storage.dart';

/// App-wide sticker book: stickers earned per story id. Every finished
/// story adds its stickers (one per good answer), replays included.
class StickerCubit extends Cubit<Map<String, int>> {
  StickerCubit(this._storage) : super(_storage.load());

  final StickerStorage _storage;

  int get total => state.values.fold(0, (a, b) => a + b);

  Future<void> add(String storyId, int count) async {
    if (count <= 0) return;
    final next = {...state, storyId: (state[storyId] ?? 0) + count};
    emit(next);
    await _storage.save(next);
  }
}
