import 'package:flutter_test/flutter_test.dart';
import 'package:bedtime_stories/core/models/child_profile.dart';
import 'package:bedtime_stories/features/player/presentation/cubit/player_cubit.dart';
import 'package:bedtime_stories/features/player/presentation/cubit/player_state.dart';

import '../../helpers/fakes.dart';

const _audio = '$fixtureDir/audio/vi';
const _be = 'assets/audio/ui/vi/be.m4a';
const _rewind = 'assets/audio/ui/vi/rewind.m4a';

void main() {
  late FakeNarrator narrator;
  late PlayerCubit cubit;
  late FakeAnalytics analytics;
  late FakeStoryRepository repository;

  PlayerCubit build({
    String? recording,
    AppLanguage language = AppLanguage.vi,
  }) {
    repository = FakeStoryRepository({
      'demo': loadFixtureStory(language: language),
    });
    return PlayerCubit(
      repository: repository,
      narrator: narrator,
      storyId: 'demo',
      language: language,
      nameVoice: FakeNameVoice(path: recording),
      analytics: analytics,
      autoAdvanceDelay: Duration.zero,
      silentSceneDuration: Duration.zero,
      choiceCelebrateDelay: Duration.zero,
      choiceOptionGap: Duration.zero,
    );
  }

  setUp(() {
    narrator = FakeNarrator();
    analytics = FakeAnalytics();
    cubit = build();
  });

  tearDown(() => cubit.close());

  Future<void> chooseAndSettle(String option) async {
    cubit.choose(option);
    await settle();
  }

  test('auto-advances intro scenes and stops at first choice', () async {
    await cubit.load();
    await settle();

    expect(cubit.state.nodeId, 'c1');
    expect(cubit.state.phase, PlayerPhase.choosing);
    // Name only in questions, at the start or end: one clip + the name.
    // No recording: the bundled "bé" clip stands in for it.
    expect(narrator.played, [
      '$_audio/s1.m4a',
      '$_audio/s2_p0.m4a',
      _be,
      _be,
      '$_audio/c1_p1.m4a',
      '$_audio/c1_bed.m4a',
      '$_audio/c1_play.m4a',
    ]);
  });

  test('English plays English clips and the English name fallback', () async {
    await cubit.close();
    narrator = FakeNarrator();
    cubit = build(language: AppLanguage.en);
    await cubit.load();
    await settle();

    expect(repository.languages, [AppLanguage.en]);
    expect(narrator.played.take(3), [
      '$fixtureDir/audio/en/s1.m4a',
      '$fixtureDir/audio/en/s2_p0.m4a',
      'assets/audio/ui/en/be.m4a',
    ]);
    expect(analytics.events.first, 'story_start:demo/en');
  });

  test('preloads the first node, rewind line and name first', () async {
    await cubit.close();
    narrator = FakeNarrator();
    cubit = build(recording: '/docs/child_name.wav');
    await cubit.load();

    expect(narrator.preloaded.take(3), [
      '$_audio/s1.m4a',
      _rewind,
      '/docs/child_name.wav',
    ]);
  });

  test('preloads the be clip when there is no recording', () async {
    await cubit.load();
    expect(narrator.preloaded, contains(_be));
  });

  test('preloads one step ahead, never the whole story', () async {
    await cubit.load();
    await settle();

    final story = loadFixtureStory();
    // At c1: both option branches are loaded, nothing past them.
    expect(narrator.preloaded, containsAll(story.nodeClips('a1')));
    expect(narrator.preloaded, containsAll(story.nodeClips('b1')));
    expect(narrator.preloaded, isNot(containsAll(story.nodeClips('d1'))));

    await chooseAndSettle('play');
    expect(narrator.notPreloaded, isEmpty);
  });

  test('every clip played on a full run was preloaded first', () async {
    await cubit.load();
    await settle();
    await chooseAndSettle('bed');
    expect(cubit.state.nodeId, 'c2');
    await chooseAndSettle('stars');
    expect(cubit.state.phase, PlayerPhase.finished);
    expect(narrator.notPreloaded, isEmpty);
  });

  test('Story.nextIds and clipPaths', () {
    final story = loadFixtureStory();
    expect(story.nextIds('s1'), ['s2']);
    expect(story.nextIds('c1'), ['a1', 'b1']);
    expect(story.nextIds('b3'), ['n1', 'c1']);
    expect(story.nextIds('end'), isEmpty);
    expect(story.clipPaths, contains('$_audio/c1_bed.m4a'));
    expect(story.clipPaths.toSet().length, story.clipPaths.length);
  });

  test('uses the parent recording for the name when there is one', () async {
    await cubit.close();
    narrator = FakeNarrator();
    cubit = build(recording: '/docs/child_name.wav');
    await cubit.load();
    await settle();

    expect(narrator.played.skip(1).take(2), [
      '$_audio/s2_p0.m4a',
      'file:/docs/child_name.wav',
    ]);
    expect(narrator.played, isNot(contains(_be)));
  });

  test('learn path offers rewind; rewind drops the choice', () async {
    await cubit.load();
    await settle();

    await chooseAndSettle('play');
    expect(cubit.state.nodeId, 'b3');
    expect(cubit.state.phase, PlayerPhase.rewindOffer);
    expect(cubit.state.path, hasLength(1));
    expect(narrator.played.last, _rewind);

    cubit.rewind();
    await settle();
    expect(cubit.state.nodeId, 'c1');
    expect(cubit.state.path, isEmpty);
    expect(analytics.events, [
      'story_start:demo/vi',
      'story_choice:demo/c1/play/learn',
      'story_rewind:demo/c1',
    ]);
  });

  test('two kind first picks = two good answers', () async {
    await cubit.load();
    await settle();

    await chooseAndSettle('bed');
    await chooseAndSettle('stars');
    expect(cubit.state.nodeId, 'end');
    expect(cubit.state.phase, PlayerPhase.finished);
    expect(cubit.state.goodCount, 2);
    expect(cubit.state.firstPicks, hasLength(2));
    expect(analytics.events.last, 'story_complete:demo/end/2');
  });

  test('a rewind then the kind option does not count as good', () async {
    await cubit.load();
    await settle();

    await chooseAndSettle('play');
    cubit.rewind();
    await settle();
    await chooseAndSettle('bed');
    await chooseAndSettle('stars');

    expect(cubit.state.phase, PlayerPhase.finished);
    expect(cubit.state.goodCount, 1);
    expect(cubit.state.firstPicks['c1'], isNot(cubit.state.firstPicks['c2']));
  });

  test('keep going after learn path continues the story', () async {
    await cubit.load();
    await settle();

    await chooseAndSettle('play');
    cubit.keepGoing();
    await settle();

    expect(cubit.state.nodeId, 'c2');
    expect(cubit.state.goodCount, 0);
  });

  test('ignores a second tap while celebrating the first', () async {
    await cubit.load();
    await settle();

    cubit
      ..choose('bed')
      ..choose('play');
    expect(cubit.state.path.single.optionId, 'bed');
  });

  test('close disposes narrator', () async {
    await cubit.close();
    expect(narrator.disposed, isTrue);
  });

  test('fires narration cues while the clip plays', () async {
    narrator.clipDuration = const Duration(milliseconds: 40);
    final cues = <PartCue>[];
    final sub = cubit.stream.listen((s) {
      final cue = s.cue;
      if (cue != null && (cues.isEmpty || cues.last != cue)) cues.add(cue);
    });
    await cubit.load();
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await sub.cancel();

    // s1: clock on "Tích tắc"; s2: Lulu hops twice on "Tưng, tưng".
    expect(cues.map((c) => '${c.part}:${c.action.name}'), [
      'clock:wiggle',
      'lulu:hop',
      'lulu:hop',
    ]);
    expect(cues.map((c) => c.seq).toSet(), hasLength(3));
  });
}
