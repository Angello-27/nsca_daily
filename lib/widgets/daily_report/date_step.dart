import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_report.dart';

class DateStep extends StatelessWidget {
  const DateStep({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<DailyReportProvider>();

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      title: const Text('Fecha del Reporte'),
      subtitle: Text(
        '${prov.reportDate.year.toString().padLeft(4, '0')}-'
        '${prov.reportDate.month.toString().padLeft(2, '0')}-'
        '${prov.reportDate.day.toString().padLeft(2, '0')}',
      ),
      trailing: IconButton(
        icon: const Icon(Icons.calendar_today),
        onPressed: () async {
          final d = await showDatePicker(
            context: context,
            initialDate: prov.reportDate,
            firstDate: DateTime(2020),
            lastDate: DateTime.now(),
          );
          if (d != null) prov.setDate(d);
        },
      ),
    );
  }
}
