import 'dart:convert';

import 'package:aiflow/features/home/domain/entities/chat_message.dart';
import 'package:http/http.dart' as http;

class ChatRemoteDS {
  final String baseUrl;
  final http.Client client;
  ChatRemoteDS({required this.baseUrl, http.Client? client})
    : client = client ?? http.Client();

  Stream<String> sendStream({
    required String sessionId,
    required List<ChatMessage> history,
    required String userText,
  }) async* {
    final payload = {
      'sessionId': sessionId,
      'messages': [
        for (final m
            in (history.length > 15
                ? history.sublist(history.length - 15)
                : history))
          {'role': m.role.name, 'content': m.content},
        {'role': 'user', 'content': userText},
      ],
      'stream': true,
    };

    final req = http.Request('POST', Uri.parse(baseUrl))
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream', // <- important
      })
      ..body = jsonEncode(payload);

    final resp = await client.send(req);

    if (resp.statusCode != 200) {
      // Read body for diagnostics
      final body = await resp.stream.bytesToString();
      // You can surface this via a logger/toast; for now throw:
      throw Exception('Chat stream error ${resp.statusCode}: $body');
    }

    // Re-open the stream since we might have consumed it above on error
    final stream = resp.stream.transform(utf8.decoder);

    // SSE frames can split arbitrarily; aggregate by lines
    await for (final chunk in stream.transform(const LineSplitter())) {
      if (chunk.isEmpty) continue;
      if (chunk.startsWith(':')) continue; // SSE comment/keepalive
      if (!chunk.startsWith('data:')) continue;

      final data = chunk.substring(5).trim();
      if (data == '[DONE]') break;

      try {
        final j = jsonDecode(data);
        final delta = j['choices']?[0]?['delta']?['content'];
        if (delta is String && delta.isNotEmpty) {
          yield delta;
        }
      } catch (_) {
        // ignore malformed lines
      }
    }
  }
}
