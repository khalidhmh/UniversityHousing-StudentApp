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
  // Returns filtered list if filter is active, otherwise all complaints
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

  /// Fetch complaints using REACTIVE CACHE-FIRST pattern
  Future<void> getComplaints() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Try to get data (Repo handles Cache + API logic)
      final result = await _dataRepository.getComplaints();

      if (result['success'] == true) {
        final data = result['data'] ?? [];
        _complaints = List<Map<String, dynamic>>.from(data);
        _errorMessage = null;

        // Re-apply current filter on new data
        _applyFilter(_selectedFilter);

        print('✅ Complaints loaded (${_complaints.length} items)');
      } else {
        // Only show error if we have NO data to show
        if (_complaints.isEmpty) {
          _errorMessage = result['message'] ?? 'فشل تحميل الشكاوى';
        }
      }
    } catch (e) {
      if (_complaints.isEmpty) {
        _errorMessage = 'حدث خطأ: $e';
      }
      print('❌ Error loading complaints: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Submit a new complaint
  Future<bool> submitComplaint({
    required String title,
    required String description,
    required String recipient,
    required bool isSecret,
  }) async {
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
      final result = await _dataRepository.submitComplaint(
        title: title,
        description: description,
        recipient: recipient,
        isSecret: isSecret,
      );

      if (result['success'] == true) {
        _successMessage = 'تم إرسال الشكوى بنجاح';

        // Refresh the list to show the new item
        await getComplaints();

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

  /// Filter complaints by status
  void filterComplaints(String filterType) {
    _selectedFilter = filterType;
    _applyFilter(filterType);
    notifyListeners();
  }

  void _applyFilter(String filterType) {
    if (filterType == 'all') {
      _filteredComplaints = List.from(_complaints);
    } else if (filterType == 'pending') {
      _filteredComplaints = _complaints.where((c) {
        final status = c['status']?.toString().toLowerCase() ?? '';
        return status == 'pending' || status == 'قيد الانتظار';
      }).toList();
    } else if (filterType == 'resolved') {
      _filteredComplaints = _complaints.where((c) {
        final status = c['status']?.toString().toLowerCase() ?? '';
        return status != 'pending' && status != 'قيد الانتظار';
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