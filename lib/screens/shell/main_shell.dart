import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/tab_provider.dart';
import '../../widgets/glow_icon.dart';
import '../overview/overview_screen.dart';
import '../app_hub/workout_tab.dart';
import '../app_hub/diet_tab.dart';
import '../app_hub/water_tab.dart';
import '../app_hub/profile_tab.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  // Fixed list — IndexedStack keeps state alive across tab switches.
  static const List<Widget> _tabs = [
    OverviewScreen(),
    WorkoutTab(),
    DietTab(),
    WaterTab(),
    ProfileTab(),
  ];

  static const _titles = [
    'FitPilot',
    'Workout Planner',
    'Diet AI',
    'Water Tracker',
    'My Profile',
  ];

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: GlowIcon.home(size: 26),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.fitness_center_outlined),
      selectedIcon: GlowIcon.workout(size: 26),
      label: 'Workout',
    ),
    NavigationDestination(
      icon: Icon(Icons.restaurant_menu_outlined),
      selectedIcon: GlowIcon.diet(size: 26),
      label: 'Diet',
    ),
    NavigationDestination(
      icon: Icon(Icons.water_drop_outlined),
      selectedIcon: GlowIcon.water(size: 26),
      label: 'Water',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: GlowIcon.profile(size: 26),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedTabProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          _titles[selectedIndex],
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: _tabs,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        animationDuration: const Duration(milliseconds: 300),
        onDestinationSelected: (i) =>
            ref.read(selectedTabProvider.notifier).state = i,
        destinations: _destinations,
      ),
    );
  }
}
