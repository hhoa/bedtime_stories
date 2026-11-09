import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:bedtime_stories/core/router/app_routes.dart';
import 'package:bedtime_stories/core/services/analytics.dart';
import 'package:bedtime_stories/core/services/name_voice.dart';
import 'package:bedtime_stories/core/services/narrator.dart';
import 'package:bedtime_stories/features/ending/presentation/cubit/ending_cubit.dart';
import 'package:bedtime_stories/features/ending/presentation/ending_screen.dart';
import 'package:bedtime_stories/features/ending/presentation/sleep_screen.dart';
import 'package:bedtime_stories/features/player/presentation/cubit/player_cubit.dart';
import 'package:bedtime_stories/features/player/presentation/story_player_screen.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/language_cubit.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/welcome_cubit.dart';
import 'package:bedtime_stories/features/profile/presentation/profile_screen.dart';
import 'package:bedtime_stories/features/profile/presentation/welcome_screen.dart';
import 'package:bedtime_stories/features/stories/domain/repositories/story_repository.dart';
import 'package:bedtime_stories/features/stories/presentation/cubit/story_list_cubit.dart';
import 'package:bedtime_stories/features/stories/presentation/home_screen.dart';

GoRouter createRouter({
  required StoryRepository storyRepository,
  required ProfileCubit profileCubit,
  required LanguageCubit languageCubit,
  required NameVoice nameVoice,
  required Analytics analytics,
  List<NavigatorObserver> observers = const [],
}) {
  return GoRouter(
    observers: observers,
    // Nothing works without a name: send first-time users to the welcome
    // page. A saved profile (prefs / localStorage) skips it for good.
    redirect: (context, state) =>
        profileCubit.state == null && state.matchedLocation != AppRoutes.welcome
        ? AppRoutes.welcome
        : null,
    routes: [
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => BlocProvider(
          create: (_) => WelcomeCubit(
            profileCubit: profileCubit,
            nameVoice: nameVoice,
            narrator: createNarrator(),
            languageCubit: languageCubit,
          )..init(),
          child: const WelcomeScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => BlocProvider(
          create: (_) =>
              StoryListCubit(repository: storyRepository)
                ..load(languageCubit.state),
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => BlocProvider(
          create: (_) =>
              StoryListCubit(repository: storyRepository)
                ..load(languageCubit.state),
          child: const ProfileScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.storyPattern,
        builder: (context, state) => BlocProvider(
          create: (context) => PlayerCubit(
            repository: storyRepository,
            narrator: createNarrator(),
            storyId: state.pathParameters['id'] ?? '',
            language: languageCubit.state,
            nameVoice: nameVoice,
            analytics: analytics,
          )..load(),
          child: const StoryPlayerScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.endingPattern,
        // Args only exist in memory; on a web refresh go back home.
        redirect: (context, state) =>
            state.extra is EndingArgs ? null : AppRoutes.home,
        builder: (context, state) {
          final args = state.extra! as EndingArgs;
          return BlocProvider(
            create: (_) => EndingCubit(
              narrator: createNarrator(),
              language: args.story.language,
              stickers: args.goodCount,
            )..start(),
            lazy: false,
            child: EndingScreen(args: args),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.sleep,
        builder: (context, state) => const SleepScreen(),
      ),
    ],
  );
}
