import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  // السيرفس المسؤولة عن الاتصال بالسيرفر
  final AuthService _authService = AuthService();

  // الحالة (State)
  bool _isLoading = false;
  String? _errorMessage;
  bool _isPasswordVisible = false; // ✅ المتغير الناقص

  // Getters (عشان الشاشة تقرأ البيانات)
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isPasswordVisible => _isPasswordVisible; // ✅ الـ Getter الناقص

  // ✅ دالة تبديل رؤية كلمة المرور (الناقصة)
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners(); // تحديث الـ UI فوراً
  }

  // دالة تسجيل الدخول
  Future<bool> login(String nationalId, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // عشان يظهر الـ Loading Indicator

    try {
      // الاتصال بـ AuthService
      final result = await _authService.login(nationalId, password);

      if (result['success'] == true) {
        _isLoading = false;
        notifyListeners();
        return true; // نجاح
      } else {
        _errorMessage = result['message'] ?? 'فشل تسجيل الدخول';
        _isLoading = false;
        notifyListeners();
        return false; // فشل
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع: $e';
      _isLoading = false;
      notifyListeners();
      return false; // فشل
    }
  }
}