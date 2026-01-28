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

  /// ✅ REFACTORED: Smart Loading - Prefs First, Then API
  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    try {
      // ========================================
      // PHASE 1: Load from SharedPreferences (INSTANT)
      // ========================================
      final prefs = await SharedPreferences.getInstance();

      // قراءة البيانات المحفوظة بسرعة (من الذاكرة، لا من الـ API)
      final cachedName = prefs.getString('student_name') ?? 'طالب';
      final cachedId = prefs.getString('student_id') ?? '0';

      // تحديث الـ state فوراً (لن ننتظر API)
      studentName = cachedName;
      studentId = cachedId;
      notifyListeners();

      print('✅ Loaded from SharedPreferences: $cachedName (ID: $cachedId)');

      // ========================================
      // PHASE 2: Fetch Fresh Data from API (في الخلفية)
      // ========================================

      // 1. تحميل بيانات الطالب من الـ API
      final profileRes = await _repository.getStudentProfile();

      if (profileRes['success'] == true && profileRes['data'] != null) {
        // API can return 'name' or 'full_name' - try both
        final freshName =
            profileRes['data']['name'] ??
            profileRes['data']['full_name'] ??
            cachedName;
        final freshId =
            (profileRes['data']['student_id'] ??
                    profileRes['data']['national_id'] ??
                    profileRes['data']['id'] ??
                    cachedId)
                .toString();

        // تحديث الـ state بالبيانات الجديدة (إن تغيرت)
        if (freshName != studentName || freshId != studentId) {
          studentName = freshName;
          studentId = freshId;

          // حفظ الـ update في SharedPreferences
          await prefs.setString('student_name', freshName);
          await prefs.setString('student_id', freshId);

          print('🔄 Updated from API: $freshName (ID: $freshId)');
          notifyListeners();
        }
      }

      // 2. تحميل حالة الحضور (مع الإصلاح: case-insensitive + date format)
      final attendanceRes = await _repository.getAttendance();
      if (attendanceRes['success'] == true) {
        final List logs = attendanceRes['data'] ?? [];
        final now = DateTime.now();

        // ✅ تنسيق التاريخ الصحيح: YYYY-MM-DD
        final todayStr =
            "${now.year}-"
            "${now.month.toString().padLeft(2, '0')}-"
            "${now.day.toString().padLeft(2, '0')}";

        // ✅ البحث عن حضور اليوم مع مقارنة case-insensitive
        isCheckedIn = logs.any((log) {
          final logDate = log['date']?.toString() ?? '';
          final status = (log['status'] ?? '')
              .toString()
              .toLowerCase(); // ✅ تحويل إلى حروف صغيرة

          // ✅ التحقق من التاريخ والحالة بشكل صحيح
          return logDate.startsWith(todayStr) &&
              (status == 'present' || status == 'attend' || status == 'حاضر');
        });

        print('📍 Attendance Check: ${isCheckedIn ? 'Present' : 'Absent'}');
      }

      // 3. تحميل الإعلانات
      final announceRes = await _repository.getAnnouncements();
      if (announceRes['success'] == true) {
        announcements = List<Map<String, dynamic>>.from(
          announceRes['data'] ?? [],
        );
      }
    } catch (e) {
      print("❌ Error loading home data: $e");

      // ✅ Fallback: إذا فشل كل شيء، على الأقل لدينا البيانات من SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      studentName = prefs.getString('student_name') ?? 'طالب';
      studentId = prefs.getString('student_id') ?? '0';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void toggleAlarm(BuildContext context) {
    isAlarmSet = !isAlarmSet;
    notifyListeners();
    String message = isAlarmSet
        ? "تم تفعيل المنبه! 10:30 م"
        : "تم إلغاء المنبه";
    Color color = isAlarmSet ? Colors.green : Colors.grey;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  /// ✅ Smart Roll Call Status Logic
  Map<String, dynamic> getRollCallStatusUI() {
    final now = DateTime.now();
    int status;

    // 1. لو الطالب سجل حضور خلاص
    if (isCheckedIn) {
      status = 1; // تم التمام
    }
    // 2. لو لسه مسجلش، بنشوف الوقت
    // فترة السماح: من 11 بالليل (23:00) لحد الفجر مثلاً
    // أو حسب اللوجيك بتاعك: لو الوقت عدى ومسجلش يبقى غياب
    else if ((now.hour == 0 && now.minute > 30) ||
        (now.hour > 0 && now.hour < 11)) {
      status = 2; // لم يتم (تأخير/غياب)
    } else {
      status = 0; // في الانتظار
    }

    switch (status) {
      case 1:
        return {
          'status': 1,
          'color': Colors.green,
          'title': "تم التمام",
          'subtitle': "تم تسجيل حضورك اليوم",
          'icon': Icons.check_circle,
          'bg_color': const Color(0xFFE8F5E9),
        };
      case 2:
        return {
          'status': 2,
          'color': Colors.red,
          'title': "لم يتم التمام",
          'subtitle': "يرجى تسجيل الحضور",
          'icon': Icons.cancel,
          'bg_color': const Color(0xFFFFEBEE),
        };
      default:
        return {
          'status': 0,
          'color': const Color(0xFFF2C94C),
          'title': "في انتظار التمام",
          'subtitle': "متاح من 11:00 م",
          'icon': Icons.access_time_filled,
          'bg_color': const Color(0xFFFFF8E1),
        };
    }
  }
}
