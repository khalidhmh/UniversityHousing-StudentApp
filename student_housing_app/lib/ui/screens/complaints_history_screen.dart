import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../widgets/pull_to_refresh.dart';
import '../widgets/complaints/complaint_item_card.dart';
import '../../../core/viewmodels/complaints_view_model.dart';
import 'complaints_screen.dart';

class ComplaintsHistoryScreen extends StatefulWidget {
  const ComplaintsHistoryScreen({super.key});

  @override
  State<ComplaintsHistoryScreen> createState() => _ComplaintsHistoryScreenState();
}

class _ComplaintsHistoryScreenState extends State<ComplaintsHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Load complaints when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ComplaintsViewModel>().getComplaints();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF001F3F),
        title: Text(
          'سجل الشكاوى',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Filter menu
          PopupMenuButton<String>(
            onSelected: (value) {
              context.read<ComplaintsViewModel>().filterComplaints(value);
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('الكل'),
              ),
              const PopupMenuItem(
                value: 'pending',
                child: Text('قيد الانتظار'),
              ),
              const PopupMenuItem(
                value: 'resolved',
                child: Text('تم الرد'),
              ),
            ],
            icon: const Icon(Icons.filter_list, color: Colors.white),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: context.read<ComplaintsViewModel>(),
        builder: (context, _) {
          final viewModel = context.read<ComplaintsViewModel>();
          final complaints = viewModel.complaints;

          return PullToRefresh(
            onRefresh: () async {
              await viewModel.getComplaints();
            },
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: _buildComplaintsList(viewModel, complaints),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ComplaintsScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFFF2C94C),
        icon: const Icon(
          Icons.add,
          color: Color(0xFF001F3F),
        ),
        label: Text(
          'شكوى جديدة',
          style: GoogleFonts.cairo(
            color: const Color(0xFF001F3F),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Build complaints list with loading/error states
  Widget _buildComplaintsList(ComplaintsViewModel viewModel, List<Map<String, dynamic>> complaints) {
    // Loading state
    if (viewModel.isLoading && complaints.isEmpty) {
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
    if (viewModel.errorMessage != null && complaints.isEmpty) {
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
                    viewModel.getComplaints();
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
    if (complaints.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 80),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox,
                  size: 64,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'لا توجد شكاوى',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'قم بإرسال شكواك الأولى الآن',
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

    // Success state with complaints list
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: complaints.length,
      itemBuilder: (context, index) {
        final complaint = complaints[index];
        return ComplaintItemCard(
          id: complaint['id']?.toString() ?? 'unknown',
          title: complaint['title'] ?? 'بدون عنوان',
          description: complaint['description'] ?? '',
          status: complaint['status'] ?? 'قيد الانتظار',
          adminReply: complaint['admin_reply'],
          date: _parseDate(complaint['date']),
          isSecret: complaint['is_secret'] ?? false,
        );
      },
    );
  }

  /// Helper to parse date from complaint data
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
}
