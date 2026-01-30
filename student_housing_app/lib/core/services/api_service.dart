import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http_parser/http_parser.dart'; // لو احتجت تحديد نوع الملف بدقة

class ApiService {
  // ✅ تأكد من تحديث الـ IP حسب شبكتك
  static const String baseUrl = "http://192.168.1.12:3000/api";

  // معالجة رابط الصور
  static String getImageUrl(String? path) {
    if (path == null || path.isEmpty) return "";
    if (path.startsWith('http')) return path;
    // حذف /api للوصول للمجلد العام (uploads)
    final rootUrl = baseUrl.replaceAll('/api', '');
    return '$rootUrl$path';
  }

  // ✅ جعلناها Public عشان DataRepository يقدر يستخدمها
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // --- GET ---
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final token = await getToken();
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

  // --- POST ---
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final token = await getToken();
      print('🚀 POST Request: $baseUrl$endpoint');
      
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );
      
      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'فشل الاتصال: $e'};
    }
  }

  // --- ✅ NEW: POST MULTIPART (لرفع الصور والملفات) ---
  Future<Map<String, dynamic>> postMultipart({
    required String endpoint,
    required Map<String, String> fields,
    File? file,
    String fileField = 'image', // اسم الحقل في الباك إند (multer)
  }) async {
    try {
      final token = await getToken();
      final uri = Uri.parse('$baseUrl$endpoint');
      var request = http.MultipartRequest('POST', uri);

      // Headers
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Fields
      request.fields.addAll(fields);

      // File
      if (file != null) {
        var stream = http.ByteStream(file.openRead());
        var length = await file.length();
        var multipartFile = http.MultipartFile(
          fileField,
          stream,
          length,
          filename: file.path.split('/').last,
        );
        request.files.add(multipartFile);
      }

      // Send
      print('🚀 UPLOAD Request: $uri');
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return _processResponse(response);
    } catch (e) {
      return {'success': false, 'message': 'فشل رفع الملف: $e'};
    }
  }

  // --- معالجة الرد ---
  Map<String, dynamic> _processResponse(http.Response response) {
    try {
      if (response.body.isEmpty) return {'success': false, 'message': 'Empty Response'};
      
      // محاولة فك التشفير، لو فشل نرجع النص كما هو
      dynamic body;
      try {
        body = jsonDecode(response.body);
      } catch (e) {
        return {'success': false, 'message': response.body};
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (body is Map<String, dynamic>) {
          return body;
        } else {
          return {'success': true, 'data': body};
        }
      } else {
        return {
          'success': false,
          'message': body is Map ? (body['message'] ?? 'حدث خطأ') : 'خطأ غير معروف'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'خطأ في معالجة البيانات: $e'};
    }
  }
}