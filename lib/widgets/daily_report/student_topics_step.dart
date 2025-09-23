// lib/widgets/daily_report_steps/student_topics_step.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_report.dart';
import '../../helpers/report_helpers.dart';
import '../../constants.dart';

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
                  Icon(Icons.checklist, color: kPrimaryColor, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Mark All Topics',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: kTextColor,
                    ),
                  ),
                ],
              ),
              Checkbox(
                value: prov.studentTopics.length == topics.length,
                activeColor: kPrimaryColor,
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
        ),
        const SizedBox(height: 16),
        ...topics.entries.map(
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
              value: prov.studentTopics.contains(e.key),
              activeColor: kPrimaryColor,
              onChanged: (sel) => prov.toggleStudentTopic(e.key, sel!),
            ),
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
                          style: const TextStyle(color: kRedColor),
                        ),
                      )
                      : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
