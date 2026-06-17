import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/chat_service.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <_Message>[
    _Message(
      text: 'Hi! I\'m your DermIQ AI assistant. Ask me anything about skincare — ingredients, routines, concerns, or product compatibility.',
      isAI: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
  ];
  bool _isTyping = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_Message(text: text, isAI: false, timestamp: DateTime.now()));
      _controller.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    // Real assistant via the Claude-backed Cloud Function. Falls back to the
    // built-in keyword replies if the backend isn't reachable (offline / not
    // yet deployed) so the chat never dead-ends.
    String reply;
    try {
      final history = [
        for (final m in _messages)
          (role: m.isAI ? 'assistant' : 'user', text: m.text),
      ];
      reply = await ref.read(chatServiceProvider).reply(history);
    } catch (_) {
      reply = _getAIResponse(text);
    }

    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _messages.add(_Message(
        text: reply,
        isAI: true,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Offline skincare/haircare knowledge base. Used as a graceful fallback when
  /// the Claude-backed Cloud Function isn't reachable — it matches the question
  /// against scored keyword rules and returns the best answer, so the assistant
  /// stays genuinely useful without a network/API key.
  String _getAIResponse(String question) {
    final q = question.toLowerCase();
    bool has(List<String> ks) => ks.any(q.contains);

    // Most specific intents first (ingredient conflicts), then topics.
    if (has(['vitamin c', 'vit c']) && has(['retinol', 'retinoid'])) {
      return 'Use them at different times: Vitamin C in the morning (it boosts your SPF\'s antioxidant defence) and Retinol at night (when skin repairs). Layering both together can be irritating and less effective, so AM/PM split is the safe, results-driven approach.';
    }
    if (has(['retinol', 'retinoid']) && has(['aha', 'bha', 'glycolic', 'salicylic', 'acid'])) {
      return 'Avoid using retinol and strong acids (AHA/BHA) in the same routine — together they over-exfoliate and can damage your barrier. Alternate nights: acids one night, retinol another. Always follow with moisturiser and use SPF every morning.';
    }
    if (has(['order', 'sequence', 'layer', 'step', 'first', 'routine']) &&
        !has(['hair', 'scalp'])) {
      return 'A simple, effective order:\n\nAM: Cleanser → Vitamin C serum → Moisturiser → Sunscreen (always last).\nPM: Cleanser → treatment/active (retinol or an acid) → Moisturiser.\n\nRule of thumb: thinnest to thickest, and water-based before oil-based. Introduce one new active at a time.';
    }

    // Ingredients
    if (has(['niacinamide'])) {
      return 'Niacinamide (Vitamin B3) is a do-it-all: it controls oil, refines pores, fades dark spots and strengthens your skin barrier. 5–10% is plenty, it suits all skin types, and it layers well with almost everything (including Vitamin C — the old "they cancel out" claim is a myth).';
    }
    if (has(['hyaluronic', 'ha ', 'hydration serum'])) {
      return 'Hyaluronic acid is a humectant — it pulls water into the skin for instant plumping. Apply it to damp skin and seal with a moisturiser on top, otherwise in dry climates it can pull moisture out of the skin. Great for every skin type, including oily.';
    }
    if (has(['salicylic', 'bha'])) {
      return 'Salicylic acid (a BHA) is oil-soluble, so it gets inside pores to clear blackheads, whiteheads and acne. Start 2–3x a week at ~2%. It pairs well with niacinamide; avoid stacking it with retinol on the same night.';
    }
    if (has(['glycolic', 'aha', 'lactic', 'exfoliat'])) {
      return 'AHAs (glycolic, lactic) exfoliate the surface to smooth texture and brighten dullness. Use at night 1–3x a week, never with retinol the same night, and SPF the next day is non-negotiable (AHAs increase sun sensitivity).';
    }
    if (has(['vitamin c', 'vit c', 'ascorbic'])) {
      return 'Vitamin C brightens, fades pigmentation and protects against daily damage. Use it in the morning before sunscreen. Introduce gradually if your skin is sensitive, and store it away from light/air so it stays potent.';
    }
    if (has(['retinol', 'retinoid', 'anti-aging', 'anti aging', 'wrinkle', 'fine line'])) {
      return 'Retinol is the gold standard for fine lines, texture and acne — it speeds cell turnover and boosts collagen. Start low (0.2–0.3%) 2 nights a week, apply to dry skin, buffer with moisturiser, and expect some "purging" early on. Daily SPF is essential while using it.';
    }
    if (has(['ceramide', 'barrier'])) {
      return 'Ceramides are lipids that rebuild your skin barrier — ideal if skin feels tight, flaky or stings. Look for a ceramide + cholesterol + fatty-acid moisturiser, and ease off actives for a week or two while the barrier recovers.';
    }
    if (has(['spf', 'sunscreen', 'sun protection', 'uv'])) {
      return 'Sunscreen is the single highest-impact step — it prevents most signs of ageing and pigmentation. Use SPF 30–50 every morning, about two finger-lengths for the face, and reapply if you\'re outdoors. It always goes on last in your AM routine.';
    }

    // Skin concerns
    if (has(['acne', 'pimple', 'breakout', 'spots'])) {
      return 'For acne: cleanse gently (don\'t over-scrub), use salicylic acid or benzoyl peroxide on active spots, add niacinamide to calm and control oil, and never skip a lightweight moisturiser + SPF. Consistency beats intensity — and see a dermatologist for cystic/painful acne.';
    }
    if (has(['oily', 'oil control', 'shiny', 'sebum'])) {
      return 'Oily skin still needs hydration — skipping moisturiser makes skin produce more oil. Use a gel cleanser, niacinamide, a lightweight gel moisturiser, and a matte sunscreen. Salicylic acid 2–3x a week helps keep pores clear.';
    }
    if (has(['dry', 'flaky', 'tight', 'dehydrat'])) {
      return 'Dry skin: swap harsh foaming cleansers for a cream/ceramide cleanser, layer hyaluronic acid on damp skin, and seal with a richer moisturiser. Avoid hot water and over-exfoliating, which strip the barrier and worsen dryness.';
    }
    if (has(['sensitive', 'redness', 'irritat', 'rosacea'])) {
      return 'For sensitive/reactive skin, keep it minimal: a gentle cleanser, a ceramide moisturiser, and mineral SPF. Look for centella (cica), panthenol and niacinamide to calm redness, and patch-test any new active for a few days first.';
    }
    if (has(['pigment', 'dark spot', 'melasma', 'uneven', 'tan'])) {
      return 'To fade pigmentation: daily SPF is the foundation (without it nothing else works), plus brightening actives like Vitamin C, alpha arbutin, niacinamide or azelaic acid. It\'s gradual — expect 6–12 weeks of consistent use.';
    }
    if (has(['pore', 'blackhead', 'whitehead'])) {
      return 'You can\'t shrink pores permanently, but you can make them look smaller: salicylic acid to keep them clear, niacinamide to refine, retinol for long-term texture, and SPF to prevent sun-related enlargement. Avoid harsh squeezing.';
    }

    // Hair
    if (has(['hair fall', 'hair loss', 'shedding', 'thinning'])) {
      return 'Some shedding (50–100 hairs/day) is normal. To reduce excess fall: be gentle when wet, use a mild sulphate-free shampoo, massage the scalp, and consider actives like redensyl or rosemary oil. Sudden or patchy loss is worth a dermatologist/trichologist visit.';
    }
    if (has(['dandruff', 'flaky scalp', 'itchy scalp'])) {
      return 'Dandruff is usually a yeast imbalance, not just dryness. Use an anti-dandruff shampoo (zinc pyrithione or ketoconazole) 2–3x a week, leave it on a couple of minutes before rinsing, and don\'t over-oil the scalp, which can feed the yeast.';
    }
    if (has(['frizz', 'frizzy'])) {
      return 'Frizz is dehydrated hair grabbing moisture from the air. Use a hydrating conditioner, apply a lightweight serum to damp hair, avoid rough towel-drying, and protect with heat protectant before styling.';
    }
    if (has(['hair growth', 'grow hair', 'longer hair'])) {
      return 'Hair grows ~1cm/month and you can\'t rush biology — but you can stop breakage that makes it look stalled: scalp massage, gentle handling, regular trims, enough protein/iron in your diet, and consistency with a growth serum if you use one.';
    }
    if (has(['oily scalp', 'greasy hair'])) {
      return 'For an oily scalp, wash a bit more often with a gentle clarifying shampoo focused on the roots, condition only the lengths, and avoid heavy oils on the scalp. Over-washing can rebound into more oil, so find your balance.';
    }

    // Meta
    if (has(['how often', 'how many times', 'frequency'])) {
      return 'General rule: cleanse + moisturise + SPF daily; exfoliating acids 1–3x a week; retinol 2–4 nights a week once your skin is used to it. Introduce one new active at a time and give it 4–6 weeks before judging results.';
    }
    if (has(['purg', 'breaking out', 'worse'])) {
      return 'Purging (a brief breakout when starting retinoids or acids) usually settles in 4–6 weeks as cell turnover speeds up. If irritation is severe or it\'s in new areas unrelated to the active, ease off and rebuild your barrier first.';
    }
    if (has(['pregnan', 'breastfeed'])) {
      return 'During pregnancy, most dermatologists advise avoiding retinoids and high-dose salicylic acid. Generally considered safe: hyaluronic acid, niacinamide, vitamin C, azelaic acid and mineral SPF — but always confirm with your doctor.';
    }
    if (has(['hi', 'hello', 'hey', 'help', 'start'])) {
      return 'Hi! I\'m your DermIQ assistant. Ask me about ingredients (retinol, niacinamide, Vitamin C…), concerns (acne, dryness, pigmentation, hair fall…), or how to order your routine. What would you like help with?';
    }

    return 'Good question! Based on your skin profile, I\'d build a gentle base routine — cleanser, moisturiser and daily SPF — then add one active at a time for your main concern. Tell me your skin type or the concern you\'re tackling (acne, dryness, pigmentation, pores, hair fall…) and I\'ll get specific.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.dColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.gradientPrimary,
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('DermIQ AI'),
                Text(
                  'Skincare Assistant',
                  style: AppTypography.caption
                      .copyWith(color: context.dColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Medical-advice disclaimer.
          Container(
            width: double.infinity,
            color: AppColors.primary.withValues(alpha: 0.06),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 14, color: context.dColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'AI guidance is educational, not medical advice. '
                    'For persistent or severe concerns, see a dermatologist.',
                    style: AppTypography.caption
                        .copyWith(color: context.dColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),

          // Suggested questions
          if (_messages.length <= 1) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Try asking:', style: AppTypography.caption),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Can I use Vitamin C and Retinol?',
                      'Why is my skin dry?',
                      'What is Niacinamide?',
                      'Best routine for oily skin?',
                    ]
                        .map((q) => GestureDetector(
                              onTap: () {
                                _controller.text = q;
                                _sendMessage();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color:
                                          AppColors.primary.withValues(alpha: 0.2)),
                                ),
                                child: Text(q,
                                    style: AppTypography.caption.copyWith(
                                        color: AppColors.primary)),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppConstants.sp16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (_, i) {
                if (_isTyping && i == _messages.length) {
                  return const _TypingIndicator();
                }
                return _MessageBubble(message: _messages[i]);
              },
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: context.dColors.surface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Ask about skincare...',
                        filled: true,
                        fillColor: context.dColors.background,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                              color: AppColors.primary, width: 1.5),
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                      maxLines: null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.gradientPrimary,
                      ),
                      child: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isAI;
  final DateTime timestamp;
  const _Message({required this.text, required this.isAI, required this.timestamp});
}

class _MessageBubble extends StatelessWidget {
  final _Message message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            message.isAI ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (message.isAI) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.gradientPrimary,
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 14),
            ),
          ],
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: message.isAI ? null : AppColors.gradientPrimary,
                color: message.isAI ? context.dColors.surface : null,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(message.isAI ? 4 : 20),
                  bottomRight: Radius.circular(message.isAI ? 20 : 4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: AppTypography.bodyMedium.copyWith(
                  color: message.isAI ? context.dColors.textPrimary : Colors.white,
                ),
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.gradientPrimary,
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Colors.white, size: 14),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: context.dColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, _) => Row(
                children: List.generate(
                  3,
                  (i) => AnimatedOpacity(
                    opacity: (_controller.value - i * 0.15).clamp(0.2, 1.0),
                    duration: Duration.zero,
                    child: Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
