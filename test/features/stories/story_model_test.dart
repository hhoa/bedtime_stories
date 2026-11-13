import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bedtime_stories/core/models/child_profile.dart';
import 'package:bedtime_stories/core/utils/app_constants.dart';
import 'package:bedtime_stories/features/stories/data/models/story_model.dart';
import 'package:bedtime_stories/features/stories/data/repositories/asset_story_repository.dart';
import 'package:bedtime_stories/features/stories/domain/entities/story.dart';

import '../../helpers/fakes.dart';

/// Same text in both languages.
Map<String, String> _t(String text) => {'vi': text, 'en': text};

Map<String, dynamic> _minimal({String endNext = 'end'}) => {
  'id': 't',
  'theme': 'x',
  'hero': 'kid',
  'title': _t('a'),
  'cover': 'c.svg',
  'start': 's1',
  'nodes': [
    {
      'id': 's1',
      'type': 'scene',
      'image': 'i.svg',
      'text': _t('a'),
      'next': endNext,
    },
    {
      'id': 'end',
      'type': 'ending',
      'image': 'i.svg',
      'sticker': 's.svg',
      'text': _t('a'),
    },
  ],
};

/// [_minimal] with node s1 changed.
Map<String, dynamic> _withS1(Map<String, dynamic> extra) {
  final json = _minimal();
  final nodes = json['nodes'] as List;
  return {
    ...json,
    'nodes': [
      {...nodes[0] as Map<String, dynamic>, ...extra},
      ...nodes.skip(1),
    ],
  };
}

Story _parse(
  Map<String, dynamic> json, {
  AppLanguage language = AppLanguage.vi,
  Map<String, dynamic>? layers,
}) => StoryModel.fromJson(
  json,
).toEntity(baseDir: 'b', language: language, layers: layers);

/// Reads every asset straight from the project folder.
final class _FileBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(await File(key).readAsBytes());
}

void main() {
  test('fixture story parses in both languages', () {
    for (final lang in AppLanguage.values) {
      final story = loadFixtureStory(language: lang);
      expect(story.startId, 's1');
      expect(story.hero, StoryHero.kid);
      expect(story.language, lang);
      expect(story.nodes['c1'], isA<ChoiceNode>());
      expect(story.coverAsset, '$fixtureDir/images/cover.webp');
      expect(story.audioDir, '$fixtureDir/audio/${lang.name}');
      expect(story.stickerAsset, '$fixtureDir/images/sticker.webp');
    }
    expect(loadFixtureStory().title, '{name} và Lulu đi ngủ');
    expect(
      loadFixtureStory(language: AppLanguage.en).title,
      '{name} and Lulu go to bed',
    );
  });

  final bundledIds =
      ((jsonDecode(File('assets/stories/index.json').readAsStringSync())
                  as Map<String, dynamic>)['stories']
              as List)
          .cast<String>();

  for (final id in bundledIds) {
    test('every referenced asset of $id exists, both languages', () {
      final paths = <String>{};
      Iterable<String> clips(List<NarrationPart> parts) =>
          parts.whereType<ClipPart>().map((p) => p.assetPath);

      for (final lang in AppLanguage.values) {
        final story = loadBundledStory(id, language: lang);
        paths
          ..add(story.coverAsset)
          ..add(AppConstants.nameFallbackAudio(lang))
          ..add(AppConstants.uiAudio('rewind', lang));
        for (var n = 0; n <= 2; n++) {
          paths.add(AppConstants.stickerAudio(n, lang));
        }
        for (final layer in story.layers.values.expand((l) => l)) {
          paths.addAll(layer.allAssets);
        }
        for (final node in story.nodes.values) {
          paths
            ..add(node.imageAsset)
            ..addAll(clips(story.nodeNarration(node.id)));
          if (node case ChoiceNode(:final options)) {
            for (final o in options) {
              paths
                ..add(o.iconAsset)
                ..addAll(clips(story.optionNarration(node.id, o.id)));
            }
          }
          if (node case EndingNode(:final stickerAsset)) {
            paths.add(stickerAsset);
          }
        }
      }
      final missing = paths.where((p) => !File(p).existsSync()).toList();
      expect(missing, isEmpty);
    });
  }

  for (final id in [...bundledIds, null]) {
    test('${id ?? 'fixture'}: drawn scenes layered, cue parts exist', () {
      for (final lang in AppLanguage.values) {
        final story = id == null
            ? loadFixtureStory(language: lang)
            : loadBundledStory(id, language: lang);
        for (final node in story.nodes.values) {
          final layers = story.layers[node.imageAsset];
          // AI pictures (PNG/JPG/WebP) may be flat or partly layered; cues
          // then name a layer part or a hotspot.
          if (node.imageAsset.endsWith('.svg')) {
            expect(layers, isNotNull, reason: '${node.id} has no layers');
          }
          final kinds = {
            for (final l in layers ?? const <SceneLayer>[]) l.kind,
            for (final h in story.hotspots[node.imageAsset] ?? const []) h.kind,
          };
          for (final cue in node.cues) {
            // `arrive` names the counted group: its parts are counter1, …
            final math = story.math;
            final part = cue.action == PartAction.arrive && math != null
                ? math.part(1)
                : cue.part;
            expect(kinds, contains(part), reason: '${node.id}: ${cue.part}');
          }
        }
      }
    });
  }

  group('languages', () {
    test('rejects a story missing English text', () {
      final json = _withS1({
        'text': {'vi': 'a'},
      });
      // Even when asked for Vietnamese: every language must be complete.
      expect(() => _parse(json), throwsFormatException);
    });

    test('rejects a missing English option label', () {
      final json = _minimal();
      (json['nodes'] as List).insert(0, {
        'id': 'c',
        'type': 'choice',
        'image': 'i.svg',
        'text': _t('Chọn gì?'),
        'options': [
          {
            'id': 'x',
            'kind': 'kind',
            'icon': 'i.svg',
            'label': {'vi': 'X'},
            'next': 's1',
          },
          {
            'id': 'y',
            'kind': 'learn',
            'icon': 'i.svg',
            'label': _t('Y'),
            'next': 's1',
          },
        ],
      });
      expect(() => _parse(json), throwsFormatException);
    });

    test('picks text and cues of the asked language', () {
      final json = _withS1({
        'text': {'vi': 'Tưng! Lulu nhảy.', 'en': 'Boing! Lulu hops.'},
        'cues': {
          'vi': [
            {'word': 'Tưng', 'part': 'lulu', 'action': 'hop'},
          ],
          'en': [
            {'word': 'hops', 'part': 'lulu', 'action': 'hop'},
          ],
        },
      });
      final en = _parse(json, language: AppLanguage.en);
      expect(en.nodes['s1']!.text, 'Boing! Lulu hops.');
      expect(en.nodes['s1']!.cues.single.word, 'hops');
      expect(en.nodeNarration('s1'), [const ClipPart('b/audio/en/s1.m4a')]);
    });

    test('rejects a cue word missing in the other language', () {
      final json = _withS1({
        'text': {'vi': 'Tưng!', 'en': 'Boing!'},
        'cues': {
          'vi': [
            {'word': 'Tưng', 'part': 'lulu', 'action': 'hop'},
          ],
          'en': [
            {'word': 'Tưng', 'part': 'lulu', 'action': 'hop'},
          ],
        },
      });
      expect(() => _parse(json), throwsFormatException);
    });
  });

  group('{name} rule', () {
    test('first or last word of the whole line, once', () {
      String? check(String text) => namePlacementError(text);
      expect(check('Trời tối rồi. Mình ngủ chưa nhỉ, {name}?'), isNull);
      expect(check('{name} ơi, mình ngủ nhé?'), isNull);
      expect(check('"{name} ơi, mấy giờ rồi?" Lulu hỏi.'), isNull);
      expect(check('{name} vươn vai thật cao. Lulu vỗ tay.'), isNull);
      expect(check('Ngủ ngon nhé, {name}.'), isNull);
      expect(check('Reng reng! {name} ngáp một cái.'), isNotNull);
      expect(check('Lulu xoay áo cho {name}. Bé mỉm cười.'), isNotNull);
      expect(check('Chào {name}, chào buổi sáng?'), isNotNull);
      expect(check('Bảy giờ rồi, {name} làm gì nhỉ?'), isNotNull);
      expect(check('{name} ơi, {name}?'), isNotNull);
    });

    // Same file as `python3 tool/check_story.py --selftest`: keeps the Dart
    // and Python rules in sync.
    test('agrees with the shared cases in name_rule_cases.json', () {
      final file = File('test/fixtures/name_rule_cases.json');
      final cases =
          (jsonDecode(file.readAsStringSync()) as Map)['cases'] as List;
      for (final c in cases.cast<Map<String, dynamic>>()) {
        final text = c['text'] as String;
        final ok = c['ok'] as bool;
        expect(
          namePlacementError(text) == null,
          ok,
          reason: '"$text" should be ${ok ? 'ok' : 'an error'}',
        );
      }
    });

    test('parser accepts the name opening a scene statement', () {
      final json = _withS1({'text': _t('{name} ngáp một cái.')});
      expect(() => _parse(json), returnsNormally);
    });

    test('parser rejects the name mid-sentence in a scene', () {
      final json = _withS1({'text': _t('Rồi {name} ngáp một cái.')});
      expect(() => _parse(json), throwsFormatException);
    });

    test('parser rejects the name in an option label', () {
      final json = _minimal();
      (json['nodes'] as List).insert(0, {
        'id': 'c',
        'type': 'choice',
        'image': 'i.svg',
        'text': _t('{name} ơi, chọn gì?'),
        'options': [
          for (final id in ['x', 'y'])
            {
              'id': id,
              'kind': id == 'x' ? 'kind' : 'learn',
              'icon': 'i.svg',
              'label': _t('{name} chọn'),
              'next': 's1',
            },
        ],
      });
      expect(() => _parse(json), throwsFormatException);
    });
  });

  test('fills the child name', () {
    const na = ChildProfile(name: 'Na', gender: Gender.girl);
    expect(resolveName('Chào {name}!', na), 'Chào Na!');
  });

  test('splits narration around the name and skips empty parts', () {
    final story = _parse(_minimal()).copyWith(
      nodes: {
        's1': const StoryNode.scene(
          id: 's1',
          imageAsset: 'i.svg',
          text: '{name} ơi, ngủ thôi {name}!',
          nextId: 'end',
        ),
      },
    );
    expect(story.nodeNarration('s1'), [
      const NamePart(),
      const ClipPart('b/audio/vi/s1_p1.m4a'),
      const NamePart(),
    ]);
  });

  group('section', () {
    test('defaults to behavior', () {
      expect(_parse(_minimal()).section, StorySection.behavior);
    });

    test('parses math', () {
      expect(
        _parse({..._minimal(), 'section': 'math'}).section,
        StorySection.math,
      );
    });

    test('rejects an unknown section', () {
      expect(
        () => _parse({..._minimal(), 'section': 'music'}),
        throwsFormatException,
      );
    });
  });

  group('AssetStoryRepository', () {
    test('lists only the asked section', () async {
      final repo = AssetStoryRepository(bundle: _FileBundle());
      final all = (await repo.getStories(AppLanguage.vi)).getOrElse(() => []);
      final math = (await repo.getStories(
        AppLanguage.vi,
        section: StorySection.math,
      )).getOrElse(() => []);
      final behavior = (await repo.getStories(
        AppLanguage.vi,
        section: StorySection.behavior,
      )).getOrElse(() => []);
      expect(all, isNotEmpty);
      expect(math.every((s) => s.section == StorySection.math), isTrue);
      expect(behavior.every((s) => s.section == StorySection.behavior), isTrue);
      expect(math.length + behavior.length, all.length);
    });
  });

  test('rejects link to missing node', () {
    expect(() => _parse(_minimal(endNext: 'nowhere')), throwsFormatException);
  });

  group('ambient', () {
    const withAmbient = _withS1;

    test('defaults to none', () {
      final story = _parse(_minimal());
      expect(story.nodes['s1']!.ambient, Ambient.none);
      expect(story.nodes['s1']!.ambientOrigin, isNull);
    });

    test('parses effect and origin', () {
      final story = _parse(
        withAmbient({
          'ambient': 'zzz',
          'ambient_origin': [0.4, 0.5],
        }),
      );
      expect(story.nodes['s1']!.ambient, Ambient.zzz);
      expect(story.nodes['s1']!.ambientOrigin, (x: 0.4, y: 0.5));
    });

    test('rejects unknown effect', () {
      expect(
        () => _parse(withAmbient({'ambient': 'rain'})),
        throwsFormatException,
      );
    });

    test('rejects origin outside the picture', () {
      expect(
        () => _parse(
          withAmbient({
            'ambient_origin': [1.5, 0.2],
          }),
        ),
        throwsFormatException,
      );
    });
  });

  group('cues', () {
    Map<String, dynamic> withCues(
      String text,
      List<Map<String, Object>> cues,
    ) => _withS1({
      'text': _t(text),
      'cues': {'vi': cues, 'en': cues},
    });

    test('parses and times cues after a leading name', () {
      const p1 = ' ơi, tưng tưng! Mình ngủ nhé. Tưng!';
      final story = _parse(
        withCues('{name}$p1', [
          {'word': 'tưng', 'part': 'lulu', 'action': 'hop'},
          {'word': 'Tưng', 'part': 'lulu', 'action': 'pulse'},
        ]),
      );
      final timings = story.cueTimings('s1');

      expect(timings, hasLength(2));
      // Both cues are in the one clip after the name.
      expect(timings[0].clip, 'b/audio/vi/s1_p1.m4a');
      expect(timings[0].clipFraction, closeTo(5 / p1.length, 1e-9));
      // The second "Tưng" (searched after the first cue) is the last word.
      expect(timings[1].cue.action, PartAction.pulse);
      expect(timings[1].clip, 'b/audio/vi/s1_p1.m4a');
      expect(timings[1].clipFraction, closeTo(30 / p1.length, 1e-9));
    });

    test('times cues before a trailing name', () {
      const p0 = 'Tưng, tưng! Mình ngủ nhé, ';
      final story = _parse(
        withCues('$p0{name}?', [
          {'word': 'tưng', 'part': 'lulu', 'action': 'hop'},
        ]),
      );
      final timings = story.cueTimings('s1');

      expect(timings, hasLength(1));
      expect(timings[0].clip, 'b/audio/vi/s1_p0.m4a');
      expect(timings[0].clipFraction, closeTo(6 / p0.length, 1e-9));
    });

    test('a measured "at" wins over the text guess', () {
      const p0 = 'Tưng, tưng! Mình ngủ nhé, ';
      final story = _parse(
        withCues('$p0{name}?', [
          {'word': 'tưng', 'part': 'lulu', 'action': 'hop', 'at': 0.42},
        ]),
      );
      final timings = story.cueTimings('s1');

      expect(timings.single.clip, 'b/audio/vi/s1_p0.m4a');
      expect(timings.single.clipFraction, 0.42);
    });

    test('rejects "at" outside 0..1', () {
      expect(
        () => _parse(
          withCues('Tưng!', [
            {'word': 'Tưng', 'part': 'lulu', 'action': 'hop', 'at': 1.5},
          ]),
        ),
        throwsFormatException,
      );
    });

    test('rejects a cue word missing from the text', () {
      expect(
        () => _parse(
          withCues('Xin chào', [
            {'word': 'Tưng', 'part': 'lulu', 'action': 'hop'},
          ]),
        ),
        throwsFormatException,
      );
    });

    test('rejects an unknown cue action', () {
      expect(
        () => _parse(
          withCues('Tưng', [
            {'word': 'Tưng', 'part': 'lulu', 'action': 'fly'},
          ]),
        ),
        throwsFormatException,
      );
    });
  });

  test('parses hotspots with image paths and default burst', () {
    final spots = parseHotspots({
      'a.webp': [
        {
          'kind': 'lulu',
          'box': [0.1, 0.2, 0.3, 0.4],
        },
        {
          'kind': 'hero',
          'box': [0.5, 0.1, 0.2, 0.6],
          'burst': 'hearts',
        },
      ],
    }, 'b/images');

    final a = spots['b/images/a.webp']!;
    expect(a.first.kind, 'lulu');
    expect(a.first.box, (x: 0.1, y: 0.2, w: 0.3, h: 0.4));
    expect(a.first.burst, Burst.sparkles);
    expect(a.last.burst, Burst.hearts);
  });

  test('rejects an unknown hotspot burst', () {
    expect(
      () => parseHotspots({
        'a.webp': [
          {
            'kind': 'lulu',
            'box': [0, 0, 1, 1],
            'burst': 'confetti',
          },
        ],
      }, 'b'),
      throwsFormatException,
    );
  });

  test('parses the layer manifest with image paths', () {
    final layers = parseLayers({
      'a.svg': [
        {'file': 'layers/a_0.svg'},
        {
          'file': 'layers/a_1.svg',
          'kind': 'lulu',
          'box': [0.1, 0.2, 0.3, 0.4],
          'pivot': [0.5, 0.6],
          'idle': 'float',
          'tap': 'hop',
          'blink': 'layers/a_1_blink.svg',
        },
      ],
    }, 'b/images');

    final a = layers['b/images/a.svg']!;
    expect(a.first.isPart, isFalse);
    expect(a.last.asset, 'b/images/layers/a_1.svg');
    expect(a.last.blinkAsset, 'b/images/layers/a_1_blink.svg');
    expect(a.last.box, (x: 0.1, y: 0.2, w: 0.3, h: 0.4));
    expect(a.last.pivot, (x: 0.5, y: 0.6));
    expect(a.last.idle, PartIdle.float);
    expect(a.last.tap, PartAction.hop);
  });

  test('parses a cropped layer rect, full-canvas when absent', () {
    final layers = parseLayers({
      'a.webp': [
        {'file': 'layers/a_0.webp'},
        {
          'file': 'layers/a_1.webp',
          'kind': 'hero',
          'rect': [0.25, 0.2, 0.3, 0.6],
        },
      ],
    }, 'b/images');

    final a = layers['b/images/a.webp']!;
    expect(a.first.rect, isNull);
    expect(a.last.rect, (x: 0.25, y: 0.2, w: 0.3, h: 0.6));
  });

  group('poses', () {
    const layers = {
      'i.webp': [
        {'file': 'i.webp'},
        {
          'file': 'layers/i_1.webp',
          'kind': 'hero',
          'box': [0.1, 0.1, 0.3, 0.6],
          'pivot': [0.25, 0.7],
          'idle': 'breathe',
          'tap': 'hop',
          'poses': {
            'default': 'layers/i_1.webp',
            'yawn': 'layers/i_1_yawn.webp',
          },
        },
      ],
    };

    Map<String, dynamic> story({
      List<Map<String, dynamic>>? cues,
      Map<String, String>? poses,
      String text = 'Bé ngáp rồi chạy.',
    }) {
      final json = _minimal();
      final nodes = json['nodes'] as List;
      return {
        ...json,
        'nodes': [
          {
            ...nodes[0] as Map<String, dynamic>,
            'image': 'images/i.webp',
            'text': _t(text),
            if (cues != null) 'cues': {'vi': cues, 'en': cues},
            'poses': ?poses,
          },
          ...nodes.skip(1),
        ],
      };
    }

    Story parse(Map<String, dynamic> json) => _parse(json, layers: layers);

    test(
      'parses layer poses with image paths, default is the layer itself',
      () {
        final l = parseLayers(layers, 'b/images')['b/images/i.webp']![1];
        expect(l.poses, {'yawn': 'b/images/layers/i_1_yawn.webp'});
        expect(l.hasPose('default'), isTrue);
        expect(l.hasPose('yawn'), isTrue);
        expect(l.hasPose('wave'), isFalse);
        expect(l.poseAsset('default'), l.asset);
        expect(l.allAssets, hasLength(2));
      },
    );

    test('parses pose and move cues and a start pose', () {
      final s = parse(
        story(
          cues: [
            {'word': 'ngáp', 'part': 'hero', 'action': 'pose', 'pose': 'yawn'},
            {
              'word': 'chạy',
              'part': 'hero',
              'action': 'move',
              'to': [0.7, 0.8],
            },
          ],
          poses: {'hero': 'yawn'},
        ),
      );
      final node = s.nodes['s1']!;
      expect(node.poses, {'hero': 'yawn'});
      expect(node.cues[0].pose, 'yawn');
      expect(node.cues[1].action, PartAction.move);
      expect(node.cues[1].to, (x: 0.7, y: 0.8));
    });

    test('rejects a pose the layer does not have', () {
      expect(
        () => parse(
          story(
            cues: [
              {'word': 'ngáp', 'part': 'hero', 'action': 'pose', 'pose': 'x'},
            ],
          ),
        ),
        throwsFormatException,
      );
      expect(
        () => parse(story(poses: {'lulu': 'yawn'})),
        throwsFormatException,
      );
    });

    test('rejects a pose cue without pose and a move cue without to', () {
      expect(
        () => parse(
          story(
            cues: [
              {'word': 'ngáp', 'part': 'hero', 'action': 'pose'},
            ],
          ),
        ),
        throwsFormatException,
      );
      expect(
        () => parse(
          story(
            cues: [
              {
                'word': 'chạy',
                'part': 'hero',
                'action': 'move',
                'to': [1.5, 0.2],
              },
            ],
          ),
        ),
        throwsFormatException,
      );
    });

    test('rejects pose or move as a tap reaction', () {
      expect(
        () => parseLayers({
          'a.webp': [
            {'file': 'a.webp', 'kind': 'hero', 'tap': 'pose'},
          ],
        }, 'b'),
        throwsFormatException,
      );
    });
  });
}
