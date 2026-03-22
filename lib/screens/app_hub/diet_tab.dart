import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/profile_provider.dart';
import '../../providers/settings_provider.dart';
import '../../utils/diet_logic.dart';

class _ChatMessage {
  final String text;
  final bool isUser;
  const _ChatMessage({required this.text, required this.isUser});
}

class DietTab extends ConsumerStatefulWidget {
  const DietTab({super.key});

  @override
  ConsumerState<DietTab> createState() => _DietTabState();
}

class _DietTabState extends ConsumerState<DietTab> {
  final List<_ChatMessage> _messages = [];
  final TextEditingController _inputCtrl = TextEditingController();
  final TextEditingController _allergyCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _typing = false;

  static const _quickChips = [
    'Grocery list',
    'Meal plan',
    'Recipe ideas',
    'Calorie guide',
    'Supplements',
    'Nutrition tips',
  ];

  @override
  void dispose() {
    _inputCtrl.dispose();
    _allergyCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send(String text) {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _typing = true;
      _inputCtrl.clear();
    });
    _scrollToBottom();

    // Simulate short "typing" delay then respond
    Future.delayed(const Duration(milliseconds: 600), () {
      final profile = ref.read(profileProvider);
      final settings = ref.read(settingsProvider);
      final response = DietLogic.respond(
        input: text,
        goal: profile.goal ?? 'maintain',
        personality: settings.personality,
        allergies: _allergyCtrl.text.trim().isNotEmpty
            ? _allergyCtrl.text.trim()
            : null,
      );
      if (mounted) {
        setState(() {
          _typing = false;
          _messages.add(_ChatMessage(text: response, isUser: false));
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Allergy filter
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: TextField(
            controller: _allergyCtrl,
            style: const TextStyle(color: AppColors.text, fontSize: 13),
            decoration: const InputDecoration(
              hintText: 'Allergies / dietary restrictions (optional)',
              prefixIcon: Icon(Icons.no_meals_outlined,
                  size: 16, color: AppColors.muted),
              isDense: true,
            ),
          ),
        ),

        // Quick chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Wrap(
            spacing: 8,
            children: _quickChips
                .map((c) => ActionChip(
                      label: Text(c),
                      onPressed: () => _send(c),
                    ))
                .toList(),
          ),
        ),

        // Messages
        Expanded(
          child: _messages.isEmpty
              ? const Center(
                  child: Text('Ask me anything about nutrition!',
                      style: TextStyle(color: AppColors.muted)))
              : ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _messages.length + (_typing ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (_typing && i == _messages.length) {
                      return const _TypingBubble();
                    }
                    final msg = _messages[i];
                    return _MessageBubble(message: msg);
                  },
                ),
        ),

        // Input bar
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputCtrl,
                  style: const TextStyle(color: AppColors.text),
                  decoration: const InputDecoration(
                    hintText: 'Ask about nutrition...',
                    isDense: true,
                  ),
                  onSubmitted: _send,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: AppColors.primary),
                onPressed: () => _send(_inputCtrl.text),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: message.isUser ? AppColors.primaryDim : AppColors.card2,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          message.text,
          style: const TextStyle(color: AppColors.text, fontSize: 13),
        ),
      ),
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
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card2,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(delay: 0),
            SizedBox(width: 4),
            _Dot(delay: 200),
            SizedBox(width: 4),
            _Dot(delay: 400),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: const BoxDecoration(
          color: AppColors.muted, shape: BoxShape.circle),
    );
  }
}
