import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_report.dart';
import '../../constants.dart';

/// Widget para seleccionar horas de trabajo y conteo de alumnos (máximo 50)
class HoursStep extends StatelessWidget {
  const HoursStep({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<DailyReportProvider>();
    const int maxTotal = 50;
    final int maleCount = prov.studentsMale ?? 0;
    final int femaleCount = prov.studentsFemale ?? 0;
    final int maxMale = (maxTotal - femaleCount).clamp(0, maxTotal);
    final int maxFemale = (maxTotal - maleCount).clamp(0, maxTotal);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Muestra el límite total de alumnos
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            'Maximum Students Allowed: $maxTotal',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),

        // Working hours
        DropdownButtonFormField<int>(
          decoration: InputDecoration(
            labelText: 'Working Hours',
            border: kDefaultInputBorder,
            focusedBorder: kDefaultFocusInputBorder,
            filled: true,
            fillColor: Colors.white70,
          ),
          value: prov.workingHours,
          items:
              List.generate(12, (i) => i + 1)
                  .map((h) => DropdownMenuItem(value: h, child: Text('$h')))
                  .toList(),
          onChanged: (v) {
            if (v != null) prov.setWorkingHours(v);
          },
          validator: (v) => v == null ? 'Please select hours' : null,
        ),

        const SizedBox(height: 16),

        // Male Students
        DropdownButtonFormField<int?>(
          decoration: InputDecoration(
            labelText: 'Male Students',
            border: kDefaultInputBorder,
            focusedBorder: kDefaultFocusInputBorder,
            filled: true,
            fillColor: Colors.white70,
          ),
          value: prov.studentsMale,
          items: [
            const DropdownMenuItem<int?>(value: null, child: Text('None')),
            ...List.generate(
              maxMale,
              (i) => i + 1,
            ).map((v) => DropdownMenuItem(value: v, child: Text('$v'))),
          ],
          onChanged: prov.setStudentsMale,
          validator: (_) {
            if (prov.studentsMale == null && prov.studentsFemale == null) {
              return 'Select at least one gender';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Female Students
        DropdownButtonFormField<int?>(
          decoration: InputDecoration(
            labelText: 'Female Students',
            border: kDefaultInputBorder,
            focusedBorder: kDefaultFocusInputBorder,
            filled: true,
            fillColor: Colors.white70,
          ),
          value: prov.studentsFemale,
          items: [
            const DropdownMenuItem<int?>(value: null, child: Text('None')),
            ...List.generate(
              maxFemale,
              (i) => i + 1,
            ).map((v) => DropdownMenuItem(value: v, child: Text('$v'))),
          ],
          onChanged: prov.setStudentsFemale,
          validator: (_) {
            if (prov.studentsMale == null && prov.studentsFemale == null) {
              return 'Select at least one gender';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Total Students
        TextFormField(
          initialValue: prov.totalStudents.toString(),
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Total Students',
            border: kDefaultInputBorder,
            focusedBorder: kDefaultFocusInputBorder,
            filled: true,
            fillColor: Colors.white70,
          ),
        ),
      ],
    );
  }
}
