import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

class ExercisePlayerScreen extends StatefulWidget {
  final Map<String, String> exerciseData;

  const ExercisePlayerScreen({super.key, required this.exerciseData});

  @override
  State<ExercisePlayerScreen> createState() => _ExercisePlayerScreenState();
}

class _ExercisePlayerScreenState extends State<ExercisePlayerScreen> {
  Timer? _timer;
  int _secondsLeft = 0;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _secondsLeft = int.tryParse(widget.exerciseData['Duration_Seconds'] ?? '180') ?? 180;
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _triggerHaptic();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondsLeft > 0) {
          setState(() => _secondsLeft--);
          if (_secondsLeft % 5 == 0) _triggerHaptic();
        } else {
          _timer?.cancel();
          setState(() => _isRunning = false);
        }
      });
    }
  }

  void _triggerHaptic() async {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(duration: 200, amplitude: 128);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.exerciseData['Somatic_Exercise_Title'] ?? 'Cvičení')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(widget.exerciseData['Day_Title'] ?? '', style: const TextStyle(fontSize: 22, color: Colors.cyan, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(widget.exerciseData['Somatic_Exercise_Text'] ?? '', style: const TextStyle(fontSize: 16, color: Colors.white)),
            const Spacer(),
            Center(
              child: Text(
                '${(_secondsLeft ~/ 60).toString().padLeft(2, '0')}:${(_secondsLeft % 60).toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.cyan),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _toggleTimer,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan, padding: const EdgeInsets.symmetric(vertical: 16)),
              child: Text(_isRunning ? 'POZASTAVIT' : 'SPUSTIT CVIČENÍ', style: const TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
