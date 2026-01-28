import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/viewmodels/maintenance_view_model.dart';

/// MaintenanceFormBottomSheet: Reusable bottom sheet for submitting maintenance requests
/// 
/// Features:
/// - Category grid selection
/// - Description text field
/// - Photo upload placeholder
/// - Loading spinner on submit
/// - Success/Error dialogs
class MaintenanceFormBottomSheet extends StatefulWidget {
  const MaintenanceFormBottomSheet({super.key});

  @override
  State<MaintenanceFormBottomSheet> createState() => _MaintenanceFormBottomSheetState();
}

class _MaintenanceFormBottomSheetState extends State<MaintenanceFormBottomSheet> {
  String? _selectedCategory;
  final TextEditingController _descriptionController = TextEditingController();

  final List<String> _categories = [
    'سباكة',
    'كهرباء',
    'نجارة',
    'ألوميتال',
    'غاز',
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: context.read<MaintenanceViewModel>(),
      builder: (context, _) {
        final viewModel = context.read<MaintenanceViewModel>();
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF001F3F),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'الإبلاغ عن الأعطال',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'اختر نوع العطل لنقوم بإرسال الفني المختص',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Category Grid
                Text(
                  'نوع العطل',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF001F3F),
                  ),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: List.generate(_categories.length, (index) {
                    String category = _categories[index];
                    bool isSelected = _selectedCategory == category;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFFF9E6)
                              : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFF2C94C)
                                : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                isSelected ? 0.12 : 0.06,
                              ),
                              blurRadius: isSelected ? 8 : 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getCategoryIcon(category),
                              size: 32,
                              color: isSelected
                                  ? const Color(0xFFF2C94C)
                                  : const Color(0xFF001F3F),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF001F3F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),

                // Description Field
                Text(
                  'وصف العطل',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF001F3F),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    style: GoogleFonts.cairo(),
                    decoration: InputDecoration(
                      hintText: 'اكتب تفاصيل العطل هنا...',
                      hintStyle: GoogleFonts.cairo(
                        color: Colors.grey,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Photo Upload
                Text(
                  'الصورة (اختيارية)',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF001F3F),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'تحميل الصورة - قيد التطوير',
                          style: GoogleFonts.cairo(),
                        ),
                        backgroundColor: Colors.blue,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF001F3F),
                        width: 2,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: Color(0xFF001F3F),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'التقاط صورة أو رفع ملف',
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            color: const Color(0xFF001F3F),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button with Loading State
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: viewModel.isSubmitting ? null : _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF2C94C),
                      disabledBackgroundColor: Colors.grey[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: viewModel.isSubmitting
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.grey[600]!,
                              ),
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'إرسال البلاغ',
                            style: GoogleFonts.cairo(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF001F3F),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Submit maintenance request
  Future<void> _submitRequest() async {
    final viewModel = context.read<MaintenanceViewModel>();

    // Validate inputs
    if (_selectedCategory == null || _descriptionController.text.isEmpty) {
      _showErrorDialog('يرجى اختيار نوع العطل وكتابة الوصف');
      return;
    }

    // Submit request via ViewModel
    final success = await viewModel.submitRequest(
      category: _selectedCategory!,
      description: _descriptionController.text,
    );

    if (success && mounted) {
      // Show success dialog
      _showSuccessDialog('تم إرسال طلب الصيانة بنجاح');
      
      // Reset form
      _descriptionController.clear();
      setState(() {
        _selectedCategory = null;
      });

      // Close bottom sheet after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } else if (viewModel.errorMessage != null) {
      _showErrorDialog(viewModel.errorMessage!);
    }
  }

  /// Show success dialog
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFE8F5E9),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'نجح',
                style: GoogleFonts.cairo(
                  color: Colors.green[900],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.cairo(
            color: Colors.green[900],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'حسناً',
              style: GoogleFonts.cairo(
                color: Colors.green[900],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFEBEE),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'خطأ',
                style: GoogleFonts.cairo(
                  color: Colors.red[900],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: GoogleFonts.cairo(
            color: Colors.red[900],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'حسناً',
              style: GoogleFonts.cairo(
                color: Colors.red[900],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get icon for category
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'كهرباء':
        return Icons.electrical_services;
      case 'سباكة':
        return Icons.plumbing;
      case 'نجارة':
        return Icons.handyman;
      case 'ألوميتال':
        return Icons.window;
      case 'غاز':
        return Icons.gas_meter;
      default:
        return Icons.build;
    }
  }
}
