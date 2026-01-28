import 'package:flutter/material.dart';
import '../repositories/data_repository.dart';

class AnnouncementsViewModel extends ChangeNotifier {
  // ============================================================================
  // STATE VARIABLES (Initialize as empty lists, never null)
  // ============================================================================

  List<Map<String, dynamic>> _announcements = [];
  bool _isLoading = false;
  String? _errorMessage;

  // ============================================================================
  // GETTERS (Immutable access to state)
  // ============================================================================

  List<Map<String, dynamic>> get announcements => _announcements;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ============================================================================
  // DEPENDENCIES
  // ============================================================================

  final DataRepository _repository = DataRepository();

  // ============================================================================
  // PUBLIC METHODS
  // ============================================================================

  /// Load announcements using REACTIVE CACHE-FIRST pattern:
  /// 1. Set isLoading = true
  /// 2. Fetch from cache (local DB) - if exists, update UI immediately
  /// 3. Fetch from API in background - if new data, update UI again
  /// 4. Set isLoading = false in finally block
  ///
  /// Error Strategy:
  /// - If API fails but cache exists: Show cache data, do NOT clear list
  /// - Only show error message if list is empty
  Future<void> loadAnnouncements() async {
    // Step 1: Set loading and clear error
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Step 2: Fetch from Repository (cache-first strategy)
      final result = await _repository.getAnnouncements();

      if (result['success'] == true) {
        // Parse and normalize the data
        final data = result['data'];
        if (data is List) {
          final normalizedData = List<Map<String, dynamic>>.from(
            data.map((item) => _normalizeAnnouncementData(item)),
          );

          // Update state with new data
          _announcements = normalizedData;
          _errorMessage = null;

          print(
            '✅ Announcements loaded (${_announcements.length} items, from ${result['fromCache'] == true ? 'CACHE' : 'API'})',
          );
        } else {
          // Invalid data format - only clear if currently empty
          if (_announcements.isEmpty) {
            _announcements = [];
            _errorMessage = 'Invalid data format';
          }
        }
      } else {
        // API error - only show error if no cache exists
        final errorMsg = result['message'] ?? 'Failed to load announcements';
        if (_announcements.isEmpty) {
          _errorMessage = errorMsg;
        } else {
          print('⚠️ API Error (showing cached data): $errorMsg');
        }
        print('❌ Error: ${result['message']}');
      }
    } catch (e) {
      // Exception - only clear if no cache exists
      if (_announcements.isEmpty) {
        _errorMessage = 'Error: $e';
      } else {
        print('⚠️ Exception (showing cached data): $e');
      }
      print('❌ Exception: $e');
    } finally {
      // Step 4: Always clear loading state
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refresh announcements (called by pull-to-refresh)
  // Future<void> refreshAnnouncements() => loadAnnouncements();

  // ============================================================================
  // PRIVATE METHODS
  // ============================================================================

  /// Normalize announcement data from API/cache
  Map<String, dynamic> _normalizeAnnouncementData(dynamic item) {
    if (item is Map) {
      return {
        'id': item['id'] ?? '',
        'title': item['title'] ?? '',
        'body': item['body'] ?? item['description'] ?? '',
        'category': item['category'] ?? 'general',
        'created_at': item['created_at'] ?? '',
        'bg_color': item['bg_color'] ?? '',
        'dot_color': item['dot_color'] ?? '',
      };
    }
    return {};
  }

  /// Get announcement by ID
  Map<String, dynamic>? getAnnouncementById(String id) {
    try {
      return _announcements.firstWhere((ann) => ann['id'] == id);
    } catch (e) {
      return null;
    }
  }

  /// Get announcements by category
  List<Map<String, dynamic>> getAnnouncementsByCategory(String category) {
    return _announcements.where((ann) => ann['category'] == category).toList();
  }

  /// Get latest announcements (sorted by date, most recent first)
  List<Map<String, dynamic>> getLatestAnnouncements({int limit = 5}) {
    final sorted = List<Map<String, dynamic>>.from(_announcements);
    sorted.sort(
      (a, b) => (b['created_at'] ?? '').compareTo(a['created_at'] ?? ''),
    );
    return sorted.take(limit).toList();
  }

  /// Refresh announcements (force API call)
  Future<void> refreshAnnouncements() async {
    await loadAnnouncements();
  }
}
