// lib/widgets/daily_report_steps/student_outcomes_step.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_report.dart';
import '../../providers/theme_provider.dart';
import '../../helpers/report_helpers.dart';
import '../../constants.dart';

/// Widget para seleccionar resultados de discusión de estudiantes
class StudentOutcomesStep extends StatelessWidget {
  const StudentOutcomesStep({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<DailyReportProvider>();
    final outcomes = getOutcomes();

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.getCardColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.getBorderColor(context)),
              ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.trending_up, color: kPrimaryColor, size: 20),
                  const SizedBox(width: 8),
                      Text(
                        'Mark All Outcomes',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextColor(context),
                        ),
                      ),
                ],
              ),
              Checkbox(
                value: prov.studentOutcomes.length == outcomes.length,
                activeColor: kPrimaryColor,
                onChanged: (all) {
                  if (all == true) {
                    for (var k in outcomes.keys) {
                      prov.toggleStudentOutcome(k, true);
                    }
                  } else {
                    for (var k in outcomes.keys) {
                      prov.toggleStudentOutcome(k, false);
                    }
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...outcomes.entries.map(
              (e) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.getCardColor(context),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.getBorderColor(context)),
                ),
            child: CheckboxListTile(
                  title: Text(
                    e.value,
                    style: TextStyle(color: AppColors.getTextColor(context)),
                  ),
              value: prov.studentOutcomes.contains(e.key),
              activeColor: kPrimaryColor,
              onChanged: (sel) => prov.toggleStudentOutcome(e.key, sel!),
            ),
          ),
        ),
        // Validación: al menos un resultado seleccionado
        FormField<bool>(
          initialValue: prov.studentOutcomes.isNotEmpty,
          validator: (_) {
            return prov.studentOutcomes.isNotEmpty
                ? null
                : 'Please select at least one outcome';
          },
          builder:
              (state) =>
                  state.hasError
                      ? Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 8),
                        child: Text(
                          state.errorText!,
                          style: const TextStyle(color: kRedColor),
                        ),
                      )
                      : const SizedBox.shrink(),
        ),
      ],
    );
      },
    );
  }
}
