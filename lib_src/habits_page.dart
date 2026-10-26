import 'package:flutter/material.dart';
import 'models.dart';
import 'state.dart';
import 'widgets.dart';

class HabitsPage extends StatelessWidget {
  final AppState state;
  const HabitsPage({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final today = todayKey();
    final habits = state.data.habits;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 10),
        const Text('অভ্যাস ট্র্যাকার',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
        const SizedBox(height: 7),
        const Text('প্রতিদিনের ভালো অভ্যাস ধরে রাখো, স্ট্রিক গড়ে তোলো।',
            style: TextStyle(fontSize: 14, color: mutedText)),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () {
            final ctrl = TextEditingController();
            showDialog(
              context: context,
              builder: (dctx) => AlertDialog(
                title: const Text('নতুন অভ্যাস'),
                content: TextField(
                  controller: ctrl,
                  decoration: const InputDecoration(
                    hintText: 'যেমন: সকালের ব্যায়াম, বই পড়া',
                    border: OutlineInputBorder(),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dctx),
                    child: const Text('বাতিল'),
                  ),
                  FilledButton(
                    onPressed: () async {
                      final t = ctrl.text.trim();
                      if (t.isEmpty) return;
                      state.data.habits.add(
                          Habit(id: state.newId(), title: t));
                      await state.save();
                      if (context.mounted) Navigator.pop(dctx);
                    },
                    child: const Text('যোগ করো'),
                  ),
                ],
              ),
            );
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('নতুন অভ্যাস যোগ করো'),
        ),
        const SizedBox(height: 20),
        if (habits.isEmpty)
          const Text('কোনো অভ্যাস যোগ করা হয়নি।',
              style: TextStyle(color: mutedText)),
        ...habits.map((h) {
          final doneToday = h.doneDates.contains(today);
          final streak = h.streak();
          return Card(
            child: ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: doneToday ? lightGreen : pageBg,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  doneToday
                      ? Icons.local_fire_department_rounded
                      : Icons.check_circle_outline_rounded,
                  color: doneToday ? Colors.orange : mutedText,
                ),
              ),
              title: Text(h.title),
              subtitle: Text(streak > 0
                  ? '🔥 $streak দিনের স্ট্রিক • মোট ${h.doneDates.length} দিন'
                  : 'মোট ${h.doneDates.length} দিন'),
              trailing: Checkbox(
                value: doneToday,
                activeColor: primaryGreen,
                onChanged: (_) => state.toggleHabit(h),
              ),
            ),
          );
        }),
        const SizedBox(height: 90),
      ],
    );
  }
}
