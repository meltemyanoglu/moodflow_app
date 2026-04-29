import 'package:flutter/material.dart';

import '../stores/mood_store.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  static const _moodOrder = ['Calm', 'Happy', 'Energetic', 'Melancholic'];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: MoodStore.instance,
      builder: (context, _) {
        final store = MoodStore.instance;
        final last7 = store.last7DaysCounts();
        final dist = store.distributionPercent();
        final streak = store.currentStreak();
        final total = store.totalCount;
        final isEmpty = total == 0;

        return Scaffold(
          backgroundColor: const Color(0xFFFAF8FF),
          appBar: AppBar(
            centerTitle: true,
            title: const Text(
              'Mood Analytics',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFF24212D),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _summaryCard(total: total, streak: streak),
                  const SizedBox(height: 24),

                  _sectionTitle(
                    title: 'Weekly Mood Stars',
                    subtitle: isEmpty
                        ? 'No data yet — your entries will light up here.'
                        : 'Each day shines brighter when you log more moods.',
                  ),
                  const SizedBox(height: 14),
                  _trendCard(last7, isEmpty),

                  const SizedBox(height: 28),

                  _sectionTitle(
                    title: 'Mood Distribution',
                    subtitle: isEmpty
                        ? 'Start logging moods to see your emotional balance.'
                        : 'Percentage breakdown of your logged moods.',
                  ),
                  const SizedBox(height: 14),
                  if (isEmpty) _emptyDistribution() else _distributionGrid(dist),

                  const SizedBox(height: 28),
                  _streakCard(streak),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitle({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w900,
            color: Color(0xFF24212D),
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF7A748A),
            fontSize: 14,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required int total,
    required int streak,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF7C4DFF),
            Color(0xFFB388FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C4DFF).withOpacity(0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _summaryItem(
              icon: Icons.favorite_rounded,
              value: '$total',
              label: 'Total moods',
            ),
          ),
          Container(
            height: 58,
            width: 1,
            color: Colors.white.withOpacity(0.35),
          ),
          Expanded(
            child: _summaryItem(
              icon: Icons.local_fire_department_rounded,
              value: '$streak',
              label: 'Day streak',
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _trendCard(List<int> last7, bool isEmpty) {
    const labels = ['6d', '5d', '4d', '3d', '2d', '1d', 'Today'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF241540),
            Color(0xFF4A2B7F),
            Color(0xFF7C4DFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C4DFF).withOpacity(0.24),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Text(
                  'Log a mood to light up your week ✨',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            )
          : Row(
              children: [
                for (var i = 0; i < last7.length; i++)
                  Expanded(
                    child: _starDay(
                      label: labels[i],
                      count: last7[i],
                      color: _starColor(i),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _starDay({
    required String label,
    required int count,
    required Color color,
  }) {
    final intensity = count.clamp(0, 5).toDouble();
    final starSize = count == 0 ? 26.0 : 26.0 + intensity * 5.5;
    final glowOpacity = count == 0 ? 0.0 : 0.25 + intensity * 0.08;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 94,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (count > 0)
                Container(
                  width: starSize + 42,
                  height: starSize + 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(glowOpacity),
                        blurRadius: 24 + intensity * 7,
                        spreadRadius: 5 + intensity * 2,
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.35),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),

              if (count > 1)
                Icon(
                  Icons.auto_awesome_rounded,
                  size: starSize + 34,
                  color: color.withOpacity(0.30),
                ),

              if (count > 2)
                Positioned(
                  top: 12,
                  right: 16,
                  child: Icon(
                    Icons.star_rounded,
                    size: 10,
                    color: Colors.white.withOpacity(0.95),
                  ),
                ),

              if (count > 3)
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    size: 12,
                    color: color.withOpacity(0.95),
                  ),
                ),

              if (count > 4)
                const Positioned(
                  top: 8,
                  child: Icon(
                    Icons.star_rounded,
                    size: 12,
                    color: Color(0xFFFFF59D),
                  ),
                ),

              ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    colors: count == 0
                        ? [
                            const Color(0xFFB9B0CB),
                            const Color(0xFFE4DDF0),
                          ]
                        : [
                            Colors.white,
                            color,
                            const Color(0xFFFFF8E1),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds);
                },
                child: Icon(
                  count == 0 ? Icons.star_border_rounded : Icons.star_rounded,
                  size: starSize,
                  color: Colors.white,
                ),
              ),

              if (count > 1)
                Positioned(
                  bottom: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: label == 'Today' ? 10.5 : 11,
            color: Colors.white.withOpacity(0.78),
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Color _starColor(int index) {
    const colors = [
      Color(0xFFFFD54F),
      Color(0xFF80DEEA),
      Color(0xFFFF8A65),
      Color(0xFFCE93D8),
      Color(0xFFA5D6A7),
      Color(0xFFFF80AB),
      Color(0xFFFFF176),
    ];

    return colors[index % colors.length];
  }

  Widget _distributionGrid(Map<String, double> dist) {
    final ordered = <MapEntry<String, double>>[
      for (final mood in _moodOrder)
        if (dist.containsKey(mood)) MapEntry(mood, dist[mood]!),
      for (final entry in dist.entries)
        if (!_moodOrder.contains(entry.key)) entry,
    ];

    return Column(
      children: [
        for (var i = 0; i < ordered.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _moodMetric(
                    ordered[i].key,
                    '${ordered[i].value.round()}%',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: i + 1 < ordered.length
                      ? _moodMetric(
                          ordered[i + 1].key,
                          '${ordered[i + 1].value.round()}%',
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _emptyDistribution() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: const Column(
        children: [
          Icon(
            Icons.insights_rounded,
            size: 42,
            color: Color(0xFF7C4DFF),
          ),
          SizedBox(height: 12),
          Text(
            'No mood data yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF24212D),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Start logging moods from the Home screen. Your analytics will appear here automatically.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6F6B80),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _moodMetric(String label, String value) {
    final style = _styleForMood(label);

    return Container(
      constraints: const BoxConstraints(minHeight: 170),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: style.color.withOpacity(0.11),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
        border: Border.all(color: style.color.withOpacity(0.11)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: style.color.withOpacity(0.14),
              shape: BoxShape.circle,
            ),
            child: Icon(style.icon, color: style.color, size: 25),
          ),
          const SizedBox(height: 14),
          FittedBox(
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.6,
                color: Color(0xFF24212D),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6F6B80),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  static _MoodVisualStyle _styleForMood(String mood) {
    switch (mood) {
      case 'Happy':
        return const _MoodVisualStyle(
          color: Color(0xFFFFB300),
          icon: Icons.wb_sunny_rounded,
        );
      case 'Energetic':
        return const _MoodVisualStyle(
          color: Color(0xFFFF7043),
          icon: Icons.bolt_rounded,
        );
      case 'Melancholic':
        return const _MoodVisualStyle(
          color: Color(0xFF5C6BC0),
          icon: Icons.water_drop_rounded,
        );
      case 'Calm':
      default:
        return const _MoodVisualStyle(
          color: Color(0xFF6B3FD6),
          icon: Icons.spa_rounded,
        );
    }
  }

  Widget _streakCard(int streak) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF8A65),
            Color(0xFFFFB74D),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF8A65).withOpacity(0.20),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            color: Colors.white,
            size: 42,
          ),
          const SizedBox(height: 10),
          Text(
            '$streak Day Streak',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            streak == 0
                ? 'Start your streak by logging your first mood today!'
                : 'You have been logging moods for $streak day(s) in a row. Keep going!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodVisualStyle {
  final Color color;
  final IconData icon;

  const _MoodVisualStyle({
    required this.color,
    required this.icon,
  });
}