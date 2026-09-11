import 'package:flutter/material.dart';
import 'exercise_player_screen.dart';
import 'progress_dashboard_screen.dart';

void main() {
  runApp(const NeuroFlowApp());
}

class NeuroFlowApp extends StatelessWidget {
  const NeuroFlowApp({super.key});

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
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ProgressDashboardScreen(),
    ExercisePlayerScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Nástěnka',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Cvičení',
          ),
        ],
      ),
    );
  }
}
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
