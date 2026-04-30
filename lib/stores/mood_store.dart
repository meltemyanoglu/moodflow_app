import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/mood_entry.dart';

// Re-exported so existing imports of MoodEntry through this store keep working.
export '../models/mood_entry.dart';

/// In-memory + SharedPreferences-backed singleton store for mood entries.
///
/// User-scoped: each user has their own storage bucket
/// (`mood_entries_v1_<userId>`). Call [setUser] right after login/signup
/// to switch the bucket; data of one user never leaks into another.
///
/// Lifecycle:
///   1. AuthService.init() resolves current user
///   2. MoodStore.instance.setUser(userId) → loads that user's entries
///   3. App renders
///   4. On logout, AuthGate calls setUser(null) → in-memory list cleared
class MoodStore extends ChangeNotifier {
  MoodStore._();
  static final MoodStore instance = MoodStore._();

  static const _keyPrefix = 'mood_entries_v1_';

  final List<MoodEntry> _entries = [];
  String? _userId;
  bool _loaded = false;

  /// Public read-only view, sorted newest-first.
  List<MoodEntry> get entries => List.unmodifiable(_entries);
  int get totalCount => _entries.length;
  bool get isEmpty => _entries.isEmpty;
  bool get isLoaded => _loaded;
  String? get currentUserId => _userId;

  String get _storageKey => '$_keyPrefix${_userId ?? "guest"}';

  /// Switch to a different user (or null for "no one logged in").
  /// Loads that user's entries from disk.
  Future<void> setUser(String? userId) async {
    if (_userId == userId && _loaded) return;
    _userId = userId;
    _loaded = false;
    _entries.clear();
    if (userId == null) {
      // No one logged in — clear and notify, no need to read disk.
      _loaded = true;
      notifyListeners();
      return;
    }
    await _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          _entries
            ..clear()
            ..addAll(
              decoded.whereType<Map>().map(
                    (m) => MoodEntry.fromJson(Map<String, dynamic>.from(m)),
                  ),
            );
          _entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        }
      }
    } catch (e) {
      debugPrint('MoodStore._loadFromStorage error: $e');
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    if (_userId == null) return; // Don't write to disk when no one is logged in.
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_entries.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, encoded);
    } catch (e) {
      debugPrint('MoodStore._persist error: $e');
    }
  }

  Future<void> add(MoodEntry entry) async {
    _entries.insert(0, entry);
    notifyListeners();
    await _persist();
  }

  Future<void> removeById(String id) async {
    final before = _entries.length;
    _entries.removeWhere((e) => e.id == id);
    if (_entries.length != before) {
      notifyListeners();
      await _persist();
    }
  }

  Future<void> clear() async {
    if (_entries.isEmpty) return;
    _entries.clear();
    notifyListeners();
    await _persist();
  }

  // ---------------- DERIVED STATS ----------------

  Map<String, double> distributionPercent() {
    if (_entries.isEmpty) return {};
    final counts = <String, int>{};
    for (final e in _entries) {
      counts[e.moodName] = (counts[e.moodName] ?? 0) + 1;
    }
    final total = _entries.length;
    return counts.map((k, v) => MapEntry(k, (v / total) * 100));
  }

  String? mostFrequentMood() {
    final dist = distributionPercent();
    if (dist.isEmpty) return null;
    return dist.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  List<int> last7DaysCounts() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final counts = List<int>.filled(7, 0);
    for (final e in _entries) {
      final day = DateTime(
        e.createdAt.year,
        e.createdAt.month,
        e.createdAt.day,
      );
      final diff = today.difference(day).inDays;
      if (diff >= 0 && diff < 7) counts[6 - diff] += 1;
    }
    return counts;
  }

  int currentStreak() {
    if (_entries.isEmpty) return 0;
    final now = DateTime.now();
    var cursor = DateTime(now.year, now.month, now.day);
    final daysWithEntry = <DateTime>{
      for (final e in _entries)
        DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day),
    };
    var streak = 0;
    while (daysWithEntry.contains(cursor)) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  MoodEntry? latestEntry() => _entries.isEmpty ? null : _entries.first;
}
