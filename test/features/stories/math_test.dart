import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:bedtime_stories/core/models/child_profile.dart';
import 'package:bedtime_stories/features/player/presentation/cubit/player_cubit.dart';
import 'package:bedtime_stories/features/player/presentation/cubit/player_state.dart';
import 'package:bedtime_stories/features/stories/data/models/story_model.dart';
import 'package:bedtime_stories/features/stories/domain/entities/story.dart';

import '../../helpers/fakes.dart';

Map<String, String> _t(String vi, [String? en]) => {'vi': vi, 'en': en ?? vi};

/// 2 + 1-ish story: a in 1..3, b in 1..(4 - a), c = a + b.
Map<String, dynamic> _mathStory({
  Map<String, dynamic>? vars,
  Map<String, dynamic>? counted,
  String question = '{a} bạn cừu thêm {b} bạn nữa. Có mấy bạn?',
}) => {
  'id': 'm',
  'theme': 'addition',
  'section': 'math',
  'hero': 'girl',
  'title': _t('Đếm cừu'),
  'cover': 'c.webp',
  'start': 's1',
  'math': {
    'counter': 'sheep',
    'icon': 'images/sheep.webp',
    'vars':
        vars ??
        {
          'a': [1, 3],
          'b': [1, '4 - a'],
          'c': 'a + b',
        },
    'field': [
      [0.1, 0.8],
      [0.2, 0.8],
      [0.3, 0.8],
      [0.4, 0.8],
      [0.5, 0.8],
    ],
    'wait': [
      [0.8, 0.7],
      [0.9, 0.7],
      [0.85, 0.6],
    ],
  },
  'nodes': [
    {
      'id': 's1',
      'type': 'scene',
      'image': 'i.webp',
      'text': _t('Bên cửa có {b} bạn cừu nữa. Nhảy qua!'),
      'next': 'c1',
      'counted': counted ?? {'field': 'a', 'wait': 'b'},
      'cues': {
        'vi': [
          {'word': 'Nhảy qua', 'part': 'sheep', 'action': 'arrive'},
        ],
        'en': [
          {'word': 'Nhảy qua', 'part': 'sheep', 'action': 'arrive'},
        ],
      },
    },
    {
      'id': 'c1',
      'type': 'choice',
      'image': 'i.webp',
      'text': _t(question),
      'counted': {'field': 'c'},
      'options': [
        {
          'id': 'right',
          'kind': 'kind',
          'answer': 'c',
          'label': _t('{n} bạn cừu', '{n} sheep'),
          'next': 'a1',
        },
        {
          'id': 'near',
          'kind': 'learn',
          'answer': 'near:c',
          'label': _t('{n} bạn cừu', '{n} sheep'),
          'next': 'b1',
        },
      ],
    },
    {
      'id': 'b1',
      'type': 'scene',
      'image': 'i.webp',
      'text': _t('Mình cùng đếm lại nhé! {count:c}!'),
      'next': 'a1',
      'offer_rewind_to': 'c1',
      'counted': {'field': 'c'},
    },
    {
      'id': 'a1',
      'type': 'scene',
      'image': 'i.webp',
      'text': _t('{c} bạn cừu đây rồi! {count:c}!'),
      'next': 'end',
      'counted': {'field': 'c'},
    },
    {
      'id': 'end',
      'type': 'ending',
      'image': 'i.webp',
      'sticker': 's.webp',
      'text': _t('Các bạn cừu ngủ rồi. {count:c:sleep}.'),
      'counted': {'field': 'c'},
    },
  ],
};

Story _parse(
  Map<String, dynamic> json, {
  AppLanguage language = AppLanguage.vi,
}) => StoryModel.fromJson(json).toEntity(baseDir: 'b', language: language);

/// Always picks the first choice.
final class _FirstRandom implements Random {
  @override
  int nextInt(int max) => 0;
  @override
  double nextDouble() => 0;
  @override
  bool nextBool() => false;
}

void main() {
  group('evalMath', () {
    test('adds and subtracts numbers and vars', () {
      expect(evalMath('2', const {}), 2);
      expect(evalMath('a + b', const {'a': 2, 'b': 1}), 3);
      expect(evalMath('5 - c', const {'c': 3}), 2);
      expect(evalMath('a+b-1', const {'a': 2, 'b': 2}), 3);
    });

    test('rejects unknown vars and junk', () {
      expect(() => evalMath('a + z', const {'a': 1}), throwsFormatException);
      expect(() => evalMath('a * 2', const {'a': 1}), throwsFormatException);
      expect(() => evalMath('a +', const {'a': 1}), throwsFormatException);
    });
  });

  group('MathSpec', () {
    test('every draw respects its ranges', () {
      final story = _parse(_mathStory());
      final spec = story.math!;
      final draws = spec.allDraws();
      expect(draws, hasLength(6)); // a=1: b 1..3, a=2: b 1..2, a=3: b 1
      final random = Random(1);
      for (var i = 0; i < 50; i++) {
        final d = spec.draw(random);
        expect(d['a'], inInclusiveRange(1, 3));
        expect(d['b'], inInclusiveRange(1, 4 - d['a']!));
        expect(d['c'], d['a']! + d['b']!);
      }
    });

    test('near miss is one away, within 1..max', () {
      final random = Random(2);
      for (var i = 0; i < 30; i++) {
        expect(nearMiss(1, 5, random), 2);
        expect(nearMiss(5, 5, random), 4);
        expect(nearMiss(3, 5, random), anyOf(2, 4));
      }
    });
  });

  group('text', () {
    test('spells numbers, capitalises at a sentence start', () {
      const values = {'a': 2, 'c': 3};
      expect(
        spellNumbers('{c} bạn cừu đây rồi! {count:c}!', AppLanguage.vi, values),
        'Ba bạn cừu đây rồi! Một, hai, ba!',
      );
      expect(
        spellNumbers('{name}, {a} sheep. "{c} more"', AppLanguage.en, values),
        '{name}, two sheep. "Three more"',
      );
      expect(
        spellNumbers('Lulu cười: "{a} bạn cừu."', AppLanguage.vi, values),
        'Lulu cười: "Hai bạn cừu."',
      );
    });

    test('tokenize keeps empty word pieces so clip numbers line up', () {
      final t = tokenize('{a} bạn');
      expect(t, hasLength(3));
      expect((t[0] as WordsToken).text, '');
      expect((t[1] as NumberToken).variable, 'a');
    });
  });

  group('parse', () {
    test('rejects number tokens without a math block', () {
      final json = _mathStory()..remove('math');
      expect(() => _parse(json), throwsFormatException);
    });

    test('rejects an unknown number', () {
      expect(
        () => _parse(_mathStory(question: 'Có {z} bạn?')),
        throwsFormatException,
      );
    });

    test('rejects counted objects that do not fit the field', () {
      expect(
        () => _parse(
          _mathStory(
            vars: {
              'a': [1, 4],
              'b': [1, 3],
              'c': 'a + b',
            },
          ),
        ),
        throwsFormatException,
      );
    });

    test('a math option without icon uses the math icon', () {
      final c1 = _parse(_mathStory()).nodes['c1']! as ChoiceNode;
      expect(c1.options.first.iconAsset, 'b/images/sheep.webp');
      expect(c1.options.first.answer, 'c');
    });
  });

  group('one play', () {
    late Story story;

    setUp(() {
      story = _parse(_mathStory()).withNumbers(_FirstRandom());
    });

    test('draws numbers and resolves answers', () {
      expect(story.values, {'a': 1, 'b': 1, 'c': 2});
      final c1 = story.nodes['c1']! as ChoiceNode;
      final byId = {for (final o in c1.options) o.id: o};
      expect(byId['right']!.count, 2);
      expect(byId['near']!.count, 1);
      expect(story.optionLabel(byId['right']!), 'Hai bạn cừu');
    });

    test('shuffles the answer cards', () {
      final orders = <String>{};
      final random = Random(3);
      for (var i = 0; i < 30; i++) {
        final c1 =
            _parse(_mathStory()).withNumbers(random).nodes['c1']! as ChoiceNode;
        orders.add(c1.options.first.id);
      }
      expect(orders, {'right', 'near'});
    });

    test('narration: words clips around number clips and counts', () {
      const ui = 'assets/audio/ui/vi';
      expect(story.nodeNarration('c1'), [
        const ClipPart('$ui/num_1.m4a'),
        const ClipPart('b/audio/vi/c1_p1.m4a'),
        const ClipPart('$ui/num_1.m4a'),
        const ClipPart('b/audio/vi/c1_p2.m4a'),
      ]);
      expect(story.nodeNarration('a1'), [
        const ClipPart('$ui/num_2.m4a'),
        const ClipPart('b/audio/vi/a1_p1.m4a'),
        const CountPart('$ui/num_1.m4a', part: 'sheep1'),
        const CountPart('$ui/num_2.m4a', part: 'sheep2'),
      ]);
      expect(
        story.nodeNarration('end').whereType<CountPart>().map((p) => p.pose),
        ['sleep', 'sleep'],
      );
      expect(story.optionNarration('c1', 'near'), [
        const ClipPart('$ui/num_1.m4a'),
        const ClipPart('b/audio/vi/c1_near_p1.m4a'),
      ]);
    });

    test('every number clip is listed for the asset check', () {
      for (var n = 1; n <= 5; n++) {
        expect(story.clipPaths, contains('assets/audio/ui/vi/num_$n.m4a'));
      }
    });

    test('placements: field, waiting, hidden', () {
      final p = story.placements('s1');
      expect(p['sheep1'], (x: 0.1, y: 0.8));
      expect(p['sheep2'], (x: 0.8, y: 0.7));
      expect(p['sheep3'], isNull);
      expect(p.containsKey('sheep5'), isTrue);
      expect(story.arrivals('s1'), [('sheep2', (x: 0.2, y: 0.8))]);
    });
  });

  group('player', () {
    test(
      'counts with a cue per number; arrive moves the waiting ones',
      () async {
        final narrator = FakeNarrator()
          ..clipDuration = const Duration(milliseconds: 5);
        final cues = <String>[];
        final cubit = PlayerCubit(
          repository: FakeStoryRepository({'m': _parse(_mathStory())}),
          narrator: narrator,
          storyId: 'm',
          language: AppLanguage.vi,
          nameVoice: FakeNameVoice(),
          analytics: FakeAnalytics(),
          autoAdvanceDelay: Duration.zero,
          silentSceneDuration: Duration.zero,
          choiceCelebrateDelay: Duration.zero,
          choiceOptionGap: Duration.zero,
          countGap: Duration.zero,
          random: _FirstRandom(),
        );
        final sub = cubit.stream.listen((s) {
          final c = s.cue;
          if (c != null && (cues.isEmpty || !cues.last.endsWith('#${c.seq}'))) {
            cues.add('${c.part}:${c.action.name}#${c.seq}');
          }
        });
        await cubit.load();
        await Future<void>.delayed(const Duration(milliseconds: 500));
        expect(cubit.state.phase, PlayerPhase.choosing);
        expect(cues.where((c) => c.startsWith('sheep2:move')), hasLength(1));

        final right = (cubit.state.node! as ChoiceNode).options.firstWhere(
          (o) => o.id == 'right',
        );
        cues.clear();
        cubit.choose(right.id);
        await Future<void>.delayed(const Duration(milliseconds: 500));
        expect(
          cues.map((c) => c.split('#').first).where((c) => c.contains('hop')),
          ['sheep1:hop', 'sheep2:hop'],
        );
        await sub.cancel();
        await cubit.close();
      },
    );
  });
}
