import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'haptic_engine.dart';
import 'main.dart';

class OceanWelcomeScreen extends StatefulWidget {
  const OceanWelcomeScreen({super.key});

  @override
  State<OceanWelcomeScreen> createState() => _OceanWelcomeScreenState();
}

class _OceanWelcomeScreenState extends State<OceanWelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _breathController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isMuted = false;
  String _breathPhase = 'Nádech...';
  String _lastTriggeredPhase = '';

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..addListener(_onBreathTick);

    _breathController.repeat();
    _initOceanSound();
  }

  Future<void> _initOceanSound() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(0.45);
      await _audioPlayer.play(AssetSource('waves.mp3'));
    } catch (_) {
      // Pokud soubor waves.mp3 ještě není nahraný, aplikace běží bez chyby dál
    }
  }

  void _toggleSound() async {
    setState(() {
      _isMuted = !_isMuted;
    });
    if (_isMuted) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  void _onBreathTick() {
    final t = _breathController.value;
    String currentPhase;

    if (t < 4 / 12) {
      currentPhase = 'Nádech...';
    } else if (t < 6 / 12) {
      currentPhase = 'Zadrž dech...';
    } else {
      currentPhase = 'Pomalý výdech...';
    }

    if (currentPhase != _lastTriggeredPhase) {
      _lastTriggeredPhase = currentPhase;
      setState(() {
        _breathPhase = currentPhase;
      });
      if (currentPhase == 'Nádech...') {
        HapticEngine.playPattern('SLOW_WAVE');
      } else if (currentPhase == 'Pomalý výdech...') {
        HapticEngine.playPattern('DEEP_SIGH');
      }
    }
  }

  double _calculateCircleProgress(double t) {
    if (t < 4 / 12) {
      final p = t / (4 / 12);
      return Curves.easeInOutSine.transform(p);
    } else if (t < 6 / 12) {
      return 1.0;
    } else {
      final p = (t - 6 / 12) / (6 / 12);
      return 1.0 - Curves.easeInOutSine.transform(p);
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _breathController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _enterProgram() {
    _audioPlayer.stop();
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, __, ___) => const MainNavigationScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF071324),
                  Color(0xFF0C2742),
                  Color(0xFF114B66),
                  Color(0xFF16697A),
                ],
              ),
            ),
          ),

          AnimatedBuilder(
            animation: _waveController,
            builder: (context, _) {
              return CustomPaint(
                size: Size.infinite,
                painter: _OceanWavesPainter(_waveController.value),
              );
            },
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 48),
                      const Column(
                        children: [
                          Text(
                            'NeuroFlow',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 3,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Zklidni svůj nervový systém',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF99E2E8),
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: _toggleSound,
                        icon: Icon(
                          _isMuted ? Icons.volume_off : Icons.waves,
                          color: const Color(0xFF99E2E8),
                        ),
                        tooltip: _isMuted ? 'Zapnout zvuk moře' : 'Ztlumit zvuk moře',
                      ),
                    ],
                  ),

                  AnimatedBuilder(
                    animation: _breathController,
                    builder: (context, _) {
                      final progress =
                          _calculateCircleProgress(_breathController.value);
                      final outerSize = 150.0 + (progress * 110.0);
                      final innerSize = 110.0 + (progress * 80.0);

                      return SizedBox(
                        width: 280,
                        height: 280,
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: outerSize,
                                height: outerSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF48CAE4)
                                      .withOpacity(0.15 + progress * 0.12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF48CAE4)
                                          .withOpacity(0.25),
                                      blurRadius: 30 + (progress * 20),
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: innerSize,
                                height: innerSize,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      const Color(0xFF90E0EF).withOpacity(0.85),
                                      const Color(0xFF0096C7).withOpacity(0.65),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.6),
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    _breathPhase,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: _enterProgram,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF48CAE4).withOpacity(0.22),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            side: const BorderSide(
                              color: Color(0xFF90E0EF),
                              width: 1.2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Vstoupit do 30denního kalendáře',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OceanWavesPainter extends CustomPainter {
  final double animationValue;
  _OceanWavesPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    _drawWave(
      canvas,
      size,
      baseHeight: size.height * 0.62,
      amplitude: 16,
      frequency: 1.4,
      phase: animationValue * 2 * math.pi,
      color: const Color(0xFF48CAE4).withOpacity(0.14),
    );
    _drawWave(
      canvas,
      size,
      baseHeight: size.height * 0.68,
      amplitude: 22,
      frequency: 1.1,
      phase: -animationValue * 2 * math.pi + 1.2,
      color: const Color(0xFF00B4D8).withOpacity(0.18),
    );
    _drawWave(
      canvas,
      size,
      baseHeight: size.height * 0.75,
      amplitude: 14,
      frequency: 1.8,
      phase: animationValue * 2 * math.pi + 2.5,
      color: const Color(0xFF90E0EF).withOpacity(0.12),
    );
  }

  void _drawWave(
    Canvas canvas,
    Size size, {
    required double baseHeight,
    required double amplitude,
    required double frequency,
    required double phase,
    required Color color,
  }) {
    final paint = Paint()..color = color;
    final path = Path()..moveTo(0, size.height);

    for (double x = 0; x <= size.width; x += 4) {
      final y = baseHeight +
          math.sin((x / size.width * 2 * math.pi * frequency) + phase) *
              amplitude;
      path.lineTo(x, y);
    }

    path
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _OceanWavesPainter oldDelegate) => true;
}
