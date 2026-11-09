import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:bedtime_stories/core/models/child_profile.dart';

/// Keeps the child profile and app language in SharedPreferences
/// (localStorage on web), so the welcome page is only shown once. Read
/// synchronously at startup so the router knows whether to show it.
final class ProfileStorage {
  ProfileStorage(this._prefs);

  static const _nameKey = 'child_name_v1';
  static const _genderKey = 'child_gender_v1';
  static const _languageKey = 'app_language_v1';

  final SharedPreferences _prefs;

  ChildProfile? load() {
    final name = _prefs.getString(_nameKey)?.trim();
    final gender = Gender.values.asNameMap()[_prefs.getString(_genderKey)];
    if (name == null || name.isEmpty || gender == null) return null;
    return ChildProfile(name: name, gender: gender);
  }

  Future<bool> save(ChildProfile profile) async {
    try {
      await _prefs.setString(_nameKey, profile.name.trim());
      await _prefs.setString(_genderKey, profile.gender.name);
      return true;
    } catch (e) {
      log('save failed: $e', name: 'ProfileStorage');
      return false;
    }
  }

  /// Vietnamese until the parent picks English.
  AppLanguage loadLanguage() =>
      AppLanguage.values.asNameMap()[_prefs.getString(_languageKey)] ??
      AppLanguage.vi;

  Future<bool> saveLanguage(AppLanguage language) async {
    try {
      return await _prefs.setString(_languageKey, language.name);
    } catch (e) {
      log('saveLanguage failed: $e', name: 'ProfileStorage');
      return false;
    }
  }
}
