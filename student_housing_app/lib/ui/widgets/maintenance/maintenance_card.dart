import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MaintenanceCard extends StatelessWidget {
  final String id;
  final String category;    // نوع العطل
  final String description;
  final String status;      // الحالة (pending, in_progress, completed)
  final String date;
  final String? imageUrl;
  final int floor;          // ✅ جديد
  final String wing;        // ✅ جديد
  final String? roomNo;     // ✅ جديد
  final String locationType; // ✅ جديد

  const MaintenanceCard({
    Key? key,
    this.id = '0',
    required this.category,
    required this.description,
    required this.status,
    required this.date,
    required this.floor,
    required this.wing,
    required this.locationType,
    this.roomNo,
    this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // تحديد اللون والنص بناءً على الحالات الثلاث المتفق عليها
    Color statusColor;
    String statusText;

    switch (status.toLowerCase()) {
      case 'completed':
        statusColor = Colors.green;
        statusText = 'تم الإصلاح';
        break;
      case 'in_progress': // ✅ الحالة الجديدة
        statusColor = Colors.blue;
        statusText = 'قيد التصليح';
        break;
      case 'pending':
      default:
        statusColor = Colors.orange;
        statusText = 'قيد الانتظار';
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Icon + Category + Status
            Row(
              children: [
                _buildCategoryIcon(category),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getCategoryName(category),
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      // عرض الموقع التفصيلي (الدور - الجناح - المكان)
                      Text(
                        "الدور $floor - جناح $wing - $locationType ${roomNo != null ? '($roomNo)' : ''}",
                        style: GoogleFonts.cairo(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(statusText, statusColor),
              ],
            ),
            const SizedBox(height: 12),
            Text(description, style: GoogleFonts.cairo(color: Colors.grey[800])),

            if (imageUrl != null && imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildImagePreview(imageUrl!),
            ],

            const SizedBox(height: 12),
            _buildFooter(date),
          ],
        ),
      ),
    );
  }

  // --- ويدجيت فرعية للتنظيم ---

  Widget _buildCategoryIcon(String cat) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(_getCategoryIcon(cat), color: Colors.blue[800]),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: GoogleFonts.cairo(color: color, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  Widget _buildImagePreview(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        url,
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => const SizedBox(),
      ),
    );
  }

  Widget _buildFooter(String dateStr) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
        const SizedBox(width: 4),
        Text(_formatDate(dateStr), style: GoogleFonts.cairo(color: Colors.grey[400], fontSize: 11)),
      ],
    );
  }

  // --- Helper Methods ---

  IconData _getCategoryIcon(String key) {
    const icons = {
      'electricity': Icons.flash_on,
      'plumbing': Icons.plumbing,
      'gas': Icons.local_fire_department,
      'internet': Icons.wifi,
    };
    return icons[key] ?? Icons.build;
  }

  String _getCategoryName(String key) {
    const map = {
      'electricity': 'كهرباء', 'plumbing': 'سباكة', 'carpentry': 'نجارة',
      'aluminum': 'ألوميتال', 'gas': 'غاز', 'internet': 'إنترنت', 'glass': 'زجاج'
    };
    return map[key] ?? key;
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return "${date.year}-${date.month}-${date.day}";
    } catch (e) { return dateStr; }
  }
}