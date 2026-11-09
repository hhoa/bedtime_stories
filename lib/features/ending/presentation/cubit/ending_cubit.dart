import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bedtime_stories/core/models/child_profile.dart';
import 'package:bedtime_stories/core/services/narrator.dart';
import 'package:bedtime_stories/core/utils/app_constants.dart';

/// Reads the sticker line aloud on the ending page (the kid can't read):
/// "you got 2 stickers" / "try another choice next time".
///
/// Owns [narrator] and disposes it on close.
class EndingCubit extends Cubit<void> {
  EndingCubit({
    required this._narrator,
    required this._language,
    required this._stickers,
    this._delay = const Duration(milliseconds: 900),
  }) : super(null);

  final Narrator _narrator;
  final AppLanguage _language;
  final int _stickers;
  final Duration _delay;
  Timer? _timer;

  /// Waits for the sticker to pop in, then speaks.
  void start() {
    _timer = Timer(_delay, () {
      if (isClosed) return;
      unawaited(
        _narrator.play(AppConstants.stickerAudio(_stickers, _language)),
      );
    });
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    await _narrator.stop();
    await _narrator.dispose();
    return super.close();
  }
}
