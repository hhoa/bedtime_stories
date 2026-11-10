import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bedtime_stories/core/utils/app_constants.dart';
import 'package:bedtime_stories/features/player/presentation/widgets/particle_paint.dart';
import 'package:bedtime_stories/features/player/presentation/widgets/scene_burst.dart';
import 'package:bedtime_stories/features/stories/domain/entities/story.dart';

Finder _showing(Burst burst) => find.byWidgetPredicate(
  (w) =>
      w is CustomPaint &&
      w.painter is BurstPainter &&
      (w.painter! as BurstPainter).showing.contains(burst),
);

Widget _host(
  ValueListenable<BurstEvent?> events, {
  bool reduceMotion = false,
}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: SizedBox(width: 400, height: 300, child: SceneBurst(events: events)),
  ),
);

void main() {
  group('loop timing', () {
    test('holds the first frame during the delay, then repeats', () {
      expect(loopT(0.5, 1, 2), 0);
      expect(loopT(2, 1, 2), closeTo(0.5, 1e-9));
      expect(loopT(3.5, 1, 2), closeTo(0.25, 1e-9));
    });

    test('reverse plays every other round backwards', () {
      expect(loopT(1.5, 0, 2, reverse: true), closeTo(0.75, 1e-9));
      expect(loopT(2.5, 0, 2, reverse: true), closeTo(0.75, 1e-9));
    });

    test('span clamps to its window', () {
      expect(span(0.1, 0.2, 0.4), 0);
      expect(span(0.4, 0.2, 0.4), closeTo(0.5, 1e-9));
      expect(span(0.9, 0.2, 0.4), 1);
    });
  });

  testWidgets('plays a burst, then stops ticking', (tester) async {
    final events = ValueNotifier<BurstEvent?>(null);
    addTearDown(events.dispose);
    await tester.pumpWidget(_host(events));
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isFalse);

    events.value = const BurstEvent(
      burst: Burst.hearts,
      center: (x: 0.5, y: 0.5),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(_showing(Burst.hearts), findsOneWidget);

    events.value = const BurstEvent(
      burst: Burst.sparkles,
      center: (x: 0.2, y: 0.2),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(_showing(Burst.sparkles), findsOneWidget);

    await tester.pump(AppConstants.burstDuration);
    await tester.pump(const Duration(milliseconds: 50));
    expect(_showing(Burst.hearts), findsNothing);
    expect(_showing(Burst.sparkles), findsNothing);
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('plays nothing with reduced motion', (tester) async {
    final events = ValueNotifier<BurstEvent?>(null);
    addTearDown(events.dispose);
    await tester.pumpWidget(_host(events, reduceMotion: true));
    events.value = const BurstEvent(
      burst: Burst.hearts,
      center: (x: 0.5, y: 0.5),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(_showing(Burst.hearts), findsNothing);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}
