import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bedtime_stories/core/models/child_profile.dart';
import 'package:bedtime_stories/core/services/name_voice.dart';
import 'package:bedtime_stories/core/utils/app_strings.dart';
import 'package:bedtime_stories/features/profile/data/profile_storage.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/language_cubit.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/welcome_cubit.dart';
import 'package:bedtime_stories/features/profile/presentation/welcome_screen.dart';

import '../../helpers/fakes.dart';

void main() {
  late FakeNameVoice voice;
  late WelcomeCubit cubit;
  late LanguageCubit language;

  Future<void> pumpWelcome(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    AppLanguage lang = AppLanguage.vi,
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues({});
    final storage = ProfileStorage(await SharedPreferences.getInstance());
    final profiles = ProfileCubit(storage);
    language = LanguageCubit(storage);
    await language.select(lang);
    cubit = WelcomeCubit(
      profileCubit: profiles,
      nameVoice: voice,
      narrator: FakeNarrator(),
      languageCubit: language,
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: profiles),
          BlocProvider.value(value: language),
          BlocProvider.value(value: cubit),
        ],
        child: const MaterialApp(home: WelcomeScreen()),
      ),
    );
    // Stars twinkle forever, so pump a fixed time instead of settling.
    await tester.pump(const Duration(seconds: 2));
  }

  setUp(() => voice = FakeNameVoice());

  const sizes = {
    'small phone': Size(375, 667),
    'phone landscape': Size(667, 375),
    'tall phone': Size(390, 844),
    'tablet landscape': Size(1024, 768),
    'tablet portrait': Size(820, 1180),
  };

  for (final MapEntry(key: name, value: size) in sizes.entries) {
    for (final lang in AppLanguage.values) {
      testWidgets('$name, ${lang.name}: fits without scrolling', (
        tester,
      ) async {
        await pumpWelcome(tester, size: size, lang: lang);
        expect(tester.takeException(), isNull, reason: 'overflow');
        // Page never scrolls (the text field's own scrollable aside).
        expect(find.byType(SingleChildScrollView), findsNothing);
        expect(find.byType(ListView), findsNothing);
        final strings = AppStrings.of(lang);
        for (final text in [strings.girl, strings.boy, strings.letsGo]) {
          expect(find.text(text), findsOneWidget);
          final rect = tester.getRect(find.text(text));
          expect(rect.bottom, lessThanOrEqualTo(size.height), reason: text);
        }
        expect(find.text(strings.recordName), findsOneWidget);
      });
    }
  }

  testWidgets('picking hero and name enables start', (tester) async {
    await pumpWelcome(tester);
    await tester.tap(find.text(const AppStringsVi().boy));
    await tester.enterText(find.byType(TextFormField), 'Bin');
    await tester.pump();

    expect(cubit.state.gender, Gender.boy);
    expect(cubit.state.canSave, isTrue);
  });

  testWidgets('language toggle switches the page to English', (tester) async {
    await pumpWelcome(tester);
    await tester.tap(find.text('EN'));
    await tester.pump();
    expect(language.state, AppLanguage.en);
    expect(find.text(const AppStringsEn().letsGo), findsOneWidget);
  });

  testWidgets('mic not asked yet: explain dialog, then recording', (
    tester,
  ) async {
    voice.mic = MicStatus.ask;
    await pumpWelcome(tester);
    const strings = AppStringsVi();

    await tester.tap(find.text(strings.recordName));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(strings.micAskTitle), findsOneWidget);
    expect(voice.recording, isFalse);

    await tester.tap(find.text(strings.continueLabel));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(strings.micAskTitle), findsNothing);
    expect(voice.recording, isTrue);
    expect(cubit.state.voice, VoiceStatus.recording);
  });

  testWidgets('mic blocked: help dialog with a Settings button', (
    tester,
  ) async {
    voice.mic = MicStatus.blocked;
    await pumpWelcome(tester);
    const strings = AppStringsVi();

    await tester.tap(find.text(strings.recordName));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(strings.micHelpTitle), findsOneWidget);
    await tester.tap(find.text(strings.openSettings));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(voice.settingsOpened, 1);
    expect(find.text(strings.micHelpTitle), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('help button opens the mic steps any time', (tester) async {
    await pumpWelcome(tester);
    await tester.tap(find.byIcon(Icons.help_outline_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text(const AppStringsVi().micHelpTitle), findsOneWidget);
  });
}
