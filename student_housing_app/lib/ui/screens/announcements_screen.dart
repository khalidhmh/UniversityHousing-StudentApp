import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF001F3F),
        title: Text("لوحة الإعلانات", style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildColoredAnnouncementCard(
                title: "تعديل مواعيد وجبة العشاء",
                body: "نحيطكم علماً بأنه تم تعديل مواعيد صرف وجبة العشاء لتبدأ من الساعة 6 مساءً وحتى 9 مساءً.",
                time: "منذ 3 ساعات",
                bgColor: const Color(0xFFFFF3E0),
                dotColor: const Color(0xFFFF9800),
              ),
              const SizedBox(height: 15),
              _buildColoredAnnouncementCard(
                title: "بدء التسجيل في الدورة الرياضية",
                body: "تم فتح باب التسجيل في دورة كرة القدم الخماسية. يرجى التوجه لمكتب رعاية الشباب للتسجيل.",
                time: "أمس",
                bgColor: const Color(0xFFE3F2FD),
                dotColor: const Color(0xFF2196F3),
              ),
              const SizedBox(height: 15),
              _buildColoredAnnouncementCard(
                title: "تعليمات هامة بخصوص الإخلاء",
                body: "على الطلاب الراغبين في إخلاء الطرف التأكد من تسليم العهدة قبل موعد المغادرة بـ 24 ساعة.",
                time: "منذ يومين",
                bgColor: const Color(0xFFFFEBEE), // أحمر فاتح
                dotColor: const Color(0xFFD32F2F),
              ),
               const SizedBox(height: 15),
              _buildColoredAnnouncementCard(
                title: "انقطاع مياه مجدول",
                body: "سيتم قطع المياه عن المبنى (أ) لأعمال الصيانة غداً من الساعة 10 صباحاً وحتى 12 ظهراً.",
                time: "منذ 3 أيام",
                bgColor: const Color(0xFFE8F5E9), // أخضر فاتح
                dotColor: const Color(0xFF43A047),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColoredAnnouncementCard({
    required String title,
    required String body,
    required String time,
    required Color bgColor,
    required Color dotColor,
  }) {
    return Container(
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
                  title,
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
            body,
            style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[800], height: 1.5),
          ),
          const SizedBox(height: 10),
          Text(
            time,
            style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}