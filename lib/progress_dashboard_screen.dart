import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'exercise_player_screen.dart';

class ProgressDashboardScreen extends StatefulWidget {
  final Map<String, bool> completedDays;

  const ProgressDashboardScreen({super.key, required this.completedDays});

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
    return Scaffold(
      appBar: AppBar(title: const Text('NeuroFlow – 30 Dní'), backgroundColor: Colors.transparent),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _daysData.length,
              itemBuilder: (context, index) {
                final day = _daysData[index];
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E293B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExercisePlayerScreen(exerciseData: day),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Den ${index + 1}', style: const TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(day['Day_Title'] ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.white70)),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
