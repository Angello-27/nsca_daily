// lib/providers/daily_report_provider.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'shared_pref_helper.dart';
import '../models/daily_report.dart';

class DailyReportProvider with ChangeNotifier {
  // Estado del formulario
  DateTime reportDate = DateTime.now();
  int? workingHours;

  // Estudiantes
  int studentsMany = 0;
  int? studentsMale;
  int? studentsFemale;
  String? averageAge;
  final Map<String, int> ethnicStudents = {};
  final Set<String> studentTopics = {};
  final Set<String> studentOutcomes = {};

  // Personal académico
  int? teachersMany;
  final Map<String, int> facultyStaff = {};
  final Map<String, int> ethnicTeachers = {};
  final Set<String> facultyTopics = {};
  final Set<String> facultyOutcomes = {};

  // Reunión y crisis
  bool metParent = false;
  bool crisisToday = false;
  final Set<String> crisisTypes = {};

  // Tiempo asignado
  final Map<String, int> percentageByTopic = {};

  int created = 1; // siempre 1 para crear

  // Métodos para actualizar estado
  void setDate(DateTime d) {
    reportDate = d;
    notifyListeners();
  }

  void setWorkingHours(int? h) {
    workingHours = h;
    notifyListeners();
  }

  void setStudentsMany(int m) {
    studentsMany = m;
    notifyListeners();
  }

  // Estudiantes: al cambiar male/female recalcula studentsMany
  void setStudentsMale(int? m) {
    studentsMale = m;
    _updateStudentsMany();
    notifyListeners();
  }

  void setStudentsFemale(int? f) {
    studentsFemale = f;
    _updateStudentsMany();
    notifyListeners();
  }

  // studentsMany se calcula internamente
  void _updateStudentsMany() {
    studentsMany = (studentsMale ?? 0) + (studentsFemale ?? 0);
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

  void setTeachersMany(int? t) {
    teachersMany = t;
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

  /// Envía el reporte usando el modelo DailyReport
  Future<void> submitReport() async {
    final token = await SharedPreferenceHelper().getAuthToken();
    if (token == null || token.isEmpty) {
      throw Exception('No auth token disponible');
    }

    final url = Uri.parse('$BASE_URL/api/daily_report');

    // Construye la instancia del modelo
    final report = DailyReport(
      reportDate: reportDate,
      workingHours: workingHours ?? 0,
      studentsMany: studentsMany,
      studentsMale: studentsMale ?? 0,
      studentsFemale: studentsFemale ?? 0,
      averageAge: averageAge,
      ethnicStudents: ethnicStudents,
      studentTopics: studentTopics.toList(),
      studentOutcomes: studentOutcomes.toList(),
      teachersMany: teachersMany ?? 0,
      facultyStaff: facultyStaff,
      ethnicTeachers: ethnicTeachers,
      facultyTopics: facultyTopics.toList(),
      facultyOutcomes: facultyOutcomes.toList(),
      metParent: metParent,
      crisisToday: crisisToday,
      crisisTypes: crisisTypes.toList(),
      percentageByTopic: percentageByTopic,
      created: created,
    );

    // Serializa a JSON y añade el token
    final payload = report.toJson()..['auth_token'] = token;

    final response = await http.post(url, body: payload);
    final data = json.decode(response.body);

    if (data['status'] != 'success') {
      throw Exception(data['error_reason'] ?? 'Error desconocido');
    }

    final int reportId = data['report_id'];
    debugPrint('Reporte diario creado con ID: $reportId');
  }
}
