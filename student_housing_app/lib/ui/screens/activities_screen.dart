import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/viewmodels/activities_view_model.dart';
import '../widgets/pull_to_refresh.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivitiesViewModel>().loadActivities();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          "الأنشطة الطلابية",
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF001F3F),
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<ActivitiesViewModel>(
        builder: (context, viewModel, child) {
          return PullToRefresh(
            onRefresh: viewModel.loadActivities,
            child: _buildBody(viewModel),
          );
        },
      ),
    );
  }

  Widget _buildBody(ActivitiesViewModel viewModel) {
    if (viewModel.isLoading && viewModel.activities.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "لا توجد أنشطة متاحة حالياً",
              style: GoogleFonts.cairo(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: viewModel.activities.length,
      itemBuilder: (context, index) {
        final activity = viewModel.activities[index];
        return FadeInUp(
          duration: const Duration(milliseconds: 500),
          delay: Duration(milliseconds: index * 100),
          child: _buildActivityCard(activity),
        );
      },
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => ActivityDetailsScreen(activity: activity)),
          // );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Placeholder (or real image if available)
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                image: const DecorationImage(
                  image: NetworkImage('https://via.placeholder.com/400x200'), // Replace with activity['image']
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2C94C),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        activity['category'] ?? 'عام',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF001F3F),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity['title'] ?? 'عنوان النشاط',
                    style: GoogleFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF001F3F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(
                        activity['date'] ?? 'تاريخ غير محدد',
                        style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 15),
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 5),
                      Text(
                        activity['location'] ?? 'غير محدد',
                        style: GoogleFonts.cairo(fontSize: 12, color: Colors.grey[600]),
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