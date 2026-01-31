import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/viewmodels/profile_view_model.dart';
import '../../core/services/auth_service.dart';
import '../screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // ✅ تحميل البيانات مرة واحدة عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileViewModel>().loadUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('الملف الشخصي', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF001F3F),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.logout, color: Colors.red),
          //   onPressed: () async {
          //     await Provider.of<AuthService>(context, listen: false).logout();
          //     if (mounted) {
          //       Navigator.of(context).pushAndRemoveUntil(
          //         MaterialPageRoute(builder: (context) => const LoginScreen()),
          //         (route) => false,
          //       );
          //     }
          //   },
          // )
        ],
      ),
      body: Consumer<ProfileViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            print(vm.photoUrl);

            return const Center(child: CircularProgressIndicator());

          }

          if (vm.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 10),
                  Text(vm.errorMessage!),
                  TextButton(
                    onPressed: () => vm.loadUserProfile(),
                    child: const Text("إعادة المحاولة"),
                  )
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => vm.loadUserProfile(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 1. صورة البروفايل
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 65,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey.shade100,
                          backgroundImage: vm.photoUrl.isNotEmpty
                              ? NetworkImage(vm.photoUrl)
                              : const AssetImage('assets/default_avatar.png') as ImageProvider,
                          // إضافة أداة عرض أثناء التحميل أو الخطأ
                          child: vm.photoUrl.isEmpty
                              ? const Icon(Icons.person, size: 60, color: Colors.grey)
                              : null,
                        ),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          onPressed: () {
                            // TODO: Add image picker logic here later
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('سيتم تفعيل رفع الصورة قريباً')),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),

                  // الاسم والرقم القومي
                  Text(
                    vm.fullName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    vm.nationalId,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 30),

                  // 2. كروت المعلومات (تم تحديثها بالحقول الجديدة)
                  _buildInfoCard(
                    context,
                    title: 'المعلومات الأكاديمية',
                    icon: Icons.school,
                    items: [
                      _InfoItem('الكلية', vm.faculty),
                      _InfoItem('المستوى', vm.userProfile?['level']?.toString() ?? 'غير محدد'),
                    ]
                  ),

                  _buildInfoCard(
                    context,
                    title: 'بيانات السكن',
                    icon: Icons.home,
                    items: [
                      _InfoItem('المبنى', vm.buildingName),
                      _InfoItem('رقم الغرفة', vm.roomNumber),
                      _InfoItem('نوع السكن', vm.userProfile?['housing_type'] ?? 'عادي'),
                    ]
                  ),

                  _buildInfoCard(
                    context,
                    title: 'التواصل',
                    icon: Icons.contact_phone,
                    items: [
                      _InfoItem('رقم الهاتف', vm.phone), // ✅ الجديد
                      _InfoItem('العنوان', vm.address),   // ✅ الجديد
                    ]
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required String title, required IconData icon, required List<_InfoItem> items}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 30),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.label, style: TextStyle(color: Colors.grey[600])),
                Expanded(
                  child: Text(
                    item.value,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;
  _InfoItem(this.label, this.value);
}