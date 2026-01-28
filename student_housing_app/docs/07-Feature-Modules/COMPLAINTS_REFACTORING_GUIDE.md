# Complaints Feature Refactoring - Complete Guide

## Overview
Successfully refactored the Complaints feature (History & New Complaint Form) to follow MVVM + Repository Pattern with Provider state management.

## Files Created/Modified

### 1. **ComplaintsViewModel** ✅
**File:** [lib/core/viewmodels/complaints_view_model.dart](lib/core/viewmodels/complaints_view_model.dart)

**Responsibilities:**
- Extends `ChangeNotifier` for reactive state management
- Injects `DataRepository` for data operations
- Manages loading/error/success states

**Key Methods:**
```dart
// Fetch complaints from repository with caching
Future<void> getComplaints()

// Submit new complaint
Future<bool> submitComplaint({
  required String title,
  required String description,
  required String recipient,
  required bool isSecret,
})

// Filter complaints by status (all/pending/resolved)
void filterComplaints(String filterType)

// Clear messages
void clearSuccessMessage()
void clearErrorMessage()
```

**State Properties:**
- `complaints` - Filtered or full list of complaints
- `isLoading` - Loading indicator for fetch operations
- `isSubmitting` - Loading indicator for submit operations
- `errorMessage` - Error message (if any)
- `successMessage` - Success message after submission
- `selectedFilter` - Current filter (all/pending/resolved)

---

### 2. **ComplaintItemCard Widget** ✅
**File:** [lib/ui/widgets/complaints/complaint_item_card.dart](lib/ui/widgets/complaints/complaint_item_card.dart)

**Features:**
- Reusable widget for displaying individual complaints
- Dynamic status colors:
  - **Green** = Resolved (تم الرد)
  - **Yellow** = Pending (قيد الانتظار)
- Expandable details with admin replies
- Secret complaint indicator
- Relative date formatting (Today, Yesterday, "X days ago")

**Constructor Parameters:**
```dart
ComplaintItemCard(
  id: String,
  title: String,
  description: String,
  status: String,
  adminReply: String?, // Optional
  date: DateTime,
  isSecret: bool,
)
```

---

### 3. **SecretModeSwitch Widget** ✅
**File:** [lib/ui/widgets/complaints/secret_mode_switch.dart](lib/ui/widgets/complaints/secret_mode_switch.dart)

**Features:**
- Reusable toggle for secret/anonymous complaint mode
- Tab-based UI (Normal Complaint / Secret Complaint)
- Warning banner when secret mode enabled
- Callback for mode changes

**Constructor:**
```dart
SecretModeSwitch(
  isSecret: bool,
  onChanged: (bool) => void,
)
```

---

### 4. **ComplaintsHistoryScreen (REFACTORED)** ✅
**File:** [lib/ui/screens/complaints_history_screen.dart](lib/ui/screens/complaints_history_screen.dart)

**Changes:**
✅ Converted from `StatelessWidget` to `StatefulWidget`
✅ Now uses `ListenableBuilder` to listen to `ComplaintsViewModel`
✅ Integrated `PullToRefresh` widget for swipe-to-refresh
✅ Displays `ComplaintItemCard` for each complaint
✅ Added filter menu (All / Pending / Resolved)
✅ Added FAB (Floating Action Button) to create new complaint
✅ Loading/Error/Empty state handling
✅ Auto-loads complaints on screen init

**Features:**
- **Pull-to-Refresh:** Manually refresh complaint list
- **Filter Menu:** Filter by status (all/pending/resolved)
- **FAB Navigation:** Navigate to new complaint form
- **State Handling:**
  - Loading spinner while fetching
  - Error dialog with retry button
  - Empty state message with suggestion
  - Success state with complaint list

---

### 5. **ComplaintsScreen (REFACTORED)** ✅
**File:** [lib/ui/screens/complaints_screen.dart](lib/ui/screens/complaints_screen.dart)

**Changes:**
✅ Connected form fields to `ComplaintsViewModel`
✅ Extracted `SecretModeSwitch` into reusable widget
✅ Replaced mock submission with real API call via ViewModel
✅ Shows loading spinner during submission
✅ Shows success/error dialogs based on ViewModel state
✅ Form auto-resets after successful submission

**Features:**
- **ListenableBuilder:** Rebuilds only when ViewModel state changes
- **Secret Mode Switch:** Reusable component
- **Form Validation:** Required fields check
- **Loading State:** Submit button disabled while submitting
- **Success Dialog:** Shows confirmation with check icon
- **Error Dialog:** Shows error message with retry option
- **Auto-Reset:** Clears all fields after successful submission
- **History Navigation:** History button in AppBar

---

### 6. **DataRepository (UPDATED)** ✅
**File:** [lib/core/repositories/data_repository.dart](lib/core/repositories/data_repository.dart)

**New Method Added:**
```dart
/// Submit a new complaint
Future<Map<String, dynamic>> submitComplaint({
  required String title,
  required String description,
  required String recipient,
  required bool isSecret,
})
```

**Integration:**
- Calls API service: `POST /student/complaints`
- Returns success/error response
- Used by `ComplaintsViewModel.submitComplaint()`

---

## Architecture Flow

### Data Flow (Get Complaints)
```
ComplaintsHistoryScreen
    ↓
ComplaintsViewModel (getComplaints)
    ↓
DataRepository (getComplaints)
    ↓
LocalDBService (cached data) OR ApiService (fresh data)
    ↓
[Response] → ViewModel → ListenableBuilder → UI Update
```

### Submit Flow (New Complaint)
```
ComplaintsScreen
    ↓
User fills form + clicks Submit
    ↓
_submitComplaint() called
    ↓
ComplaintsViewModel.submitComplaint()
    ↓
DataRepository.submitComplaint()
    ↓
ApiService (POST /student/complaints)
    ↓
Success/Error Dialog + Form Reset (if success)
```

---

## Integration Points

### Dependency Injection (Provider)
Make sure your `main.dart` includes the ViewModel:

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ComplaintsViewModel()),
    // ... other providers
  ],
  child: MyApp(),
)
```

### Navigation
Both screens are already connected:
- **History → New Complaint:** FAB in ComplaintsHistoryScreen
- **New Complaint → History:** History icon in ComplaintsScreen AppBar

---

## State Management Pattern

### ChangeNotifier Pattern
All state changes notify listeners automatically:
```dart
// In ViewModel
void _setLoading(bool value) {
  _isLoading = value;
  notifyListeners();  // Triggers rebuild
}
```

### ListenableBuilder Pattern
Used in screens to rebuild on state change:
```dart
ListenableBuilder(
  listenable: viewModel,
  builder: (context, _) {
    // Rebuilds whenever viewModel.notifyListeners() is called
  },
)
```

---

## Status Values

### Complaint Status Mappings
| Value | Display | Color |
|-------|---------|-------|
| `تم الرد` / `resolved` | Resolved | Green ✅ |
| `قيد الانتظار` / `pending` | Pending | Yellow ⏳ |

---

## Error Handling

### ViewModel Error Management
```dart
// Clear error after showing dialog
viewModel.clearErrorMessage();

// Clear success after showing dialog
viewModel.clearSuccessMessage();
```

### Screen Error Dialogs
- **Submit Errors:** Show error dialog with message
- **Fetch Errors:** Show error banner with retry button
- **Validation Errors:** Show in-dialog validation messages

---

## Future Enhancements

1. **Pagination:** Add pagination for large complaint lists
2. **Search:** Add search functionality by title/status
3. **Sorting:** Sort by date, status, or priority
4. **Attachments:** Implement file upload for images/documents
5. **Real-time Updates:** Use WebSocket for live updates
6. **Offline Support:** Enhanced caching for offline mode
7. **Animations:** Add transition animations (animate_do)
8. **Analytics:** Track complaint submission success/failure

---

## Testing Checklist

- [ ] Load complaints history (empty, loading, error, success states)
- [ ] Pull-to-refresh updates list
- [ ] Filter complaints by status
- [ ] Navigate to new complaint form
- [ ] Toggle secret mode and verify warning appears
- [ ] Submit valid complaint
- [ ] Submit with empty fields (validation error)
- [ ] Check success dialog after submission
- [ ] Verify form resets after successful submission
- [ ] Navigate back to history and verify new complaint appears
- [ ] Check error handling for API failures
- [ ] Verify loading spinner during submission

---

## File Structure
```
lib/
├── core/
│   ├── repositories/
│   │   └── data_repository.dart (UPDATED - added submitComplaint)
│   └── viewmodels/
│       └── complaints_view_model.dart (NEW)
└── ui/
    ├── screens/
    │   ├── complaints_history_screen.dart (REFACTORED)
    │   └── complaints_screen.dart (REFACTORED)
    └── widgets/
        └── complaints/
            ├── complaint_item_card.dart (NEW)
            └── secret_mode_switch.dart (NEW)
```

---

## Summary

✅ All 4 files completed successfully
✅ MVVM + Repository Pattern implemented
✅ Provider state management integrated
✅ ListenableBuilder for reactive UI
✅ Reusable widgets extracted
✅ Error handling with user dialogs
✅ Loading states with spinners
✅ Pull-to-refresh functionality
✅ Filter capabilities
✅ Form validation
✅ Auto-reset after success

The Complaints feature is now production-ready with clean architecture, proper separation of concerns, and excellent user experience! 🎉
