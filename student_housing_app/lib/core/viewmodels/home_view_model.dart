import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/data_repository.dart';

class HomeViewModel extends ChangeNotifier {
  // ✅ استخدام الـ Repository (الحقيقة الواحدة)
  final DataRepository _repository = DataRepository();

  // --- الحالة (State) ---
  bool isLoading = true;
  String studentName = "جاري التحميل...";
  String studentId = ""; // ✅ رقم الطالب (يستخدم في الـ QR Code)
  bool isCheckedIn = false;
  bool isAlarmSet = false;
  List<Map<String, dynamic>> announcements = [];

  // --- دوال التحكم (Actions) ---

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    // 1. تحميل بيانات الطالب (الاسم و الرقم) من الريبو
    final profileRes = await _repository.getStudentProfile();
    if (profileRes['success'] == true && profileRes['data'] != null) {
      studentName = profileRes['data']['full_name'] ?? "طالب";
      // استخراج رقم الطالب (student_id أو national_id أو id)
      studentId = profileRes['data']['student_id'] ?? 
                  profileRes['data']['national_id'] ?? 
                  profileRes['data']['id'] ?? 
                  "0";
    } else {
      // Fallback لو مفيش داتا لسه
      final prefs = await SharedPreferences.getInstance();
      studentName = prefs.getString('student_name') ?? "طالب";
      studentId = prefs.getString('student_id') ?? "0";
    }

    // 2. تحميل حالة التمام من الريبو
    final attendanceRes = await _repository.getAttendance();
    if (attendanceRes['success'] == true) {
      // منطق حساب "هل حضرت اليوم؟"
      // (ممكن ننقل المنطق ده للريبو مستقبلاً لتبسيط الـ VM)
      final List logs = attendanceRes['data'] ?? [];
      final now = DateTime.now();
      final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      
      isCheckedIn = logs.any((log) {
        String logDate = log['date'].toString();
        return logDate.startsWith(todayStr) && log['status'] == 'Present';
      });
    }

    // 3. تحميل الإعلانات من الريبو (بدل الـ LocalDB المباشر)
    final announceRes = await _repository.getAnnouncements();
    if (announceRes['success'] == true) {
      announcements = List<Map<String, dynamic>>.from(announceRes['data']);
    }

    isLoading = false;
    notifyListeners();
  }

  void toggleAlarm(BuildContext context) {
    isAlarmSet = !isAlarmSet;
    notifyListeners();
    String message = isAlarmSet ? "تم تفعيل المنبه! 10:30 م" : "تم إلغاء المنبه";
    Color color = isAlarmSet ? Colors.green : Colors.grey;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  Map<String, dynamic> getRollCallStatusUI() {
    final now = DateTime.now();
    int status;
    if (isCheckedIn) {
      status = 1; // تم
    } else if ((now.hour == 0 && now.minute > 30) || (now.hour > 0 && now.hour < 11)) {
      status = 2; // تأخير
    } else {
      status = 0; // انتظار
    }

    switch (status) {
      case 1:
        return {'status': 1, 'color': Colors.green, 'title': "تم التمام", 'subtitle': "تم تسجيل حضورك اليوم", 'icon': Icons.check_circle, 'bg_color': const Color(0xFFE8F5E9)};
      case 2:
        return {'status': 2, 'color': Colors.red, 'title': "لم يتم التمام", 'subtitle': "تم تسجيل غياب", 'icon': Icons.cancel, 'bg_color': const Color(0xFFFFEBEE)};
      default:
        return {'status': 0, 'color': const Color(0xFFF2C94C), 'title': "في انتظار التمام", 'subtitle': "متاح من 11:00 م", 'icon': Icons.access_time_filled, 'bg_color': const Color(0xFFFFF8E1)};
    }
  }
}