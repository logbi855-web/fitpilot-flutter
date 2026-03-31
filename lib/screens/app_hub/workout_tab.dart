import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/workout_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/step_indicator.dart';
import '../../widgets/exercise_card.dart';

class WorkoutTab extends ConsumerWidget {
  const WorkoutTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(workoutProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: StepIndicator(currentStep: state.step),
        ),
        Expanded(
          child: _stepBody(context, ref, state),
        ),
      ],
    );
  }

  Widget _stepBody(BuildContext context, WidgetRef ref, WorkoutState state) {
    switch (state.step) {
      case 1:
        return _ChoiceStep(
          title: 'Choose Intensity',
          options: const [
            _Option('High', 'Challenging, fast-paced', 'high'),
            _Option('Low', 'Steady, recovery pace', 'low'),
          ],
          savedPlans: state.savedPlans,
          onSelect: (v) => ref.read(workoutProvider.notifier).setIntensity(v),
        );
      case 2:
        return _ChoiceStep(
          title: 'Choose Location',
          options: const [
            _Option('Home', 'No equipment needed', 'home'),
            _Option('Gym', 'Full equipment access', 'gym'),
          ],
          onSelect: (v) => ref.read(workoutProvider.notifier).setLocation(v),
          onBack: () => ref.read(workoutProvider.notifier).goBack(),
        );
      case 3:
        return _ChoiceStep(
          title: 'Choose Focus',
          options: const [
            _Option('Upper Body', 'Chest, back, shoulders, arms', 'upper'),
            _Option('Lower Body', 'Legs, glutes, calves', 'lower'),
            _Option('Full Body', 'Complete workout', 'full'),
          ],
          onSelect: (v) {
            final profile = ref.read(profileProvider);
            ref.read(workoutProvider.notifier).setFocus(
              v,
              fitnessLevel: profile.fitnessLevel ?? 'beginner',
              medicalConditions: profile.medicalConditions,
              bodyShape: profile.bodyShape,
            );
          },
          onBack: () => ref.read(workoutProvider.notifier).goBack(),
        );
      case 4:
        return _PlanStep(state: state);
      default:
        return const SizedBox();
    }
  }
}

class _Option {
  final String title;
  final String subtitle;
  final String value;
  const _Option(this.title, this.subtitle, this.value);
}

LinearGradient? _optionGradient(String value) => switch (value) {
  'high'  => const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFEF5350), Color(0xFFFF6F00)]),
  'low'   => const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF66BB6A), Color(0xFF00838F)]),
  'home'  => const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)]),
  'gym'   => const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1565C0), Color(0xFF4DD0E1)]),
  'upper' => const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFEF5350), Color(0xFFFF6F00)]),
  'lower' => const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF66BB6A), Color(0xFF00838F)]),
  'full'  => const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF7C3AED), Color(0xFF4DD0E1)]),
  _ => null,
};

// ── Step 1–3: Choice screens ─────────────────────────────────────────────────

class _ChoiceStep extends ConsumerWidget {
  final String title;
  final List<_Option> options;
  final ValueChanged<String> onSelect;
  final VoidCallback? onBack;
  final List<dynamic> savedPlans;

  const _ChoiceStep({
    required this.title,
    required this.options,
    required this.onSelect,
    this.onBack,
    this.savedPlans = const [],
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          ...options.map((opt) {
                final grad = _optionGradient(opt.value);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => onSelect(opt.value),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Row(
                          children: [
                            // Gradient left accent bar
                            if (grad != null)
                              Container(
                                width: 4,
                                height: 72,
                                decoration: BoxDecoration(gradient: grad),
                              ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(opt.title,
                                              style: const TextStyle(
                                                  color: AppColors.text,
                                                  fontWeight: FontWeight.w700)),
                                          Text(opt.subtitle,
                                              style: const TextStyle(
                                                  color: AppColors.muted, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right, color: AppColors.muted),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
          if (onBack != null)
            TextButton(
              onPressed: onBack,
              child: const Text('Back', style: TextStyle(color: AppColors.muted)),
            ),

          // Saved plans — shown on step 1 only
          if (savedPlans.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Divider(color: AppColors.border),
            const SizedBox(height: 8),
            const Text('Saved Plans',
                style: TextStyle(
                    color: AppColors.text,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...savedPlans.map((plan) => _SavedPlanTile(
                  plan: plan,
                  onLoad: () => ref.read(workoutProvider.notifier).loadPlan(plan),
                  onDelete: () =>
                      ref.read(workoutProvider.notifier).deletePlan(plan.id),
                )),
          ],
        ],
      ),
    );
  }
}

class _SavedPlanTile extends StatelessWidget {
  final dynamic plan;
  final VoidCallback onLoad;
  final VoidCallback onDelete;

  const _SavedPlanTile({
    required this.plan,
    required this.onLoad,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card2,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(plan.title,
                    style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                Text('${plan.exercises.length} exercises · ${plan.savedAt}',
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 11)),
              ],
            ),
          ),
          TextButton(
            onPressed: onLoad,
            child: const Text('Load',
                style: TextStyle(color: AppColors.primary, fontSize: 12)),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16, color: AppColors.muted),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

// ── Step 4: Plan view with exercise toggles ──────────────────────────────────

class _PlanStep extends ConsumerStatefulWidget {
  final WorkoutState state;
  const _PlanStep({required this.state});

  @override
  ConsumerState<_PlanStep> createState() => _PlanStepState();
}

class _PlanStepState extends ConsumerState<_PlanStep> {
  final Set<int> _done = {};

  @override
  Widget build(BuildContext context) {
    final exercises = widget.state.exercises;
    final profile = ref.watch(profileProvider);
    final doneCount = _done.length;
    final totalCount = exercises.length;
    final pct = totalCount > 0 ? doneCount / totalCount : 0.0;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Your Plan',
                  style: TextStyle(
                      color: AppColors.text,
                      fontSize: 20,
                      fontWeight: FontWeight.w700)),
              TextButton(
                onPressed: () => ref.read(workoutProvider.notifier).resetWizard(),
                child: const Text('Reset',
                    style: TextStyle(color: AppColors.muted)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text('$doneCount / $totalCount exercises done',
                  style: AppTextStyles.mono(
                      fontSize: 10, color: AppColors.primary)),
            ],
          ),
          if (_bodyShapeTip(profile.bodyShape, widget.state.choices.focus) case final tip when tip.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryDim.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(tip,
                  style: AppTextStyles.mono(fontSize: 10, color: AppColors.primary)),
            ),
          ],
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (ctx, constraints) => Stack(
              children: [
                Container(
                  height: 5,
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                if (pct > 0)
                  Container(
                    height: 5,
                    width: constraints.maxWidth * pct,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFFA78BFA), Color(0xFF4DD0E1)],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, i) {
                return ExerciseCard(
                  key: ValueKey('exercise_$i'),
                  rawText: exercises[i],
                  isDone: _done.contains(i),
                  onToggleDone: () => setState(() {
                    if (_done.contains(i)) {
                      _done.remove(i);
                    } else {
                      _done.add(i);
                    }
                  }),
                  onEdit: () => _editExercise(context, i, exercises[i]),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => ref
                      .read(workoutProvider.notifier)
                      .savePlan(
                        fitnessLevel: profile.fitnessLevel ?? 'beginner',
                        bodyShape: profile.bodyShape,
                        goal: profile.goal,
                        age: profile.age,
                      ),
                  child: const Text('Save Plan'),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => _addExercise(context),
                child: const Text('+ Add'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _bodyShapeTip(String? shape, String? focus) {
    if (shape == null || focus == null) return '';
    const tips = {
      'apple-upper': 'Apple shape: prioritise cardio alongside upper body work.',
      'apple-lower': 'Apple shape: great choice — lower body burns core fat too.',
      'apple-full': 'Apple shape: full body circuits are ideal for overall fat loss.',
      'pear-upper': 'Pear shape: upper body work helps balance proportions.',
      'pear-lower': 'Pear shape: mix strength and cardio to tone lower body.',
      'pear-full': 'Pear shape: full body sessions keep metabolism high.',
      'hourglass-upper': 'Hourglass: maintain your balance with controlled upper work.',
      'hourglass-lower': 'Hourglass: toning lower body preserves your natural shape.',
      'hourglass-full': 'Hourglass: full body is perfect to maintain proportion.',
      'rectangle-upper': 'Rectangle: upper body definition creates the V-taper look.',
      'rectangle-lower': 'Rectangle: lower body curves come from glute and leg focus.',
      'rectangle-full': 'Rectangle: full body adds shape and muscle all around.',
    };
    return tips['$shape-$focus'] ?? '';
  }

  void _editExercise(BuildContext context, int index, String current) {
    final ctrl = TextEditingController(text: current);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Edit Exercise',
            style: TextStyle(color: AppColors.text)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: AppColors.text),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(workoutProvider.notifier).updateExercise(index, ctrl.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _addExercise(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Add Exercise',
            style: TextStyle(color: AppColors.text)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: AppColors.text),
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Pull-ups — 3×8'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                ref.read(workoutProvider.notifier).addExercise(ctrl.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
