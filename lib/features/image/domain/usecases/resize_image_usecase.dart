import 'dart:io';
import 'package:aiflow/core/services/resize/resize_service.dart';
import 'package:image/image.dart' as img;
import '../entities/resized_image.dart';

class ResizeImageUseCase {
  Future<ResizedImage> call({
    required File input,
    required int width,
    required int height,
  }) async {
    final out = await ResizeService.resize(
      image: input,
      width: width,
      height: height,
      interpolation: img.Interpolation.cubic,
      jpegQuality: 95,
    );
    return ResizedImage(
      original: input,
      result: out,
      width: width,
      height: height,
    );
  }
}
