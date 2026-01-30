import 'package:flutter/material.dart';
import '../repositories/data_repository.dart';

class ComplaintsViewModel extends ChangeNotifier {
  // ============================================================================
  // DEPENDENCIES
  // ============================================================================
  final DataRepository _dataRepository = DataRepository();

  // ============================================================================
  // STATE VARIABLES
  // ============================================================================
  List<Map<String, dynamic>> _complaints = [];
  List<Map<String, dynamic>> _filteredComplaints = [];

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  String _selectedFilter = 'all'; // all, pending, resolved

  // ============================================================================
  // GETTERS
  // ============================================================================
  List<Map<String, dynamic>> get complaints {
    if (_selectedFilter == 'all') {
      return _complaints;
    }
    return _filteredComplaints;
  }

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String get selectedFilter => _selectedFilter;
  int get complaintCount => _complaints.length;

  // ============================================================================
  // PUBLIC METHODS
  // ============================================================================

  /// ✅ Fetch complaints (Renamed to fetchComplaints for consistency)
  Future<void> fetchComplaints() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _dataRepository.getComplaints();

      if (result['success'] == true) {
        final data = result['data'] ?? [];
        _complaints = List<Map<String, dynamic>>.from(data);
        _errorMessage = null;

        // Re-apply filter
        _applyFilter(_selectedFilter);
      } else {
        if (_complaints.isEmpty) {
          _errorMessage = result['message'] ?? 'فشل تحميل الشكاوى';
        }
      }
    } catch (e) {
      if (_complaints.isEmpty) {
        _errorMessage = 'حدث خطأ: $e';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ✅ Submit a new complaint (Removed recipient & isSecret)
  Future<bool> submitComplaint(String title, String description) async {
    if (title.isEmpty || description.isEmpty) {
      _errorMessage = 'يرجى ملء العنوان والتفاصيل';
      notifyListeners();
      return false;
    }

    _isSubmitting = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      // ✅ Updated to match DataRepository signature
      final result = await _dataRepository.submitComplaint(
        title: title,
        description: description,
      );

      if (result['success'] == true) {
        _successMessage = 'تم إرسال الشكوى بنجاح';
        
        // Refresh list
        await fetchComplaints();
        return true;
      } else {
        _errorMessage = result['message'] ?? 'فشل إرسال الشكوى';
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

  /// Filter complaints logic
  void filterComplaints(String filterType) {
    _selectedFilter = filterType;
    _applyFilter(filterType);
    notifyListeners();
  }

  void _applyFilter(String filterType) {
    if (filterType == 'all') {
      _filteredComplaints = List.from(_complaints);
    } else {
      _filteredComplaints = _complaints.where((c) {
        final status = c['status']?.toString().toLowerCase() ?? '';
        
        if (filterType == 'pending') {
          return status == 'pending' || status == 'قيد الانتظار';
        } else if (filterType == 'resolved') {
          // أي حالة غير معلقة تعتبر منتهية (تم الرد / تم الحل / مرفوضة)
          return status != 'pending' && status != 'قيد الانتظار';
        }
        return true;
      }).toList();
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