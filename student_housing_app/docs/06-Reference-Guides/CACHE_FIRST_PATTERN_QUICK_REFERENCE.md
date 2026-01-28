# ViewModel Cache-First Pattern - Quick Reference

## The Complete Pattern

```dart
/// Load data with cache-first strategy
/// 
/// Strategy:
/// 1. Show loading indicator
/// 2. Load from repository (cache-first)
/// 3. Update UI with cached data instantly
/// 4. API fetches in background, updates if new data
/// 5. Hide loading indicator in finally block
Future<void> loadData() async {
  // STEP 1: Prepare state
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();  // 🔔 Notify UI: showing loading

  try {
    // STEP 2: Fetch from repository (goes through cache-first logic)
    final result = await _repository.getData();
    
    if (result['success'] == true) {
      // STEP 3: Update state with fetched data
      _data = List<Map<String, dynamic>>.from(result['data'] ?? []);
      _errorMessage = null;
      
      print('✅ Data loaded from ${result['fromCache'] == true ? 'CACHE' : 'API'}');
    } else {
      // STEP 4: Handle error - but preserve cache!
      final errorMsg = result['message'] ?? 'Failed to load';
      
      if (_data.isEmpty) {
        // No cache exists - show error to user
        _errorMessage = errorMsg;
      } else {
        // Cache exists - silently use it
        print('⚠️ API Error, showing cached data');
      }
    }
  } catch (e) {
    // STEP 5: Handle exceptions - but preserve cache!
    if (_data.isEmpty) {
      // No cache exists - show error to user
      _errorMessage = 'Error: $e';
    } else {
      // Cache exists - silently use it
      print('⚠️ Exception, showing cached data');
    }
  } finally {
    // STEP 6: Always clear loading state (most important!)
    _isLoading = false;
    notifyListeners();  // 🔔 Final notification to UI
  }
}
```

## State Variables (Required in ALL ViewModels)

```dart
// Private state - only modifiable through methods
List<Map<String, dynamic>> _data = [];        // ✅ Never null, always []
bool _isLoading = false;                      // ✅ Track loading state
String? _errorMessage;                        // ✅ User-visible errors
String? _successMessage;                      // ✅ Success feedback after submit
bool _isSubmitting = false;                   // ✅ For form submissions

// Public getters - immutable access
List<Map<String, dynamic>> get data => _data;
bool get isLoading => _isLoading;
String? get errorMessage => _errorMessage;
String? get successMessage => _successMessage;
bool get isSubmitting => _isSubmitting;
```

## Helper Methods (Reusable across ViewModels)

```dart
/// Set loading state and notify listeners
void _setLoading(bool value) {
  _isLoading = value;
  notifyListeners();
}

/// Set submitting state and notify listeners
void _setSubmitting(bool value) {
  _isSubmitting = value;
  notifyListeners();
}

/// Clear error and success messages
void _clearMessages() {
  _errorMessage = null;
  _successMessage = null;
  notifyListeners();
}
```

## Submit/Request Pattern

```dart
/// Submit data with validation, error handling, and refresh
Future<bool> submitRequest({
  required String field1,
  required String field2,
}) async {
  // Step 1: Validate input
  if (field1.isEmpty || field2.isEmpty) {
    _errorMessage = 'يرجى ملء جميع الحقول المطلوبة';  // Arabic: "Please fill all fields"
    notifyListeners();
    return false;
  }
  
  // Step 2: Set submitting state
  _isSubmitting = true;
  _errorMessage = null;
  _successMessage = null;
  notifyListeners();
  
  try {
    // Step 3: Call repository
    final result = await _repository.submitData(
      field1: field1,
      field2: field2,
    );
    
    // Step 4: Handle response
    if (result['success'] == true) {
      _successMessage = 'تم الإرسال بنجاح';  // Arabic: "Sent successfully"
      
      // Step 5: Refresh list to show new entry
      await loadData();
      
      // Step 6: Return success
      return true;
    } else {
      _errorMessage = result['message'] ?? 'فشل الإرسال';  // Arabic: "Send failed"
      notifyListeners();
      return false;
    }
  } catch (e) {
    _errorMessage = 'خطأ: $e';  // Arabic: "Error: $e"
    notifyListeners();
    return false;
  } finally {
    // Step 7: Clear submitting flag
    _isSubmitting = false;
    notifyListeners();
  }
}
```

## Error Handling Rules

### ✅ CORRECT: Preserve Cache

```dart
if (result['success'] == true) {
  _data = result['data'];
  _errorMessage = null;
} else {
  // Check if we have cached data
  if (_data.isEmpty) {
    // No cache - show error
    _errorMessage = result['message'];
  } else {
    // Have cache - silently use it
    print('⚠️ API error, showing cached data');
  }
}
```

### ❌ WRONG: Destroy Cache

```dart
// NEVER DO THIS!
if (result['success'] != true) {
  _data = [];  // ❌ Loses all cached data!
  _errorMessage = result['message'];
}

// NEVER DO THIS!
try {
  _data = await _apiService.get();  // ❌ Direct service call!
} catch(e) {
  _data = [];  // ❌ Loses cache!
}
```

## In Screens - How to Use

### Display Loading State

```dart
Consumer<MyViewModel>(
  builder: (context, viewModel, child) {
    if (viewModel.isLoading && viewModel.data.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }
    
    return ListView(
      children: viewModel.data.map((item) => ListTile(
        title: Text(item['title']),
      )).toList(),
    );
  }
)
```

### Display Error Only When No Data

```dart
Consumer<MyViewModel>(
  builder: (context, viewModel, child) {
    // Show error only if list is empty AND error exists
    if (viewModel.data.isEmpty && viewModel.errorMessage != null) {
      return Center(child: Text(viewModel.errorMessage!));
    }
    
    // Show data (even if loading - cached data)
    return ListView(
      children: viewModel.data.map(...).toList(),
    );
  }
)
```

### Handle Submit with Success/Error

```dart
ElevatedButton(
  onPressed: () async {
    bool success = await viewModel.submitRequest(
      field1: titleController.text,
      field2: descController.text,
    );
    
    if (success) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.successMessage ?? 'تم')),
      );
      
      // Navigate back or refresh
      Navigator.pop(context);
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.errorMessage ?? 'خطأ')),
      );
    }
  },
  child: Text('إرسال'),
)
```

## Special Case: Event_Date Mapping (ActivitiesViewModel)

The API returns `event_date` but UI expects `date`:

```dart
/// CRITICAL: Map 'event_date' from API to 'date' for UI
Map<String, dynamic> _normalizeActivityData(dynamic item) {
  if (item is Map) {
    return {
      'id': item['id'] ?? '',
      'title': item['title'] ?? '',
      'date': item['event_date'] ?? item['date'] ?? '',  // ✅ Map event_date to date
      'time': item['time'] ?? '',
      // ... other fields
    };
  }
  return {};
}
```

## Debugging Checklist

When a ViewModel isn't working:

- [ ] Are all state variables private (`_data`) with getters?
- [ ] Is `notifyListeners()` called after state changes?
- [ ] Are there 4 `notifyListeners()` calls? (begin, after fetch, in catch, in finally)
- [ ] Does error handling check `if (_data.isEmpty)`?
- [ ] Is the method using `_repository` or directly calling services?
- [ ] Are lists initialized as `[]` not `null`?
- [ ] Is the method async with try/catch/finally?
- [ ] Does success case set `_errorMessage = null`?
- [ ] Does submit pattern validate input first?
- [ ] Does submit pattern call `loadData()` to refresh?

## Testing Cache-First Behavior

1. **First Load:** Should show spinner then cached data
2. **API Fails:** Should show cached data without error
3. **No Cache:** Should show error message
4. **Go Offline:** Disable internet, should show cached data
5. **Submit Success:** Should refresh list
6. **Submit Error:** Should show error without losing data

---

**Ready to use!** Copy-paste these patterns into any ViewModel.
