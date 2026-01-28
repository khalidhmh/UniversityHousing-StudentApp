import 'package:flutter/foundation.dart';
import '../repositories/data_repository.dart';

/// ClearanceViewModel: State management for Clearance feature
///
/// Implements REACTIVE CACHE-FIRST pattern:
/// 1. Set isLoading = true
/// 2. Fetch from cache (local DB) - if exists, update UI immediately
/// 3. Fetch from API in background - if new data, update UI again
/// 4. Set isLoading = false in finally block
///
/// Error Strategy:
/// - If API fails but cache exists: Show cache data, do NOT clear
/// - Only show error message if data is empty
class ClearanceViewModel extends ChangeNotifier {
  // ============================================================================
  // DEPENDENCIES
  // ============================================================================
  final DataRepository _repository;

  // ============================================================================
  // STATE VARIABLES
  // ============================================================================
  Map<String, dynamic>? _clearanceData;
  bool _hasActiveRequest = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // ============================================================================
  // GETTERS
  // ============================================================================
  Map<String, dynamic>? get clearanceData => _clearanceData;
  bool get hasActiveRequest => _hasActiveRequest;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// Constructor with dependency injection
  ClearanceViewModel({DataRepository? repository})
    : _repository = repository ?? DataRepository();

  // ============================================================================
  // PUBLIC METHODS
  // ============================================================================

  /// Load current clearance status using REACTIVE CACHE-FIRST pattern:
  /// 1. Set isLoading = true
  /// 2. Fetch from cache - if exists, update UI immediately
  /// 3. Fetch from API in background - if new data, update UI again
  /// 4. Set isLoading = false
  ///
  /// Handles:
  /// - If status exists -> set hasActiveRequest = true
  /// - If 404/null -> set hasActiveRequest = false
  /// - Error handling with user-friendly messages
  Future<void> loadStatus() async {
    // Step 1: Set loading state
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Step 2: Fetch from Repository (cache-first strategy)
      final result = await _repository.getClearanceStatus();

      if (result['success'] == true && result['data'] != null) {
        // Parse and update state
        _clearanceData = result['data'];
        _hasActiveRequest = true;
        _errorMessage = null;

        print(
          '✅ Clearance status loaded (from ${result['fromCache'] == true ? 'CACHE' : 'API'})',
        );
      } else {
        // No active clearance - this is OK, not an error
        if (_clearanceData == null) {
          _clearanceData = null;
          _hasActiveRequest = false;
        }
        print('✅ No active clearance request');
      }
    } catch (e) {
      // Exception - only show if no cached data
      if (_clearanceData == null) {
        _errorMessage = 'حدث خطأ في تحميل الحالة: $e';
      } else {
        print('⚠️ Exception (showing cached data): $e');
      }
      _hasActiveRequest = false;
      print('❌ Exception: $e');
    } finally {
      // Step 4: Always clear loading state
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Start the clearance process
  ///
  /// Initiates a new clearance request
  /// On success, updates clearanceData and hasActiveRequest
  Future<bool> startClearanceProcess() async {
    // Step 1: Set loading state
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      // Step 2: Call API via repository (NOT directly to ApiService)
      final result = await _repository.initiateClearance();

      if (result['success'] == true) {
        // Success: Update state with new clearance data
        _clearanceData = result['data'];
        _hasActiveRequest = true;
        _successMessage = 'تم بدء إجراءات إخلاء الطرف بنجاح';
        _errorMessage = null;

        print('✅ Clearance process started successfully');
        notifyListeners();
        return true;
      } else {
        // API error
        _errorMessage = result['message'] ?? 'فشل بدء الإجراءات';
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
      // Always clear loading state
      _isLoading = false;
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

  // ===== Private Helpers =====

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
  }

  /// Clear both error and success messages
  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }
}
