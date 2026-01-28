# Complaints Refactoring - Code Structure Summary

## 1️⃣ ComplaintsViewModel.dart

**Location:** `lib/core/viewmodels/complaints_view_model.dart`

```dart
import 'package:flutter/material.dart';
import '../repositories/data_repository.dart';

class ComplaintsViewModel extends ChangeNotifier {
  final DataRepository _dataRepository = DataRepository();

  // STATE
  List<Map<String, dynamic>> _complaints = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;
  String _selectedFilter = 'all';

  // GETTERS
  List<Map<String, dynamic>> get complaints => /* filtered list */
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  
  // METHODS
  Future<void> getComplaints()                    // Fetch from repo
  Future<bool> submitComplaint(...)               // Submit new complaint
  void filterComplaints(String filterType)        // Filter: all/pending/resolved
  void clearSuccessMessage()                      // Clear success
  void clearErrorMessage()                        // Clear error
}
```

---

## 2️⃣ ComplaintItemCard.dart

**Location:** `lib/ui/widgets/complaints/complaint_item_card.dart`

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ComplaintItemCard extends StatelessWidget {
  // Constructor parameters
  final String id;
  final String title;
  final String description;
  final String status;              // "تم الرد" (green) / "قيد الانتظار" (yellow)
  final String? adminReply;
  final DateTime date;
  final bool isSecret;

  const ComplaintItemCard({...});

  @override
  Widget build(BuildContext context) {
    // Expandable tile with:
    // - Status icon & color (green/yellow)
    // - Title (or "شكوى سرية" if secret)
    // - Formatted date
    // - Status chip
    // - Expandable details:
    //   - Original complaint
    //   - Admin reply (if exists) or pending message
    //   - Secret indicator (if secret)
  }
}
```

---

## 3️⃣ SecretModeSwitch.dart

**Location:** `lib/ui/widgets/complaints/secret_mode_switch.dart`

```dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SecretModeSwitch extends StatelessWidget {
  final bool isSecret;
  final ValueChanged<bool> onChanged;

  const SecretModeSwitch({
    required this.isSecret,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Tab toggle: "شكوى عادية" (dark) / "شكوى سرية" (red)
    // Warning banner below if secret mode enabled:
    // "هذه الشكوى مشفرة ولن يظهر اسمك أو بياناتك للمستلم"
  }
}
```

---

## 4️⃣ ComplaintsHistoryScreen.dart (Refactored)

**Location:** `lib/ui/screens/complaints_history_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/pull_to_refresh.dart';
import '../../widgets/complaints/complaint_item_card.dart';
import '../../../core/viewmodels/complaints_view_model.dart';

class ComplaintsHistoryScreen extends StatefulWidget {
  @override
  State<ComplaintsHistoryScreen> createState() => _ComplaintsHistoryScreenState();
}

class _ComplaintsHistoryScreenState extends State<ComplaintsHistoryScreen> {
  @override
  void initState() {
    // Load complaints on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ComplaintsViewModel>().getComplaints();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'سجل الشكاوى',
        actions: [
          // Filter menu: All / Pending / Resolved
          PopupMenuButton<String>(
            onSelected: (value) {
              context.read<ComplaintsViewModel>().filterComplaints(value);
            },
            itemBuilder: (context) => [...],
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: context.read<ComplaintsViewModel>(),
        builder: (context, _) {
          final viewModel = context.read<ComplaintsViewModel>();
          
          return PullToRefresh(
            onRefresh: () async => viewModel.getComplaints(),
            child: _buildComplaintsList(viewModel, viewModel.complaints),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('شكوى جديدة'),
        onPressed: () => Navigator.push(context, ComplaintsScreen),
      ),
    );
  }

  Widget _buildComplaintsList(viewModel, complaints) {
    // Handle states:
    // - Loading: CircularProgressIndicator
    // - Error: Error icon + message + retry button
    // - Empty: Empty inbox icon
    // - Success: ListView of ComplaintItemCard
  }
}
```

---

## 5️⃣ ComplaintsScreen.dart (Refactored)

**Location:** `lib/ui/screens/complaints_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/viewmodels/complaints_view_model.dart';
import '../widgets/complaints/secret_mode_switch.dart';

class ComplaintsScreen extends StatefulWidget {
  @override
  State<ComplaintsScreen> createState() => _ComplaintsScreenState();
}

class _ComplaintsScreenState extends State<ComplaintsScreen> {
  late ComplaintsViewModel _viewModel;
  bool _isSecret = false;
  String? _selectedRecipient;
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  final List<String> recipients = [
    'مدير المبنى',
    'رعاية الشباب',
    'شؤون التغذية',
    'الأمن والسلامة',
    'الخدمات الإدارية',
  ];

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<ComplaintsViewModel>();
    _setupListeners();  // Listen for success/error messages
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 'الشكاوى والمقترحات',
        actions: [
          IconButton(
            icon: Icons.history,
            onPressed: () => Navigator.push(context, ComplaintsHistoryScreen),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) {
          return Column(
            children: [
              // Secret mode switch (reusable widget)
              SecretModeSwitch(
                isSecret: _isSecret,
                onChanged: (value) => setState(() => _isSecret = value),
              ),
              
              // Recipient dropdown
              DropdownButtonFormField<String>(
                value: _selectedRecipient,
                items: [...],
                onChanged: (value) => setState(() => _selectedRecipient = value),
              ),
              
              // Subject text field
              TextField(...),
              
              // Message text field (multiline)
              TextField(...),
              
              // Attachment buttons
              Row(...),
              
              // Submit button (shows spinner if submitting)
              ElevatedButton(
                onPressed: _viewModel.isSubmitting ? null : _submitComplaint,
                child: _viewModel.isSubmitting
                    ? CircularProgressIndicator()
                    : Text('إرسال الشكوى'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _submitComplaint() async {
    // Validate inputs
    if (_selectedRecipient == null || _subjectController.text.isEmpty) {
      _showErrorDialog('يرجى ملء جميع الحقول');
      return;
    }

    // Call ViewModel
    final success = await _viewModel.submitComplaint(
      title: _subjectController.text,
      description: _messageController.text,
      recipient: _selectedRecipient!,
      isSecret: _isSecret,
    );

    // Reset form if success
    if (success && mounted) {
      _subjectController.clear();
      _messageController.clear();
      setState(() {
        _selectedRecipient = null;
        _isSecret = false;
      });
    }
  }

  void _showSuccessDialog(String message) {
    // Show green dialog with check icon
  }

  void _showErrorDialog(String message) {
    // Show red dialog with error icon
  }
}
```

---

## 6️⃣ DataRepository.dart (New Method)

**Location:** `lib/core/repositories/data_repository.dart`

**NEW METHOD ADDED:**
```dart
/// Submit a new complaint via API
Future<Map<String, dynamic>> submitComplaint({
  required String title,
  required String description,
  required String recipient,
  required bool isSecret,
}) async {
  try {
    final response = await _apiService.post(
      '/student/complaints',
      {
        'title': title,
        'description': description,
        'recipient': recipient,
        'is_secret': isSecret,
        'status': 'pending',
      },
    );

    if (response['success'] == true) {
      return {
        'success': true,
        'message': 'تم إرسال الشكوى بنجاح',
        'data': response['data'],
      };
    } else {
      return {
        'success': false,
        'message': response['message'] ?? 'فشل إرسال الشكوى',
      };
    }
  } catch (e) {
    return {
      'success': false,
      'message': 'خطأ في الاتصال: $e',
    };
  }
}
```

---

## Data Structures

### Complaint Object (from API)
```dart
{
  'id': 1,                    // Unique identifier
  'title': 'مشكلة في السخان',
  'description': 'الماء بارد جداً...',
  'status': 'قيد الانتظار',    // or 'تم الرد'
  'type': 'maintenance',
  'admin_reply': 'سيتم معالجة المشكلة...',
  'is_secret': false,
  'date': '2026-01-26T10:30:00',
}
```

### Submit Complaint Payload
```dart
{
  'title': 'String',
  'description': 'String',
  'recipient': 'String',      // e.g., 'مدير المبنى'
  'is_secret': bool,
  'status': 'pending',        // Always pending for new
}
```

---

## Key Design Patterns Used

### 1. **ChangeNotifier Pattern**
- ViewModel extends ChangeNotifier
- Calls `notifyListeners()` after state changes
- Enables automatic UI rebuilds

### 2. **ListenableBuilder Pattern**
- Listens to ViewModel for state changes
- Rebuilds only when ViewModel notifies
- Efficient and reactive

### 3. **Provider Pattern**
- Dependency injection via Provider
- ViewModel injected in widget tree
- Access via `context.read<ComplaintsViewModel>()`

### 4. **Repository Pattern**
- Single source of truth: DataRepository
- Handles caching + API calls
- Provides clean interface to ViewModels

### 5. **Widget Composition**
- SecretModeSwitch: Reusable component
- ComplaintItemCard: Reusable component
- PullToRefresh: Reusable component
- Separates concerns and enables reusability

---

## Integration Checklist

✅ All 4 files created/refactored
✅ ViewModel properly manages state
✅ Screens use ListenableBuilder
✅ Widgets are reusable and composable
✅ Error handling with dialogs
✅ Loading states with spinners
✅ Form validation
✅ Navigation between screens
✅ Pull-to-refresh functionality
✅ Filter capabilities

**Ready for production! 🚀**
