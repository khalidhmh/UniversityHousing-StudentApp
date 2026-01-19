import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // بنحدد عرض ثابت عشان الويب يبان كأنه موبايل
    const double mobileWidth = 480.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        // هذا الصندوق هو السر: يجبر المحتوى على البقاء في المنتصف بعرض الموبايل
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: mobileWidth,
          ),
          child: Container(
             color: const Color(0xFFF5F5F5), // لون خلفية الموبايل
             // استخدام Stack لعمل التداخل المطلوب
             child: Stack(
              children: [
                // 1. طبقة الخلفية الكحلي (الهيدر)
                Container(
                  height: 280, // ارتفاع ثابت للهيدر
                  decoration: const BoxDecoration(
                    color: Color(0xFF001F3F),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40), // دوران أكبر قليلاً للمطابقة
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                ),

                // 2. طبقة المحتوى القابل للسكرول (فوق الخلفية)
                SingleChildScrollView(
                  // مسافة من فوق عشان نبدأ بعد شريط الحالة
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
                  child: Column(
                    children: [
                      // --- بيانات الطالب (الصورة والاسم) ---
                      Center(
                        child: Column(
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2)
                                ),
                              child: const CircleAvatar(
                                radius: 50, // تكبير الصورة قليلاً
                                // هنا ممكن تحط صورة حقيقية مستقبلاً
                                // backgroundImage: AssetImage('assets/profile.jpg'),
                                backgroundColor: Colors.white24,
                                child: Icon(Icons.person, size: 60, color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              "أحمد حسن محمد",
                              style: GoogleFonts.cairo(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "كلية الحاسبات والذكاء الاصطناعي",
                              style: GoogleFonts.cairo(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30), // مسافة قبل الكارت العائم

                      // --- الكارت العائم (System ID) ---
                      // Stack عشان نحط الرسم المقطع فوق الكونتينر الكحلي
                      Stack(
                        children: [
                          // الكونتينر الكحلي الأساسي
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF001F3F),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "كود الطالب (SYSTEM ID)",
                                  style: GoogleFonts.cairo(
                                    color: const Color(0xFFF2C94C), // ذهبي
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // أيقونة النسخ
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8)
                                      ),
                                      child: const Icon(Icons.copy, color: Colors.white70, size: 20)
                                    ),
                                    const SizedBox(width: 15),
                                    // الكود
                                    Text(
                                      "SYS-2026-8894#",
                                      style: GoogleFonts.sourceCodePro(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 2.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // رسم الإطار المقطع يدوياً فوق الكونتينر
                          Positioned.fill(
                            child: CustomPaint(
                              painter: DashedRectPainter(
                                color: const Color(0xFFF2C94C), // لون ذهبي
                                strokeWidth: 2.5,
                                gap: 6.0,
                                dash: 8.0,
                                borderRadius: 20.0
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // --- بانر القراءة فقط ---
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF2196F3).withOpacity(0.5), width: 1.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.lock_outline_rounded, size: 18, color: Color(0xFF1976D2)),
                            const SizedBox(width: 10),
                            Text(
                              "وضع القراءة فقط - لا يمكن تعديل البيانات",
                              style: GoogleFonts.cairo(
                                color: const Color(0xFF1976D2),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --- قائمة البيانات ---
                      _buildInfoTile(Icons.credit_card, "الرقم القومي", "30412010101234"),
                      _buildInfoTile(Icons.badge_outlined, "رقم الكارنيه", "202604123"),
                      _buildInfoTile(Icons.school_outlined, "الكلية والفرقة", "حاسبات - الفرقة الرابعة"),
                      _buildInfoTile(Icons.apartment_outlined, "نوع السكن", "سكن عادي (مصري)"),
                      _buildInfoTile(Icons.business_outlined, "المبنى والغرفة", "مبنى (أ) - غرفة 304"),
                      
                      const SizedBox(height: 50), // مسافة في الآخر
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // دالة بناء كارت البيانات الواحد
  Widget _buildInfoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20), // دوران أكبر
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [
          // الأيقونة في دائرة رمادي
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.grey[500], size: 24),
          ),
          const SizedBox(width: 20),
          // النصوص
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.cairo(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.cairo(
                    color: const Color(0xFF001F3F),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // قفل صغير
          Icon(Icons.lock_rounded, color: Colors.grey[300], size: 20),
        ],
      ),
    );
  }
}

// --- رسام الحدود المقطعة المحسن (Advanced Dashed Painter) ---
class DashedRectPainter extends CustomPainter {
  final double strokeWidth;
  final Color color;
  final double gap;
  final double dash;
  final double borderRadius;

  DashedRectPainter({
    this.strokeWidth = 2.0,
    this.color = Colors.red,
    this.gap = 5.0,
    this.dash = 8.0,
    this.borderRadius = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint dashedPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round; // حواف مستديرة للشرط

    // إنشاء مسار مستطيل بحواف دائرية
    RRect rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(borderRadius),
    );
    
    Path path = Path()..addRRect(rRect);

    // تحويل المسار المتصل إلى مسار مقطع
    Path dashedPath = _dashPath(path, dash, gap);
    
    canvas.drawPath(dashedPath, dashedPaint);
  }

  // دالة مساعدة لتقطيع المسار
  Path _dashPath(Path source, double dashArray, double gapArray) {
    Path dest = Path();
    for (ui.PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        double length = draw ? dashArray : gapArray;
        if (distance + length > metric.length) {
          length = metric.length - distance;
        }
        if (draw) {
          dest.addPath(metric.extractPath(distance, distance + length), Offset.zero);
        }
        distance += length;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}