import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// One chat turn sent to the model.
typedef ChatTurn = ({String role, String text});

/// Gemini API key — supplied at build time and NEVER committed:
///   flutter build apk --dart-define=GEMINI_API_KEY=your_free_tier_key
/// When absent, [ChatService.isConfigured] is false and the chat screen falls
/// back to its built-in offline knowledge base.
const _kGeminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

/// Free-tier Gemini model (Google AI Studio key). Flash is fast + free-tier
/// friendly; swap here if Google changes the free model lineup.
const _kGeminiModel = 'gemini-2.5-flash';

const _systemPrompt = '''
You are DermIQ's AI assistant — a friendly, knowledgeable skincare and haircare guide inside the DermIQ app.

Guidelines:
- Give practical, evidence-based advice on ingredients, routines, skin/hair concerns, and product types.
- Be concise and warm. Prefer short paragraphs or tight bullet points. Avoid jargon unless you explain it.
- When relevant, mention ingredient conflicts (e.g. retinol + AHAs), patch-testing, and sunscreen.
- You are NOT a doctor. For severe, persistent, or worsening conditions, advise seeing a dermatologist. Do not diagnose or prescribe.
- Stay on skincare/haircare topics; gently redirect off-topic questions.
''';

/// Talks directly to the Gemini REST API (free tier) from the app — no Cloud
/// Function / Blaze plan required. The key is injected at build time.
class ChatService {
  ChatService(this._client);
  final http.Client _client;

  bool get isConfigured => _kGeminiApiKey.isNotEmpty;

  Future<String> reply(List<ChatTurn> history) async {
    if (!isConfigured) {
      throw StateError('GEMINI_API_KEY not set');
    }

    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/'
      '$_kGeminiModel:generateContent?key=$_kGeminiApiKey',
    );

    final body = {
      'systemInstruction': {
        'parts': [
          {'text': _systemPrompt},
        ],
      },
      'contents': [
        for (final t in history)
          {
            // Gemini roles are 'user' / 'model'.
            'role': t.role == 'assistant' ? 'model' : 'user',
            'parts': [
              {'text': t.text},
            ],
          },
      ],
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 700,
      },
    };

    final res = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 25));

    if (res.statusCode != 200) {
      throw http.ClientException('Gemini ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      throw StateError('Empty Gemini response');
    }
    final parts =
        ((candidates.first as Map)['content'] as Map?)?['parts'] as List?;
    final text = (parts != null && parts.isNotEmpty)
        ? (parts.first as Map)['text'] as String?
        : null;
    final reply = text?.trim() ?? '';
    if (reply.isEmpty) throw StateError('Empty Gemini text');
    return reply;
  }
}

final chatServiceProvider =
    Provider<ChatService>((ref) => ChatService(http.Client()));
