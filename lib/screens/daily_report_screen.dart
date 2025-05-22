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

  // Faculty data
  int? _facultyTotal;
  final Map<String, int> _facultyEthnic = {};
  final Set<String> _facultyTopics = {};
  final Set<String> _facultyOutcomes = {};

  // Meeting & Crisis
  bool _metParent = false;
  bool _crisisToday = false;
  final Set<String> _crisisTypes = {};

  // Time allocation
  final Map<String, int> _timeAlloc = {};

  @override
  void initState() {
    super.initState();
    // Initialize one key per step
    _stepKeys = List.generate(7, (_) => GlobalKey<FormState>());
  }

  void _onStepContinue() {
    if (_currentStep < _steps.length - 1) {
      // Validate only current step
      if (_stepKeys[_currentStep].currentState!.validate()) {
        setState(() => _currentStep += 1);
      }
    } else {
      // Final submit or restart
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Form submitted')));
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

  Widget _buildStep1Hours() => Form(
    key: _stepKeys[0],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<int>(
          decoration: _inputDecoration('Working Hours'),
          items:
              List.generate(12, (i) => i + 1)
                  .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
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
                  .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
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
                          (v) => DropdownMenuItem(value: v, child: Text('$v')),
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
                          (v) => DropdownMenuItem(value: v, child: Text('$v')),
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

  Widget _buildStep2Ethnicity() => Form(
    key: _stepKeys[1],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<int>(
          decoration: _inputDecoration('Average Age'),
          items:
              List.generate(16, (i) => i + 5)
                  .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                  .toList(),
          value: _studentsAge,
          onChanged: (v) => setState(() => _studentsAge = v),
          validator: (v) => v == null ? 'Please select age' : null,
        ),
        const SizedBox(height: 16),
        const Text(
          'Racial or ethnic group of Students:',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const Divider(),
        ...getEthnicGroups().entries.expand<Widget>(
          (e) => [
            DropdownButtonFormField<int>(
              decoration: _inputDecoration(e.value),
              items:
                  List.generate(50, (i) => i + 1)
                      .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                      .toList(),
              value: _studentsEthnic[e.key],
              onChanged: (v) => setState(() => _studentsEthnic[e.key] = v!),
              validator: (v) {
                final sum = _studentsEthnic.values.fold(0, (s, x) => s + x);
                return sum == (_studentsTotal ?? 0)
                    ? null
                    : 'Sum must equal total';
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ],
    ),
  );

  Widget _buildStep3Topics() => Form(
    key: _stepKeys[2],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Discussion Topics',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        ...getDiscussionTopics().entries.map(
          (e) => CheckboxListTile(
            title: Text(e.value),
            value: _studentTopics.contains(e.key),
            onChanged:
                (sel) => setState(
                  () =>
                      sel!
                          ? _studentTopics.add(e.key)
                          : _studentTopics.remove(e.key),
                ),
          ),
        ),
        const Divider(),
        const Text('Outcomes', style: TextStyle(fontWeight: FontWeight.w600)),
        ...getOutcomes().entries.map(
          (e) => CheckboxListTile(
            title: Text(e.value),
            value: _studentOutcomes.contains(e.key),
            onChanged:
                (sel) => setState(
                  () =>
                      sel!
                          ? _studentOutcomes.add(e.key)
                          : _studentOutcomes.remove(e.key),
                ),
          ),
        ),
      ],
    ),
  );

  Widget _buildStep4Faculty() => Form(
    key: _stepKeys[3],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<int>(
          decoration: _inputDecoration('Total Faculty/Staff'),
          items:
              List.generate(50, (i) => i + 1)
                  .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                  .toList(),
          value: _facultyTotal,
          onChanged: (v) => setState(() => _facultyTotal = v),
          validator: (v) => v == null ? 'Select total' : null,
        ),
        const SizedBox(height: 16),
        ...getFacultyOrStaffGroups().entries.expand<Widget>(
          (e) => [
            DropdownButtonFormField<int>(
              decoration: _inputDecoration(e.value),
              items:
                  List.generate(50, (i) => i + 1)
                      .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                      .toList(),
              value: _facultyEthnic[e.key],
              onChanged: (v) => setState(() => _facultyEthnic[e.key] = v!),
              validator: (v) {
                final sum = _facultyEthnic.values.fold(0, (s, x) => s + x);
                return sum == (_facultyTotal ?? 0)
                    ? null
                    : 'Sum must equal total';
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ],
    ),
  );

  Widget _buildStep5FacultyTopics() => Form(
    key: _stepKeys[4],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Discussion Topics',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        ...getDiscussionTopics(forTeacher: true).entries.map(
          (e) => CheckboxListTile(
            title: Text(e.value),
            value: _facultyTopics.contains(e.key),
            onChanged:
                (sel) => setState(
                  () =>
                      sel!
                          ? _facultyTopics.add(e.key)
                          : _facultyTopics.remove(e.key),
                ),
          ),
        ),
        const Divider(),
        const Text(
          'Faculty Outcomes',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        ...getOutcomes().entries.map(
          (e) => CheckboxListTile(
            title: Text(e.value),
            value: _facultyOutcomes.contains(e.key),
            onChanged:
                (sel) => setState(
                  () =>
                      sel!
                          ? _facultyOutcomes.add(e.key)
                          : _facultyOutcomes.remove(e.key),
                ),
          ),
        ),
      ],
    ),
  );

  Widget _buildStep6MeetingCrisis() => Form(
    key: _stepKeys[5],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('Met with parent/guardian?'),
          value: _metParent,
          onChanged: (v) => setState(() => _metParent = v),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Was there a crisis today?'),
          value: _crisisToday,
          onChanged: (v) => setState(() => _crisisToday = v),
        ),
        if (_crisisToday) ...[
          const Divider(),
          const Text(
            'Crisis Types',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          ...getCrisisTypes().entries.map(
            (e) => CheckboxListTile(
              title: Text(e.value),
              value: _crisisTypes.contains(e.key),
              onChanged:
                  (sel) => setState(
                    () =>
                        sel!
                            ? _crisisTypes.add(e.key)
                            : _crisisTypes.remove(e.key),
                  ),
            ),
          ),
        ],
      ],
    ),
  );

  Widget _buildStep7TimeAllocation() => Form(
    key: _stepKeys[6],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Time Allocation (%)',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        ...getPercentageOnTopics().entries.expand<Widget>(
          (e) => [
            DropdownButtonFormField<int>(
              decoration: _inputDecoration(e.value),
              items:
                  List.generate(100, (i) => i + 1)
                      .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                      .toList(),
              value: _timeAlloc[e.key],
              onChanged: (v) => setState(() => _timeAlloc[e.key] = v!),
              validator: (v) => v == null ? 'Select value' : null,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ],
    ),
  );

  List<Step> get _steps => [
    Step(
      title: const Text('Hours & Students'),
      content: _buildStep1Hours(),
      isActive: _currentStep >= 0,
      state: _currentStep > 0 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: const Text('Student Demographics'),
      content: _buildStep2Ethnicity(),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: const Text('Topics & Outcomes'),
      content: _buildStep3Topics(),
      isActive: _currentStep >= 2,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: const Text('Faculty Demographics'),
      content: _buildStep4Faculty(),
      isActive: _currentStep >= 3,
      state: _currentStep > 3 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: const Text('Faculty Discussion/Outcomes'),
      content: _buildStep5FacultyTopics(),
      isActive: _currentStep >= 4,
      state: _currentStep > 4 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: const Text('Meeting & Crisis'),
      content: _buildStep6MeetingCrisis(),
      isActive: _currentStep >= 5,
      state: _currentStep > 5 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: const Text('Time Allocation'),
      content: _buildStep7TimeAllocation(),
      isActive: _currentStep >= 6,
      state: _currentStep > 6 ? StepState.complete : StepState.indexed,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    isLast ? 'Submit' : 'Next',
                    style: const TextStyle(fontWeight: FontWeight.bold),
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
                    child: const Text(
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
