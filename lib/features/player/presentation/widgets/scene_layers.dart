import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bedtime_stories/core/utils/app_constants.dart';
import 'package:bedtime_stories/features/stories/domain/entities/story.dart';
import 'package:bedtime_stories/core/widgets/story_image.dart';

/// Asks picture parts to react: one layer by [index] (a tap) or every
/// layer of a [kind] (a narration cue). A new object each time, so the same
/// reaction twice still plays twice.
final class PartReaction {
  const PartReaction({
    required this.action,
    this.index,
    this.kind,
    this.pose,
    this.to,
  });

  final PartAction action;
  final int? index;
  final String? kind;

  /// With [PartAction.pose] / [PartAction.move], see [StoryCue].
  final String? pose;
  final CanvasPoint? to;
}

/// How far a part travels to put its pivot on [to] (fractions of the picture).
Offset moveOffset(SceneLayer layer, CanvasPoint to) =>
    Offset(to.x - layer.pivot.x, to.y - layer.pivot.y);

/// A scene picture drawn as stacked layers (see `tool/gen_art.py`). Parts
/// loop their idle motion, blink, and react to [reactions].
class SceneLayers extends StatelessWidget {
  const SceneLayers({
    required this.layers,
    required this.reactions,
    this.startPoses = const {},
    super.key,
  });

  /// Asset paths already resolved for the hero.
  final List<SceneLayer> layers;
  final ValueListenable<PartReaction?> reactions;

  /// Node's starting pose per part kind.
  final Map<String, String> startPoses;

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return Stack(
      fit: StackFit.expand,
      children: [
        for (var i = 0; i < layers.length; i++)
          if (layers[i].isPart)
            _PartLayer(
              layer: layers[i],
              index: i,
              reactions: reactions,
              still: still,
              startPose: startPoses[layers[i].kind],
            )
          else
            _svg(layers[i].asset),
      ],
    );
  }
}

/// Whether [point] (fractions of the picture) is inside [b], with the
/// small-finger padding.
bool hitBox(CanvasBox b, Offset point) {
  const pad = AppConstants.partTapPadding;
  return point.dx >= b.x - pad &&
      point.dx <= b.x + b.w + pad &&
      point.dy >= b.y - pad &&
      point.dy <= b.y + b.h + pad;
}

/// Topmost tappable layer under [point] (fractions of the picture), or null.
int? hitPart(List<SceneLayer> layers, Offset point) {
  for (var i = layers.length - 1; i >= 0; i--) {
    final l = layers[i];
    final b = l.box;
    if (l.tap != null && b != null && hitBox(b, point)) return i;
  }
  return null;
}

/// Last (topmost) hotspot under [point], or null.
SceneHotspot? hitHotspot(List<SceneHotspot> hotspots, Offset point) {
  for (final h in hotspots.reversed) {
    if (hitBox(h.box, point)) return h;
  }
  return null;
}

Widget _svg(String asset) => StoryImage(asset, fit: BoxFit.cover);

/// Draws [child] in [rect] (fractions) of the picture box it fills.
class InRect extends StatelessWidget {
  const InRect({required this.rect, required this.child, super.key});

  final CanvasBox rect;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      CustomSingleChildLayout(delegate: _RectLayout(rect), child: child);
}

class _RectLayout extends SingleChildLayoutDelegate {
  const _RectLayout(this.rect);

  final CanvasBox rect;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints.tight(
        Size(constraints.maxWidth * rect.w, constraints.maxHeight * rect.h),
      );

  @override
  Offset getPositionForChild(Size size, Size childSize) =>
      Offset(size.width * rect.x, size.height * rect.y);

  @override
  bool shouldRelayout(_RectLayout old) => old.rect != rect;
}

class _PartLayer extends StatefulWidget {
  const _PartLayer({
    required this.layer,
    required this.index,
    required this.reactions,
    required this.still,
    this.startPose,
  });

  final SceneLayer layer;
  final int index;
  final ValueListenable<PartReaction?> reactions;

  /// Reduced motion: no idle, blink or bounce; pose and move still apply
  /// (they carry meaning), instantly.
  final bool still;
  final String? startPose;

  @override
  State<_PartLayer> createState() => _PartLayerState();
}

class _PartLayerState extends State<_PartLayer> with TickerProviderStateMixin {
  late final AnimationController _idle;
  late final AnimationController _react;
  late final AnimationController _squash;
  late final AnimationController _move;
  final _blinking = ValueNotifier(false);
  late final ValueNotifier<String> _pose;
  final _rnd = Random();
  PartAction? _action;
  Timer? _blinkTimer;

  /// Travel offset (fractions of the picture): tweens from [_moveFrom] to
  /// [_moveTo] while [_move] runs, then holds.
  Offset _moveFrom = Offset.zero;
  Offset _moveTo = Offset.zero;

  SceneLayer get _layer => widget.layer;

  String _validPose(String? name) =>
      name != null && _layer.hasPose(name) ? name : defaultPose;

  @override
  void initState() {
    super.initState();
    _pose = ValueNotifier(_validPose(widget.startPose));
    _idle = AnimationController(
      vsync: this,
      duration: _idlePeriod(_layer.idle),
    );
    _squash = AnimationController(
      vsync: this,
      duration: AppConstants.poseSquashDuration,
    );
    _move = AnimationController(
      vsync: this,
      duration: AppConstants.partMoveDuration,
    );
    if (_layer.idle != PartIdle.none && !widget.still) {
      // Offset each part so they don't all move in step.
      _idle
        ..value = (widget.index * 0.37) % 1
        ..repeat();
    }
    _react = AnimationController(
      vsync: this,
      duration: AppConstants.partReactDuration,
    );
    widget.reactions.addListener(_onReaction);
    if (_layer.blinkAsset != null && _layer.poses.isEmpty && !widget.still) {
      _scheduleBlink();
    }
  }

  @override
  void didUpdateWidget(_PartLayer old) {
    super.didUpdateWidget(old);
    // Same picture, next node (a choice reusing the scene): its start pose.
    if (widget.startPose != old.startPose && widget.startPose != null) {
      _pose.value = _validPose(widget.startPose);
    }
  }

  Offset get _moveOffset {
    final t = Curves.easeInOut.transform(_move.value);
    return Offset.lerp(_moveFrom, _moveTo, t)!;
  }

  void _onReaction() {
    final r = widget.reactions.value;
    if (r == null) return;
    final mine =
        r.index == widget.index || (r.kind != null && r.kind == _layer.kind);
    if (!mine) return;
    switch (r.action) {
      case PartAction.pose:
        final pose = r.pose;
        if (pose == null || !_layer.hasPose(pose)) return;
        _pose.value = pose;
        if (!widget.still) _squash.forward(from: 0);
      case PartAction.move:
        final to = r.to;
        if (to == null) return;
        _moveFrom = _moveOffset;
        _moveTo = moveOffset(_layer, to);
        if (widget.still) {
          _move.value = 1;
        } else {
          _move.forward(from: 0);
        }
      case PartAction.hop || PartAction.wiggle || PartAction.pulse:
        if (widget.still) return;
        _action = r.action;
        _react.forward(from: 0);
    }
  }

  void _scheduleBlink() {
    final wait =
        AppConstants.blinkMinGap +
        AppConstants.blinkMinGap * _rnd.nextDouble() * 1.5;
    _blinkTimer = Timer(wait, () {
      if (!mounted) return;
      _blinking.value = true;
      _blinkTimer = Timer(AppConstants.blinkDuration, () {
        if (!mounted) return;
        _blinking.value = false;
        _scheduleBlink();
      });
    });
  }

  @override
  void dispose() {
    widget.reactions.removeListener(_onReaction);
    _blinkTimer?.cancel();
    _idle.dispose();
    _react.dispose();
    _squash.dispose();
    _move.dispose();
    _blinking.dispose();
    _pose.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blink = _layer.blinkAsset;
    final picture = _layer.poses.isNotEmpty
        ? _poseStack()
        : blink == null
        ? _svg(_layer.asset)
        : Stack(
            fit: StackFit.expand,
            children: [
              _svg(_layer.asset),
              // Kept in the tree (loaded) and just shown for a moment.
              ValueListenableBuilder<bool>(
                valueListenable: _blinking,
                builder: (context, on, child) =>
                    Opacity(opacity: on ? 1 : 0, child: child),
                child: _svg(blink),
              ),
            ],
          );
    final pivot = Alignment(_layer.pivot.x * 2 - 1, _layer.pivot.y * 2 - 1);
    final rect = _layer.rect;
    // Motion below works on the whole picture box, so pivot, moves and tap
    // boxes stay picture fractions; a cropped part just sits at its rect.
    final placed = rect == null ? picture : InRect(rect: rect, child: picture);

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_idle, _react, _squash, _move]),
        child: placed,
        builder: (context, child) {
          final m = _Motion();
          if (!widget.still) {
            m.applyIdle(_layer.idle, _idle.value);
            if (_react.isAnimating) m.applyAction(_action, _react.value);
            if (_squash.isAnimating) m.applySquash(_squash.value);
            // A small arc while travelling.
            if (_move.isAnimating) m.dy -= 0.06 * sin(pi * _move.value);
          }
          final travel = _moveOffset;
          return FractionalTranslation(
            translation: Offset(travel.dx, travel.dy + m.dy),
            child: Transform(
              alignment: pivot,
              transform: Matrix4.rotationZ(m.rot)
                ..multiply(Matrix4.diagonal3Values(m.sx, m.sy, 1)),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

extension on _PartLayerState {
  /// Every pose stays loaded; only the current one shows (quick cross-fade).
  Widget _poseStack() {
    final names = [defaultPose, ..._layer.poses.keys];
    final fade = widget.still ? Duration.zero : AppConstants.poseFadeDuration;
    return ValueListenableBuilder<String>(
      valueListenable: _pose,
      builder: (context, current, _) => Stack(
        fit: StackFit.expand,
        children: [
          for (final name in names)
            AnimatedOpacity(
              key: ValueKey(name),
              opacity: name == current ? 1 : 0,
              duration: fade,
              child: _svg(_layer.poseAsset(name)),
            ),
        ],
      ),
    );
  }
}

Duration _idlePeriod(PartIdle idle) => switch (idle) {
  PartIdle.breathe => const Duration(milliseconds: 3200),
  PartIdle.float => const Duration(milliseconds: 2600),
  PartIdle.sway => const Duration(milliseconds: 4000),
  PartIdle.glow => const Duration(milliseconds: 3400),
  PartIdle.none => const Duration(seconds: 1),
};

/// Offsets for one frame. [dy] is a fraction of the picture height,
/// [rot] in radians, [sx]/[sy] scale around the part's pivot.
final class _Motion {
  double dy = 0;
  double rot = 0;
  double sx = 1;
  double sy = 1;

  void applyIdle(PartIdle idle, double t) {
    final w = sin(2 * pi * t);
    switch (idle) {
      case PartIdle.breathe:
        sy *= 1 + 0.014 * w;
        sx *= 1 - 0.005 * w;
      case PartIdle.float:
        dy += 0.009 * w;
      case PartIdle.sway:
        rot += 0.025 * w;
      case PartIdle.glow:
        final g = 1 + 0.035 * (w + 1) / 2;
        sx *= g;
        sy *= g;
      case PartIdle.none:
        break;
    }
  }

  /// Small squash-and-stretch when a part switches pose.
  void applySquash(double t) {
    final s = 0.05 * sin(pi * t);
    sy *= 1 - s;
    sx *= 1 + s;
  }

  void applyAction(PartAction? action, double t) {
    switch (action) {
      case PartAction.hop:
        // Two little bounces, the second smaller; squash on landing.
        final h = sin(2 * pi * t).abs() * (1 - 0.45 * t);
        dy -= 0.055 * h;
        final squash = (1 - h) * sin(pi * t) * 0.06;
        sy *= 1 - squash;
        sx *= 1 + squash;
      case PartAction.wiggle:
        rot += 0.13 * sin(6 * pi * t) * (1 - t);
      case PartAction.pulse:
        final p = 1 + 0.14 * sin(pi * t);
        sx *= p;
        sy *= p;
      case PartAction.pose || PartAction.move || null:
        break;
    }
  }
}
