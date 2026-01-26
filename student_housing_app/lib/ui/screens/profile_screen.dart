import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/viewmodels/profile_view_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load profile when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    const double mobileWidth = 480.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: mobileWidth,
          ),
          child: Container(
            color: const Color(0xFFF5F5F5),
            child: ListenableBuilder(
              listenable: context.read<ProfileViewModel>(),
              builder: (context, _) {
                final viewModel = context.read<ProfileViewModel>();
                final studentData = viewModel.studentData;

                return Stack(
                  children: [
                    // Gradient background header
                    Container(
                      height: 280,
                      decoration: const BoxDecoration(
                        color: Color(0xFF001F3F),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                      ),
                    ),

                    // Scrollable content
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
                      child: Column(
                        children: [
                          // Loading state
                          if (viewModel.isLoading)
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircularProgressIndicator(),
                                  const SizedBox(height: 20),
                                  Text(
                                    'جاري التحميل...',
                                    style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          // Error state
                          else if (viewModel.errorMessage != null)
                            Center(
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
                                      viewModel.loadProfile();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFF001F3F),
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
                            )
                          // Success state with data
                          else if (studentData != null) ...[
                            // Student info header
                            Center(
                              child: Column(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Colors.white24,
                                      child: const Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    studentData['full_name'] ??
                                        studentData['fullName'] ??
                                        'أحمد حسن محمد',
                                    style: GoogleFonts.cairo(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    studentData['college'] ??
                                        studentData['academic_info'] ??
                                        'كلية الحاسبات والذكاء الاصطناعي',
                                    style: GoogleFonts.cairo(
                                      color: Colors.white70,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),

                            // System ID Card
                            Stack(
                              children: [
                                // Dark blue container
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 25,
                                    horizontal: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF001F3F),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.25),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'رقم النظام',
                                        style: GoogleFonts.cairo(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        studentData['systemId'] ?? 
                                            studentData['student_id'] ??
                                            studentData['id'] ??
                                            'N/A',
                                        style: GoogleFonts.cairo(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Dashed border on top
                                CustomPaint(
                                  painter: DashedBorderPainter(),
                                  child: SizedBox(
                                    width: double.infinity,
                                    height:
                                        25 + 16 + 20, // padding + text height + gap
                                  ),
                                ),

                                // Lock badge
                                Positioned(
                                  top: -8,
                                  left: 20,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFFC107),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.lock,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 30),

                            // National ID
                            _buildInfoCard(
                              label: 'الرقم القومي',
                              value: studentData['nationalId'] ?? 
                                     studentData['national_id'] ?? 
                                     'N/A',
                              showLock: true,
                            ),
                            const SizedBox(height: 20),

                            // Student ID
                            _buildInfoCard(
                              label: 'رقم الطالب',
                              value: studentData['studentId'] ?? 
                                     studentData['student_id'] ?? 
                                     'N/A',
                            ),
                            const SizedBox(height: 20),

                            // Academic Info
                            _buildInfoCard(
                              label: 'المعلومات الأكاديمية',
                              value: studentData['academicInfo'] ?? 
                                     studentData['academic_info'] ?? 
                                     'N/A',
                            ),
                            const SizedBox(height: 20),

                            // Housing Type
                            _buildInfoCard(
                              label: 'نوع السكن',
                              value: studentData['housingType'] ?? 
                                     studentData['housing_type'] ?? 
                                     'N/A',
                            ),
                            const SizedBox(height: 20),

                            // Room
                            _buildInfoCard(
                              label: 'الغرفة',
                              value: studentData['room'] ?? 
                                     studentData['room_json'] ?? 
                                     'N/A',
                            ),
                            const SizedBox(height: 40),
                          ] else
                            // Empty state
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.inbox,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'لا توجد بيانات متاحة',
                                    style: GoogleFonts.cairo(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String label,
    required String value,
    bool showLock = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.cairo(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
              if (showLock)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.yellow[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock,
                    size: 14,
                    color: Colors.yellow[800],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.cairo(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final dashArray = 8.0;
  final gapArray = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final path = Path()..addRect(rect);
    final dashedPath = getDashedPath(path);

    canvas.drawPath(dashedPath, paint);
  }

  Path getDashedPath(Path source) {
    Path dest = Path();
    for (ui.PathMetric metric in source.computeMetrics()) {
      double distance = 0.0;
      bool draw = true;
      while (distance < metric.length) {
        double length = draw ? dashArray : gapArray;
        if (distance + length > metric.length) {
          length = metric.length - distance;
        }
        if (draw) {
          dest.addPath(
            metric.extractPath(distance, distance + length),
            Offset.zero,
          );
        }
        distance += length;
        draw = !draw;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
