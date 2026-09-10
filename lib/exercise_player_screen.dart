import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExercisePlayerScreen extends StatefulWidget {
  final Map<String, dynamic> exerciseData;

  const ExercisePlayerScreen({Key? key, required this.exerciseData}) : super(key: key);

  @override
  State<ExercisePlayerScreen> createState() => _ExercisePlayerScreenState();
}

class _ExercisePlayerScreenState extends State<ExercisePlayerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  Timer? _timer;
  int _secondsRemaining = 0;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.exerciseData['Duration_Seconds'] ?? 300;

    // Vizuální animace dýchání (4s nádech, 4s výdech)
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController.reverse();
          _triggerHaptic();
        } else if (status == AnimationStatus.dismissed) {
          _animationController.forward();
          _triggerHaptic();
        }
      });

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _startSession();
  }

  void _triggerHaptic() {
    final pattern = widget.exerciseData['Haptic_Pattern'];
    if (pattern == 'DEEP_SIGH') {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _pauseSession();
      }
    });
  }

  void _startSession() {
    setState(() => _isPlaying = true);
    _animationController.forward();
    _startTimer();
  }

  void _pauseSession() {
    setState(() => _isPlaying = false);
    _animationController.stop();
    _timer?.cancel();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(widget.exerciseData['Day_Title'] ?? 'Cvičení'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              widget.exerciseData['Somatic_Exercise_Title'] ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Spacer(),

            // Pulzující kruh
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.cyanAccent.withOpacity(0.6),
                          Colors.blue.withOpacity(0.2),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 10,
                        )
                      ],
                    ),
                  ),
                );
              },
            ),

            const Spacer(),

            // Odpočet času
            Text(
              _formatTime(_secondsRemaining),
              style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w300),
            ),
            const SizedBox(height: 10),

            // Ovládací tlačítko
            IconButton(
              iconSize: 64,
              icon: Icon(
                _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                color: Colors.cyanAccent,
              ),
              onPressed: () {
                if (_isPlaying) {
                  _pauseSession();
                } else {
                  _startSession();
                }
              },
            ),

            const SizedBox(height: 30),

            // Spodní informace z DB
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Proč to funguje?', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                    widget.exerciseData['Neuro_Science_Why'] ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.exerciseData['Yoga_Philosophy'] ?? '',
                    style: const TextStyle(color: Colors.white38, fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

