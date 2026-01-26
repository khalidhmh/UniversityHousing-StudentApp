import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:async';

// ViewModel
import '../../core/viewmodels/home_view_model.dart';

// Widgets
import '../../ui/widgets/status_card.dart';
import '../../ui/widgets/pull_to_refresh.dart';

// Screens
import 'meals_screen.dart';
import 'activities_screen.dart';
import 'complaints_screen.dart';
import 'permissions_screen.dart';
import 'profile_screen.dart';
import 'maintenance_screen.dart';
import 'more_screen.dart';
import 'notifications_screen.dart';
import 'announcements_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // تعريف الـ ViewModel
  final HomeViewModel _viewModel = HomeViewModel();

  @override
  void initState() {
    super.initState();
    // تحميل البيانات
    _viewModel.loadData();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _onTabChange(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // ✅ تصحيح: استخدام return بدلاً من body:
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) {
        // Generate QR data from studentId
        final qrData = _viewModel.studentId.isNotEmpty
            ? "${_viewModel.studentId}-${DateTime.now().millisecondsSinceEpoch ~/ 30000}"
            : "0";

        final List<Widget> screens = [
          HomeDashboard(
            qrData: qrData,
            onTabChange: _onTabChange,
            viewModel: _viewModel,
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
            selectedLabelStyle: GoogleFonts.cairo(
                fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: GoogleFonts.cairo(fontSize: 10),
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home), label: "الرئيسية"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.restaurant), label: "الوجبات"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.local_activity), label: "الأنشطة"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: "الملف"),
              BottomNavigationBarItem(
                  icon: Icon(Icons.menu), label: "المزيد"),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------
// HomeDashboard
// ---------------------------------------------------------
class HomeDashboard extends StatelessWidget {
  final String qrData;
  final Function(int) onTabChange;
  final HomeViewModel viewModel;

  const HomeDashboard({
    super.key,
    required this.qrData,
    required this.onTabChange,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    final statusData = viewModel.getRollCallStatusUI();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF001F3F),
        elevation: 0,
        title: Row(
          children: [
            FadeInLeft(
              duration: const Duration(milliseconds: 500),
              child: const CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: Icon(Icons.school, color: Color(0xFF001F3F)),
              ),
            ),
            const SizedBox(width: 10),
            FadeInLeft(
              delay: const Duration(milliseconds: 200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("جامعة العاصمة",
                      style: GoogleFonts.cairo(
                          fontSize: 12, color: const Color(0xFFF2C94C))),
                  Text(
                      "أهلاً، ${viewModel.studentName.split(' ').take(2).join(' ')}",
                      style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationsScreen())),
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: PullToRefresh(
            onRefresh: viewModel.loadData,
            child: Column(
              children: [
                // 1. كارت الحالة
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: StatusCard(
                    title: statusData['title'],
                    subtitle: statusData['subtitle'],
                    icon: statusData['icon'],
                    color: statusData['color'],
                    backgroundColor: statusData['bg_color'],
                    qrData: qrData,
                    onQrTap: () => _showQRDialog(context),
                    showAlarm: statusData['status'] == 0,
                    isAlarmSet: viewModel.isAlarmSet,
                    onAlarmTap: () => viewModel.toggleAlarm(context),
                  ),
                ),

                // 2. الوصول السريع
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      FadeInUp(
                        delay: const Duration(milliseconds: 300),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSectionTitle("الوصول السريع"),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: _buildQuickAccessGrid(context),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // 3. الإعلانات
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      FadeInUp(
                        delay: const Duration(milliseconds: 500),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSectionTitle("آخر الإعلانات"),
                            TextButton(
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                        const AnnouncementsScreen())),
                                child: Text("عرض الكل",
                                    style: GoogleFonts.cairo(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)))
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      if (viewModel.isLoading)
                        const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: viewModel.announcements.length,
                          itemBuilder: (context, index) {
                            return FadeInUp(
                              delay:
                              Duration(milliseconds: 600 + (index * 100)),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _buildColoredAnnouncementCard(
                                  title: viewModel.announcements[index]
                                  ['title'],
                                  time: viewModel.announcements[index]
                                  ['created_at'] ??
                                      "الآن",
                                  bgColor: index % 2 == 0
                                      ? const Color(0xFFFFF3E0)
                                      : const Color(0xFFE3F2FD),
                                  dotColor: index % 2 == 0
                                      ? const Color(0xFFFF9800)
                                      : const Color(0xFF2196F3),
                                ),
                              ),
                            );
                          },
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

  // --- Helper Methods ---

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
                child: Icon(Icons.qr_code_scanner,
                    color: Colors.white, size: 30),
              ),
              const SizedBox(height: 15),
              Text("باركود الطالب",
                  style: GoogleFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF001F3F))),
              Text(viewModel.studentName,
                  style: GoogleFonts.cairo(
                      fontSize: 16, color: Colors.grey[700])),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color(0xFFF2C94C), width: 3),
                    borderRadius: BorderRadius.circular(15)),
                child: QrImageView(
                    data: qrData, version: QrVersions.auto, size: 200.0),
              ),
              const SizedBox(height: 20),
              Text("يستخدم للتمام واستلام الوجبات",
                  style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF001F3F),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  child: Text("إغلاق",
                      style: GoogleFonts.cairo(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessGrid(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double itemWidth = (constraints.maxWidth - 40) / 4;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionItem(
              width: itemWidth,
              icon: Icons.restaurant,
              label: "الوجبات",
              onTap: () => onTabChange(1)),
          _buildActionItem(
              width: itemWidth,
              icon: Icons.chat_bubble_outline,
              label: "الشكاوى",
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ComplaintsScreen()))),
          _buildActionItem(
              width: itemWidth,
              icon: Icons.build_outlined,
              label: "الصيانة",
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MaintenanceScreen()))),
          _buildActionItem(
              width: itemWidth,
              icon: Icons.description_outlined,
              label: "التصاريح",
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PermissionsScreen()))),
        ],
      );
    });
  }

  Widget _buildActionItem(
      {required double width,
        required IconData icon,
        required String label,
        required VoidCallback onTap}) {
    return ZoomIn(
      duration: const Duration(milliseconds: 500),
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: width,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 15,
                        offset: const Offset(0, 5))
                  ],
                ),
                child: Icon(icon, color: const Color(0xFF001F3F), size: 30),
              ),
              const SizedBox(height: 10),
              Text(label,
                  style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColoredAnnouncementCard(
      {required String title,
        required String time,
        required Color bgColor,
        required Color dotColor}) {
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
          CircleAvatar(radius: 5, backgroundColor: dotColor),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFD84315))),
                Text(time,
                    style: GoogleFonts.cairo(
                        fontSize: 12, color: Colors.grey[600])),
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
        border:
        Border(right: BorderSide(color: Color(0xFFF2C94C), width: 3)),
      ),
      child: Text(title,
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 18)),
    );
  }
}