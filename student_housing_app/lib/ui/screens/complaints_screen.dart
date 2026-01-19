import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'complaints_history_screen.dart';

class ComplaintsScreen extends StatefulWidget {
  const ComplaintsScreen({super.key});

  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  bool isSecret = false;
  String? selectedRecipient;
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tab Toggle
                _buildTabToggle(),
                const SizedBox(height: 20),

                // Secret Mode Warning
                if (isSecret) _buildSecretWarning(),
                if (isSecret) const SizedBox(height: 20),

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

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      _submitComplaint();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF2C94C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'إرسال الشكوى',
                      style: GoogleFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF001F3F),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Tab Toggle Widget
  Widget _buildTabToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isSecret = false;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isSecret ? const Color(0xFF001F3F) : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'شكوى عادية',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: !isSecret ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isSecret = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSecret ? const Color(0xFFFF6B6B) : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'شكوى سرية',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isSecret ? Colors.white : Colors.grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Secret Mode Warning Banner
  Widget _buildSecretWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFFFE69C),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lock,
            color: Color(0xFFFF8C00),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'هذه الشكوى مشفرة ولن يظهر اسمك أو بياناتك للمستلم',
              style: GoogleFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF856404),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Recipient Dropdown
  Widget _buildRecipientDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: selectedRecipient,
        items: recipients.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: GoogleFonts.cairo(),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedRecipient = newValue;
          });
        },
        hint: Text(
          'اختر المستقبل',
          style: GoogleFonts.cairo(
            color: Colors.grey,
          ),
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          hintStyle: GoogleFonts.cairo(
            color: Colors.grey,
          ),
        ),
      ),
    );
  }

  // Text Field Input
  Widget _buildTextFieldInput(
    TextEditingController controller,
    String hintText,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.cairo(),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.cairo(
            color: Colors.grey,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  // Multiline Text Field Input
  Widget _buildMultilineTextFieldInput(
    TextEditingController controller,
    String hintText,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: 5,
        style: GoogleFonts.cairo(),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.cairo(
            color: Colors.grey,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  // Attachment Button
  Widget _buildAttachmentButton(String label, IconData icon) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '$label - قيد التطوير',
                style: GoogleFonts.cairo(),
              ),
              backgroundColor: Colors.blue,
            ),
          );
        },
        icon: Icon(icon),
        label: Text(
          label,
          style: GoogleFonts.cairo(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF001F3F),
          side: const BorderSide(
            color: Color(0xFF001F3F),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // Submit Complaint Handler
  void _submitComplaint() {
    if (selectedRecipient == null ||
        _subjectController.text.isEmpty ||
        _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى ملء جميع الحقول المطلوبة',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    String mode = isSecret ? 'سرية' : 'عادية';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم إرسال الشكوى $mode بنجاح',
          style: GoogleFonts.cairo(),
        ),
        backgroundColor: Colors.green,
      ),
    );

    // Reset form
    _subjectController.clear();
    _messageController.clear();
    setState(() {
      selectedRecipient = null;
      isSecret = false;
    });
  }
}
