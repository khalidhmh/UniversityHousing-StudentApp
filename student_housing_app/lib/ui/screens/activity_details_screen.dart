import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/activity_model.dart';

class ActivityDetailsScreen extends StatelessWidget {
  final Activity activity;

  const ActivityDetailsScreen({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
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
                        _getCategoryIcon(activity.category),
                        size: 60,
                        color: Colors.white24,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        activity.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          color: Colors.white30,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            // ✅ التعديل هنا: استخدمنا Column عشان "نمسك" الارتفاع
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
                                child: Text(activity.category, style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: const Color(0xFF001F3F))),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(activity.title, style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF001F3F))),

                          const SizedBox(height: 25),

                          // معلومات الوقت والمكان
                          _buildInfoRow(Icons.calendar_today, "التاريخ", activity.date),
                          _buildInfoRow(Icons.access_time, "الوقت", activity.time),
                          _buildInfoRow(Icons.location_on, "الموقع", activity.location),

                          const SizedBox(height: 25),

                          // الخريطة (مجرد شكل عشان ميعملش Error)
                          Container(
                            height: 150,
                            width: double.infinity,
                            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey[300]!)),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.map, size: 40, color: Colors.grey[400]),
                                  Text("[Map Preview]", style: GoogleFonts.cairo(color: Colors.grey)),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 25),
                          Text("تفاصيل النشاط", style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF001F3F))),
                          const SizedBox(height: 10),
                          Text(activity.description, style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[700], height: 1.6)),
                          
                          const SizedBox(height: 100), // مسافة عشان الزرار العائم
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -5))]),
        child: Row( // استخدمنا Row وجواه Expanded عشان نضمن التمركز صح
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SizedBox(
                // لازم نحدد عرض ثابت أو نستخدم Expanded لو جوه Row
                width: MediaQuery.of(context).size.width > 600 ? 600 : MediaQuery.of(context).size.width - 40, 
                height: 55,
                child: ElevatedButton(
                  onPressed: () {}, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2C94C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text("اشترك الآن", style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF001F3F))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
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