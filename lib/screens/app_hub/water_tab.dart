import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/water_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/water_ring.dart';

({String icon, String message, Color color}) _waterPrompt(
    int totalMl, int goalMl) {
  final pct = goalMl > 0 ? (totalMl / goalMl * 100).round() : 0;
  if (pct == 0) {
    return (
      icon: 'Start hydrating!',
      message: 'Log your first glass to begin tracking.',
      color: AppColors.muted
    );
  } else if (pct < 25) {
    return (
      icon: 'Only $totalMl ml so far.',
      message: 'Drink a glass right now — your body needs it.',
      color: AppColors.error
    );
  } else if (pct < 50) {
    return (
      icon: '$pct% done.',
      message: 'Halfway to your goal. Keep sipping!',
      color: AppColors.error
    );
  } else if (pct < 75) {
    return (
      icon: 'Good progress — $totalMl ml logged.',
      message: '${goalMl - totalMl} ml left to reach your goal.',
      color: AppColors.blue
    );
  } else if (pct < 100) {
    return (
      icon: 'Almost there!',
      message: 'Only ${goalMl - totalMl} ml to go. You\'re crushing it today!',
      color: AppColors.blue
    );
  } else {
    return (
      icon: 'Goal reached!',
      message: '$totalMl ml consumed today. Excellent hydration!',
      color: AppColors.primary
    );
  }
}

class WaterTab extends ConsumerStatefulWidget {
  const WaterTab({super.key});

  @override
  ConsumerState<WaterTab> createState() => _WaterTabState();
}

class _WaterTabState extends ConsumerState<WaterTab> {
  final TextEditingController _customCtrl = TextEditingController();

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final water = ref.watch(waterProvider);
    final settings = ref.watch(settingsProvider);
    final goal = settings.waterGoal;
    final pct = goal > 0 ? (water.totalMl / goal).clamp(0.0, 1.0) : 0.0;
    final goalReached = water.totalMl >= goal;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Ring
          Center(child: WaterRing(totalMl: water.totalMl, goalMl: goal)),
          const SizedBox(height: 12),
          // Motivational prompt
          Builder(builder: (_) {
            final p = _waterPrompt(water.totalMl, goal);
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: p.color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: p.color.withValues(alpha: 0.25)),
              ),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 12),
                  children: [
                    TextSpan(
                        text: '${p.icon} ',
                        style: TextStyle(
                            color: p.color, fontWeight: FontWeight.w700)),
                    TextSpan(
                        text: p.message,
                        style: const TextStyle(color: AppColors.muted)),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (ctx, constraints) => Stack(
              children: [
                Container(
                  height: 6,
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                if (pct > 0)
                  Container(
                    height: 6,
                    width: constraints.maxWidth * pct,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4DD0E1), Color(0xFF818CF8), Color(0xFFA78BFA)],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text('Goal: $goal ml',
              style: const TextStyle(color: AppColors.muted, fontSize: 12)),

          if (goalReached) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryDim.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary),
              ),
              child: const Text('Daily goal reached!',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
            ),
          ],

          const SizedBox(height: 20),

          // Quick-add buttons
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              (ml: 150, icon: Icons.local_cafe_outlined),
              (ml: 250, icon: Icons.local_drink_outlined),
              (ml: 330, icon: Icons.sports_bar_outlined),
              (ml: 500, icon: Icons.water_drop_outlined),
            ].map((item) {
              return InkWell(
                onTap: () => ref.read(waterProvider.notifier).addWater(item.ml),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                    ),
                    border: Border.all(
                      color: const Color(0xFF4DD0E1).withValues(alpha: 0.3),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x224DD0E1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.icon, size: 16, color: const Color(0xFF4DD0E1)),
                      const SizedBox(width: 6),
                      Text(
                        '+${item.ml} ml',
                        style: const TextStyle(
                          color: Color(0xFF4DD0E1),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Custom amount
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _customCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: AppColors.text),
                  decoration: const InputDecoration(
                    hintText: 'Custom ml',
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  final ml = int.tryParse(_customCtrl.text.trim());
                  if (ml != null && ml > 0) {
                    ref.read(waterProvider.notifier).addWater(ml);
                    _customCtrl.clear();
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Log list
          if (water.log.isNotEmpty) ...[
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Today\'s Log',
                  style: TextStyle(
                      color: AppColors.text,
                      fontSize: 14,
                      fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 8),
            ...water.log.asMap().entries.map((entry) {
              final i = entry.key;
              final log = entry.value;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.water_drop, color: AppColors.primary, size: 18),
                title: Text('${log.ml} ml',
                    style: const TextStyle(color: AppColors.text, fontSize: 13)),
                subtitle: Text(log.time,
                    style: const TextStyle(color: AppColors.muted, fontSize: 11)),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 16, color: AppColors.muted),
                  onPressed: () =>
                      ref.read(waterProvider.notifier).removeEntry(i),
                ),
              );
            }),
          ],

          const SizedBox(height: 8),
          TextButton(
            onPressed: () => ref.read(waterProvider.notifier).reset(),
            child: const Text('Reset Today',
                style: TextStyle(color: AppColors.muted)),
          ),
        ],
      ),
    );
  }
}
