import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// MaintenanceCard: Reusable widget for displaying individual maintenance request
/// 
/// Features:
/// - Dynamic status colors (Fixed=Green, Pending=Orange)
/// - Category icon
/// - Location display
/// - Formatted date
class MaintenanceCard extends StatelessWidget {
  final String id;
  final String category;
  final String title;
  final String location;
  final String status;
  final DateTime date;

  const MaintenanceCard({
    super.key,
    required this.id,
    required this.category,
    required this.title,
    required this.location,
    required this.status,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final (statusBgColor, statusTextColor) = _getStatusColors();
    final categoryIcon = _getCategoryIcon(category);

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
          // Category Icon (Left)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              categoryIcon,
              size: 24,
              color: const Color(0xFF001F3F),
            ),
          ),
          const SizedBox(width: 12),

          // Request Details (Center)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF001F3F),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  location,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(date),
                  style: GoogleFonts.cairo(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Status Badge (Right)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              status,
              style: GoogleFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: statusTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get status colors based on status string
  (Color, Color) _getStatusColors() {
    final normalizedStatus = status.toLowerCase();

    if (normalizedStatus.contains('تم الإصلاح') || normalizedStatus.contains('fixed')) {
      return (
        Colors.green.withOpacity(0.1),
        Colors.green,
      );
    } else if (normalizedStatus.contains('قيد الانتظار') || normalizedStatus.contains('pending')) {
      return (
        Colors.amber.withOpacity(0.1),
        Colors.amber[700]!,
      );
    } else {
      // Default: pending
      return (
        Colors.amber.withOpacity(0.1),
        Colors.amber[700]!,
      );
    }
  }

  /// Get icon for category
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'كهرباء':
      case 'electrical':
        return Icons.electrical_services;
      case 'سباكة':
      case 'plumbing':
        return Icons.plumbing;
      case 'نجارة':
      case 'carpentry':
        return Icons.handyman;
      case 'ألوميتال':
      case 'aluminum':
        return Icons.window;
      case 'غاز':
      case 'gas':
        return Icons.gas_meter;
      default:
        return Icons.build;
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
