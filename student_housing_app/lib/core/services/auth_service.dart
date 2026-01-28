import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'local_db_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final LocalDBService _localDBService = LocalDBService();

  /// ✅ Enhanced Login - Captures and saves user data immediately
  Future<Map<String, dynamic>> login(String nationalId, String password) async {
    try {
      // إرسال الطلب
      final response = await _apiService.post('/auth/login', {
        'national_id': nationalId,
        'password': password,
      });

      // التحقق من الهيكل: { success: true, data: { token: "...", user: {...} } }
      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];

        // التأكد إن data عبارة عن Map وجواها token
        if (data is Map && data['token'] != null) {
          final token = data['token'];
          final prefs = await SharedPreferences.getInstance();

          // ✅ حفظ التوكن
          await prefs.setString('auth_token', token);

          // ✅ NEW: حفظ بيانات المستخدم بشكل فردي من الاستجابة
          if (data['user'] != null) {
            final user = data['user'];

            // حفظ البيانات الأساسية بشكل منفصل للوصول السريع
            // Note: API returns 'name', not 'full_name'
            final userName = user['name'] ?? user['full_name'] ?? 'طالب';
            final userId =
                (user['student_id'] ?? user['national_id'] ?? user['id'] ?? '0')
                    .toString();

            await prefs.setString('student_name', userName);
            await prefs.setString('student_id', userId);
            await prefs.setString('user_role', user['role'] ?? 'student');
            await prefs.setString('national_id', user['national_id'] ?? '');

            // حفظ كل البيانات كـ JSON للرجوع إليها لاحقاً
            await prefs.setString('user_data', jsonEncode(user));

            print('✅ User data saved: $userName (ID: $userId)');
          }

          return {'success': true, 'data': data};
        }
      }

      return {
        'success': false,
        'message': response['message'] ?? 'فشل تسجيل الدخول',
      };
    } catch (e) {
      return {'success': false, 'message': 'خطأ غير متوقع: $e'};
    }
  }

  /// ✅ NEW: clearSession() - Wipes all user data (SharedPreferences + SQLite)
  Future<void> clearSession() async {
    try {
      print('🗑️  Clearing session...');

      // 1. مسح SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      await prefs.remove('student_name');
      await prefs.remove('student_id');
      await prefs.remove('user_role');
      await prefs.remove('national_id');

      // 2. مسح SQLite database (جميع الجداول)
      await _localDBService.clearAllData();

      print('✅ Session cleared successfully');
    } catch (e) {
      print('❌ Error clearing session: $e');
    }
  }

  /// ✅ Legacy logout method (now calls clearSession)
  Future<void> logout() async {
    await clearSession();
  }

  /// ✅ Get current stored user data from SharedPreferences
  Future<Map<String, String>> getStoredUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('student_name') ?? 'طالب',
      'id': prefs.getString('student_id') ?? '0',
      'role': prefs.getString('user_role') ?? 'student',
      'nationalId': prefs.getString('national_id') ?? '',
    };
  }

  /// ✅ Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('auth_token');
  }
}
