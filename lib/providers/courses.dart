import 'dart:convert';
import 'dart:io';
import 'package:nsca_daily/providers/course_detail_mixin.dart';

import '../models/course.dart';
import '../models/course_detail.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../constants.dart';
import 'shared_pref_helper.dart';

class Courses with ChangeNotifier, CourseDetailMixin {
  List<Course> _items = [];
  List<Course> _topItems = [];
  List<CourseDetail> _courseDetailsitems = [];

  Courses(this._items, this._topItems);

  List<Course> get items {
    return [..._items];
  }

  List<Course> get topItems {
    return [..._topItems];
  }

  /*CourseDetail get getCourseDetail {
    return _courseDetailsitems.first;
  }*/

  int get itemCount {
    return _items.length;
  }

  Course findById(int id) {
    // Primero intenta en _items
    for (var c in _items) {
      if (c.id == id) return c;
    }
    // Luego en _topItems
    for (var c in _topItems) {
      if (c.id == id) return c;
    }
    // Si no existe, lanza con mensaje claro o devuelve un placeholder
    throw StateError('Course with id $id not found.');
  }

  Future<void> fetchTopCourses() async {
    final url = Uri.parse('$BASE_URL/api/top_courses');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final extractedData = json.decode(response.body) as List;
        _topItems = buildCourseList(extractedData);
        notifyListeners();
      } else {
        debugPrint('Top courses: statusCode = ${response.statusCode}');
      }
    } on SocketException catch (e) {
      debugPrint('No hay conexión de red: $e');
    } on FormatException catch (e) {
      debugPrint('Respuesta inválida: $e');
    } catch (e) {
      debugPrint('Error inesperado al fetchTopCourses: $e');
    }
  }

  Future<void> fetchCoursesByCategory(int categoryId) async {
    var url = '$BASE_URL/api/category_wise_course?category_id=$categoryId';
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as List;
      // ignore: unnecessary_null_comparison
      if (extractedData == null) {
        return;
      }
      // debugPrint(extractedData);

      _items = buildCourseList(extractedData);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchCoursesBySearchQuery(String searchQuery) async {
    var url =
        '$BASE_URL/api/courses_by_search_string?search_string=$searchQuery';
    // debugPrint(url);
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as List;
      // ignore: unnecessary_null_comparison
      if (extractedData == null) {
        return;
      }
      // debugPrint(extractedData);

      _items = buildCourseList(extractedData);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> filterCourses(
    String selectedCategory,
    String selectedPrice,
    String selectedLevel,
    String selectedLanguage,
    String selectedRating,
  ) async {
    var url =
        '$BASE_URL/api/filter_course?selected_category=$selectedCategory&selected_price=$selectedPrice&selected_level=$selectedLevel&selected_language=$selectedLanguage&selected_rating=$selectedRating&selected_search_string=';
    // debugPrint(url);
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as List;
      // ignore: unnecessary_null_comparison
      if (extractedData == null) {
        return;
      }
      // debugPrint(extractedData);

      _items = buildCourseList(extractedData);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> fetchMyWishlist() async {
    var authToken = await SharedPreferenceHelper().getAuthToken();
    var url = '$BASE_URL/api/my_wishlist?auth_token=$authToken';
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as List;
      // ignore: unnecessary_null_comparison
      if (extractedData == null) {
        return;
      }
      // debugPrint(extractedData);
      _items = buildCourseList(extractedData);
      // debugPrint(_items);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  List<Course> buildCourseList(List extractedData) {
    final List<Course> loadedCourses = [];
    for (var courseData in extractedData) {
      loadedCourses.add(
        Course(
          id: int.parse(courseData['id']),
          title: courseData['title'],
          thumbnail: courseData['thumbnail'],
          price: courseData['price'],
          isFreeCourse: courseData['is_free_course'],
          instructor: courseData['instructor_name'],
          instructorImage: courseData['instructor_image'],
          rating: courseData['rating'],
          totalNumberRating: courseData['number_of_ratings'],
          numberOfEnrollment: courseData['total_enrollment'],
          shareableLink: courseData['shareable_link'],
          courseOverviewProvider: courseData['course_overview_provider'],
          courseOverviewUrl: courseData['video_url'],
          vimeoVideoId: courseData['vimeo_video_id'],
        ),
      );
      // debugPrint(catData['name']);
    }
    return loadedCourses;
  }

  Future<void> toggleWishlist(int courseId, bool removeItem) async {
    var authToken = await SharedPreferenceHelper().getAuthToken();
    var url =
        '$BASE_URL/api/toggle_wishlist_items?auth_token=$authToken&course_id=$courseId';
    if (!removeItem) {
      _courseDetailsitems.first.isWishlisted!
          ? _courseDetailsitems.first.isWishlisted = false
          : _courseDetailsitems.first.isWishlisted = true;
      notifyListeners();
    }
    try {
      final response = await http.get(Uri.parse(url));
      final responseData = json.decode(response.body);
      if (responseData['status'] == 'removed') {
        if (removeItem) {
          final existingMyCourseIndex = _items.indexWhere(
            (mc) => mc.id == courseId,
          );

          _items.removeAt(existingMyCourseIndex);
          notifyListeners();
        } else {
          _courseDetailsitems.first.isWishlisted = false;
        }
      } else if (responseData['status'] == 'added') {
        if (!removeItem) {
          _courseDetailsitems.first.isWishlisted = true;
        }
      }
      // notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> getEnrolled(int courseId) async {
    final authToken = await SharedPreferenceHelper().getAuthToken();
    var url =
        '$BASE_URL/api/enroll_free_course?course_id=$courseId&auth_token=$authToken';
    try {
      final response = await http.get(Uri.parse(url));
      final responseData = json.decode(response.body);
      if (responseData['message'] == 'success') {
        _courseDetailsitems.first.isPurchased = true;

        notifyListeners();
      }
    } catch (error) {
      rethrow;
    }
  }
}
