import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'avatar_storage.dart';

class SupabaseAvatarStorage implements AvatarStorage {
  SupabaseAvatarStorage(this._sb);

  final SupabaseClient _sb;
  static const String bucket = 'avatars';

  @override
  Future<String> uploadAvatar({
    required String userId,
    required Uint8List bytes,
    String? previousUrl,
  }) async {
    final filename = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = '$userId/$filename';

    await _sb.storage
        .from(bucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(
            upsert: true,
            contentType: 'image/jpeg',
          ),
        );

    // Delete previous *after* successful upload to avoid losing old pic on failure
    if (previousUrl != null && previousUrl.isNotEmpty) {
      await _safeDeleteByUrl(previousUrl);
    }

    return _sb.storage.from(bucket).getPublicUrl(path);
  }

  @override
  Future<void> deleteAvatarByUrl(String url) async {
    await _safeDeleteByUrl(url);
  }

  Future<void> _safeDeleteByUrl(String url) async {
    final path = _pathFromPublicUrl(url);
    if (path != null && path.isNotEmpty) {
      await _sb.storage.from(bucket).remove([path]);
    }
  }

  String? _pathFromPublicUrl(String url) {
    const needle = '/storage/v1/object/public/$bucket/';
    final i = url.indexOf(needle);
    if (i == -1) return null;
    return url.substring(i + needle.length);
  }
}
