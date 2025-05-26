import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:nsca_daily/constants.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_report.dart';
import './date_step.dart';
import 'student_demographics_step.dart';
import './student_ethnic_step.dart';
import './student_topics_step.dart';
import './student_outcomes_step.dart';
import './faculty_demographics_step.dart';
import './faculty_ethnic_step.dart';
import './faculty_topics_step.dart';
import './faculty_outcomes_step.dart';
import './meeting_crisis_step.dart';
import './time_allocation_step.dart';

/// Widget que arma el Stepper completo del reporte diario.
class DailyReportStepper extends StatefulWidget {
  const DailyReportStepper({super.key});

  @override
  State<DailyReportStepper> createState() => _DailyReportStepperState();
}

class _DailyReportStepperState extends State<DailyReportStepper> {
  int _currentStep = 0;
  final _stepKeys = List.generate(11, (_) => GlobalKey<FormState>());

  Future<void> _onContinue(DailyReportProvider prov) async {
    final isLast = _currentStep == _steps.length - 1;
    final form = _stepKeys[_currentStep].currentState;
    if (form == null || form.validate()) {
      if (isLast) {
        try {
          final error = await prov.submitReport();
          if (!mounted) return;
          if (error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(error)));
          } else {
            // En lugar del SnackBar, mostramos el diálogo de éxito
            await showSuccessDialog(context);
            // 1) Reseteo el provider
            prov.reset();
            // 2) Pinto el stepper de nuevo en 0
            setState(() {
              _currentStep = 0;
            });
          }
        } catch (error) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(error.toString())));
        }
      } else {
        setState(() => _currentStep++);
      }
    }
  }

  void _onCancel() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  List<Step> get _steps => [
    Step(
      title: const Text('Report Date'),
      content: Form(key: _stepKeys[0], child: const DateStep()),
      isActive: _currentStep >= 0,
    ),
    Step(
      title: const Text('Student Demographics'),
      content: Form(key: _stepKeys[1], child: const StudentDemographicsStep()),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: const Text('Student Ethnicity'),
      content: Form(key: _stepKeys[2], child: const StudentEthnicStep()),
      isActive: _currentStep >= 2,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: const Text('Student Topics'),
      content: Form(key: _stepKeys[3], child: const StudentTopicsStep()),
      isActive: _currentStep >= 3,
      state: _currentStep > 3 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: const Text('Student Outcomes'),
      content: Form(key: _stepKeys[4], child: const StudentOutcomesStep()),
      isActive: _currentStep >= 4,
      state: _currentStep > 4 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: const Text('Faculty Demographics'),
      content: Form(key: _stepKeys[5], child: const FacultyDemographicsStep()),
      isActive: _currentStep >= 5,
      state: _currentStep > 5 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: const Text('Faculty Ethnicity'),
      content: Form(key: _stepKeys[6], child: const FacultyEthnicStep()),
      isActive: _currentStep >= 6,
      state: _currentStep > 6 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: const Text('Faculty Topics'),
      content: Form(key: _stepKeys[7], child: const FacultyTopicsStep()),
      isActive: _currentStep >= 7,
      state: _currentStep > 7 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: const Text('Faculty Outcomes'),
      content: Form(key: _stepKeys[8], child: const FacultyOutcomesStep()),
      isActive: _currentStep >= 8,
      state: _currentStep > 8 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: const Text('Meeting & Crisis'),
      content: Form(key: _stepKeys[9], child: const MeetingCrisisStep()),
      isActive: _currentStep >= 9,
      state: _currentStep > 9 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: const Text('Time Allocation'),
      content: Form(key: _stepKeys[10], child: const TimeAllocationStep()),
      isActive: _currentStep >= 10,
      state: _currentStep > 10 ? StepState.complete : StepState.indexed,
    ),
  ];

  Future<void> showSuccessDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (_) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Si tienes un JSON de Lottie en assets:
                Lottie.asset(
                  'assets/images/success.json',
                  width: 120,
                  repeat: false,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Your daily report was submitted successfully!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  Widget _buildNextButton(ControlsDetails details, bool isLast) {
    return MaterialButton(
      onPressed: details.onStepContinue,
      color: kPrimaryColor,
      textColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      splashColor: kStarColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7.0),
        side: const BorderSide(color: kPrimaryColor),
      ),
      child: Text(
        isLast ? 'Submit' : 'Next',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBackButton(ControlsDetails details) {
    return MaterialButton(
      onPressed: details.onStepCancel,
      color: kSectionTileColor,
      textColor: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      splashColor: kDarkGreyColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7.0),
        side: const BorderSide(color: kSectionTileColor),
      ),
      child: const Text('Back', style: TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DailyReportProvider>(
      builder:
          (ctx, prov, _) => Stepper(
            type: StepperType.vertical,
            currentStep: _currentStep,
            steps: _steps,
            onStepContinue: () => _onContinue(prov),
            onStepCancel: _onCancel,
            controlsBuilder: (ctx, details) {
              final isLast = _currentStep == _steps.length - 1;
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    _buildNextButton(details, isLast),
                    const SizedBox(width: 8),
                    if (_currentStep > 0) _buildBackButton(details),
                  ],
                ),
              );
            },
          ),
    );
  }
}
