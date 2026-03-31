import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// 4-step wizard step indicator: 4 dots connected by 3 lines.
class StepIndicator extends StatelessWidget {
  final int currentStep; // 1–4
  final int totalSteps;

  const StepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps * 2 - 1, (i) {
        if (i.isEven) {
          final stepNum = i ~/ 2 + 1;
          final isActive = stepNum <= currentStep;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 14,
            height: 14,
            decoration: isActive
                ? const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFA78BFA), Color(0xFF7C3AED)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x557C3AED),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  )
                : const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.border,
                  ),
          );
        } else {
          final connectorIndex = i ~/ 2;
          final isActive = connectorIndex + 1 < currentStep;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 32,
            height: 2,
            decoration: isActive
                ? const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
                    ),
                  )
                : const BoxDecoration(color: AppColors.border),
          );
        }
      }),
    );
  }
}
