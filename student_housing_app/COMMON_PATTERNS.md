# Common Patterns & Code Examples

## 📚 Patterns Used in This Implementation

### 1. Singleton Pattern (ViewModels via Provider)
```dart
// ✅ Provider automatically manages singleton
ChangeNotifierProvider(create: (_) => LoginViewModel())

// Usage anywhere in the app
Provider.of<LoginViewModel>(context)
// Same instance everywhere!
```

### 2. Observer Pattern (ChangeNotifier)
```dart
// ✅ ViewModel notifies all listeners when state changes
class LoginViewModel extends ChangeNotifier {
  void updateState() {
    _state = newValue;
    notifyListeners();  // Observers get notified
  }
}
```

### 3. Repository Pattern (DataRepository)
```dart
// ✅ Single source of truth for data
class DataRepository {
  // Fetch local first, sync from API
  Future<Map> getStudentProfile() async {
    final cached = await _localDB.getStudentProfile();
    if (cached != null) return cached;  // Return immediately
    
    return await _fetchAndCacheStudentProfile();  // Sync in background
  }
}
```

### 4. Dependency Injection
```dart
// ✅ Dependencies injected, not created
class LoginViewModel extends ChangeNotifier {
  final AuthService _authService;  // Injected
  
  LoginViewModel({AuthService? authService})
    : _authService = authService ?? AuthService();
}

// Usage with mocking
test('login test', () {
  final mockAuth = MockAuthService();
  final vm = LoginViewModel(authService: mockAuth);
});
```

---

## 🎯 Real-World Examples

### Example 1: Login with Email Verification

**ViewModel:**
```dart
class LoginViewModel extends ChangeNotifier {
  String? _userEmail;
  bool _emailVerified = false;
  
  Future<bool> login(String email, String password) async {
    // ... existing login logic
    
    if (result['success']) {
      _userEmail = email;
      _emailVerified = result['emailVerified'] ?? false;
      
      if (!_emailVerified) {
        _errorMessage = 'Please verify your email';
        notifyListeners();
        return false;
      }
      
      return true;
    }
    
    return false;
  }
  
  Future<void> resendVerification() async {
    // Send verification email
    notifyListeners();
  }
}
```

**Screen:**
```dart
if (viewModel.errorMessage?.contains('verify') ?? false)
  Column(
    children: [
      Text('Email not verified'),
      ElevatedButton(
        onPressed: viewModel.resendVerification,
        child: Text('Resend verification email'),
      ),
    ],
  ),
```

### Example 2: Form with Multiple Validators

**ViewModel:**
```dart
class SignupViewModel extends ChangeNotifier {
  String? _passwordError;
  String? _emailError;
  String? _idError;
  
  bool validatePassword(String password) {
    if (password.length < 8) {
      _passwordError = 'Min 8 characters';
      notifyListeners();
      return false;
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      _passwordError = 'Must contain uppercase';
      notifyListeners();
      return false;
    }
    _passwordError = null;
    notifyListeners();
    return true;
  }
  
  bool validateEmail(String email) {
    if (!email.contains('@')) {
      _emailError = 'Invalid email';
      notifyListeners();
      return false;
    }
    _emailError = null;
    notifyListeners();
    return true;
  }
}
```

**Screen:**
```dart
GlassTextField(
  controller: _passwordController,
  label: "Password",
  icon: Icons.lock,
  onChanged: viewModel.validatePassword,
  validator: (_) => viewModel.passwordError,
),
if (viewModel.passwordError != null)
  Text(
    viewModel.passwordError!,
    style: TextStyle(color: Colors.red),
  ),
```

### Example 3: Infinite Scroll List with ViewModel

**ViewModel:**
```dart
class ComplaintsViewModel extends ChangeNotifier {
  List<Complaint> _complaints = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  
  Future<void> loadMore() async {
    if (_isLoading || !_hasMore) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final newComplaints = await _apiService.getComplaints(page: _page);
      
      if (newComplaints.isEmpty) {
        _hasMore = false;
      } else {
        _complaints.addAll(newComplaints);
        _page++;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Initial load
  Future<void> refresh() async {
    _page = 1;
    _complaints.clear();
    await loadMore();
  }
}
```

**Screen:**
```dart
ListView.builder(
  itemCount: viewModel.complaints.length + 1,
  itemBuilder: (context, index) {
    if (index == viewModel.complaints.length) {
      return viewModel.isLoading
          ? Center(child: CircularProgressIndicator())
          : SizedBox.shrink();
    }
    
    // Trigger load more when near end
    if (index == viewModel.complaints.length - 5) {
      Future.microtask(() => viewModel.loadMore());
    }
    
    return ComplaintTile(viewModel.complaints[index]);
  },
)
```

### Example 4: Search/Filter with Debounce

**ViewModel:**
```dart
import 'dart:async';

class SearchViewModel extends ChangeNotifier {
  List<Result> _results = [];
  Timer? _debounce;
  
  Future<void> search(String query) async {
    // Cancel previous search
    _debounce?.cancel();
    
    // Debounce: wait 500ms after user stops typing
    _debounce = Timer(Duration(milliseconds: 500), () async {
      if (query.isEmpty) {
        _results = [];
        notifyListeners();
        return;
      }
      
      final results = await _apiService.search(query);
      _results = results;
      notifyListeners();
    });
  }
  
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
```

**Screen:**
```dart
GlassTextField(
  controller: _searchController,
  label: "Search",
  icon: Icons.search,
  onChanged: viewModel.search,
),
if (viewModel.results.isNotEmpty)
  ListView.builder(
    itemCount: viewModel.results.length,
    itemBuilder: (context, index) =>
        ResultTile(viewModel.results[index]),
  ),
```

### Example 5: Filter with Multiple Options

**ViewModel:**
```dart
class FilterViewModel extends ChangeNotifier {
  String? _statusFilter;
  String? _typeFilter;
  DateTimeRange? _dateRange;
  
  void setStatus(String? status) {
    _statusFilter = status;
    notifyListeners();
    _applyFilters();
  }
  
  void setType(String? type) {
    _typeFilter = type;
    notifyListeners();
    _applyFilters();
  }
  
  void setDateRange(DateTimeRange? range) {
    _dateRange = range;
    notifyListeners();
    _applyFilters();
  }
  
  Future<void> _applyFilters() async {
    final result = await _apiService.getFiltered(
      status: _statusFilter,
      type: _typeFilter,
      startDate: _dateRange?.start,
      endDate: _dateRange?.end,
    );
    notifyListeners();
  }
  
  void clearFilters() {
    _statusFilter = null;
    _typeFilter = null;
    _dateRange = null;
    notifyListeners();
    _applyFilters();
  }
}
```

**Screen:**
```dart
Column(
  children: [
    DropdownButton(
      value: viewModel.statusFilter,
      items: ['Pending', 'Resolved', 'Rejected']
          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
          .toList(),
      onChanged: viewModel.setStatus,
    ),
    ElevatedButton(
      onPressed: viewModel.clearFilters,
      child: Text('Clear Filters'),
    ),
  ],
)
```

---

## 🔧 Advanced ViewModel Patterns

### Pattern 1: Combining Multiple Services

```dart
class DashboardViewModel extends ChangeNotifier {
  final ApiService _apiService;
  final LocalDBService _dbService;
  final DataRepository _repository;
  
  // Combine data from multiple sources
  Future<void> loadDashboard() async {
    final profile = await _repository.getStudentProfile();
    final announcements = await _repository.announcements();
    final stats = await _apiService.getDashboardStats();
    
    _data = {
      'profile': profile,
      'announcements': announcements,
      'stats': stats,
    };
    notifyListeners();
  }
}
```

### Pattern 2: Error Recovery with Retry

```dart
class RetryableViewModel extends ChangeNotifier {
  int _retryCount = 0;
  static const MAX_RETRIES = 3;
  
  Future<bool> loginWithRetry(String id, String pwd) async {
    for (int i = 0; i < MAX_RETRIES; i++) {
      try {
        _retryCount = i + 1;
        notifyListeners();
        
        final result = await _authService.login(id, pwd);
        if (result['success']) {
          _retryCount = 0;
          return true;
        }
      } catch (e) {
        if (i == MAX_RETRIES - 1) {
          _errorMessage = 'Max retries reached';
        }
      }
    }
    return false;
  }
}
```

### Pattern 3: Batch Operations

```dart
class BatchViewModel extends ChangeNotifier {
  Future<void> submitMultipleForms(List<FormData> forms) async {
    _isLoading = true;
    notifyListeners();
    
    final futures = forms.map((form) => 
      _apiService.submitForm(form)
    );
    
    try {
      final results = await Future.wait(futures);
      _successCount = results.where((r) => r['success']).length;
    } catch (e) {
      _errorMessage = 'Batch operation failed';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

---

## 🧪 Testing Patterns

### Unit Test: ViewModel

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockAuthService extends Mock implements AuthService {}

void main() {
  group('LoginViewModel', () {
    late LoginViewModel viewModel;
    late MockAuthService mockAuth;
    
    setUp(() {
      mockAuth = MockAuthService();
      viewModel = LoginViewModel(authService: mockAuth);
    });
    
    test('login returns false with invalid ID', () async {
      final result = await viewModel.login('123', 'password');
      expect(result, false);
      expect(viewModel.errorMessage, isNotNull);
    });
    
    test('login calls AuthService', () async {
      when(mockAuth.login('30412010101234', '123456'))
          .thenAnswer((_) async => {'success': true});
      
      await viewModel.login('30412010101234', '123456');
      
      verify(mockAuth.login('30412010101234', '123456')).called(1);
    });
    
    test('togglePasswordVisibility works', () {
      expect(viewModel.isPasswordVisible, false);
      viewModel.togglePasswordVisibility();
      expect(viewModel.isPasswordVisible, true);
    });
  });
}
```

### Widget Test: LoginScreen

```dart
void main() {
  testWidgets('LoginScreen shows error on invalid login', 
    (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => LoginViewModel()),
          ],
          child: MaterialApp(home: LoginScreen()),
        ),
      );
      
      // Enter invalid ID
      await tester.enterText(find.byType(TextFormField).first, '123');
      
      // Tap login
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      // Check error message
      expect(find.byIcon(Icons.error_outline), findsWidgets);
    }
  );
}
```

---

## 📱 Real Widget Examples

### Custom Button with Loading State

```dart
class LoadingButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;
  
  const LoadingButton({
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }
}

// Usage:
LoadingButton(
  label: 'تسجيل الدخول',
  isLoading: viewModel.isLoading,
  onPressed: () => _handleLogin(viewModel),
)
```

### Error Display Widget

```dart
class ErrorBanner extends StatelessWidget {
  final String? error;
  final VoidCallback onDismiss;
  
  const ErrorBanner({
    required this.error,
    required this.onDismiss,
  });
  
  @override
  Widget build(BuildContext context) {
    if (error == null) return SizedBox.shrink();
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFFF6B6B).withOpacity(0.1),
        border: Border.all(color: Color(0xFFFF6B6B)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Color(0xFFFF6B6B)),
          SizedBox(width: 12),
          Expanded(child: Text(error!)),
          GestureDetector(
            onTap: onDismiss,
            child: Icon(Icons.close, color: Color(0xFFFF6B6B)),
          ),
        ],
      ),
    );
  }
}

// Usage:
ErrorBanner(
  error: viewModel.errorMessage,
  onDismiss: viewModel.clearError,
)
```

---

## 🚀 Performance Tips

### Avoid Unnecessary Rebuilds
```dart
// ❌ WRONG: Rebuilds entire screen
Consumer<LoginViewModel>(builder: (context, vm, _) {
  return Scaffold(body: /* whole screen */ );
})

// ✅ RIGHT: Rebuild only needed parts
ListenableBuilder(
  listenable: vm.isLoadingNotifier,
  builder: (context, _) {
    return CircularProgressIndicator();
  },
)
```

### Use Computed Properties
```dart
// ✅ Avoid recalculating in builder
class LoginViewModel extends ChangeNotifier {
  bool get canSubmit => !isLoading && id.isNotEmpty && pwd.isNotEmpty;
}

// Usage:
onPressed: viewModel.canSubmit ? () => login() : null,
```

### Lazy Loading
```dart
Future<void> loadScreenData() async {
  // Load critical data first
  await loadUserProfile();
  
  // Load secondary data in background
  loadAnnouncements();
  loadStatistics();
}
```

---

These patterns will help you build scalable, maintainable Flutter applications! 🚀
