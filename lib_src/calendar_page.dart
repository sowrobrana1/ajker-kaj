import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'models.dart';
import 'state.dart';
import 'widgets.dart';

class CalendarPage extends StatefulWidget {
  final AppState state;
  const CalendarPage({super.key, required this.state});
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime focused = DateTime.now();
  DateTime? selected;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final sel = selected ?? DateTime.now();
    final selKey = dateKey(sel);
    final dayTasks = state.data.tasksForDate(selKey)
      ..sort((a, b) => a.time.compareTo(b.time));
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TableCalendar<Task>(
            firstDay: DateTime(2020),
            lastDay: DateTime(2035),
            focusedDay: focused,
            selectedDayPredicate: (d) => isSameDay(d, sel),
            eventLoader: (d) => state.data.tasksForDate(dateKey(d)),
            calendarFormat: CalendarFormat.month,
            onDaySelected: (s, f) => setState(() {
              selected = s;
              focused = f;
            }),
            onPageChanged: (f) => focused = f,
            headerStyle: const HeaderStyle(formatButtonVisible: false),
            calendarStyle: CalendarStyle(
              markerDecoration: const BoxDecoration(
                color: primaryGreen,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: primaryGreen.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              selectedDecoration: const BoxDecoration(
                color: primaryGreen,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text('$selKey তারিখের কাজ',
            style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        if (dayTasks.isEmpty)
          const Text('এই তারিখে কোনো কাজ নেই।',
              style: TextStyle(color: mutedText)),
        ...dayTasks.map((t) => TaskTile(task: t, state: state)),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: () => showDialog(
            context: context,
            builder: (_) =>
                TaskEditDialog(state: state, initialDate: selKey),
          ),
          icon: const Icon(Icons.add_rounded),
          label: const Text('এই তারিখে কাজ যোগ করো'),
        ),
        const SizedBox(height: 90),
      ],
    );
  }
}
