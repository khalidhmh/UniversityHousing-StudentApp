import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/viewmodels/announcements_view_model.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  @override
  void initState() {
    super.initState();
    // Load announcements using Provider's context to access ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnnouncementsViewModel>().loadAnnouncements();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF001F3F),
        title: Text(
          "لوحة الإعلانات",
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<AnnouncementsViewModel>( // استخدم Consumer أفضل هنا
        builder: (context, viewModel, _) {
          // 1. حالة التحميل (فقط لو القائمة فارغة)
          if (viewModel.isLoading && viewModel.announcements.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF001F3F)));
          }

          // 2. حالة الخطأ
          if (viewModel.errorMessage != null && viewModel.announcements.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(viewModel.errorMessage!, style: GoogleFonts.cairo()),
                  ElevatedButton(
                    onPressed: () => viewModel.loadAnnouncements(),
                    child: const Text("حاول مرة أخرى"),
                  )
                ],
              ),
            );
          }

          // 3. القائمة الفارغة
          if (viewModel.announcements.isEmpty) {
            return Center(child: Text('لا توجد إعلانات حالياً', style: GoogleFonts.cairo()));
          }

          // 4. عرض البيانات (تم إصلاح الـ Scroll)
          return RefreshIndicator(
            onRefresh: () => viewModel.refreshAnnouncements(),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: viewModel.announcements.length,
              itemBuilder: (context, index) {
                final announcement = viewModel.announcements[index];
                return _buildAnnouncementCard(announcement);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnnouncementCard(Map<String, dynamic> announcement) {
    // Default colors if not provided from API
    final bgColor = _getBackgroundColor(announcement['category'] ?? 'general');
    final dotColor = _getDotColor(announcement['category'] ?? 'general');

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: dotColor.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 5, backgroundColor: dotColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  announcement['title'] ?? '',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF001F3F),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            announcement['body'] ?? '',
            style: GoogleFonts.cairo(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _formatDate(announcement['created_at'] ?? ''),
            style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor(String category) {
    switch (category.toLowerCase()) {
      case 'رياضة':
        return const Color(0xFFE8F5E9); // أخضر فاتح
      case 'ثقافة':
        return const Color(0xFFE3F2FD); // أزرق فاتح
      case 'تحذير':
      case 'هام':
        return const Color(0xFFFFEBEE); // أحمر فاتح
      case 'صيانة':
      case 'تعديل':
        return const Color(0xFFFFF3E0); // برتقالي فاتح
      default:
        return const Color(0xFFFFF3E0); // برتقالي فاتح
    }
  }

  Color _getDotColor(String category) {
    switch (category.toLowerCase()) {
      case 'رياضة':
        return const Color(0xFF43A047);
      case 'ثقافة':
        return const Color(0xFF2196F3);
      case 'تحذير':
      case 'هام':
        return const Color(0xFFD32F2F);
      case 'صيانة':
      case 'تعديل':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFFFF9800);
    }
  }

  String _formatDate(String dateString) {
    // If the API returns a simple time format like "منذ 3 ساعات", use it directly
    if (dateString.contains('منذ') || dateString.contains('أمس')) {
      return dateString;
    }

    // If it's a timestamp, try to parse and format it
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inHours < 1) {
        return 'منذ قليل';
      } else if (difference.inHours < 24) {
        return 'منذ ${difference.inHours} ساعة';
      } else if (difference.inDays == 1) {
        return 'أمس';
      } else if (difference.inDays < 7) {
        return 'منذ ${difference.inDays} أيام';
      } else {
        return '${date.year}/${date.month}/${date.day}';
      }
    } catch (e) {
      return dateString;
    }
  }
}
