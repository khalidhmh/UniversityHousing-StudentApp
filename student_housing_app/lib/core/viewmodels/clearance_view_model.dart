import 'package:flutter/material.dart';
import '../repositories/data_repository.dart';

class ClearanceViewModel extends ChangeNotifier {
  final DataRepository _repository = DataRepository();

  bool _isLoading = false;
  String? _errorMessage;
  
  // ✅ البيانات الجديدة
  String _status = 'none'; // none, pending, approved, rejected
  String _notes = '';
  int _currentStep = 0; // للتحكم في الـ UI Stepper

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get status => _status;
  String get notes => _notes;
  int get currentStep => _currentStep;

  // جلب حالة الإخلاء
  Future<void> loadClearanceStatus() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getClearanceStatus();
      
      if (result['success']) {
        if (result['data'] == null) {
          _status = 'none';
          _currentStep = 0;
        } else {
          final data = result['data'];
          _status = data['status'] ?? 'none';
          _notes = data['notes'] ?? '';
          
          // ✅ تحديث الخطوة بناءً على الحالة
          if (_status == 'pending') {
            _currentStep = 1; // قيد المراجعة
          } else if (_status == 'approved') {
            _currentStep = 2; // تم الإخلاء بنجاح
          } else if (_status == 'rejected') {
            _currentStep = 0; // تم الرفض (العودة للبداية مع ملاحظات)
          }
        }
      } else {
        _errorMessage = result['message'];
      }
    } catch (e) {
      _errorMessage = 'فشل تحميل حالة الإخلاء';
    }

    _isLoading = false;
    notifyListeners();
  }

  // بدء إجراءات الإخلاء
  Future<bool> initiateClearance() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.initiateClearance();
      if (result['success']) {
        await loadClearanceStatus(); // تحديث الحالة
        return true;
      } else {
        _errorMessage = result['message'];
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء تقديم الطلب';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}