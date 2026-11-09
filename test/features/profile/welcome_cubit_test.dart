import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bedtime_stories/core/models/child_profile.dart';
import 'package:bedtime_stories/core/services/name_voice.dart';
import 'package:bedtime_stories/features/profile/data/profile_storage.dart';
import 'package:bedtime_stories/features/profile/data/sticker_storage.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/language_cubit.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/sticker_cubit.dart';
import 'package:bedtime_stories/features/profile/presentation/cubit/welcome_cubit.dart';

import '../../helpers/fakes.dart';

void main() {
  late ProfileStorage storage;
  late FakeNarrator narrator;
  late FakeNameVoice voice;

  Future<void> setUpPrefs([Map<String, Object> values = const {}]) async {
    SharedPreferences.setMockInitialValues(values);
    storage = ProfileStorage(await SharedPreferences.getInstance());
  }

  WelcomeCubit build(ProfileCubit profiles, {LanguageCubit? language}) =>
      WelcomeCubit(
        profileCubit: profiles,
        nameVoice: voice,
        narrator: narrator,
        languageCubit: language ?? LanguageCubit(storage),
      );

  setUp(() async {
    narrator = FakeNarrator();
    voice = FakeNameVoice();
    await setUpPrefs();
  });

  test('no profile until name and gender are saved', () {
    expect(ProfileCubit(storage).state, isNull);
  });

  test('ignores blank or unknown stored values', () async {
    await setUpPrefs({'child_name_v1': '  ', 'child_gender_v1': 'boy'});
    expect(storage.load(), isNull);
    await setUpPrefs({'child_name_v1': 'Na', 'child_gender_v1': 'cat'});
    expect(storage.load(), isNull);
  });

  test('saves trimmed name and gender, then marks saved', () async {
    final profiles = ProfileCubit(storage);
    final cubit = build(profiles);

    expect(cubit.state.canSave, isFalse);
    cubit
      ..selectGender(Gender.boy)
      ..setName('  Bin ');
    expect(cubit.state.canSave, isTrue);

    await cubit.save();

    const expected = ChildProfile(name: 'Bin', gender: Gender.boy);
    expect(cubit.state.saved, isTrue);
    expect(profiles.state, expected);
    expect(storage.load(), expected);
    await cubit.close();
    expect(narrator.disposed, isTrue);
  });

  test('prefills from existing profile and finds the recording', () async {
    final profiles = ProfileCubit(storage);
    await profiles.save(const ChildProfile(name: 'Na', gender: Gender.girl));
    voice.path = '/docs/child_name.m4a';

    final cubit = build(profiles);
    await cubit.init();

    expect(cubit.state.name, 'Na');
    expect(cubit.state.gender, Gender.girl);
    expect(cubit.state.voice, VoiceStatus.saved);
  });

  test('record then stop saves and plays back the take', () async {
    final cubit = build(ProfileCubit(storage));

    await cubit.toggleRecording();
    expect(cubit.state.voice, VoiceStatus.recording);
    expect(cubit.state.canSave, isFalse);

    await cubit.toggleRecording();
    expect(cubit.state.voice, VoiceStatus.saved);
    expect(narrator.played.last, 'file:/docs/child_name.m4a');
  });

  test('denied mic shows a hint and stays idle', () async {
    voice.allowMic = false;
    final cubit = build(ProfileCubit(storage));

    await cubit.toggleRecording();

    expect(cubit.state.voice, VoiceStatus.none);
    expect(cubit.state.micDenied, isTrue);
  });

  test(
    'each denied try flips micDenied again, so the help dialog reopens',
    () async {
      voice.allowMic = false;
      final cubit = build(ProfileCubit(storage));
      final seen = <bool>[];
      final sub = cubit.stream.listen((s) => seen.add(s.micDenied));

      await cubit.toggleRecording();
      await cubit.toggleRecording();
      await cubit.openMicSettings();
      await sub.cancel();

      expect(seen, [true, false, true]);
      expect(voice.settingsOpened, 1);
    },
  );

  test('preview plays the be clip when there is no recording', () async {
    final cubit = build(ProfileCubit(storage))..setName('Na');
    await cubit.previewName();
    expect(narrator.played.last, 'assets/audio/ui/vi/be.m4a');
  });

  test('renaming drops an old recording of the previous name', () async {
    final profiles = ProfileCubit(storage);
    await profiles.save(const ChildProfile(name: 'Na', gender: Gender.girl));
    voice.path = '/docs/child_name.m4a';

    final cubit = build(profiles)..setName('Bin');
    await cubit.save();

    expect(voice.path, isNull);
  });

  test('renaming keeps a recording made on this visit', () async {
    final profiles = ProfileCubit(storage);
    await profiles.save(const ChildProfile(name: 'Na', gender: Gender.girl));

    final cubit = build(profiles)..setName('Bin');
    await cubit.toggleRecording();
    await cubit.toggleRecording();
    await cubit.save();

    expect(voice.path, isNotNull);
  });

  test('saved profile and language survive a restart (prefs)', () async {
    final profiles = ProfileCubit(storage);
    await profiles.save(const ChildProfile(name: 'Na', gender: Gender.girl));
    await LanguageCubit(storage).select(AppLanguage.en);

    // Same prefs, fresh cubits: what the next app launch sees.
    final prefs = await SharedPreferences.getInstance();
    final again = ProfileStorage(prefs);
    expect(
      ProfileCubit(again).state,
      const ChildProfile(name: 'Na', gender: Gender.girl),
    );
    expect(LanguageCubit(again).state, AppLanguage.en);
  });

  test('language defaults to Vietnamese', () {
    expect(LanguageCubit(storage).state, AppLanguage.vi);
  });

  test('preview uses the English fallback in English', () async {
    final language = LanguageCubit(storage);
    await language.select(AppLanguage.en);
    final cubit = build(ProfileCubit(storage), language: language)
      ..setName('Na');
    await cubit.previewName();
    expect(narrator.played.last, 'assets/audio/ui/en/be.m4a');
  });

  group('mic permission', () {
    test('not asked yet: explain first, record after continue', () async {
      voice.mic = MicStatus.ask;
      final cubit = build(ProfileCubit(storage));

      await cubit.toggleRecording();
      expect(cubit.state.micExplain, isTrue);
      expect(cubit.state.voice, VoiceStatus.none);
      expect(voice.recording, isFalse);

      await cubit.startAfterExplain();
      expect(cubit.state.micExplain, isFalse);
      expect(cubit.state.voice, VoiceStatus.recording);
    });

    test('blocked: straight to the help, no system prompt', () async {
      voice.mic = MicStatus.blocked;
      final cubit = build(ProfileCubit(storage));

      await cubit.toggleRecording();
      expect(cubit.state.micDenied, isTrue);
      expect(cubit.state.micExplain, isFalse);
      expect(voice.recording, isFalse);
    });

    test('refused at the system prompt: help shows', () async {
      voice
        ..mic = MicStatus.ask
        ..allowMic = false;
      final cubit = build(ProfileCubit(storage));

      await cubit.toggleRecording();
      await cubit.startAfterExplain();
      expect(cubit.state.micDenied, isTrue);
    });
  });

  group('stickers', () {
    test('adds per story, totals, and persists', () async {
      final prefs = await SharedPreferences.getInstance();
      final stickers = StickerCubit(StickerStorage(prefs));
      expect(stickers.total, 0);

      await stickers.add('demo', 2);
      await stickers.add('demo', 1);
      await stickers.add('other', 0);
      await stickers.add('other', 1);

      expect(stickers.state, {'demo': 3, 'other': 1});
      expect(stickers.total, 4);
      expect(StickerCubit(StickerStorage(prefs)).state, stickers.state);
    });

    test('ignores broken stored data', () async {
      await setUpPrefs({'stickers_v1': 'not json'});
      final prefs = await SharedPreferences.getInstance();
      expect(StickerStorage(prefs).load(), isEmpty);
    });
  });
}
