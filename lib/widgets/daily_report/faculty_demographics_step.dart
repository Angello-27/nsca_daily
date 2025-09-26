// lib/widgets/daily_report_steps/faculty_demographics_step.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_report.dart';
import '../../providers/theme_provider.dart';
import '../../helpers/report_helpers.dart';
import '../../constants.dart';

/// Widget para capturar demografía del personal académico (desglose por rol)
class FacultyDemographicsStep extends StatelessWidget {
  const FacultyDemographicsStep({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<DailyReportProvider>();
    const int maxTotal = 50;
    final total = prov.teachersMany ?? 0;
    final groups = getFacultyOrStaffGroups();

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
                  Expanded(
                    child: Text(
                      'Maximum Faculty/Staff Allowed: $maxTotal',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.getTextColor(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Total de personal académico
            DropdownButtonFormField<int?>(
              decoration: InputDecoration(
                labelText: 'Total Faculty/Staff',
                labelStyle: TextStyle(
                  color: AppColors.getTextSecondaryColor(context),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.getBorderColor(context),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kPrimaryColor, width: 2),
                ),
                filled: true,
                fillColor: AppColors.getCardColor(context),
              ),
              initialValue: prov.teachersMany,
              items: [
                // opción inicial vacía
                DropdownMenuItem<int?>(
                  value: null,
                  child: Text(
                    'None',
                    style: TextStyle(color: AppColors.getTextColor(context)),
                  ),
                ),
                // de 1 a total
                ...List.generate(50, (i) => i + 1).map(
                  (v) => DropdownMenuItem(
                    value: v,
                    child: Text(
                      '$v',
                      style: TextStyle(color: AppColors.getTextColor(context)),
                    ),
                  ),
                ),
              ],
              onChanged: (v) {
                if (v != null) prov.setTeachersMany(v);
              },
              validator: (v) => v == null ? 'Please select total' : null,
            ),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.getCardColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.getBorderColor(context)),
              ),
              child: Row(
                children: [
                  Icon(Icons.group_outlined, color: kPrimaryColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Breakdown by Role:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.getTextColor(context),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

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
                    labelStyle: TextStyle(
                      color: AppColors.getTextSecondaryColor(context),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.getBorderColor(context),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: kPrimaryColor,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: AppColors.getCardColor(context),
                  ),
                  initialValue: current <= maxForThis ? current : 0,
                  items:
                      List.generate(maxForThis + 1, (i) => i)
                          .map(
                            (v) => DropdownMenuItem(
                              value: v,
                              child: Text(
                                '$v',
                                style: TextStyle(
                                  color: AppColors.getTextColor(context),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (v) => prov.setFacultyStaff(key, v),
                  validator: (_) {
                    final sumAll = prov.facultyStaff.values.fold(
                      0,
                      (s, x) => s + x,
                    );
                    return sumAll == total
                        ? null
                        : 'Sum must equal total faculty';
                  },
                ),
              );
            }),
          ],
        );
      },
    );
  }
}
