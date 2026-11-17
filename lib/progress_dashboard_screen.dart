import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'exercise_player_screen.dart';
import 'lotus_progress_store.dart';

const Color _turquoise = Color(0xFF48CAE4);
const Color _softTurquoise = Color(0xFF90E0EF);
const Color _gold = Color(0xFFE9C46A);

class ProgressDashboardScreen extends StatefulWidget {
  final Set<String> completedDays;
  final ValueChanged<String>? onDayCompleted;

  const ProgressDashboardScreen({
    super.key,
    required this.completedDays,
    this.onDayCompleted,
  });

  @override
  State<ProgressDashboardScreen> createState() => _ProgressDashboardScreenState();
}

class _ProgressDashboardScreenState extends State<ProgressDashboardScreen> {
  List<Map<String, String>> _daysData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCSV();
  }

  Future<void> _loadCSV() async {
    try {
      final rawData = await rootBundle.loadString('assets/neuroflow-30dni.csv');
      final lines = rawData.split('\n');
      List<Map<String, String>> loaded = [];

      for (int i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        final row = line.split(';');
        if (row.length >= 10) {
          loaded.add({
            'Day_ID': row[0],
            'Week_Number': row[1],
            'Day_Title': row[2],
            'Somatic_Exercise_Title': row[3],
            'Somatic_Exercise_Text': row[4],
            'Neuro_Science_Why': row[5],
            'Yoga_Philosophy': row[6],
            'Haptic_Pattern': row[7],
            'Duration_Seconds': row[8],
            'Visual_Instruction': row[9],
          });
        }
      }

      setState(() {
        _daysData = loaded;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dayIds = _daysData.map((d) => d['Day_ID'] ?? '').toSet();
    final lotusCount = widget.completedDays.where(dayIds.contains).length;
    return Scaffold(
      appBar: AppBar(title: const Text('NeuroFlow – 30 Dní'), backgroundColor: Colors.transparent),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: _LotusPanel(count: lotusCount, total: _daysData.length),
                ),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _daysData.length,
                    itemBuilder: (context, index) {
                      final day = _daysData[index];
                      final dayId = day['Day_ID'] ?? '';
                      final done = widget.completedDays.contains(dayId);
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E293B),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ExercisePlayerScreen(
                                exerciseData: day,
                                isCompleted: done,
                                onCompleted: widget.onDayCompleted,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Den ${index + 1}', style: const TextStyle(color: _turquoise, fontWeight: FontWeight.bold)),
                                if (done)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 4),
                                    child: Semantics(
                                      label: 'dokončeno',
                                      child: Icon(Icons.local_florist, size: 12, color: _gold),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              day['Day_Title'] ?? '',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 10, color: Colors.white70),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _LotusPanel extends StatelessWidget {
  final int count;
  final int total;

  const _LotusPanel({required this.count, required this.total});

  @override
  Widget build(BuildContext context) {
    final current = currentLotusMilestone(count);
    final encouragement = current == null
        ? 'Každý den je jeden lotos. Nemusíš stihnout všechno.'
        : 'Máš ${current.name}. Každý den je jeden lotos, nemusíš stihnout všechno.';
    return Semantics(
      label: 'Sbírka lotosů: $count z $total',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0x14FFFFFF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _turquoise, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.local_florist, color: _gold),
                const SizedBox(width: 8),
                Text(
                  'Sbírka lotosů',
                  style: const TextStyle(fontSize: 16, color: _softTurquoise, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text('$count z $total', style: const TextStyle(fontSize: 16, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 8),
            Text(encouragement, style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.white70)),
            const SizedBox(height: 12),
            Row(
              children: [
                for (final m in lotusMilestones)
                  Expanded(
                    child: Column(
                      children: [
                        Icon(
                          Icons.local_florist,
                          size: 22,
                          color: count >= m.days ? _gold : Colors.white24,
                        ),
                        const SizedBox(height: 2),
                        Text('${m.days} dní', style: const TextStyle(fontSize: 11, color: Colors.white)),
                        Text(
                          m.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10,
                            color: count >= m.days ? _softTurquoise : Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
