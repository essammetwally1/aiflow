import 'dart:io';

class ResizedImage {
  final File original;
  final File result;
  final int width;
  final int height;
  ResizedImage({
    required this.original,
    required this.result,
    required this.width,
    required this.height,
  });
}
