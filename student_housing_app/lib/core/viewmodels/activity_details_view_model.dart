import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/data_repository.dart';
import 'activities_view_model.dart';

class ActivityDetailsViewModel extends ChangeNotifier {
  final DataRepository _dataRepository = DataRepository();

  Map<String, dynamic>? _activity;
  bool _isSubmitting = false;
  bool _isSubscribed = false; // القيمة الحقيقية المتحكمة في الزر

  // ============================================================================
  // GETTERS
  // ============================================================================
  Map<String, dynamic>? get activity => _activity;
  bool get isSubmitting => _isSubmitting;
  bool get isSubscribed => _isSubscribed;

  // ============================================================================
  // PUBLIC METHODS
  // ============================================================================

  /// Initialize Data
  void setInitialData(Map<String, dynamic> data) {
    _activity = data;
    // ✅ تصحيح: قراءة حالة الاشتراك فوراً من البيانات الممررة
    final subVal = data['is_subscribed'];
    _isSubscribed = (subVal == 1 || subVal == true);
    notifyListeners();
  }

  /// التبديل الذكي بين الاشتراك وإلغاء الاشتراك
  Future<void> toggleSubscription(BuildContext context) async {
    if (_activity == null || _isSubmitting) return;

    _isSubmitting = true;
    notifyListeners();

    // الوصول للـ Main ViewModel لتحديث القائمة الرئيسية
    final mainVM = Provider.of<ActivitiesViewModel>(context, listen: false);
    bool success;
    int activityId = _activity!['id'];

    // تنفيذ العملية بناءً على الحالة الحالية
    if (_isSubscribed) {
      success = await mainVM.unsubscribeFromActivity(activityId);
    } else {
      success = await mainVM.subscribeToActivity(activityId);
    }

    if (success) {
      // ✅ تحديث الحالة المحلية بنجاح
      _isSubscribed = !_isSubscribed;
      _updateLocalState(isSubscribed: _isSubscribed);

      _showSnackBar(context, _isSubscribed ? "تم الاشتراك بنجاح" : "تم إلغاء الاشتراك");
    } else {
      // في حالة الفشل، الـ MainViewModel غالباً رجع الحالة لأصلها، فنظهر تنبيه
      _showSnackBar(context, "فشل في تحديث طلبك، حاول مرة أخرى", isError: true);
    }

    _isSubmitting = false;
    notifyListeners();
  }

  // ============================================================================
  // PRIVATE HELPERS
  // ============================================================================

  /// تحديث بيانات الـ Map المحلي للنشاط لضمان اتساق البيانات
  void _updateLocalState({required bool isSubscribed}) {
    if (_activity == null) return;

    // تحديث القيمة داخل الـ Map
    _activity!['is_subscribed'] = isSubscribed ? 1 : 0;

    // تحديث عداد المشاركين (اختياري لو بتستخدمه في الـ UI)
    if (_activity!.containsKey('participant_count')) {
      if (isSubscribed) {
        _activity!['participant_count'] = (_activity!['participant_count'] ?? 0) + 1;
      } else {
        if ((_activity!['participant_count'] ?? 0) > 0) {
          _activity!['participant_count'] = _activity!['participant_count'] - 1;
        }
      }
    }
    notifyListeners();
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}