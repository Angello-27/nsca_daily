// lib/widgets/daily_report_steps/student_ethnic_step.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_report.dart';
import '../../helpers/report_helpers.dart';
import '../../constants.dart';

/// Widget para capturar etnicidad y edad promedio de estudiantes
class StudentEthnicStep extends StatelessWidget {
  const StudentEthnicStep({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<DailyReportProvider>();
    final total = prov.studentsMany; // ahora es int no nullable

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Muestra el total de estudiantes
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorderColor),
          ),
          child: Row(
            children: [
              Icon(Icons.people_outline, color: kPrimaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Total Students: $total',
                style: const TextStyle(
                  fontWeight: FontWeight.w600, 
                  fontSize: 16,
                  color: kTextColor,
                ),
              ),
            ],
          ),
        ),

        // Para cada grupo étnico
        ...getEthnicGroups().entries.map((e) {
          final key = e.key;
          final label = e.value;
          final current = prov.ethnicStudents[key] ?? 0;

          // Suma de todos los seleccionados excepto este grupo
          final sumOthers = prov.ethnicStudents.entries
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
              onChanged: (v) {
                // Actualiza el provider
                prov.setEthnicStudent(key, v);
              },
              validator: (_) {
                // Después de cambiar, la suma total debe coincidir con `total`
                final sumAll = prov.ethnicStudents.values.fold(
                  0,
                  (s, x) => s + x,
                );
                return sumAll == total ? null : 'Sum must equal total students';
              },
            ),
          );
        }),
      ],
    );
  }
}
