// lib/widgets/daily_report_steps/meeting_crisis_step.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_report.dart';
import '../../providers/theme_provider.dart';
import '../../helpers/report_helpers.dart';
import '../../constants.dart';

/// Widget para capturar reunión con padres y crisis del día
class MeetingCrisisStep extends StatelessWidget {
  const MeetingCrisisStep({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<DailyReportProvider>();
    final crisisOptions = getCrisisTypes();

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Parent/guardian meeting switch
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.getCardColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.getBorderColor(context)),
          ),
          child: SwitchListTile(
            title: Text(
              'Met with Parent/Guardian?',
              style: TextStyle(color: AppColors.getTextColor(context)),
            ),
            value: prov.metParent,
            activeThumbColor: kPrimaryColor,
            onChanged: prov.setMetParent,
          ),
        ),
        const SizedBox(height: 16),

        // Crisis today switch
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.getCardColor(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.getBorderColor(context)),
          ),
          child: SwitchListTile(
            title: Text(
              'Crisis Today?',
              style: TextStyle(color: AppColors.getTextColor(context)),
            ),
            value: prov.crisisToday,
            activeThumbColor: kPrimaryColor,
            onChanged: prov.setCrisisToday,
          ),
        ),

        // If crisis occurred, show types
        if (prov.crisisToday) ...[
          const SizedBox(height: 16),
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
                    Icon(Icons.warning_outlined, color: kRedColor, size: 20),
                    const SizedBox(width: 8),
                      Text(
                        'Crisis Types',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.getTextColor(context),
                        ),
                      ),
                  ],
                ),
                Checkbox(
                  value: prov.crisisTypes.length == crisisOptions.length,
                  activeColor: kPrimaryColor,
                  onChanged: (all) {
                    for (var key in crisisOptions.keys) {
                      prov.toggleCrisisType(key, all == true);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...crisisOptions.entries.map(
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
                value: prov.crisisTypes.contains(e.key),
                activeColor: kPrimaryColor,
                onChanged: (sel) => prov.toggleCrisisType(e.key, sel!),
              ),
            ),
          ),
          // Validación: al menos un tipo de crisis si aplica
          FormField<bool>(
            initialValue: prov.crisisTypes.isNotEmpty,
            validator: (_) {
              if (prov.crisisToday && prov.crisisTypes.isEmpty) {
                return 'Please select at least one crisis type';
              }
              return null;
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
      ],
    );
      },
    );
  }
}
