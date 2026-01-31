import 'dart:convert';

import 'package:flutter/material.dart';
import '../repositories/data_repository.dart';
import 'dart:io';

// core/viewmodels/profile_view_model.dart

class ProfileViewModel extends ChangeNotifier {
  final DataRepository _repository = DataRepository();
  bool _isLoading = false;
  Map<String, dynamic>? _userProfile;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  Map<String, dynamic>? get userProfile => _userProfile;
  String? get errorMessage => _errorMessage;

  // --- Getters محسنة ---
  String get fullName => _userProfile?['full_name'] ?? 'طالب';
  String get nationalId => _userProfile?['national_id'] ?? '---';
  String get faculty => _userProfile?['college'] ?? '---';
  String get photoUrl => _userProfile?['photo_url'] ?? '';
  String get phone => _userProfile?['phone'] ?? 'غير مسجل';
  String get address => _userProfile?['address'] ?? 'غير مسجل';
  String get level => _userProfile?['level']?.toString() ?? '---';
  String get housingType => _userProfile?['housing_type'] ?? 'سكن عادي';

  // استخراج بيانات السكن بذكاء (سواء كانت Object أو JSON من الكاش)
  Map<String, dynamic> _getHousingData() {
    if (_userProfile == null) return {};
    if (_userProfile!['housing'] != null) return _userProfile!['housing'];

    // إذا كانت البيانات قادمة من الكاش (SQLite)
    if (_userProfile!['room_json'] != null) {
      try {
        return jsonDecode(_userProfile!['room_json']);
      } catch (e) {
        return {};
      }
    }
    return {};
  }

  String get buildingName => _getHousingData()['building'] ?? '---';
  String get roomNumber => _getHousingData()['room'] ?? _getHousingData()['room_no'] ?? '---';

  Future<void> loadUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _repository.getStudentProfile();
    if (result['success']) {
      _userProfile = result['data'];
    } else {
      _errorMessage = result['message'];
    }

    _isLoading = false;
    notifyListeners();
  }
}