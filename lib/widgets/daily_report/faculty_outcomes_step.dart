// lib/widgets/daily_report_steps/faculty_outcomes_step.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_report.dart';
import '../../helpers/report_helpers.dart';
import '../../constants.dart';

/// Widget para seleccionar los resultados de discusión del personal académico
class FacultyOutcomesStep extends StatelessWidget {
  const FacultyOutcomesStep({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<DailyReportProvider>();
    final outcomes = getOutcomes();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.trending_up, color: kPrimaryColor, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Mark All Outcomes',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: kTextColor,
                    ),
                  ),
                ],
              ),
              Checkbox(
                value: prov.facultyOutcomes.length == outcomes.length,
                activeColor: kPrimaryColor,
                onChanged: (all) {
                  if (all == true) {
                    for (var key in outcomes.keys) {
                      prov.toggleFacultyOutcome(key, true);
                    }
                  } else {
                    for (var key in outcomes.keys) {
                      prov.toggleFacultyOutcome(key, false);
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
              color: kCardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kBorderColor),
            ),
            child: CheckboxListTile(
              title: Text(
                e.value,
                style: const TextStyle(color: kTextColor),
              ),
              value: prov.facultyOutcomes.contains(e.key),
              activeColor: kPrimaryColor,
              onChanged: (sel) => prov.toggleFacultyOutcome(e.key, sel!),
            ),
          ),
        ),
        // Validación: al menos un resultado seleccionado
        FormField<bool>(
          initialValue: prov.facultyOutcomes.isNotEmpty,
          validator: (_) {
            return prov.facultyOutcomes.isNotEmpty
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
  }
}
