/// MVVM + REPOSITORY PATTERN IMPLEMENTATION GUIDE
/// 
/// This document covers the refactored Login feature following MVVM architecture
/// with Provider state management and the Repository Pattern.
///
/// ============================================================================
/// ARCHITECTURE OVERVIEW
/// ============================================================================
/// 
/// The application follows this layered architecture:
/// 
/// UI Layer (Screens & Widgets)
///   ↓
/// ViewModel Layer (Business Logic & State)
///   ↓
/// Repository Layer (Data Abstraction)
///   ↓
/// Service Layer (API & Local DB)
///
/// ============================================================================
/// FILE STRUCTURE
/// ============================================================================
///
/// lib/
/// ├── core/
/// │   ├── viewmodels/
/// │   │   ├── login_view_model.dart      [NEW] ✨
/// │   │   └── home_view_model.dart
/// │   ├── repositories/
/// │   │   └── data_repository.dart       [EXISTING]
/// │   └── services/
/// │       ├── auth_service.dart
/// │       ├── api_service.dart
/// │       └── local_db_service.dart
/// └── ui/
///     ├── screens/
///     │   ├── login_screen.dart          [REFACTORED] ✨
///     │   └── home_screen.dart
///     └── widgets/
///         ├── glass_text_field.dart      [NEW] ✨
///         ├── pull_to_refresh.dart
///         ├── status_card.dart
///         └── secure_qr_widget.dart
///
/// ============================================================================
/// COMPONENT DETAILS
/// ============================================================================
///
/// 1. LoginViewModel (lib/core/viewmodels/login_view_model.dart)
///    ────────────────────────────────────────────────────────────
///    ✓ Extends ChangeNotifier for reactive state
///    ✓ Manages: loading state, error messages, password visibility
///    ✓ Public methods:
///      - login(studentId, password): Future<bool>
///      - togglePasswordVisibility(): void
///      - clearError(): void
///    ✓ Handles all validation and error handling
///    ✓ Calls AuthService for authentication
///
/// 2. GlassTextField (lib/ui/widgets/glass_text_field.dart)
///    ────────────────────────────────────────────────────────────
///    ✓ Reusable StatelessWidget with glassmorphism design
///    ✓ Supports password fields with visibility toggle
///    ✓ Customizable icon, label, validation
///    ✓ RTL-friendly with Cairo font
///    ✓ Can be reused in any form across the app
///
/// 3. LoginScreen (lib/ui/screens/login_screen.dart)
///    ────────────────────────────────────────────────────────────
///    ✓ Pure presentation layer - no business logic
///    ✓ Uses ListenableBuilder to react to ViewModel changes
///    ✓ Handles navigation on success
///    ✓ Beautiful UI with animations (fade-in effect)
///    ✓ Error display in real-time
///
/// ============================================================================
/// USAGE EXAMPLE - MAIN.DART SETUP
/// ============================================================================
///
/// import 'package:provider/provider.dart';
/// import 'package:student_housing_app/core/viewmodels/login_view_model.dart';
///
/// void main() {
///   runApp(const MyApp());
/// }
///
/// class MyApp extends StatelessWidget {
///   const MyApp({super.key});
///
///   @override
///   Widget build(BuildContext context) {
///     return MultiProvider(
///       providers: [
///         // Provide LoginViewModel
///         ChangeNotifierProvider(
///           create: (_) => LoginViewModel(),
///         ),
///         // Add other providers here (HomeViewModel, etc.)
///       ],
///       child: MaterialApp(
///         title: 'Student Housing App',
///         theme: ThemeData(
///           useMaterial3: true,
///           colorScheme: ColorScheme.fromSeed(
///             seedColor: const Color(0xFFF2C94C),
///           ),
///         ),
///         home: const LoginScreen(),
///       ),
///     );
///   }
/// }
///
/// ============================================================================
/// STATE MANAGEMENT FLOW
/// ============================================================================
///
/// User Input Flow:
/// 1. User enters credentials → TextFormField validates
/// 2. User taps Login button → _handleLogin(viewModel)
/// 3. Screen calls viewModel.login(id, password)
/// 4. ViewModel validates inputs → notifyListeners() if invalid
/// 5. ViewModel calls AuthService.login()
/// 6. AuthService hits API and saves token
/// 7. ViewModel receives response → notifyListeners()
/// 8. ListenableBuilder rebuilds with updated state
/// 9. If success → Navigate to HomeScreen
/// 10. If error → Show error message in UI
///
/// State Updates:
/// ┌─────────────────────────────────────────────────────┐
/// │ User Action (Login Button Press)                     │
/// └─────────────────────────────────────────────────────┘
///                          ↓
/// ┌─────────────────────────────────────────────────────┐
/// │ ViewModel validates & sets _isLoading = true        │
/// │ notifyListeners()                                   │
/// └─────────────────────────────────────────────────────┘
///                          ↓
/// ┌─────────────────────────────────────────────────────┐
/// │ ListenableBuilder detects change & rebuilds         │
/// │ Button shows CircularProgressIndicator              │
/// └─────────────────────────────────────────────────────┘
///                          ↓
/// ┌─────────────────────────────────────────────────────┐
/// │ AuthService calls API (async)                        │
/// └─────────────────────────────────────────────────────┘
///                          ↓
/// ┌─────────────────────────────────────────────────────┐
/// │ ViewModel receives response & sets:                  │
/// │ - _isLoading = false                                │
/// │ - _errorMessage = null (or error text)              │
/// │ notifyListeners()                                   │
/// └─────────────────────────────────────────────────────┘
///                          ↓
/// ┌─────────────────────────────────────────────────────┐
/// │ ListenableBuilder rebuilds with new state           │
/// │ Button is now enabled or shows error                │
/// └─────────────────────────────────────────────────────┘
///
/// ============================================================================
/// USING GLASS_TEXT_FIELD WIDGET
/// ============================================================================
///
/// // Simple text field
/// GlassTextField(
///   controller: _usernameController,
///   label: "رقم الطالب / Student ID",
///   icon: Icons.person_outline,
///   validator: (value) {
///     if (value?.isEmpty ?? true) return 'Field required';
///     return null;
///   },
/// )
///
/// // Password field with visibility toggle
/// GlassTextField(
///   controller: _passwordController,
///   label: "كلمة المرور / Password",
///   icon: Icons.lock_outline,
///   isPassword: true,
///   isPasswordVisible: viewModel.isPasswordVisible,
///   onVisibilityToggle: viewModel.togglePasswordVisibility,
///   validator: (value) {
///     if ((value?.length ?? 0) < 6) return 'Min 6 characters';
///     return null;
///   },
/// )
///
/// // Email field
/// GlassTextField(
///   controller: _emailController,
///   label: "البريد الإلكتروني / Email",
///   icon: Icons.email_outlined,
///   keyboardType: TextInputType.emailAddress,
///   textCapitalization: TextCapitalization.none,
///   validator: (value) {
///     if (!(value?.contains('@') ?? false)) return 'Invalid email';
///     return null;
///   },
/// )
///
/// ============================================================================
/// VIEWMODEL BEST PRACTICES
/// ============================================================================
///
/// ✓ DO:
///   - Keep ViewModels focused on a single concern
///   - Use ChangeNotifier and notifyListeners() for state updates
///   - Validate inputs in ViewModel, not UI
///   - Handle errors gracefully with meaningful messages
///   - Use descriptive getter names (isLoading, errorMessage, etc.)
///   - Keep private variables (_isLoading) and expose via getters
///   - Call notifyListeners() after every state change
///   - Return meaningful values from ViewModel methods (bool, data, etc.)
///
/// ✗ DON'T:
///   - Mix UI logic with business logic
///   - Directly manipulate UI state from ViewModel
///   - Forget to call notifyListeners() after state changes
///   - Make ViewModel depend on BuildContext
///   - Use setState in ViewModel context
///   - Store complex objects without proper lifecycle management
///
/// ============================================================================
/// LISTERABLE_BUILDER vs CONSUMER
/// ============================================================================
///
/// ListenableBuilder (Used in LoginScreen):
/// - Manually specifies the Listenable
/// - More control over what triggers rebuilds
/// - Better for performance (rebuilds only specific widgets)
///
/// Usage:
/// ListenableBuilder(
///   listenable: viewModel,
///   builder: (context, _) {
///     return Text(viewModel.isLoading ? 'Loading...' : 'Ready');
///   },
/// )
///
/// Consumer (Alternative using Provider package):
/// - Automatically gets provider from context
/// - Cleaner syntax for simple cases
/// - Less control over rebuild scope
///
/// Usage:
/// Consumer<LoginViewModel>(
///   builder: (context, viewModel, _) {
///     return Text(viewModel.isLoading ? 'Loading...' : 'Ready');
///   },
/// )
///
/// ============================================================================
/// ERROR HANDLING FLOW
/// ============================================================================
///
/// User enters wrong password:
/// 1. API returns { success: false, message: 'كلمات مرور غير متطابقة' }
/// 2. ViewModel catches response and sets:
///    _errorMessage = 'كلمات مرور غير متطابقة'
///    _isLoading = false
/// 3. notifyListeners() triggers rebuild
/// 4. UI shows error container with close button
/// 5. User can tap 'X' to dismiss error via clearError()
///
/// Network error:
/// 1. AuthService catches exception and returns error response
/// 2. ViewModel receives error → sets _errorMessage
/// 3. UI displays error message
/// 4. User can retry login
///
/// Validation error:
/// 1. User taps Login with empty password
/// 2. Form validation fails (FormField validator)
/// 3. UI shows validation error below field
/// 4. ViewModel.login() is never called
/// 5. User cannot proceed until form is valid
///
/// ============================================================================
/// TESTING
/// ============================================================================
///
/// Test ViewModel:
/// ```
/// test('login returns false on validation error', () {
///   final viewModel = LoginViewModel();
///   final result = await viewModel.login('', 'password');
///   expect(result, false);
///   expect(viewModel.errorMessage, isNotNull);
/// });
/// ```
///
/// Test Widget:
/// ```
/// testWidgets('shows error message', (WidgetTester tester) async {
///   await tester.pumpWidget(
///     ChangeNotifierProvider<LoginViewModel>(
///       create: (_) => MockLoginViewModel(),
///       child: const MaterialApp(home: LoginScreen()),
///     ),
///   );
///   expect(find.text('خطأ'), findsOneWidget);
/// });
/// ```
///
/// ============================================================================
/// NEXT STEPS - REFACTORING OTHER SCREENS
/// ============================================================================
///
/// Follow the same pattern for other screens:
///
/// 1. HomeScreen:
///    - ✓ Already has HomeViewModel
///    - Use ListenableBuilder instead of setState
///    - Extract widgets (ActivityCard, AnnouncementTile, etc.)
///
/// 2. ComplaintsScreen:
///    - Create ComplaintsViewModel
///    - Use GlassTextField for complaint form
///    - Use DataRepository for fetching complaints
///
/// 3. ProfileScreen:
///    - Create ProfileViewModel
///    - Use DataRepository for profile data
///    - Add profile editing form with GlassTextField
///
/// 4. General Pattern:
///    - Data flows: Screen → ViewModel → Repository → Services
///    - State updates: Services → Repository → ViewModel → Screen
///    - UI is always a function of ViewModel state
///
/// ============================================================================
