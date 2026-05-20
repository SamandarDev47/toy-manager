import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../models/wedding.dart';
import '../services/firebase_services.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  final service = FirebaseService();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((results) {
      final connected = results.contains(ConnectivityResult.mobile) || results.contains(ConnectivityResult.wifi) || results.contains(ConnectivityResult.ethernet);
      if (mounted) setState(() => _isOnline = connected);
    });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOnline) {
      return const AppPage(
        title: 'Statistika',
        child: EmptyState(
          icon: Icons.wifi_off_rounded,
          title: 'Internet ulanmagan',
          subtitle: 'Statistika Firebase’dan olinadi. Internetni yoqing va qayta oching.',
        ),
      );
    }

    return AppPage(
      title: 'Statistika',
      scrollable: false,
      padding: EdgeInsets.zero,
      child: StreamBuilder<List<Wedding>>(
        stream: service.getWeddings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final weddings = snapshot.data ?? [];
          final today = weddings.where((e) => e.isToday).length;
          final day = weddings.where((e) => e.timeOfDay == 'Kunduzi').length;
          final night = weddings.where((e) => e.timeOfDay == 'Kechqurun').length;
          final singers = weddings.fold<int>(0, (sum, w) => sum + w.singers.length);
          final musicians = weddings.fold<int>(0, (sum, w) => sum + w.musicians.length);

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
            children: [
              HeroPanel(
                icon: Icons.insights_rounded,
                title: '${weddings.length} ta faol to‘y',
                subtitle: 'Jadvaldagi faol to‘ylar, bugungi bandlik va jamoa soni.',
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: MediaQuery.of(context).size.width > 650 ? 4 : 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.28,
                children: [
                  _StatCard(title: 'Bugun', value: '$today', icon: Icons.today_rounded, color: AppTheme.accent),
                  _StatCard(title: 'Kunduzi', value: '$day', icon: Icons.wb_sunny_outlined, color: AppTheme.secondary),
                  _StatCard(title: 'Kechqurun', value: '$night', icon: Icons.nightlight_round, color: AppTheme.primary),
                  _StatCard(title: 'Jamoa tanlovi', value: '${singers + musicians}', icon: Icons.groups_rounded, color: AppTheme.success),
                ],
              ),
              const SizedBox(height: 16),
              AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Tezkor xulosa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  _InfoRow(icon: Icons.event_available_rounded, title: 'Faol jadval', value: '${weddings.length} ta'),
                  const Divider(height: 22),
                  _InfoRow(icon: Icons.mic_external_on_outlined, title: 'Qo‘shiqchi tanlovlari', value: '$singers ta'),
                  const Divider(height: 22),
                  _InfoRow(icon: Icons.music_note_rounded, title: 'Sozanda tanlovlari', value: '$musicians ta'),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: color),
        ),
        const Spacer(),
        Text(value, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(title, style: const TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _InfoRow({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, color: AppTheme.primary),
      const SizedBox(width: 10),
      Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800))),
      Text(value, style: const TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w800)),
    ]);
  }
}
