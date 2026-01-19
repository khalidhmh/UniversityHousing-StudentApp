import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Model for Complaint History
class ComplaintHistory {
  final String id;
  final String subject;
  final String description;
  final String status; // 'تم الرد', 'قيد الانتظار'
  final String? adminReply;
  final DateTime date;
  final bool isSecret;

  ComplaintHistory({
    required this.id,
    required this.subject,
    required this.description,
    required this.status,
    this.adminReply,
    required this.date,
    this.isSecret = false,
  });
}

class ComplaintsHistoryScreen extends StatelessWidget {
  const ComplaintsHistoryScreen({super.key});

  List<ComplaintHistory> _getMockComplaints() {
    return [
      ComplaintHistory(
        id: '1',
        subject: 'مشكلة في سخان الغاز',
        description: 'السخان لا يعمل بشكل صحيح وتكون المياه باردة جداً في الصباح.',
        status: 'تم الرد',
        adminReply: 'تم إرسال الفني المختص وتم إصلاح السخان. تم استبدال قطعة معيبة.',
        date: DateTime(2026, 1, 15),
        isSecret: false,
      ),
      ComplaintHistory(
        id: '2',
        subject: 'صوت مزعج في الليل',
        description: 'هناك صوت عالي ومزعج قادم من الغرفة المجاورة طوال الليل.',
        status: 'قيد الانتظار',
        adminReply: null,
        date: DateTime(2026, 1, 18),
        isSecret: false,
      ),
      ComplaintHistory(
        id: '3',
        subject: 'شكوى سرية',
        description: 'تم إرسال شكوى سرية ولن يتم الكشف عن تفاصيلها.',
        status: 'تم الرد',
        adminReply: 'تم استقبال شكواك السرية وسيتم التعامل معها بسرية تامة.',
        date: DateTime(2026, 1, 10),
        isSecret: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final complaints = _getMockComplaints();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF001F3F),
        title: Text(
          'سجل الشكاوى',
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
            itemCount: complaints.length,
            itemBuilder: (context, index) {
              return _buildComplaintCard(context, complaints[index]);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildComplaintCard(BuildContext context, ComplaintHistory complaint) {
    Color statusColor;
    IconData statusIcon;
    Color chipBgColor;
    Color chipTextColor;

    if (complaint.status == 'تم الرد') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      chipBgColor = Colors.green.withOpacity(0.1);
      chipTextColor = Colors.green;
    } else {
      statusColor = Colors.amber;
      statusIcon = Icons.schedule;
      chipBgColor = Colors.amber.withOpacity(0.1);
      chipTextColor = Colors.amber[700]!;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Icon(
            statusIcon,
            color: statusColor,
            size: 24,
          ),
          title: Text(
            complaint.isSecret ? 'شكوى سرية' : complaint.subject,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF001F3F),
            ),
          ),
          subtitle: Text(
            '${complaint.date.day} Jan ${complaint.date.year}',
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: chipBgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              complaint.status,
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: chipTextColor,
              ),
            ),
          ),
          children: [
            Container(
              color: Colors.grey[50],
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Original Complaint
                  Text(
                    'الشكوى الأصلية',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF001F3F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      complaint.description,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Admin Reply (if exists)
                  if (complaint.adminReply != null) ...[
                    Text(
                      'رد الإدارة',
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF001F3F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green[300]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              complaint.adminReply!,
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                color: Colors.green[900],
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.amber[300]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.schedule,
                            color: Colors.amber[700],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'في انتظار رد من الإدارة...',
                              style: GoogleFonts.cairo(
                                fontSize: 13,
                                color: Colors.amber[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
