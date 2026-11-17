import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'lotus_illustration.dart';

const Color _turquoise = Color(0xFF48CAE4);
const Color _softTurquoise = Color(0xFF90E0EF);
const Color _gold = Color(0xFFE9C46A);
const Color _calmText = Color(0xFFE2E8F0);

class ExercisePlayerScreen extends StatefulWidget {
  final Map<String, String> exerciseData;
  final bool isCompleted;
  final ValueChanged<String>? onCompleted;

  const ExercisePlayerScreen({
    super.key,
    required this.exerciseData,
    this.isCompleted = false,
    this.onCompleted,
  });

  @override
  State<ExercisePlayerScreen> createState() => _ExercisePlayerScreenState();
}

class _ExercisePlayerScreenState extends State<ExercisePlayerScreen> {
  Timer? _timer;
  int _secondsLeft = 0;
  bool _isRunning = false;
  bool _finished = false;
  late bool _completed;

  @override
  void initState() {
    super.initState();
    _secondsLeft = int.tryParse(widget.exerciseData['Duration_Seconds'] ?? '180') ?? 180;
    _completed = widget.isCompleted;
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
      return;
    }
    setState(() {
      _isRunning = true;
      _finished = false;
    });
    HapticFeedback.vibrate();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
        if (_secondsLeft % 5 == 0) HapticFeedback.selectionClick();
      } else {
        _timer?.cancel();
        setState(() {
          _isRunning = false;
          _finished = true;
        });
        HapticFeedback.heavyImpact();
      }
    });
  }

  void _markCompleted() {
    final dayId = widget.exerciseData['Day_ID'] ?? '';
    if (dayId.isEmpty || _completed) return;
    widget.onCompleted?.call(dayId);
    setState(() => _completed = true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget _completionArea() {
    final hasDay = (widget.exerciseData['Day_ID'] ?? '').isNotEmpty;
    if (!hasDay) return const SizedBox.shrink();
    if (_completed) {
      return const Text(
        'Tento den už máš mezi lotosy.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: _gold),
      );
    }
    if (!_finished) return const SizedBox.shrink();
    return SizedBox(
      height: 54,
      child: OutlinedButton(
        onPressed: _markCompleted,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: _gold, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: const Text(
          'Označit den jako dokončený',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.exerciseData['Somatic_Exercise_Title'] ?? 'Cvičení';
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    final clock = '$minutes:$seconds';
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: Colors.transparent),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.exerciseData['Day_Title'] ?? '',
                style: const TextStyle(fontSize: 22, color: _softTurquoise, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0x14FFFFFF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _turquoise, width: 1),
                ),
                child: Text(
                  widget.exerciseData['Somatic_Exercise_Text'] ?? '',
                  style: const TextStyle(fontSize: 16, height: 1.5, color: _calmText),
                ),
              ),
              const Spacer(),
              Center(
                child: CalmIllustration(
                  motif: motifForExercise(title),
                  label: 'Klidná ilustrace ke cvičení',
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Semantics(
                  liveRegion: true,
                  label: 'Zbývá $clock',
                  child: Text(
                    clock,
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      color: _softTurquoise,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                height: 54,
                child: OutlinedButton(
                  onPressed: _toggleTimer,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0x3348CAE4),
                    side: const BorderSide(color: _softTurquoise, width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Text(
                    _isRunning ? 'Pozastavit' : 'Spustit cvičení',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _completionArea(),
            ],
          ),
        ),
      ),
    );
  }
}
