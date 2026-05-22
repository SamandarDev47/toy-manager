import 'package:flutter/material.dart';
import '../pages/add_page.dart';
import '../pages/chat/chat_page.dart';
import '../pages/home_page.dart';
import '../pages/profile/profile_settings_page.dart';
import '../pages/stats_page.dart';
import '../services/chat_service.dart';
import '../services/firebase_services.dart';
import '../theme/app_theme.dart';

class MainNavBar extends StatefulWidget {
  const MainNavBar({super.key});

  @override
  State<MainNavBar> createState() => _MainNavBarState();
}

class _MainNavBarState extends State<MainNavBar> {
  int _index = 0;
  final ChatService _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    FirebaseService().saveUserToken();
    FirebaseService().archivePastWeddings();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const HomePage(),
      const AddPage(),
      ChatPage(active: _index == 2),
      const StatsPage(),
      const ProfileSettingsPage(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.card(context),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppTheme.line(context)),
            boxShadow: AppTheme.isDark(context) ? null : AppTheme.softShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (value) => setState(() => _index = value),
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.event_available_outlined),
                selectedIcon: Icon(Icons.event_available),
                label: 'To‘ylar',
              ),
              const NavigationDestination(
                icon: Icon(Icons.add_circle_outline),
                selectedIcon: Icon(Icons.add_circle),
                label: 'Yangi',
              ),
              NavigationDestination(
                icon: _ChatIcon(service: _chatService, selected: false),
                selectedIcon: _ChatIcon(service: _chatService, selected: true),
                label: 'Chat',
              ),
              const NavigationDestination(
                icon: Icon(Icons.bar_chart_outlined),
                selectedIcon: Icon(Icons.bar_chart),
                label: 'Stat',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatIcon extends StatelessWidget {
  final ChatService service;
  final bool selected;

  const _ChatIcon({required this.service, required this.selected});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: service.unreadCount(),
      initialData: 0,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(selected ? Icons.chat_bubble : Icons.chat_bubble_outline),
            if (count > 0)
              Positioned(
                right: -8,
                top: -7,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.danger,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppTheme.card(context), width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, height: 1),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
