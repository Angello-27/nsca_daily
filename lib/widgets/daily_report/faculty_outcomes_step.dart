// lib/widgets/daily_report_steps/faculty_outcomes_step.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_report.dart';
import '../../helpers/report_helpers.dart';

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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mark All Outcomes',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Checkbox(
              value: prov.facultyOutcomes.length == outcomes.length,
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
        ...outcomes.entries.map(
          (e) => CheckboxListTile(
            title: Text(e.value),
            value: prov.facultyOutcomes.contains(e.key),
            onChanged: (sel) => prov.toggleFacultyOutcome(e.key, sel!),
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
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                      : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
