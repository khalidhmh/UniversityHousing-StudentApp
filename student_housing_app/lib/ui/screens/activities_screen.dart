import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/viewmodels/activities_view_model.dart';
import 'activity_details_screen.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  @override
  void initState() {
    super.initState();
    // ✅ تحميل الأنشطة بمجرد فتح الصفحة (من الكاش أو السيرفر)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ActivitiesViewModel>(context, listen: false).loadActivities();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // لون خلفية هادئ
      appBar: AppBar(
        title: Text('الأنشطة الطلابية', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF001F3F),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // ✅ إجبار التحديث من السيرفر عند السحب
          await Provider.of<ActivitiesViewModel>(context, listen: false).loadActivities(forceRefresh: true);
        },
        child: Consumer<ActivitiesViewModel>(
          builder: (context, vm, child) {
            // 1. حالة التحميل (فقط إذا كانت القائمة فارغة)
            if (vm.isLoading && vm.activities.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            // 2. حالة الخطأ (فقط إذا كانت القائمة فارغة)
            if (vm.errorMessage != null && vm.activities.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 10),
                    Text(vm.errorMessage!, style: GoogleFonts.cairo(color: Colors.red)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => vm.loadActivities(forceRefresh: true),
                      child: Text("إعادة المحاولة", style: GoogleFonts.cairo()),
                    )
                  ],
                ),
              );
            }

            // 3. حالة القائمة الفارغة
            if (vm.activities.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.event_busy, size: 80, color: Colors.grey),
                    const SizedBox(height: 10),
                    Text("لا توجد أنشطة متاحة حالياً", style: GoogleFonts.cairo(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              );
            }

            // 4. عرض القائمة
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vm.activities.length,
              itemBuilder: (context, index) {
                final activity = vm.activities[index];
                return _buildActivityCard(context, activity);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, Map<String, dynamic> activity) {
    // ✅ إصلاح منطق التحقق من الاشتراك (SQLite يخزن true كـ 1)
    final subVal = activity['is_subscribed'];
    bool isSubscribed = subVal == true || subVal == 1;

    // ✅ إصلاح اسم الحقل ليتوافق مع DataRepository (image_url)
    String imageUrl = activity['image_url'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        // تمييز الأنشطة المشترك بها بإطار أخضر خفيف
        side: isSubscribed ? const BorderSide(color: Colors.green, width: 1.5) : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ActivityDetailsScreen(
                activityId: activity['id'],
                initialData: activity,
              ),
            ),
          ).then((_) {
            // تحديث القائمة عند العودة (تحسباً لتغيير حالة الاشتراك في التفاصيل)
            Provider.of<ActivitiesViewModel>(context, listen: false).loadActivities();
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة النشاط
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 160,
                  color: Colors.grey[200],
                  child: const Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey)),
                ),
              )
                  : Container(
                height: 160,
                width: double.infinity,
                color: Colors.grey[200],
                child: const Center(child: Icon(Icons.event, size: 60, color: Colors.blueGrey)),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // التصنيف
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2C94C).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          activity['category'] ?? 'عام',
                          style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFB8860B) // Dark Golden Rod
                          ),
                        ),
                      ),
                      // حالة الاشتراك
                      if (isSubscribed)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green, size: 14),
                              const SizedBox(width: 4),
                              Text("مشترك", style: GoogleFonts.cairo(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // العنوان
                  Text(
                    activity['title'] ?? 'بدون عنوان',
                    style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF001F3F)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 10),

                  // التاريخ والمكان
                  Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 5),
                      // ✅ إصلاح اسم حقل التاريخ (event_date)
                      Text(
                          activity['event_date'] ?? activity['date'] ?? 'غير محدد',
                          style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey[700])
                      ),
                      const SizedBox(width: 20),
                      const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          activity['location'] ?? 'غير محدد',
                          style: GoogleFonts.cairo(fontSize: 13, color: Colors.grey[700]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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