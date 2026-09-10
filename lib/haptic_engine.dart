import 'package:flutter/services.dart';

enum HapticPatternType {
  slowWave,
  deepSigh,
  groundPulse,
  boxBreath,
  general,
}

class HapticEngine {
  static Future<void> playPattern(String patternName) async {
    switch (patternName) {
      case 'DEEP_SIGH':
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 150));
        await HapticFeedback.mediumImpact();
        break;

      case 'BOX_BREATH':
        await HapticFeedback.selectionClick();
        break;

      case 'GROUND_PULSE':
        await HapticFeedback.heavyImpact();
        break;

      case 'SLOW_WAVE':
      default:
        await HapticFeedback.lightImpact();
        break;
    }
  }
}
