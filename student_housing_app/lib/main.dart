import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

// ✅ استيراد كل الـ ViewModels
import 'core/viewmodels/announcements_view_model.dart';
import 'core/viewmodels/profile_view_model.dart';
import 'core/viewmodels/notifications_view_model.dart';
import 'core/viewmodels/activities_view_model.dart'; // جديد
import 'core/viewmodels/complaints_view_model.dart'; // جديد
import 'core/viewmodels/maintenance_view_model.dart'; // جديد
import 'core/viewmodels/permissions_view_model.dart'; // جديد
import 'core/viewmodels/clearance_view_model.dart'; // جديد

import 'ui/screens/login_screen.dart';

void main() {
  runApp(const StudentHousingApp());
}

// Custom scroll behavior for web/desktop dragging
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

class StudentHousingApp extends StatelessWidget {
  const StudentHousingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // ✅ هنا بنسجل كل "الأدمغة" (ViewModels) عشان الشاشات تشوفها
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationsViewModel()),

        // 👇 دول اللي كانوا ناقصين وعاملين الشاشة الحمراء
        ChangeNotifierProvider(create: (_) => ActivitiesViewModel()),
        ChangeNotifierProvider(create: (_) => ComplaintsViewModel()),
        ChangeNotifierProvider(create: (_) => MaintenanceViewModel()),
        ChangeNotifierProvider(create: (_) => PermissionsViewModel()),
        ChangeNotifierProvider(create: (_) => ClearanceViewModel()),
        ChangeNotifierProvider(create: (_) => AnnouncementsViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'جامعة العاصمة - سكن الطلاب',

        // إعدادات اللغة العربية
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('ar', 'EG')],
        locale: const Locale('ar', 'EG'),

        scrollBehavior: MyCustomScrollBehavior(),
        theme: ThemeData(
          primaryColor: const Color(0xFF001F3F),
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
          useMaterial3: true,
        ),

        // صفحة البداية
        home: const LoginScreen(),
      ),
    );
  }
}