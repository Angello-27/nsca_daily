// lib/widgets/daily_report_steps/faculty_ethnic_step.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_report.dart';
import '../../helpers/report_helpers.dart';
import '../../constants.dart';

/// Widget para capturar etnicidad del personal académico
class FacultyEthnicStep extends StatelessWidget {
  const FacultyEthnicStep({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<DailyReportProvider>();
    final total = prov.teachersMany ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Muestra el total de personal académico
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorderColor),
          ),
          child: Row(
            children: [
              Icon(Icons.group_outlined, color: kPrimaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Total Faculty/Staff: $total',
                style: const TextStyle(
                  fontWeight: FontWeight.w600, 
                  fontSize: 16,
                  color: kTextColor,
                ),
              ),
            ],
          ),
        ),

        // Para cada grupo étnico del staff
        ...getEthnicGroups().entries.map((e) {
          final key = e.key;
          final label = e.value;
          final current = prov.ethnicTeachers[key] ?? 0;

          // Suma de los valores de otros grupos étnicos
          final sumOthers = prov.ethnicTeachers.entries
              .where((entry) => entry.key != key)
              .fold<int>(0, (sum, entry) => sum + entry.value);

          // Máximo permitido para este dropdown
          final maxForThis = (total - sumOthers).clamp(0, total);

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(color: kTextSecondaryColor),
                border: kDefaultInputBorder,
                focusedBorder: kDefaultFocusInputBorder,
                filled: true,
                fillColor: kCardColor,
              ),
              initialValue: current <= maxForThis ? current : 0,
              items:
                  List.generate(maxForThis + 1, (i) => i)
                      .map((v) => DropdownMenuItem(value: v, child: Text('$v', style: const TextStyle(color: kTextColor))))
                      .toList(),
              onChanged: (v) => prov.setEthnicTeacher(key, v),
              validator: (_) {
                final sumAll = prov.ethnicTeachers.values.fold(
                  0,
                  (s, x) => s + x,
                );
                return sumAll == total ? null : 'Sum must equal total faculty';
              },
            ),
          );
        }),
      ],
    );
  }
}
