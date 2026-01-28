import 'package:flutter/foundation.dart';
import '../repositories/data_repository.dart';

/// NotificationsViewModel: State management for Notifications feature
/// 
/// Extends ChangeNotifier to provide reactive updates to UI
/// Injects DataRepository as single source of truth
class NotificationsViewModel extends ChangeNotifier {
  final DataRepository _repository;

  // State variables
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters for UI access
  List<Map<String, dynamic>> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Constructor with dependency injection
  NotificationsViewModel({DataRepository? repository})
      : _repository = repository ?? DataRepository();

  /// Load notifications list
  /// 
  /// Fetches notifications from repository and updates state
  Future<void> loadNotifications() async {
    _setLoading(true);
    _clearMessages();

    try {
      final result = await _repository.getNotifications();

      if (result['success'] == true) {
        _notifications = List<Map<String, dynamic>>.from(
          result['data'] ?? [],
        );
        print('✅ Notifications loaded successfully - Count: ${_notifications.length}');
      } else {
        _errorMessage = result['message'] ?? 'فشل تحميل الإشعارات';
        print('❌ Error: $_errorMessage');
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ غير متوقع: $e';
      print('❌ Exception: $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
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

  /// Clear error messages
  void _clearMessages() {
    _errorMessage = null;
  }
}
