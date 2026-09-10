import 'package:flutter/material.dart';

class ProgressDashboardScreen extends StatelessWidget {
  final Map<String, bool> completedDays;
  final int currentStreak;

  const ProgressDashboardScreen({
    Key? key,
    required this.completedDays,
    this.currentStreak = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int totalCompleted = completedDays.values.where((v) => v).length;
    double progressPercentage = totalCompleted / 30;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Můj pokrok'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Karta přehledu statistik
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn('Dokončeno', '$totalCompleted / 30', Icons.check_circle_outline, Colors.cyanAccent),
                    Container(width: 1, height: 40, color: Colors.white10),
                    _buildStatColumn('Série', '$currentStreak dnů', Icons.local_fire_department, Colors.orangeAccent),
                    Container(width: 1, height: 40, color: Colors.white10),
                    _buildStatColumn('Pokrok', '${(progressPercentage * 100).toInt()}%', Icons.donut_large, Colors.lightGreenAccent),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progressPercentage,
                  minHeight: 12,
                  backgroundColor: const Color(0xFF1E293B),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
                ),
              ),

              const SizedBox(height: 30),
              const Text(
                '30denní somatická cesta',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Mřížka 4 týdnů
              _buildWeekSection('Týden 1: Somatická cvičení', 1, 7),
              _buildWeekSection('Týden 2: Dechové techniky', 8, 14),
              _buildWeekSection('Týden 3: Kognitivní vzorce', 15, 21),
              _buildWeekSection('Týden 4: Integrace do života', 22, 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 28),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }

  Widget _buildWeekSection(String title, int startDay, int endDay) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(color: Colors.cyanAccent, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: (endDay - startDay + 1),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            int dayNum = startDay + index;
            String dayKey = 'DAY_${dayNum.toString().padLeft(2, '0')}';
            bool isDone = completedDays[dayKey] ?? false;

            return Container(
              decoration: BoxDecoration(
                color: isDone ? Colors.cyanAccent.withOpacity(0.2) : const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isDone ? Colors.cyanAccent : Colors.white10,
                  width: isDone ? 1.5 : 1,
                ),
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check, color: Colors.cyanAccent, size: 18)
                    : Text(
                        '$dayNum',
                        style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
