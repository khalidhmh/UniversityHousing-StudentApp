import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:async';

// Imports
import 'meals_screen.dart';
import 'activities_screen.dart';
import 'complaints_screen.dart';
import 'permissions_screen.dart';
import 'profile_screen.dart';
import 'maintenance_screen.dart';
import 'more_screen.dart';
import 'notifications_screen.dart';
import 'announcements_screen.dart'; // Import the new screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  // بيانات الـ QR الثابتة للطالب (ID) + متغير للوقت لزيادة الأمان
  final String _studentID = "202604123"; 
  String _qrData = "202604123";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // تحديث الكود كل 30 ثانية للأمان (اختياري)
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        setState(() {
          _qrData = "$_studentID-${DateTime.now().millisecondsSinceEpoch}";
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onTabChange(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      HomeDashboard(
        qrData: _qrData,
        onTabChange: _onTabChange,
      ),
      const MealsScreen(),
      const ActivitiesScreen(),
      const ProfileScreen(),
      const MoreScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabChange,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF001F3F),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        selectedLabelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.cairo(fontSize: 10),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "الرئيسية"),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: "الوجبات"),
          BottomNavigationBarItem(icon: Icon(Icons.local_activity), label: "الأنشطة"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "الملف"),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: "المزيد"),
        ],
      ),
    );
  }
}

class HomeDashboard extends StatelessWidget {
  final String qrData;
  final Function(int) onTabChange;

  const HomeDashboard({
    super.key, 
    required this.qrData, 
    required this.onTabChange
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF001F3F),
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: Icon(Icons.school, color: Color(0xFF001F3F)),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("جامعة العاصمة", style: GoogleFonts.cairo(fontSize: 12, color: const Color(0xFFF2C94C))),
                Text("أهلاً، أحمد حسن", style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
               Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()));
            },
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          // وسعنا العرض شوية عشان العناصر تاخد راحتها ومتبقاش صغيرة
          constraints: const BoxConstraints(maxWidth: 600), 
          child: SingleChildScrollView(
            child: Column(
              children: [
                // QR Code Section (Clickable)
                _buildQRSection(context),

                // Quick Access
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionTitle("الوصول السريع"),
                        ],
                      ),
                      const SizedBox(height: 15),
                      // كبرنا الجريد شوية
                      _buildQuickAccessGrid(context),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // Announcements Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionTitle("آخر الإعلانات"),
                          TextButton(
                            onPressed: () {
                              // الذهاب لصفحة الإعلانات
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const AnnouncementsScreen()));
                            }, 
                            child: Text("عرض الكل", style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.bold))
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      
                      _buildColoredAnnouncementCard(
                        title: "تعديل مواعيد وجبة العشاء",
                        time: "منذ 3 ساعات",
                        bgColor: const Color(0xFFFFF3E0), 
                        dotColor: const Color(0xFFFF9800),
                      ),
                      
                      const SizedBox(height: 10),
                      
                      _buildColoredAnnouncementCard(
                        title: "بدء التسجيل في الدورة الرياضية",
                        time: "أمس",
                        bgColor: const Color(0xFFE3F2FD), 
                        dotColor: const Color(0xFF2196F3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQRSection(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          height: 80,
          decoration: const BoxDecoration(
            color: Color(0xFF001F3F),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),
        // الكارت الأبيض الرئيسي
        Container(
          margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text("OK", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 12)),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("حالة التمام اليوم", style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12)),
                    Row(
                      children: [
                        Text("تم التمام", style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF001F3F))),
                        const SizedBox(width: 5),
                        const Icon(Icons.check_circle, color: Colors.green, size: 18),
                      ],
                    ),
                    Text("18 يناير 2026 - 09:30 مساءً", style: GoogleFonts.cairo(color: Colors.grey, fontSize: 10)),
                  ],
                ),
              ),
              
              // --- QR Code Icon (Clickable) ---
              // هنا التعديل: خليناه قابل للضغط ويفتح Dialog
              GestureDetector(
                onTap: () => _showQRDialog(context),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 45.0, // كبرناه سيكا عشان يبان
                    foregroundColor: const Color(0xFF001F3F),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- دالة عرض الـ QR الكبير للمطعم ---
  void _showQRDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xFF001F3F),
                child: Icon(Icons.restaurant_menu, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 15),
              Text(
                "تصريح الوجبة",
                style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF001F3F)),
              ),
              Text(
                "أحمد حسن محمد",
                style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 20),
              
              // الـ QR Code الكبير
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFF2C94C), width: 3),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: QrImageView(
                  data: qrData, // نفس الداتا المتغيرة
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "امسح الكود لاستلام الوجبة",
                style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF001F3F),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text("إغلاق", style: GoogleFonts.cairo(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessGrid(BuildContext context) {
    // استخدمنا GridView بسيطة عشان نتحكم في الحجم أحسن
    return LayoutBuilder(
      builder: (context, constraints) {
        // حساب عرض الكارت بناء على المساحة المتاحة
        double itemWidth = (constraints.maxWidth - 40) / 4; 
        
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildActionItem(
              width: itemWidth,
              icon: Icons.restaurant, 
              label: "الوجبات", 
              onTap: () => onTabChange(1)
            ),
            _buildActionItem(
              width: itemWidth,
              icon: Icons.chat_bubble_outline, 
              label: "الشكاوى",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ComplaintsScreen()))
            ),
            _buildActionItem(
              width: itemWidth,
              icon: Icons.build_outlined, 
              label: "الصيانة",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MaintenanceScreen()))
            ),
            _buildActionItem(
              width: itemWidth,
              icon: Icons.description_outlined, 
              label: "التصاريح",
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PermissionsScreen()))
            ),
          ],
        );
      }
    );
  }

  Widget _buildActionItem({
    required double width, 
    required IconData icon, 
    required String label, 
    required VoidCallback onTap
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          children: [
            // كبرنا حجم الكونتينر والأيقونة
            Container(
              padding: const EdgeInsets.all(18), 
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Icon(icon, color: const Color(0xFF001F3F), size: 30),
            ),
            const SizedBox(height: 10),
            Text(label, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildColoredAnnouncementCard({
    required String title,
    required String time,
    required Color bgColor,
    required Color dotColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: dotColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 5,
            backgroundColor: dotColor,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFD84315),
                  ),
                ),
                Text(
                  time,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: Color(0xFFF2C94C), width: 3)),
      ),
      child: Text(title, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18)),
    );
  }
}