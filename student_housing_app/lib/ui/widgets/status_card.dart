import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';

class StatusCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final String qrData;
  final VoidCallback onQrTap;

  final bool showAlarm;
  final bool isAlarmSet;
  final VoidCallback? onAlarmTap;

  const StatusCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.qrData,
    required this.onQrTap,
    this.showAlarm = false,
    this.isAlarmSet = false,
    this.onAlarmTap,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ تحسين بسيط: تحديد لو الحالة "تم التمام" عشان نتحكم في عرض النصوص
    final bool isCheckedIn = color == Colors.green;

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
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(icon, color: color, size: 24),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("حالة التمام اليوم", style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12)),
                        const Spacer(),
                        // زر المنبه يظهر فقط في حالة (في انتظار التمام)
                        if (showAlarm && onAlarmTap != null)
                          GestureDetector(
                            onTap: onAlarmTap,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                  color: isAlarmSet ? const Color(0xFFE8F5E9) : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: isAlarmSet ? Colors.green : Colors.grey.shade300
                                  )
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isAlarmSet ? Icons.notifications_active : Icons.notifications_none,
                                    size: 14,
                                    color: isAlarmSet ? Colors.green : Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isAlarmSet ? "مفعل" : "تذكير",
                                    style: GoogleFonts.cairo(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isAlarmSet ? Colors.green : Colors.grey
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                      ],
                    ),
                    Text(title, style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF001F3F))),
                    Text(
                      subtitle,
                      style: GoogleFonts.cairo(
                        // ✅ لو الطالب حضر (أخضر) بنخلي النص رمادي هادي، لو غايب (أحمر) بنسيبه أحمر عشان ينبهه
                          color: isCheckedIn ? Colors.grey : color,
                          fontSize: 10,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onQrTap,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Hero(
                    tag: 'qr_hero',
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 45.0,
                      foregroundColor: const Color(0xFF001F3F),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}