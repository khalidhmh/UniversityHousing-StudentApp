import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ComplaintItemCard: Reusable widget for displaying individual complaint
/// 
/// Features:
/// - Dynamic status colors (Pending=Yellow, Resolved=Green)
/// - Expandable details with admin reply
/// - Secret complaint indicator
/// - Date display
class ComplaintItemCard extends StatelessWidget {
  final String id;
  final String title;
  final String description;
  final String status;
  final String? adminReply;
  final DateTime date;
  final bool isSecret;

  const ComplaintItemCard({
    super.key,
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    this.adminReply,
    required this.date,
    this.isSecret = false,
  });

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusIcon, chipBgColor, chipTextColor) = _getStatusColors();
    final displayTitle = isSecret ? 'شكوى سرية' : title;
    final formattedDate = _formatDate(date);

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
            displayTitle,
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF001F3F),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            formattedDate,
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
              status,
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
                      description,
                      style: GoogleFonts.cairo(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Admin Reply or Pending Message
                  if (adminReply != null && adminReply!.isNotEmpty)
                    _buildAdminReply(adminReply!)
                  else
                    _buildPendingMessage(),

                  // Secret Indicator
                  if (isSecret) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E5F5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.purple[300]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock,
                            color: Colors.purple,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'هذه شكوى سرية ولن يتم الكشف عن بياناتك',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: Colors.purple[900],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build admin reply section
  Widget _buildAdminReply(String reply) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  reply,
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
      ],
    );
  }

  /// Build pending message
  Widget _buildPendingMessage() {
    return Container(
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
    );
  }

  /// Get status colors based on status string
  (Color, IconData, Color, Color) _getStatusColors() {
    // Normalize status to lowercase for comparison
    final normalizedStatus = status.toLowerCase();

    if (normalizedStatus.contains('تم الرد') || normalizedStatus.contains('resolved')) {
      return (
        Colors.green,
        Icons.check_circle,
        Colors.green.withOpacity(0.1),
        Colors.green,
      );
    } else if (normalizedStatus.contains('قيد الانتظار') || normalizedStatus.contains('pending')) {
      return (
        Colors.amber,
        Icons.schedule,
        Colors.amber.withOpacity(0.1),
        Colors.amber[700]!,
      );
    } else {
      // Default: pending
      return (
        Colors.amber,
        Icons.schedule,
        Colors.amber.withOpacity(0.1),
        Colors.amber[700]!,
      );
    }
  }

  /// Format date to readable string
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'اليوم';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'قبل ${difference.inDays} أيام';
    } else {
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    }
  }

  /// Get Arabic month name
  String _getMonthName(int month) {
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return months[month - 1];
  }
}
