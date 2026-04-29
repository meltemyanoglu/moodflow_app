/// One saved mood entry. Lives on disk via SharedPreferences (JSON).
///
/// `id` is generated when the entry is created and is used as a stable
/// key for [Dismissible] in the history list — never use list index.
class MoodEntry {
  final String id;
  final String moodName;
  final String note;
  final DateTime createdAt;

  const MoodEntry({
    required this.id,
    required this.moodName,
    required this.note,
    required this.createdAt,
  });

  /// Factory used when the user creates a new entry.
  /// Generates a unique id from the current microseconds timestamp.
  factory MoodEntry.create({
    required String moodName,
    required String note,
  }) {
    final now = DateTime.now();
    return MoodEntry(
      id: now.microsecondsSinceEpoch.toString(),
      moodName: moodName,
      note: note,
      createdAt: now,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'moodName': moodName,
        'note': note,
        'createdAt': createdAt.toIso8601String(),
      };

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    final created = DateTime.tryParse(json['createdAt'] as String? ?? '') ??
        DateTime.now();
    return MoodEntry(
      // Older entries saved before we added `id` won't have one — fall back
      // to the timestamp so they still get a stable key.
      id: (json['id'] as String?) ?? created.microsecondsSinceEpoch.toString(),
      moodName: json['moodName'] as String? ?? '',
      note: json['note'] as String? ?? '',
      createdAt: created,
    );
  }
}
