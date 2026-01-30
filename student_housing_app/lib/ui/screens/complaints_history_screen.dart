import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../widgets/pull_to_refresh.dart'; // تأكد من أن هذا الويجت يدعم Scrollable بداخله
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
    // ✅ استخدام fetchComplaints بدلاً من getComplaints
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ComplaintsViewModel>().fetchComplaints();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // لون خلفية أهدأ
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
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Filter menu
          PopupMenuButton<String>(
            onSelected: (value) {
              context.read<ComplaintsViewModel>().filterComplaints(value);
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'all',
                child: Text('الكل', style: GoogleFonts.cairo()),
              ),
              PopupMenuItem(
                value: 'pending',
                child: Text('قيد الانتظار', style: GoogleFonts.cairo()),
              ),
              PopupMenuItem(
                value: 'resolved',
                child: Text('تم الرد', style: GoogleFonts.cairo()),
              ),
            ],
            icon: const Icon(Icons.filter_list, color: Colors.white),
          ),
        ],
      ),
      // ✅ استخدام Consumer للاستماع للتغييرات
      body: Consumer<ComplaintsViewModel>(
        builder: (context, viewModel, child) {
          return RefreshIndicator(
            onRefresh: () async {
              await viewModel.fetchComplaints();
            },
            child: _buildBody(viewModel),
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
          ).then((_) {
            // تحديث القائمة عند العودة من إضافة شكوى جديدة
            context.read<ComplaintsViewModel>().fetchComplaints();
          });
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

  Widget _buildBody(ComplaintsViewModel viewModel) {
    final complaints = viewModel.complaints;

    // 1. Loading State
    if (viewModel.isLoading && complaints.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 2. Error State
    if (viewModel.errorMessage != null && complaints.isEmpty) {
      return ListView( // ListView لضمان عمل الـ RefreshIndicator
        padding: const EdgeInsets.all(20),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 10),
          Text(
            viewModel.errorMessage!,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(color: Colors.red, fontSize: 16),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () => viewModel.fetchComplaints(),
              child: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
            ),
          ),
        ],
      );
    }

    // 3. Empty State
    if (complaints.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inbox_outlined, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'لا توجد شكاوى حالياً',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'يمكنك إرسال شكوى جديدة من الزر بالأسفل',
                  style: GoogleFonts.cairo(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // 4. Success List
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: complaints.length,
      // ✅ إزالة shrinkWrap و physics للسماح بالتمرير الطبيعي
      itemBuilder: (context, index) {
        final complaint = complaints[index];
        return ComplaintItemCard(
          id: complaint['id']?.toString() ?? '0',
          title: complaint['title'] ?? 'بدون عنوان',
          description: complaint['description'] ?? '',
          status: complaint['status'] ?? 'pending',
          adminReply: complaint['admin_reply'] ?? complaint['reply_text'], // ✅ دعم المسميين
          date: _parseDate(complaint['created_at'] ?? complaint['date']), // ✅ استخدام created_at
          isSecret: complaint['is_secret'] == true || complaint['is_secret'] == 1,
        );
      },
    );
  }

  /// دالة مساعدة لتحليل التاريخ بأمان
  DateTime _parseDate(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();
    if (dateValue is DateTime) return dateValue;
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