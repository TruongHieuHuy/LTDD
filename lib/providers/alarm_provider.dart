import 'package:flutter/material.dart';
import '../models/alarm_model.dart';
import '../utils/database_service.dart';

class AlarmProvider with ChangeNotifier {
  List<AlarmModel> _alarms = [];

  List<AlarmModel> get alarms => _alarms;
  List<AlarmModel> get enabledAlarms =>
      _alarms.where((alarm) => alarm.isEnabled).toList();

  AlarmProvider() {
    loadAlarms();
  }

  Future<void> loadAlarms() async {
    _alarms = DatabaseService.getAllAlarms();
    notifyListeners();
  }

  Future<void> addAlarm(AlarmModel alarm) async {
    await DatabaseService.saveAlarm(alarm);
    await loadAlarms();
  }

  Future<void> updateAlarm(AlarmModel alarm) async {
    await DatabaseService.updateAlarm(alarm);
    await loadAlarms();
  }

  Future<void> toggleAlarm(String id) async {
    final alarm = _alarms.firstWhere((a) => a.id == id);
    alarm.isEnabled = !alarm.isEnabled;
    await DatabaseService.updateAlarm(alarm);
    await loadAlarms();
  }

  Future<void> deleteAlarm(String id) async {
    await DatabaseService.deleteAlarm(id);
    await loadAlarms();
  }

  String? getNextAlarmTime() {
    final enabled = enabledAlarms;
    if (enabled.isEmpty) return null;
    return enabled.first.time;
  }
}
