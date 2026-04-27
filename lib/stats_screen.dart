import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8FF),
      appBar: AppBar(
        title: const Text(
          "Mood Analytics",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Weekly Mood Trend",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height:20),

            Container(
              height:250,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show:false),
                  borderData: FlBorderData(show:false),
                  titlesData: FlTitlesData(show:false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved:true,
                      barWidth:4,
                      spots: const [
                        FlSpot(0,2),
                        FlSpot(1,4),
                        FlSpot(2,3),
                        FlSpot(3,5),
                        FlSpot(4,4),
                        FlSpot(5,6),
                        FlSpot(6,5),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height:30),

            const Text(
              "Mood Distribution",
              style: TextStyle(
                fontSize:24,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height:18),

            Row(
              children:[
                Expanded(child:_moodMetric("Calm","42%")),
                SizedBox(width:12),
                Expanded(child:_moodMetric("Happy","31%")),
              ],
            ),

            SizedBox(height:12),

            Row(
              children:[
                Expanded(child:_moodMetric("Energetic","17%")),
                SizedBox(width:12),
                Expanded(child:_moodMetric("Melancholic","10%")),
              ],
            ),

            const SizedBox(height:30),

            Container(
              padding: EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:[
                    Color(0xFF7C4DFF),
                    Color(0xFF5E35B1),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children:[
                  Text(
                    "7 Day Streak",
                    style: TextStyle(
                      color:Colors.white,
                      fontSize:30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height:8),
                  Text(
                    "You logged moods every day this week",
                    style: TextStyle(color:Colors.white70),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  static Widget _moodMetric(String label,String value){
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children:[
          Text(
            value,
            style: TextStyle(
              fontSize:28,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height:6),
          Text(label),
        ],
      ),
    );
  }
}