import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/workout_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/step_indicator.dart';

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
          onSelect: (v) =>
              ref.read(workoutProvider.notifier).setIntensity(v),
        );
      case 2:
        return _ChoiceStep(
          title: 'Choose Location',
          options: const [
            _Option('Home', 'No equipment needed', 'home'),
            _Option('Gym', 'Full equipment access', 'gym'),
          ],
          onSelect: (v) =>
              ref.read(workoutProvider.notifier).setLocation(v),
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
        return _PlanStep(state: state, ref: ref);
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

class _ChoiceStep extends StatelessWidget {
  final String title;
  final List<_Option> options;
  final ValueChanged<String> onSelect;
  final VoidCallback? onBack;

  const _ChoiceStep({
    required this.title,
    required this.options,
    required this.onSelect,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          ...options.map((opt) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () => onSelect(opt.value),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
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
              )),
          if (onBack != null)
            TextButton(
              onPressed: onBack,
              child: const Text('Back', style: TextStyle(color: AppColors.muted)),
            ),
        ],
      ),
    );
  }
}

class _PlanStep extends ConsumerWidget {
  final WorkoutState state;
  final WidgetRef ref;

  const _PlanStep({required this.state, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

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
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 1.0,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: state.exercises.length,
              itemBuilder: (context, i) => ListTile(
                leading: CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.primaryDim,
                  child: Text('${i + 1}',
                      style: const TextStyle(fontSize: 10, color: AppColors.text)),
                ),
                title: Text(state.exercises[i],
                    style: const TextStyle(color: AppColors.text, fontSize: 13)),
                trailing: IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      size: 16, color: AppColors.muted),
                  onPressed: () =>
                      _editExercise(context, ref, i, state.exercises[i]),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => ref.read(workoutProvider.notifier).savePlan(
                  fitnessLevel: profile.fitnessLevel ?? 'beginner',
                  bodyShape: profile.bodyShape,
                  goal: profile.goal,
                  age: profile.age,
                ),
            child: const Text('Save Plan'),
          ),
        ],
      ),
    );
  }

  void _editExercise(
      BuildContext context, WidgetRef ref, int index, String current) {
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
              ref
                  .read(workoutProvider.notifier)
                  .updateExercise(index, ctrl.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
