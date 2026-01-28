import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../repositories/data_repository.dart';

/// ProfileViewModel: State management for Profile feature
class ProfileViewModel extends ChangeNotifier {
  final DataRepository _repository;

  // State variables
  Map<String, dynamic>? _studentData;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters for UI access
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasData => _studentData != null;

  // Derived Getters (Safe Data Access)
  String get fullName => _studentData?['full_name'] ?? 'طالب';
  String get college => _studentData?['college'] ?? 'جامعة القاهرة';
  String get nationalId => _studentData?['national_id'] ?? '---';
  String get studentId => _studentData?['student_id'] ?? _studentData?['national_id'] ?? '---';
  String get photoUrl => _studentData?['photo_url'] ?? '';
  
  String get level => _studentData?['level']?.toString() ?? '---';

  String get housingInfo {
    // Check if we have 'housing' object or older 'room_json'
    if (_studentData?['room_json'] != null) {
       try {
         final roomData = jsonDecode(_studentData!['room_json']);
         return "مبنى (${roomData['building']}) - غرفة ${roomData['room_no']}";
       } catch (e) {
         return 'غير مسكن';
       }
    }
    return 'غير مسكن';
  }

  // Individual housing fields if needed
  String get buildingName {
    if (_studentData?['room_json'] != null) {
      try {
        final roomData = jsonDecode(_studentData!['room_json']);
        return roomData['building'] ?? '---';
      } catch (_) {}
    }
    return '---';
  }

  String get roomNumber {
    if (_studentData?['room_json'] != null) {
      try {
        final roomData = jsonDecode(_studentData!['room_json']);
        return roomData['room_no']?.toString() ?? '---';
      } catch (_) {}
    }
    return '---';
  }

  /// Constructor
  ProfileViewModel({DataRepository? repository})
      : _repository = repository ?? DataRepository();

  /// Load student profile data
  Future<void> loadUserProfile() async {
    // Smart Loading: Only show spinner if we have no data
    if (_studentData == null) {
      _isLoading = true;
      notifyListeners();
    }
    
    _errorMessage = null;

    try {
      final result = await _repository.getStudentProfile();

      if (result['success'] == true && result['data'] != null) {
        _studentData = result['data'];
        
        // If data came from cache, we might get a background refresh later.
        // The repository handles the background fetch triggering.
        // If we wanted to listen to changes fully we would need a Stream, 
        // but for now relying on the returned data is fine.
        
      } else {
        _errorMessage = result['message'] ?? 'فشل تحميل البيانات الشخصية';
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}