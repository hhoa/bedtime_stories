import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bedtime_stories/features/player/presentation/widgets/particle_paint.dart';
import 'package:bedtime_stories/features/player/presentation/widgets/scene_ambient.dart';
import 'package:bedtime_stories/features/stories/domain/entities/story.dart';

Widget _host(Ambient ambient, {bool reduceMotion = false}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: SizedBox(
      width: 400,
      height: 300,
      child: SceneAmbient(ambient: ambient, seed: 1),
    ),
  ),
);

/// A painter drawn inside the ambient overlay.
final _painted = find.descendant(
  of: find.byType(SceneAmbient),
  matching: find.byWidgetPredicate(
    (w) => w is CustomPaint && w.painter != null,
  ),
);

void main() {
  for (final ambient in Ambient.values) {
    testWidgets('$ambient renders and loops without errors', (tester) async {
      await tester.pumpWidget(_host(ambient));
      // Loops never settle, so step time manually.
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 700));
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('draws nothing when reduced motion is on', (tester) async {
    await tester.pumpWidget(_host(Ambient.zzz, reduceMotion: true));
    expect(_painted, findsNothing);
  });

  for (final ambient in [Ambient.sparkles, Ambient.zzz, Ambient.motes]) {
    testWidgets('$ambient is one painter on one ticker', (tester) async {
      await tester.pumpWidget(_host(ambient));
      await tester.pump(const Duration(seconds: 1));
      expect(_painted, findsOneWidget);
      expect(find.byType(ParticleLoop), findsOneWidget);
    });
  }
}
