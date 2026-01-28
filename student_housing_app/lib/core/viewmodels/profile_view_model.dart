import 'package:flutter/foundation.dart';
import '../repositories/data_repository.dart';

/// ProfileViewModel: State management for Profile feature
class ProfileViewModel extends ChangeNotifier {
  final DataRepository _repository;

  // State variables
  Map<String, dynamic>? _userProfile; // ✅ غيرنا الاسم هنا
  bool _isLoading = false;
  String? _errorMessage;

  // Getters for UI access
  // ✅ وهنا كمان غيرنا اسم الـ Getter عشان يطابق اللي في الشاشة
  Map<String, dynamic>? get userProfile => _userProfile;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Constructor
  ProfileViewModel({DataRepository? repository})
      : _repository = repository ?? DataRepository();

  /// Load student profile data
  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getStudentProfile();

      if (result['success'] == true && result['data'] != null) {
        _userProfile = result['data']; // ✅ حفظ البيانات في المتغير الصحيح
        print('✅ Student profile loaded successfully');
      } else {
        _errorMessage = 'فشل تحميل البيانات الشخصية';
        print('❌ Error: $_errorMessage');
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع: $e';
      print('❌ Exception: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}