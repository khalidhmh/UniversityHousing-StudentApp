import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MaintenanceCard extends StatelessWidget {
  final String id; // ✅ مطلوب
  final String title; // كان category
  final String description; // ✅ جديد
  final String status;
  final String date; // كان created_at
  final String? imageUrl; // ✅ جديد
  final String? location; // ✅ مطلوب

  const MaintenanceCard({
    Key? key,
    this.id = '0',
    required this.title,
    required this.description,
    required this.status,
    required this.date,
    this.imageUrl,
    this.location,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    switch (status.toLowerCase()) {
      case 'completed':
      case 'تم التصليح':
        statusColor = Colors.green;
        statusText = 'تم الإصلاح';
        break;
      case 'pending':
      case 'قيد الانتظار':
      default:
        statusColor = Colors.orange;
        statusText = 'قيد الانتظار';
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.build, color: Colors.blue[800]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getCategoryName(title),
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      if (location != null)
                        Text(
                          location!,
                          style: GoogleFonts.cairo(color: Colors.grey, fontSize: 12),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: GoogleFonts.cairo(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              description,
              style: GoogleFonts.cairo(color: Colors.grey[800]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            // Image (If exists)
            if (imageUrl != null && imageUrl!.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  imageUrl!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c,e,s) => const SizedBox(), // إخفاء لو فشل التحميل
                ),
              ),
            ],

            const SizedBox(height: 12),
            // Footer: Date
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  _formatDate(date),
                  style: GoogleFonts.cairo(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return "${date.year}-${date.month}-${date.day}";
    } catch (e) {
      return dateStr;
    }
  }

  String _getCategoryName(String key) {
    const map = {
      'electricity': 'كهرباء',
      'plumbing': 'سباكة',
      'carpentry': 'نجارة',
      'aluminum': 'ألوميتال',
      'gas': 'غاز',
      'internet': 'إنترنت',
    };
    return map[key] ?? key;
  }
}