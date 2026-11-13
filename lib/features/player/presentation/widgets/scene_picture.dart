import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bedtime_stories/core/theme/app_colors.dart';
import 'package:bedtime_stories/core/theme/app_spacing.dart';
import 'package:bedtime_stories/core/utils/app_constants.dart';
import 'package:bedtime_stories/features/player/presentation/cubit/player_state.dart';
import 'package:bedtime_stories/features/player/presentation/widgets/scene_ambient.dart';
import 'package:bedtime_stories/features/player/presentation/widgets/scene_burst.dart';
import 'package:bedtime_stories/features/player/presentation/widgets/scene_layers.dart';
import 'package:bedtime_stories/features/stories/domain/entities/story.dart';
import 'package:bedtime_stories/core/widgets/story_image.dart';

/// Scene illustration: slow "Ken Burns" zoom that keeps gently breathing,
/// an [Ambient] overlay, and cross-fade between scenes.
///
/// With [layers], the hero, Lulu and props move on their own: idle loops,
/// blinks, [cue] reactions from the narration, and a reaction when the kid
/// taps one of them. AI pictures can have [hotspots] for parts that aren't
/// layers: a tap or a cue naming one plays a sparkle or heart burst there. Tapping anywhere
/// else replays the narration.
class ScenePicture extends StatefulWidget {
  const ScenePicture({
    required this.imageAsset,
    required this.onTap,
    required this.semanticLabel,
    this.layers,
    this.hotspots,
    this.cue,
    this.poses = const {},
    this.placements = const {},
    this.ambient = Ambient.none,
    this.ambientOrigin,
    super.key,
  });

  final String imageAsset;

  /// Asset paths already resolved for the hero. Null = draw flat.
  final List<SceneLayer>? layers;

  /// Tappable areas for parts that [layers] don't move.
  final List<SceneHotspot>? hotspots;

  /// Latest narration cue; a new [PartCue.seq] makes matching parts react.
  final PartCue? cue;

  /// Node's starting pose per part kind.
  final Map<String, String> poses;

  /// Math stories: counted parts' start spots, null = hidden
  /// ([Story.placements]).
  final Map<String, CanvasPoint?> placements;
  final VoidCallback onTap;
  final String semanticLabel;
  final Ambient ambient;
  final AmbientOrigin? ambientOrigin;

  @override
  State<ScenePicture> createState() => _ScenePictureState();
}

class _ScenePictureState extends State<ScenePicture> {
  final _reactions = ValueNotifier<PartReaction?>(null);
  final _bursts = ValueNotifier<BurstEvent?>(null);

  /// Where `move` cues sent each part kind (picture fractions), so taps
  /// still find it. Cleared when the picture changes.
  final _moved = <String, CanvasPoint>{};

  /// [ScenePicture.layers] with tap boxes shifted to where parts moved or
  /// were placed; hidden parts can't be tapped.
  List<SceneLayer>? get _tapLayers {
    final layers = widget.layers;
    final placed = widget.placements;
    if (layers == null || (_moved.isEmpty && placed.isEmpty)) return layers;
    return [
      for (final l in layers)
        if (placed.containsKey(l.kind) &&
            placed[l.kind] == null &&
            !_moved.containsKey(l.kind))
          l.copyWith(tap: null)
        else if ((_moved[l.kind] ?? placed[l.kind]) case final to?
            when l.box != null)
          l.copyWith(box: _shift(l.box!, moveOffset(l, to)))
        else
          l,
    ];
  }

  /// Hotspots for parts that aren't moving layers (a layered picture may cut
  /// out only Lulu and keep the child as a hotspot).
  List<SceneHotspot> get _hotspots {
    final moving = {
      for (final l in widget.layers ?? const <SceneLayer>[])
        if (l.tap != null) l.kind,
    };
    return [
      for (final h in widget.hotspots ?? const <SceneHotspot>[])
        if (!moving.contains(h.kind)) h,
    ];
  }

  void _burst(SceneHotspot h) => _bursts.value = BurstEvent(
    burst: h.burst,
    center: (x: h.box.x + h.box.w / 2, y: h.box.y + h.box.h / 2),
  );

  @override
  void didUpdateWidget(ScenePicture old) {
    super.didUpdateWidget(old);
    if (widget.imageAsset != old.imageAsset ||
        !mapEquals(widget.placements, old.placements)) {
      _moved.clear();
    }
    final cue = widget.cue;
    if (cue != null && cue.seq != old.cue?.seq) {
      _reactions.value = PartReaction(
        action: cue.action,
        kind: cue.part,
        pose: cue.pose,
        to: cue.to,
      );
      if (cue.action == PartAction.move && cue.to != null) {
        _moved[cue.part] = cue.to!;
      }
      // Pose and move only mean something for layers.
      if (cue.action.isTapReaction) {
        for (final h in _hotspots) {
          if (h.kind == cue.part) _burst(h);
        }
      }
    }
  }

  @override
  void dispose() {
    _reactions.dispose();
    _bursts.dispose();
    super.dispose();
  }

  void _handleTap(TapUpDetails details, Size size) {
    if (!MediaQuery.disableAnimationsOf(context)) {
      final point = Offset(
        details.localPosition.dx / size.width,
        details.localPosition.dy / size.height,
      );
      final layers = _tapLayers;
      final hit = layers == null ? null : hitPart(layers, point);
      if (hit != null) {
        HapticFeedback.lightImpact();
        _reactions.value = PartReaction(action: layers![hit].tap!, index: hit);
        return;
      }
      final spot = hitHotspot(_hotspots, point);
      if (spot != null) {
        HapticFeedback.lightImpact();
        _burst(spot);
        return;
      }
    }
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final layers = widget.layers;
    final picture = layers == null
        ? StoryImage(widget.imageAsset, fit: BoxFit.cover)
        : SceneLayers(
            layers: layers,
            reactions: _reactions,
            startPoses: widget.poses,
            placements: widget.placements,
          );

    return Center(
      child: AspectRatio(
        aspectRatio: AppConstants.sceneAspectRatio,
        child: Semantics(
          button: true,
          label: widget.semanticLabel,
          child: LayoutBuilder(
            builder: (context, box) => GestureDetector(
              onTapUp: (d) => _handleTap(d, box.biggest),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.lavender.withValues(alpha: 0.18),
                      blurRadius: 40,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  child: AnimatedSwitcher(
                    duration: AppConstants.sceneFadeDuration,
                    child: Stack(
                      key: ValueKey(widget.imageAsset),
                      fit: StackFit.expand,
                      children: [
                        _KenBurns(child: picture),
                        SceneAmbient(
                          ambient: widget.ambient,
                          origin: widget.ambientOrigin,
                          seed: widget.imageAsset.hashCode,
                        ),
                        SceneBurst(events: _bursts),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

CanvasBox _shift(CanvasBox b, Offset by) =>
    (x: b.x + by.dx, y: b.y + by.dy, w: b.w, h: b.h);

class _KenBurns extends StatelessWidget {
  const _KenBurns({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return SizedBox.expand(child: child);
    }
    // Boundary: the zoom only moves the drawn picture, never redraws it.
    return SizedBox.expand(
      child: RepaintBoundary(child: child)
          .animate()
          .scaleXY(
            begin: 1,
            end: AppConstants.kenBurnsScale,
            duration: AppConstants.kenBurnsDuration,
            curve: Curves.easeOut,
          )
          // Second layer starts when the zoom ends and loops forever.
          .animate(
            delay: AppConstants.kenBurnsDuration,
            onPlay: (c) => c.repeat(reverse: true),
          )
          .scaleXY(
            end: AppConstants.breatheScale,
            duration: AppConstants.breatheDuration,
            curve: Curves.easeInOut,
          )
          .moveX(
            begin: -AppConstants.breatheDrift,
            end: AppConstants.breatheDrift,
            duration: AppConstants.breatheDuration,
            curve: Curves.easeInOut,
          ),
    );
  }
}
