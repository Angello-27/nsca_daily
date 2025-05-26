// lib/widgets/daily_report_steps/faculty_topics_step.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_report.dart';
import '../../helpers/report_helpers.dart';

/// Widget para seleccionar los temas discutidos por el personal académico
class FacultyTopicsStep extends StatelessWidget {
  const FacultyTopicsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<DailyReportProvider>();
    final topics = getDiscussionTopics(forTeacher: true);

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
              value: prov.facultyTopics.length == topics.length,
              onChanged: (all) {
                if (all == true) {
                  for (var key in topics.keys) {
                    prov.toggleFacultyTopic(key, true);
                  }
                } else {
                  for (var key in topics.keys) {
                    prov.toggleFacultyTopic(key, false);
                  }
                }
              },
            ),
          ],
        ),
        ...topics.entries.map(
          (e) => CheckboxListTile(
            title: Text(e.value),
            value: prov.facultyTopics.contains(e.key),
            onChanged: (sel) => prov.toggleFacultyTopic(e.key, sel!),
          ),
        ),
        // Validación: al menos un tema seleccionado
        FormField<bool>(
          initialValue: prov.facultyTopics.isNotEmpty,
          validator: (_) {
            return prov.facultyTopics.isNotEmpty
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
