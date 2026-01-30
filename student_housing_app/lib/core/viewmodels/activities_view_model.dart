import 'package:flutter/material.dart';
import '../repositories/data_repository.dart';

class ActivitiesViewModel extends ChangeNotifier {
  final DataRepository _repository = DataRepository();

  bool _isLoading = false;
  List<Map<String, dynamic>> _activities = [];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get activities => _activities;
  String? get errorMessage => _errorMessage;

  // ✅ تم تغيير الاسم من fetchActivities إلى loadActivities ليتوافق مع الشاشة
  Future<void> loadActivities({bool forceRefresh = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _repository.getActivities(forceRefresh: forceRefresh);
      if (result['success']) {
        _activities = List<Map<String, dynamic>>.from(result['data']);
      } else {
        _errorMessage = result['message'];
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ في الاتصال';
    }

    _isLoading = false;
    notifyListeners();
  }

  // ✅ الاشتراك في نشاط
  Future<bool> subscribeToActivity(int activityId) async {
    // 1. تحديث واجهة المستخدم فوراً (Optimistic Update)
    final index = _activities.indexWhere((a) => a['id'] == activityId);
    if (index != -1) {
      _activities[index]['is_subscribed'] = 1; // أو true حسب الداتا بييز
      notifyListeners();
    }

    // 2. إرسال الطلب للسيرفر
    final result = await _repository.subscribeToActivity(activityId);

    if (!result['success']) {
      // لو فشل، نرجع الحالة زي ما كانت
      if (index != -1) {
        _activities[index]['is_subscribed'] = 0;
        notifyListeners();
      }
      return false;
    }
    return true;
  }

  // ✅ إلغاء الاشتراك
  Future<bool> unsubscribeFromActivity(int activityId) async {
    final index = _activities.indexWhere((a) => a['id'] == activityId);
    if (index != -1) {
      _activities[index]['is_subscribed'] = 0;
      notifyListeners();
    }

    final result = await _repository.unsubscribeFromActivity(activityId);

    if (!result['success']) {
      if (index != -1) {
        _activities[index]['is_subscribed'] = 1;
        notifyListeners();
      }
      return false;
    }
    return true;
  }
}