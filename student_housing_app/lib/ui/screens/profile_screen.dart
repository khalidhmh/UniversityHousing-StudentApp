import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/viewmodels/profile_view_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ✅ 1. تعريف الـ ViewModel هنا عشان الكل يشوفه
  final ProfileViewModel _viewModel = ProfileViewModel();

  @override
  void initState() {
    super.initState();
    // ✅ 2. دلوقتي نقدر نستخدمه هنا عشان نحمل البيانات أول ما الصفحة تفتح
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        if (_viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // استخدام بيانات آمنة (عشان ميحصلش كراش)
        final user = _viewModel.userProfile;
        final room = user?['room_json'] != null && user!['room_json'] is Map
            ? user['room_json']
            : {'room_no': 'غير مسكن', 'building': '---'};

        return Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: AppBar(
            title: Text("الملف الشخصي", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            backgroundColor: const Color(0xFF001F3F),
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _viewModel.loadProfile(),
              )
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // صورة البروفايل
                Center(
                  child: Stack(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFF2C94C), width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[200],
                          backgroundImage: (user?['photo_url'] != null && user!['photo_url'].toString().isNotEmpty)
                              ? NetworkImage(user['photo_url'])
                              : null,
                          child: (user?['photo_url'] == null || user!['photo_url'].toString().isEmpty)
                              ? const Icon(Icons.person, size: 60, color: Colors.grey)
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: CircleAvatar(
                          backgroundColor: const Color(0xFF001F3F),
                          radius: 18,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                            onPressed: () {
                              // كود رفع الصورة مستقبلاً
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  user?['full_name'] ?? "اسم الطالب",
                  style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF001F3F)),
                ),
                Text(
                  "ID: ${user?['national_id'] ?? '---'}",
                  style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey),
                ),

                const SizedBox(height: 30),

                // بطاقة بيانات السكن
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0,5))],
                  ),
                  child: Column(
                    children: [
                      _buildInfoRow(Icons.apartment, "المبنى", room['building'] ?? '---'),
                      const Divider(),
                      _buildInfoRow(Icons.meeting_room, "رقم الغرفة", room['room_no']?.toString() ?? '---'),
                      const Divider(),
                      _buildInfoRow(Icons.school, "الكلية", user?['college'] ?? 'غير محدد'),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // زر تسجيل الخروج
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // كود تسجيل الخروج
                    },
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: Text("تسجيل الخروج", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFF2C94C)),
          const SizedBox(width: 15),
          Text(label, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.grey[700])),
          const Spacer(),
          Text(value, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(0xFF001F3F))),
        ],
      ),
    );
  }
}