// lib/widgets/daily_report_steps/student_outcomes_step.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_report.dart';
import '../../helpers/report_helpers.dart';

/// Widget para seleccionar resultados de discusión de estudiantes
class StudentOutcomesStep extends StatelessWidget {
  const StudentOutcomesStep({super.key});

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
              value: prov.studentOutcomes.length == outcomes.length,
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
        ...outcomes.entries.map(
          (e) => CheckboxListTile(
            title: Text(e.value),
            value: prov.studentOutcomes.contains(e.key),
            onChanged: (sel) => prov.toggleStudentOutcome(e.key, sel!),
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
                          style: const TextStyle(color: Colors.red),
                        ),
                      )
                      : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
