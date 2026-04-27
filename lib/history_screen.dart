import 'package:flutter/material.dart';
import 'mood_store.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  static const _moodColors = <String, Color>{
    'Calm': Color(0xFF6B9DFF),
    'Happy': Color(0xFFFFC857),
    'Melancholic': Color(0xFF9C7CB7),
    'Energetic': Color(0xFFFF7E6B),
  };

  static const _moodIcons = <String, IconData>{
    'Calm': Icons.spa_rounded,
    'Happy': Icons.wb_sunny_rounded,
    'Melancholic': Icons.cloud_rounded,
    'Energetic': Icons.bolt_rounded,
  };

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dayDate = DateTime(d.year, d.month, d.day);
    final diff = today.difference(dayDate).inDays;
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    if (diff == 0) return 'Bugün $hh:$mm';
    if (diff == 1) return 'Dün $hh:$mm';
    return '${d.day}.${d.month}.${d.year} $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MoodStore.instance,
      builder: (context, _) {
        final entries = MoodStore.instance.entries;

        return Scaffold(
          backgroundColor: const Color(0xFFFAF8FF),
          appBar: AppBar(
            title: const Text(
              'History',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: entries.isEmpty
              ? _emptyState()
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 30),
                  itemCount: entries.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final e = entries[index];
                    final color =
                        _moodColors[e.moodName] ?? const Color(0xFF6B3FD6);
                    final icon =
                        _moodIcons[e.moodName] ?? Icons.emoji_emotions_rounded;

                    return Dismissible(
                      key: ValueKey(
                        '${e.createdAt.millisecondsSinceEpoch}-$index',
                      ),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF7E6B),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (_) {
                        MoodStore.instance.removeAt(index);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${e.moodName} silindi'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.18),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(icon, color: color),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        e.moodName,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF171733),
                                        ),
                                      ),
                                      Text(
                                        _formatDate(e.createdAt),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF8D889A),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (e.note.isNotEmpty) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      e.note,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        height: 1.4,
                                        color: Color(0xFF4A4761),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: const Color(0xFFEDE5FF),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.history_rounded,
                color: Color(0xFF6B3FD6),
                size: 40,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Henüz kayıt yok',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Home sayfasından bir mood seçip "Save Mood" ile kaydetmeye başla.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6F6B80), height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
