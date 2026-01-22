import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Model for Request
class PermissionRequest {
  final String id;
  final String type;
  final DateTime fromDate;
  final DateTime toDate;
  final String status; // 'مقبول', 'قيد الانتظار', 'مرفوض'
  final String reason;

  PermissionRequest({
    required this.id,
    required this.type,
    required this.fromDate,
    required this.toDate,
    required this.status,
    required this.reason,
  });
}

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  late List<PermissionRequest> requests;

  @override
  void initState() {
    super.initState();
    requests = _getDummyRequests();
  }

  List<PermissionRequest> _getDummyRequests() {
    return [
      PermissionRequest(
        id: '1',
        type: 'تصريح مبيت',
        fromDate: DateTime(2026, 1, 20),
        toDate: DateTime(2026, 1, 22),
        status: 'مقبول',
        reason: 'حالة صحية طارئة',
      ),
      PermissionRequest(
        id: '2',
        type: 'دخول متأخر',
        fromDate: DateTime(2026, 1, 23),
        toDate: DateTime(2026, 1, 23),
        status: 'قيد الانتظار',
        reason: 'التزامات أكاديمية',
      ),
      PermissionRequest(
        id: '3',
        type: 'إجازة طارئة',
        fromDate: DateTime(2026, 1, 15),
        toDate: DateTime(2026, 1, 18),
        status: 'مرفوض',
        reason: 'زيارة عائلية',
      ),
      PermissionRequest(
        id: '4',
        type: 'تصريح مبيت',
        fromDate: DateTime(2026, 1, 10),
        toDate: DateTime(2026, 1, 12),
        status: 'مقبول',
        reason: 'مشروع أكاديمي',
      ),
    ];
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonth(date.month)} ${date.year}';
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF001F3F),
        title: Text(
          'طلباتي والتصاريح',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              return _buildRequestCard(requests[index]);
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showNewRequestBottomSheet(context);
        },
        backgroundColor: const Color(0xFF001F3F),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildRequestCard(PermissionRequest request) {
    Color statusBgColor;
    Color statusTextColor;

    if (request.status == 'مقبول') {
      statusBgColor = Colors.green.withOpacity(0.1);
      statusTextColor = Colors.green;
    } else if (request.status == 'قيد الانتظار') {
      statusBgColor = Colors.amber.withOpacity(0.1);
      statusTextColor = Colors.amber[700]!;
    } else {
      statusBgColor = Colors.red.withOpacity(0.1);
      statusTextColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Status Badge (Left)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              request.status,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: statusTextColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Request Details (Center)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.type,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF001F3F),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_formatDate(request.fromDate)} - ${_formatDate(request.toDate)}',
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Chevron Icon (Right)
          Icon(
            Icons.chevron_right,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  void _showNewRequestBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return const _NewRequestForm();
      },
    );
  }
}

class _NewRequestForm extends StatefulWidget {
  const _NewRequestForm();

  @override
  State<_NewRequestForm> createState() => __NewRequestFormState();
}

class __NewRequestFormState extends State<_NewRequestForm> {
  String? selectedType;
  DateTime? fromDate;
  DateTime? toDate;
  final TextEditingController reasonController = TextEditingController();

  final List<String> requestTypes = [
    'تصريح مبيت',
    'دخول متأخر',
    'إجازة طارئة',
    'خروج مبكر',
  ];

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  void _submitRequest() {
    if (selectedType == null ||
        fromDate == null ||
        toDate == null ||
        reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى ملء جميع الحقول',
            style: GoogleFonts.cairo(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم إرسال الطلب بنجاح',
          style: GoogleFonts.cairo(),
        ),
        backgroundColor: Colors.green,
      ),
    );

    // Reset form and close
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Center(
              child: Text(
                'طلب جديد',
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF001F3F),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Request Type Dropdown
            Text(
              'نوع التصريح',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF001F3F),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: DropdownButtonFormField<String>(
                initialValue: selectedType,
                items: requestTypes.map((String value) {
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
                    selectedType = newValue;
                  });
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  hintText: 'اختر نوع التصريح',
                  hintStyle: GoogleFonts.cairo(
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // From Date
            Text(
              'من',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF001F3F),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _selectDate(context, true),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        fromDate == null
                            ? 'اختر التاريخ'
                            : '${fromDate!.day}/${fromDate!.month}/${fromDate!.year}',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: fromDate == null
                              ? Colors.grey
                              : const Color(0xFF001F3F),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // To Date
            Text(
              'إلى',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF001F3F),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => _selectDate(context, false),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        toDate == null
                            ? 'اختر التاريخ'
                            : '${toDate!.day}/${toDate!.month}/${toDate!.year}',
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: toDate == null
                              ? Colors.grey
                              : const Color(0xFF001F3F),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Reason TextField
            Text(
              'السبب',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF001F3F),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: reasonController,
                maxLines: 3,
                style: GoogleFonts.cairo(),
                decoration: InputDecoration(
                  hintText: 'اكتب سبب الطلب',
                  hintStyle: GoogleFonts.cairo(
                    color: Colors.grey,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF2C94C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'إرسال الطلب',
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
    );
  }
}
