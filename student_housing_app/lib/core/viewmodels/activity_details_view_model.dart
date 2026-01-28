import 'package:flutter/material.dart';
import '../repositories/data_repository.dart';

class ActivityDetailsViewModel extends ChangeNotifier {
  // ============================================================================
  // DEPENDENCIES
  // ============================================================================
  final DataRepository _dataRepository = DataRepository();

  // ============================================================================
  // STATE VARIABLES
  // ============================================================================
  Map<String, dynamic>? _activity;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  // ============================================================================
  // GETTERS
  // ============================================================================
  Map<String, dynamic>? get activity => _activity;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  // Check if subscribed based on local data
  bool get isSubscribed {
    if (_activity == null) return false;
    return _activity!['is_subscribed'] == true || _activity!['is_subscribed'] == 1;
  }

  // ============================================================================
  // PUBLIC METHODS
  // ============================================================================

  /// Initialize Data
  void setInitialData(Map<String, dynamic> data) {
    _activity = data;
    notifyListeners();
  }

  /// The Main Action: Toggle Subscription
  Future<void> toggleSubscription(BuildContext context) async {
    if (_activity == null) return;

    if (isSubscribed) {
      await _unsubscribe(context);
    } else {
      await _subscribe(context);
    }
  }

  // ============================================================================
  // PRIVATE HELPERS (Logic Implementation)
  // ============================================================================

  /// Logic: Subscribe (Smart & Self-Healing)
  Future<void> _subscribe(BuildContext context) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _dataRepository.subscribeToActivity(_activity!['id']);

      if (result['success'] == true) {
        // نجاح طبيعي
        _successMessage = 'تم الاشتراك بنجاح!';
        _updateLocalState(isSubscribed: true, incrementCount: true);
      }
      // ✅ الحل السحري: معالجة حالة "مشترك بالفعل"
      else if (result['message'].toString().contains('already subscribed') ||
          result['message'].toString().contains('409')) {

        _successMessage = 'تم تحديث حالة الاشتراك';
        // التطبيق كان فاكر غلط، ودلوقتي هنصحح المعلومة ونخليه "مشترك"
        _updateLocalState(isSubscribed: true, incrementCount: false);

      } else {
        _errorMessage = result['message'] ?? 'فشل الاشتراك';
        _showSnackBar(context, _errorMessage!, isError: true);
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ: $e';
      _showSnackBar(context, _errorMessage!, isError: true);
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Logic: Unsubscribe
  Future<void> _unsubscribe(BuildContext context) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _dataRepository.unsubscribeFromActivity(_activity!['id']);

      if (result['success'] == true) {
        _successMessage = 'تم إلغاء الاشتراك بنجاح';

        // ✅ استخدام الدالة المساعدة هنا كمان عشان الكود يبقى أنظف
        _updateLocalState(isSubscribed: false, incrementCount: false);

      } else {
        _errorMessage = result['message'] ?? 'فشل إلغاء الاشتراك';
        _showSnackBar(context, _errorMessage!, isError: true);
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ: $e';
      _showSnackBar(context, _errorMessage!, isError: true);
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  // ✅ الدالة الموحدة لتحديث الحالة
  void _updateLocalState({required bool isSubscribed, bool incrementCount = false}) {
    if (_activity == null) return;

    _activity!['is_subscribed'] = isSubscribed;

    if (incrementCount) {
      _activity!['participant_count'] = (_activity!['participant_count'] ?? 0) + 1;
    } else if (!isSubscribed && (_activity!['participant_count'] ?? 0) > 0) {
      // بننقص العدد لو بنلغي الاشتراك
      _activity!['participant_count'] = _activity!['participant_count'] - 1;
    }

    notifyListeners();
  }

  /// Helper to show SnackBars
  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}