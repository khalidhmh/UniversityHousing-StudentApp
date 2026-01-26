import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ⚠️ هام جداً:
  // لو شغال على Emulator (محاكي أندرويد) استخدم: 10.0.2.2
  // لو شغال على موبايل حقيقي أو iOS استخدم الـ IP بتاع جهازك: 192.168.1.X
  // static const String _baseUrl = "http://10.0.2.2:3000/api";
  static const String _baseUrl = "http://192.168.1.12:3000/api";

  // Singleton Pattern (عشان نستخدم نفس النسخة في كل مكان)
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // دالة لجلب التوكن من الذاكرة
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // --- 1. تسجيل الدخول (Login) ---
  Future<Map<String, dynamic>> login(String id, String password) async {
    final url = Uri.parse('$_baseUrl/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userType': 'student', // مثبت مبدئياً، ممكن نغيره بعدين
          'id': id,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // حفظ التوكن والبيانات عند النجاح
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('student_name', data['user']['name']);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'خطأ في تسجيل الدخول'};
      }
    } catch (e) {
      return {'success': false, 'message': 'فشل الاتصال بالسيرفر: $e'};
    }
  }

  // --- 2. دالة GET عامة (لجلب البيانات) ---
  // دي اللي هنستخدمها لجلب الشكاوى، الغياب، الأنشطة...
  Future<Map<String, dynamic>> get(String endpoint) async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'message': 'غير مسجل دخول'};

    final url = Uri.parse('$_baseUrl$endpoint');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // ✅ هنا السحر: بنبعت التوكن للسيرفر
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else if (response.statusCode == 401) {
        // لو التوكن انتهى، ممكن هنا نعمل خروج تلقائي
        return {'success': false, 'message': 'انتهت الجلسة، سجل دخول مرة أخرى'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'حدث خطأ'};
      }
    } catch (e) {
      return {'success': false, 'message': 'فشل الاتصال: $e'};
    }
  }

  // --- 3. دالة POST عامة (لإرسال البيانات) ---
  // دي اللي هنستخدمها لإرسال شكوى، طلب صيانة، طلب تصريح...
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    final token = await _getToken();
    if (token == null) return {'success': false, 'message': 'غير مسجل دخول'};

    final url = Uri.parse('$_baseUrl$endpoint');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message'] ?? 'فشل الإرسال'};
      }
    } catch (e) {
      return {'success': false, 'message': 'فشل الاتصال: $e'};
    }
  }
}