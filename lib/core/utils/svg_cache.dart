import 'package:flutter_svg/flutter_svg.dart';

/// Parses an SVG asset into flutter_svg's cache ahead of time, so it shows
/// on the first frame when a widget later asks for it.
void precacheSvg(String asset) {
  final loader = SvgAssetLoader(asset);
  svg.cache.putIfAbsent(loader.cacheKey(null), () => loader.loadBytes(null));
}
