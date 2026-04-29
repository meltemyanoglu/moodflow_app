import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/mood_entry.dart';

// Re-exported so existing imports of MoodEntry through this store keep working.
export '../models/mood_entry.dart';

/// In-memory + SharedPreferences-backed singleton store for mood entries.
///
/// Always call `await MoodStore.instance.load()` once in `main()` BEFORE
/// `runApp(...)`. After that the rest of the app can read entries
/// synchronously and listen for changes via `AnimatedBuilder`.
class MoodStore extends ChangeNotifier {
  MoodStore._();
  static final MoodStore instance = MoodStore._();

  static const String _storageKey = 'mood_entries_v1';

  final List<MoodEntry> _entries = [];
  bool _loaded = false;

  /// Public read-only view, sorted newest-first.
  List<MoodEntry> get entries => List.unmodifiable(_entries);
  int get totalCount => _entries.length;
  bool get isEmpty => _entries.isEmpty;
  bool get isLoaded => _loaded;

  /// Load entries from disk. Idempotent — safe to call multiple times.
  Future<void> load() async {
    if (_loaded) return;
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
          // Make sure newest-first invariant holds even if older app
          // versions saved them differently.
          _entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        }
      }
    } catch (e) {
      debugPrint('MoodStore.load error: $e');
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(
        _entries.map((e) => e.toJson()).toList(),
      );
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

  /// Stable removal by id — never use list index for delete.
  Future<void> removeById(String id) async {
    final removed = _entries.length;
    _entries.removeWhere((e) => e.id == id);
    if (_entries.length != removed) {
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

  /// Mood → percentage of total.
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

  /// Number of entries logged on each of the last 7 days.
  /// Index 0 = 6 days ago. Index 6 = today.
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

  /// Consecutive days with at least one entry, ending today.
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
