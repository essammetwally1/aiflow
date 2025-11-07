import 'dart:io';
import 'package:image_picker/image_picker.dart';

class PickImageUseCase {
  final ImagePicker _picker = ImagePicker();

  Future<File?> call(ImageSource source) async {
    final x = await _picker.pickImage(
      source: source,
      imageQuality: 100,
      maxWidth: 8192,
      maxHeight: 8192,
    );
    if (x == null) return null;
    return File(x.path);
  }
}
