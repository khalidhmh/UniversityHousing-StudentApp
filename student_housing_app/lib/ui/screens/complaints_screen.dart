import 'dart:ui'; // ✅ For ImageFilter
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/viewmodels/complaints_view_model.dart';
import '../widgets/complaints/secret_mode_switch.dart';
import 'complaints_history_screen.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  // تم تعطيل الوضع السري مؤقتاً
  final bool _isSecret = false;

  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // لون خلفية هادئ
      appBar: AppBar(
        backgroundColor: const Color(0xFF001F3F),
        title: Text(
          'الشكاوى والمقترحات',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
            tooltip: "سجل الشكاوى",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ComplaintsHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ComplaintsViewModel>(
        builder: (context, viewModel, _) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ 1. Secret Mode (Disabled & Blurred)
                    Stack(
                      children: [
                        // The original widget (disabled look)
                        Opacity(
                          opacity: 0.6,
                          child: SecretModeSwitch(
                            isSecret: _isSecret,
                            onChanged: (value) {}, // لا يفعل شيء
                          ),
                        ),
                        // The Blur Overlay
                        Positioned.fill(
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                              child: Container(
                                color: Colors.grey.withOpacity(0.1),
                                alignment: Alignment.center,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "ميزة قادمة في التحديث القادم 🔒",
                                    style: GoogleFonts.cairo(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    // (تم إخفاء اختيار المستقبل لأنه أصبح تلقائياً في النظام الجديد)

                    // ✅ 2. Subject TextField
                    Text(
                      'الموضوع',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF001F3F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTextFieldInput(_subjectController, 'أدخل عنوان المشكلة'),
                    const SizedBox(height: 20),

                    // ✅ 3. Message TextField
                    Text(
                      'الرسالة',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF001F3F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildMultilineTextFieldInput(
                      _messageController,
                      'اكتب تفاصيل شكواك أو مقترحك هنا...',
                    ),
                    const SizedBox(height: 20),

                    // ✅ 4. Attachments (Disabled for now)
                    Text(
                      'المرفقات (اختياري)',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF001F3F),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildDisabledAttachmentButton('تحميل صورة', Icons.image),
                        _buildDisabledAttachmentButton('تحميل ملف', Icons.attach_file),
                      ],
                    ),
                    const SizedBox(height: 40),

                    // ✅ 5. Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: viewModel.isSubmitting
                            ? null
                            : () => _submitComplaint(context, viewModel),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF2C94C),
                          foregroundColor: const Color(0xFF001F3F), // Text color
                          disabledBackgroundColor: Colors.grey[300],
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: viewModel.isSubmitting
                            ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.grey[700]!,
                            ),
                            strokeWidth: 2.5,
                          ),
                        )
                            : Text(
                          'إرسال الشكوى',
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Error Message
                    if (viewModel.errorMessage != null && viewModel.errorMessage!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red.shade900),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  viewModel.errorMessage!,
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    color: Colors.red.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Success Message
                    if (viewModel.successMessage != null && viewModel.successMessage!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green.shade900),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  viewModel.successMessage!,
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    color: Colors.green.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Text Field Helper
  Widget _buildTextFieldInput(TextEditingController controller, String hintText) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.cairo(),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.cairo(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  /// Multiline Text Field Helper
  Widget _buildMultilineTextFieldInput(TextEditingController controller, String hintText) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextField(
        controller: controller,
        maxLines: 6,
        style: GoogleFonts.cairo(),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.cairo(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  /// Disabled Attachment Button Helper
  Widget _buildDisabledAttachmentButton(String label, IconData icon) {
    return Expanded(
      child: Opacity(
        opacity: 0.5,
        child: OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('سيتم تفعيل المرفقات في التحديث القادم', style: GoogleFonts.cairo())),
            );
          },
          icon: Icon(icon),
          label: Text(label, style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.grey,
            side: const BorderSide(color: Colors.grey),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ),
    );
  }

  /// Submit Logic
  Future<void> _submitComplaint(BuildContext context, ComplaintsViewModel viewModel) async {
    // Validate
    if (_subjectController.text.trim().isEmpty || _messageController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('يرجى كتابة العنوان وتفاصيل الشكوى', style: GoogleFonts.cairo()),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // ✅ Submit (Removed recipient & isSecret)
    final success = await viewModel.submitComplaint(
      _subjectController.text.trim(), // Title
      _messageController.text.trim(), // Description
    );

    if (success && mounted) {
      // Clear fields
      _subjectController.clear();
      _messageController.clear();
      // Show dialog then go back
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 50),
            const SizedBox(height: 10),
            Text('تم الإرسال', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('تم استلام شكواك بنجاح وسيتم الرد عليها قريباً.',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(color: Colors.grey[700])
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close Dialog
              Navigator.pop(context); // Close Screen
            },
            child: Text('حسناً', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(0xFF001F3F))),
          ),
        ],
      ),
    );
  }
}