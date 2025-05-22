// lib/providers/course_detail_mixin.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:nsca_daily/models/lesson.dart';
import 'package:nsca_daily/models/section.dart';
import '../models/course_detail.dart';
import '../constants.dart';
import 'shared_pref_helper.dart';

mixin CourseDetailMixin on ChangeNotifier {
  late List<CourseDetail> _courseDetailsItems;

  Future<void> fetchCourseDetailById(int courseId) async {
    final authToken = await SharedPreferenceHelper().getAuthToken();
    var url = '$BASE_URL/api/course_details_by_id?course_id=$courseId';
    if (authToken != null && authToken.isNotEmpty) {
      url += '&auth_token=$authToken';
    }

    final response = await http.get(Uri.parse(url));
    final extracted = json.decode(response.body) as List;
    if (extracted.isEmpty) return;

    // Aquí reutilizas tu lógica existente de Courses para construir CourseDetail
    final List<CourseDetail> loaded = [];
    for (var data in extracted) {
      loaded.add(
        CourseDetail(
          courseId: int.parse(data['id']),
          courseIncludes: List<String>.from(data['includes']),
          courseRequirements: List<String>.from(data['requirements']),
          courseOutcomes: List<String>.from(data['outcomes']),
          isWishlisted: data['is_wishlisted'],
          isPurchased:
              data['is_purchased'] is int
                  ? data['is_purchased'] == 1
                  : data['is_purchased'],
          mSection:
              (data['sections'] as List).map((s) {
                return Section(
                  id: int.parse(s['id']),
                  numberOfCompletedLessons: s['completed_lesson_number'],
                  title: s['title'],
                  totalDuration: s['total_duration'],
                  lessonCounterEnds: s['lesson_counter_ends'],
                  lessonCounterStarts: s['lesson_counter_starts'],
                  mLesson:
                      (s['lessons'] as List).map((l) {
                        return Lesson(
                          id: int.parse(l['id']),
                          title: l['title'],
                          duration: l['duration'],
                          lessonType: l['lesson_type'],
                          isFree: l['is_free'],
                          videoUrl: l['video_url'],
                          summary: l['summary'],
                          attachmentType: l['attachment_type'],
                          attachment: l['attachment'],
                          attachmentUrl: l['attachment_url'],
                          isCompleted: l['is_completed'].toString(),
                          videoUrlWeb: l['video_url_web'],
                          videoTypeWeb: l['video_type_web'],
                          vimeoVideoId: l['vimeo_video_id'],
                        );
                      }).toList(),
                );
              }).toList(),
        ),
      );
    }

    _courseDetailsItems = loaded;
    notifyListeners();
  }

  CourseDetail get getCourseDetail => _courseDetailsItems.first;
}
