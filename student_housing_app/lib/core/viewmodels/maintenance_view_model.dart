import 'package:flutter/material.dart';
import '../repositories/data_repository.dart';

class MaintenanceViewModel extends ChangeNotifier {
  // ============================================================================
  // DEPENDENCIES
  // ============================================================================
  final DataRepository _dataRepository = DataRepository();

  // ============================================================================
  // STATE VARIABLES
  // ============================================================================
  List<Map<String, dynamic>> _maintenanceRequests = [];

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  // ============================================================================
  // GETTERS
  // ============================================================================
  List<Map<String, dynamic>> get maintenanceRequests => _maintenanceRequests;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  int get requestCount => _maintenanceRequests.length;

  // ============================================================================
  // PUBLIC METHODS
  // ============================================================================

  /// Fetch maintenance requests
  Future<void> getMaintenanceRequests() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _dataRepository.getMaintenance();

      if (result['success'] == true) {
        _maintenanceRequests = List<Map<String, dynamic>>.from(result['data'] ?? []);
        _errorMessage = null;
        print('✅ Maintenance requests loaded (${_maintenanceRequests.length} items)');
      } else {
        if (_maintenanceRequests.isEmpty) {
          _errorMessage = result['message'] ?? 'فشل تحميل طلبات الصيانة';
        }
      }
    } catch (e) {
      if (_maintenanceRequests.isEmpty) {
        _errorMessage = 'حدث خطأ: $e';
      }
      print('❌ Error loading maintenance: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Submit a new maintenance request
  Future<bool> submitRequest({
    required String category,
    required String description,
  }) async {
    if (category.isEmpty || description.isEmpty) {
      _errorMessage = 'يرجى ملء نوع الصيانة والوصف';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final result = await _dataRepository.submitMaintenance(
        category: category,
        description: description,
      );

      if (result['success'] == true) {
        _successMessage = 'تم إرسال طلب الصيانة بنجاح';

        // Refresh list
        await getMaintenanceRequests();

        return true;
      } else {
        _errorMessage = result['message'] ?? 'فشل إرسال الطلب';
        return false;
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء الإرسال: $e';
      return false;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  void clearSuccessMessage() {
    _successMessage = null;
    notifyListeners();
  }

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }
}