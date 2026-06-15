import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shop/data/payment_service.dart' show firebaseFunctionsProvider;

/// One chat turn sent to the backend.
typedef ChatTurn = ({String role, String text});

/// Talks to the `chatWithDermiq` Cloud Function, which proxies to the Claude
/// API server-side (the API key never ships in the app).
class ChatService {
  ChatService(this._ref);
  final Ref _ref;

  Future<String> reply(List<ChatTurn> history) async {
    final functions = _ref.read(firebaseFunctionsProvider);
    final res = await functions.httpsCallable('chatWithDermiq').call({
      'messages': [
        for (final t in history) {'role': t.role, 'content': t.text},
      ],
    });
    final data = res.data as Map;
    return (data['reply'] as String?)?.trim().isNotEmpty == true
        ? data['reply'] as String
        : "Sorry, I couldn't generate a response. Please try again.";
  }
}

final chatServiceProvider = Provider<ChatService>((ref) => ChatService(ref));
