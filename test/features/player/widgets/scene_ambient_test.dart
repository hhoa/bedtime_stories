import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
    expect(find.text('z'), findsNothing);
  });

  testWidgets('zzz shows letters', (tester) async {
    await tester.pumpWidget(_host(Ambient.zzz));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('z'), findsWidgets);
    // Let staggered start delays fire before teardown.
    await tester.pump(const Duration(seconds: 5));
  });
}
