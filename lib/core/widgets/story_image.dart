import 'dart:developer';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bedtime_stories/core/utils/app_constants.dart';
import 'package:bedtime_stories/core/utils/svg_cache.dart';

bool _isSvg(String asset) => asset.toLowerCase().endsWith('.svg');

/// Draws a story picture asset: SVG (drawn art) or PNG/JPG/WebP (AI art).
class StoryImage extends StatelessWidget {
  const StoryImage(
    this.asset, {
    this.fit,
    this.width,
    this.height,
    this.bitmap = false,
    super.key,
  });

  final String asset;
  final BoxFit? fit;
  final double? width;
  final double? height;

  /// Draw once as a bitmap sized to the box, for still pictures in lists
  /// (story covers). Without it an SVG is redrawn from its vectors on every
  /// frame, which the home stars and scrolling ask for many times a second.
  /// Raster art is decoded at box size instead of full 1600×1200.
  final bool bitmap;

  @override
  Widget build(BuildContext context) {
    if (bitmap) {
      return SizedBox(
        width: width,
        height: height,
        child: LayoutBuilder(
          builder: (context, box) {
            final dpr = MediaQuery.devicePixelRatioOf(context);
            if (!box.hasBoundedWidth || !box.hasBoundedHeight) {
              return StoryImage(asset, fit: fit);
            }
            final pixels = Size(
              (box.maxWidth * dpr).roundToDouble(),
              (box.maxHeight * dpr).roundToDouble(),
            );
            if (_isSvg(asset)) {
              return _SvgBitmap(
                asset: asset,
                fit: fit ?? BoxFit.contain,
                pixels: pixels,
                scale: dpr,
              );
            }
            // Decode at a fixed bucket, not the exact box width: every new
            // width is a new image-cache key, which on web fetches and
            // decodes the file again (window resize, column change).
            return Image.asset(
              asset,
              fit: fit,
              width: box.maxWidth,
              height: box.maxHeight,
              cacheWidth: pixels.width <= AppConstants.smallCoverDecodeWidth
                  ? AppConstants.smallCoverDecodeWidth.toInt()
                  : null,
              gaplessPlayback: true,
              filterQuality: FilterQuality.medium,
            );
          },
        ),
      );
    }
    if (_isSvg(asset)) {
      return SvgPicture.asset(
        asset,
        fit: fit ?? BoxFit.contain,
        width: width,
        height: height,
      );
    }
    return Image.asset(
      asset,
      fit: fit,
      width: width,
      height: height,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
    );
  }
}

/// Loads a picture ahead of time so it shows on its first frame.
void precacheStoryImage(BuildContext context, String asset) {
  if (_isSvg(asset)) {
    precacheSvg(asset);
  } else {
    precacheImage(AssetImage(asset), context);
  }
}

/// An SVG rendered once into a [ui.Image] of exactly [pixels].
class _SvgBitmap extends StatefulWidget {
  const _SvgBitmap({
    required this.asset,
    required this.fit,
    required this.pixels,
    required this.scale,
  });

  final String asset;
  final BoxFit fit;
  final Size pixels;
  final double scale;

  @override
  State<_SvgBitmap> createState() => _SvgBitmapState();
}

class _SvgBitmapState extends State<_SvgBitmap> {
  ui.Image? _image;
  String? _key;

  String get _wanted =>
      '${widget.asset}@${widget.fit.name}:'
      '${widget.pixels.width.toInt()}x${widget.pixels.height.toInt()}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(_SvgBitmap old) {
    super.didUpdateWidget(old);
    if (_wanted != _key) _load();
  }

  Future<void> _load() async {
    final key = _wanted;
    _key = key;
    final image = await _SvgBitmapCache.get(
      key,
      widget.asset,
      widget.fit,
      widget.pixels,
    );
    if (!mounted || _key != key) {
      image?.dispose();
      return;
    }
    setState(() {
      _image?.dispose();
      _image = image;
    });
  }

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    // Until the bitmap is ready (a frame or two), draw the vectors.
    if (image == null) {
      return SvgPicture.asset(widget.asset, fit: widget.fit);
    }
    return RawImage(
      image: image,
      scale: widget.scale,
      fit: BoxFit.fill,
      filterQuality: FilterQuality.medium,
    );
  }
}

/// Keeps a few rendered covers, so going back home doesn't render again.
/// Callers get their own [ui.Image.clone] handle and dispose it.
abstract final class _SvgBitmapCache {
  static const _maxEntries = 16;
  static final _images = <String, Future<ui.Image?>>{}; // insertion order

  static Future<ui.Image?> get(
    String key,
    String asset,
    BoxFit fit,
    Size pixels,
  ) async {
    final pending = _images.remove(key) ?? _render(asset, fit, pixels);
    _images[key] = pending; // most recent last
    while (_images.length > _maxEntries) {
      final oldest = _images.keys.first;
      final evicted = _images.remove(oldest);
      evicted?.then((img) => img?.dispose());
    }
    final image = await pending;
    if (image == null) _images.remove(key); // try again next time
    return image?.clone();
  }

  static Future<ui.Image?> _render(
    String asset,
    BoxFit fit,
    Size pixels,
  ) async {
    try {
      final info = await vg.loadPicture(SvgAssetLoader(asset), null);
      final fitted = applyBoxFit(fit, info.size, pixels);
      final src = Alignment.center.inscribe(
        fitted.source,
        Offset.zero & info.size,
      );
      final dst = Alignment.center.inscribe(
        fitted.destination,
        Offset.zero & pixels,
      );
      final recorder = ui.PictureRecorder();
      Canvas(recorder)
        ..clipRect(Offset.zero & pixels)
        ..translate(dst.left, dst.top)
        ..scale(dst.width / src.width, dst.height / src.height)
        ..translate(-src.left, -src.top)
        ..drawPicture(info.picture);
      info.picture.dispose();
      final picture = recorder.endRecording();
      final image = await picture.toImage(
        pixels.width.toInt(),
        pixels.height.toInt(),
      );
      picture.dispose();
      return image;
    } catch (e) {
      log('render $asset failed: $e', name: 'StoryImage');
      return null;
    }
  }
}
