import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'local_db_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  final LocalDBService _localDBService = LocalDBService();

  /// ✅ Enhanced Login
  Future<Map<String, dynamic>> login(String nationalId, String password) async {
    try {
      final response = await _apiService.post('/auth/login', {
        'national_id': nationalId,
        'password': password,
      });

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];

        if (data is Map && data['token'] != null) {
          final token = data['token'];
          final prefs = await SharedPreferences.getInstance();

          await prefs.setString('auth_token', token);

          if (data['user'] != null) {
            final user = data['user'];

            // الحقول المتوقعة من الباك إند الجديد
            final userName = user['name'] ?? user['full_name'] ?? 'طالب';
            final userId = (user['id'] ?? '0').toString(); // ID المستخدم
            
            await prefs.setString('student_name', userName);
            await prefs.setString('student_id', userId);
            await prefs.setString('user_role', user['role'] ?? 'student');
            await prefs.setString('national_id', user['national_id'] ?? '');
            
            // ✅ NEW: حفظ الصورة ورقم الهاتف للكاش السريع
            if (user['photo_url'] != null) {
              await prefs.setString('photo_url', ApiService.getImageUrl(user['photo_url']));
            }
            if (user['phone'] != null) {
              await prefs.setString('phone', user['phone']);
            }

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

  /// ✅ Clear Session
  Future<void> clearSession() async {
    try {
      print('🗑️ Clearing session...');
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // مسح كل شيء في الـ SharedPreferences أسهل وأضمن

      // مسح قاعدة البيانات المحلية
      await _localDBService.clearAllData();

      print('✅ Session cleared successfully');
    } catch (e) {
      print('❌ Error clearing session: $e');
    }
  }

  Future<void> logout() async {
    await clearSession();
  }

  Future<Map<String, String>> getStoredUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('student_name') ?? 'طالب',
      'id': prefs.getString('student_id') ?? '0',
      'role': prefs.getString('user_role') ?? 'student',
      'nationalId': prefs.getString('national_id') ?? '',
      'photoUrl': prefs.getString('photo_url') ?? '', // ✅
    };
  }

  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('auth_token');
  }
}