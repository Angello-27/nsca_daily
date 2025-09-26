import 'package:flutter/material.dart';
import 'package:nsca_daily/constants.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_report.dart';
import '../../providers/theme_provider.dart';

/// Widget para seleccionar la fecha del reporte diario
class DateStep extends StatelessWidget {
  const DateStep({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<DailyReportProvider>();

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.getCardColor(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.getBorderColor(context)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: kPrimaryColor, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Report Date',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.getTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${prov.reportDate.year.toString().padLeft(4, '0')}-'
                          '${prov.reportDate.month.toString().padLeft(2, '0')}-'
                          '${prov.reportDate.day.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.getTextSecondaryColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_calendar),
                    color: kPrimaryColor,
                    onPressed: () async {
                      final selected = await showDatePicker(
                        context: context,
                        initialDate: prov.reportDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (selected != null) prov.setDate(selected);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Working hours
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: 'Working Hours',
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
              initialValue: prov.workingHours,
              items:
                  List.generate(12, (i) => i + 1)
                      .map((h) => DropdownMenuItem(value: h, child: Text('$h', style: TextStyle(color: AppColors.getTextColor(context)))))
                      .toList(),
              onChanged: (v) {
                if (v != null) prov.setWorkingHours(v);
              },
              validator: (v) => v == null ? 'Please select hours' : null,
            ),
          ],
        );
      },
    );
  }
}
