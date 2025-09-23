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
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: kBorderColor),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: kPrimaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Maximum Students Allowed: $maxTotal',
                style: const TextStyle(
                  fontWeight: FontWeight.w600, 
                  fontSize: 16,
                  color: kTextColor,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Male Students
        DropdownButtonFormField<int?>(
          decoration: InputDecoration(
            labelText: 'Male Students',
            labelStyle: const TextStyle(color: kTextSecondaryColor),
            border: kDefaultInputBorder,
            focusedBorder: kDefaultFocusInputBorder,
            filled: true,
            fillColor: kCardColor,
          ),
          initialValue: prov.studentsMale,
          items: [
            const DropdownMenuItem<int?>(value: null, child: Text('None', style: TextStyle(color: kTextColor))),
            ...List.generate(
              maxMale,
              (i) => i + 1,
            ).map((v) => DropdownMenuItem(value: v, child: Text('$v', style: const TextStyle(color: kTextColor)))),
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
            labelStyle: const TextStyle(color: kTextSecondaryColor),
            border: kDefaultInputBorder,
            focusedBorder: kDefaultFocusInputBorder,
            filled: true,
            fillColor: kCardColor,
          ),
          initialValue: prov.studentsFemale,
          items: [
            const DropdownMenuItem<int?>(value: null, child: Text('None', style: TextStyle(color: kTextColor))),
            ...List.generate(
              maxFemale,
              (i) => i + 1,
            ).map((v) => DropdownMenuItem(value: v, child: Text('$v', style: const TextStyle(color: kTextColor)))),
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
          style: const TextStyle(color: kTextColor),
          decoration: InputDecoration(
            labelText: 'Total Students',
            labelStyle: const TextStyle(color: kTextSecondaryColor),
            border: kDefaultInputBorder,
            focusedBorder: kDefaultFocusInputBorder,
            filled: true,
            fillColor: kCardColor,
          ),
        ),

        const SizedBox(height: 16),

        // Average Age dropdown
        DropdownButtonFormField<String?>(
          decoration: InputDecoration(
            labelText: 'Average Age',
            labelStyle: const TextStyle(color: kTextSecondaryColor),
            border: kDefaultInputBorder,
            focusedBorder: kDefaultFocusInputBorder,
            filled: true,
            fillColor: kCardColor,
          ),
          items:
              getAgeGroups().entries
                  .map(
                    (e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(color: kTextColor))),
                  )
                  .toList(),
          initialValue: prov.averageAge,
          onChanged: prov.setAverageAge,
        ),
      ],
    );
  }
}
