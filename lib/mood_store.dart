import 'package:flutter/foundation.dart';

/// Tek bir mood kaydı (hafızada tutulur).
class MoodEntry {
  final String moodName;
  final String note;
  final DateTime createdAt;

  const MoodEntry({
    required this.moodName,
    required this.note,
    required this.createdAt,
  });
}

/// Uygulama boyunca paylaşılan in-memory store.
/// ChangeNotifier sayesinde dinleyen widget'lar otomatik yenilenir.
class MoodStore extends ChangeNotifier {
  MoodStore._internal();
  static final MoodStore instance = MoodStore._internal();

  final List<MoodEntry> _entries = [];

  List<MoodEntry> get entries => List.unmodifiable(_entries);

  int get totalCount => _entries.length;

  void add(MoodEntry entry) {
    _entries.insert(0, entry); // en yeni başta
    notifyListeners();
  }

  void removeAt(int index) {
    if (index < 0 || index >= _entries.length) return;
    _entries.removeAt(index);
    notifyListeners();
  }

  void clear() {
    _entries.clear();
    notifyListeners();
  }

  /// Mood adına göre yüzde dağılımı döndürür: { 'Calm': 42.0, ... }
  Map<String, double> distributionPercent() {
    if (_entries.isEmpty) return {};
    final counts = <String, int>{};
    for (final e in _entries) {
      counts[e.moodName] = (counts[e.moodName] ?? 0) + 1;
    }
    final total = _entries.length;
    return counts.map((k, v) => MapEntry(k, (v / total) * 100));
  }

  /// En sık seçilen mood'u döndürür (yoksa null).
  String? mostFrequentMood() {
    final dist = distributionPercent();
    if (dist.isEmpty) return null;
    return dist.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  /// Son 7 günün her birinde kaç kayıt yapıldığını verir (chart için).
  /// Index 0 = 6 gün önce, Index 6 = bugün.
  List<int> last7DaysCounts() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final counts = List<int>.filled(7, 0);
    for (final e in _entries) {
      final d = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
      final diff = today.difference(d).inDays;
      if (diff >= 0 && diff < 7) {
        counts[6 - diff] += 1;
      }
    }
    return counts;
  }

  /// Üst üste kaç gün kayıt yapıldı (streak).
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
}
