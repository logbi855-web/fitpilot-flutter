import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../core/storage/storage_service.dart';
import '../../models/body_profile.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/step_indicator.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  // Step 1: Name + Photo
  final _nameCtrl = TextEditingController();
  String? _photoPath;

  // Step 2: Body stats
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();

  // Step 3: Goal
  String? _goal;
  String? _fitnessLevel;

  @override
  void dispose() {
    _pageCtrl.dispose();
    _nameCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  void _next() => _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );

  void _back() => _pageCtrl.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null && mounted) setState(() => _photoPath = file.path);
  }

  Future<void> _complete() async {
    final profile = BodyProfile(
      name: _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : 'User',
      height: double.tryParse(_heightCtrl.text),
      weight: double.tryParse(_weightCtrl.text),
      age: int.tryParse(_ageCtrl.text),
      goal: _goal,
      fitnessLevel: _fitnessLevel,
      photoPath: _photoPath,
    );
    await ref.read(profileProvider.notifier).save(profile);
    await StorageService.setString(StorageKeys.onboarding, 'done');
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Step indicator — hidden on welcome (page 0)
            AnimatedOpacity(
              opacity: _page > 0 ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 4),
                child: StepIndicator(
                  currentStep: _page.clamp(1, 4),
                  totalSteps: 4,
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageCtrl,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (p) => setState(() => _page = p),
                children: [
                  _WelcomePage(onStart: _next),
                  _NamePhotoPage(
                    nameCtrl: _nameCtrl,
                    photoPath: _photoPath,
                    onPickPhoto: _pickPhoto,
                    onNext: _next,
                    onBack: _back,
                  ),
                  _StatsPage(
                    heightCtrl: _heightCtrl,
                    weightCtrl: _weightCtrl,
                    ageCtrl: _ageCtrl,
                    onNext: _next,
                    onBack: _back,
                  ),
                  _GoalPage(
                    goal: _goal,
                    fitnessLevel: _fitnessLevel,
                    onGoalChanged: (v) => setState(() => _goal = v),
                    onLevelChanged: (v) => setState(() => _fitnessLevel = v),
                    onNext: _next,
                    onBack: _back,
                  ),
                  _DonePage(
                    name: _nameCtrl.text.trim(),
                    onComplete: _complete,
                    onBack: _back,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Welcome ────────────────────────────────────────────────────────────────────

class _WelcomePage extends StatefulWidget {
  final VoidCallback onStart;
  const _WelcomePage({required this.onStart});

  @override
  State<_WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<_WelcomePage>
    with TickerProviderStateMixin {
  late AnimationController _breathCtrl;
  late AnimationController _shimmerCtrl;
  late Animation<double> _breathAnim;

  @override
  void initState() {
    super.initState();
    _breathCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _breathAnim = CurvedAnimation(parent: _breathCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _breathCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Breathing glow icon
          AnimatedBuilder(
            animation: _breathAnim,
            builder: (_, child) => Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primaryDim, Color(0xFF4C1D95)],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryDim.withValues(
                        alpha: 0.25 + 0.45 * _breathAnim.value),
                    blurRadius: 16 + 24 * _breathAnim.value,
                    spreadRadius: 2 + 4 * _breathAnim.value,
                  ),
                ],
              ),
              child: Transform.scale(
                scale: 1.0 + 0.06 * _breathAnim.value,
                child: child,
              ),
            ),
            child: const Icon(Icons.fitness_center, size: 52, color: Colors.white),
          ),
          const SizedBox(height: 36),
          const Text(
            'Welcome to FitPilot',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.text,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your AI-powered fitness companion.\nLet\'s personalise your experience.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.muted, fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 56),
          // Shimmer gradient button
          AnimatedBuilder(
            animation: _shimmerCtrl,
            builder: (_, __) {
              final t = _shimmerCtrl.value;
              return InkWell(
                onTap: widget.onStart,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 52,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment(-2.0 + t * 4.0, 0),
                      end: Alignment(-2.0 + t * 4.0 + 2.0, 0),
                      colors: const [
                        Color(0xFF5B21B6),
                        Color(0xFF7C3AED),
                        Color(0xFFA78BFA),
                        Color(0xFFD8B4FE),
                        Color(0xFFA78BFA),
                        Color(0xFF7C3AED),
                        Color(0xFF5B21B6),
                      ],
                      stops: [0.0, 0.15, 0.3, 0.5, 0.7, 0.85, 1.0],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x557C3AED),
                        blurRadius: 14,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Get Started',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Name + Photo ───────────────────────────────────────────────────────────────

class _NamePhotoPage extends StatelessWidget {
  final TextEditingController nameCtrl;
  final String? photoPath;
  final VoidCallback onPickPhoto;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _NamePhotoPage({
    required this.nameCtrl,
    required this.photoPath,
    required this.onPickPhoto,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Who are you?',
            style: TextStyle(
                color: AppColors.text, fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add your name and a profile photo.',
            style: TextStyle(color: AppColors.muted, fontSize: 14),
          ),
          const SizedBox(height: 32),
          Center(
            child: GestureDetector(
              onTap: onPickPhoto,
              child: Stack(
                children: [
                  Hero(
                    tag: 'profile-avatar',
                    child: CircleAvatar(
                      radius: 56,
                      backgroundColor: AppColors.primaryDim,
                      backgroundImage: photoPath != null
                          ? FileImage(File(photoPath!))
                          : null,
                      child: photoPath == null
                          ? const Icon(Icons.add_a_photo,
                              size: 32, color: Colors.white)
                          : null,
                    ),
                  ),
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle),
                      child:
                          const Icon(Icons.edit, size: 14, color: AppColors.bg),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text('Your Name',
              style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: nameCtrl,
            style: const TextStyle(color: AppColors.text),
            decoration: const InputDecoration(hintText: 'Enter your name'),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 36),
          _NavRow(onBack: onBack, onNext: onNext),
        ],
      ),
    );
  }
}

// ── Body Stats ─────────────────────────────────────────────────────────────────

class _StatsPage extends StatelessWidget {
  final TextEditingController heightCtrl;
  final TextEditingController weightCtrl;
  final TextEditingController ageCtrl;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _StatsPage({
    required this.heightCtrl,
    required this.weightCtrl,
    required this.ageCtrl,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your body stats',
            style: TextStyle(
                color: AppColors.text, fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Used to calculate BMI and personalise your plan.',
            style: TextStyle(color: AppColors.muted, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 32),
          Row(children: [
            Expanded(
              child: _StatsField(label: 'Height (cm)', ctrl: heightCtrl, hint: '170'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _StatsField(label: 'Weight (kg)', ctrl: weightCtrl, hint: '70'),
            ),
          ]),
          const SizedBox(height: 16),
          _StatsField(label: 'Age', ctrl: ageCtrl, hint: '25'),
          const SizedBox(height: 36),
          _NavRow(onBack: onBack, onNext: onNext),
        ],
      ),
    );
  }
}

class _StatsField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final String hint;
  const _StatsField(
      {required this.label, required this.ctrl, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: AppColors.text),
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

// ── Fitness Goal ───────────────────────────────────────────────────────────────

class _GoalPage extends StatelessWidget {
  final String? goal;
  final String? fitnessLevel;
  final ValueChanged<String> onGoalChanged;
  final ValueChanged<String> onLevelChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _GoalPage({
    required this.goal,
    required this.fitnessLevel,
    required this.onGoalChanged,
    required this.onLevelChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "What's your goal?",
            style: TextStyle(
                color: AppColors.text, fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            "We'll tailor your plan to match your goal.",
            style: TextStyle(color: AppColors.muted, fontSize: 14),
          ),
          const SizedBox(height: 28),
          const Text('Fitness Goal',
              style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          _GoalOption(
            label: 'Lose Weight',
            description: 'Burn fat and improve body composition',
            icon: Icons.trending_down,
            selected: goal == 'lose',
            onTap: () => onGoalChanged('lose'),
          ),
          const SizedBox(height: 8),
          _GoalOption(
            label: 'Maintain Weight',
            description: 'Stay fit and maintain current physique',
            icon: Icons.balance,
            selected: goal == 'maintain',
            onTap: () => onGoalChanged('maintain'),
          ),
          const SizedBox(height: 8),
          _GoalOption(
            label: 'Gain Muscle',
            description: 'Build strength and increase muscle mass',
            icon: Icons.trending_up,
            selected: goal == 'gain',
            onTap: () => onGoalChanged('gain'),
          ),
          const SizedBox(height: 22),
          const Text('Fitness Level',
              style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['beginner', 'intermediate', 'advanced'].map((level) {
              final sel = fitnessLevel == level;
              return GestureDetector(
                onTap: () => onLevelChanged(level),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primaryDim : AppColors.card2,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: sel ? AppColors.primary : AppColors.border),
                  ),
                  child: Text(
                    level[0].toUpperCase() + level.substring(1),
                    style: TextStyle(
                      color: sel ? AppColors.primary : AppColors.text,
                      fontWeight:
                          sel ? FontWeight.w700 : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 36),
          _NavRow(onBack: onBack, onNext: onNext),
        ],
      ),
    );
  }
}

class _GoalOption extends StatelessWidget {
  final String label;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _GoalOption({
    required this.label,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryDim.withValues(alpha: 0.2)
              : AppColors.card2,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.border,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  color: selected ? AppColors.primary : AppColors.muted,
                  size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: selected ? AppColors.primary : AppColors.text,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  Text(description,
                      style: const TextStyle(
                          color: AppColors.muted, fontSize: 12)),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle,
                  color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── Done ───────────────────────────────────────────────────────────────────────

class _DonePage extends StatelessWidget {
  final String name;
  final VoidCallback onComplete;
  final VoidCallback onBack;

  const _DonePage({
    required this.name,
    required this.onComplete,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.primaryDim.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: const Icon(Icons.check, size: 44, color: AppColors.primary),
          ),
          const SizedBox(height: 28),
          Text(
            "You're all set${name.isNotEmpty ? ', $name' : ''}!",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.text,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            "Your profile is ready.\nLet's begin your fitness journey.",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: AppColors.muted, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 48),
          ElevatedButton(
            onPressed: onComplete,
            style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52)),
            child: const Text("Let's Go!", style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onBack,
            child: const Text('Back',
                style: TextStyle(color: AppColors.muted)),
          ),
        ],
      ),
    );
  }
}

// ── Shared nav row ─────────────────────────────────────────────────────────────

class _NavRow extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onNext;
  const _NavRow({required this.onBack, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
              onPressed: onBack, child: const Text('Back')),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
              onPressed: onNext, child: const Text('Next')),
        ),
      ],
    );
  }
}
