import 'package:flutter/material.dart';

import '../models/wedding.dart';
import '../services/firebase_services.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirebaseService();
    return AppShell(
      title: 'Statistika',
      subtitle: 'Faol va arxivdagi to‘ylar hisobi',
      icon: Icons.bar_chart_rounded,
      child: StreamBuilder<List<Wedding>>(
        stream: service.getWeddings(),
        builder: (context, activeSnap) {
          return StreamBuilder<List<Wedding>>(
            stream: service.getHistory(),
            builder: (context, historySnap) {
              final active = activeSnap.data ?? [];
              final history = historySnap.data ?? [];
              final today = active.where((e) => e.isToday).length;
              final tomorrow = active.where((e) {
                final d = e.dateTime;
                if (d == null) return false;
                final now = DateTime.now();
                final t = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
                return d.year == t.year && d.month == t.month && d.day == t.day;
              }).length;
              return Column(children: [
                Row(children: [
                  Expanded(child: _StatCard(title: 'Faol', value: '${active.length}', icon: Icons.event_available_rounded, color: AppTheme.primary)),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(title: 'Arxiv', value: '${history.length}', icon: Icons.archive_rounded, color: AppTheme.warning)),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _StatCard(title: 'Bugun', value: '$today', icon: Icons.today_rounded, color: AppTheme.success)),
                  const SizedBox(width: 10),
                  Expanded(child: _StatCard(title: 'Ertaga', value: '$tomorrow', icon: Icons.notifications_active_rounded, color: AppTheme.secondary)),
                ]),
                const SizedBox(height: 14),
                AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const SectionTitle(title: 'Eslatma'),
                  Text('Sanasi o‘tgan to‘ylar avtomatik arxivga ko‘chadi. Ertangi to‘ylar bo‘yicha notification GitHub Actions orqali yuboriladi.', style: TextStyle(color: AppTheme.subtext(context), height: 1.4)),
                ])),
              ]);
            },
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
    return AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 44, height: 44, decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(16)), child: Icon(icon, color: color)),
      const SizedBox(height: 14),
      Text(value, style: TextStyle(color: AppTheme.text(context), fontSize: 28, fontWeight: FontWeight.w900)),
      const SizedBox(height: 3),
      Text(title, style: TextStyle(color: AppTheme.subtext(context), fontWeight: FontWeight.w700)),
    ]));
  }
}
