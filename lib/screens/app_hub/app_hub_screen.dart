import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import 'weather_tab.dart';
import 'workout_tab.dart';
import 'diet_tab.dart';
import 'water_tab.dart';
import 'profile_tab.dart';

class AppHubScreen extends StatelessWidget {
  final String activeTab;

  const AppHubScreen({super.key, required this.activeTab});

  int get _tabIndex {
    switch (activeTab) {
      case 'weather':  return 0;
      case 'workout':  return 1;
      case 'diet':     return 2;
      case 'water':    return 3;
      case 'profile':  return 4;
      default:         return 0;
    }
  }

  void _onTap(BuildContext context, int index) {
    const routes = ['/app/weather', '/app/workout', '/app/diet', '/app/water', '/app/profile'];
    context.go(routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    final bodies = [
      const WeatherTab(),
      const WorkoutTab(),
      const DietTab(),
      const WaterTab(),
      const ProfileTab(),
    ];

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(
          _tabLabel(activeTab),
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: bodies[_tabIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => _onTap(context, i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.wb_sunny_outlined), label: 'Weather'),
          NavigationDestination(
              icon: Icon(Icons.fitness_center), label: 'Workouts'),
          NavigationDestination(
              icon: Icon(Icons.restaurant_menu), label: 'Diet'),
          NavigationDestination(
              icon: Icon(Icons.water_drop_outlined), label: 'Water'),
          NavigationDestination(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }

  String _tabLabel(String tab) {
    switch (tab) {
      case 'weather': return 'Weather';
      case 'workout': return 'Workout Planner';
      case 'diet':    return 'Diet AI';
      case 'water':   return 'Water Tracker';
      case 'profile': return 'My Profile';
      default:        return 'FitPilot';
    }
  }
}
