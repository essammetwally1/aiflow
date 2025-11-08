import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/send_message_stream.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository repo;
  final SendMessageStream sendMessageStream;
  final String sessionId;

  ChatProvider({
    required this.repo,
    required this.sendMessageStream,
    required this.sessionId,
  });

  final List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  StreamSubscription<String>? _sub;
  bool _isSending = false;
  bool get isSending => _isSending;

  Future<void> init() async {
    final history = await repo.loadHistory(sessionId, limit: 100);
    _messages.clear();
    // ..addAll(history);
    notifyListeners();
  }

  Future<void> clear() async {
    await repo.clearHistory(sessionId);
    _messages.clear();
    notifyListeners();
  }

  Future<void> send(String text) async {
    if (_isSending) return;
    _isSending = true;
    notifyListeners();

    final userMsg = ChatMessage(
      id: const Uuid().v4(),
      role: ChatRole.user,
      content: text,
      createdAt: DateTime.now(),
    );
    _messages.add(userMsg);
    await repo.appendMessage(sessionId, userMsg);
    notifyListeners();

    final assistantId = const Uuid().v4();
    _messages.add(
      ChatMessage(
        id: assistantId,
        role: ChatRole.assistant,
        content: '',
        createdAt: DateTime.now(),
        isStreaming: true,
      ),
    );
    notifyListeners();

    final history = _messages;
    _sub =
        sendMessageStream(
          sessionId: sessionId,
          history: history,
          userText: text,
        ).listen(
          (delta) async {
            final i = _messages.indexWhere((m) => m.id == assistantId);
            if (i != -1) {
              _messages[i] = _messages[i].copyWith(
                content: _messages[i].content + delta,
              );
              notifyListeners();
            }
          },
          onError: (_) {
            final i = _messages.indexWhere((m) => m.id == assistantId);
            if (i != -1) {
              _messages[i] = _messages[i].copyWith(
                isStreaming: false,
                isFailed: true,
              );
            }
            _isSending = false;
            notifyListeners();
          },
          onDone: () async {
            final i = _messages.indexWhere((m) => m.id == assistantId);
            if (i != -1) {
              final finalized = _messages[i].copyWith(isStreaming: false);
              _messages[i] = finalized;
              await repo.appendMessage(sessionId, finalized);
            }
            _isSending = false;
            notifyListeners();
          },
        );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
