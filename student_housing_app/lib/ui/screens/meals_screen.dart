import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:google_fonts/google_fonts.dart';
import '../widgets/secure_qr_widget.dart';

class MealsScreen extends StatelessWidget {
  const MealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF001F3F),
        title: Text("بونات التغذية", style: GoogleFonts.cairo(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          // Original content (now blurred in background)
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // تنبيه بسيط
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber[100],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.orange),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "يرجى مسح الكود أمام الجهاز المخصص في المطعم",
                          style: GoogleFonts.cairo(fontSize: 12, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),

                // 1. كارت الغداء والعشاء (الرئيسي)
                const SecureQrWidget(
                  title: "وجبة الغداء واستلام العشاء",
                  timeRange: "02:00 م - 07:00 م",
                  icon: Icons.restaurant,
                  activeColor: Color(0xFF001F3F), // كحلي
                ),

                // عنوان فاصل
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    "الوجبات القادمة",
                    style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ),

                // 2. كارت الفطار (اليوم التالي)
                const SecureQrWidget(
                  title: "فطار غداً (صباحاً)",
                  timeRange: "06:00 ص - 09:00 ص",
                  icon: Icons.free_breakfast,
                  activeColor: Color(0xFF001F3F), // ممكن تخليه لون تاني لو حابب
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Blur Effect & Coming Soon Overlay
          Positioned.fill(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ),

          // Coming Soon Message
          Center(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.blue[50]!,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.restaurant_menu,
                      size: 60,
                      color: const Color(0xFF001F3F),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "قريباً - المرحلة الثانية",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF001F3F),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "خدمة المطعم غير متاحة حالياً، انتظرونا في التحديث القادم!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}