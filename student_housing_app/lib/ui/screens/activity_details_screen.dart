import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/viewmodels/activity_details_view_model.dart';
import '../../core/viewmodels/activities_view_model.dart';

class ActivityDetailsScreen extends StatelessWidget {
  final int activityId;
  // نستقبل البيانات المبدئية عشان العرض يكون فوري
  final Map<String, dynamic>? initialData;

  const ActivityDetailsScreen({super.key, required this.activityId, this.initialData});

  @override
  Widget build(BuildContext context) {
    // 1. محاولة العثور على البيانات من القائمة الرئيسية إذا لم تمرر
    Map<String, dynamic> data = initialData ?? {};
    if (data.isEmpty) {
      // البحث في الفيو موديل الرئيسي
      final mainVM = Provider.of<ActivitiesViewModel>(context, listen: false);
      try {
        data = mainVM.activities.firstWhere((element) => element['id'] == activityId);
      } catch (e) {
        data = {};
      }
    }

    // 2. إنشاء الفيو موديل الخاص بهذه الصفحة
    return ChangeNotifierProvider(
      create: (_) => ActivityDetailsViewModel()..setInitialData(data),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Consumer<ActivityDetailsViewModel>(
          builder: (context, vm, child) {
            final activity = vm.activity;
            if (activity == null) {
              return const Center(child: Text("النشاط غير موجود"));
            }

            // استخراج البيانات بأمان
            final String title = activity['title'] ?? "بدون عنوان";
            final String description = activity['description'] ?? "لا يوجد وصف";
            final String category = "عام";
            final String dateStr = activity['event_date'] ?? activity['date'] ?? "";
            final String location = activity['location'] ?? "غير محدد";

            // قراءة حالة الاشتراك الحالية
            final bool isSubscribed = vm.isSubscribed;

            // تنسيق التاريخ والوقت
            String date = dateStr;
            String time = "";
            if (dateStr.contains('T')) {
              final parts = dateStr.split('T');
              date = parts[0];
              time = parts[1].substring(0, 5); // HH:MM
            }

            return CustomScrollView(
              slivers: [
                // ================== Header Image & Title ==================
                SliverAppBar(
                  expandedHeight: 250,
                  pinned: true,
                  backgroundColor: const Color(0xFF001F3F),
                  leading: IconButton(
                    icon: const CircleAvatar(
                        backgroundColor: Colors.black26,
                        child: Icon(Icons.arrow_back, color: Colors.white)
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      color: const Color(0xFF001F3F),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getCategoryIcon(category),
                              size: 60,
                              color: Colors.white24,
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                title,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.cairo(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // ================== Content Body ==================
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // العنوان والتصنيف
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(color: const Color(0xFFF2C94C), borderRadius: BorderRadius.circular(20)),
                                      child: Text(category, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(0xFF001F3F))),
                                    ),
                                    if (isSubscribed)
                                      Row(
                                        children: [
                                          const Icon(Icons.check_circle, color: Colors.green),
                                          const SizedBox(width: 5),
                                          Text("أنت مشترك", style: GoogleFonts.cairo(color: Colors.green, fontWeight: FontWeight.bold)),
                                        ],
                                      )
                                  ],
                                ),
                                const SizedBox(height: 15),
                                Text(title, style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF001F3F))),

                                const SizedBox(height: 25),

                                // معلومات الوقت والمكان
                                _buildInfoRow(Icons.calendar_today, "التاريخ", date),
                                if (time.isNotEmpty) _buildInfoRow(Icons.access_time, "الوقت", time),
                                _buildInfoRow(Icons.location_on, "الموقع", location),

                                const SizedBox(height: 25),

                                // الوصف
                                Text("تفاصيل النشاط", style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF001F3F))),
                                const SizedBox(height: 10),
                                Text(description, style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[700], height: 1.6)),

                                const SizedBox(height: 100), // مسافة للزر العائم
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            );
          },
        ),

        // ================== Action Button (Subscribe / Unsubscribe) ==================
        bottomSheet: Consumer<ActivityDetailsViewModel>(
          builder: (context, vm, child) {
            if (vm.activity == null) return const SizedBox();

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))]),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width > 600 ? 600 : MediaQuery.of(context).size.width - 40,
                      height: 55,
                      child: ElevatedButton(
                        // ✅ التعديل الأهم: استخدام toggleSubscription
                        onPressed: vm.isSubmitting
                            ? null
                            : () => vm.toggleSubscription(context),

                        style: ElevatedButton.styleFrom(
                          // ✅ لو مشترك: أحمر (إلغاء) | لو مش مشترك: أصفر (اشتراك)
                          backgroundColor: vm.isSubscribed ? Colors.red.shade50 : const Color(0xFFF2C94C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: vm.isSubscribed ? const BorderSide(color: Colors.red) : BorderSide.none,
                          ),
                          elevation: vm.isSubscribed ? 0 : 2,
                        ),

                        child: vm.isSubmitting
                            ? const SizedBox(
                            height: 25,
                            width: 25,
                            child: CircularProgressIndicator(strokeWidth: 3)
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // ✅ تغيير الأيقونة والنص حسب الحالة
                            Icon(
                              vm.isSubscribed ? Icons.cancel_outlined : Icons.check_circle_outline,
                              color: vm.isSubscribed ? Colors.red : const Color(0xFF001F3F),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              vm.isSubscribed ? "إلغاء الاشتراك" : "اشترك الآن",
                              style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: vm.isSubscribed ? Colors.red : const Color(0xFF001F3F)
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String? category) {
    if (category == null) return Icons.event;
    if (category.contains('رياضة')) return Icons.sports_soccer;
    if (category.contains('ثقافة')) return Icons.theater_comedy;
    if (category.contains('فن')) return Icons.palette;
    return Icons.event;
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: const Color(0xFF001F3F), size: 20),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
              Text(value, style: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF001F3F))),
            ],
          )
        ],
      ),
    );
  }
}