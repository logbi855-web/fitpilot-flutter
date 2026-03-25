import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/settings_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/workout_provider.dart';
import '../../providers/water_provider.dart';
import '../../providers/progress_provider.dart';
import '../../core/storage/storage_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _apiKeyCtrl;
  bool _apiKeyObscured = true;

  @override
  void initState() {
    super.initState();
    _apiKeyCtrl = TextEditingController(
        text: ref.read(settingsProvider).claudeApiKey);
  }

  @override
  void dispose() {
    _apiKeyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Settings',
            style: TextStyle(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader('Preferences'),

          // Language
          _DropdownTile<String>(
            label: 'Language',
            value: settings.language,
            items: const {
              'en': 'English',
              'af': 'Afrikaans',
              'fr': 'French',
              'zu': 'Zulu',
            },
            onChanged: (v) => notifier.update(language: v),
          ),

          // AI Personality
          _DropdownTile<String>(
            label: 'AI Personality',
            value: settings.personality,
            items: const {
              'friendly': 'Friendly',
              'hard': 'Hard Coach',
              'calm': 'Calm',
            },
            onChanged: (v) => notifier.update(personality: v),
          ),

          // Water Goal
          _DropdownTile<int>(
            label: 'Daily Water Goal',
            value: settings.waterGoal,
            items: const {
              1500: '1500 ml',
              2000: '2000 ml',
              2500: '2500 ml',
              3000: '3000 ml',
              3500: '3500 ml',
            },
            onChanged: (v) => notifier.update(waterGoal: v),
          ),

          const Divider(color: AppColors.border, height: 32),
          _SectionHeader('Toggles'),

          SwitchListTile(
            title: const Text('Rest Day Reminders',
                style: TextStyle(color: AppColors.text)),
            value: settings.restDay,
            activeColor: AppColors.primary,
            onChanged: (v) => notifier.update(restDay: v),
          ),
          SwitchListTile(
            title: const Text('Weather Workout Influence',
                style: TextStyle(color: AppColors.text)),
            value: settings.weatherWorkout,
            activeColor: AppColors.primary,
            onChanged: (v) => notifier.update(weatherWorkout: v),
          ),
          SwitchListTile(
            title: const Text('Show Progress Bars',
                style: TextStyle(color: AppColors.text)),
            value: settings.progress,
            activeColor: AppColors.primary,
            onChanged: (v) => notifier.update(progress: v),
          ),

          const Divider(color: AppColors.border, height: 32),
          _SectionHeader('AI Coach'),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextField(
              controller: _apiKeyCtrl,
              obscureText: _apiKeyObscured,
              style: const TextStyle(color: AppColors.text, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Claude API Key',
                hintText: 'sk-ant-...',
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        _apiKeyObscured
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: AppColors.muted,
                        size: 18,
                      ),
                      onPressed: () =>
                          setState(() => _apiKeyObscured = !_apiKeyObscured),
                    ),
                    IconButton(
                      icon: const Icon(Icons.save_outlined,
                          color: AppColors.primary, size: 18),
                      onPressed: () {
                        notifier.update(claudeApiKey: _apiKeyCtrl.text.trim());
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('API key saved')),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(color: AppColors.border, height: 32),
          _SectionHeader('Data'),

          ListTile(
            title: const Text('Clear Cache',
                style: TextStyle(color: AppColors.text)),
            trailing: const Icon(Icons.delete_outline, color: AppColors.muted),
            onTap: () => _confirmAction(
              context,
              'Clear Cache?',
              'This will clear energy level and location data.',
              () async {
                await StorageService.remove(StorageKeys.energy);
                await StorageService.remove(StorageKeys.location);
              },
            ),
          ),
          ListTile(
            title: const Text('Reset Saved Plans',
                style: TextStyle(color: AppColors.text)),
            trailing:
                const Icon(Icons.fitness_center, color: AppColors.muted),
            onTap: () => _confirmAction(
              context,
              'Reset Plans?',
              'All saved workout plans will be deleted.',
              () => ref.read(workoutProvider.notifier).resetPlans(),
            ),
          ),
          ListTile(
            title: const Text('Full Reset',
                style: TextStyle(color: AppColors.error)),
            trailing: const Icon(Icons.warning_outlined, color: AppColors.error),
            onTap: () => _confirmAction(
              context,
              'Full Reset?',
              'All data (profile, plans, water, progress, streak) will be permanently deleted.',
              () async {
                await ref.read(profileProvider.notifier).reset();
                await ref.read(workoutProvider.notifier).resetPlans();
                await ref.read(waterProvider.notifier).reset();
                await ref.read(progressProvider.notifier).reset();
                await StorageService.clear();
              },
              destructive: true,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAction(
    BuildContext context,
    String title,
    String message,
    Future<void> Function() action, {
    bool destructive = false,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(title,
            style: const TextStyle(color: AppColors.text)),
        content: Text(message,
            style: const TextStyle(color: AppColors.muted, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: destructive
                ? ElevatedButton.styleFrom(backgroundColor: AppColors.error)
                : null,
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirmed == true) await action();
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text.toUpperCase(),
          style: const TextStyle(
              color: AppColors.muted,
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700)),
    );
  }
}

class _DropdownTile<T> extends StatelessWidget {
  final String label;
  final T value;
  final Map<T, String> items;
  final ValueChanged<T?> onChanged;

  const _DropdownTile({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(color: AppColors.text)),
      trailing: DropdownButton<T>(
        value: value,
        dropdownColor: AppColors.card2,
        underline: const SizedBox(),
        style: const TextStyle(color: AppColors.text),
        onChanged: onChanged,
        items: items.entries
            .map((e) => DropdownMenuItem<T>(
                  value: e.key,
                  child: Text(e.value),
                ))
            .toList(),
      ),
    );
  }
}
