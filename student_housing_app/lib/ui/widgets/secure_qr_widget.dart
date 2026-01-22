import 'dart:async';
// عشان kIsWeb
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
// تم حذف مكتبة flutter_windowmanager لأنها تسبب مشاكل في البناء
import '../../core/services/security_service.dart';

class SecureQrWidget extends StatefulWidget {
  // المتغيرات الجديدة عشان نستخدم الكارت لأي وجبة
  final String title;
  final String timeRange;
  final IconData icon;
  final Color activeColor;

  const SecureQrWidget({
    super.key,
    required this.title,
    required this.timeRange,
    required this.icon,
    this.activeColor = const Color(0xFF001F3F), // اللون الافتراضي كحلي
  });

  @override
  State<SecureQrWidget> createState() => _SecureQrWidgetState();
}

class _SecureQrWidgetState extends State<SecureQrWidget> {
  final SecurityService _securityService = SecurityService();
  late Timer _timer;
  
  String _qrData = ""; 
  int _secondsLeft = 30; 
  int _lastTimeWindow = 0; 
  
  final String _studentId = "202604123"; 

  @override
  void initState() {
    super.initState();
    // _enableSecureMode(); // تم تعطيل الحماية مؤقتاً
    _refreshQrLogic(); 

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _refreshQrLogic();
        });
      }
    });
  }

  void _refreshQrLogic() {
    int currentWindow = DateTime.now().millisecondsSinceEpoch ~/ 30000;
    if (currentWindow != _lastTimeWindow) {
      // هنا ممكن ندمج نوع الوجبة في التشفير لو حابب مستقبلاً
      _qrData = _securityService.generateSecureQRToken(_studentId);
      _lastTimeWindow = currentWindow;
    }
    _secondsLeft = _securityService.getSecondsRemaining();
  }

  // تم تعطيل هذه الدالة لأن المكتبة المسؤولة عنها قديمة
  /*
  Future<void> _enableSecureMode() async {
    if (kIsWeb) return; 
    try { await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE); } catch (e) { debugPrint("$e"); }
  }
  */

  @override
  void dispose() {
    _timer.cancel();
    // تم إزالة كود التنظيف الخاص بالمكتبة المحذوفة
    /*
    if (!kIsWeb) {
      FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    }
    */
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20), // مسافة تحت كل كارت
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(widget.icon, color: widget.activeColor),
              Text(widget.title, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: widget.activeColor, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 20),
          
          SizedBox(
            height: 200, width: 200,
            child: QrImageView(
              data: _qrData,
              version: QrVersions.auto,
              size: 200, 
              eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: widget.activeColor), 
              dataModuleStyle: QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: widget.activeColor)
            ),
          ),
          
          const SizedBox(height: 20),
          
          LinearProgressIndicator(
            value: _securityService.getRemainingTimePercentage(), 
            backgroundColor: Colors.grey[200], 
            color: const Color(0xFFF2C94C)
          ),
          const SizedBox(height: 5),
          Text("يتغير الكود خلال $_secondsLeft ثانية", style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12)),
          
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 5),
              Text(widget.timeRange, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.grey[700])),
            ],
          )
        ],
      ),
    );
  }
}