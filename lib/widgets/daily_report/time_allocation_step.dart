// lib/widgets/daily_report_steps/time_allocation_step.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_report.dart';
import '../../helpers/report_helpers.dart';
import '../../constants.dart';

/// Widget para asignación de tiempo (%) por tema (sin validaciones, libre)
class TimeAllocationStep extends StatelessWidget {
  const TimeAllocationStep({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<DailyReportProvider>();
    final topics = getPercentageOnTopics();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Time Allocation (%)',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),

        ...topics.entries.expand<Widget>((e) {
          final key = e.key;
          final label = e.value;
          final current = prov.percentageByTopic[key];

          return [
            DropdownButtonFormField<int?>(
              decoration: InputDecoration(
                labelText: label,
                border: kDefaultInputBorder,
                focusedBorder: kDefaultFocusInputBorder,
                filled: true,
                fillColor: Colors.white70,
              ),
              initialValue: current,
              items: [
                const DropdownMenuItem<int?>(value: null, child: Text('None')),
                ...List.generate(
                  100,
                  (i) => 100 - i,
                ).map((v) => DropdownMenuItem(value: v, child: Text('$v'))),
              ],
              onChanged: (v) {
                prov.setPercentage(key, v ?? 0);
              },
            ),
            const SizedBox(height: 16),
          ];
        }),
      ],
    );
  }
}
