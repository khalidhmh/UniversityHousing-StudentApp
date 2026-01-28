import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';

/// ClearanceTimelineCard: Shows timeline with progress steps (State B - request exists)
/// 
/// Displays:
/// - Animated timeline with 3 steps
/// - Current step highlighted in orange (pulsing)
/// - Completed steps in green
/// - Future steps in grey
/// - Yellow info box with instructions
class ClearanceTimelineCard extends StatelessWidget {
  final Map<String, dynamic>? clearanceData;

  const ClearanceTimelineCard({
    super.key,
    required this.clearanceData,
  });

  @override
  Widget build(BuildContext context) {
    // Determine which step is currently active based on clearanceData
    final currentStep = _getCurrentStep();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Step 1: Request submitted (completed)
          FadeInLeft(
            delay: const Duration(milliseconds: 200),
            from: 50,
            child: _buildTimelineStep(
              icon: Icons.check_circle,
              iconColor: const Color(0xFF00C853),
              title: "تقديم الطلب",
              subtitle: "تم تسجيل طلبك بنجاح",
              isActive: false,
              isLast: false,
              isCompleted: true,
            ),
          ),

          // Step 2: Supervisor review (current)
          FadeInLeft(
            delay: const Duration(milliseconds: 800),
            from: 50,
            child: _buildTimelineStep(
              icon: Icons.access_time_filled,
              iconColor: const Color(0xFFFFC107),
              title: "مراجعة المشرف",
              subtitle: "بانتظار زيارة المشرف للغرفة",
              isActive: currentStep == 2,
              isLast: false,
              isPulsing: currentStep == 2,
            ),
          ),

          // Step 3: Final approval (future)
          FadeInLeft(
            delay: const Duration(milliseconds: 1400),
            from: 50,
            child: _buildTimelineStep(
              icon: Icons.verified_user_outlined,
              iconColor: Colors.grey[300]!,
              title: "الاعتماد النهائي",
              subtitle: "موافقة إدارة الإسكان",
              isActive: false,
              isLast: true,
              isCompleted: false,
            ),
          ),

          const SizedBox(height: 30),

          // Info box
          SlideInUp(
            delay: const Duration(milliseconds: 1800),
            child: Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9C4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFFBC02D),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFFF57F17),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "يرجى التواجد في الغرفة لتسهيل عملية الفحص.",
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: const Color(0xFFF57F17),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  /// Determine which step is currently active
  /// Based on clearanceData status field
  int _getCurrentStep() {
    if (clearanceData == null) return 2;

    final status = clearanceData!['status']?.toString().toLowerCase() ?? 'pending';

    // Step mapping based on status
    if (status == 'completed' || status == 'approved') {
      return 3; // All steps completed
    } else if (status == 'in_review' || status == 'in-review') {
      return 2; // Currently in review
    } else {
      return 2; // Default to review step (pending)
    }
  }

  /// Build individual timeline step
  Widget _buildTimelineStep({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isActive,
    required bool isLast,
    bool isPulsing = false,
    bool isCompleted = false,
  }) {
    Widget iconWidget = Icon(icon, color: iconColor, size: 30);

    if (isPulsing) {
      iconWidget = Pulse(
        infinite: true,
        duration: const Duration(seconds: 2),
        child: iconWidget,
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            iconWidget,
            if (!isLast)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 50.0),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, child) {
                  return Container(
                    width: 2,
                    height: value,
                    color: isCompleted
                        ? const Color(0xFF00C853)
                        : Colors.grey[200],
                    margin: const EdgeInsets.symmetric(vertical: 5),
                  );
                },
              ),
          ],
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isActive ? const Color(0xFF001F3F) : Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }
}
