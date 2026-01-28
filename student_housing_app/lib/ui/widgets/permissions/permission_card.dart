import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// PermissionCard: Reusable widget for displaying individual permission requests
/// 
/// Shows:
/// - Status badge with color coding (Green/Orange/Red)
/// - Permission type and date range
/// - Consistent styling across all permission requests
class PermissionCard extends StatelessWidget {
  final String id;
  final String type;
  final DateTime fromDate;
  final DateTime toDate;
  final String status;
  final String reason;

  const PermissionCard({
    super.key,
    required this.id,
    required this.type,
    required this.fromDate,
    required this.toDate,
    required this.status,
    required this.reason,
  });

  @override
  Widget build(BuildContext context) {
    final (bgColor, textColor) = _getStatusColors();

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
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: GoogleFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: textColor,
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
                  type,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF001F3F),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_formatDate(fromDate)} - ${_formatDate(toDate)}',
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

  /// Get status colors based on permission status
  /// Returns: (backgroundColor, textColor)
  (Color, Color) _getStatusColors() {
    if (status == 'مقبول') {
      return (Colors.green.withOpacity(0.1), Colors.green);
    } else if (status == 'قيد الانتظار') {
      return (Colors.amber.withOpacity(0.1), Colors.amber[700]!);
    } else {
      return (Colors.red.withOpacity(0.1), Colors.red);
    }
  }

  /// Format date to Arabic style (e.g., "١٩ يناير ٢٠٢٦")
  String _formatDate(DateTime date) {
    return '${date.day} ${_getArabicMonth(date.month)} ${date.year}';
  }

  /// Get Arabic month names
  String _getArabicMonth(int month) {
    const arabicMonths = [
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
    return arabicMonths[month - 1];
  }
}
