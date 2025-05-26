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
  late final TextEditingController _totalController;

  // Date
  DateTime? _reportDate;

  // Student data
  // Hours & students
  int? _workingHours;
  int? _studentsMale;
  int? _studentsFemale;
  int? _studentsTotal;
  // Student ethnicity
  String? _studentsAge;
  final Map<String, int> _studentEthnic = {};
  // Student topics & outcomes
  final Set<String> _studentTopics = {};
  final Set<String> _studentOutcomes = {};

  // Faculty data
  // Faculty total, breakdown & ethnicity
  int? _facultyTotal;
  final Map<String, int> _facultyGroups = {};
  final Map<String, int> _facultyEthnic = {};
  // Faculty topics & outcomes
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
    _reportDate = DateTime.now();
    _totalController = TextEditingController(text: '0');
    _stepKeys = List.generate(11, (_) => GlobalKey<FormState>());
  }

  @override
  void dispose() {
    _totalController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _reportDate!,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _reportDate = d);
  }

  void _onStepContinue() {
    if (_currentStep < _steps.length - 1) {
      // Validate only current step
      final form = _stepKeys[_currentStep].currentState;
      if (form == null || form.validate()) {
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

  void _updateTotals() {
    final sum = (_studentsMale ?? 0) + (_studentsFemale ?? 0);
    setState(() {
      _studentsTotal = sum;
      _totalController.text = '$sum';
    });
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

  // Step builders
  Widget _buildStep0Date() => Form(
    key: _stepKeys[0],
    child: Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: ListTile(
        title: const Text('Report Date'),
        subtitle: Text(
          '${_reportDate!.year}-${_reportDate!.month.toString().padLeft(2, '0')}-${_reportDate!.day.toString().padLeft(2, '0')}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.calendar_today),
          color: kPrimaryColor,
          onPressed: _pickDate,
        ),
      ),
    ),
  );

  Widget _buildStep1Hours() => Form(
    key: _stepKeys[1],
    child: Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int?>(
                  decoration: _inputDecoration('Male'),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('None'),
                    ),
                    ...List.generate(
                      50,
                      (i) => i + 1,
                    ).map((v) => DropdownMenuItem(value: v, child: Text('$v'))),
                  ],
                  value: _studentsMale,
                  onChanged: (v) {
                    setState(() {
                      _studentsMale = v;
                      _updateTotals();
                    });
                  },
                  validator: (_) {
                    if (_studentsMale == null && _studentsFemale == null) {
                      return 'Select male or female';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int?>(
                  decoration: _inputDecoration('Female'),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('None'),
                    ),
                    ...List.generate(
                      50,
                      (i) => i + 1,
                    ).map((v) => DropdownMenuItem(value: v, child: Text('$v'))),
                  ],
                  value: _studentsFemale,
                  onChanged: (v) {
                    setState(() {
                      _studentsFemale = v;
                      _updateTotals();
                    });
                  },
                  validator: (_) {
                    if (_studentsMale == null && _studentsFemale == null) {
                      return 'Select male or female';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            readOnly: true,
            controller: _totalController,
            decoration: _inputDecoration('Total Students'),
          ),
        ],
      ),
    ),
  );

  Widget _buildStep2StudentEthnic() => Form(
    key: _stepKeys[2],
    child: Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            decoration: _inputDecoration('Average Age'),
            items:
                getAgeGroups().entries
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                    )
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
              DropdownButtonFormField<int?>(
                decoration: _inputDecoration(e.value),
                items: [
                  // Opción vacía:
                  const DropdownMenuItem<int?>(value: 0, child: Text('None')),
                  ...List.generate(
                    50,
                    (i) => i + 1,
                  ).map((v) => DropdownMenuItem(value: v, child: Text('$v'))),
                ],
                value: _studentEthnic[e.key],
                onChanged: (v) => setState(() => _studentEthnic[e.key] = v!),
                validator: (v) {
                  final sum = _studentEthnic.values.fold(0, (s, x) => s + x);
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
    ),
  );

  Widget _buildStep3StudentTopics() => Form(
    key: _stepKeys[3],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mark all topics',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Checkbox(
              // Si todos los elementos están seleccionados:
              value: _studentTopics.length == getDiscussionTopics().length,
              onChanged: (all) {
                setState(() {
                  if (all == true) {
                    _studentTopics.clear();
                    _studentTopics.addAll(getDiscussionTopics().keys);
                  } else {
                    _studentTopics.clear();
                  }
                });
              },
            ),
          ],
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
        // --- Invisible FormField que valida al menos 1 Topic ---
        FormField<bool>(
          initialValue: _studentTopics.isNotEmpty,
          validator: (_) {
            return _studentTopics.isEmpty
                ? 'Please select at least one topic'
                : null;
          },
          builder: (state) {
            return state.hasError
                ? Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: Text(
                    state.errorText!,
                    style: TextStyle(color: kRedColor),
                  ),
                )
                : const SizedBox.shrink();
          },
        ),
      ],
    ),
  );

  Widget _buildStep4StudentOutcomes() => Form(
    key: _stepKeys[4],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mark all outcomes',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Checkbox(
              // Si todos los elementos están seleccionados:
              value: _studentOutcomes.length == getOutcomes().length,
              onChanged: (all) {
                setState(() {
                  if (all == true) {
                    _studentOutcomes.clear();
                    _studentOutcomes.addAll(getOutcomes().keys);
                  } else {
                    _studentOutcomes.clear();
                  }
                });
              },
            ),
          ],
        ),
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
        // --- Invisible FormField que valida al menos 1 Outcome ---
        FormField<bool>(
          initialValue: _studentOutcomes.isNotEmpty,
          validator: (_) {
            return _studentOutcomes.isEmpty
                ? 'Please select at least one outcome'
                : null;
          },
          builder: (state) {
            return state.hasError
                ? Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: Text(
                    state.errorText!,
                    style: TextStyle(color: kRedColor),
                  ),
                )
                : const SizedBox.shrink();
          },
        ),
      ],
    ),
  );

  Widget _buildStep5Faculty() => Form(
    key: _stepKeys[5],
    child: Padding(
      padding: const EdgeInsets.only(top: 8.0),
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
          const Text(
            'Breakdown by Role:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const Divider(),
          ...getFacultyOrStaffGroups().entries.expand<Widget>(
            (e) => [
              DropdownButtonFormField<int?>(
                decoration: _inputDecoration(e.value),
                items: [
                  // Opción vacía:
                  const DropdownMenuItem<int?>(value: 0, child: Text('None')),
                  ...List.generate(
                    50,
                    (i) => i + 1,
                  ).map((v) => DropdownMenuItem(value: v, child: Text('$v'))),
                ],
                value: _facultyGroups[e.key],
                onChanged: (v) => setState(() => _facultyGroups[e.key] = v!),
                validator: (v) {
                  final sum = _facultyGroups.values.fold(0, (s, x) => s + x);
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
    ),
  );

  Widget _buildStep6FacultyEthnic() => Form(
    key: _stepKeys[6],
    child: Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...getEthnicGroups().entries.expand<Widget>(
            (e) => [
              DropdownButtonFormField<int?>(
                decoration: _inputDecoration(e.value),
                items: [
                  // Opción vacía:
                  const DropdownMenuItem<int?>(value: 0, child: Text('None')),
                  ...List.generate(
                    50,
                    (i) => i + 1,
                  ).map((v) => DropdownMenuItem(value: v, child: Text('$v'))),
                ],
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
    ),
  );

  Widget _buildStep7FacultyTopics() => Form(
    key: _stepKeys[7],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mark all topics',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Checkbox(
              // Si todos los elementos están seleccionados:
              value: _facultyTopics.length == getDiscussionTopics().length,
              onChanged: (all) {
                setState(() {
                  if (all == true) {
                    _facultyTopics.clear();
                    _facultyTopics.addAll(getDiscussionTopics().keys);
                  } else {
                    _facultyTopics.clear();
                  }
                });
              },
            ),
          ],
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
        // --- Invisible FormField que valida al menos 1 Topic ---
        FormField<bool>(
          initialValue: _facultyTopics.isNotEmpty,
          validator: (_) {
            return _facultyTopics.isEmpty
                ? 'Please select at least one topic'
                : null;
          },
          builder: (state) {
            return state.hasError
                ? Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: Text(
                    state.errorText!,
                    style: TextStyle(color: kRedColor),
                  ),
                )
                : const SizedBox.shrink();
          },
        ),
      ],
    ),
  );

  Widget _buildStep8FacultyOutcomes() => Form(
    key: _stepKeys[8],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mark all outcomes',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Checkbox(
              // Si todos los elementos están seleccionados:
              value: _facultyOutcomes.length == getOutcomes().length,
              onChanged: (all) {
                setState(() {
                  if (all == true) {
                    _facultyOutcomes.clear();
                    _facultyOutcomes.addAll(getOutcomes().keys);
                  } else {
                    _facultyOutcomes.clear();
                  }
                });
              },
            ),
          ],
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
        // --- Invisible FormField que valida al menos 1 Outcome ---
        FormField<bool>(
          initialValue: _facultyOutcomes.isNotEmpty,
          validator: (_) {
            return _facultyOutcomes.isEmpty
                ? 'Please select at least one outcome'
                : null;
          },
          builder: (state) {
            return state.hasError
                ? Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: Text(
                    state.errorText!,
                    style: TextStyle(color: kRedColor),
                  ),
                )
                : const SizedBox.shrink();
          },
        ),
      ],
    ),
  );

  Widget _buildStep9MeetingCrisis() => Form(
    key: _stepKeys[9],
    child: Padding(
      padding: const EdgeInsets.only(top: 8.0),
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
            onChanged:
                (v) => setState(() {
                  _crisisToday = v;
                  _crisisTypes.clear();
                }),
          ),
          if (_crisisToday) ...[
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Crisis Types',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Checkbox(
                  // Si todos los elementos están seleccionados:
                  value: _crisisTypes.length == getCrisisTypes().length,
                  onChanged: (all) {
                    setState(() {
                      if (all == true) {
                        _crisisTypes.clear();
                        _crisisTypes.addAll(getCrisisTypes().keys);
                      } else {
                        _crisisTypes.clear();
                      }
                    });
                  },
                ),
              ],
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
            // Este FormField valida que haya al menos uno marcado
            FormField<bool>(
              initialValue: _crisisTypes.isNotEmpty,
              validator: (_) {
                if (_crisisToday && _crisisTypes.isEmpty) {
                  return 'Please select at least one crisis type';
                }
                return null;
              },
              builder: (state) {
                if (!state.hasError) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text(
                    state.errorText!,
                    style: TextStyle(color: kRedColor),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    ),
  );

  Widget _buildStep10TimeAllocation() => Form(
    key: _stepKeys[10],
    child: Padding(
      padding: const EdgeInsets.only(top: 8.0),
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
                    List.generate(100, (i) => 100 - i)
                        .map(
                          (v) => DropdownMenuItem(value: v, child: Text('$v')),
                        )
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
    ),
  );

  List<Step> get _steps => [
    Step(
      title: const Text('Date'),
      content: _buildStep0Date(),
      isActive: _currentStep >= 0,
    ),
    Step(
      title: const Text('Hours & Students'),
      content: _buildStep1Hours(),
      isActive: _currentStep >= 1,
      state: _currentStep > 1 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: const Text('Student Ethnicity'),
      content: _buildStep2StudentEthnic(),
      isActive: _currentStep >= 2,
      state: _currentStep > 2 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: const Text('Student Topics'),
      content: _buildStep3StudentTopics(),
      isActive: _currentStep >= 3,
      state: _currentStep > 3 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: const Text('Student Outcomes'),
      content: _buildStep4StudentOutcomes(),
      isActive: _currentStep >= 4,
      state: _currentStep > 4 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: const Text('Faculty Demographics'),
      content: _buildStep5Faculty(),
      isActive: _currentStep >= 5,
      state: _currentStep > 5 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: const Text('Faculty Ethnicity'),
      content: _buildStep6FacultyEthnic(),
      isActive: _currentStep >= 6,
      state: _currentStep > 6 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: const Text('Faculty Topics'),
      content: _buildStep7FacultyTopics(),
      isActive: _currentStep >= 7,
      state: _currentStep > 7 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: const Text('Faculty Outcomes'),
      content: _buildStep8FacultyOutcomes(),
      isActive: _currentStep >= 8,
      state: _currentStep > 8 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: const Text('Meeting & Crisis'),
      content: _buildStep9MeetingCrisis(),
      isActive: _currentStep >= 9,
      state: _currentStep > 9 ? StepState.complete : StepState.indexed,
    ),
    Step(
      title: const Text('Time Allocation'),
      content: _buildStep10TimeAllocation(),
      isActive: _currentStep >= 10,
      state: _currentStep > 10 ? StepState.complete : StepState.indexed,
    ),
  ];

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
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
            primary: kPrimaryColor, // para iconos y líneas activas
            secondary: kSecondaryColor, // a veces usado para el acento
          ),
        ),
        child: Stepper(
          type: StepperType.vertical,
          currentStep: _currentStep,
          onStepContinue: _onStepContinue,
          onStepCancel: _onStepCancel,
          controlsBuilder: (context, details) {
            final isLast = _currentStep == _steps.length - 1;
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  _buildNextButton(details, isLast),
                  const SizedBox(width: 8),
                  if (_currentStep > 0) _buildBackButton(details),
                ],
              ),
            );
          },
          steps: _steps,
        ),
      ),
    );
  }
}
