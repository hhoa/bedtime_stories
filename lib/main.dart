import 'dart:async';
import 'dart:developer';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bedtime_stories/core/router/app_router.dart';
import 'package:bedtime_stories/core/services/analytics.dart';
import 'package:bedtime_stories/core/services/name_voice.dart';
import 'package:bedtime_stories/core/theme/app_theme.dart';
import 'package:bedtime_stories/core/models/child_profile.dart';
import 'package:bedtime_stories/core/utils/app_strings.dart';
import 'package:bedtime_stories/features/profile/data/profile_storage.dart';
import 'package:bedtime_stories/features/profile/data/sticker_storage.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/language_cubit.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/sticker_cubit.dart';
import 'package:bedtime_stories/features/stories/data/repositories/asset_story_repository.dart';
import 'package:bedtime_stories/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    final ofl = await rootBundle.loadString('assets/fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['BeVietnamPro', 'Baloo2'], ofl);
  });

  final analytics = await _startAnalytics();
  final prefs = await SharedPreferences.getInstance();
  final storage = ProfileStorage(prefs);
  final profileCubit = ProfileCubit(storage);
  final languageCubit = LanguageCubit(storage);
  final stickerCubit = StickerCubit(StickerStorage(prefs));
  _trackHeroGender(profileCubit, analytics);
  final router = createRouter(
    storyRepository: AssetStoryRepository(),
    profileCubit: profileCubit,
    languageCubit: languageCubit,
    nameVoice: RecordNameVoice(prefs),
    analytics: analytics,
    observers: [if (analytics is FirebaseAppAnalytics) analytics.observer],
  );

  runApp(
    BedtimeApp(
      profileCubit: profileCubit,
      languageCubit: languageCubit,
      stickerCubit: stickerCubit,
      router: router,
    ),
  );
}

/// Firebase is optional: the app plays stories fine without it.
Future<Analytics> _startAnalytics() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final analytics = FirebaseAppAnalytics(FirebaseAnalytics.instance);
    await analytics.applyKidsConsent();
    return analytics;
  } catch (e) {
    log('Firebase init failed: $e', name: 'main');
    return const NoopAnalytics();
  }
}

/// Keeps the `hero_gender` user property in sync with the profile.
void _trackHeroGender(ProfileCubit profileCubit, Analytics analytics) {
  final gender = profileCubit.state?.gender;
  if (gender != null) unawaited(analytics.setHeroGender(gender));
  profileCubit.stream.map((profile) => profile?.gender).distinct().listen((
    gender,
  ) {
    if (gender != null) unawaited(analytics.setHeroGender(gender));
  });
}

class BedtimeApp extends StatelessWidget {
  const BedtimeApp({
    required this.profileCubit,
    required this.languageCubit,
    required this.stickerCubit,
    required this.router,
    super.key,
  });

  final ProfileCubit profileCubit;
  final LanguageCubit languageCubit;
  final StickerCubit stickerCubit;
  final GoRouter router;

  static Locale _locale(AppLanguage language) => switch (language) {
    AppLanguage.vi => const Locale('vi', 'VN'),
    AppLanguage.en => const Locale('en', 'US'),
  };

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: profileCubit),
        BlocProvider.value(value: languageCubit),
        BlocProvider.value(value: stickerCubit),
      ],
      child: BlocBuilder<LanguageCubit, AppLanguage>(
        builder: (context, language) => MaterialApp.router(
          title: AppStrings.of(language).appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.night,
          routerConfig: router,
          builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
            value: AppTheme.overlayStyle,
            child: child!,
          ),
          // No scrollbars anywhere (they look out of place on web).
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            scrollbars: false,
          ),
          locale: _locale(language),
          supportedLocales: [for (final l in AppLanguage.values) _locale(l)],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );
  }
}
