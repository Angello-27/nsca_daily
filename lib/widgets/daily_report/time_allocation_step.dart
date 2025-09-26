// lib/widgets/daily_report_steps/time_allocation_step.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_report.dart';
import '../../providers/theme_provider.dart';
import '../../helpers/report_helpers.dart';
import '../../constants.dart';

/// Widget para asignación de tiempo (%) por tema (sin validaciones, libre)
class TimeAllocationStep extends StatelessWidget {
  const TimeAllocationStep({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<DailyReportProvider>();
    final topics = getPercentageOnTopics();

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
            children: [
              Icon(Icons.schedule, color: kPrimaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Time Allocation (%)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.getTextColor(context),
                ),
              ),
            ],
          ),
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
                labelStyle: TextStyle(color: AppColors.getTextSecondaryColor(context)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.getBorderColor(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kPrimaryColor, width: 2),
                ),
                filled: true,
                fillColor: AppColors.getCardColor(context),
              ),
              initialValue: current,
              items: [
                DropdownMenuItem<int?>(value: null, child: Text('None', style: TextStyle(color: AppColors.getTextColor(context)))),
                ...List.generate(
                  100,
                  (i) => 100 - i,
                ).map((v) => DropdownMenuItem(value: v, child: Text('$v', style: TextStyle(color: AppColors.getTextColor(context))))),
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
      },
    );
  }
}
