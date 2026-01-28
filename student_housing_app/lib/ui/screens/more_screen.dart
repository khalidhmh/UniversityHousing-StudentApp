import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/repositories/data_repository.dart';
import '../../core/services/auth_service.dart';
import 'maintenance_screen.dart';
import 'complaints_history_screen.dart';
import 'notifications_screen.dart';
import 'clearance_screen.dart';
import 'login_screen.dart';
import '../../core/repositories/data_repository.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
            decoration: const BoxDecoration(
              color: Color(0xFF001F3F),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Text(
              'المزيد',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Menu Items
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildMenuItem(
                        context,
                        'الإشعارات',
                        Icons.notifications,
                        const Color(0xFFFF6B6B),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationsScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildMenuItem(
                        context,
                        'الشكاوى',
                        Icons.chat_bubble,
                        const Color(0xFF4A90E2),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ComplaintsHistoryScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildMenuItem(
                        context,
                        'الصيانة',
                        Icons.build,
                        const Color(0xFFFFA500),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MaintenanceScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildMenuItem(
                        context,
                        'إخلاء الطرف',
                        Icons.verified_user,
                        const Color(0xFF2ECB71),
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ClearanceScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildMenuItem(
                        context,
                        'عن التطبيق',
                        Icons.info,
                        const Color(0xFF9B59B6),
                        () {
                          _showAboutDialog(context);
                        },
                      ),
                      const SizedBox(height: 40),
                      // Logout Button
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            _showLogoutConfirmation(context);
                          },
                          child: Text(
                            'تسجيل الخروج',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFF6B6B),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Version Footer
                      Center(
                        child: Text(
                          'Version 2.0.1 (Build 2026)',
                          style: GoogleFonts.cairo(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Circular Icon Background
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            // Title with Arrow
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF001F3F),
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'عن التطبيق',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF001F3F),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAboutRow('اسم التطبيق', 'تطبيق السكن الجامعي'),
              const SizedBox(height: 12),
              _buildAboutRow('الإصدار', '2.0.1'),
              const SizedBox(height: 12),
              _buildAboutRow('البناء', '2026'),
              const SizedBox(height: 12),
              _buildAboutRow('الجهة المطورة', 'وحدة تكنولوجيا المعلومات'),
              const SizedBox(height: 16),
              Text(
                'الغرض',
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF001F3F),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'توفير منصة رقمية متكاملة لإدارة شؤون الطلاب والطالبات بالمدينة الجامعية.',
                style: GoogleFonts.cairo(
                  fontSize: 13,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'حسناً',
              style: GoogleFonts.cairo(color: const Color(0xFF001F3F)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF001F3F),
            fontSize: 13,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'تسجيل الخروج',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF001F3F),
          ),
        ),
        content: Text(
          'هل تريد بالفعل تسجيل الخروج من التطبيق؟',
          style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: GoogleFonts.cairo(color: const Color(0xFF001F3F)),
            ),
          ),
          // ✅ NEW: Enhanced logout with clearSession()
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // قفل الدايلوج

              // ✅ Single call to clearSession() handles everything:
              // 1. Clears SharedPreferences (auth_token, student_name, student_id, user_role, etc.)
              // 2. Clears SQLite database (all tables)
              final authService = AuthService();
              await authService.clearSession();

              // Navigate back to login with clean state
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            child: Text(
              'تسجيل الخروج',
              style: GoogleFonts.cairo(
                color: const Color(0xFFFF6B6B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
