import 'dart:io';
import 'package:flutter/material.dart';
import '../repositories/data_repository.dart';

class MaintenanceViewModel extends ChangeNotifier {
  final DataRepository _repository = DataRepository();

  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _requests = [];

  // --- حقول الإدخال الجديدة ---
  String? _selectedCategory; // نوع العطل
  int? _selectedFloor;      // الدور (1-6)
  String? _selectedWing;    // الجناح (أ، ب، ج، د)
  String? _selectedLocation; // نوع المكان (غرفة، حمام، إلخ)
  String? _selectedRoomNo;   // رقم الغرفة المحدد
  File? _selectedImage;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, dynamic>> get requests => _requests;
  String? get selectedCategory => _selectedCategory;
  int? get selectedFloor => _selectedFloor;
  String? get selectedWing => _selectedWing;
  String? get selectedLocation => _selectedLocation;
  String? get selectedRoomNo => _selectedRoomNo;
  File? get selectedImage => _selectedImage;

  // --- دوال التحديث (Setters) مع تطبيق اللوجيك ---

  void setCategory(String category) {
    _selectedCategory = category;
    // إعادة ضبط الحقول التالية عند تغيير نوع العطل لضمان التزامن
    _selectedWing = null;
    _selectedLocation = null;
    _selectedRoomNo = null;
    notifyListeners();
  }

  void setFloor(int floor) {
    _selectedFloor = floor;
    // ✅ تصفير الاختيارات المعتمدة على الدور لمنع خطأ Dropdown
    _selectedWing = null;
    _selectedLocation = null;
    _selectedRoomNo = null;
    notifyListeners();
  }

  void setWing(String wing) {
    _selectedWing = wing;
    _selectedLocation = null;
    _selectedRoomNo = null;
    notifyListeners();
  }

  void setLocation(String location) {
    _selectedLocation = location;
    _selectedRoomNo = null;
    notifyListeners();
  }

  void setRoomNo(String roomNo) {
    _selectedRoomNo = roomNo;
    notifyListeners();
  }

  void setImage(File image) {
    _selectedImage = image;
    notifyListeners();
  }

  void clearImage() {
    _selectedImage = null;
    notifyListeners();
  }

  // --- منطق القيود (Conditional Logic) ---

  // 1. الأجنحة المتاحة بناءً على نوع العطل
  List<String> getAvailableWings() {
    if (_selectedCategory == 'gas') return ['ب', 'د']; // الغاز مسموح في ب ود فقط (أوفيس)
    return ['أ', 'ب', 'ج', 'د'];
  }

  // 2. الأماكن المتاحة بناءً على العطل والجناح
  List<String> getAvailableLocations() {
    if (_selectedCategory == null || _selectedWing == null) return [];

    // قيود نوع العطل أولاً
    if (_selectedCategory == 'gas') return ['أوفيس'];
    if (_selectedCategory == 'internet') return ['غرفة مذاكرة'];
    if (_selectedCategory == 'carpentry') return ['غرفة عادية'];
    if (_selectedCategory == 'plumbing') return ['حمام', 'أوفيس', 'الطرقة'];

    // لو كهرباء أو ألوميتال أو زجاج (مسموح بكل شيء حسب الجناح)
    List<String> locations = ['حمام', 'غرفة مذاكرة', 'الطرقة', 'غرفة عادية'];
    if (_selectedWing == 'ب' || _selectedWing == 'د') {
      locations.add('أوفيس');
    }
    return locations;
  }

  // 3. أرقام الغرف بناءً على الجناح
// ✅ تحديث: أرقام الغرف بناءً على الدور والجناح المختارين
  List<String> getAvailableRooms() {
    if (_selectedWing == null || _selectedFloor == null) return [];

    // تحويل رقم الدور لنص عشان نستخدمه كبادئة (Prefix)
    String f = _selectedFloor.toString();

    if (_selectedWing == 'أ') return ['$f' '01', '$f' '02', '$f' '03', '$f' '04', '$f' '05', '$f' '06'];
    if (_selectedWing == 'ب') return ['$f' '08', '$f' '09', '$f' '10', '$f' '11', '$f' '12'];
    if (_selectedWing == 'ج') return ['$f' '14', '$f' '15', '$f' '16', '$f' '17', '$f' '18', '$f' '19'];
    if (_selectedWing == 'د') return ['$f' '21', '$f' '22', '$f' '23', '$f' '24', '$f' '25'];

    return [];
  }

  // --- العمليات الأساسية ---

  Future<void> loadRequests() async {
    _isLoading = true;
    _errorMessage = null; // تصفير الخطأ القديم
    notifyListeners();

    try {
      final result = await _repository.getMaintenance();
      if (result['success']) {
        _requests = List<Map<String, dynamic>>.from(result['data']);
        print("✅ تم تحميل ${_requests.length} طلب صيانة");
      } else {
        _errorMessage = result['message'] ?? "فشل تحميل البيانات";
      }
    } catch (e) {
      _errorMessage = "حدث خطأ غير متوقع: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitRequest({required String description}) async {
    if (_selectedCategory == null || _selectedFloor == null || _selectedWing == null || _selectedLocation == null) {
      _errorMessage = "يرجى إكمال كافة البيانات المطلوبة";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.submitMaintenance(
        category: _selectedCategory!,
        description: description,
        floor: _selectedFloor!,
        wing: _selectedWing!,
        locationType: _selectedLocation!,
        roomNumber: _selectedRoomNo,
        image: _selectedImage,
      );

      if (result['success']) {
        await loadRequests();
        resetForm();
        return true;
      }
      _errorMessage = result['message'];
      return false;
    } catch (e) {
      _errorMessage = "حدث خطأ في الاتصال بالسيرفر";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetForm() {
    _selectedCategory = null;
    _selectedFloor = null;
    _selectedWing = null;
    _selectedLocation = null;
    _selectedRoomNo = null;
    _selectedImage = null;
    notifyListeners();
  }
}