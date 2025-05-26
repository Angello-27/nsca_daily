import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_report.dart';
import '../../constants.dart';

class HoursStep extends StatelessWidget {
  const HoursStep({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<DailyReportProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Horas de trabajo (int, no nullable)
        DropdownButtonFormField<int>(
          decoration: InputDecoration(
            labelText: 'Horas de trabajo',
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
          validator: (v) => v == null ? 'Seleccione horas' : null,
        ),

        const SizedBox(height: 16),

        // Alumnos varones y hembras (int? nullable)
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int?>(
                decoration: InputDecoration(
                  labelText: 'Alumnos varones',
                  border: kDefaultInputBorder,
                  focusedBorder: kDefaultFocusInputBorder,
                  filled: true,
                  fillColor: Colors.white70,
                ),
                value: prov.studentsMale,
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Ninguno'),
                  ),
                  ...List.generate(
                    50,
                    (i) => i + 1,
                  ).map((v) => DropdownMenuItem(value: v, child: Text('$v'))),
                ],
                onChanged: prov.setStudentsMale,
                validator: (_) {
                  if (prov.studentsMale == null &&
                      prov.studentsFemale == null) {
                    return 'Seleccione al menos un género';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<int?>(
                decoration: InputDecoration(
                  labelText: 'Alumnos hembras',
                  border: kDefaultInputBorder,
                  focusedBorder: kDefaultFocusInputBorder,
                  filled: true,
                  fillColor: Colors.white70,
                ),
                value: prov.studentsFemale,
                items: [
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('Ninguno'),
                  ),
                  ...List.generate(
                    50,
                    (i) => i + 1,
                  ).map((v) => DropdownMenuItem(value: v, child: Text('$v'))),
                ],
                onChanged: prov.setStudentsFemale,
                validator: (_) {
                  if (prov.studentsMale == null &&
                      prov.studentsFemale == null) {
                    return 'Seleccione al menos un género';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Total de alumnos (propiedad del provider)
        TextFormField(
          initialValue: prov.totalStudents.toString(),
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Total de alumnos',
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
