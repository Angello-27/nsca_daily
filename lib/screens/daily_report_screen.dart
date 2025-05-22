// lib/screens/daily_report_screen.dart
import 'package:flutter/material.dart';
import 'package:nsca_daily/helpers/report_helpers.dart';
import '../constants.dart';

class DailyReportScreen extends StatefulWidget {
  const DailyReportScreen({super.key});

  @override
  State<DailyReportScreen> createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  int _currentStep = 0;

  // Form keys for each step
  late final List<GlobalKey<FormState>> _stepKeys;

  // Student data
  int? _workingHours;
  int? _studentsTotal;
  int? _studentsMale;
  int? _studentsFemale;
  int? _studentsAge;
  final Map<String, int> _studentsEthnic = {};
  final Set<String> _studentTopics = {};
  final Set<String> _studentOutcomes = {};

  @override
  void initState() {
    super.initState();
    // Initialize one key per step
    _stepKeys = List.generate(3, (_) => GlobalKey<FormState>());
  }

  void _onStepContinue() {
    if (_currentStep < _steps.length - 1) {
      // Validate only current step
      if (_stepKeys[_currentStep].currentState!.validate()) {
        setState(() => _currentStep += 1);
      }
    } else {
      // Final demo
      setState(() => _currentStep = 0);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Demo completed')));
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) setState(() => _currentStep -= 1);
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: kDefaultInputBorder,
      enabledBorder: kDefaultInputBorder,
      focusedBorder: kDefaultFocusInputBorder,
      errorBorder: kDefaultFocusErrorBorder,
      filled: true,
      fillColor: Colors.white70,
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    );
  }

  Widget _buildStepHours() {
    return Form(
      key: _stepKeys[0],
      child: Column(
        children: [
          DropdownButtonFormField<int>(
            decoration: _inputDecoration('Working Hours'),
            items:
                List.generate(12, (i) => i + 1)
                    .map((h) => DropdownMenuItem(value: h, child: Text('$h')))
                    .toList(),
            value: _workingHours,
            onChanged: (v) => setState(() => _workingHours = v),
            validator: (v) => v == null ? 'Please select hours' : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            decoration: _inputDecoration('Total Students'),
            items:
                List.generate(50, (i) => i + 1)
                    .map((s) => DropdownMenuItem(value: s, child: Text('$s')))
                    .toList(),
            value: _studentsTotal,
            onChanged: (v) => setState(() => _studentsTotal = v),
            validator: (v) => v == null ? 'Please select total' : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  decoration: _inputDecoration('Male'),
                  items:
                      List.generate(50, (i) => i + 1)
                          .map(
                            (m) =>
                                DropdownMenuItem(value: m, child: Text('$m')),
                          )
                          .toList(),
                  value: _studentsMale,
                  onChanged: (v) => setState(() => _studentsMale = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  decoration: _inputDecoration('Female'),
                  items:
                      List.generate(50, (i) => i + 1)
                          .map(
                            (f) =>
                                DropdownMenuItem(value: f, child: Text('$f')),
                          )
                          .toList(),
                  value: _studentsFemale,
                  onChanged: (v) => setState(() => _studentsFemale = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepEthnicity() {
    return Form(
      key: _stepKeys[1],
      child: Column(
        children: [
          DropdownButtonFormField<int>(
            decoration: _inputDecoration('Average Age'),
            items:
                List.generate(16, (i) => i + 5)
                    .map((a) => DropdownMenuItem(value: a, child: Text('$a')))
                    .toList(),
            value: _studentsAge,
            onChanged: (v) => setState(() => _studentsAge = v),
            validator: (v) => v == null ? 'Please select age' : null,
          ),
          const SizedBox(height: 16),
          ...getEthnicGroups().entries.map((e) {
            return DropdownButtonFormField<int>(
              decoration: _inputDecoration(e.value),
              items:
                  List.generate(50, (i) => i + 1)
                      .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                      .toList(),
              value: _studentsEthnic[e.key],
              onChanged: (v) => setState(() => _studentsEthnic[e.key] = v!),
              validator: (v) {
                final sum = _studentsEthnic.values.fold(0, (s, x) => s + x);
                return sum == (_studentsTotal ?? 0)
                    ? null
                    : 'Sum must equal total';
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStepTopics() {
    return Form(
      key: _stepKeys[2],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Discussion Topics',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          ...getDiscussionTopics().entries.map((e) {
            return CheckboxListTile(
              title: Text(e.value),
              value: _studentTopics.contains(e.key),
              onChanged:
                  (sel) => setState(() {
                    if (sel!) {
                      _studentTopics.add(e.key);
                    } else {
                      _studentTopics.remove(e.key);
                    }
                  }),
            );
          }),
          const Divider(),
          const Text('Outcomes', style: TextStyle(fontWeight: FontWeight.w600)),
          ...getOutcomes().entries.map((e) {
            return CheckboxListTile(
              title: Text(e.value),
              value: _studentOutcomes.contains(e.key),
              onChanged:
                  (sel) => setState(() {
                    if (sel!) {
                      _studentOutcomes.add(e.key);
                    } else {
                      _studentOutcomes.remove(e.key);
                    }
                  }),
            );
          }),
        ],
      ),
    );
  }

  List<Step> get _steps => [
    Step(
      title: const Text('Hours & Students'),
      content: _buildStepHours(),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: const Text('Ethnicity & Age'),
      content: _buildStepEthnicity(),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: const Text('Topics & Outcomes'),
      content: _buildStepTopics(),
      isActive: _currentStep >= 2,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Report'),
        backgroundColor: kBackgroundColor,
      ),
      backgroundColor: kBackgroundColor,
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: _onStepContinue,
        onStepCancel: _onStepCancel,
        onStepTapped: (index) => setState(() => _currentStep = index),
        controlsBuilder: (context, details) {
          final isLast = _currentStep == _steps.length - 1;
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                MaterialButton(
                  onPressed: details.onStepContinue,
                  color: kPrimaryColor,
                  textColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 15,
                  ),
                  splashColor: kStarColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7.0),
                    side: const BorderSide(color: kPrimaryColor),
                  ),
                  child: Text(
                    isLast ? 'Restart' : 'Next',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                if (_currentStep > 0)
                  MaterialButton(
                    onPressed: details.onStepCancel,
                    color: kSectionTileColor,
                    textColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 15,
                    ),
                    splashColor: kDarkGreyColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7.0),
                      side: const BorderSide(color: kSectionTileColor),
                    ),
                    child: Text(
                      'Back',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          );
        },
        steps: _steps,
      ),
    );
  }
}
