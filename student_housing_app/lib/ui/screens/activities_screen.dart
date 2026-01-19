import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/models/activity_model.dart';
import 'activity_details_screen.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  // Dummy activities data
  List<Activity> _getDummyActivities() {
    return [
      Activity(
        id: '1',
        title: 'بطولة كرة القدم الداخلية',
        category: 'رياضة',
        date: '2026-01-25',
        time: '03:00 PM',
        location: 'ملعب الجامعة الرئيسي',
        imagePath: 'https://placehold.co/600x400/001F3F/FFFFFF?text=كرة+القدم',
        description: 'بطولة كرة القدم الداخلية للطلاب. تنافس شريف بين جميع الأقسام الأكاديمية. ستقام في ملعب الجامعة الرئيسي يوم السبت. مشاركة مفتوحة لجميع الطلاب.',
      ),
      Activity(
        id: '2',
        title: 'معرض الثقافة الإسلامية',
        category: 'ثقافة',
        date: '2026-01-26',
        time: '10:00 AM',
        location: 'المكتبة المركزية',
        imagePath: 'https://placehold.co/600x400/F2C94C/001F3F?text=معرض+ثقافي',
        description: 'معرض شامل يعرض التراث الإسلامي والفن والحضارة. يتضمن محاضرات وعروض تقديمية وورش عمل تفاعلية. فرصة رائعة للتعرف على الجوانب المختلفة للثقافة الإسلامية.',
      ),
      Activity(
        id: '3',
        title: 'دورة تطوير المهارات الرقمية',
        category: 'تدريب',
        date: '2026-01-27',
        time: '02:00 PM',
        location: 'قاعة المحاضرات (أ)',
        imagePath: 'https://placehold.co/600x400/001F3F/F2C94C?text=تدريب+رقمي',
        description: 'دورة تدريبية مكثفة في المهارات الرقمية والبرمجة الأساسية. يقدمها متخصصون من قطاع التكنولوجيا. مناسبة للمبتدئين والمتقدمين. تشمل مشاريع عملية وشهادة إتمام.',
      ),
      Activity(
        id: '4',
        title: 'حفل الموسيقى الصاخب',
        category: 'ترفيه',
        date: '2026-01-28',
        time: '07:00 PM',
        location: 'الساحة الرئيسية',
        imagePath: 'https://placehold.co/600x400/F2C94C/001F3F?text=حفل+موسيقي',
        description: 'حفل موسيقي حي يضم فنانين محليين وعالميين. تجربة موسيقية لا تُنسى مع أفضل الفنانين. حضور مجاني لجميع الطلاب. احجز مقعدك مبكراً.',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final activities = _getDummyActivities();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF001F3F),
        title: Text(
          'الأنشطة والفعاليات',
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
            itemCount: activities.length,
            itemBuilder: (context, index) {
              return _buildActivityCard(context, activities[index]);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard(BuildContext context, Activity activity) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActivityDetailsScreen(activity: activity),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            // Image with badge
            Stack(
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF001F3F),
                  ),
                  child: _buildActivityImagePlaceholder(activity.category),
                ),
                // Category badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF001F3F),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      activity.category,
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Title & Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.title,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF001F3F),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        activity.date,
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          activity.location,
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ActivityDetailsScreen(activity: activity),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color(0xFF001F3F),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'عرض التفاصيل',
                        style: GoogleFonts.cairo(
                          color: const Color(0xFF001F3F),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to get appropriate icon for activity category
  Widget _buildActivityImagePlaceholder(String category) {
    IconData icon = Icons.event;
    Color iconColor = Colors.white;

    if (category == 'رياضة') {
      icon = Icons.sports_volleyball;
    } else if (category == 'ثقافة') {
      icon = Icons.palette;
    } else if (category == 'تدريب') {
      icon = Icons.school;
    } else if (category == 'ترفيه') {
      icon = Icons.music_note;
    }

    return Center(
      child: Icon(
        icon,
        size: 80,
        color: iconColor,
      ),
    );
  }
}
