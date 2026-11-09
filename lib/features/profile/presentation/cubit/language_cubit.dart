import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bedtime_stories/core/models/child_profile.dart';
import 'package:bedtime_stories/core/utils/app_strings.dart';
import 'package:bedtime_stories/features/profile/data/profile_storage.dart';

/// App-wide language. Separate from the profile so the welcome page can
/// switch it before a profile exists.
class LanguageCubit extends Cubit<AppLanguage> {
  LanguageCubit(this._storage) : super(_storage.loadLanguage());

  final ProfileStorage _storage;

  Future<void> select(AppLanguage language) async {
    if (language == state) return;
    emit(language);
    await _storage.saveLanguage(language);
  }
}

extension LanguageX on BuildContext {
  /// Reactive: rebuilds when the language changes.
  AppLanguage get language =>
      select<LanguageCubit, AppLanguage>((c) => c.state);

  /// UI text in the current language. Reactive: only inside build.
  AppStrings get strings => AppStrings.of(language);

  /// UI text for callbacks (dialogs, taps), outside build.
  AppStrings get readStrings => AppStrings.of(read<LanguageCubit>().state);
}
