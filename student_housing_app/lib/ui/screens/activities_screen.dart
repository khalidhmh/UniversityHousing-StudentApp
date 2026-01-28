import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/viewmodels/activities_view_model.dart';
import 'activity_details_screen.dart'; // تأكد من المسار

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen> {
  @override
  void initState() {
    super.initState();
    // ✅ الحل السحري:
    // بنطلب تحميل الأنشطة بمجرد فتح الصفحة، حتى لو فيه داتا قديمة
    // استخدام addPostFrameCallback عشان نتجنب مشاكل الـ Build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ActivitiesViewModel>(context, listen: false).loadActivities();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('الأنشطة الطلابية', style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF001F3F),
        centerTitle: true,
        elevation: 0,
      ),
      // ✅ إضافة RefreshIndicator عشان تقدر تشد الشاشة لتحت وتحدث يدوي
      body: RefreshIndicator(
        onRefresh: () async {
          await Provider.of<ActivitiesViewModel>(context, listen: false).loadActivities();
        },
        child: Consumer<ActivitiesViewModel>(
          builder: (context, vm, child) {
            // حالة التحميل (لو القائمة فاضية بس)
            if (vm.isLoading && vm.activities.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            // حالة الخطأ (لو القائمة فاضية وفيه إيرور)
            if (vm.errorMessage != null && vm.activities.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 10),
                    Text(vm.errorMessage!, style: GoogleFonts.cairo(color: Colors.red)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: vm.loadActivities,
                      child: Text("إعادة المحاولة", style: GoogleFonts.cairo()),
                    )
                  ],
                ),
              );
            }

            // حالة القائمة الفاضية (مفيش أنشطة خالص)
            if (vm.activities.isEmpty) {
              return Center(child: Text("لا توجد أنشطة حالياً", style: GoogleFonts.cairo(color: Colors.grey)));
            }

            // ✅ عرض القائمة
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
    // تحديد هل الطالب مشترك أم لا لتغيير شكل الكارت
    bool isSubscribed = activity['is_subscribed'] == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        // لو مشترك، بنحط حدود خضراء خفيفة للكارت
        side: isSubscribed ? const BorderSide(color: Colors.green, width: 2) : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          // الانتقال لصفحة التفاصيل مع تمرير البيانات
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ActivityDetailsScreen(
                activityId: activity['id'],
                initialData: activity,
              ),
            ),
          ).then((_) {
            // ✅ لما يرجع من التفاصيل، نعمل تحديث عشان لو اشترك أو ألغى هناك
            Provider.of<ActivitiesViewModel>(context, listen: false).loadActivities();
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة النشاط
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
              child: Image.network(
                activity['imagePath'] ?? '',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey)),
                ),
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
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2C94C).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          activity['category'] ?? 'عام',
                          style: GoogleFonts.cairo(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFF2C94C) // نص ذهبي
                          ),
                        ),
                      ),
                      // ✅ أيقونة الاشتراك (تظهر فقط لو مشترك)
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
                  const SizedBox(height: 8),
                  Text(
                    activity['title'],
                    style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF001F3F)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(activity['date'], style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
                      const SizedBox(width: 16),
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(activity['location'], style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey)),
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