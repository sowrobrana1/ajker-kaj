import 'package:flutter/material.dart';
import 'models.dart';
import 'storage.dart';
import 'notifications.dart';

class AppState extends ChangeNotifier {
  final AppData data = AppData();
  bool loaded = false;
  String searchQuery = '';

  Future<void> init() async {
    await data.load();
    _carryForward();
    await NotifyService.init();
    await NotifyService.rescheduleAll(data.tasks);
    loaded = true;
    notifyListeners();
  }

  // Yesterday's unfinished tasks move to today (auto-carry).
  void _carryForward() {
    final today = todayKey();
    var changed = false;
    for (final t in data.tasks) {
      if (!t.done && t.date != today && t.recurring == 'none') {
        // Only carry tasks from the last 7 days to avoid ancient clutter.
        try {
          final d = parseKey(t.date);
          if (DateTime.now().difference(d).inDays <= 7) {
            t.date = today;
            changed = true;
          }
        } catch (_) {}
      }
    }
    if (changed) data.save();
  }

  Future<void> save() async {
    await data.save();
    notifyListeners();
  }

  Future<void> addTask(Task t) async {
    data.tasks.add(t);
    await NotifyService.scheduleTask(t);
    await save();
  }

  Future<void> updateTask(Task t) async {
    await NotifyService.cancelTask(t);
    if (!t.done) await NotifyService.scheduleTask(t);
    await save();
  }

  Future<void> deleteTask(Task t) async {
    await NotifyService.cancelTask(t);
    data.tasks.removeWhere((e) => e.id == t.id);
    await save();
  }

  Future<void> toggleTask(Task t, bool v) async {
    t.done = v;
    await updateTask(t);
  }

  Future<void> toggleHabit(Habit h) async {
    final k = todayKey();
    if (h.doneDates.contains(k)) {
      h.doneDates.remove(k);
    } else {
      h.doneDates.add(k);
    }
    await save();
  }

  String newId() => DateTime.now().microsecondsSinceEpoch.toString();
}
