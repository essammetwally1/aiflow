import 'package:hive/hive.dart';
import '../models/chat_message_model.dart';

class ChatLocalDS {
  final Box<ChatMessageModel> box;
  ChatLocalDS(this.box);

  Future<List<ChatMessageModel>> load(
    String sessionId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final items =
        box.values.where((m) => m.id.startsWith('$sessionId:')).toList()
          ..sort((a, b) => a.createdAtMs.compareTo(b.createdAtMs));
    return items.skip(offset).take(limit).toList();
  }

  Future<void> append(String sessionId, ChatMessageModel m) async {
    await box.put(m.id, m);
  }

  Future<void> clear(String sessionId) async {
    final toDelete = box.keys
        .where((k) => k.toString().startsWith('$sessionId:'))
        .toList();
    await box.deleteAll(toDelete);
  }
}
