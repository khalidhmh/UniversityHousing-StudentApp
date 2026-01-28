import 'package:student_housing_app/core/services/api_service.dart';
import 'package:student_housing_app/core/services/local_db_service.dart';
import 'dart:convert';

class DataRepository {
  final ApiService _apiService;
  final LocalDBService _localDBService;

  static final DataRepository _instance = DataRepository._internal(
    ApiService(),
    LocalDBService(),
  );

  factory DataRepository() => _instance;

  DataRepository._internal(this._apiService, this._localDBService);

  // ===========================================================================
  // 1. Student Profile
  // ===========================================================================
  Future<Map<String, dynamic>> getStudentProfile() async {
    try {
      final cachedProfile = await _localDBService.getStudentProfile();
      if (cachedProfile != null) {
        _fetchAndCacheStudentProfile();
        return {'success': true, 'data': cachedProfile, 'fromCache': true};
      }
      return await _fetchAndCacheStudentProfile();
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> _fetchAndCacheStudentProfile() async {
    try {
      final apiResponse = await _apiService.get('/student/profile');
      if (apiResponse['success'] == true && apiResponse['data'] != null) {
        final profileData = apiResponse['data'];

        await _localDBService.cacheData('student_profile', [
          {
            'id': (profileData['id'] ?? '').toString(),
            'national_id': (profileData['national_id'] ?? '').toString(),
            'full_name': profileData['full_name'] ?? 'طالب',
            'room_json': profileData['room'] != null
                ? (profileData['room'] is String ? profileData['room'] : jsonEncode(profileData['room']))
                : jsonEncode({'room_no': 'غير مسكن', 'building': '---'}),
            'photo_url': ApiService.getImageUrl(profileData['photo_url']),
            'student_id': (profileData['student_id'] ?? profileData['national_id'] ?? '').toString(),
            'college': profileData['college'] ?? '',
          }
        ]);
        return {'success': true, 'data': profileData, 'fromCache': false};
      }
      return {'success': false, 'message': apiResponse['message']};
    } catch (e) {
      return {'success': false, 'message': 'API Error: $e'};
    }
  }

  // ===========================================================================
  // 2. Attendance
  // ===========================================================================
  Future<Map<String, dynamic>> getAttendance() async {
    final cached = await _localDBService.getAttendanceLogs();
    if (cached.isNotEmpty) {
      _fetchAndCacheAttendance();
      return {'success': true, 'data': cached, 'fromCache': true};
    }
    return await _fetchAndCacheAttendance();
  }

  Future<Map<String, dynamic>> _fetchAndCacheAttendance() async {
    try {
      final apiResponse = await _apiService.get('/student/attendance');
      if (apiResponse['success'] == true) {
        final attendanceList = apiResponse['data'] as List;
        final attendanceData = attendanceList.map((item) => {
          'date': item['date'] ?? '',
          'status': (item['status'] ?? 'present').toString().toLowerCase(),
        }).toList();
        await _localDBService.cacheData('attendance_cache', attendanceData);
        return {'success': true, 'data': attendanceData, 'fromCache': false};
      }
      return {'success': false, 'message': apiResponse['message']};
    } catch (e) {
      return {'success': false, 'message': '$e'};
    }
  }

  // ===========================================================================
  // 3. Activities (Fixed Logic)
  // ===========================================================================
  // --- Activities ---

  /// Get Activities with option to force API fetch
  Future<Map<String, dynamic>> getActivities({bool forceRefresh = false}) async {
    // 1. لو مش طالبين تحديث إجباري، هات من الكاش الأول
    if (!forceRefresh) {
      final cached = await _localDBService.getActivities();
      if (cached.isNotEmpty) {
        // بنشغل التحديث في الخلفية عشان المرة الجاية
        _fetchAndCacheActivities();
        return {'success': true, 'data': cached, 'fromCache': true};
      }
    }

    // 2. لو مفيش كاش أو طالبين تحديث إجباري، هات من الـ API
    return await _fetchAndCacheActivities();
  }

  Future<Map<String, dynamic>> _fetchAndCacheActivities() async {
    try {
      final response = await _apiService.get('/student/activities');

      // ✅ FIX: Check for 'data' OR 'activities' to prevent Null error
      // This handles both backend response formats
      final rawList = response['data'] ?? response['activities'];

      if (response['success'] == true && rawList != null && rawList is List) {
        final cleanedList = rawList.map((item) => {
          'id': item['id'],
          'title': item['title'] ?? 'بدون عنوان',
          'description': item['description'] ?? '',
          'category': item['category'] ?? 'عام',
          'location': item['location'] ?? '',
          // Ensure correct date mapping
          'event_date': item['event_date'] ?? item['date'] ?? '',
          'image_url': ApiService.getImageUrl(item['image_url']),
          'is_subscribed': (item['is_subscribed'] == true || item['is_subscribed'] == 1) ? 1 : 0
        }).toList();

        await _localDBService.cacheData('activities_cache', cleanedList);
        return {'success': true, 'data': cleanedList, 'fromCache': false};
      }
      return {'success': false, 'message': response['message'] ?? 'No data found'};
    } catch (e) {
      print("❌ Error fetching activities: $e");
      return {'success': false, 'message': 'API Error: $e'};
    }
  }

  // --- Activity Subscription ---

  // اشتراك
  Future<Map<String, dynamic>> subscribeToActivity(int activityId) async {
    try {
      final response = await _apiService.post(
        '/student/activities/subscribe',
        {'activity_id': activityId},
      );
      return response;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // إلغاء اشتراك
  Future<Map<String, dynamic>> unsubscribeFromActivity(int activityId) async {
    try {
      final response = await _apiService.post(
        '/student/activities/unsubscribe',
        {'activity_id': activityId},
      );
      return response;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ===========================================================================
  // 4. Announcements
  // ===========================================================================
  Future<Map<String, dynamic>> getAnnouncements() async {
    final cached = await _localDBService.getAnnouncements();
    if (cached.isNotEmpty) {
      _fetchAndCacheAnnouncements();
      return {'success': true, 'data': cached, 'fromCache': true};
    }
    return await _fetchAndCacheAnnouncements();
  }

  Future<Map<String, dynamic>> _fetchAndCacheAnnouncements() async {
    try {
      final response = await _apiService.get('/student/announcements');

      // Handle both 'data' and 'announcements' keys if needed
      final rawList = response['data'] ?? response['announcements'];

      if (response['success'] == true && rawList != null && rawList is List) {
        final cleanedList = rawList.map((item) => {
          'id': item['id'],
          'title': item['title'] ?? 'إعلان هام',
          'body': item['body'] ?? '',
          'category': item['category'] ?? 'general',
          'priority': item['priority'] ?? 'normal',
          'created_at': item['created_at'] ?? '',
        }).toList();

        await _localDBService.cacheData('announcements_cache', cleanedList);
        return {'success': true, 'data': cleanedList, 'fromCache': false};
      }
      return {'success': false, 'message': response['message']};
    } catch (e) {
      return {'success': false, 'message': 'API Error: $e'};
    }
  }

  // ===========================================================================
  // 5. Complaints
  // ===========================================================================
  Future<Map<String, dynamic>> getComplaints() async {
    final cached = await _localDBService.getComplaints();
    if (cached.isNotEmpty) {
      _fetchAndCacheComplaints();
      return {'success': true, 'data': cached, 'fromCache': true};
    }
    return await _fetchAndCacheComplaints();
  }

  Future<Map<String, dynamic>> _fetchAndCacheComplaints() async {
    try {
      final apiResponse = await _apiService.get('/student/complaints');
      if (apiResponse['success'] == true) {
        final list = apiResponse['data'] as List;
        final data = list.map((item) => {
          'id': item['id'] ?? 0,
          'title': item['title'] ?? 'بدون عنوان',
          'description': item['description'] ?? '',
          'status': (item['status'] ?? 'pending').toString().toLowerCase(),
          'type': item['type'] ?? 'general',
          'admin_reply': item['admin_reply'] ?? '',
          'created_at': item['created_at'] ?? '',
        }).toList();

        await _localDBService.cacheData('complaints_cache', data);
        return {'success': true, 'data': data, 'fromCache': false};
      }
      return {'success': false, 'data': []};
    } catch (e) {
      return {'success': false, 'message': '$e', 'data': []};
    }
  }

  Future<Map<String, dynamic>> submitComplaint({required String title, required String description, required String recipient, required bool isSecret}) async {
    return await _apiService.post('/student/complaints', {
      'title': title, 'description': description, 'recipient': recipient, 'is_secret': isSecret, 'status': 'pending',
    });
  }

  // ===========================================================================
  // 6. Maintenance
  // ===========================================================================
  Future<Map<String, dynamic>> getMaintenance() async {
    final cached = await _localDBService.getMaintenanceRequests();
    if (cached.isNotEmpty) {
      _fetchAndCacheMaintenance();
      return {'success': true, 'data': cached, 'fromCache': true};
    }
    return await _fetchAndCacheMaintenance();
  }

  Future<Map<String, dynamic>> _fetchAndCacheMaintenance() async {
    try {
      final apiResponse = await _apiService.get('/student/maintenance');
      if (apiResponse['success'] == true) {
        final list = apiResponse['data'] as List;
        final data = list.map((item) => {
          'id': item['id'] ?? 0,
          'category': item['category'] ?? 'عام',
          'description': item['description'] ?? '',
          'status': (item['status'] ?? 'pending').toString().toLowerCase(),
          'supervisor_reply': item['supervisor_reply'] ?? '',
          'created_at': item['created_at'] ?? '',
        }).toList();

        await _localDBService.cacheData('maintenance_cache', data);
        return {'success': true, 'data': data, 'fromCache': false};
      }
      return {'success': false, 'data': []};
    } catch (e) {
      return {'success': false, 'data': []};
    }
  }

  Future<Map<String, dynamic>> submitMaintenance({required String category, required String description}) async {
    return await _apiService.post('/student/maintenance', {'category': category, 'description': description, 'status': 'pending'});
  }

  // ===========================================================================
  // 7. Permissions
  // ===========================================================================
  Future<Map<String, dynamic>> getPermissions() async {
    final cached = await _localDBService.getPermissions();
    if (cached.isNotEmpty) {
      _fetchAndCachePermissions();
      return {'success': true, 'data': cached, 'fromCache': true};
    }
    return await _fetchAndCachePermissions();
  }

  Future<Map<String, dynamic>> _fetchAndCachePermissions() async {
    try {
      final apiResponse = await _apiService.get('/student/permissions');
      if (apiResponse['success'] == true) {
        final list = apiResponse['data'] as List;
        final data = list.map((item) => {
          'id': item['id'] ?? 0,
          'type': item['type'] ?? 'تصريح',
          'start_date': item['start_date'] ?? '',
          'end_date': item['end_date'] ?? '',
          'reason': item['reason'] ?? '',
          'status': (item['status'] ?? 'pending').toString().toLowerCase(),
          'created_at': item['created_at'] ?? '',
        }).toList();

        await _localDBService.cacheData('permissions_cache', data);
        return {'success': true, 'data': data, 'fromCache': false};
      }
      return {'success': false, 'data': []};
    } catch (e) {
      return {'success': false, 'data': []};
    }
  }

  Future<Map<String, dynamic>> requestPermission({required String type, required String startDate, required String endDate, required String reason}) async {
    return await _apiService.post('/student/permissions', {'type': type, 'start_date': startDate, 'end_date': endDate, 'reason': reason, 'status': 'pending'});
  }

  // ===========================================================================
  // 8. Notifications
  // ===========================================================================
  Future<Map<String, dynamic>> getNotifications() async {
    try {
      final response = await _apiService.get('/student/notifications');
      if (response['success'] == true) {
        final list = response['data'] as List;
        final cleaned = list.map((item) => {
          'id': item['id'],
          'title': item['title'] ?? '',
          'body': item['body'] ?? '',
          'is_unread': item['is_unread'] ?? false,
          'created_at': item['created_at'] ?? '',
        }).toList();
        return {'success': true, 'data': cleaned};
      }
      return {'success': true, 'data': []};
    } catch (e) {
      return {'success': false, 'message': '$e', 'data': []};
    }
  }

  // ===========================================================================
  // 9. Clearance
  // ===========================================================================
  Future<Map<String, dynamic>> getClearanceStatus() async {
    try {
      final cached = await _localDBService.getClearanceStatus();
      if (cached != null) {
        _fetchAndCacheClearance();
        return {'success': true, 'data': cached, 'fromCache': true};
      }
      return await _fetchAndCacheClearance();
    } catch (e) {
      return {'success': false, 'message': '$e'};
    }
  }

  Future<Map<String, dynamic>> _fetchAndCacheClearance() async {
    try {
      final response = await _apiService.get('/student/clearance');
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        await _localDBService.cacheData('clearance_cache', [{
          'id': data['id'],
          'status': data['status'],
          'room_check_passed': (data['room_check_passed'] == true) ? 1 : 0,
          'keys_returned': (data['keys_returned'] == true) ? 1 : 0,
          'initiated_at': data['initiated_at']
        }]);
        return {'success': true, 'data': data, 'fromCache': false};
      }
      return {'success': true, 'data': null};
    } catch (e) {
      return {'success': false, 'message': '$e'};
    }
  }

  Future<Map<String, dynamic>> initiateClearance() async {
    return await _apiService.post('/student/clearance', {'status': 'pending', 'initiated_at': DateTime.now().toIso8601String()});
  }

  // ===========================================================================
  // Utility
  // ===========================================================================
  Future<void> clearCache() async {
    await _localDBService.clearAllData();
  }
}