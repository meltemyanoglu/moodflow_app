import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'mood_store.dart';

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
        final isEmpty = store.totalCount == 0;

        return Scaffold(
          backgroundColor: const Color(0xFFFAF8FF),
          appBar: AppBar(
            title: const Text(
              'Mood Analytics',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weekly Mood Trend',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  isEmpty
                      ? 'Henüz veri yok — kayıt ekledikçe burada görünecek.'
                      : 'Son 7 gündeki günlük kayıt sayısı',
                  style: const TextStyle(color: Color(0xFF6F6B80)),
                ),
                const SizedBox(height: 18),
                Container(
                  height: 250,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (value, meta) {
                              const labels = ['-6', '-5', '-4', '-3', '-2', '-1', '0'];
                              final i = value.toInt();
                              if (i < 0 || i >= labels.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  i == 6 ? 'Bugün' : labels[i],
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF8D889A),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          color: const Color(0xFF6B3FD6),
                          barWidth: 4,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color(0xFF6B3FD6).withOpacity(0.12),
                          ),
                          spots: [
                            for (var i = 0; i < last7.length; i++)
                              FlSpot(i.toDouble(), last7[i].toDouble()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Mood Distribution',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 18),
                if (isEmpty)
                  _emptyDistribution()
                else
                  _distributionGrid(dist),
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C4DFF), Color(0xFF5E35B1)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$streak Gün Streak',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        streak == 0
                            ? 'Bugün ilk kaydını ekleyerek başla!'
                            : 'Son $streak gündür mood kaydediyorsun. 👏',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _distributionGrid(Map<String, double> dist) {
    final ordered = [
      for (final m in _moodOrder)
        if (dist.containsKey(m)) MapEntry(m, dist[m]!),
      for (final e in dist.entries)
        if (!_moodOrder.contains(e.key)) e,
    ];
    final rows = <Widget>[];
    for (var i = 0; i < ordered.length; i += 2) {
      final left = ordered[i];
      final right = i + 1 < ordered.length ? ordered[i + 1] : null;
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Expanded(
                child: _moodMetric(left.key, '${left.value.round()}%'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: right == null
                    ? const SizedBox.shrink()
                    : _moodMetric(right.key, '${right.value.round()}%'),
              ),
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }

  Widget _emptyDistribution() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Text(
        'Henüz dağılım yok. Home sayfasından mood kaydetmeye başla.',
        style: TextStyle(color: Color(0xFF6F6B80)),
      ),
    );
  }

  static Widget _moodMetric(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(label),
        ],
      ),
    );
  }
}
