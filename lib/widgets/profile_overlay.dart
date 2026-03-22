import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_theme.dart';
import '../providers/profile_provider.dart';

/// Slide-up profile overlay — shown via showModalBottomSheet.
class ProfileOverlay extends ConsumerWidget {
  const ProfileOverlay({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const ProfileOverlay(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.border2,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.primaryDim,
            backgroundImage: profile.photoPath != null
                ? AssetImage(profile.photoPath!) as ImageProvider
                : null,
            child: profile.photoPath == null
                ? Text(
                    profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            profile.name,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (profile.goal != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Goal: ${profile.goal}',
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
            ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.person_outline, color: AppColors.primary),
            title: const Text('Edit Profile', style: TextStyle(color: AppColors.text)),
            onTap: () {
              Navigator.pop(context);
              context.go('/app/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: AppColors.primary),
            title: const Text('Settings', style: TextStyle(color: AppColors.text)),
            onTap: () {
              Navigator.pop(context);
              context.go('/settings');
            },
          ),
        ],
      ),
    );
  }
}
