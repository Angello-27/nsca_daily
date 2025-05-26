// lib/models/daily_report.dart

/// Modelo que representa la estructura de un reporte diario.
class DailyReport {
  final DateTime reportDate;
  final int workingHours;
  final int studentsMale;
  final int studentsFemale;
  final String? averageAge;
  final Map<String, int> ethnicStudents;
  final List<String> studentTopics;
  final List<String> studentOutcomes;
  final int facultyTotal;
  final Map<String, int> teacherReport;
  final Map<String, int> facultyStaff;
  final Map<String, int> ethnicTeachers;
  final List<String> facultyTopics;
  final List<String> facultyOutcomes;
  final bool metParent;
  final bool crisisToday;
  final List<String> crisisTypes;
  final Map<String, int> percentageByTopic;
  final int created;

  DailyReport({
    required this.reportDate,
    required this.workingHours,
    required this.studentsMale,
    required this.studentsFemale,
    this.averageAge,
    Map<String, int>? ethnicStudents,
    List<String>? studentTopics,
    List<String>? studentOutcomes,
    required this.facultyTotal,
    Map<String, int>? teacherReport,
    Map<String, int>? facultyStaff,
    Map<String, int>? ethnicTeachers,
    List<String>? facultyTopics,
    List<String>? facultyOutcomes,
    required this.metParent,
    required this.crisisToday,
    List<String>? crisisTypes,
    Map<String, int>? percentageByTopic,
    this.created = 1,
  }) : ethnicStudents = ethnicStudents ?? {},
       studentTopics = studentTopics ?? [],
       studentOutcomes = studentOutcomes ?? [],
       teacherReport = teacherReport ?? {},
       facultyStaff = facultyStaff ?? {},
       ethnicTeachers = ethnicTeachers ?? {},
       facultyTopics = facultyTopics ?? [],
       facultyOutcomes = facultyOutcomes ?? [],
       crisisTypes = crisisTypes ?? [],
       percentageByTopic = percentageByTopic ?? {};

  factory DailyReport.fromJson(Map<String, dynamic> json) {
    return DailyReport(
      reportDate: DateTime.parse(json['report_date'] as String),
      workingHours: json['working'] as int,
      studentsMale: json['students']['male'] as int,
      studentsFemale: json['students']['female'] as int,
      averageAge: json['average_age'] as String?,
      ethnicStudents: Map<String, int>.from(json['ethnic']['student'] ?? {}),
      studentTopics: List<String>.from(json['topics']['student'] ?? []),
      studentOutcomes: List<String>.from(json['outcomes']['student'] ?? []),
      facultyTotal:
          json['faculty'] is Map
              ? (json['faculty']['total'] as int)
              : (json['faculty_total'] as int),
      teacherReport: Map<String, int>.from(json['teachers'] ?? {}),
      facultyStaff: Map<String, int>.from(
        json['faculty'] is Map ? json['faculty']['staff'] : json['faculty'],
      ),
      ethnicTeachers: Map<String, int>.from(json['ethnic']['teacher'] ?? {}),
      facultyTopics: List<String>.from(json['topics']['teacher'] ?? []),
      facultyOutcomes: List<String>.from(json['outcomes']['teacher'] ?? []),
      metParent: (json['parent_meeting'] as int) == 1,
      crisisToday: (json['crisis_today'] as int) == 1,
      crisisTypes: List<String>.from(json['crisis_types'] ?? []),
      percentageByTopic: Map<String, int>.from(json['percentage'] ?? {}),
      created: json['created'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'created': created,
      'report_date': reportDate.toIso8601String().split('T').first,
      'working': workingHours,
      'students': {'male': studentsMale, 'female': studentsFemale},
      'average_age': averageAge,
      'teachers': teacherReport,
      'faculty': facultyStaff,
      'ethnic': {'student': ethnicStudents, 'teacher': ethnicTeachers},
      'topics': {'student': studentTopics, 'teacher': facultyTopics},
      'outcomes': {'student': studentOutcomes, 'teacher': facultyOutcomes},
      'parent_meeting': metParent ? 1 : 0,
      'crisis_today': crisisToday ? 1 : 0,
      'crisis_types': crisisTypes,
      'percentage': percentageByTopic,
    };
  }
}
