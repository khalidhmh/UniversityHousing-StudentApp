import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart'; // استيراد مكتبة الأنيميشن

class ClearanceScreen extends StatefulWidget {
  const ClearanceScreen({super.key});

  @override
  State<ClearanceScreen> createState() => _ClearanceScreenState();
}

class _ClearanceScreenState extends State<ClearanceScreen> {
  // متغير لتجربة الحالة (في التطبيق الحقيقي بييجي من الداتابيز)
  bool _isRequestSubmitted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // لغينا لون الخلفية السادة هنا عشان هنحط تدرج
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent, // بار شفاف عشان الخلفية تبان تحته
        elevation: 0,
        title: FadeInDown( // أنيميشن للعنوان
          delay: const Duration(milliseconds: 200),
          child: Text(
            "إخلاء الطرف",
            style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        centerTitle: true,
        leading: FadeInDown( // أنيميشن لزرار الرجوع
          delay: const Duration(milliseconds: 200),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Stack(
        children: [
          // 1. الخلفية المتدرجة (Gradient Background)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF001F3F), // كحلي من فوق
                  Color(0xFFF5F7FA), // رمادي فاتح جداً من تحت
                ],
                stops: [0.2, 0.5], // نقطة التحول
              ),
            ),
          ),

          // 2. المحتوى
          Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // مسافة عشان الهيدر الشفاف
                    const SizedBox(height: 110), 
                    
                    // أنيميشن دخول الكارت الرئيسي من أسفل لأعلى
                    SlideInUp(
                      duration: const Duration(milliseconds: 600),
                      from: 100,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _isRequestSubmitted 
                            ? _buildStatusCard() // كارت التايم لاين
                            : _buildRequestCard(), // كارت الطلب الأحمر
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- كارت طلب الإخلاء (الأحمر) ---
  Widget _buildRequestCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // أنيميشن نبض للأيقونة الحمراء
          Pulse(
            infinite: true,
            duration: const Duration(seconds: 2),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFFFEBEE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFD32F2F),
                size: 50,
              ),
            ),
          ),
          const SizedBox(height: 20),
          FadeIn(
            delay: const Duration(milliseconds: 400),
            child: Text(
              "تنبيه هام",
              style: GoogleFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF001F3F),
              ),
            ),
          ),
          const SizedBox(height: 15),
          FadeIn(
            delay: const Duration(milliseconds: 600),
            child: Text(
              "عند تقديم طلب إخلاء الطرف، سيقوم المشرف بزيارة غرفتك للتحقق من حالتها. هذه العملية لا يمكن التراجع عنها.",
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 30),
          FadeInUp(
            delay: const Duration(milliseconds: 800),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => _showConfirmationDialog(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  shadowColor: const Color(0xFFD32F2F).withOpacity(0.4),
                ),
                child: Text(
                  "بدء إجراءات الإخلاء",
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- كارت متابعة الطلب (التايم لاين المتحرك) ---
  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // الخطوة 1: تظهر أولاً
          FadeInLeft(
            delay: const Duration(milliseconds: 200),
            from: 50,
            child: _buildTimelineStep(
              icon: Icons.check_circle,
              iconColor: const Color(0xFF00C853),
              title: "تقديم الطلب",
              subtitle: "تم تسجيل طلبك بنجاح",
              isActive: true,
              isLast: false,
            ),
          ),
          
          // الخطوة 2: تظهر بعدها بـ 600ms
          FadeInLeft(
            delay: const Duration(milliseconds: 800),
            from: 50,
            child: _buildTimelineStep(
              icon: Icons.access_time_filled,
              iconColor: const Color(0xFFFFC107),
              title: "مراجعة المشرف",
              subtitle: "بانتظار زيارة المشرف للغرفة",
              isActive: true, // دي الخطوة الحالية
              isLast: false,
              isPulsing: true, // هنخليها تنبض
            ),
          ),

          // الخطوة 3: تظهر في الآخر
          FadeInLeft(
            delay: const Duration(milliseconds: 1400),
            from: 50,
            child: _buildTimelineStep(
              icon: Icons.verified_user_outlined,
              iconColor: Colors.grey[300]!,
              title: "الاعتماد النهائي",
              subtitle: "موافقة إدارة الإسكان",
              isActive: false,
              isLast: true,
            ),
          ),

          const SizedBox(height: 30),

          // صندوق الملاحظات يظهر من تحت
          SlideInUp(
            delay: const Duration(milliseconds: 1800),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9C4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFBC02D), width: 0.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFFF57F17)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "يرجى التواجد في الغرفة لتسهيل عملية الفحص.",
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: const Color(0xFFF57F17),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

 Widget _buildTimelineStep({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isActive,
    required bool isLast,
    bool isPulsing = false,
  }) {
    Widget iconWidget = Icon(icon, color: iconColor, size: 30);

    if (isPulsing) {
      iconWidget = Pulse(
        infinite: true,
        duration: const Duration(seconds: 2),
        child: iconWidget,
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            iconWidget,
            if (!isLast)
              // التعديل: شلنا الـ delay لأن TweenAnimationBuilder لا يدعمه
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 50.0),
                duration: const Duration(milliseconds: 500),
                // delay: const Duration(milliseconds: 400), <--- السطر ده كان السبب، تم حذفه
                builder: (context, value, child) {
                  return Container(
                    width: 2,
                    height: value,
                    color: Colors.grey[200],
                    margin: const EdgeInsets.symmetric(vertical: 5),
                  );
                },
              ),
          ],
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isActive ? const Color(0xFF001F3F) : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }
  void _showConfirmationDialog() {
    // دايلوج بيظهر بأنيميشن تكبير (Scale)
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "تأكيد الطلب",
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(0xFF001F3F)),
        ),
        content: Text(
          "هل أنت متأكد من رغبتك في بدء إجراءات إخلاء الطرف؟",
          style: GoogleFonts.cairo(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text("إلغاء", style: GoogleFonts.cairo(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _isRequestSubmitted = true;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text("تأكيد", style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: child,
        );
      },
    );
  }
}