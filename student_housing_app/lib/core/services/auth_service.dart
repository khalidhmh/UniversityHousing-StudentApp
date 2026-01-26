import 'dart:convert';
// import 'package:http/http.dart' as http; // لم نعد بحاجة له هنا لأننا سنستخدم ApiService
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart'; // تأكد من استيراد ApiService

class AuthService {
  // نستخدم ApiService بدلاً من كتابة الرابط مرة أخرى
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> login(String id, String password) async {
    try {
      // نستخدم دالة login الموجودة في ApiService مباشرة
      // لأنك قمت بالفعل بكتابة منطق الـ Login هناك بشكل صحيح
      final response = await _apiService.login(id, password);
      return response;
    } catch (e) {
      return {'success': false, 'message': 'فشل الاتصال بالسيرفر: $e'};
    }
  }
}