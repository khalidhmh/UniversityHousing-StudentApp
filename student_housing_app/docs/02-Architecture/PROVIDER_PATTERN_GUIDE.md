# Provider Pattern Best Practices - Development Guide

**Purpose:** Guide for future Flutter developers on maintaining Provider pattern compliance

---

## TL;DR - The Quick Version

When building UI screens in this app, follow this simple formula:

```dart
// 1. Add lifecycle method
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<MyViewModel>().loadData();
  });
}

// 2. Wrap UI in Consumer or ListenableBuilder
@override
Widget build(BuildContext context) {
  return Consumer<MyViewModel>(  // or ListenableBuilder
    builder: (context, viewModel, _) {
      // 3. Handle all three states
      if (viewModel.isLoading) return LoadingWidget();
      if (viewModel.errorMessage != null) return ErrorWidget();
      if (viewModel.items.isEmpty) return EmptyWidget();
      
      // 4. Display data only
      return ListView.builder(
        itemCount: viewModel.items.length,
        itemBuilder: (context, index) => ItemWidget(viewModel.items[index]),
      );
    },
  );
}
```

---

## Complete Development Checklist

When creating a new screen, use this checklist:

### ViewModel Setup
- [ ] Create ViewModel class extending `ChangeNotifier`
- [ ] Add property: `bool isLoading = false`
- [ ] Add property: `String? errorMessage`
- [ ] Add property: `List<T> items = []`
- [ ] Create method: `Future<void> loadData()`
- [ ] In loadData():
  - [ ] Set `isLoading = true; notifyListeners();`
  - [ ] Try/catch API calls
  - [ ] On error: `errorMessage = message; notifyListeners();`
  - [ ] On success: `items = data; errorMessage = null; notifyListeners();`
  - [ ] Finally: `isLoading = false; notifyListeners();`

### Screen Setup
- [ ] Extend `StatefulWidget`
- [ ] In initState:
  ```dart
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<MyViewModel>().loadData();
  });
  ```
- [ ] Choose binding pattern:
  - Use `Consumer<MyViewModel>` if rebuilds needed frequently
  - Use `ListenableBuilder` if minimal rebuilds needed
- [ ] Implement three states:
  ```dart
  if (viewModel.isLoading && viewModel.items.isEmpty) {
    return CircularProgressIndicator();
  }
  
  if (viewModel.errorMessage != null && viewModel.items.isEmpty) {
    return ErrorWidget(
      message: viewModel.errorMessage!,
      onRetry: () => viewModel.loadData(),
    );
  }
  
  if (viewModel.items.isEmpty) {
    return EmptyStateWidget();
  }
  
  return DataWidget(viewModel.items);
  ```

### Button/Action Setup
- [ ] For state-reading buttons: `context.read<ViewModel>(listen: false).method()`
- [ ] For validation checks: Validate in ViewModel, not UI
- [ ] For async methods: Pass `context` if UI update needed after

---

## Pattern Comparison

### ❌ WRONG - Using setState

```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  late MyViewModel _viewModel;
  List<Item> _items = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _viewModel = MyViewModel();  // ❌ Manual instantiation
    _loadItems();
  }

  void _loadItems() async {
    setState(() => _isLoading = true);  // ❌ setState
    try {
      _items = await _viewModel.loadItems();
      setState(() => _isLoading = false);  // ❌ setState
    } catch (e) {
      setState(() {  // ❌ setState
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return CircularProgressIndicator();  // ❌ Only handles loading
    }
    return ListView.builder(
      itemCount: _items.length,  // ❌ Local state, not ViewModel
      itemBuilder: (context, index) => Text(_items[index].name),
    );
  }
}
```

### ✅ CORRECT - Using Provider Pattern

```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  @override
  void initState() {
    super.initState();
    // ✅ Safe ViewModel access
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MyViewModel>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Consumer for reactive updates
    return Consumer<MyViewModel>(
      builder: (context, viewModel, _) {
        // ✅ All three states
        if (viewModel.isLoading && viewModel.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.errorMessage != null && viewModel.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48),
                SizedBox(height: 16),
                Text(viewModel.errorMessage!),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => viewModel.loadData(),
                  child: Text('إعادة محاولة'),
                ),
              ],
            ),
          );
        }

        if (viewModel.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 48),
                SizedBox(height: 16),
                Text('لا توجد بيانات'),
              ],
            ),
          );
        }

        // ✅ Display data only
        return ListView.builder(
          itemCount: viewModel.items.length,
          itemBuilder: (context, index) => 
              ItemCard(viewModel.items[index]),
        );
      },
    );
  }
}
```

---

## Common Mistakes to Avoid

### ❌ Mistake 1: Creating ViewModel in initState
```dart
// WRONG
void initState() {
  super.initState();
  _viewModel = MyViewModel();  // Creates new instance!
}

// RIGHT
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    context.read<MyViewModel>().loadData();  // Uses Provider instance
  });
}
```

### ❌ Mistake 2: Using setState for ViewModel state
```dart
// WRONG
void _loadData() async {
  setState(() => _isLoading = true);  // Managing ViewModel state in Screen!
  final data = await _viewModel.loadData();
  setState(() => _isLoading = false);
}

// RIGHT - All state in ViewModel
await viewModel.loadData();  // ViewModel manages isLoading internally
```

### ❌ Mistake 3: Not handling error state
```dart
// WRONG - No error handling
if (viewModel.isLoading) {
  return CircularProgressIndicator();
}
return ListView.builder(...);

// RIGHT - All states handled
if (viewModel.isLoading && viewModel.items.isEmpty) {
  return CircularProgressIndicator();
}
if (viewModel.errorMessage != null && viewModel.items.isEmpty) {
  return ErrorWidget();
}
if (viewModel.items.isEmpty) {
  return EmptyWidget();
}
return ListView.builder(...);
```

### ❌ Mistake 4: Putting logic in UI
```dart
// WRONG - Filtering in Screen
Widget _buildList(List<Item> allItems) {
  final filtered = allItems.where((i) => i.status == 'active').toList();
  return ListView.builder(
    itemCount: filtered.length,
    itemBuilder: (context, index) => ItemCard(filtered[index]),
  );
}

// RIGHT - Filtering in ViewModel
// ViewModel has: List<Item> get activeItems => items.where(...).toList();
Widget _buildList(List<Item> items) {
  return ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) => ItemCard(items[index]),
  );
}
```

### ❌ Mistake 5: Using context after await
```dart
// WRONG - Context might be invalid after await
void _submitForm() async {
  final result = await viewModel.submit(data);  // await
  ScaffoldMessenger.of(context).showSnackBar(...);  // context invalid!
}

// RIGHT - Pass context as parameter
void _submitForm() async {
  await viewModel.submit(data);  // ViewModel handles result
  if (mounted) {  // Check if still mounted
    ScaffoldMessenger.of(context).showSnackBar(...);
  }
}

// OR - Use Consumer and context is always valid
ElevatedButton(
  onPressed: () => _submitForm(context),  // Pass context
  child: Text('Submit'),
)
```

---

## Complete Example: Building a New Screen

### Step 1: Create ViewModel

```dart
// lib/core/viewmodels/products_view_model.dart
import 'package:flutter/material.dart';
import '../repositories/product_repository.dart';

class ProductsViewModel extends ChangeNotifier {
  final ProductRepository _repository;

  // State properties
  bool _isLoading = false;
  String? _errorMessage;
  List<Product> _products = [];

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Product> get products => _products;

  ProductsViewModel(this._repository);

  // Load method
  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = await _repository.getProducts();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh method
  Future<void> refreshProducts() => loadProducts();
}
```

### Step 2: Create Screen

```dart
// lib/ui/screens/products_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/viewmodels/products_view_model.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  void initState() {
    super.initState();
    // Safe ViewModel access
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductsViewModel>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Products')),
      body: Consumer<ProductsViewModel>(
        builder: (context, viewModel, child) {
          // Loading state
          if (viewModel.isLoading && viewModel.products.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (viewModel.errorMessage != null && viewModel.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48),
                  SizedBox(height: 16),
                  Text(viewModel.errorMessage!),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadProducts(),
                    child: Text('إعادة محاولة'),
                  ),
                ],
              ),
            );
          }

          // Empty state
          if (viewModel.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart, size: 48),
                  SizedBox(height: 16),
                  Text('لا توجد منتجات'),
                ],
              ),
            );
          }

          // Success state
          return RefreshIndicator(
            onRefresh: () => viewModel.refreshProducts(),
            child: ListView.builder(
              itemCount: viewModel.products.length,
              itemBuilder: (context, index) {
                final product = viewModel.products[index];
                return ProductCard(product: product);
              },
            ),
          );
        },
      ),
    );
  }
}
```

### Step 3: Register in Provider Setup

```dart
// In your main.dart or providers setup
MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (context) => ProductsViewModel(context.read<ProductRepository>()),
    ),
  ],
  child: MyApp(),
)
```

---

## Testing Checklist

Before committing, test these scenarios:

- [ ] **Loading State:** Does spinner show when loading?
- [ ] **Success State:** Does data display correctly after loading?
- [ ] **Error State:** Does error message show if API fails?
- [ ] **Empty State:** Does empty message show when no data?
- [ ] **Retry Action:** Does retry button work and reload data?
- [ ] **Refresh:** Does pull-to-refresh trigger reload?
- [ ] **Navigation:** Can you navigate away and back without crashes?
- [ ] **Validation:** Do forms validate before submission?
- [ ] **Offline:** Does app handle offline gracefully? (if applicable)
- [ ] **Performance:** Does app feel responsive? No lag?

---

## Quick Reference: When to Use What

### Consumer vs ListenableBuilder

**Use Consumer when:**
- Screen needs frequent rebuilds
- UI depends directly on ViewModel state
- Example: Form with reactive validation

**Use ListenableBuilder when:**
- Screen rarely needs rebuilds
- Only specific widgets listen to ViewModel
- Example: List with infrequent updates

---

## Resources

- Official Provider Documentation: https://pub.dev/packages/provider
- Flutter Best Practices: https://flutter.dev/docs/development/best-practices
- MVVM Architecture: See ARCHITECTURE_DIAGRAMS.md
- Existing Examples: All 7 audited screens in this codebase

---

**Remember:** Follow the patterns established in the audited screens. They've been verified as production-ready. 

**Good luck building! 🚀**
