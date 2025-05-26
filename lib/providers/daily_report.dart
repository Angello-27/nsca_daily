// lib/providers/daily_report_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'shared_pref_helper.dart';

class DailyReportProvider with ChangeNotifier {
  // 1) Estado de formulario
  DateTime reportDate = DateTime.now();
  int? workingHours;

  int? studentsMale;
  int? studentsFemale;

  String? averageAge;
  final Map<String, int> ethnicStudents = {};

  final Set<String> studentTopics = {};
  final Set<String> studentOutcomes = {};

  int? facultyTotal;
  final Map<String, int> teacherReport = {}; // 'teachers'
  final Map<String, int> facultyStaff = {}; // 'faculty'

  final Map<String, int> ethnicTeachers = {};

  final Set<String> facultyTopics = {};
  final Set<String> facultyOutcomes = {};

  bool metParent = false;
  bool crisisToday = false;
  final Set<String> crisisTypes = {};

  final Map<String, int> percentageByTopic = {};

  int created = 1; // enviar siempre 1 para crear

  // 2) Métodos para actualizar estado
  void setDate(DateTime d) {
    reportDate = d;
    notifyListeners();
  }

  void setWorkingHours(int h) {
    workingHours = h;
    notifyListeners();
  }

  void setStudentsMale(int? m) {
    studentsMale = m;
    notifyListeners();
  }

  void setStudentsFemale(int? f) {
    studentsFemale = f;
    notifyListeners();
  }

  void setAverageAge(String? a) {
    averageAge = a;
    notifyListeners();
  }

  void setEthnicStudent(String key, int? v) {
    ethnicStudents[key] = v ?? 0;
    notifyListeners();
  }

  void toggleStudentTopic(String k, bool sel) {
    sel ? studentTopics.add(k) : studentTopics.remove(k);
    notifyListeners();
  }

  void toggleStudentOutcome(String k, bool sel) {
    sel ? studentOutcomes.add(k) : studentOutcomes.remove(k);
    notifyListeners();
  }

  void setFacultyTotal(int t) {
    facultyTotal = t;
    notifyListeners();
  }

  void setTeacherReportMany(int t) {
    teacherReport['many'] = t;
    notifyListeners();
  }

  void setFacultyStaff(String k, int? v) {
    facultyStaff[k] = v ?? 0;
    notifyListeners();
  }

  void setEthnicTeacher(String key, int? v) {
    ethnicTeachers[key] = v ?? 0;
    notifyListeners();
  }

  void toggleFacultyTopic(String k, bool sel) {
    sel ? facultyTopics.add(k) : facultyTopics.remove(k);
    notifyListeners();
  }

  void toggleFacultyOutcome(String k, bool sel) {
    sel ? facultyOutcomes.add(k) : facultyOutcomes.remove(k);
    notifyListeners();
  }

  void setMetParent(bool v) {
    metParent = v;
    notifyListeners();
  }

  void setCrisisToday(bool v) {
    crisisToday = v;
    if (!v) crisisTypes.clear();
    notifyListeners();
  }

  void toggleCrisisType(String k, bool sel) {
    sel ? crisisTypes.add(k) : crisisTypes.remove(k);
    notifyListeners();
  }

  void setPercentage(String key, int? v) {
    percentageByTopic[key] = v ?? 0;
    notifyListeners();
  }

  // 3) Construye el payload que espera tu API
  Map<String, dynamic> _buildPayload() {
    return {
      'auth_token': '', // lo pondremos en submit()
      'created': created,
      'report_date': reportDate.toIso8601String().split('T').first,
      'working': workingHours ?? 0,
      'students': {'male': studentsMale ?? 0, 'female': studentsFemale ?? 0},
      'teachers': teacherReport,
      'faculty': facultyStaff,
      'ethnic': {'student': ethnicStudents, 'teacher': ethnicTeachers},
      'topics': {
        'student': studentTopics.toList(),
        'teacher': facultyTopics.toList(),
      },
      'outcomes': {
        'student': studentOutcomes.toList(),
        'teacher': facultyOutcomes.toList(),
      },
      'parent_meeting': metParent ? 1 : 0,
      'crisis_today': crisisToday ? 1 : 0,
      'crisis_types': crisisTypes.toList(),
      'percentage': percentageByTopic,
    };
  }

  /// 4) Llama a la API para crear o actualizar el reporte
  Future<void> submitReport() async {
    final token = await SharedPreferenceHelper().getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token');
    }
    final url = Uri.parse('$BASE_URL/api/daily_report');
    final payload = _buildPayload()..['auth_token'] = token;

    final response = await http.post(url, body: payload);
    final data = json.decode(response.body);
    if (data['status'] != 'success') {
      throw Exception(data['error_reason'] ?? 'Unknown error');
    }
    // si quieres guardar el report_id:
    final int reportId = data['report_id'];
    debugPrint('El nuevo Reporte Diario: $reportId');
    // … quizás navigate o mostrar mensaje …
  }
}
