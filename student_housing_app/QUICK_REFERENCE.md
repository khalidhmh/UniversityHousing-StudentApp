# Quick Reference - Login Refactoring

## 🎯 Three Files Created/Refactored

### 1️⃣ LoginViewModel
**Path:** `lib/core/viewmodels/login_view_model.dart`

```dart
// Public Interface
LoginViewModel viewModel;
viewModel.login(studentId, password)        // Returns: Future<bool>
viewModel.isLoading                         // Returns: bool
viewModel.errorMessage                      // Returns: String?
viewModel.isPasswordVisible                 // Returns: bool
viewModel.togglePasswordVisibility()        // void
viewModel.clearError()                      // void
```

### 2️⃣ GlassTextField Widget
**Path:** `lib/ui/widgets/glass_text_field.dart`

```dart
// Basic Usage
GlassTextField(
  controller: textController,
  label: "Label Text",
  icon: Icons.person,
)

// With Validation
GlassTextField(
  controller: textController,
  label: "Email",
  icon: Icons.email,
  keyboardType: TextInputType.emailAddress,
  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
)

// Password Field
GlassTextField(
  controller: passwordController,
  label: "Password",
  icon: Icons.lock,
  isPassword: true,
  isPasswordVisible: viewModel.isPasswordVisible,
  onVisibilityToggle: viewModel.togglePasswordVisibility,
)
```

### 3️⃣ Refactored LoginScreen
**Path:** `lib/ui/screens/login_screen.dart`

Key changes:
- ✅ Uses `ListenableBuilder` for reactive updates
- ✅ No direct `ApiService` calls
- ✅ No `setState` calls
- ✅ Uses `GlassTextField` widget
- ✅ Shows error in beautiful container
- ✅ Delegates all logic to `LoginViewModel`

---

## 🔌 How to Integrate

### Step 1: Update main.dart
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => LoginViewModel()),
  ],
  child: MaterialApp(
    home: const LoginScreen(),
  ),
)
```

### Step 2: Run your app
```bash
flutter pub get
flutter run
```

---

## 📊 State Management Overview

```
User Action
    ↓
Screen → ViewModel.login()
    ↓
ViewModel → Validates input
    ↓
ViewModel → Calls AuthService.login()
    ↓
AuthService → Makes API call
    ↓
Response → ViewModel updates state
    ↓
ViewModel.notifyListeners()
    ↓
ListenableBuilder detects change
    ↓
UI rebuilds with new state
    ↓
Success: Navigate | Error: Show message
```

---

## 🎨 Component Behaviors

### Loading State
- Button shows spinner
- Button is disabled
- Input fields remain enabled

### Error State
- Red error container appears below inputs
- Shows error message from ViewModel
- Close (X) button dismisses error
- User can retry

### Success State
- Navigation to HomeScreen
- Previous routes cleared

---

## 💡 Common Use Cases

### Adding Another TextField
```dart
GlassTextField(
  controller: _emailController,
  label: "البريد الإلكتروني / Email",
  icon: Icons.email_outlined,
  keyboardType: TextInputType.emailAddress,
  validator: (value) {
    if (!(value?.contains('@') ?? false)) {
      return 'Invalid email address';
    }
    return null;
  },
)
```

### Custom Validation in ViewModel
```dart
// Add to LoginViewModel
if (studentId.startsWith('3')) {
  // Special handling for specific IDs
}
```

### Handling Multiple Errors
```dart
// ViewModel already supports single error message
// For multiple errors, use a List<String> instead:
List<String> _errors = [];

// Then display in UI:
if (viewModel.errors.isNotEmpty)
  Column(children: viewModel.errors.map((e) => Text(e)).toList())
```

---

## 🧪 Testing Tips

### Test ViewModel
```dart
test('login fails with short ID', () async {
  final vm = LoginViewModel();
  final result = await vm.login('123', 'pass');
  expect(result, false);
  expect(vm.errorMessage, isNotNull);
});
```

### Test Widget
```dart
testWidgets('shows error message', (tester) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
      ],
      child: const MaterialApp(home: LoginScreen()),
    ),
  );
  // Interact and verify
});
```

---

## ⚠️ Common Mistakes to Avoid

❌ **DON'T:**
```dart
// ❌ Calling API directly from screen
final api = ApiService();
final result = await api.login(...);

// ❌ Using setState with ChangeNotifier
setState(() => isLoading = true);

// ❌ Forgetting notifyListeners()
_isLoading = true;  // UI won't update!

// ❌ Making ViewModel depend on BuildContext
final context = Provider.of<LoginViewModel>(context).context;
```

✅ **DO:**
```dart
// ✅ Call through ViewModel
final success = await viewModel.login(id, pass);

// ✅ ViewModel handles state
viewModel.togglePasswordVisibility();  // calls notifyListeners internally

// ✅ Always call notifyListeners() after state changes
_errorMessage = "Error";
notifyListeners();  // Required!

// ✅ Keep ViewModel independent
// Use ViewModel in any UI layer
```

---

## 📚 Architecture Layers

```
┌─────────────────────────────┐
│   Presentation (UI)         │
│   - LoginScreen (Stateful)  │
│   - GlassTextField (Widget) │
└──────────┬──────────────────┘
           │ Uses
┌──────────▼──────────────────┐
│   ViewModel (State Logic)    │
│   - LoginViewModel           │
│   - Extends ChangeNotifier   │
└──────────┬──────────────────┘
           │ Uses
┌──────────▼──────────────────┐
│   Services (Business Logic)  │
│   - AuthService             │
│   - ApiService              │
└────────────────────────────┘
```

---

## 🚀 Next Refactoring Target

Once comfortable with this pattern, apply to:
1. **HomeScreen** - Use DataRepository for profile/announcements
2. **ComplaintsScreen** - Create ComplaintsViewModel
3. **ProfileScreen** - Profile editing with GlassTextField
4. **SettingsScreen** - Common settings management

Same pattern = Consistency!

---

**Ready to use!** ✨
