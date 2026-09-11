import 'package:flutter/material.dart';
import 'exercise_player_screen.dart';
import 'progress_dashboard_screen.dart';

void main() {
  runApp(const NeuroFlowApp());
}

class NeuroFlowApp extends StatelessWidget {
  const NeuroFlowApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeuroFlow',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        primarySwatch: Colors.cyan,
      ),
      home: const MainNavigationScreen(),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // Ukázková data pro první den (DAY_01)
  final Map<String, dynamic> _todayExercise = {
    'Day_ID': 'DAY_01',
    'Week_Number': 1,
    'Day_Title': 'Den 1: Mapování napětí',
    'Somatic_Exercise_Title': 'Somatický scan těla',
    'Somatic_Exercise_Text': 'Pohodlně se posaďte nebo lehněte. Zavřete oči a pomalu projděte pozorností tělo od palců u nohou až po temeno hlavy.',
    'Neuro_Science_Why': 'Zaměření pozornosti na fyzické vjemy bez hodnocení snižuje reaktivitu amygdaly a zklidňuje osu hypotalamus-hypofýza-nadledviny.',
    'Yoga_Philosophy': 'Pratjáhára – stažení smyslů do vnitřního světa jako první krok sebepoznání.',
    'Haptic_Pattern': 'SLOW_WAVE',
    'Duration_Seconds': 300,
  };

  // Ukázkový stav dokončených dní
  final Map<String, bool> _completedDays = {
    'DAY_01': true,
    'DAY_02': true,
    'DAY_03': false,
  };

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      ExercisePlayerScreen(exerciseData: _todayExercise),
      ProgressDashboardScreen(
        completedDays: _completedDays,
        currentStreak: 2,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: const Color(0xFF1E293B),
        selectedItemColor: Colors.cyanAccent,
        unselectedItemColor: Colors.white38,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement),
            label: 'Cvičení',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Pokrok',
          ),
        ],
      ),
    );
  }
}
