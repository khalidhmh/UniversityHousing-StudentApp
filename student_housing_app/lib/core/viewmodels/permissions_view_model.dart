import 'package:flutter/foundation.dart';
import '../repositories/data_repository.dart';

/// PermissionsViewModel: State management for Permissions feature
///
/// Implements REACTIVE CACHE-FIRST pattern:
/// 1. Set isLoading = true
/// 2. Fetch from cache (local DB) - if exists, update UI immediately
/// 3. Fetch from API in background - if new data, update UI again
/// 4. Set isLoading = false in finally block
///
/// Error Strategy:
/// - If API fails but cache exists: Show cache data, do NOT clear list
/// - Only show error message if list is empty
class PermissionsViewModel extends ChangeNotifier {
  // ============================================================================
  // DEPENDENCIES
  // ============================================================================
  final DataRepository _repository;

  // ============================================================================
  // STATE VARIABLES (Initialize as empty lists, never null)
  // ============================================================================
  List<Map<String, dynamic>> _permissionRequests = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  // ============================================================================
  // GETTERS
  // ============================================================================
  List<Map<String, dynamic>> get permissionRequests => _permissionRequests;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// Constructor with dependency injection
  PermissionsViewModel({DataRepository? repository})
    : _repository = repository ?? DataRepository();

  // ============================================================================
  // PUBLIC METHODS
  // ============================================================================

  /// Fetch all permission requests for the current student
  ///
  /// Uses REACTIVE CACHE-FIRST pattern:
  /// 1. Set isLoading = true
  /// 2. Fetch from cache - if exists, update UI immediately
  /// 3. Fetch from API in background - if new data, update UI again
  /// 4. Set isLoading = false
  ///
  /// Error Strategy:
  /// - If API fails but cache exists: Show cache data
  /// - Only show error if list is empty
  Future<void> getPermissions() async {
    // Step 1: Set loading state
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Step 2: Fetch from Repository (cache-first strategy)
      final result = await _repository.getPermissions();

      if (result['success'] == true) {
        // Parse and update state
        _permissionRequests = List<Map<String, dynamic>>.from(
          result['data'] ?? [],
        );
        _errorMessage = null;

        print(
          '✅ Permissions loaded (${_permissionRequests.length} items, from ${result['fromCache'] == true ? 'CACHE' : 'API'})',
        );
      } else {
        // API error - only show if no cache exists
        final errorMsg = result['message'] ?? 'فشل تحميل الطلبات';
        if (_permissionRequests.isEmpty) {
          _errorMessage = errorMsg;
        } else {
          print('⚠️ API Error (showing cached data): $errorMsg');
        }
        print('❌ Error: ${result['message']}');
      }
    } catch (e) {
      // Exception - only show if no cache exists
      if (_permissionRequests.isEmpty) {
        _errorMessage = 'حدث خطأ غير متوقع: $e';
      } else {
        print('⚠️ Exception (showing cached data): $e');
      }
      print('❌ Exception: $e');
    } finally {
      // Step 4: Always clear loading state
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Submit a new permission request
  ///
  /// Validates input and submits to repository
  /// Refreshes the list on success
  ///
  /// Parameters:
  /// - [type]: Permission type (e.g., 'تصريح مبيت', 'دخول متأخر')
  /// - [reason]: Reason for the request
  /// - [startDate]: Start date in format 'YYYY-MM-DD'
  /// - [endDate]: End date in format 'YYYY-MM-DD'
  Future<bool> requestPermission({
    required String type,
    required String reason,
    required String startDate,
    required String endDate,
  }) async {
    // Step 1: Validate inputs
    if (type.isEmpty ||
        reason.isEmpty ||
        startDate.isEmpty ||
        endDate.isEmpty) {
      _errorMessage = 'يرجى ملء جميع الحقول المطلوبة';
      notifyListeners();
      return false;
    }

    // Step 2: Set submitting state
    _isSubmitting = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Step 3: Call API via repository (NOT directly to ApiService)
      final result = await _repository.requestPermission(
        type: type,
        reason: reason,
        startDate: startDate,
        endDate: endDate,
      );

      if (result['success'] == true) {
        // Success: Refresh list to show new request
        _successMessage = 'تم إرسال طلب التصريح بنجاح';
        print('✅ Permission request submitted successfully');

        // Refresh the list in background
        await getPermissions();
        return true;
      } else {
        // API error
        _errorMessage = result['message'] ?? 'فشل إرسال الطلب';
        print('❌ Error: $_errorMessage');
        notifyListeners();
        return false;
      }
    } catch (e) {
      // Exception handling
      _errorMessage = 'خطأ في الاتصال: $e';
      print('❌ Exception: $e');
      notifyListeners();
      return false;
    } finally {
      // Always clear submitting state
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Clear success message
  void clearSuccessMessage() {
    _successMessage = null;
    notifyListeners();
  }

  /// Clear error message
  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============================================================================
  // PRIVATE HELPERS
  // ============================================================================

  /// Set loading state and notify listeners
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Set submitting state and notify listeners
  void _setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }

  /// Clear both error and success messages
  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }
}
