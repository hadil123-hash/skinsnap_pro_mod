import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../services/ai_beauty_assistant_service.dart';
import '../services/sound_service.dart';
import '../utils/constants.dart';
import '../widgets/app_logo_badge.dart';
import '../widgets/beauty_ui.dart';

class BeautyAssistantScreen extends StatefulWidget {
  const BeautyAssistantScreen({super.key});

  @override
  State<BeautyAssistantScreen> createState() => _BeautyAssistantScreenState();
}

class _BeautyAssistantScreenState extends State<BeautyAssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AiBeautyAssistantService _assistant = AiBeautyAssistantService();
  final List<_AssistantMessage> _messages = [];

  bool _sending = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final app = context.read<AppProvider>();
    _messages.add(
      _AssistantMessage(
        text: _welcome(app.locale.languageCode),
        isUser: false,
      ),
    );
    _initialized = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send(AppProvider app, [String? preset]) async {
    final text = (preset ?? _controller.text).trim();
    if (text.isEmpty || _sending) {
      await SoundService().feedbackError();
      return;
    }

    setState(() {
      _messages.add(_AssistantMessage(text: text, isUser: true));
      _controller.clear();
      _sending = true;
    });
    _scrollDown();

    final history = _messages
        .map((m) => {
              'role': m.isUser ? 'user' : 'assistant',
              'text': m.text,
            })
        .toList();

    final answer = await _assistant.answer(
      message: text,
      languageCode: app.locale.languageCode,
      history: history,
    );

    if (!mounted) return;
    await SoundService().feedbackSuccess();

    setState(() {
      _messages.add(_AssistantMessage(text: answer, isUser: false));
      _sending = false;
    });
    _scrollDown();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  String _welcome(String lang) {
    return switch (lang) {
      'en' => 'Hello! I am your SkinSnap assistant. Ask me anything: skincare, makeup, ingredients, routine, product scans, or even general questions.',
      'ar' => 'مرحبا! أنا مساعد SkinSnap. اسأليني ما تشائين: العناية بالبشرة، المكياج، المكوّنات، الروتين، فحص المنتجات أو حتى الأسئلة العامة.',
      _ => 'Bonjour ! Je suis votre assistant SkinSnap. Posez-moi n’importe quelle question : skincare, makeup, ingrédients, routine, scan produit, ou même une question générale.',
    };
  }

  List<String> _quickQuestions(String lang) {
    return switch (lang) {
      'en' => const [
          'I have oily skin. What routine should I follow?',
          'Can you explain my scanned product simply?',
          'What makeup look suits a natural style?',
        ],
      'ar' => const [
          'عندي بشرة دهنية، ما الروتين المناسب؟',
          'هل يمكنك شرح المنتج الذي قمت بفحصه ببساطة؟',
          'ما المكياج المناسب لستايل طبيعي؟',
        ],
      _ => const [
          'J’ai une peau grasse, quelle routine suivre ?',
          'Peux-tu expliquer simplement mon produit scanné ?',
          'Quel makeup pour un style naturel ?',
        ],
    };
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final quickQuestions = _quickQuestions(app.locale.languageCode);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BeautyGradientBackground(
        child: SafeArea(
          child: AnimatedPadding(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.only(bottom: bottomInset > 0 ? 6 : 0),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      BeautyCircleIcon(
                        icon: Icons.arrow_back_ios_new_rounded,
                        size: 44,
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          app.tr('assistant_title'),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  BeautyCard(
                    padding: const EdgeInsets.all(16),
                    color: AppColors.hotPink,
                    child: Row(
                      children: [
                        const AppLogoBadge(size: 60),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                app.tr('hello'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                app.tr('assistant_intro'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  height: 1.35,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: quickQuestions.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final question = quickQuestions[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(999),
                          onTap: () => _send(app, question),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.hotPink.withValues(alpha: .16)),
                            ),
                            child: Text(
                              question,
                              style: const TextStyle(
                                color: AppColors.hotPink,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(top: 4, bottom: 8),
                      itemCount: _messages.length + (_sending ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (_sending && index == _messages.length) {
                          return const _TypingBubble();
                        }
                        return _MessageBubble(message: _messages[index]);
                      },
                    ),
                  ),
                  _InputBar(
                    controller: _controller,
                    sending: _sending,
                    hint: app.tr('write_question'),
                    onSend: () => _send(app),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.sending,
    required this.hint,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sending;
  final String hint;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 54, maxHeight: 84),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 2,
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                hintText: hint,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: sending ? null : onSend,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: sending ? null : AppColors.beautyGradient,
                color: sending ? AppColors.hotPink.withValues(alpha: .35) : null,
                shape: BoxShape.circle,
              ),
              child: sending
                  ? const Padding(
                      padding: EdgeInsets.all(11),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _AssistantMessage message;

  @override
  Widget build(BuildContext context) {
    final align = message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = message.isUser ? AppColors.hotPink : Colors.white;
    final textColor = message.isUser ? Colors.white : Colors.black87;
    return Column(
      crossAxisAlignment: align,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .78),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(message.isUser ? 18 : 6),
              bottomRight: Radius.circular(message.isUser ? 6 : 18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Text(
            message.text,
            style: TextStyle(color: textColor, height: 1.45, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            _TypingDot(),
            SizedBox(width: 6),
            _TypingDot(delay: 150),
            SizedBox(width: 6),
            _TypingDot(delay: 300),
          ],
        ),
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  const _TypingDot({this.delay = 0});
  final int delay;

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: .25, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.hotPink,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _AssistantMessage {
  const _AssistantMessage({required this.text, required this.isUser});
  final String text;
  final bool isUser;
}
