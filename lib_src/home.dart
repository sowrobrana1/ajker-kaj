import 'package:flutter/material.dart';
import 'models.dart';
import 'state.dart';
import 'widgets.dart';
import 'lang.dart';
import 'bangla_date.dart';
import 'settings_page.dart';

class HomePage extends StatelessWidget {
  final AppState state;
  final void Function(int) goTab;
  const HomePage({super.key, required this.state, required this.goTab});

  @override
  Widget build(BuildContext context) {
    final lang = state.data.language;
    final today = state.data.todayTasks();
    final done = today.where((t) => t.done).length;
    final progress = today.isEmpty ? 0.0 : done / today.length;
    final now = DateTime.now();
    final query = state.searchQuery.toLowerCase();
    final visible = query.isEmpty
        ? today
        : today
            .where((t) => t.title.toLowerCase().contains(query))
            .toList();
    final upcoming = state.data.reminders
        .where((r) {
          try {
            final d = parseKey(r.date);
            return !d.isBefore(DateTime(now.year, now.month, now.day));
          } catch (_) {
            return false;
          }
        })
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: primaryGreen,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(Icons.checklist_rounded,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Ajker Kaj',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w800)),
                        Text(tr(lang, 'appTag'),
                            style: const TextStyle(
                                color: mutedText, fontSize: 11)),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => SettingsPage(state: state)),
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).cardColor,
                    ),
                    icon: const Icon(Icons.settings_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('শুভ দিন! 👋',
                  style:
                      TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
              const SizedBox(height: 5),
              Text(
                '${banglaDateString(now)} • আজকের দিনটি গুছিয়ে নাও',
                style: const TextStyle(fontSize: 13, color: mutedText),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: tr(lang, 'search'),
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                  filled: true,
                ),
                onChanged: (v) {
                  state.searchQuery = v;
                  state.save();
                },
              ),
              const SizedBox(height: 20),
              _progressCard(done, today.length, progress),
              const SizedBox(height: 26),
              _header(tr(lang, 'todayTasks'), '$done/${today.length} ${tr(lang, 'done')}'),
              const SizedBox(height: 12),
              if (visible.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('আজকের জন্য কোনো কাজ নেই। + বোতামে নতুন কাজ যোগ করো।',
                      style: TextStyle(color: mutedText)),
                ),
              ...visible.map((t) => TaskTile(task: t, state: state)),
              const SizedBox(height: 22),
              _header(tr(lang, 'upcoming'), ''),
              const SizedBox(height: 12),
              if (upcoming.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('কোনো আসন্ন রিমাইন্ডার নেই।',
                      style: TextStyle(color: mutedText)),
                ),
              ...upcoming.take(3).map((r) => Card(
                    child: ListTile(
                      leading: Icon(
                        r.kind == 'birthday'
                            ? Icons.cake_rounded
                            : r.kind == 'exam'
                                ? Icons.school_rounded
                                : r.kind == 'document'
                                    ? Icons.badge_rounded
                                    : Icons.receipt_long_rounded,
                        color: primaryGreen,
                      ),
                      title: Text(r.title),
                      subtitle: Text(
                          '${r.date}${r.amount > 0 ? ' • ৳${r.amount.toStringAsFixed(0)}' : ''}'),
                    ),
                  )),
              const SizedBox(height: 22),
              _header(tr(lang, 'dailyExpense'), ''),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF0FF),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Color(0xFF5578CF), size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tr(lang, 'todayExpense'),
                              style: const TextStyle(
                                  color: mutedText, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            '৳ ${state.data.todayExpenseTotal().toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => goTab(3),
                      child: const Text('বিস্তারিত'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('ছোট ছোট পদক্ষেপেই বড় অগ্রগতি!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: mutedText, fontSize: 13)),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _header(String title, String trailing) {
    return Row(
      children: [
        Expanded(
          child: Text(title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w800)),
        ),
        if (trailing.isNotEmpty)
          Text(trailing,
              style: const TextStyle(
                  fontSize: 12,
                  color: primaryGreen,
                  fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _progressCard(int done, int total, double progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF168653), Color(0xFF27A66D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('আজকের অগ্রগতি',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w700)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${(progress * 100).round()}%',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text('$done / $total টি কাজ সম্পন্ন হয়েছে',
              style: const TextStyle(color: Color(0xFFE1F7E9), fontSize: 13)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  color: Color(0xFFFFE7A0), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  total > 0 && done == total
                      ? 'দারুণ! সব কাজ শেষ!'
                      : 'চালিয়ে যাও, তুমি ভালো করছ!',
                  style:
                      const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
