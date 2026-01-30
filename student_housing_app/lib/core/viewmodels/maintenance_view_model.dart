import 'dart:io';
import 'package:flutter/material.dart';
import '../repositories/data_repository.dart';

class MaintenanceViewModel extends ChangeNotifier {
  final DataRepository _repository = DataRepository();

  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _requests = [];

  // حقول الإدخال
  File? _selectedImage;
  String _selectedLocationType = 'room';

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get requests => _requests;
  File? get selectedImage => _selectedImage;
  String get selectedLocationType => _selectedLocationType;

  // تحميل الطلبات
  Future<void> loadRequests() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getMaintenance();
      if (result['success']) {
        _requests = List<Map<String, dynamic>>.from(result['data']);
      } else {
        _errorMessage = result['message'];
      }
    } catch (e) {
      _errorMessage = 'فشل تحميل البيانات';
    }

    _isLoading = false;
    notifyListeners();
  }

  // إدارة الصورة
  void setImage(File image) {
    _selectedImage = image;
    notifyListeners();
  }

  void clearImage() {
    _selectedImage = null;
    notifyListeners();
  }

  void setLocationType(String type) {
    _selectedLocationType = type;
    notifyListeners();
  }

  // إرسال الطلب
  Future<bool> submitRequest({
    required String category,
    required String description,
    required String locationDetails
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.submitMaintenance(
          category: category,
          description: description,
          locationType: _selectedLocationType,
          locationDetails: locationDetails,
          image: _selectedImage
      );

      if (result['success']) {
        await loadRequests();
        clearImage();
        _selectedLocationType = 'room';
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ في الاتصال';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}