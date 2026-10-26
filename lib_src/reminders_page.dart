import 'package:flutter/material.dart';
import 'models.dart';
import 'state.dart';
import 'widgets.dart';

String kindLabel(String k) {
  switch (k) {
    case 'birthday':
      return 'জন্মদিন';
    case 'exam':
      return 'পরীক্ষা/ডেডলাইন';
    case 'document':
      return 'ডকুমেন্ট মেয়াদ';
    default:
      return 'বিল';
  }
}

IconData kindIcon(String k) {
  switch (k) {
    case 'birthday':
      return Icons.cake_rounded;
    case 'exam':
      return Icons.school_rounded;
    case 'document':
      return Icons.badge_rounded;
    default:
      return Icons.receipt_long_rounded;
  }
}

class RemindersPage extends StatelessWidget {
  final AppState state;
  const RemindersPage({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final items = [...state.data.reminders]
      ..sort((a, b) => a.date.compareTo(b.date));
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 10),
        const Text('রিমাইন্ডার',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
        const SizedBox(height: 7),
        const Text('বিল, জন্মদিন, ডকুমেন্ট মেয়াদ আর পরীক্ষার তারিখ — কিছুই ভুল হবে না।',
            style: TextStyle(fontSize: 14, color: mutedText)),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () => showDialog(
            context: context,
            builder: (_) => ReminderDialog(state: state),
          ),
          icon: const Icon(Icons.add_rounded),
          label: const Text('নতুন রিমাইন্ডার যোগ করো'),
        ),
        const SizedBox(height: 20),
        if (items.isEmpty)
          const Text('কোনো রিমাইন্ডার নেই।',
              style: TextStyle(color: mutedText)),
        ...items.map((r) {
          var daysLeft = '';
          try {
            final d = parseKey(r.date);
            final diff =
                d.difference(DateTime.now()).inDays;
            daysLeft = diff < 0
                ? 'মেয়াদ পার হয়ে গেছে'
                : diff == 0
                    ? 'আজ!'
                    : '$diff দিন বাকি';
          } catch (_) {}
          return Card(
            child: ListTile(
              leading: Icon(kindIcon(r.kind), color: primaryGreen),
              title: Text(r.title),
              subtitle: Text(
                  '${kindLabel(r.kind)} • ${r.date} • $daysLeft${r.amount > 0 ? ' • ৳${r.amount.toStringAsFixed(0)}' : ''}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    color: Colors.red),
                onPressed: () async {
                  state.data.reminders
                      .removeWhere((e) => e.id == r.id);
                  await state.save();
                },
              ),
            ),
          );
        }),
        const SizedBox(height: 90),
      ],
    );
  }
}

class ReminderDialog extends StatefulWidget {
  final AppState state;
  const ReminderDialog({super.key, required this.state});
  @override
  State<ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<ReminderDialog> {
  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  String kind = 'bill';
  String date = todayKey();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('নতুন রিমাইন্ডার'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                hintText: 'যেমন: বিদ্যুৎ বিল, মায়ের জন্মদিন',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: kind,
              decoration: const InputDecoration(
                  labelText: 'ধরন', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'bill', child: Text('বিল')),
                DropdownMenuItem(value: 'birthday', child: Text('জন্মদিন')),
                DropdownMenuItem(value: 'document', child: Text('ডকুমেন্ট মেয়াদ')),
                DropdownMenuItem(value: 'exam', child: Text('পরীক্ষা/ডেডলাইন')),
              ],
              onChanged: (v) => setState(() => kind = v ?? 'bill'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'টাকার অংক (যদি থাকে)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: Text('তারিখ: $date')),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: parseKey(date),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) {
                      setState(() => date = dateKey(picked));
                    }
                  },
                  child: const Text('বদলাও'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('বাতিল'),
        ),
        FilledButton(
          onPressed: () async {
            final title = titleCtrl.text.trim();
            if (title.isEmpty) return;
            widget.state.data.reminders.add(ReminderItem(
              id: widget.state.newId(),
              title: title,
              date: date,
              kind: kind,
              amount: double.tryParse(amountCtrl.text.trim()) ?? 0,
            ));
            await widget.state.save();
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('যোগ করো'),
        ),
      ],
    );
  }
}
