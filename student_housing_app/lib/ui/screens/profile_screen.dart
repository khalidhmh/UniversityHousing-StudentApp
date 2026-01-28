import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/viewmodels/profile_view_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().loadUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF001F3F);
    const accentColor = Color(0xFFF2C94C);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<ProfileViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Premium Header with User Info
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Background Curve
                    Container(
                      height: 280,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(40),
                          bottomRight: Radius.circular(40),
                        ),
                      ),
                    ),
                    
                    // Profile Content
                    Positioned(
                      top: 60, // Adjust for status bar
                      child: Column(
                        children: [
                          // Avatar with border
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: accentColor, width: 3),
                            ),
                            child: CircleAvatar(
                              radius: 55,
                              backgroundColor: Colors.grey,
                              backgroundImage: vm.photoUrl.isNotEmpty 
                                  ? NetworkImage(vm.photoUrl) as ImageProvider
                                  : const AssetImage('assets/profile1.png'), // Fallback if URL is empty but not error
                              onBackgroundImageError: (_, __) {
                                // This handles network errors by showing the fallback asset not handled directly here 
                                // but we rely on the implementation, 
                                // simpler approach with existing code structure:
                              },
                              child: vm.photoUrl.isEmpty 
                                  ? const Icon(Icons.person, size: 60, color: Colors.white) 
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            vm.fullName,
                            style: GoogleFonts.cairo(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            vm.college,
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // System ID Ticket/Card (Floating overlap)
                    Positioned(
                      bottom: -30,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.85,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFF001F3F), // Dark background for the ticket
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: accentColor, style: BorderStyle.solid),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                             Text(
                              "كود الطالب (SYSTEM ID)",
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                             Row(
                               mainAxisAlignment: MainAxisAlignment.center,
                               children: [
                                 const Icon(Icons.copy, color: Colors.white70, size: 18),
                                 const SizedBox(width: 8),
                                 Text(
                                  "SYS-${DateTime.now().year}-${vm.studentId}", // Dynamic System ID format
                                  style: GoogleFonts.cairo(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                  ),
                                 ),
                               ],
                             ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 60), // Space for the overlapping card

            // Read-only Notice
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 18, color: Colors.blue.shade800),
                  const SizedBox(width: 8),
                  Text(
                    "وضع القراءة فقط - لا يمكن تعديل البيانات",
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Info Cards Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildDetailsCard("الرقم القومي", "30412010101234", Icons.credit_card_outlined),
                  _buildDetailsCard("رقم الكارنية", "202604123", Icons.badge_outlined),
                  _buildDetailsCard("الكلية والفرقة", "حاسبات - الفرقة الرابعة", Icons.school_outlined),
                  _buildDetailsCard("نوع السكن", "سكن عادي (مصري)", Icons.apartment_outlined),
                  _buildDetailsCard("المبنى والغرفة", "مبنى (أ) - غرفة 304", Icons.location_on_outlined),
                  // Address
                   _buildDetailsCard("العنوان", "10 شارع التحرير، الدقي، الجيزة", Icons.location_city_outlined),
                ],
              ),
            ),

             const SizedBox(height: 20),
             
             // Contact/Settings
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 20),
               child: Column(
                 children: [
                   _buildActionTile("تغيير كلمة المرور", Icons.lock_reset_outlined, () {}),
                   _buildActionTile("تسجيل الخروج", Icons.logout_outlined, () {}, isDestructive: true),
                 ],
               ),
             ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
           Container(
             padding: const EdgeInsets.all(10),
             decoration: BoxDecoration(
               color: Colors.grey.shade50,
               shape: BoxShape.circle,
             ),
             child: Icon(icon, color: Colors.grey.shade600, size: 22),
           ),
           const SizedBox(width: 16),
           Expanded(
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text(
                   label,
                   style: GoogleFonts.cairo(
                     fontSize: 12,
                     color: Colors.grey.shade500,
                   ),
                 ),
                 Text(
                   value,
                   style: GoogleFonts.cairo(
                     fontSize: 14,
                     fontWeight: FontWeight.bold,
                     color: const Color(0xFF001F3F),
                   ),
                 ),
               ],
             ),
           ),
        ],
      ),
    );
  }

  Widget _buildActionTile(String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDestructive ? Colors.red.shade50 : Colors.white,
         borderRadius: BorderRadius.circular(12),
         border: isDestructive ? Border.all(color: Colors.red.shade100) : Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: isDestructive ? Colors.red : const Color(0xFF001F3F)),
        title: Text(
          title,
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: isDestructive ? Colors.red : const Color(0xFF001F3F),
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: isDestructive ? Colors.red.withOpacity(0.5) : Colors.grey),
      ),
    );
  }
}
