// lib/widgets/daily_report_steps/student_topics_step.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_report.dart';
import '../../helpers/report_helpers.dart';

/// Widget para seleccionar los temas discutidos por estudiantes
class StudentTopicsStep extends StatelessWidget {
  const StudentTopicsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<DailyReportProvider>();
    final topics = getDiscussionTopics();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mark All Topics',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Checkbox(
              value: prov.studentTopics.length == topics.length,
              onChanged: (all) {
                if (all == true) {
                  for (var k in topics.keys) {
                    prov.toggleStudentTopic(k, true);
                  }
                } else {
                  for (var k in topics.keys) {
                    prov.toggleStudentTopic(k, false);
                  }
                }
              },
            ),
          ],
        ),
        ...topics.entries.map(
          (e) => CheckboxListTile(
            title: Text(e.value),
            value: prov.studentTopics.contains(e.key),
            onChanged: (sel) => prov.toggleStudentTopic(e.key, sel!),
          ),
        ),
        // Validación: al menos un tema seleccionado
        FormField<bool>(
          initialValue: prov.studentTopics.isNotEmpty,
          validator: (_) {
            return prov.studentTopics.isNotEmpty
                ? null
                : 'Please select at least one topic';
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
