import 'package:flutter/material.dart';
import '../repositories/data_repository.dart';

class ActivitiesViewModel extends ChangeNotifier {
  // ============================================================================
  // STATE VARIABLES
  // ============================================================================

  List<Map<String, dynamic>> _activities = [];
  bool _isLoading = false;
  String? _errorMessage;

  // ============================================================================
  // GETTERS
  // ============================================================================

  List<Map<String, dynamic>> get activities => _activities;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ============================================================================
  // DEPENDENCIES
  // ============================================================================

  final DataRepository _repository = DataRepository();

  // ============================================================================
  // PUBLIC METHODS
  // ============================================================================

  /// Load activities using REACTIVE CACHE-THEN-NETWORK pattern:
  /// 1. Show Cache immediately.
  /// 2. Force fetch from API to update status (Subscribe/Unsubscribe).
  Future<void> loadActivities() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // ---------------------------------------------------------
    // STEP 1: LOAD FROM CACHE (FAST)
    // ---------------------------------------------------------
    try {
      final cacheResult = await _repository.getActivities(forceRefresh: false);
      if (cacheResult['success'] == true) {
        _updateStateWithData(cacheResult['data']);
        print('✅ UI Updated from CACHE');
      }
    } catch (e) {
      print('⚠️ Cache load warning: $e');
    }

    // ---------------------------------------------------------
    // STEP 2: FORCE FETCH FROM API (ACCURATE)
    // ---------------------------------------------------------
    try {
      // This will force the repository to hit the server and get fresh 'is_subscribed' status
      final apiResult = await _repository.getActivities(forceRefresh: true);

      if (apiResult['success'] == true) {
        _updateStateWithData(apiResult['data']);
        _errorMessage = null;
        print('✅ UI Updated from API (Fresh Data)');
      } else {
        // If API fails and we have no cache, show error
        if (_activities.isEmpty) {
          _errorMessage = apiResult['message'] ?? 'فشل تحميل البيانات';
        }
      }
    } catch (e) {
      if (_activities.isEmpty) {
        _errorMessage = 'Error: $e';
      }
      print('❌ API Exception: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper to process and update state
  void _updateStateWithData(dynamic data) {
    if (data is List) {
      final normalizedData = List<Map<String, dynamic>>.from(
        data.map((item) => _normalizeActivityData(item)),
      );
      _activities = normalizedData;
      notifyListeners();
    }
  }

  // ============================================================================
  // PRIVATE METHODS
  // ============================================================================

  /// Normalize activity data from API/cache
  /// ✅ FIXED: Added is_subscribed and participant_count mapping
  Map<String, dynamic> _normalizeActivityData(dynamic item) {
    if (item is Map) {
      return {
        'id': item['id'] ?? 0, // Ensure ID is int if possible, or handle appropriately
        'title': item['title'] ?? '',
        'category': item['category'] ?? '',
        'date': item['event_date'] ?? item['date'] ?? '',
        'time': item['time'] ?? '',
        'location': item['location'] ?? '',
        'imagePath': item['image_url'] ?? item['imagePath'] ?? '',
        'description': item['description'] ?? '',

        // ✅ CRITICAL FIX: Pass subscription status to UI
        'is_subscribed': (item['is_subscribed'] == true || item['is_subscribed'] == 1),
        'participant_count': item['participant_count'] ?? 0,
      };
    }
    return {};
  }

  /// Get activity by ID (for details screen)
  Map<String, dynamic>? getActivityById(int id) {
    try {
      return _activities.firstWhere((activity) => activity['id'] == id);
    } catch (e) {
      return null;
    }
  }

  /// Refresh activities (force API call)
  Future<void> refreshActivities() async {
    await loadActivities();
  }
}