import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../core/viewmodels/permissions_view_model.dart';

/// PermissionFormBottomSheet: Reusable form for submitting new permission requests
/// 
/// Features:
/// - Date picker for start and end dates
/// - Validation: EndDate must not be before StartDate
/// - Dropdown for permission type selection
/// - Reason textarea
/// - ListenableBuilder wrapper for reactive updates
/// - Loading spinner on submit
/// - Success/Error dialogs
class PermissionFormBottomSheet extends StatefulWidget {
  const PermissionFormBottomSheet({super.key});

  @override
  State<PermissionFormBottomSheet> createState() =>
      _PermissionFormBottomSheetState();
}

class _PermissionFormBottomSheetState extends State<PermissionFormBottomSheet> {
  String? _selectedType;
  DateTime? _fromDate;
  DateTime? _toDate;
  final TextEditingController _reasonController = TextEditingController();
  bool _isSubmitting = false;

  final List<String> _permissionTypes = [
    'تصريح مبيت',
    'دخول متأخر',
    'إجازة طارئة',
    'خروج مبكر',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  /// Select date and update state
  /// [isStart]: true for start date, false for end date
  Future<void> _selectDate(bool isStart) async {
    final initialDate = isStart
        ? (_fromDate ?? DateTime.now())
        : (_toDate ?? DateTime.now());

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          _fromDate = pickedDate;
          // Reset end date if it's before the new start date
          if (_toDate != null && _toDate!.isBefore(pickedDate)) {
            _toDate = null;
          }
        } else {
          _toDate = pickedDate;
        }
      });
    }
  }

  /// Submit permission request with validation
  Future<void> _submitRequest() async {
    // Validation
    if (_selectedType == null) {
      _showErrorDialog('يرجى اختيار نوع التصريح');
      return;
    }

    if (_fromDate == null) {
      _showErrorDialog('يرجى اختيار تاريخ البداية');
      return;
    }

    if (_toDate == null) {
      _showErrorDialog('يرجى اختيار تاريخ النهاية');
      return;
    }

    if (_toDate!.isBefore(_fromDate!)) {
      _showErrorDialog('تاريخ النهاية يجب أن يكون بعد تاريخ البداية');
      return;
    }

    if (_reasonController.text.trim().isEmpty) {
      _showErrorDialog('يرجى كتابة السبب');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final viewModel = context.read<PermissionsViewModel>();
      final success = await viewModel.requestPermission(
        type: _selectedType!,
        reason: _reasonController.text.trim(),
        startDate: _formatDateForAPI(_fromDate!),
        endDate: _formatDateForAPI(_toDate!),
      );

      if (success) {
        _showSuccessDialog();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) Navigator.pop(context);
        });
      } else {
        _showErrorDialog(
          viewModel.errorMessage ?? 'فشل إرسال الطلب',
        );
      }
    } catch (e) {
      _showErrorDialog('حدث خطأ غير متوقع: $e');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  /// Show success dialog with checkmark
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.green[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: Colors.green[700],
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'تم إرسال الطلب بنجاح',
              style: GoogleFonts.cairo(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'حسناً',
              style: GoogleFonts.cairo(
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Show error dialog with error message
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                color: Colors.red[700],
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.cairo(
                fontSize: 16,
                color: Colors.red[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'حسناً',
              style: GoogleFonts.cairo(
                color: Colors.red[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Format date for API in format YYYY-MM-DD
  String _formatDateForAPI(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Format date for display
  String _formatDateForDisplay(DateTime? date) {
    if (date == null) return 'اختر التاريخ';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: context.read<PermissionsViewModel>(),
      builder: (context, _) {
        final viewModel = context.read<PermissionsViewModel>();

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
                        'طلب تصريح جديد',
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'قم بملء النموذج لإرسال طلب تصريح',
                        style: GoogleFonts.cairo(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Permission Type Dropdown
                Text(
                  'نوع التصريح',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF001F3F),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 1,
                    ),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedType,
                    hint: Text(
                      'اختر نوع التصريح',
                      style: GoogleFonts.cairo(color: Colors.grey),
                    ),
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: _permissionTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(
                          type,
                          style: GoogleFonts.cairo(),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedType = value);
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Start Date Picker
                Text(
                  'من تاريخ',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF001F3F),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _selectDate(true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.grey),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _formatDateForDisplay(_fromDate),
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: _fromDate == null
                                  ? Colors.grey
                                  : const Color(0xFF001F3F),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // End Date Picker
                Text(
                  'إلى تاريخ',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF001F3F),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _selectDate(false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.grey[300]!,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: Colors.grey),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _formatDateForDisplay(_toDate),
                            style: GoogleFonts.cairo(
                              fontSize: 14,
                              color: _toDate == null
                                  ? Colors.grey
                                  : const Color(0xFF001F3F),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Reason TextField
                Text(
                  'السبب',
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
                    controller: _reasonController,
                    maxLines: 3,
                    style: GoogleFonts.cairo(),
                    decoration: InputDecoration(
                      hintText: 'اكتب سبب الطلب',
                      hintStyle: GoogleFonts.cairo(color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting || viewModel.isSubmitting
                        ? null
                        : _submitRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF2C94C),
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isSubmitting || viewModel.isSubmitting
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.grey[600]!,
                              ),
                            ),
                          )
                        : Text(
                            'إرسال الطلب',
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
}
