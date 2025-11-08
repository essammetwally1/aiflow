import 'dart:async';
import '../entities/chat_message.dart';

abstract class ChatRepository {
  Stream<String> sendMessageStream({
    required String sessionId,
    required List<ChatMessage> history,
    required String userText,
  });

  Future<List<ChatMessage>> loadHistory(
    String sessionId, {
    int limit = 50,
    int offset = 0,
  });
  Future<void> appendMessage(String sessionId, ChatMessage msg);
  Future<void> clearHistory(String sessionId);
}
