// lib/screens/daily_report_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/daily_report.dart';
import '../providers/theme_provider.dart';
import '../widgets/daily_report/daily_report_stepper.dart';
import '../constants.dart';

class DailyReportScreen extends StatelessWidget {
  const DailyReportScreen({super.key});
  static const routeName = '/daily-report';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DailyReportProvider(),
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Scaffold(
            backgroundColor: AppColors.getBackgroundColor(context),
            body: DailyReportStepper(),
          );
        },
      ),
    );
  }
}
