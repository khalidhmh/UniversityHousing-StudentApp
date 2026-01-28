import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/viewmodels/notifications_view_model.dart';
import '../widgets/pull_to_refresh.dart'; // ✅ الاستيراد الصحيح للويدجت بتاعنا

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsViewModel>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    const double mobileWidth = 600.0;

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
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: mobileWidth),
          child: ListenableBuilder(
            listenable: context.read<NotificationsViewModel>(),
            builder: (context, _) {
              final viewModel = context.read<NotificationsViewModel>();

              // ✅ استخدام PullToRefresh المخصص
              return PullToRefresh(
                onRefresh: viewModel.loadNotifications,
                child: _buildBody(viewModel),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(NotificationsViewModel viewModel) {
    // Loading state (initial load)
    if (viewModel.isLoading && viewModel.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            Text(
              'جاري تحميل الإشعارات...',
              style: GoogleFonts.cairo(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    // Error state
    if (viewModel.errorMessage != null && viewModel.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              viewModel.errorMessage!,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 16,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                viewModel.loadNotifications();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF001F3F),
              ),
              child: Text(
                'إعادة محاولة',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (viewModel.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_off,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد إشعارات',
              style: GoogleFonts.cairo(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Notifications list
    return ListView.builder(
      shrinkWrap: true, // ✅ مفتاح الحل 1
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.notifications.length,
      itemBuilder: (context, index) {
        return _buildNotificationItem(
          viewModel.notifications[index],
        );
      },
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final type = _parseNotificationType(notification['type']);
    final isUnread = notification['isUnread'] ?? notification['is_unread'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? Colors.white : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: isUnread
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
              color: _getIconBackgroundColor(type),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIcon(type),
              color: _getIconColor(type),
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
                  notification['senderName'] ??
                      notification['sender_name'] ??
                      notification['from'] ??
                      'مرسل غير معروف',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF001F3F),
                  ),
                ),
                const SizedBox(height: 6),
                // Message Content
                Text(
                  notification['message'] ??
                      notification['body'] ??
                      '',
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
                notification['timestamp'] ??
                    notification['created_at'] ??
                    '',
                style: GoogleFonts.cairo(
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 8),
              if (isUnread)
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

  NotificationType _parseNotificationType(dynamic type) {
    if (type is String) {
      switch (type.toLowerCase()) {
        case 'supervisor':
          return NotificationType.supervisor;
        case 'buildingmanager':
        case 'building_manager':
          return NotificationType.buildingManager;
        case 'generalmanager':
        case 'general_manager':
          return NotificationType.generalManager;
        default:
          return NotificationType.supervisor;
      }
    }
    return NotificationType.supervisor;
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
}

enum NotificationType {
  supervisor,
  buildingManager,
  generalManager,
}