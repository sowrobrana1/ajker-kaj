import 'dart:convert';

String todayKey() {
  final n = DateTime.now();
  return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
}

String dateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime parseKey(String k) {
  final p = k.split('-');
  return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
}

class SubTask {
  String title;
  bool done;
  SubTask({required this.title, this.done = false});
  Map<String, dynamic> toJson() => {'title': title, 'done': done};
  factory SubTask.fromJson(Map<String, dynamic> j) =>
      SubTask(title: j['title'] ?? '', done: j['done'] == true);
}

class Task {
  String id;
  String title;
  String date; // yyyy-MM-dd
  String time; // HH:mm or ''
  bool done;
  String priority; // high, medium, low
  String category;
  String recurring; // none, daily, weekly
  List<SubTask> subtasks;
  String? imagePath;
  int timeSpentSec;
  Task({
    required this.id,
    required this.title,
    required this.date,
    this.time = '',
    this.done = false,
    this.priority = 'medium',
    this.category = 'কাজ',
    this.recurring = 'none',
    List<SubTask>? subtasks,
    this.imagePath,
    this.timeSpentSec = 0,
  }) : subtasks = subtasks ?? [];
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date,
        'time': time,
        'done': done,
        'priority': priority,
        'category': category,
        'recurring': recurring,
        'subtasks': subtasks.map((s) => s.toJson()).toList(),
        'imagePath': imagePath,
        'timeSpentSec': timeSpentSec,
      };
  factory Task.fromJson(Map<String, dynamic> j) => Task(
        id: j['id'] ?? '',
        title: j['title'] ?? '',
        date: j['date'] ?? todayKey(),
        time: j['time'] ?? '',
        done: j['done'] == true,
        priority: j['priority'] ?? 'medium',
        category: j['category'] ?? 'কাজ',
        recurring: j['recurring'] ?? 'none',
        subtasks: (j['subtasks'] as List? ?? [])
            .map((e) => SubTask.fromJson(e as Map<String, dynamic>))
            .toList(),
        imagePath: j['imagePath'],
        timeSpentSec: j['timeSpentSec'] ?? 0,
      );
}

class Habit {
  String id;
  String title;
  List<String> doneDates;
  Habit({required this.id, required this.title, List<String>? doneDates})
      : doneDates = doneDates ?? [];
  int streak() {
    var count = 0;
    var d = DateTime.now();
    // Streak counts back from today (or yesterday if today not done yet).
    if (!doneDates.contains(dateKey(d))) {
      d = d.subtract(const Duration(days: 1));
    }
    while (doneDates.contains(dateKey(d))) {
      count++;
      d = d.subtract(const Duration(days: 1));
    }
    return count;
  }

  Map<String, dynamic> toJson() =>
      {'id': id, 'title': title, 'doneDates': doneDates};
  factory Habit.fromJson(Map<String, dynamic> j) => Habit(
        id: j['id'] ?? '',
        title: j['title'] ?? '',
        doneDates:
            (j['doneDates'] as List? ?? []).map((e) => e.toString()).toList(),
      );
}

class Expense {
  String id;
  String title;
  double amount;
  String type; // income, expense
  String date;
  String category;
  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    this.category = 'অন্যান্য',
  });
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'type': type,
        'date': date,
        'category': category,
      };
  factory Expense.fromJson(Map<String, dynamic> j) => Expense(
        id: j['id'] ?? '',
        title: j['title'] ?? '',
        amount: (j['amount'] ?? 0).toDouble(),
        type: j['type'] ?? 'expense',
        date: j['date'] ?? todayKey(),
        category: j['category'] ?? 'অন্যান্য',
      );
}

class ReminderItem {
  String id;
  String title;
  String date;
  String kind; // bill, birthday, document, exam
  double amount;
  ReminderItem({
    required this.id,
    required this.title,
    required this.date,
    required this.kind,
    this.amount = 0,
  });
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date,
        'kind': kind,
        'amount': amount,
      };
  factory ReminderItem.fromJson(Map<String, dynamic> j) => ReminderItem(
        id: j['id'] ?? '',
        title: j['title'] ?? '',
        date: j['date'] ?? todayKey(),
        kind: j['kind'] ?? 'bill',
        amount: (j['amount'] ?? 0).toDouble(),
      );
}

class SavingsGoal {
  String id;
  String title;
  double target;
  double saved;
  SavingsGoal(
      {required this.id,
      required this.title,
      required this.target,
      this.saved = 0});
  Map<String, dynamic> toJson() =>
      {'id': id, 'title': title, 'target': target, 'saved': saved};
  factory SavingsGoal.fromJson(Map<String, dynamic> j) => SavingsGoal(
        id: j['id'] ?? '',
        title: j['title'] ?? '',
        target: (j['target'] ?? 0).toDouble(),
        saved: (j['saved'] ?? 0).toDouble(),
      );
}

String encodeList(List<dynamic> items) =>
    jsonEncode(items.map((e) => (e as dynamic).toJson()).toList());
