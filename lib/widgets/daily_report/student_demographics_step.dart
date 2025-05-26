import 'package:flutter/material.dart';
import 'package:nsca_daily/helpers/report_helpers.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_report.dart';
import '../../constants.dart';

/// Widget para seleccionar horas de trabajo y conteo de alumnos (máximo 50)
class StudentDemographicsStep extends StatefulWidget {
  const StudentDemographicsStep({super.key});

  @override
  State<StudentDemographicsStep> createState() =>
      _StudentDemographicsStepState();
}

class _StudentDemographicsStepState extends State<StudentDemographicsStep> {
  late final TextEditingController _totalController;
  late final DailyReportProvider _prov;

  @override
  void initState() {
    super.initState();
    _totalController = TextEditingController();
    // Capturamos el provider y suscribimos listener
    _prov = context.read<DailyReportProvider>();
    _prov.addListener(_updateTotal);
    _updateTotal();
  }

  @override
  void dispose() {
    // Usamos la referencia guardada, no context.read()
    _prov.removeListener(_updateTotal);
    _totalController.dispose();
    super.dispose();
  }

  void _updateTotal() {
    if (!mounted) return;
    _totalController.text = (_prov.studentsMany).toString();
  }

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
          controller: _totalController,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Total Students',
            border: kDefaultInputBorder,
            focusedBorder: kDefaultFocusInputBorder,
            filled: true,
            fillColor: Colors.white70,
          ),
        ),

        const SizedBox(height: 16),

        // Average Age dropdown
        DropdownButtonFormField<String?>(
          decoration: InputDecoration(
            labelText: 'Average Age',
            border: kDefaultInputBorder,
            focusedBorder: kDefaultFocusInputBorder,
            filled: true,
            fillColor: Colors.white70,
          ),
          items:
              getAgeGroups().entries
                  .map(
                    (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
                  )
                  .toList(),
          value: prov.averageAge,
          onChanged: prov.setAverageAge,
        ),
      ],
    );
  }
}
