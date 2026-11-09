import 'package:flutter/material.dart';

/// Scrolls across the full available width while keeping [child] centered
/// and capped at [maxWidth], so a drag on the side margins scrolls too.
class CenteredScrollView extends StatelessWidget {
  const CenteredScrollView({
    super.key,
    required this.child,
    this.maxWidth = double.infinity,
    this.padding = EdgeInsets.zero,
    this.centerVertically = true,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  /// Centers short content vertically; otherwise it sits at the top.
  final bool centerVertically;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: box.maxWidth,
            minHeight: centerVertically ? box.maxHeight : 0,
          ),
          child: Align(
            alignment: centerVertically
                ? Alignment.center
                : Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Padding(padding: padding, child: child),
            ),
          ),
        ),
      ),
    );
  }
}
