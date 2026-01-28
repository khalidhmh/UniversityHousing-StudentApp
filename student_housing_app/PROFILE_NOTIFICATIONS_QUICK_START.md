# 📋 Profile & Notifications Refactoring - Quick Reference

## ✅ What Was Done

### Files Created
1. ✅ `lib/core/viewmodels/profile_view_model.dart` - ProfileViewModel
2. ✅ `lib/core/viewmodels/notifications_view_model.dart` - NotificationsViewModel

### Files Modified
1. ✅ `lib/core/repositories/data_repository.dart` - Added getNotifications()
2. ✅ `lib/ui/screens/profile_screen.dart` - MVVM refactoring with ListenableBuilder
3. ✅ `lib/ui/screens/notifications_screen.dart` - MVVM + PullToRefresh
4. ✅ `lib/main.dart` - Added Provider setup

---

## 🔑 Key Code Snippets

### ProfileViewModel Usage
```dart
// In ProfileScreen
final viewModel = context.read<ProfileViewModel>();

// Access data
Text(viewModel.studentData?['fullName'] ?? 'N/A')

// Check states
if (viewModel.isLoading) { ... }
if (viewModel.errorMessage != null) { ... }
```

### NotificationsViewModel Usage
```dart
// In NotificationsScreen
final viewModel = context.read<NotificationsViewModel>();

// Access notifications list
ListView.builder(
  itemCount: viewModel.notifications.length,
  itemBuilder: (context, index) {
    final notification = viewModel.notifications[index];
    // Render notification
  },
)

// Check states
if (viewModel.isLoading) { ... }
if (viewModel.errorMessage != null) { ... }
```

### ListenableBuilder Pattern
```dart
ListenableBuilder(
  listenable: context.read<ProfileViewModel>(),
  builder: (context, _) {
    final viewModel = context.read<ProfileViewModel>();
    
    // UI rebuilds when viewModel.notifyListeners() is called
    return Column(
      children: [
        if (viewModel.isLoading)
          CircularProgressIndicator()
        else if (viewModel.errorMessage != null)
          ErrorWidget(message: viewModel.errorMessage!)
        else if (viewModel.studentData != null)
          SuccessWidget(data: viewModel.studentData!)
        else
          EmptyWidget(),
      ],
    );
  },
)
```

### Pull-to-Refresh Implementation
```dart
SmartRefresher(
  controller: _refreshController,
  onRefresh: () async {
    await viewModel.loadNotifications();
    _refreshController.refreshCompleted();
  },
  header: const WaterDropHeader(),
  child: NotificationsList(),
)
```

---

## 🎯 State Flow

### ProfileScreen State Flow
```
initState()
  ↓
context.read<ProfileViewModel>().loadProfile()
  ↓
ViewModel calls _repository.getStudentProfile()
  ↓
API returns data → ViewModel updates _studentData
  ↓
ViewModel.notifyListeners()
  ↓
ListenableBuilder rebuilds with new data
  ↓
UI displays profile information
```

### NotificationsScreen State Flow
```
initState()
  ↓
context.read<NotificationsViewModel>().loadNotifications()
  ↓
ViewModel calls _repository.getNotifications()
  ↓
API returns notifications → ViewModel updates _notifications list
  ↓
ViewModel.notifyListeners()
  ↓
ListenableBuilder rebuilds with new notifications
  ↓
UI displays notification list

User pulls to refresh:
  ↓
_onRefresh() called
  ↓
Same loading flow repeats
  ↓
_refreshController.refreshCompleted()
```

---

## 📱 UI States Handled

### ProfileScreen
- ✅ Loading: Spinner + "جاري التحميل..."
- ✅ Error: Icon + message + Retry button
- ✅ Empty: Inbox icon + "لا توجد بيانات متاحة"
- ✅ Success: Full profile with all fields

### NotificationsScreen
- ✅ Loading: Spinner + "جاري تحميل الإشعارات..."
- ✅ Error: Icon + message + Retry button
- ✅ Empty: Bell icon + "لا توجد إشعارات"
- ✅ Success: Notification list with dynamic types

---

## 🔌 Provider Setup

In `main.dart`:
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ProfileViewModel()),
    ChangeNotifierProvider(create: (_) => NotificationsViewModel()),
  ],
  child: MaterialApp(
    // ... config
  ),
)
```

Now ViewModels are available anywhere via:
```dart
context.read<ProfileViewModel>()
context.read<NotificationsViewModel>()
```

---

## 🧪 Testing

### Test ProfileScreen
```dart
testWidgets('ProfileScreen displays student data', (tester) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),
      ],
      child: MaterialApp(home: ProfileScreen()),
    ),
  );
  
  await tester.pumpAndSettle(); // Wait for API
  
  expect(find.text('أحمد حسن محمد'), findsWidgets);
});
```

### Test NotificationsScreen
```dart
testWidgets('NotificationsScreen displays notifications', (tester) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NotificationsViewModel()),
      ],
      child: MaterialApp(home: NotificationsScreen()),
    ),
  );
  
  await tester.pumpAndSettle();
  
  expect(find.byType(ListView), findsWidgets);
});
```

---

## 📊 Notification Types

| Type | Icon | Color | Use Case |
|------|------|-------|----------|
| supervisor | person | Grey | Supervisor messages |
| buildingManager | domain | Light Blue | Building manager notices |
| generalManager | shield | Dark Blue | General manager announcements |

---

## 🚀 Common Tasks

### Reload Profile
```dart
context.read<ProfileViewModel>().loadProfile()
```

### Reload Notifications
```dart
context.read<NotificationsViewModel>().loadNotifications()
```

### Check if Loading
```dart
bool isLoading = context.read<ProfileViewModel>().isLoading;
```

### Get Error Message
```dart
String? error = context.read<ProfileViewModel>().errorMessage;
```

### Access Data
```dart
Map? data = context.read<ProfileViewModel>().studentData;
List notifications = context.read<NotificationsViewModel>().notifications;
```

---

## 🎓 Architecture Pattern

```
┌─────────────────────────────────────────┐
│ UI Layer (Screens)                      │
│ - ProfileScreen                         │
│ - NotificationsScreen                   │
│ - Uses ListenableBuilder                │
└────────────────┬────────────────────────┘
                 │
    ┌────────────▼────────────┐
    │ ViewModel Layer         │
    │ - ProfileViewModel      │
    │ - NotificationsViewModel
    │ - Extends ChangeNotifier
    │ - Business Logic        │
    └────────────┬────────────┘
                 │
    ┌────────────▼────────────┐
    │ Repository Layer        │
    │ - DataRepository        │
    │ - Single Source of Truth
    │ - Cache Strategy        │
    └────────────┬────────────┘
                 │
    ┌────────────▼────────────┐
    │ Service Layer           │
    │ - ApiService            │
    │ - API Calls             │
    └─────────────────────────┘
```

---

## ✨ What Makes This Great

✅ **Reactive:** UI updates automatically when data changes
✅ **Testable:** Business logic separated from UI
✅ **Maintainable:** Clear separation of concerns
✅ **Reusable:** ViewModels can be used by multiple screens
✅ **Scalable:** Easy to add new features following same pattern
✅ **Error Handling:** Proper error states with user feedback
✅ **Loading States:** User always knows what's happening
✅ **Type Safe:** Strong typing throughout architecture

---

**Status:** ✅ READY FOR PRODUCTION
**Pattern:** MVVM + Repository
**Last Updated:** 2024
