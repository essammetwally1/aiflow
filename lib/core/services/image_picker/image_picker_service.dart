import 'dart:io' show File;
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/material.dart';
import 'package:aiflow/core/theme/app_theme.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<Uint8List?> pickAndCrop(
    ImageSource source, {
    required bool isDark,
  }) async {
    final XFile? picked = await _picker.pickImage(
      source: source,
      maxWidth: 2000,
      maxHeight: 2000,
      imageQuality: 100,
    );
    if (picked == null) return null;

    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      return _compress(bytes);
    }

    // Theme-aware cropper
    final Color toolbarColor = isDark
        ? AppTheme.backgroundDark
        : AppTheme.backgroundLight;
    final Color toolbarWidgetColor = AppTheme.primary;
    final Color activeControlsWidgetColor = AppTheme.primary;

    final CroppedFile? cropped = await ImageCropper().cropImage(
      sourcePath: picked.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressFormat: ImageCompressFormat.jpg,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop',
          toolbarColor: toolbarColor,
          toolbarWidgetColor: toolbarWidgetColor,
          activeControlsWidgetColor: activeControlsWidgetColor,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          hideBottomControls: true,
          statusBarColor: toolbarColor,
          backgroundColor: toolbarColor,
        ),
        IOSUiSettings(title: 'Crop', aspectRatioLockEnabled: true),
      ],
    );
    if (cropped == null) return null;

    final bytes = await File(cropped.path).readAsBytes();
    return _compress(bytes);
  }

  Future<Uint8List> _compress(Uint8List input) async {
    final out = await FlutterImageCompress.compressWithList(
      input,
      minWidth: 800,
      minHeight: 800,
      quality: 85,
      format: CompressFormat.jpeg,
    );
    return Uint8List.fromList(out);
  }
}
