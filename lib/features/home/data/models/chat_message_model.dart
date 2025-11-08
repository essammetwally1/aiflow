import 'package:hive/hive.dart';
import '../../domain/entities/chat_message.dart';

// MUST match the file's exact name (case-sensitive on Linux)
part 'chat_message_model.g.dart';

@HiveType(typeId: 11) // unique across the whole app
class ChatMessageModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  int roleIndex; // 0 user, 1 assistant, 2 system

  @HiveField(2)
  String content;

  @HiveField(3)
  int createdAtMs;

  ChatMessageModel({
    required this.id,
    required this.roleIndex,
    required this.content,
    required this.createdAtMs,
  });

  factory ChatMessageModel.fromEntity(ChatMessage e) => ChatMessageModel(
    id: e.id,
    roleIndex: e.role.index,
    content: e.content,
    createdAtMs: e.createdAt.millisecondsSinceEpoch,
  );

  ChatMessage toEntity() => ChatMessage(
    id: id,
    role: ChatRole.values[roleIndex],
    content: content,
    createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
  );
}
