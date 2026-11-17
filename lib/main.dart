import 'package:flutter/material.dart';
import 'exercise_player_screen.dart';
import 'progress_dashboard_screen.dart';
import 'ocean_welcome_screen.dart';
import 'lotus_progress_store.dart';

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
      home: const OceanWelcomeScreen(),
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
  LotusProgressStore? _store;
  Set<String> _completedDays = <String>{};

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final store = await LotusProgressStore.open();
    if (!mounted) return;
    setState(() {
      _store = store;
      _completedDays = store.loadCompleted();
    });
  }

  Future<void> _markDayCompleted(String dayId) async {
    final store = _store;
    if (store == null) return;
    final added = await store.markCompleted(dayId);
    if (!mounted || !added) return;
    setState(() => _completedDays = store.loadCompleted());
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      ProgressDashboardScreen(
        completedDays: _completedDays,
        onDayCompleted: _markDayCompleted,
      ),
      ExercisePlayerScreen(exerciseData: const {}),
    ];
    return Scaffold(
      body: screens[_currentIndex],
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
