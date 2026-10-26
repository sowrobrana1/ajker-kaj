import 'package:flutter/material.dart';
import 'models.dart';
import 'state.dart';
import 'widgets.dart';

class ExpensesPage extends StatelessWidget {
  final AppState state;
  const ExpensesPage({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final d = state.data;
    final monthExp = d.monthExpenseTotal();
    final monthInc = d.monthIncomeTotal();
    final budget = d.monthlyBudget;
    final budgetUsed = budget > 0 ? monthExp / budget : 0.0;
    final items = [...d.expenses]
      ..sort((a, b) => b.date.compareTo(a.date));
    // Last 7 days totals for the mini chart.
    final now = DateTime.now();
    final last7 = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final k = dateKey(day);
      final total = d.expenses
          .where((e) => e.date == k && e.type == 'expense')
          .fold(0.0, (a, e) => a + e.amount);
      return total;
    });
    final max7 = last7.fold(0.0, (a, b) => b > a ? b : a);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 10),
        const Text('খরচের হিসাব',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _statCard('এই মাসে আয়', '৳ ${monthInc.toStringAsFixed(0)}',
                  Colors.green),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard('এই মাসে খরচ', '৳ ${monthExp.toStringAsFixed(0)}',
                  Colors.red),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (budget > 0)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    'মাসিক বাজেট: ৳ ${budget.toStringAsFixed(0)}  •  ব্যবহার: ${(budgetUsed * 100).round()}%'),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: budgetUsed > 1 ? 1 : budgetUsed,
                    minHeight: 10,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      budgetUsed >= 0.8 ? Colors.red : primaryGreen,
                    ),
                  ),
                ),
                if (budgetUsed >= 0.8)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('সতর্কতা: বাজেটের ৮০% পার হয়ে গেছে!',
                        style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('গত ৭ দিনের খরচ',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              SizedBox(
                height: 100,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (i) {
                    final h = max7 > 0 ? (last7[i] / max7) * 80 : 0.0;
                    return Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(last7[i] > 0
                              ? last7[i].toStringAsFixed(0)
                              : ''),
                          const SizedBox(height: 4),
                          Container(
                            height: h + 4,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: primaryGreen,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () => showDialog(
            context: context,
            builder: (_) => ExpenseDialog(state: state),
          ),
          icon: const Icon(Icons.add_rounded),
          label: const Text('আয়/খরচ যোগ করো'),
        ),
        const SizedBox(height: 20),
        if (items.isEmpty)
          const Text('কোনো এন্ট্রি নেই।',
              style: TextStyle(color: mutedText)),
        ...items.take(50).map((e) => Card(
              child: ListTile(
                leading: Icon(
                  e.type == 'income'
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  color: e.type == 'income' ? Colors.green : Colors.red,
                ),
                title: Text(e.title),
                subtitle: Text('${e.date} • ${e.category}'),
                trailing: Text(
                  '${e.type == 'income' ? '+' : '-'}৳ ${e.amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color:
                        e.type == 'income' ? Colors.green : Colors.red,
                  ),
                ),
              ),
            )),
        const SizedBox(height: 90),
      ],
    );
  }

  Widget _statCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: mutedText, fontSize: 12)),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}

class ExpenseDialog extends StatefulWidget {
  final AppState state;
  const ExpenseDialog({super.key, required this.state});
  @override
  State<ExpenseDialog> createState() => _ExpenseDialogState();
}

class _ExpenseDialogState extends State<ExpenseDialog> {
  final titleCtrl = TextEditingController();
  final amountCtrl = TextEditingController();
  String type = 'expense';
  String category = 'অন্যান্য';
  String date = todayKey();
  final categories = ['খাবার', 'বাজার', 'যাতায়াত', 'বিল', 'বেতন', 'ব্যবসা', 'অন্যান্য'];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('আয়/খরচ যোগ করো'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                hintText: 'যেমন: বাজার, বেতন',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'টাকার অংক',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: type,
              decoration: const InputDecoration(
                  labelText: 'ধরন', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'expense', child: Text('খরচ')),
                DropdownMenuItem(value: 'income', child: Text('আয়')),
              ],
              onChanged: (v) => setState(() => type = v ?? 'expense'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: category,
              decoration: const InputDecoration(
                  labelText: 'ক্যাটাগরি', border: OutlineInputBorder()),
              items: categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => category = v ?? 'অন্যান্য'),
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
            final amount = double.tryParse(amountCtrl.text.trim()) ?? 0;
            if (title.isEmpty || amount <= 0) return;
            widget.state.data.expenses.add(Expense(
              id: widget.state.newId(),
              title: title,
              amount: amount,
              type: type,
              date: date,
              category: category,
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
