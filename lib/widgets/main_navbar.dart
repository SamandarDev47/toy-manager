import 'package:flutter/material.dart';
import '../pages/add_page.dart';
import '../pages/chat/chat_page.dart';
import '../pages/home_page.dart';
import '../pages/profile/profile_settings_page.dart';
import '../pages/stats_page.dart';
import '../services/firebase_services.dart';
import '../theme/app_theme.dart';

class MainNavBar extends StatefulWidget {
  const MainNavBar({super.key});

  @override
  State<MainNavBar> createState() => _MainNavBarState();
}

class _MainNavBarState extends State<MainNavBar> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    FirebaseService().saveUserToken();
    FirebaseService().archivePastWeddings();
  }

  @override
  Widget build(BuildContext context) {
    final pages = const [HomePage(), AddPage(), ChatPage(), StatsPage(), ProfileSettingsPage()];
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppTheme.stroke),
            boxShadow: AppTheme.softShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (value) => setState(() => _index = value),
            destinations: const [
              NavigationDestination(icon: Icon(Icons.event_available_outlined), selectedIcon: Icon(Icons.event_available), label: 'To‘ylar'),
              NavigationDestination(icon: Icon(Icons.add_circle_outline), selectedIcon: Icon(Icons.add_circle), label: 'Yangi'),
              NavigationDestination(icon: Icon(Icons.chat_bubble_outline), selectedIcon: Icon(Icons.chat_bubble), label: 'Chat'),
              NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Stat'),
              NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
            ],
          ),
        ),
      ),
    );
  }
}
