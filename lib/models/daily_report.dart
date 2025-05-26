// lib/models/daily_report.dart

class DailyReport {
  final DateTime reportDate;
  final int workingHours;

  // Del formulario web:
  final int studentsMany;
  final int studentsMale;
  final int studentsFemale;
  final String? averageAge;
  final Map<String, int> ethnicStudents;
  final List<String> studentTopics;
  final List<String> studentOutcomes;

  final int teachersMany;
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
    required this.studentsMany,
    required this.studentsMale,
    required this.studentsFemale,
    this.averageAge,
    Map<String, int>? ethnicStudents,
    List<String>? studentTopics,
    List<String>? studentOutcomes,
    required this.teachersMany,
    Map<String, int>? facultyStaff,
    Map<String, int>? teacherReport,
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

      // aquí mapeamos students[...] → propiedades
      studentsMany: json['students']['many'] as int,
      studentsMale: json['students']['male'] as int,
      studentsFemale: json['students']['female'] as int,
      averageAge: json['students']['ages'] as String?,

      ethnicStudents: Map<String, int>.from(json['ethnic']['student'] ?? {}),
      studentTopics: List<String>.from(json['topics']['student'] ?? []),
      studentOutcomes: List<String>.from(json['outcomes']['student'] ?? []),

      // aquí mapeamos teachers[...] → propiedades
      teachersMany: json['teachers']['many'] as int,

      facultyStaff: Map<String, int>.from(json['faculty'] ?? {}),
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

      // así enviará exactamente lo que espera tu API PHP:
      'students': {
        'many': studentsMany,
        'male': studentsMale,
        'female': studentsFemale,
        'ages': averageAge,
      },
      'ethnic': {'student': ethnicStudents, 'teacher': ethnicTeachers},
      'topics': {'student': studentTopics, 'teacher': facultyTopics},
      'outcomes': {'student': studentOutcomes, 'teacher': facultyOutcomes},

      'teachers': {'many': teachersMany},
      'faculty': facultyStaff,

      'parent_meeting': metParent ? 1 : 0,
      'crisis_today': crisisToday ? 1 : 0,
      'crisis_types': crisisTypes,

      'percentage': percentageByTopic,
    };
  }
}
