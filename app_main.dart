import 'package:flutter/material.dart';

void main() {
  runApp(const AjkerKajApp());
}

const Color primaryGreen = Color(0xFF168653);
const Color lightGreen = Color(0xFFE7F6ED);
const Color pageBg = Color(0xFFF6F8F7);
const Color darkText = Color(0xFF18231D);
const Color mutedText = Color(0xFF7D8982);

class AjkerKajApp extends StatelessWidget {
  const AjkerKajApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ajker Kaj',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: pageBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          primary: primaryGreen,
          surface: Colors.white,
        ),
        fontFamily: 'Roboto',
      ),
      home: const DashboardPage(),
    );
  }
}

class DailyTask {
  DailyTask({
    required this.title,
    required this.time,
    required this.icon,
    this.done = false,
  });

  final String title;
  final String time;
  final IconData icon;
  bool done;
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedTab = 0;

  final List<DailyTask> tasks = [
    DailyTask(
      title: 'সকালের ব্যায়াম',
      time: 'সকাল ৭:০০',
      icon: Icons.fitness_center_rounded,
      done: true,
    ),
    DailyTask(
      title: 'বিদ্যুৎ বিল দেওয়া',
      time: 'সকাল ৯:০০',
      icon: Icons.receipt_long_rounded,
      done: true,
    ),
    DailyTask(
      title: 'বাজার করা',
      time: 'বিকেল ৫:০০',
      icon: Icons.shopping_basket_rounded,
    ),
    DailyTask(
      title: 'মাসের খরচ আপডেট',
      time: 'রাত ৮:০০',
      icon: Icons.account_balance_wallet_rounded,
    ),
    DailyTask(
      title: 'আগামীকালের পরিকল্পনা',
      time: 'রাত ৯:০০',
      icon: Icons.event_note_rounded,
    ),
  ];

  int get completedCount => tasks.where((task) => task.done).length;

  double get progress =>
      tasks.isEmpty ? 0 : completedCount / tasks.length;

  void addTask() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('নতুন কাজ যোগ করো'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'কাজের নাম লিখো',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('বাতিল'),
          ),
          FilledButton(
            onPressed: () {
              final title = controller.text.trim();
              if (title.isEmpty) return;

              setState(() {
                tasks.add(
                  DailyTask(
                    title: title,
                    time: 'সময় নির্ধারণ করা হয়নি',
                    icon: Icons.task_alt_rounded,
                  ),
                );
              });

              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('নতুন কাজ যোগ হয়েছে')),
              );
            },
            child: const Text('যোগ করো'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: selectedTab,
          children: [
            _buildHome(),
            _buildCalendar(),
            _buildReminders(),
            _buildProfile(),
          ],
        ),
      ),
      floatingActionButton: selectedTab == 0
          ? FloatingActionButton.extended(
              onPressed: addTask,
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('নতুন কাজ'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: (index) {
          setState(() => selectedTab = index);
        },
        backgroundColor: Colors.white,
        indicatorColor: lightGreen,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'হোম',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'ক্যালেন্ডার',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none_rounded),
            selectedIcon: Icon(Icons.notifications_rounded),
            label: 'রিমাইন্ডার',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'প্রোফাইল',
          ),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildHeader(),
              const SizedBox(height: 24),
              _buildGreeting(),
              const SizedBox(height: 20),
              _buildProgressCard(),
              const SizedBox(height: 26),
              _buildSectionHeader(
                'আজকের কাজ',
                '$completedCount/${tasks.length} সম্পন্ন',
              ),
              const SizedBox(height: 12),
              ...tasks.map(_buildTaskTile),
              const SizedBox(height: 22),
              _buildSectionHeader('আসন্ন রিমাইন্ডার', 'সবগুলো দেখো'),
              const SizedBox(height: 12),
              _buildReminderCard(),
              const SizedBox(height: 22),
              _buildSectionHeader('দৈনিক হিসাব', 'বিস্তারিত'),
              const SizedBox(height: 12),
              _buildExpenseCard(),
              const SizedBox(height: 16),
              const Text(
                'ছোট ছোট পদক্ষেপেই বড় অগ্রগতি!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: mutedText,
                  fontSize: 13,
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: primaryGreen,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.checklist_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 11),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ajker Kaj',
                style: TextStyle(
                  color: darkText,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'তোমার প্রতিদিন, তোমার পরিকল্পনা',
                style: TextStyle(color: mutedText, fontSize: 11),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: () => setState(() => selectedTab = 2),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: darkText,
          ),
          icon: const Icon(Icons.notifications_none_rounded),
        ),
      ],
    );
  }

  Widget _buildGreeting() {
    final now = DateTime.now();
    const months = [
      'জানুয়ারি', 'ফেব্রুয়ারি', 'মার্চ', 'এপ্রিল',
      'মে', 'জুন', 'জুলাই', 'আগস্ট',
      'সেপ্টেম্বর', 'অক্টোবর', 'নভেম্বর', 'ডিসেম্বর',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'শুভ দিন! 👋',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w800,
            color: darkText,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '${now.day} ${months[now.month - 1]}, ${now.year} • '
          'আজকের দিনটি গুছিয়ে নাও',
          style: const TextStyle(
            fontSize: 13,
            color: mutedText,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF168653), Color(0xFF27A66D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryGreen.withOpacity(0.17),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'আজকের অগ্রগতি',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            '$completedCount / ${tasks.length} টি কাজ সম্পন্ন হয়েছে',
            style: const TextStyle(
              color: Color(0xFFE1F7E9),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 9,
              backgroundColor: Colors.white.withOpacity(0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFFFFE7A0),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  completedCount == tasks.length
                      ? 'দারুণ! সব কাজ শেষ!'
                      : 'চালিয়ে যাও, তুমি ভালো করছ!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String trailing) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: darkText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            if (title == 'আসন্ন রিমাইন্ডার') {
              setState(() => selectedTab = 2);
            } else if (title == 'দৈনিক হিসাব') {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('খরচের বিস্তারিত ফিচার পরে যোগ করা হবে'),
                ),
              );
            }
          },
          child: Text(
            trailing,
            style: const TextStyle(
              fontSize: 12,
              color: primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskTile(DailyTask task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: task.done
              ? const Color(0xFFD8F0E0)
              : const Color(0xFFEDF0EE),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: task.done ? lightGreen : pageBg,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              task.icon,
              color: task.done ? primaryGreen : mutedText,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: task.done ? mutedText : darkText,
                    decoration:
                        task.done ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      size: 13,
                      color: mutedText,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        task.time,
                        style: const TextStyle(
                          fontSize: 11,
                          color: mutedText,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Checkbox(
            value: task.done,
            activeColor: primaryGreen,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            onChanged: (value) {
              setState(() => task.done = value ?? false);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2D9),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              color: Color(0xFFD99520),
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'বাজার করার সময়',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: darkText,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'আজ বিকেল ৫:০০ টা',
                  style: TextStyle(
                    color: mutedText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: mutedText,
          ),
        ],
      ),
    );
  }

  Widget _buildExpenseCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
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
              color: Color(0xFF5578CF),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'আজকের খরচ',
                  style: TextStyle(
                    color: mutedText,
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '৳ ০.০০',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.trending_down_rounded,
              color: primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return _simplePage(
      icon: Icons.calendar_month_rounded,
      title: 'আমার ক্যালেন্ডার',
      subtitle: 'গুরুত্বপূর্ণ তারিখ ও পরিকল্পনা এক জায়গায় রাখো।',
      child: const Text(
        'এখানে পরে মাসভিত্তিক ক্যালেন্ডার ও ইভেন্ট যোগ করা যাবে।',
        textAlign: TextAlign.center,
        style: TextStyle(color: mutedText),
      ),
    );
  }

  Widget _buildReminders() {
    return _simplePage(
      icon: Icons.notifications_active_rounded,
      title: 'রিমাইন্ডার',
      subtitle: 'কোনো গুরুত্বপূর্ণ কাজ ভুলে যেও না।',
      child: Column(
        children: [
          ...tasks.map((task) => _buildTaskTile(task)),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: addTask,
            icon: const Icon(Icons.add),
            label: const Text('নতুন রিমাইন্ডার যোগ করো'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    return _simplePage(
      icon: Icons.person_rounded,
      title: 'আমার প্রোফাইল',
      subtitle: 'তোমার দৈনন্দিন অভ্যাস ও পরিকল্পনা।',
      child: const Column(
        children: [
          ListTile(
            leading: Icon(Icons.language_rounded),
            title: Text('ভাষা'),
            subtitle: Text('বাংলা'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.palette_outlined),
            title: Text('অ্যাপের থিম'),
            subtitle: Text('সবুজ ও সাদা'),
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.info_outline_rounded),
            title: Text('অ্যাপ সম্পর্কে'),
            subtitle: Text('Ajker Kaj • Version 1.0.0'),
          ),
        ],
      ),
    );
  }

  Widget _simplePage({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 20),
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: lightGreen,
            borderRadius: BorderRadius.circular(23),
          ),
          child: Icon(icon, size: 35, color: primaryGreen),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w800,
            color: darkText,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: mutedText,
          ),
        ),
        const SizedBox(height: 25),
        child,
      ],
    );
  }
}
