import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bedtime_stories/core/utils/app_constants.dart';
import 'package:bedtime_stories/features/player/presentation/cubit/player_state.dart';
import 'package:bedtime_stories/features/player/presentation/widgets/scene_burst.dart';
import 'package:bedtime_stories/features/player/presentation/widgets/scene_layers.dart';
import 'package:bedtime_stories/features/player/presentation/widgets/scene_picture.dart';
import 'package:bedtime_stories/features/stories/domain/entities/story.dart';

import '../../../helpers/fakes.dart';

/// Fixture pictures live on disk, not in pubspec assets.
Widget app(Widget home) => DefaultAssetBundle(
  bundle: DiskAssetBundle(),
  child: MaterialApp(home: home),
);

void main() {
  group('hitPart', () {
    const layers = [
      SceneLayer(asset: 'bg.svg'),
      SceneLayer(
        asset: 'hero.svg',
        kind: 'hero',
        box: (x: 0.2, y: 0.2, w: 0.3, h: 0.5),
        tap: PartAction.hop,
      ),
      SceneLayer(
        asset: 'lulu.svg',
        kind: 'lulu',
        box: (x: 0.4, y: 0.3, w: 0.2, h: 0.4),
        tap: PartAction.hop,
      ),
      SceneLayer(
        asset: 'moon.svg',
        kind: 'moon',
        box: (x: 0.8, y: 0.1, w: 0.1, h: 0.1),
      ),
    ];

    test('picks the topmost tappable part', () {
      expect(hitPart(layers, const Offset(0.45, 0.5)), 2);
      expect(hitPart(layers, const Offset(0.25, 0.5)), 1);
    });

    test('counts a near miss, ignores far taps and untappable parts', () {
      expect(hitPart(layers, const Offset(0.17, 0.5)), 1);
      expect(hitPart(layers, const Offset(0.05, 0.95)), isNull);
      expect(hitPart(layers, const Offset(0.85, 0.15)), isNull);
    });
  });

  group('ScenePicture with layers', () {
    final story = loadFixtureStory();
    final image = story.nodes['s2']!.imageAsset;
    final layers = story.layers[image]!;

    Future<int> pumpAndTap(WidgetTester tester, Offset fraction) async {
      var replays = 0;
      await tester.pumpWidget(
        app(
          SizedBox(
            width: 800,
            height: 600,
            child: ScenePicture(
              imageAsset: image,
              layers: layers,
              onTap: () => replays++,
              semanticLabel: 'scene',
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      final rect = tester.getRect(find.byType(AspectRatio));
      await tester.tapAt(
        rect.topLeft +
            Offset(rect.width * fraction.dx, rect.height * fraction.dy),
      );
      // Idle loops never settle, so step time manually.
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(tester.takeException(), isNull);
      // flutter_animate's Ken Burns start delay can't be cancelled.
      await tester.pump(AppConstants.kenBurnsDuration);
      await tester.pumpWidget(const SizedBox());
      return replays;
    }

    testWidgets('tapping Lulu makes her react instead of replaying', (
      tester,
    ) async {
      final lulu = layers.firstWhere((l) => l.kind == 'lulu').box!;
      final replays = await pumpAndTap(
        tester,
        Offset(lulu.x + lulu.w / 2, lulu.y + lulu.h / 2),
      );
      expect(replays, 0);
    });

    testWidgets('tapping empty floor replays the narration', (tester) async {
      final replays = await pumpAndTap(tester, const Offset(0.97, 0.97));
      expect(replays, 1);
    });
  });

  testWidgets('a cropped part is drawn at its rect of the picture', (
    tester,
  ) async {
    const rect = (x: 0.25, y: 0.2, w: 0.5, h: 0.6);
    await tester.pumpWidget(
      Center(
        child: SizedBox(
          width: 800,
          height: 600,
          child: InRect(
            rect: rect,
            child: Container(key: const Key('part')),
          ),
        ),
      ),
    );
    final box = tester.getRect(find.byKey(const Key('part')));
    final canvas = tester.getRect(find.byType(InRect));
    expect(box.left - canvas.left, 200);
    expect(box.top - canvas.top, 120);
    expect(box.size, const Size(400, 360));
  });

  group('hitHotspot', () {
    const spots = [
      SceneHotspot(kind: 'hero', box: (x: 0.2, y: 0.2, w: 0.4, h: 0.5)),
      SceneHotspot(kind: 'lulu', box: (x: 0.5, y: 0.4, w: 0.2, h: 0.3)),
    ];

    test('picks the last listed spot where they overlap', () {
      expect(hitHotspot(spots, const Offset(0.55, 0.5))?.kind, 'lulu');
      expect(hitHotspot(spots, const Offset(0.3, 0.3))?.kind, 'hero');
      expect(hitHotspot(spots, const Offset(0.95, 0.05)), isNull);
    });
  });

  group('ScenePicture with hotspots (flat AI picture)', () {
    // Fixture a1: flat picture, hero and Lulu hotspots.
    final story = loadFixtureStory();
    final image = story.nodes['a1']!.imageAsset;
    final spots = story.hotspots[image]!;

    Future<int> pumpAndTap(
      WidgetTester tester,
      Offset fraction, {
      required Finder expectShown,
    }) async {
      var replays = 0;
      await tester.pumpWidget(
        app(
          SizedBox(
            width: 800,
            height: 600,
            child: ScenePicture(
              imageAsset: image,
              hotspots: spots,
              onTap: () => replays++,
              semanticLabel: 'scene',
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      final rect = tester.getRect(find.byType(AspectRatio));
      await tester.tapAt(
        rect.topLeft +
            Offset(rect.width * fraction.dx, rect.height * fraction.dy),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(expectShown, findsWidgets);
      await tester.pump(AppConstants.burstDuration);
      expect(tester.takeException(), isNull);
      await tester.pump(AppConstants.kenBurnsDuration);
      await tester.pumpWidget(const SizedBox());
      return replays;
    }

    Offset center(String kind) {
      final b = spots.firstWhere((h) => h.kind == kind).box;
      return Offset(b.x + b.w / 2, b.y + b.h / 2);
    }

    testWidgets('tapping the child shows hearts instead of replaying', (
      tester,
    ) async {
      final replays = await pumpAndTap(
        tester,
        center('hero'),
        expectShown: find.byIcon(Icons.favorite),
      );
      expect(replays, 0);
    });

    testWidgets('tapping Lulu plays a burst instead of replaying', (
      tester,
    ) async {
      final replays = await pumpAndTap(
        tester,
        center('lulu'),
        expectShown: find.byType(SceneBurst),
      );
      expect(replays, 0);
    });

    testWidgets('tapping elsewhere replays the narration', (tester) async {
      final replays = await pumpAndTap(
        tester,
        const Offset(0.97, 0.97),
        expectShown: find.byType(SceneBurst),
      );
      expect(replays, 1);
    });
  });

  testWidgets('partly layered AI picture: Lulu moves, the child keeps hearts', (
    tester,
  ) async {
    // Fixture s2: Lulu is a cut layer, the child a hotspot.
    final story = loadFixtureStory();
    final image = story.nodes['s2']!.imageAsset;
    final layers = story.layers[image]!;
    final spots = story.hotspots[image]!;
    expect(layers.where((l) => l.kind == 'lulu'), isNotEmpty);
    var replays = 0;
    await tester.pumpWidget(
      app(
        SizedBox(
          width: 800,
          height: 600,
          child: ScenePicture(
            imageAsset: image,
            layers: layers,
            hotspots: spots,
            onTap: () => replays++,
            semanticLabel: 'scene',
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    final rect = tester.getRect(find.byType(AspectRatio));
    Future<void> tapCenter(CanvasBox b) => tester.tapAt(
      rect.topLeft +
          Offset(rect.width * (b.x + b.w / 2), rect.height * (b.y + b.h / 2)),
    );
    await tapCenter(spots.firstWhere((h) => h.kind == 'hero').box);
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byIcon(Icons.favorite), findsWidgets);
    await tapCenter(layers.firstWhere((l) => l.kind == 'lulu').box!);
    for (var i = 0; i < 15; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(replays, 0);
    expect(tester.takeException(), isNull);
    await tester.pump(AppConstants.kenBurnsDuration);
    await tester.pumpWidget(const SizedBox());
  });

  group('poses', () {
    // Fixture s2: Lulu is a cut layer with a "clap" pose.
    final story = loadFixtureStory();
    final girl = story.nodes['s2']!.imageAsset;
    final layers = story.layers[girl]!;
    final lulu = layers.firstWhere((l) => l.kind == 'lulu');

    double opacityOf(WidgetTester tester, String pose) =>
        tester.widget<AnimatedOpacity>(find.byKey(ValueKey(pose))).opacity;

    Future<void> pump(
      WidgetTester tester, {
      PartCue? cue,
      Map<String, String> poses = const {},
      VoidCallback? onTap,
    }) => tester.pumpWidget(
      app(
        SizedBox(
          width: 800,
          height: 600,
          child: ScenePicture(
            imageAsset: girl,
            layers: layers,
            cue: cue,
            poses: poses,
            onTap: onTap ?? () {},
            semanticLabel: 'scene',
          ),
        ),
      ),
    );

    Future<void> finish(WidgetTester tester) async {
      expect(tester.takeException(), isNull);
      await tester.pump(AppConstants.kenBurnsDuration);
      await tester.pumpWidget(const SizedBox());
    }

    testWidgets('a pose cue switches the shown picture and holds it', (
      tester,
    ) async {
      await pump(tester);
      await tester.pump(const Duration(milliseconds: 100));
      expect(opacityOf(tester, defaultPose), 1);
      expect(opacityOf(tester, 'clap'), 0);

      await pump(
        tester,
        cue: const PartCue(
          part: 'lulu',
          action: PartAction.pose,
          seq: 1,
          pose: 'clap',
        ),
      );
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(opacityOf(tester, 'clap'), 1);
      expect(opacityOf(tester, defaultPose), 0);
      await finish(tester);
    });

    testWidgets('the node start pose shows from the first frame', (
      tester,
    ) async {
      await pump(tester, poses: {'lulu': 'clap'});
      await tester.pump(const Duration(milliseconds: 100));
      expect(opacityOf(tester, 'clap'), 1);
      await finish(tester);
    });

    testWidgets('after a move cue, tapping the new spot hits the part', (
      tester,
    ) async {
      var replays = 0;
      const to = (x: 0.2, y: 0.8);
      await pump(tester, onTap: () => replays++);
      await pump(
        tester,
        onTap: () => replays++,
        cue: const PartCue(
          part: 'lulu',
          action: PartAction.move,
          seq: 1,
          to: to,
        ),
      );
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      final by = moveOffset(lulu, to);
      final b = lulu.box!;
      final rect = tester.getRect(find.byType(AspectRatio));
      await tester.tapAt(
        rect.topLeft +
            Offset(
              rect.width * (b.x + b.w / 2 + by.dx),
              rect.height * (b.y + b.h / 2 + by.dy),
            ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(replays, 0);
      await finish(tester);
    });
  });
}
