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
    child: Padding(
      padding: const EdgeInsets.only(top: 8.0),
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
                child: DropdownButtonFormField<int?>(
                  decoration: _inputDecoration('Male'),
                  items: [
                    // Opción vacía:
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
                  onChanged: (v) => setState(() => _studentsMale = v),
                  validator: (v) {
                    final total = _studentsTotal;
                    final female = _studentsFemale;
                    // 1) Total obligatorio
                    if (total == null) return 'Select total first';
                    // 2) Caso “todos mujeres”: male puede ser null si female == total
                    if (v == null && female == total) return null;
                    // 3) Ambos no nulos: suma debe coincidir
                    if (v != null && female != null) {
                      return (v + female == total)
                          ? null
                          : 'Male + Female must equal total';
                    }
                    // 4) Caso “todos hombres”: male == total
                    if (v != null && female == null) {
                      return (v == total) ? null : 'Sum must equal total';
                    }
                    // 5) Si llegamos aquí, falta info de ambos o suma incorrecta
                    return 'Required or match total';
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int?>(
                  decoration: _inputDecoration('Female'),
                  items: [
                    // Opción vacía:
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
                  onChanged: (v) => setState(() => _studentsFemale = v),
                  validator: (v) {
                    final total = _studentsTotal;
                    final male = _studentsMale;
                    if (total == null) return 'Select total first';
                    if (v == null && male == total) return null;
                    if (v != null && male != null) {
                      return (v + male == total)
                          ? null
                          : 'Male + Female must equal total';
                    }
                    if (v != null && male == null) {
                      return (v == total) ? null : 'Sum must equal total';
                    }
                    return 'Required or match total';
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _buildStep2Ethnicity() => Form(
    key: _stepKeys[1],
    child: Padding(
      padding: const EdgeInsets.only(top: 8.0),
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
              DropdownButtonFormField<int?>(
                decoration: _inputDecoration(e.value),
                items: [
                  // Opción vacía:
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('None'),
                  ),
                  ...List.generate(
                    50,
                    (i) => i + 1,
                  ).map((v) => DropdownMenuItem(value: v, child: Text('$v'))),
                ],
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
    ),
  );

  Widget _buildStep3Topics() => Form(
    key: _stepKeys[2],
    child: Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Discussion Topics',
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
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Outcomes',
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
    ),
  );

  Widget _buildStep4Faculty() => Form(
    key: _stepKeys[3],
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
          ...getFacultyOrStaffGroups().entries.expand<Widget>(
            (e) => [
              DropdownButtonFormField<int?>(
                decoration: _inputDecoration(e.value),
                items: [
                  // Opción vacía:
                  const DropdownMenuItem<int?>(
                    value: null,
                    child: Text('None'),
                  ),
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

  Widget _buildStep5FacultyTopics() => Form(
    key: _stepKeys[4],
    child: Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Discussion Topics',
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
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Faculty Outcomes',
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
    ),
  );

  Widget _buildStep6MeetingCrisis() => Form(
    key: _stepKeys[5],
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

  Widget _buildStep7TimeAllocation() => Form(
    key: _stepKeys[6],
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
