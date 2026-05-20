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
  final _chatService = ChatService();

  @override
  void initState() {
    super.initState();
    FirebaseService().saveUserToken();
    FirebaseService().archivePastWeddings();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [const HomePage(), const AddPage(), ChatPage(active: _index == 2), const StatsPage(), const ProfileSettingsPage()];
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (value) => setState(() => _index = value),
            destinations: [
              const NavigationDestination(icon: Icon(Icons.event_available_outlined), selectedIcon: Icon(Icons.event_available), label: 'To‘ylar'),
              const NavigationDestination(icon: Icon(Icons.add_circle_outline), selectedIcon: Icon(Icons.add_circle), label: 'Yangi'),
              NavigationDestination(icon: _ChatIcon(service: _chatService, selected: false, hideBadge: _index == 2), selectedIcon: _ChatIcon(service: _chatService, selected: true, hideBadge: _index == 2), label: 'Chat'),
              const NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Stat'),
              const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profil'),
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
  final bool hideBadge;
  const _ChatIcon({required this.service, required this.selected, required this.hideBadge});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: service.unreadCount(),
      builder: (context, snapshot) {
        final count = hideBadge ? 0 : (snapshot.data ?? 0);
        return Stack(clipBehavior: Clip.none, children: [
          Icon(selected ? Icons.chat_bubble : Icons.chat_bubble_outline),
          if (count > 0)
            Positioned(
              right: -9,
              top: -8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(color: AppTheme.danger, borderRadius: BorderRadius.circular(99), border: Border.all(color: Theme.of(context).colorScheme.surface, width: 1.5)),
                constraints: const BoxConstraints(minWidth: 18),
                child: Text(count > 99 ? '99+' : '$count', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
              ),
            ),
        ]);
      },
    );
  }
}
