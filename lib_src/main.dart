import 'package:flutter/material.dart';
import 'state.dart';
import 'widgets.dart';
import 'home.dart';
import 'calendar_page.dart';
import 'reminders_page.dart';
import 'expenses_page.dart';
import 'habits_page.dart';
import 'lang.dart';

void main() {
  runApp(const AjkerKajApp());
}

class AjkerKajApp extends StatefulWidget {
  const AjkerKajApp({super.key});
  @override
  State<AjkerKajApp> createState() => _AjkerKajAppState();
}

class _AjkerKajAppState extends State<AjkerKajApp> {
  final AppState state = AppState();

  @override
  void initState() {
    super.initState();
    state.init();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        return MaterialApp(
          title: 'Ajker Kaj',
          debugShowCheckedModeBanner: false,
          themeMode:
              state.data.darkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            scaffoldBackgroundColor: pageBg,
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryGreen,
              primary: primaryGreen,
              surface: Colors.white,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: primaryGreen,
              primary: primaryGreen,
              brightness: Brightness.dark,
            ),
          ),
          home: state.loaded
              ? MainPage(state: state)
              : const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
        );
      },
    );
  }
}

class MainPage extends StatefulWidget {
  final AppState state;
  const MainPage({super.key, required this.state});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final lang = widget.state.data.language;
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: selectedTab,
          children: [
            HomePage(
                state: widget.state,
                goTab: (i) => setState(() => selectedTab = i)),
            CalendarPage(state: widget.state),
            RemindersPage(state: widget.state),
            ExpensesPage(state: widget.state),
            HabitsPage(state: widget.state),
          ],
        ),
      ),
      floatingActionButton: selectedTab == 0
          ? FloatingActionButton.extended(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => TaskEditDialog(state: widget.state),
              ),
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: Text(tr(lang, 'newTask')),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: (index) {
          setState(() => selectedTab = index);
        },
        indicatorColor: lightGreen,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: tr(lang, 'home'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_month_outlined),
            selectedIcon: const Icon(Icons.calendar_month_rounded),
            label: tr(lang, 'calendar'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.notifications_none_rounded),
            selectedIcon: const Icon(Icons.notifications_rounded),
            label: tr(lang, 'reminders'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: const Icon(Icons.account_balance_wallet_rounded),
            label: tr(lang, 'expenses'),
          ),
          NavigationDestination(
            icon: const Icon(Icons.check_circle_outline_rounded),
            selectedIcon: const Icon(Icons.check_circle_rounded),
            label: tr(lang, 'habits'),
          ),
        ],
      ),
    );
  }
}
