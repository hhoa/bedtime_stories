import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bedtime_stories/core/models/child_profile.dart';
import 'package:bedtime_stories/core/utils/app_strings.dart';
import 'package:bedtime_stories/features/ending/presentation/ending_screen.dart';
import 'package:bedtime_stories/features/profile/data/profile_storage.dart';
import 'package:bedtime_stories/features/profile/data/sticker_storage.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/language_cubit.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/sticker_cubit.dart';
import 'package:bedtime_stories/features/profile/presentation/profile_screen.dart';
import 'package:bedtime_stories/features/stories/domain/entities/story.dart';
import 'package:bedtime_stories/features/stories/presentation/cubit/story_list_cubit.dart';
import 'package:bedtime_stories/features/stories/presentation/home_screen.dart';
import 'package:bedtime_stories/features/stories/presentation/widgets/story_card.dart';

import '../helpers/fakes.dart';

void main() {
  late LanguageCubit language;
  late StickerCubit stickers;
  late FakeStoryRepository repository;

  Future<void> pumpScreen(
    WidgetTester tester,
    Widget screen, {
    Map<String, Story> stories = const {},
    Map<String, Object> prefs = const {},
  }) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({
      'child_name_v1': 'Na',
      'child_gender_v1': 'girl',
      ...prefs,
    });
    final p = await SharedPreferences.getInstance();
    final storage = ProfileStorage(p);
    language = LanguageCubit(storage);
    stickers = StickerCubit(StickerStorage(p));
    repository = FakeStoryRepository(stories);
    await tester.pumpWidget(
      DefaultAssetBundle(
        bundle: DiskAssetBundle(),
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ProfileCubit(storage)),
            BlocProvider.value(value: language),
            BlocProvider.value(value: stickers),
            BlocProvider(
              create: (_) =>
                  StoryListCubit(repository: repository)..load(language.state),
            ),
          ],
          child: MaterialApp(home: screen),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> finish(WidgetTester tester) async {
    expect(tester.takeException(), isNull);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpWidget(const SizedBox());
  }

  group('home', () {
    testWidgets('no stories yet: friendly message, no grid', (tester) async {
      await pumpScreen(tester, const HomeScreen());
      expect(find.text(const AppStringsVi().noStories), findsOneWidget);
      expect(find.byType(GridView), findsNothing);
      await finish(tester);
    });

    testWidgets('lazy grid of story cards, avatar shows stickers', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        const HomeScreen(),
        stories: {'demo': loadFixtureStory()},
        prefs: {'stickers_v1': '{"demo": 3}'},
      );
      expect(find.byType(GridView), findsOneWidget);
      expect(find.byType(StoryCard), findsOneWidget);
      expect(find.text('Na và Lulu đi ngủ'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      await finish(tester);
    });

    testWidgets('switching language reloads stories in English', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        const HomeScreen(),
        stories: {'demo': loadFixtureStory()},
      );
      await language.select(AppLanguage.en);
      await tester.pump(const Duration(milliseconds: 300));
      expect(repository.languages, [AppLanguage.vi, AppLanguage.en]);
      await finish(tester);
    });
  });

  group('profile', () {
    testWidgets('shows total and each story sticker with its count', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        const ProfileScreen(),
        stories: {'demo': loadFixtureStory()},
        prefs: {'stickers_v1': '{"demo": 2}'},
      );
      expect(find.text('Na'), findsOneWidget);
      expect(find.text(const AppStringsVi().stickerTotal(2)), findsOneWidget);
      expect(find.text('×2'), findsOneWidget);
      expect(find.text(const AppStringsVi().noStickersYet), findsNothing);
      await finish(tester);
    });

    testWidgets('no stickers yet: encouragement, faded sticker', (
      tester,
    ) async {
      await pumpScreen(
        tester,
        const ProfileScreen(),
        stories: {'demo': loadFixtureStory()},
      );
      expect(find.text(const AppStringsVi().noStickersYet), findsOneWidget);
      expect(find.byType(ColorFiltered), findsOneWidget);
      await finish(tester);
    });
  });

  group('ending', () {
    testWidgets('one sticker per good answer', (tester) async {
      final story = loadFixtureStory();
      await pumpScreen(
        tester,
        EndingScreen(
          args: EndingArgs(story: story, goodCount: 2, choiceCount: 2),
        ),
      );
      await tester.pump(const Duration(seconds: 2));
      expect(find.text(const AppStringsVi().stickersEarned(2)), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) => w.runtimeType.toString() == '_Sticker'),
        findsNWidgets(2),
      );
      await finish(tester);
    });

    testWidgets('no good answer: no sticker, gentle nudge', (tester) async {
      final story = loadFixtureStory();
      await pumpScreen(
        tester,
        EndingScreen(
          args: EndingArgs(story: story, goodCount: 0, choiceCount: 2),
        ),
      );
      await tester.pump(const Duration(seconds: 2));
      expect(find.text(const AppStringsVi().noSticker), findsOneWidget);
      expect(
        find.byWidgetPredicate((w) => w.runtimeType.toString() == '_Sticker'),
        findsNothing,
      );
      await finish(tester);
    });
  });
}
