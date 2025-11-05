import 'dart:typed_data';

abstract class AvatarStorage {
  Future<String> uploadAvatar({
    required String userId,
    required Uint8List bytes,
    String? previousUrl,
  });

  Future<void> deleteAvatarByUrl(String url);
}
