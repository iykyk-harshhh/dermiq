import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/dermiq_colors.dart';
import '../../../../core/constants/app_constants.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
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

    // Simulate AI response
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _messages.add(_Message(
        text: _getAIResponse(text),
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

  String _getAIResponse(String question) {
    final q = question.toLowerCase();
    if (q.contains('vitamin c') && q.contains('retinol')) {
      return 'Great question! Vitamin C and Retinol can actually cancel each other out when used together. Vitamin C works best at a low pH, while Retinol needs a higher pH. Use Vitamin C in the morning and Retinol at night for the best results.';
    }
    if (q.contains('dry')) {
      return 'Dry skin can be caused by several factors: lack of moisturization, harsh cleansers stripping the skin barrier, dehydration, or environmental factors. I\'d recommend switching to a ceramide-based cleanser and adding hyaluronic acid to your routine.';
    }
    if (q.contains('niacinamide')) {
      return 'Niacinamide (Vitamin B3) is a powerhouse ingredient! It reduces pore appearance, controls oil, fades dark spots, and strengthens your skin barrier. It\'s well-tolerated and works with most other ingredients.';
    }
    return 'That\'s a great skincare question! Based on your skin profile, I\'d suggest starting with a gentle routine and slowly introducing active ingredients. Would you like me to analyze a specific concern or ingredient in more detail?';
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
