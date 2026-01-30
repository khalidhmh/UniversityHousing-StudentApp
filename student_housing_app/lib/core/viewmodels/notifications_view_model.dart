import 'package:flutter/material.dart';
import '../repositories/data_repository.dart';

class NotificationsViewModel extends ChangeNotifier {
  final DataRepository _repository = DataRepository();

  bool _isLoading = false;
  List<Map<String, dynamic>> _notifications = [];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get notifications => _notifications;
  String? get errorMessage => _errorMessage;

  // عدد الإشعارات غير المقروءة
  int get unreadCount => _notifications.where((n) => n['is_read'] == false || n['is_read'] == 0).length;

  // ✅ توحيد الاسم: loadNotifications
  Future<void> loadNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getNotifications();
      if (result['success']) {
        _notifications = List<Map<String, dynamic>>.from(result['data']);

        // ترتيب الإشعارات: الأحدث أولاً
        _notifications.sort((a, b) {
          final dateA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(2000);
          final dateB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(2000);
          return dateB.compareTo(dateA);
        });
      } else {
        _errorMessage = result['message'];
      }
    } catch (e) {
      _errorMessage = 'فشل تحميل الإشعارات';
      print('Error fetching notifications: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ✅ تحديد الإشعار كمقروء
  Future<void> markAsRead(int id) async {
    final index = _notifications.indexWhere((n) => n['id'] == id);
    if (index != -1) {
      // تحديث الواجهة فوراً (Optimistic UI)
      _notifications[index]['is_read'] = true;
      notifyListeners();

      // إرسال الطلب للسيرفر (لو الـ API جاهز)
      // await _repository.markNotificationAsRead(id); 
    }
  }
}