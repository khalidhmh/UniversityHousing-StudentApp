import 'package:flutter/material.dart';
import '../repositories/data_repository.dart';
import 'dart:io';

class ProfileViewModel extends ChangeNotifier {
  final DataRepository _repository = DataRepository();

  bool _isLoading = false;
  Map<String, dynamic>? _userProfile;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get userProfile => _userProfile;
  String? get errorMessage => _errorMessage;

  // Helper getters for UI
  String get fullName => _userProfile?['full_name'] ?? 'طالب';
  String get nationalId => _userProfile?['national_id'] ?? '';
  String get faculty => _userProfile?['college'] ?? '';
  String get photoUrl => _userProfile?['photo_url'] ?? '';
  
  // ✅ الحقول الجديدة
  String get phone => _userProfile?['phone'] ?? 'غير مسجل';
  String get address => _userProfile?['address'] ?? 'العنوان غير مسجل';
  
  // ✅ استخراج بيانات السكن بشكل آمن
  String get buildingName {
    if (_userProfile != null && _userProfile!['housing'] != null) {
      return _userProfile!['housing']['building'] ?? '---';
    }
    return '---';
  }
  
  String get roomNumber {
    if (_userProfile != null && _userProfile!['housing'] != null) {
      return _userProfile!['housing']['room'] ?? '---';
    }
    return '---';
  }

  Future<void> loadUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getStudentProfile();
      if (result['success']) {
        _userProfile = result['data'];
      } else {
        _errorMessage = result['message'];
      }
    } catch (e) {
      _errorMessage = 'فشل تحميل الملف الشخصي';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> uploadPhoto(File photo) async {
    // سيتم تنفيذ هذا الجزء في DataRepository لاحقاً إذا احتجنا رفعه من البروفايل
    // حالياً نركز على عرض البيانات
  }
}