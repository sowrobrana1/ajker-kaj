import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class AppData {
  List<Task> tasks = [];
  List<Habit> habits = [];
  List<Expense> expenses = [];
  List<ReminderItem> reminders = [];
  List<SavingsGoal> goals = [];
  bool darkMode = false;
  String language = 'bn';
  double monthlyBudget = 0;

  // Carry yesterday's unfinished, non-recurring tasks forward is handled
  // by the app on startup (see carryForward in main).
  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    tasks = _decode<Task>(p.getString('tasks'), Task.fromJson);
    habits = _decode<Habit>(p.getString('habits'), Habit.fromJson);
    expenses = _decode<Expense>(p.getString('expenses'), Expense.fromJson);
    reminders =
        _decode<ReminderItem>(p.getString('reminders'), ReminderItem.fromJson);
    goals = _decode<SavingsGoal>(p.getString('goals'), SavingsGoal.fromJson);
    darkMode = p.getBool('darkMode') ?? false;
    language = p.getString('language') ?? 'bn';
    monthlyBudget = p.getDouble('monthlyBudget') ?? 0;
    if (tasks.isEmpty && habits.isEmpty && expenses.isEmpty) {
      _seed();
    }
  }

  void _seed() {
    final t = todayKey();
    tasks = [
      Task(id: 's1', title: 'সকালের ব্যায়াম', date: t, time: '07:00', done: true, category: 'স্বাস্থ্য'),
      Task(id: 's2', title: 'বিদ্যুৎ বিল দেওয়া', date: t, time: '09:00', done: true, category: 'বিল'),
      Task(id: 's3', title: 'বাজার করা', date: t, time: '17:00', category: 'বাজার'),
      Task(id: 's4', title: 'মাসের খরচ আপডেট', date: t, time: '20:00', category: 'হিসাব'),
      Task(id: 's5', title: 'আগামীকালের পরিকল্পনা', date: t, time: '21:00', category: 'পরিকল্পনা'),
    ];
    habits = [
      Habit(id: 'h1', title: 'সকালের ব্যায়াম'),
      Habit(id: 'h2', title: 'বই পড়া'),
    ];
  }

  List<T> _decode<T>(String? raw, T Function(Map<String, dynamic>) f) {
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => f(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('tasks', encodeList(tasks));
    await p.setString('habits', encodeList(habits));
    await p.setString('expenses', encodeList(expenses));
    await p.setString('reminders', encodeList(reminders));
    await p.setString('goals', encodeList(goals));
    await p.setBool('darkMode', darkMode);
    await p.setString('language', language);
    await p.setDouble('monthlyBudget', monthlyBudget);
  }

  String exportJson() {
    return jsonEncode({
      'tasks': tasks.map((e) => e.toJson()).toList(),
      'habits': habits.map((e) => e.toJson()).toList(),
      'expenses': expenses.map((e) => e.toJson()).toList(),
      'reminders': reminders.map((e) => e.toJson()).toList(),
      'goals': goals.map((e) => e.toJson()).toList(),
    });
  }

  List<Task> tasksForDate(String date) =>
      tasks.where((t) => t.date == date).toList();

  List<Task> todayTasks() => tasksForDate(todayKey());

  int completedToday() => todayTasks().where((t) => t.done).length;

  double todayExpenseTotal() => expenses
      .where((e) => e.date == todayKey() && e.type == 'expense')
      .fold(0, (a, e) => a + e.amount);

  double monthExpenseTotal() {
    final n = DateTime.now();
    final prefix = '${n.year}-${n.month.toString().padLeft(2, '0')}';
    return expenses
        .where((e) => e.date.startsWith(prefix) && e.type == 'expense')
        .fold(0, (a, e) => a + e.amount);
  }

  double monthIncomeTotal() {
    final n = DateTime.now();
    final prefix = '${n.year}-${n.month.toString().padLeft(2, '0')}';
    return expenses
        .where((e) => e.date.startsWith(prefix) && e.type == 'income')
        .fold(0, (a, e) => a + e.amount);
  }
}
