import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Klíč, pod kterým se ukládají dokončené dny (JSON pole Day_ID).
const String kCompletedDaysKey = 'neuroflow_completed_days_v1';

/// Kam se uloží poškozená hodnota, aby se nic tiše nepřepsalo.
const String kCorruptBackupKey = 'neuroflow_completed_days_v1_damaged_backup';

class LotusMilestone {
  final int days;
  final String name;
  const LotusMilestone(this.days, this.name);
}

const List<LotusMilestone> lotusMilestones = [
  LotusMilestone(3, 'Poupě klidu'),
  LotusMilestone(7, 'Tyrkysový lotos'),
  LotusMilestone(15, 'Zlatý lotos'),
  LotusMilestone(30, 'Mistr klidné mysli'),
];

/// Nejvyšší dosažený milník při daném počtu lotosů, nebo null před prvním.
LotusMilestone? currentLotusMilestone(int lotusCount) {
  LotusMilestone? reached;
  for (final m in lotusMilestones) {
    if (lotusCount >= m.days) reached = m;
  }
  return reached;
}

class LotusProgressStore {
  final SharedPreferences _prefs;

  LotusProgressStore(this._prefs);

  static Future<LotusProgressStore> open() async {
    return LotusProgressStore(await SharedPreferences.getInstance());
  }

  /// Všechny dokončené dny. Poškozená hodnota se uloží pod [kCorruptBackupKey].
  Set<String> loadCompleted() {
    final raw = _prefs.getString(kCompletedDaysKey);
    if (raw == null) return <String>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        throw const FormatException('Stored value is not a list.');
      }
      return decoded.whereType<String>().where((id) => id.isNotEmpty).toSet();
    } catch (_) {
      if (!_prefs.containsKey(kCorruptBackupKey)) {
        unawaited(_prefs.setString(kCorruptBackupKey, raw));
      }
      return <String>{};
    }
  }

  /// Přidá [dayId] jen jednou. Vrátí true, jen pokud byl den opravdu nově přidán.
  Future<bool> markCompleted(String dayId) async {
    if (dayId.isEmpty) return false;
    final current = loadCompleted();
    if (current.contains(dayId)) return false;
    final updated = [...current, dayId]..sort();
    await _prefs.setString(kCompletedDaysKey, jsonEncode(updated));
    return true;
  }
}
