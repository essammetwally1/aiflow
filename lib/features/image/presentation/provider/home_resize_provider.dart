import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// NEW: decode dimensions
import 'package:image/image.dart' as img;

import 'package:aiflow/features/image/data/repositories/image_repository.dart';
import 'package:aiflow/features/image/domain/entities/resized_image.dart';

enum HomeResizeStatus { idle, picking, readyToResize, resizing, done, error }

class HomeResizeProvider extends ChangeNotifier {
  final ImageRepository _repo;

  HomeResizeProvider(this._repo);

  HomeResizeStatus status = HomeResizeStatus.idle;
  File? picked;
  ResizedImage? output;
  String? message;

  int width = 0;
  int height = 0;

  void setWidth(String v) {
    final n = int.tryParse(v);
    if (n != null && n > 0) width = n;
    notifyListeners();
  }

  void setHeight(String v) {
    final n = int.tryParse(v);
    if (n != null && n > 0) height = n;
    notifyListeners();
  }

  Future<void> pick(ImageSource src) async {
    status = HomeResizeStatus.picking;
    output = null;
    message = null;
    notifyListeners();

    try {
      final file = await _repo.pick(src);
      if (file == null) {
        status = picked == null
            ? HomeResizeStatus.idle
            : HomeResizeStatus.readyToResize;
        notifyListeners();
        return;
      }

      picked = file;

      // === NEW: compute actual dimensions (with EXIF orientation applied) ===
      try {
        final bytes = await file.readAsBytes();
        final decoded = img.decodeImage(bytes);
        if (decoded != null) {
          final oriented = img.bakeOrientation(decoded);
          width = oriented.width;
          height = oriented.height;
        }
      } catch (e) {
        // Non-fatal: keep defaults if something goes wrong
        message = 'Could not read image dimensions: $e';
      }
      // =====================================================================

      status = HomeResizeStatus.readyToResize;
      notifyListeners();
    } catch (e) {
      status = HomeResizeStatus.error;
      message = '$e';
      notifyListeners();
    }
  }

  Future<void> doResize() async {
    final src = picked;
    if (src == null) return;

    status = HomeResizeStatus.resizing;
    output = null;
    message = null;
    notifyListeners();

    try {
      final r = await _repo.resize(input: src, width: width, height: height);
      output = r;
      status = HomeResizeStatus.done;
      notifyListeners();
    } catch (e) {
      status = HomeResizeStatus.error;
      message = '$e';
      notifyListeners();
    }
  }

  Future<bool> saveOutputToGallery() async {
    final out = output?.result;
    if (out == null) return false;
    return _repo.saveToGallery(out);
  }

  void reset() {
    status = HomeResizeStatus.idle;
    picked = null;
    output = null;
    message = null;
    width = 0;
    height = 0;
  }
}
