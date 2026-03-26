import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/profile_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/meal_provider.dart';
import '../../models/meal_entry.dart';
import '../../utils/diet_logic.dart';
import '../../widgets/weekly_calorie_chart.dart';
import '../../widgets/glow_icon.dart';

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

class _DietTabState extends ConsumerState<DietTab>
    with SingleTickerProviderStateMixin {
  // ── Tab controller ─────────────────────────────────────────────────────────
  late TabController _tabCtrl;

  // ── Chat state ─────────────────────────────────────────────────────────────
  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text:
          "Hey! I'm your Nutrition Planning Agent. Ask for a full meal plan, grocery list, recipes, or tell me what ingredients you have — I'll give you a personalised, goal-based nutrition response!",
      isUser: false,
    ),
  ];
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
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
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
        // ── Sub-tab bar ────────────────────────────────────────────────────
        Container(
          color: AppColors.surface,
          child: TabBar(
            controller: _tabCtrl,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.muted,
            labelStyle: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600),
            tabs: const [
              Tab(icon: Icon(Icons.chat_bubble_outline_rounded, size: 16),
                  text: 'AI Chat'),
              Tab(icon: Icon(Icons.add_circle_outline_rounded, size: 16),
                  text: 'Log Meal'),
            ],
          ),
        ),

        // ── Tab views ──────────────────────────────────────────────────────
        Expanded(
          child: TabBarView(
            controller: _tabCtrl,
            children: [
              // ── Chat tab (existing layout preserved) ─────────────────────
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: TextField(
                      controller: _allergyCtrl,
                      style: const TextStyle(
                          color: AppColors.text, fontSize: 13),
                      decoration: const InputDecoration(
                        hintText:
                            'Allergies / dietary restrictions (optional)',
                        prefixIcon: Icon(Icons.no_meals_outlined,
                            size: 16, color: AppColors.muted),
                        isDense: true,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
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
                  Expanded(
                    child: _messages.isEmpty
                        ? const Center(
                            child: Text('Ask me anything about nutrition!',
                                style:
                                    TextStyle(color: AppColors.muted)))
                        : ListView.builder(
                            controller: _scrollCtrl,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12),
                            itemCount:
                                _messages.length + (_typing ? 1 : 0),
                            itemBuilder: (context, i) {
                              if (_typing && i == _messages.length) {
                                return const _TypingBubble();
                              }
                              return _MessageBubble(
                                  message: _messages[i]);
                            },
                          ),
                  ),
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
                          icon: const Icon(Icons.send,
                              color: AppColors.primary),
                          onPressed: () => _send(_inputCtrl.text),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ── Meal log tab ──────────────────────────────────────────────
              const _MealLogTab(),
            ],
          ),
        ),

        // ── Weekly chart — visible on both tabs ────────────────────────────
        const Padding(
          padding: EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: WeeklyCalorieChart(),
        ),
      ],
    );
  }
}

// ── Meal log tab ──────────────────────────────────────────────────────────────

class _MealLogTab extends ConsumerStatefulWidget {
  const _MealLogTab();

  @override
  ConsumerState<_MealLogTab> createState() => _MealLogTabState();
}

class _MealLogTabState extends ConsumerState<_MealLogTab> {
  final _nameCtrl = TextEditingController();
  final _calsCtrl = TextEditingController();
  String _mealType = 'breakfast';

  static const _types = {
    'breakfast': 'Breakfast',
    'lunch': 'Lunch',
    'dinner': 'Dinner',
    'snack': 'Snack',
  };

  static const _typeIcons = {
    'breakfast': Icons.free_breakfast_rounded,
    'lunch': Icons.lunch_dining_rounded,
    'dinner': Icons.dinner_dining_rounded,
    'snack': Icons.cookie_outlined,
  };

  static const _typeColors = {
    'breakfast': Color(0xFFFFB74D),
    'lunch': Color(0xFF81C784),
    'dinner': Color(0xFFA78BFA),
    'snack': Color(0xFF64B5F6),
  };

  @override
  void dispose() {
    _nameCtrl.dispose();
    _calsCtrl.dispose();
    super.dispose();
  }

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void _log() {
    final name = _nameCtrl.text.trim();
    final cals = int.tryParse(_calsCtrl.text.trim());
    if (name.isEmpty || cals == null || cals <= 0) return;
    ref.read(mealProvider.notifier).addMeal(
          name: name,
          calories: cals,
          type: _mealType,
        );
    _nameCtrl.clear();
    _calsCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final meals = ref.watch(mealProvider);
    final today = _todayStr();
    final todayMeals = meals.where((m) => m.date == today).toList()
      ..sort((a, b) => b.id.compareTo(a.id)); // newest first
    final totalToday =
        todayMeals.fold(0, (s, m) => s + m.calories);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Log form ─────────────────────────────────────────────────────
          Card(
            color: AppColors.card,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const GlowIcon.diet(size: 28),
                      const SizedBox(width: 10),
                      const Text('Log a Meal',
                          style: TextStyle(
                              color: AppColors.text,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Meal name
                  TextField(
                    controller: _nameCtrl,
                    style: const TextStyle(
                        color: AppColors.text, fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Meal name (e.g. Oatmeal with berries)',
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Calories input
                      Expanded(
                        child: TextField(
                          controller: _calsCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                              color: AppColors.text, fontSize: 13),
                          decoration: const InputDecoration(
                            hintText: 'Calories (kcal)',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Meal type dropdown
                      DropdownButton<String>(
                        value: _mealType,
                        dropdownColor: AppColors.card2,
                        underline: const SizedBox(),
                        style: const TextStyle(
                            color: AppColors.text, fontSize: 13),
                        onChanged: (v) {
                          if (v != null) setState(() => _mealType = v);
                        },
                        items: _types.entries
                            .map((e) => DropdownMenuItem(
                                  value: e.key,
                                  child: Text(e.value),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _log,
                      child: const Text('Log Meal'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Today's meals ────────────────────────────────────────────────
          if (todayMeals.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Today's Meals",
                    style: TextStyle(
                        color: AppColors.text,
                        fontSize: 14,
                        fontWeight: FontWeight.w700)),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDim.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$totalToday kcal',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...todayMeals.map((m) => _MealTile(
                  meal: m,
                  typeIcon: _typeIcons[m.type] ?? Icons.restaurant_rounded,
                  typeColor: _typeColors[m.type] ?? AppColors.primary,
                  onDelete: () =>
                      ref.read(mealProvider.notifier).deleteMeal(m.id),
                )),
          ] else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.restaurant_outlined,
                        color: AppColors.border, size: 36),
                    const SizedBox(height: 8),
                    const Text('No meals logged today',
                        style: TextStyle(
                            color: AppColors.muted, fontSize: 12)),
                    const SizedBox(height: 4),
                    const Text(
                      'Use the form above to start tracking your calories.',
                      style: TextStyle(
                          color: AppColors.muted2, fontSize: 10),
                      textAlign: TextAlign.center,
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

class _MealTile extends StatelessWidget {
  final MealEntry meal;
  final IconData typeIcon;
  final Color typeColor;
  final VoidCallback onDelete;

  const _MealTile({
    required this.meal,
    required this.typeIcon,
    required this.typeColor,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: typeColor.withValues(alpha: 0.14),
              border: Border.all(
                  color: typeColor.withValues(alpha: 0.30), width: 1),
            ),
            child: Icon(typeIcon, size: 16, color: typeColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meal.name,
                    style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                Text(meal.type[0].toUpperCase() + meal.type.substring(1),
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 11)),
              ],
            ),
          ),
          Text('${meal.calories} kcal',
              style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700)),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.close_rounded,
                size: 15, color: AppColors.muted),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints:
                const BoxConstraints(minWidth: 28, minHeight: 28),
          ),
        ],
      ),
    );
  }
}

// ── Chat bubble widgets ───────────────────────────────────────────────────────

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
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78),
        decoration: BoxDecoration(
          color: message.isUser
              ? AppColors.primaryDim
              : AppColors.card2,
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
            _Dot(),
            SizedBox(width: 4),
            _Dot(),
            SizedBox(width: 4),
            _Dot(),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

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
