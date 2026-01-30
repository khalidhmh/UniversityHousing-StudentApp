import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/viewmodels/notifications_view_model.dart';
// import '../widgets/pull_to_refresh.dart'; // تأكد من المسار أو استخدم RefreshIndicator العادي

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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // خلفية رمادية فاتحة جداً
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
      // ✅ RefreshIndicator بسيط ومباشر
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<NotificationsViewModel>().loadNotifications();
        },
        child: Consumer<NotificationsViewModel>(
          builder: (context, vm, child) {
            return _buildBody(vm);
          },
        ),
      ),
    );
  }

  Widget _buildBody(NotificationsViewModel viewModel) {
    // 1. Loading
    if (viewModel.isLoading && viewModel.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Error
    if (viewModel.errorMessage != null && viewModel.notifications.isEmpty) {
      return ListView(
        padding: const EdgeInsets.only(top: 100),
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(viewModel.errorMessage!, textAlign: TextAlign.center, style: GoogleFonts.cairo()),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: viewModel.loadNotifications,
              child: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
            ),
          )
        ],
      );
    }

    // 3. Empty
    if (viewModel.notifications.isEmpty) {
      return ListView(
        padding: const EdgeInsets.only(top: 100),
        children: [
          const Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'لا توجد إشعارات جديدة',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(fontSize: 18, color: Colors.grey[600]),
          ),
        ],
      );
    }

    // 4. List
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.notifications.length,
      itemBuilder: (context, index) {
        final notification = viewModel.notifications[index];
        return _buildNotificationCard(notification);
      },
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    // تحليل النوع لتحديد الأيقونة واللون
    final type = _getNotificationType(notification);
    final isRead = notification['is_read'] == true || notification['is_read'] == 1;

    return Dismissible(
      key: Key(notification['id'].toString()),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        // TODO: Implement delete logic
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: isRead ? 0 : 2, // الإشعار غير المقروء يكون بارز
        color: isRead ? Colors.white : Colors.blue.shade50, // تمييز لوني
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // عند الضغط، نحدد الإشعار كمقروء
            context.read<NotificationsViewModel>().markAsRead(notification['id']);

            // TODO: توجيه المستخدم للشاشة المناسبة حسب النوع
            // if (type == NotificationType.maintenance) Navigator.pushNamed(...)
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الأيقونة الملونة
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: _getBgColor(type),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_getIcon(type), color: _getIconColor(type), size: 22),
                ),
                const SizedBox(width: 15),

                // المحتوى
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            notification['title'] ?? 'إشعار جديد',
                            style: GoogleFonts.cairo(
                                fontSize: 15,
                                fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                color: const Color(0xFF001F3F)
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        notification['message'] ?? notification['body'] ?? '',
                        style: GoogleFonts.cairo(
                            fontSize: 13,
                            color: Colors.grey[700],
                            height: 1.4
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(notification['created_at']),
                        style: GoogleFonts.cairo(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Helpers ---

  // تحديد نوع الإشعار من العنوان أو المحتوى (مؤقتاً حتى يدعم الباك إند حقل type)
  _NotifType _getNotificationType(Map<String, dynamic> notif) {
    final title = (notif['title'] ?? '').toString().toLowerCase();

    if (title.contains('صيانة') || title.contains('تصليح')) return _NotifType.maintenance;
    if (title.contains('شكوى') || title.contains('مقترح')) return _NotifType.complaint;
    if (title.contains('نشاط') || title.contains('مسابقة')) return _NotifType.activity;
    if (title.contains('إنذار') || title.contains('غياب') || title.contains('جزاء')) return _NotifType.warning;

    return _NotifType.general;
  }

  Color _getBgColor(_NotifType type) {
    switch (type) {
      case _NotifType.maintenance: return Colors.orange.withOpacity(0.15);
      case _NotifType.complaint: return Colors.purple.withOpacity(0.15);
      case _NotifType.warning: return Colors.red.withOpacity(0.15);
      case _NotifType.activity: return Colors.green.withOpacity(0.15);
      default: return Colors.blue.withOpacity(0.15);
    }
  }

  Color _getIconColor(_NotifType type) {
    switch (type) {
      case _NotifType.maintenance: return Colors.orange[800]!;
      case _NotifType.complaint: return Colors.purple[800]!;
      case _NotifType.warning: return Colors.red[800]!;
      case _NotifType.activity: return Colors.green[800]!;
      default: return Colors.blue[800]!;
    }
  }

  IconData _getIcon(_NotifType type) {
    switch (type) {
      case _NotifType.maintenance: return Icons.build_circle_outlined;
      case _NotifType.complaint: return Icons.support_agent;
      case _NotifType.warning: return Icons.warning_amber_rounded;
      case _NotifType.activity: return Icons.celebration;
      default: return Icons.notifications_none;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 60) return 'منذ ${diff.inMinutes} دقيقة';
      if (diff.inHours < 24) return 'منذ ${diff.inHours} ساعة';
      if (diff.inDays == 1) return 'أمس';
      return '${date.day}/${date.month}';
    } catch (e) {
      return '';
    }
  }
}

enum _NotifType {
  maintenance, // صيانة
  complaint,   // شكوى
  warning,     // إنذار/غياب
  activity,    // نشاط
  general      // عام
}