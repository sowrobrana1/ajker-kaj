import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'models.dart';
import 'state.dart';
import 'widgets.dart';
import 'lang.dart';

class SettingsPage extends StatefulWidget {
  final AppState state;
  const SettingsPage({super.key, required this.state});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final budgetCtrl = TextEditingController(
      text: widget.state.data.monthlyBudget > 0
          ? widget.state.data.monthlyBudget.toStringAsFixed(0)
          : '');

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final d = state.data;
    final lang = d.language;
    // Weekly review: last 7 days.
    final now = DateTime.now();
    var weekDone = 0;
    var weekTotal = 0;
    var weekExp = 0.0;
    for (var i = 0; i < 7; i++) {
      final k = dateKey(now.subtract(Duration(days: i)));
      final ts = d.tasksForDate(k);
      weekTotal += ts.length;
      weekDone += ts.where((t) => t.done).length;
      weekExp += d.expenses
          .where((e) => e.date == k && e.type == 'expense')
          .fold(0.0, (a, e) => a + e.amount);
    }

    return Scaffold(
      appBar: AppBar(title: Text(tr(lang, 'settings'))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SwitchListTile(
            title: Text(tr(lang, 'darkMode')),
            value: d.darkMode,
            activeColor: primaryGreen,
            onChanged: (v) async {
              d.darkMode = v;
              await state.save();
              setState(() {});
            },
          ),
          ListTile(
            title: Text(tr(lang, 'language')),
            subtitle: Text(lang == 'bn' ? 'বাংলা' : 'English'),
            trailing: DropdownButton<String>(
              value: lang,
              items: const [
                DropdownMenuItem(value: 'bn', child: Text('বাংলা')),
                DropdownMenuItem(value: 'en', child: Text('English')),
              ],
              onChanged: (v) async {
                if (v == null) return;
                d.language = v;
                await state.save();
                setState(() {});
              },
            ),
          ),
          const Divider(),
          TextField(
            controller: budgetCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: tr(lang, 'budget'),
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (v) async {
              d.monthlyBudget = double.tryParse(v.trim()) ?? 0;
              await state.save();
            },
          ),
          const SizedBox(height: 20),
          Text(tr(lang, 'weeklyReview'),
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              title: Text('গত ৭ দিন: $weekDone/$weekTotal কাজ শেষ'),
              subtitle: Text('খরচ: ৳ ${weekExp.toStringAsFixed(0)}'),
            ),
          ),
          const SizedBox(height: 20),
          Text(tr(lang, 'savingsGoals'),
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...d.goals.map((g) {
            final p = g.target > 0 ? g.saved / g.target : 0.0;
            return Card(
              child: ListTile(
                title: Text(g.title),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        '৳ ${g.saved.toStringAsFixed(0)} / ৳ ${g.target.toStringAsFixed(0)}'),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: p > 1 ? 1 : p,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          primaryGreen),
                    ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_rounded,
                          color: primaryGreen),
                      onPressed: () async {
                        final c = TextEditingController();
                        final v = await showDialog<String>(
                          context: context,
                          builder: (dctx) => AlertDialog(
                            title: const Text('কত জমালে?'),
                            content: TextField(
                              controller: c,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: 'টাকার অংক',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(dctx),
                                child: const Text('বাতিল'),
                              ),
                              FilledButton(
                                onPressed: () =>
                                    Navigator.pop(dctx, c.text),
                                child: const Text('যোগ করো'),
                              ),
                            ],
                          ),
                        );
                        if (v != null) {
                          g.saved += double.tryParse(v.trim()) ?? 0;
                          await state.save();
                          setState(() {});
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: Colors.red),
                      onPressed: () async {
                        d.goals.removeWhere((e) => e.id == g.id);
                        await state.save();
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
          OutlinedButton.icon(
            onPressed: () async {
              final titleC = TextEditingController();
              final targetC = TextEditingController();
              final ok = await showDialog<bool>(
                context: context,
                builder: (dctx) => AlertDialog(
                  title: const Text('নতুন সেভিংস গোল'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: titleC,
                        decoration: const InputDecoration(
                          hintText: 'যেমন: নতুন ফোন',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: targetC,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'লক্ষ্য টাকা',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(dctx, false),
                      child: const Text('বাতিল'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(dctx, true),
                      child: const Text('যোগ করো'),
                    ),
                  ],
                ),
              );
              if (ok == true && titleC.text.trim().isNotEmpty) {
                d.goals.add(SavingsGoal(
                  id: state.newId(),
                  title: titleC.text.trim(),
                  target: double.tryParse(targetC.text.trim()) ?? 0,
                ));
                await state.save();
                setState(() {});
              }
            },
            icon: const Icon(Icons.savings_rounded),
            label: const Text('গোল যোগ করো'),
          ),
          const SizedBox(height: 20),
          Text(tr(lang, 'templates'),
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _templateChip('বাজার ডে', ['বাজার করা', 'মাছ-মাংস কেনা', 'ফল কেনা', 'বিল দেওয়া']),
              _templateChip('অফিস ডে', ['মিটিং প্রস্তুতি', 'ইমেইল চেক', 'রিপোর্ট লেখা', 'আগামীকালের পরিকল্পনা']),
              _templateChip('পড়া ডে', ['বই পড়া ১ ঘণ্টা', 'নোট লেখা', 'রিভিশন', 'পরীক্ষার প্রস্তুতি']),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () async {
              await Share.share(state.data.exportJson(),
                  subject: 'Ajker Kaj backup');
            },
            icon: const Icon(Icons.ios_share_rounded),
            label: Text(tr(lang, 'export')),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: Text(tr(lang, 'about')),
            subtitle: const Text('Ajker Kaj • Version 2.0.0'),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _templateChip(String name, List<String> items) {
    return ActionChip(
      label: Text(name),
      onPressed: () async {
        final t = todayKey();
        for (final title in items) {
          widget.state.data.tasks.add(Task(
            id: widget.state.newId(),
            title: title,
            date: t,
            category: 'পরিকল্পনা',
          ));
        }
        await widget.state.save();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$name লোড হয়েছে')),
          );
        }
      },
    );
  }
}
