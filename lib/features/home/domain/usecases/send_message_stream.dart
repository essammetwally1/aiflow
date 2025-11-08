import '../repositories/chat_repository.dart';
import '../entities/chat_message.dart';

class SendMessageStream {
  final ChatRepository repo;
  SendMessageStream(this.repo);

  Stream<String> call({
    required String sessionId,
    required List<ChatMessage> history,
    required String userText,
  }) => repo.sendMessageStream(
    sessionId: sessionId,
    history: history,
    userText: userText,
  );
}
