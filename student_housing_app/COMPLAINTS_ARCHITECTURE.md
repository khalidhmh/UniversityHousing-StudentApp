# Complaints Feature - Architecture Diagram

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                          │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌──────────────────────────┐  ┌──────────────────────────┐       │
│  │  ComplaintsHistoryScreen │  │   ComplaintsScreen       │       │
│  │  (Stateful)              │  │   (Stateful)             │       │
│  │                          │  │                          │       │
│  │  • ListenableBuilder     │  │  • ListenableBuilder     │       │
│  │  • PullToRefresh widget  │  │  • Form fields           │       │
│  │  • Filter menu           │  │  • Submit button         │       │
│  │  • FAB to new complaint  │  │  • Success/Error dialogs │       │
│  └────────────┬─────────────┘  └──────────────┬───────────┘       │
│               │                               │                    │
│               └───────────────────┬───────────┘                    │
│                                   │                                 │
│  ┌────────────────────────────────▼─────────────────────┐         │
│  │         STATE MANAGEMENT LAYER (Provider)           │         │
│  ├────────────────────────────────────────────────────────┤       │
│  │                                                      │         │
│  │  ┌──────────────────────────────────────────────┐   │         │
│  │  │    ComplaintsViewModel (ChangeNotifier)      │   │         │
│  │  │                                              │   │         │
│  │  │  STATE:                                      │   │         │
│  │  │  • _complaints: List<Map>                   │   │         │
│  │  │  • _isLoading: bool                         │   │         │
│  │  │  • _isSubmitting: bool                      │   │         │
│  │  │  • _errorMessage: String?                  │   │         │
│  │  │  • _successMessage: String?                │   │         │
│  │  │  • _selectedFilter: String                 │   │         │
│  │  │                                              │   │         │
│  │  │  METHODS:                                    │   │         │
│  │  │  • getComplaints()                          │   │         │
│  │  │  • submitComplaint(...)                     │   │         │
│  │  │  • filterComplaints(String)                 │   │         │
│  │  │  • clearSuccessMessage()                    │   │         │
│  │  │  • clearErrorMessage()                      │   │         │
│  │  └────────────┬─────────────────────────────────┘   │         │
│  │               │                                      │         │
│  └───────────────┼──────────────────────────────────────┘         │
│                  │                                                 │
└──────────────────┼─────────────────────────────────────────────────┘
                   │
┌──────────────────▼──────────────────────────────────────────────────┐
│                     DATA LAYER (Repository)                        │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  ┌─────────────────────────────────────────────────────────────┐ │
│  │  DataRepository (Singleton)                               │ │
│  │                                                             │ │
│  │  • getComplaints()          → Cache-first strategy        │ │
│  │  • submitComplaint(...)     → API POST request            │ │
│  │  • _fetchAndCacheComplaints() → Background update         │ │
│  │                                                             │ │
│  └────────┬────────────────────────────────────┬──────────────┘ │
│           │                                    │                 │
│  ┌────────▼────────────────┐    ┌──────────────▼──────────────┐ │
│  │  LocalDBService         │    │  ApiService                │ │
│  │                         │    │                            │ │
│  │  • Caching              │    │  • GET  /student/complaints│ │
│  │  • Offline support      │    │  • POST /student/complaints│ │
│  │  • SQLite/Hive          │    │  • Error handling          │ │
│  └─────────────────────────┘    └────────────────────────────┘ │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
                                │
                                │
                        ┌───────▼────────┐
                        │   Backend API  │
                        │  (REST/HTTP)   │
                        └────────────────┘
```

---

## 🔄 Data Flow Diagrams

### Flow 1: Fetch Complaints (Get)

```
User opens ComplaintsHistoryScreen
            │
            ▼
Screen calls viewModel.getComplaints()
            │
            ▼
ViewModel calls repository.getComplaints()
            │
            ├─→ Checks LocalDBService (Cache)
            │   ├─ Cache exists? → Return immediately (fromCache: true)
            │   │                  + trigger background refresh
            │   │
            │   └─ No cache? → Continue to API
            │
            ├─→ Calls ApiService.get('/student/complaints')
            │   │
            │   ├─ Success? ──→ Cache the response
            │   │             Return (success: true, fromCache: false)
            │   │
            │   └─ Error? ──→ Return (success: false, error message)
            │
            ▼
ViewModel updates state:
  • _complaints = [...]
  • _isLoading = false
  • notifyListeners()
            │
            ▼
ListenableBuilder triggers rebuild
            │
            ▼
Screen shows complaint list or error/empty state
```

### Flow 2: Submit Complaint

```
User fills form + clicks submit
            │
            ▼
Calls _submitComplaint()
            │
            ├─→ Validate inputs ─→ Show error if invalid
            │
            ▼
Calls viewModel.submitComplaint(title, desc, recipient, isSecret)
            │
            ▼
ViewModel:
  • _isSubmitting = true
  • notifyListeners() ──→ Show spinner
            │
            ▼
Calls repository.submitComplaint(...)
            │
            ▼
Repository:
  • Calls ApiService.post('/student/complaints', payload)
  • Returns (success: true/false, message)
            │
            ▼
ViewModel receives response:
  • _isSubmitting = false
  • Set _successMessage OR _errorMessage
  • notifyListeners()
            │
            ▼
Listener callback triggered:
  • Show success dialog (if success)
  • Show error dialog (if error)
            │
            ▼
If success:
  • Reset form
  • Clear controllers
  • Reset secret mode
  • Auto-refresh complaints list
```

### Flow 3: Filter Complaints

```
User taps filter menu
            │
            ▼
Selects 'pending' / 'resolved' / 'all'
            │
            ▼
Calls viewModel.filterComplaints('pending')
            │
            ▼
ViewModel:
  • _selectedFilter = 'pending'
  • Applies filter to _complaints
  • _filteredComplaints = filtered list
  • notifyListeners()
            │
            ▼
ListenableBuilder rebuilds with filtered list
            │
            ▼
Screen shows only pending complaints
```

---

## 🎨 Widget Composition

```
ComplaintsHistoryScreen
├── AppBar
│   ├── Title: "سجل الشكاوى"
│   └── Filter Menu (PopupMenuButton)
├── ListenableBuilder (listens to ViewModel)
│   └── PullToRefresh
│       └── Center
│           └── ConstrainedBox (maxWidth: 600)
│               └── ListView (or LoadingWidget or ErrorWidget)
│                   └── ComplaintItemCard (for each complaint)
│                       ├── ExpansionTile
│                       │   ├── Leading: Status Icon
│                       │   ├── Title: Complaint Title
│                       │   ├── Subtitle: Date
│                       │   └── Trailing: Status Chip
│                       └── Children: [Details Container]
│                           ├── Original Complaint
│                           ├── Admin Reply / Pending Message
│                           └── Secret Indicator (if secret)
└── FloatingActionButton
    └── Label: "شكوى جديدة"
    └── Action: Navigate to ComplaintsScreen
```

```
ComplaintsScreen
├── AppBar
│   ├── Title: "الشكاوى والمقترحات"
│   └── History Button
├── ListenableBuilder (listens to ViewModel)
│   └── SingleChildScrollView
│       └── Column
│           ├── SecretModeSwitch (reusable widget)
│           │   ├── Tab Toggle
│           │   │   ├── "شكوى عادية"
│           │   │   └── "شكوى سرية"
│           │   └── Warning Banner (if secret)
│           ├── DropdownButtonFormField
│           │   └── Recipients list
│           ├── TextField
│           │   └── Subject
│           ├── TextField
│           │   └── Message (multiline)
│           ├── Attachment Buttons
│           │   ├── Upload Image
│           │   └── Upload File
│           └── ElevatedButton
│               └── Submit (shows spinner if loading)
└── Dialogs
    ├── Success Dialog (green, with checkmark)
    └── Error Dialog (red, with error icon)
```

---

## 🔌 Dependencies & Integration

```
main.dart
    │
    ├─→ MultiProvider
    │   ├─→ ChangeNotifierProvider(ComplaintsViewModel)
    │   └─→ ... other providers
    │
    ├─→ Provider Package
    │   ├─→ context.read<ComplaintsViewModel>()
    │   ├─→ ListenableBuilder(listenable: viewModel)
    │   └─→ viewModel.addListener()
    │
    ├─→ Google Fonts
    │   └─→ GoogleFonts.cairo()
    │
    └─→ Other Packages
        ├─→ animate_do (future use)
        ├─→ shared_preferences
        ├─→ http
        └─→ sqlite / hive
```

---

## 📊 State Management Flow

```
┌──────────────────────────────────┐
│  User Interaction                │
│  (Tap button, Fill form, etc)    │
└────────────┬─────────────────────┘
             │
             ▼
┌──────────────────────────────────┐
│  Screen Widget (_ComplaintsScreenState)
│  • Calls ViewModel method        │
│  • Updates local state (UI-only) │
│  └─ setState() for UI changes    │
└────────────┬─────────────────────┘
             │
             ▼
┌──────────────────────────────────┐
│  ViewModel (ChangeNotifier)      │
│  • Executes business logic       │
│  • Updates state (_complaints)   │
│  • Calls notifyListeners()       │
└────────────┬─────────────────────┘
             │
             ▼
┌──────────────────────────────────┐
│  Repository (DataRepository)     │
│  • Handles data operations       │
│  • Manages caching               │
│  • Communicates with API/DB      │
└────────────┬─────────────────────┘
             │
             ▼
┌──────────────────────────────────┐
│  Services (ApiService, etc)      │
│  • Network calls                 │
│  • Database operations           │
│  • Cache management              │
└────────────┬─────────────────────┘
             │
             ▼
┌──────────────────────────────────┐
│  Response back through layers    │
│  • ViewModel gets response       │
│  • Updates state                 │
│  • Calls notifyListeners()       │
└────────────┬─────────────────────┘
             │
             ▼
┌──────────────────────────────────┐
│  ListenableBuilder detects change
│  • Rebuilds child widgets        │
│  • Shows updated UI              │
└──────────────────────────────────┘
```

---

## 🗂️ File Organization

```
student_housing_app/
├── lib/
│   ├── main.dart                          [Updated: Add ViewModel to Provider]
│   │
│   ├── core/
│   │   ├── repositories/
│   │   │   └── data_repository.dart       [UPDATED: Add submitComplaint()]
│   │   │
│   │   ├── services/
│   │   │   ├── api_service.dart           [Already exists]
│   │   │   └── local_db_service.dart      [Already exists]
│   │   │
│   │   └── viewmodels/
│   │       ├── home_view_model.dart       [Already exists]
│   │       ├── login_view_model.dart      [Already exists]
│   │       └── complaints_view_model.dart [✅ NEW]
│   │
│   └── ui/
│       ├── screens/
│       │   ├── login_screen.dart          [Already exists]
│       │   ├── home_screen.dart           [Already exists]
│       │   ├── complaints_history_screen.dart  [✅ REFACTORED]
│       │   └── complaints_screen.dart     [✅ REFACTORED]
│       │
│       └── widgets/
│           ├── glass_text_field.dart      [Already exists]
│           ├── pull_to_refresh.dart       [Already exists]
│           ├── status_card.dart           [Already exists]
│           │
│           └── complaints/                [✅ NEW DIRECTORY]
│               ├── complaint_item_card.dart      [✅ NEW]
│               └── secret_mode_switch.dart      [✅ NEW]
│
└── Documentation/
    ├── COMPLAINTS_REFACTORING_GUIDE.md   [✅ NEW]
    ├── COMPLAINTS_CODE_STRUCTURE.md      [✅ NEW]
    └── COMPLAINTS_QUICK_START.md         [✅ NEW]
```

---

## ✅ Quality Checklist

```
Architecture:
  ✅ MVVM pattern implemented
  ✅ Repository pattern for data
  ✅ Provider for state management
  ✅ Clear separation of concerns

State Management:
  ✅ ChangeNotifier for reactive updates
  ✅ ListenableBuilder for efficient rebuilds
  ✅ Proper state initialization
  ✅ Error/Loading/Success states

User Experience:
  ✅ Loading spinners
  ✅ Error dialogs with retry
  ✅ Success confirmations
  ✅ Form validation
  ✅ Empty state handling
  ✅ Pull-to-refresh
  ✅ Filter capabilities

Code Quality:
  ✅ Reusable widgets
  ✅ Clean code structure
  ✅ Proper error handling
  ✅ Comments and documentation
  ✅ Type-safe (no dynamic types where not needed)
  ✅ No console warnings
```

---

Perfect! The entire Complaints feature is now refactored with clean MVVM architecture! 🎉
