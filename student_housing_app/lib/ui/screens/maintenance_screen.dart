import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // تأكد إنك ضايف المكتبة دي
import '../../core/viewmodels/maintenance_view_model.dart';
import '../widgets/maintenance/maintenance_card.dart';
import '../widgets/maintenance/maintenance_form_bottom_sheet.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({Key? key}) : super(key: key);

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  @override
  void initState() {
    super.initState();
    // ✅ تحميل البيانات
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MaintenanceViewModel>().loadRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text('طلبات الصيانة', style: GoogleFonts.cairo(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF001F3F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const MaintenanceFormBottomSheet(),
          );
        },
        label: Text('طلب جديد', style: GoogleFonts.cairo(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFFF2C94C),
        foregroundColor: const Color(0xFF001F3F),
      ),
      body: Consumer<MaintenanceViewModel>(
        builder: (context, vm, child) {
          // Loading
          if (vm.isLoading && vm.requests.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Empty
          if (vm.requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.build_circle_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 20),
                  Text('لا توجد طلبات صيانة سابقة', style: GoogleFonts.cairo(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          // List
          return RefreshIndicator(
            onRefresh: () => vm.loadRequests(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: vm.requests.length,
              // داخل ListView.builder في MaintenanceScreen
              itemBuilder: (context, index) {
                final req = vm.requests[index];

                return MaintenanceCard(
                  id: req['id']?.toString() ?? '0',
                  category: req['category'] ?? 'عام', // تأكد من تغيير المسمى لـ category لو غيرته في الكارت
                  description: req['description'] ?? 'لا يوجد وصف',
                  status: req['status'] ?? 'pending',
                  date: req['created_at'] ?? '',
                  imageUrl: req['image_url'],
                  // البيانات الجديدة المفصلة
                  floor: req['floor'] ?? 0,
                  wing: req['wing'] ?? '',
                  locationType: req['location_type'] ?? '',
                  roomNo: req['room_number'],
                );
              },
            ),
          );
        },
      ),
    );
  }
}