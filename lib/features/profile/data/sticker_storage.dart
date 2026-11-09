import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';

/// Stickers earned per story (`{storyId: count}`) in SharedPreferences
/// (localStorage on web).
final class StickerStorage {
  StickerStorage(this._prefs);

  static const _key = 'stickers_v1';

  final SharedPreferences _prefs;

  Map<String, int> load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return const {};
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return {
        for (final MapEntry(:key, :value) in json.entries)
          if (value is int && value > 0) key: value,
      };
    } catch (e) {
      log('load failed: $e', name: 'StickerStorage');
      return const {};
    }
  }

  Future<bool> save(Map<String, int> stickers) async {
    try {
      return await _prefs.setString(_key, jsonEncode(stickers));
    } catch (e) {
      log('save failed: $e', name: 'StickerStorage');
      return false;
    }
  }
}
