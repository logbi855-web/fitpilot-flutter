import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/profile_provider.dart';
import '../../models/body_profile.dart';
import '../../widgets/bmi_gauge.dart';

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _heightCtrl;
  late TextEditingController _ageCtrl;
  late TextEditingController _weightCtrl;
  late TextEditingController _targetCtrl;
  late TextEditingController _supplementDetailsCtrl;
  late TextEditingController _medicationCtrl;
  late TextEditingController _medOtherCtrl;

  String? _bodyShape;
  String? _fitnessLevel;
  String? _goal;
  String? _supplements;
  List<String> _medicalConditions = [];

  static const _conditions = [
    'heart', 'hypertension', 'diabetes', 'asthma', 'arthritis', 'back_pain',
  ];

  @override
  void initState() {
    super.initState();
    final p = ref.read(profileProvider);
    _nameCtrl = TextEditingController(text: p.name);
    _heightCtrl = TextEditingController(text: p.height?.toString() ?? '');
    _ageCtrl = TextEditingController(text: p.age?.toString() ?? '');
    _weightCtrl = TextEditingController(text: p.weight?.toString() ?? '');
    _targetCtrl = TextEditingController(text: p.targetWeight?.toString() ?? '');
    _supplementDetailsCtrl = TextEditingController(text: p.supplementDetails);
    _medicationCtrl = TextEditingController(text: p.medication);
    _medOtherCtrl = TextEditingController(text: p.medicalOther);
    _bodyShape = p.bodyShape;
    _fitnessLevel = p.fitnessLevel;
    _goal = p.goal;
    _supplements = p.takesSupplements;
    _medicalConditions = List.from(p.medicalConditions);
  }

  @override
  void dispose() {
    for (final c in [_nameCtrl, _heightCtrl, _ageCtrl, _weightCtrl,
        _targetCtrl, _supplementDetailsCtrl, _medicationCtrl, _medOtherCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      await ref.read(profileProvider.notifier).updatePhoto(file.path);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final profile = BodyProfile(
      name: _nameCtrl.text.trim(),
      height: double.tryParse(_heightCtrl.text),
      age: int.tryParse(_ageCtrl.text),
      weight: double.tryParse(_weightCtrl.text),
      targetWeight: double.tryParse(_targetCtrl.text),
      bodyShape: _bodyShape,
      fitnessLevel: _fitnessLevel,
      goal: _goal,
      medicalConditions: _medicalConditions,
      medicalOther: _medOtherCtrl.text,
      takesSupplements: _supplements,
      supplementDetails: _supplementDetailsCtrl.text,
      medication: _medicationCtrl.text,
      healthCaution: _medicalConditions.isNotEmpty,
      photoPath: ref.read(profileProvider).photoPath,
    );
    await ref.read(profileProvider.notifier).save(profile);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Profile saved!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final completionFields = [
      _nameCtrl.text.isNotEmpty,
      _heightCtrl.text.isNotEmpty,
      _ageCtrl.text.isNotEmpty,
      _weightCtrl.text.isNotEmpty,
      _bodyShape != null,
      _fitnessLevel != null,
      _goal != null,
    ];
    final completion =
        completionFields.where((v) => v).length / completionFields.length;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Center(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 44,
                      backgroundColor: AppColors.primaryDim,
                      backgroundImage: profile.photoPath != null
                          ? FileImage(File(profile.photoPath!))
                          : null,
                      child: profile.photoPath == null
                          ? Text(
                              profile.name.isNotEmpty
                                  ? profile.name[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                  fontSize: 32,
                                  color: AppColors.text,
                                  fontWeight: FontWeight.w700),
                            )
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                            color: AppColors.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt,
                            size: 14, color: AppColors.bg),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: LinearProgressIndicator(
                value: completion,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                'Profile ${(completion * 100).round()}% complete',
                style: const TextStyle(color: AppColors.muted, fontSize: 11),
              ),
            ),
            const SizedBox(height: 20),

            // Basic info fields
            _label('Name'),
            TextFormField(
              controller: _nameCtrl,
              style: const TextStyle(color: AppColors.text),
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(hintText: 'Your name'),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Height (cm)'),
                    TextFormField(
                      controller: _heightCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.text),
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(hintText: '170'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Age'),
                    TextFormField(
                      controller: _ageCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.text),
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(hintText: '25'),
                    ),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Weight (kg)'),
                    TextFormField(
                      controller: _weightCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.text),
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(hintText: '70'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Target (kg)'),
                    TextFormField(
                      controller: _targetCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: AppColors.text),
                      decoration: const InputDecoration(hintText: '65'),
                    ),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 20),

            // BMI gauge
            if (profile.bmi != null) ...[
              _label('BMI'),
              BmiGauge(bmi: profile.bmi),
              const SizedBox(height: 8),
            ],

            // Body shape
            _label('Body Shape'),
            _ToggleGroup(
              options: const ['pear', 'apple', 'hourglass', 'rectangle'],
              selected: _bodyShape,
              onSelect: (v) => setState(() { _bodyShape = v; }),
            ),
            const SizedBox(height: 16),

            // Fitness level
            _label('Fitness Level'),
            _ToggleGroup(
              options: const ['beginner', 'intermediate', 'advanced'],
              selected: _fitnessLevel,
              onSelect: (v) => setState(() { _fitnessLevel = v; }),
            ),
            const SizedBox(height: 16),

            // Goal
            _label('Goal'),
            _ToggleGroup(
              options: const ['lose', 'maintain', 'gain'],
              selected: _goal,
              onSelect: (v) => setState(() { _goal = v; }),
            ),
            const SizedBox(height: 16),

            // Medical conditions
            _label('Medical Conditions'),
            ..._conditions.map((c) => CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: Text(_conditionLabel(c),
                  style: const TextStyle(color: AppColors.text, fontSize: 13)),
              value: _medicalConditions.contains(c),
              activeColor: AppColors.primary,
              onChanged: (v) => setState(() {
                if (v == true) {
                  _medicalConditions.add(c);
                } else {
                  _medicalConditions.remove(c);
                }
              }),
            )),
            const SizedBox(height: 8),
            TextFormField(
              controller: _medOtherCtrl,
              style: const TextStyle(color: AppColors.text),
              decoration: const InputDecoration(hintText: 'Other conditions...'),
            ),
            if (_medicalConditions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9800).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFF9800).withValues(alpha: 0.4)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Color(0xFFFF9800), size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Consult your doctor before starting any new exercise or diet programme.',
                        style: TextStyle(color: Color(0xFFFF9800), fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Supplements
            _label('Takes Supplements?'),
            Row(children: [
              _SelectButton(label: 'Yes', value: 'yes', selected: _supplements == 'yes',
                  onTap: () => setState(() { _supplements = 'yes'; })),
              const SizedBox(width: 12),
              _SelectButton(label: 'No', value: 'no', selected: _supplements == 'no',
                  onTap: () => setState(() { _supplements = 'no'; })),
            ]),
            if (_supplements == 'yes') ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _supplementDetailsCtrl,
                style: const TextStyle(color: AppColors.text),
                decoration: const InputDecoration(
                    hintText: 'e.g. Whey protein, Creatine, Omega-3...'),
              ),
            ],
            const SizedBox(height: 16),

            TextFormField(
              controller: _medicationCtrl,
              style: const TextStyle(color: AppColors.text),
              decoration: const InputDecoration(hintText: 'Current medication (optional)'),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              child: const Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      );

  String _conditionLabel(String c) => {
        'heart': 'Heart condition',
        'hypertension': 'Hypertension',
        'diabetes': 'Diabetes',
        'asthma': 'Asthma',
        'arthritis': 'Arthritis',
        'back_pain': 'Back pain',
      }[c] ?? c;
}

class _ToggleGroup extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _ToggleGroup({
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: options.map((opt) {
        final isSelected = opt == selected;
        return GestureDetector(
          onTap: () => onSelect(opt),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryDim : AppColors.card2,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border),
            ),
            child: Text(
              opt[0].toUpperCase() + opt.substring(1),
              style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.text,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SelectButton extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _SelectButton({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryDim : AppColors.card2,
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: selected ? AppColors.primary : AppColors.border),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? AppColors.primary : AppColors.text,
                fontWeight: selected ? FontWeight.w700 : FontWeight.normal)),
      ),
    );
  }
}
