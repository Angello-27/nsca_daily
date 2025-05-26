// lib/widgets/daily_report_steps/meeting_crisis_step.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_report.dart';
import '../../helpers/report_helpers.dart';

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
        SwitchListTile(
          title: const Text('Met with Parent/Guardian?'),
          value: prov.metParent,
          onChanged: prov.setMetParent,
        ),
        const SizedBox(height: 16),

        // Crisis today switch
        SwitchListTile(
          title: const Text('Crisis Today?'),
          value: prov.crisisToday,
          onChanged: prov.setCrisisToday,
        ),

        // If crisis occurred, show types
        if (prov.crisisToday) ...[
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Crisis Types',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Checkbox(
                value: prov.crisisTypes.length == crisisOptions.length,
                onChanged: (all) {
                  for (var key in crisisOptions.keys) {
                    prov.toggleCrisisType(key, all == true);
                  }
                },
              ),
            ],
          ),
          ...crisisOptions.entries.map(
            (e) => CheckboxListTile(
              title: Text(e.value),
              value: prov.crisisTypes.contains(e.key),
              onChanged: (sel) => prov.toggleCrisisType(e.key, sel!),
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
                            style: const TextStyle(color: Colors.red),
                          ),
                        )
                        : const SizedBox.shrink(),
          ),
        ],
      ],
    );
  }
}
