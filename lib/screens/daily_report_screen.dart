// lib/screens/daily_report_screen.dart
import 'package:flutter/material.dart';
import 'package:nsca_daily/constants.dart';
import 'package:provider/provider.dart';
import '../providers/daily_report.dart';
import '../widgets/daily_report/daily_report_stepper.dart';

class DailyReportScreen extends StatelessWidget {
  const DailyReportScreen({super.key});
  static const routeName = '/daily-report';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DailyReportProvider(),
      child: Scaffold(
        body: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: kPrimaryColor, // para iconos y líneas activas
              secondary: kSecondaryColor, // a veces usado para el acento
            ),
          ),
          child: DailyReportStepper(),
        ),
      ),
    );
  }
}
