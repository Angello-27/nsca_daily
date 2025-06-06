import 'package:flutter/material.dart';
import 'package:nsca_daily/constants.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_report.dart';

/// Widget para seleccionar la fecha del reporte diario
class DateStep extends StatelessWidget {
  const DateStep({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<DailyReportProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
          title: const Text('Report Date'),
          subtitle: Text(
            '${prov.reportDate.year.toString().padLeft(4, '0')}-'
            '${prov.reportDate.month.toString().padLeft(2, '0')}-'
            '${prov.reportDate.day.toString().padLeft(2, '0')}',
          ),
          trailing: IconButton(
            icon: const Icon(Icons.calendar_today),
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
        ),
        const SizedBox(height: 16),
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
      ],
    );
  }
}
