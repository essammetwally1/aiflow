import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ResizeService {
  static const _maxDimension = 8192;

  static Future<File> resize({
    required File image,
    required int width,
    required int height,
    int jpegQuality = 95,
    img.Interpolation interpolation = img.Interpolation.cubic,
  }) async {
    if (!image.existsSync()) throw Exception('Image not found');
    if (width <= 0 || height <= 0) throw Exception('Invalid dimensions');
    if (width > _maxDimension || height > _maxDimension) {
      throw Exception('Max dimension is $_maxDimension px');
    }

    final result = await compute<_Params, _Result>(
      _isolateResize,
      _Params(image.path, width, height, jpegQuality, interpolation),
    );

    final dir = await getTemporaryDirectory();
    final name =
        'resized_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(9999)}.${result.ext}';
    final out = File('${dir.path}/$name');
    await out.writeAsBytes(result.bytes, flush: true);
    return out;
  }

  static _Result _isolateResize(_Params p) {
    final srcBytes = File(p.path).readAsBytesSync();
    final decoded = img.decodeImage(srcBytes);
    if (decoded == null) throw Exception('Unsupported/invalid image');

    final oriented = img.bakeOrientation(decoded);
    final resized = img.copyResize(
      oriented,
      width: p.w,
      height: p.h,
      interpolation: p.i,
      maintainAspect: false, // exact dimensions as requested
    );

    final jpg = img.encodeJpg(resized, quality: p.q);
    return _Result(jpg, 'jpg');
  }
}

class _Params {
  final String path;
  final int w, h, q;
  final img.Interpolation i;
  _Params(this.path, this.w, this.h, this.q, this.i);
}

class _Result {
  final List<int> bytes;
  final String ext;
  _Result(this.bytes, this.ext);
}
