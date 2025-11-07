import 'dart:io';
import 'package:aiflow/core/services/resize/resize_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:gal/gal.dart';

import '../../domain/entities/resized_image.dart';

class ImageRepository {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pick(ImageSource source) async {
    final x = await _picker.pickImage(
      source: source,
      imageQuality: 100,
      maxWidth: 8192,
      maxHeight: 8192,
    );
    if (x == null) return null;
    return File(x.path);
  }

  Future<ResizedImage> resize({
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

  /// Returns true on success.
  Future<bool> saveToGallery(File file) async {
    // Ask for access (gal handles platform differences).
    final granted = await Gal.requestAccess(toAlbum: true);
    if (!granted) return false;

    // Save to album (uses MediaStore on Android, Photos on iOS).
    await Gal.putImage(file.path, album: 'AiFlow');
    return true;
  }
}
