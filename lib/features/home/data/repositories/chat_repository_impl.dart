import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasources/chat_local_ds.dart';
import '../datasources/chat_remote_ds.dart';
import '../models/chat_message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDS remote;
  final ChatLocalDS local;

  ChatRepositoryImpl({required this.remote, required this.local});

  @override
  Stream<String> sendMessageStream({
    required String sessionId,
    required List<ChatMessage> history,
    required String userText,
  }) => remote.sendStream(
    sessionId: sessionId,
    history: history,
    userText: userText,
  );

  @override
  Future<List<ChatMessage>> loadHistory(
    String sessionId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final models = await local.load(sessionId, limit: limit, offset: offset);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> appendMessage(String sessionId, ChatMessage msg) async {
    final m = ChatMessageModel.fromEntity(msg)..id = '$sessionId:${msg.id}';
    await local.append(sessionId, m);
  }

  @override
  Future<void> clearHistory(String sessionId) => local.clear(sessionId);
}
