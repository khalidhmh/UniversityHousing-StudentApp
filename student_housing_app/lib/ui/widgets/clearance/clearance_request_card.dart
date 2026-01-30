import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:provider/provider.dart';
import '../../../core/viewmodels/clearance_view_model.dart';

class ClearanceRequestCard extends StatefulWidget {
  const ClearanceRequestCard({super.key});

  @override
  State<ClearanceRequestCard> createState() => _ClearanceRequestCardState();
}

class _ClearanceRequestCardState extends State<ClearanceRequestCard> {
  bool _isSubmitting = false;

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
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
            onPressed: () async {
              Navigator.pop(ctx);
              await _submitClearanceRequest();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              "تأكيد",
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitClearanceRequest() async {
    setState(() => _isSubmitting = true);

    try {
      final viewModel = context.read<ClearanceViewModel>();

      // ✅ تصحيح اسم الدالة هنا: initiateClearance بدلاً من startClearanceProcess
      final success = await viewModel.initiateClearance();

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم بدء إجراءات إخلاء الطرف بنجاح', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage ?? 'فشل بدء الإجراءات', style: GoogleFonts.cairo()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ غير متوقع', style: GoogleFonts.cairo()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          Pulse(
            infinite: true,
            duration: const Duration(seconds: 2),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFFFEBEE),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFD32F2F), size: 50),
            ),
          ),
          const SizedBox(height: 20),
          FadeIn(
            delay: const Duration(milliseconds: 400),
            child: Text(
              "تنبيه هام",
              style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF001F3F)),
            ),
          ),
          const SizedBox(height: 15),
          FadeIn(
            delay: const Duration(milliseconds: 600),
            child: Text(
              "عند تقديم طلب إخلاء الطرف، سيقوم المشرف بزيارة غرفتك للتحقق من حالتها.",
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[600], height: 1.6),
            ),
          ),
          const SizedBox(height: 30),
          FadeInUp(
            delay: const Duration(milliseconds: 800),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _showConfirmationDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 5,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(
                  "بدء إجراءات الإخلاء",
                  style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}