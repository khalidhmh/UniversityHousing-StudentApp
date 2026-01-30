import 'dart:io'; // ✅ Needed for File upload
import 'dart:math';
import 'package:student_housing_app/core/services/api_service.dart';
import 'package:student_housing_app/core/services/local_db_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http; // ✅ For multipart request

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
  // 1. Student Profile (Updated for new DB structure)
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

        // ✅ التوافق مع هيكلية الرد الجديدة من الباك إند
        // الباك إند بيرجع housing object جاهز: { building: "...", room: "..." }
        Map<String, dynamic> housingMap;
        if (profileData['housing'] != null) {
          housingMap = {
            'building': profileData['housing']['building'] ?? '---',
            'room_no': profileData['housing']['room'] ?? '---'
          };
        } else {
          housingMap = {'room_no': 'غير مسكن', 'building': '---'};
        }

        await _localDBService.cacheData('student_profile', [
          {
            'id': (profileData['id'] ?? '').toString(),
            'national_id': (profileData['national_id'] ?? '').toString(),
            'full_name': profileData['full_name'] ?? 'طالب',
            'address': profileData['address'] ?? 'غير متوفر',
            'housing_type': profileData['housing_type'] ?? 'سكن عادي',
            'level': (profileData['level'] ?? 1).toString(),
            'room_json': jsonEncode(housingMap), // تخزين كـ JSON للكاش
            'photo_url': ApiService.getImageUrl(profileData['photo_url']),
            'student_id': (profileData['student_id'] ?? profileData['national_id'] ?? '').toString(),
            'college': profileData['college'] ?? '',
            'phone': profileData['phone'] ?? '', // ✅ حقل جديد
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
  // 2. Attendance (Updated Logic)
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
        // print("Khaliddddd");
        // ✅ التعديل: تخزين الحالة كـ Boolean (0 أو 1 للـ SQLite)
        final attendanceData = attendanceList.map((item) => {
          'date': item['date'] ?? '',
          // نحولها لـ 1 لو true و 0 لو false
          'status': (item['status'] == true || item['status'] == 'Present') ? 1 : 0,
          'supervisor_name': item['supervisor_name'] ?? '',
        }).toList();
        print(attendanceData);
        print(attendanceList);
        await _localDBService.cacheData('attendance_cache', attendanceData);
        return {'success': true, 'data': attendanceData, 'fromCache': false};
      }
      return {'success': false, 'message': apiResponse['message']};
    } catch (e) {
      return {'success': false, 'message': '$e'};
    }
  }

  // ===========================================================================
  // 3. Activities (Fixed Subscription Logic)
  // ===========================================================================
  Future<Map<String, dynamic>> getActivities({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await _localDBService.getActivities();
      if (cached.isNotEmpty) {
        _fetchAndCacheActivities();
        return {'success': true, 'data': cached, 'fromCache': true};
      }
    }
    return await _fetchAndCacheActivities();
  }

  Future<Map<String, dynamic>> _fetchAndCacheActivities() async {
    try {
      final response = await _apiService.get('/student/activities');
      final rawList = response['data'] ?? response['activities'];

      if (response['success'] == true && rawList != null && rawList is List) {
        final cleanedList = rawList.map((item) => {
          'id': item['id'],
          'title': item['title'] ?? 'بدون عنوان',
          'description': item['description'] ?? '',
          'category': item['category'] ?? 'عام',
          'location': item['location'] ?? '',
          'event_date': item['event_date'] ?? item['date'] ?? '', // ✅ Handled both names
          'image_url': ApiService.getImageUrl(item['image_url']),
          'is_subscribed': (item['is_subscribed'] == true || item['is_subscribed'] == 1) ? 1 : 0
        }).toList();

        await _localDBService.cacheData('activities_cache', cleanedList);
        return {'success': true, 'data': cleanedList, 'fromCache': false};
      }
      return {'success': false, 'message': response['message'] ?? 'No data found'};
    } catch (e) {
      return {'success': false, 'message': 'API Error: $e'};
    }
  }

  // --- Subscriptions ---
  Future<Map<String, dynamic>> subscribeToActivity(int activityId) async {
    return await _apiService.post('/student/activities/subscribe', {'activity_id': activityId});
  }

  Future<Map<String, dynamic>> unsubscribeFromActivity(int activityId) async {
    return await _apiService.post('/student/activities/unsubscribe', {'activity_id': activityId});
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
      final rawList = response['data'] ?? response['announcements'];

      if (response['success'] == true && rawList != null && rawList is List) {
        final cleanedList = rawList.map((item) => {
          'id': item['id'],
          'title': item['title'] ?? 'إعلان هام',
          'body': item['content'] ?? item['body'] ?? '', // ✅ content from new DB
          'category': item['category'] ?? 'general',
          'priority': item['importance'] ?? item['priority'] ?? 'normal', // ✅ importance
          'publisher': item['publisher'] ?? 'الإدارة', // ✅ اسم الناشر
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
          'admin_reply': item['reply_text'] ?? item['admin_reply'] ?? '', // ✅ reply_text
          'created_at': item['created_at'] ?? '',
        }).toList();

        await _localDBService.cacheData('complaints_cache', data);
        return {'success': true, 'data': data, 'fromCache': false};
      }
      return {'success': false, 'data': []};
    } catch (e) {
      return {'success': false, 'data': []};
    }
  }

  Future<Map<String, dynamic>> submitComplaint({required String title, required String description}) async {
    return await _apiService.post('/student/complaints', {
      'title': title, 'description': description
    });
  }

  // ===========================================================================
  // 6. Maintenance (Updated for Image Upload & New Fields)
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
          'location_type': item['location_type'] ?? '', // ✅ حقل جديد
          'status': (item['status'] ?? 'pending').toString().toLowerCase(),
          'image_url': ApiService.getImageUrl(item['image_url']), // ✅ صورة العطل
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

  // ✅ New: Submit with Image support
  Future<Map<String, dynamic>> submitMaintenance({
    required String category,
    required String description,
    required String locationType, // ✅ New
    String? locationDetails,      // ✅ New
    File? image                   // ✅ New
  }) async {
    try {
      // ✅ التعديل الأول: استخدم ApiService.baseUrl بدلاً من _apiService.baseUrl
      var uri = Uri.parse('${ApiService.baseUrl}/student/maintenance');
      var request = http.MultipartRequest('POST', uri);

      // Headers (Token)
      String? token = await _apiService.getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Fields
      request.fields['category'] = category;
      request.fields['description'] = description;
      request.fields['location_type'] = locationType;
      if (locationDetails != null) request.fields['location_details'] = locationDetails;

      // File
      if (image != null) {
        request.files.add(await http.MultipartFile.fromPath('image', image.path));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Upload Error: $e'};
    }
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
    return await _apiService.post('/student/permissions', {
      'type': type, 'start_date': startDate, 'end_date': endDate, 'reason': reason
    });
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
          'body': item['message'] ?? item['body'] ?? '', // ✅ message field
          'is_read': item['is_read'] ?? false, // ✅ is_read field (was is_unread)
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
  // 9. Clearance (New DB Logic)
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
      // If clearance request exists, 'data' will be an object. If not, it might be null or { status: 'none' }

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];

        // لو الداتا راجعة فيها status = 'none'، يبقى الطالب معملش طلب لسه
        if (data['status'] == 'none') {
          // استخدم دالة database الجاهزة التي تضمن عدم وجود null
          final db = await _localDBService.database;
          await db.delete('clearance_cache'); // Clear cache if none
          return {'success': true, 'data': null, 'fromCache': false};
        }

        await _localDBService.cacheData('clearance_cache', [{
          'id': data['id'],
          'status': data['status'],
          'notes': data['notes'] ?? '',
          'request_date': data['request_date'],
          // Dummy fields for compatibility with UI if needed, or remove them from UI
          'room_check_passed': (data['status'] == 'approved') ? 1 : 0,
          'keys_returned': (data['status'] == 'approved') ? 1 : 0,
        }]);
        return {'success': true, 'data': data, 'fromCache': false};
      }
      return {'success': true, 'data': null};
    } catch (e) {
      return {'success': false, 'message': '$e'};
    }
  }

  Future<Map<String, dynamic>> initiateClearance() async {
    return await _apiService.post('/student/clearance/initiate', {});
  }

  // ===========================================================================
  // Utility
  // ===========================================================================
  // ✅ التعديل الثاني: إصلاح دالة clearCache في آخر الملف
  Future<void> clearCache() async {
    // استخدم دالة database الجاهزة التي تضمن عدم وجود null
    final db = await _localDBService.database;
    // الآن يمكنك الحذف بأمان لأن db مستحيل تكون null
    await db.delete('student_profile');
    await db.delete('attendance_cache');
    await db.delete('complaints_cache');
    await db.delete('maintenance_cache');
    await db.delete('permissions_cache');
    await db.delete('activities_cache');
    await db.delete('clearance_cache');
    await db.delete('announcements_cache');
    print("🗑️ Local Data Cleared");
  }
}