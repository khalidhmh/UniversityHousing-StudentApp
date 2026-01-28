import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ✅ تأكد إن الـ IP ده هو بتاع جهاز الكمبيوتر بتاعك (من أمر hostname -I)
  static const String baseUrl = "http://192.168.1.12:3000/api";

  // ✅ انسخ الدالة دي وضيفها هنا (مهمة جداً)
  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    if (path.startsWith('http')) return path;
    // بنشيل /api عشان نوصل للروت بتاع الصور
    final rootUrl = baseUrl.replaceAll('/api', '');
    return '$rootUrl$path';
  }

  // دالة لجلب التوكن (لو موجود)
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token'); // وحدنا الاسم لـ auth_token
  }

  // --- دالة GET ---
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final token = await _getToken();

      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'فشل الاتصال: $e'};
    }
  }

  // --- دالة POST (الجوكر) ---
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final token = await _getToken();

      print('🚀 POST Request to: $baseUrl$endpoint'); // Debug

      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          // ✅ التوكن هنا اختياري: لو موجود حطه، لو مش موجود (زي الـ Login) كمل عادي
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('📥 Response: ${response.body}'); // Debug
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'فشل الاتصال: $e'};
    }
  }

  // --- معالجة الرد الموحدة ---
  Map<String, dynamic> _processResponse(http.Response response) {
    try {
      if (response.body.isEmpty) return {'success': false, 'message': 'Empty Response'};

      final body = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // لو الرد Map رجعه زي ما هو، لو List أو String غلفه
        if (body is Map<String, dynamic>) {
          // أحياناً السيرفر بيرجع success:true بس البيانات ناقصة، ده مجرد تمرير
          return body;
        } else {
          return {'success': true, 'data': body};
        }
      } else {
        // لو فيه خطأ من السيرفر (400, 401, 500)
        return {
          'success': false,
          'message': body is Map ? (body['message'] ?? 'حدث خطأ') : 'خطأ غير معروف'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'خطأ في قراءة البيانات: $e'};
    }
  }
}