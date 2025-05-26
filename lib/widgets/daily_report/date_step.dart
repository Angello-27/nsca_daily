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

    return ListTile(
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
    );
  }
}
