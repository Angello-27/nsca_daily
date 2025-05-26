// lib/widgets/daily_report_steps/faculty_demographics_step.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_report.dart';
import '../../helpers/report_helpers.dart';
import '../../constants.dart';

/// Widget para capturar demografía del personal académico (desglose por rol)
class FacultyDemographicsStep extends StatelessWidget {
  const FacultyDemographicsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<DailyReportProvider>();
    final total = prov.teachersMany ?? 0;
    final groups = getFacultyOrStaffGroups();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Total de personal académico
        DropdownButtonFormField<int>(
          decoration: InputDecoration(
            labelText: 'Total Faculty/Staff',
            border: kDefaultInputBorder,
            focusedBorder: kDefaultFocusInputBorder,
            filled: true,
            fillColor: Colors.white70,
          ),
          value: prov.teachersMany,
          items:
              List.generate(50, (i) => i + 1)
                  .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                  .toList(),
          onChanged: (v) {
            if (v != null) prov.setTeachersMany(v);
          },
          validator: (v) => v == null ? 'Please select total' : null,
        ),

        const SizedBox(height: 16),
        const Text(
          'Breakdown by Role:',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const Divider(),

        // Desglose dinámico por rol (no supera el total)
        ...groups.entries.map((e) {
          final key = e.key;
          final label = e.value;
          final current = prov.facultyStaff[key] ?? 0;

          // Suma de los valores de otros roles
          final sumOthers = prov.facultyStaff.entries
              .where((entry) => entry.key != key)
              .fold<int>(0, (sum, entry) => sum + entry.value);

          // Máximo permitido para este dropdown
          final maxForThis = (total - sumOthers).clamp(0, total);

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: label,
                border: kDefaultInputBorder,
                focusedBorder: kDefaultFocusInputBorder,
                filled: true,
                fillColor: Colors.white70,
              ),
              value: current <= maxForThis ? current : 0,
              items:
                  List.generate(maxForThis + 1, (i) => i)
                      .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                      .toList(),
              onChanged: (v) => prov.setFacultyStaff(key, v),
              validator: (_) {
                final sumAll = prov.facultyStaff.values.fold(
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
