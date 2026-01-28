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
  bool _isSecret = false;
  String? _selectedRecipient;
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  final List<String> recipients = [
    'مدير المبنى',
    'رعاية الشباب',
    'شؤون التغذية',
    'الأمن والسلامة',
    'الخدمات الإدارية',
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.white),
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
                    // Secret Mode Switch
                    SecretModeSwitch(
                      isSecret: _isSecret,
                      onChanged: (value) {
                        setState(() {
                          _isSecret = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Recipient Dropdown
                    Text(
                      'المستقبل',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF001F3F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildRecipientDropdown(),
                    const SizedBox(height: 20),

                    // Subject TextField
                    Text(
                      'الموضوع',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF001F3F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTextFieldInput(_subjectController, 'أدخل الموضوع'),
                    const SizedBox(height: 20),

                    // Message TextField
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
                      'اكتب شكواك أو مقترحك هنا...',
                    ),
                    const SizedBox(height: 20),

                    // Attachments Row
                    Text(
                      'المرفقات',
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
                        _buildAttachmentButton('تحميل صورة', Icons.image),
                        _buildAttachmentButton('تحميل ملف', Icons.attach_file),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Submit Button with Loading State
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: viewModel.isSubmitting
                            ? null
                            : () => _submitComplaint(context, viewModel),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF2C94C),
                          disabledBackgroundColor: Colors.grey[400],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: viewModel.isSubmitting
                            ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.grey[600]!,
                                  ),
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'إرسال الشكوى',
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF001F3F),
                                ),
                              ),
                      ),
                    ),

                    // Error Message Display
                    if (viewModel.errorMessage != null &&
                        viewModel.errorMessage!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red[900]),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  viewModel.errorMessage!,
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    color: Colors.red[900],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Success Message Display
                    if (viewModel.successMessage != null &&
                        viewModel.successMessage!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green[900],
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  viewModel.successMessage!,
                                  style: GoogleFonts.cairo(
                                    fontSize: 14,
                                    color: Colors.green[900],
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

  /// Build recipient dropdown
  Widget _buildRecipientDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedRecipient,
        items: recipients.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value, style: GoogleFonts.cairo()),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedRecipient = newValue;
          });
        },
        hint: Text(
          'اختر المستقبل',
          style: GoogleFonts.cairo(color: Colors.grey),
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          hintStyle: GoogleFonts.cairo(color: Colors.grey),
        ),
      ),
    );
  }

  /// Build text field input
  Widget _buildTextFieldInput(
    TextEditingController controller,
    String hintText,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.cairo(),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.cairo(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  /// Build multiline text field input
  Widget _buildMultilineTextFieldInput(
    TextEditingController controller,
    String hintText,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: TextField(
        controller: controller,
        maxLines: 5,
        style: GoogleFonts.cairo(),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.cairo(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  /// Build attachment button
  Widget _buildAttachmentButton(String label, IconData icon) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$label - قيد التطوير', style: GoogleFonts.cairo()),
              backgroundColor: Colors.blue,
            ),
          );
        },
        icon: Icon(icon),
        label: Text(
          label,
          style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF001F3F),
          side: const BorderSide(color: Color(0xFF001F3F), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  /// Submit complaint handler
  Future<void> _submitComplaint(
    BuildContext context,
    ComplaintsViewModel viewModel,
  ) async {
    // Validate inputs
    if (_selectedRecipient == null ||
        _subjectController.text.isEmpty ||
        _messageController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'يرجى ملء جميع الحقول المطلوبة',
              style: GoogleFonts.cairo(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // Submit complaint via ViewModel (using Provider context to avoid context validity issues)
    final success = await viewModel.submitComplaint(
      title: _subjectController.text,
      description: _messageController.text,
      recipient: _selectedRecipient!,
      isSecret: _isSecret,
    );

    if (success && mounted) {
      // Reset form
      _subjectController.clear();
      _messageController.clear();
      setState(() {
        _selectedRecipient = null;
        _isSecret = false;
      });
    }
  }

  /// Show success dialog
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFE8F5E9),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'نجح',
                style: GoogleFonts.cairo(
                  color: Colors.green[900],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.cairo(color: Colors.green[900]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'حسناً',
              style: GoogleFonts.cairo(
                color: Colors.green[900],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFEBEE),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'خطأ',
                style: GoogleFonts.cairo(
                  color: Colors.red[900],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.cairo(color: Colors.red[900]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'حسناً',
              style: GoogleFonts.cairo(
                color: Colors.red[900],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
