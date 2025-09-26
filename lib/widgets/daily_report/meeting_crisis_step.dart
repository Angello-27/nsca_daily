// lib/widgets/daily_report_steps/meeting_crisis_step.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_report.dart';
import '../../helpers/report_helpers.dart';
import '../../constants.dart';

/// Widget para capturar reunión con padres y crisis del día
class MeetingCrisisStep extends StatelessWidget {
  const MeetingCrisisStep({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<DailyReportProvider>();
    final crisisOptions = getCrisisTypes();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Parent/guardian meeting switch
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorderColor),
          ),
          child: SwitchListTile(
            title: const Text(
              'Met with Parent/Guardian?',
              style: TextStyle(color: kTextColor),
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
            color: kCardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorderColor),
          ),
          child: SwitchListTile(
            title: const Text(
              'Crisis Today?',
              style: TextStyle(color: kTextColor),
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
              color: kCardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kBorderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_outlined, color: kRedColor, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Crisis Types',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: kTextColor,
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
                color: kCardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kBorderColor),
              ),
              child: CheckboxListTile(
                title: Text(
                  e.value,
                  style: const TextStyle(color: kTextColor),
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
  }
}
