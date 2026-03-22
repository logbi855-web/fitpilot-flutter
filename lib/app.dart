import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/storage/storage_service.dart';
import 'providers/water_provider.dart';
import 'screens/overview/overview_screen.dart';
import 'screens/app_hub/app_hub_screen.dart';
import 'screens/settings/settings_screen.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const OverviewScreen(),
    ),
    GoRoute(
      path: '/app/:tab',
      builder: (context, state) {
        final tab = state.pathParameters['tab'] ?? 'weather';
        return AppHubScreen(activeTab: tab);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

class FitPilotApp extends ConsumerStatefulWidget {
  const FitPilotApp({super.key});

  @override
  ConsumerState<FitPilotApp> createState() => _FitPilotAppState();
}

class _FitPilotAppState extends ConsumerState<FitPilotApp>
    with WidgetsBindingObserver {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  Future<void> _init() async {
    await StorageService.init();
    if (mounted) setState(() => _initialized = true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Check for midnight water-tracker reset on app resume
    if (state == AppLifecycleState.resumed) {
      ref.read(waterProvider.notifier).checkMidnightReset();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return const MaterialApp(
        home: Scaffold(
          backgroundColor: AppColors.bg,
          body: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      );
    }

    return MaterialApp.router(
      title: 'FitPilot',
      theme: AppTheme.dark,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
