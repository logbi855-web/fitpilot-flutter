import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'core/storage/storage_service.dart';
import 'providers/water_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/shell/main_shell.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/settings/settings_screen.dart';

GoRouter _buildRouter() => GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final done = StorageService.getString(StorageKeys.onboarding) != null;
        if (!done && state.uri.path != '/onboarding') return '/onboarding';
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: MainShell(),
          ),
        ),
        GoRoute(
          path: '/onboarding',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const OnboardingScreen(),
            transitionsBuilder: (context, animation, secondary, child) =>
                FadeTransition(opacity: animation, child: child),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const SettingsScreen(),
            transitionsBuilder: (context, animation, secondary, child) =>
                SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
              child: child,
            ),
          ),
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
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  Future<void> _init() async {
    await StorageService.init();
    if (mounted) {
      _router = _buildRouter();
      setState(() => _initialized = true);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
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

    final lang = ref.watch(settingsProvider).language;
    return MaterialApp.router(
      title: 'FitPilot',
      theme: AppTheme.dark,
      locale: Locale(lang),
      supportedLocales: const [
        Locale('en'),
        Locale('af'),
        Locale('fr'),
        Locale('zu'),
      ],
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
