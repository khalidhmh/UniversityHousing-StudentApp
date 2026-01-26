import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../widgets/pull_to_refresh.dart';
import '../widgets/maintenance/maintenance_card.dart';
import '../widgets/maintenance/maintenance_form_bottom_sheet.dart';
import '../../../core/viewmodels/maintenance_view_model.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  @override
  void initState() {
    super.initState();
    // Load maintenance requests when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MaintenanceViewModel>().getMaintenanceRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF001F3F),
        title: Text(
          'طلبات الصيانة',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListenableBuilder(
        listenable: context.read<MaintenanceViewModel>(),
        builder: (context, _) {
          final viewModel = context.read<MaintenanceViewModel>();
          final requests = viewModel.maintenanceRequests;

          return PullToRefresh(
            onRefresh: () async {
              await viewModel.getMaintenanceRequests();
            },
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: _buildMaintenanceList(viewModel, requests),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showMaintenanceFormBottomSheet(context);
        },
        backgroundColor: const Color(0xFFF2C94C),
        icon: const Icon(
          Icons.add,
          color: Color(0xFF001F3F),
        ),
        label: Text(
          'طلب جديد',
          style: GoogleFonts.cairo(
            color: const Color(0xFF001F3F),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Build maintenance list with loading/error states
  Widget _buildMaintenanceList(
    MaintenanceViewModel viewModel,
    List<Map<String, dynamic>> requests,
  ) {
    // Loading state
    if (viewModel.isLoading && requests.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 50),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'جاري التحميل...',
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Error state
    if (viewModel.errorMessage != null && requests.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 50),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    viewModel.getMaintenanceRequests();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF001F3F),
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
          ),
        ],
      );
    }

    // Empty state
    if (requests.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 80),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.build_circle,
                  size: 64,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'لا توجد طلبات صيانة',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'قم بإرسال طلب صيانة جديد الآن',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Success state with requests list
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return MaintenanceCard(
          id: request['id']?.toString() ?? 'unknown',
          category: request['category'] ?? 'صيانة',
          title: request['title'] ?? 'بدون عنوان',
          location: request['location'] ?? 'غير محدد',
          status: request['status'] ?? 'قيد الانتظار',
          date: _parseDate(request['date']),
        );
      },
    );
  }

  /// Helper to parse date from request data
  DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null) {
      return DateTime.now();
    }

    if (dateValue is DateTime) {
      return dateValue;
    }

    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        return DateTime.now();
      }
    }

    return DateTime.now();
  }

  /// Show maintenance form bottom sheet
  void _showMaintenanceFormBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) {
        return const MaintenanceFormBottomSheet();
      },
    );
  }
}
