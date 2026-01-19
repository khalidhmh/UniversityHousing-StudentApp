import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Notification {
  final String id;
  final String senderName;
  final String message;
  final String timestamp;
  final NotificationType type;
  final bool isUnread;

  Notification({
    required this.id,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.type,
    this.isUnread = true,
  });
}

enum NotificationType {
  supervisor, // Grey bg, Person Icon
  buildingManager, // Light Blue bg, Building Icon
  generalManager, // Dark Blue bg, Shield Icon
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  List<Notification> _getMockNotifications() {
    return [
      Notification(
        id: '1',
        senderName: 'المشرف',
        message: 'يرجى التأكد من نظافة الغرفة والممرات اليوم قبل الساعة 5 مساءً',
        timestamp: 'منذ ساعتين',
        type: NotificationType.supervisor,
        isUnread: true,
      ),
      Notification(
        id: '2',
        senderName: 'مدير المبنى',
        message: 'سيتم إجراء صيانة دورية في الأدوار 2-4 غداً الساعة 10 صباحاً',
        timestamp: 'منذ 4 ساعات',
        type: NotificationType.buildingManager,
        isUnread: true,
      ),
      Notification(
        id: '3',
        senderName: 'المدير العام',
        message: 'تم استقبال شكواك وسيتم الرد عليها في أقرب وقت ممكن',
        timestamp: 'منذ يوم',
        type: NotificationType.generalManager,
        isUnread: false,
      ),
      Notification(
        id: '4',
        senderName: 'المشرف',
        message: 'تنبيه: الإضاءة الخارجية ستكون معطلة غداً من 2-4 مساءً',
        timestamp: 'منذ يومين',
        type: NotificationType.supervisor,
        isUnread: false,
      ),
      Notification(
        id: '5',
        senderName: 'مدير المبنى',
        message: 'تم تحديث شروط السكن. يرجى مراجعة التطبيق للاطلاع على التفاصيل',
        timestamp: 'منذ 3 أيام',
        type: NotificationType.buildingManager,
        isUnread: false,
      ),
    ];
  }

  Color _getIconBackgroundColor(NotificationType type) {
    switch (type) {
      case NotificationType.supervisor:
        return Colors.grey.withOpacity(0.2);
      case NotificationType.buildingManager:
        return const Color(0xFF4A90E2).withOpacity(0.2);
      case NotificationType.generalManager:
        return const Color(0xFF001F3F).withOpacity(0.2);
    }
  }

  Color _getIconColor(NotificationType type) {
    switch (type) {
      case NotificationType.supervisor:
        return Colors.grey[600]!;
      case NotificationType.buildingManager:
        return const Color(0xFF4A90E2);
      case NotificationType.generalManager:
        return const Color(0xFF001F3F);
    }
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.supervisor:
        return Icons.person;
      case NotificationType.buildingManager:
        return Icons.domain;
      case NotificationType.generalManager:
        return Icons.shield;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _getMockNotifications();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF001F3F),
        title: Text(
          'الإشعارات',
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
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return _buildNotificationItem(
                notifications[index],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationItem(Notification notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notification.isUnread ? Colors.white : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: notification.isUnread
            ? Border.all(
                color: Colors.blue.withOpacity(0.2),
                width: 1.5,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Right: Circular Icon Container
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getIconBackgroundColor(notification.type),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIcon(notification.type),
              color: _getIconColor(notification.type),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Center: Message Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sender Name
                Text(
                  notification.senderName,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF001F3F),
                  ),
                ),
                const SizedBox(height: 6),
                // Message Content
                Text(
                  notification.message,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Left: Timestamp and Unread Indicator
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                notification.timestamp,
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 8),
              if (notification.isUnread)
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6B6B),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
