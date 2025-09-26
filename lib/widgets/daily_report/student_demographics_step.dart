import 'package:flutter/material.dart';
import 'package:nsca_daily/helpers/report_helpers.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_report.dart';
import '../../providers/theme_provider.dart';
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

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Muestra el límite total de alumnos
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.getCardColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.getBorderColor(context)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: kPrimaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Maximum Students Allowed: $maxTotal',
                    style: TextStyle(
                      fontWeight: FontWeight.w600, 
                      fontSize: 16,
                      color: AppColors.getTextColor(context),
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
                labelStyle: TextStyle(color: AppColors.getTextSecondaryColor(context)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.getBorderColor(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kPrimaryColor, width: 2),
                ),
                filled: true,
                fillColor: AppColors.getCardColor(context),
              ),
              initialValue: prov.studentsMale,
              items: [
                DropdownMenuItem<int?>(value: null, child: Text('None', style: TextStyle(color: AppColors.getTextColor(context)))),
                ...List.generate(
                  maxMale,
                  (i) => i + 1,
                ).map((v) => DropdownMenuItem(value: v, child: Text('$v', style: TextStyle(color: AppColors.getTextColor(context))))),
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
                labelStyle: TextStyle(color: AppColors.getTextSecondaryColor(context)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.getBorderColor(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kPrimaryColor, width: 2),
                ),
                filled: true,
                fillColor: AppColors.getCardColor(context),
              ),
              initialValue: prov.studentsFemale,
              items: [
                DropdownMenuItem<int?>(value: null, child: Text('None', style: TextStyle(color: AppColors.getTextColor(context)))),
                ...List.generate(
                  maxFemale,
                  (i) => i + 1,
                ).map((v) => DropdownMenuItem(value: v, child: Text('$v', style: TextStyle(color: AppColors.getTextColor(context))))),
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
              style: TextStyle(color: AppColors.getTextColor(context)),
              decoration: InputDecoration(
                labelText: 'Total Students',
                labelStyle: TextStyle(color: AppColors.getTextSecondaryColor(context)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.getBorderColor(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kPrimaryColor, width: 2),
                ),
                filled: true,
                fillColor: AppColors.getCardColor(context),
              ),
            ),

            const SizedBox(height: 16),

            // Average Age dropdown
            DropdownButtonFormField<String?>(
              decoration: InputDecoration(
                labelText: 'Average Age',
                labelStyle: TextStyle(color: AppColors.getTextSecondaryColor(context)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.getBorderColor(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kPrimaryColor, width: 2),
                ),
                filled: true,
                fillColor: AppColors.getCardColor(context),
              ),
              items:
                  getAgeGroups().entries
                      .map(
                        (e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: TextStyle(color: AppColors.getTextColor(context)))),
                      )
                      .toList(),
              initialValue: prov.averageAge,
              onChanged: prov.setAverageAge,
            ),
          ],
        );
      },
    );
  }
}
