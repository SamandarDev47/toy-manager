import 'package:flutter/material.dart';
import '../models/wedding.dart';
import '../services/firebase_services.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirebaseService();
    return AppPage(
      title: 'Arxiv',
      scrollable: false,
      padding: EdgeInsets.zero,
      child: StreamBuilder<List<Wedding>>(
        stream: service.getHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final history = snapshot.data ?? [];
          if (history.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: EmptyState(
                  icon: Icons.archive_outlined,
                  title: 'Arxiv bo‘sh',
                  subtitle: 'To‘y sanasi o‘tganidan keyin yoki qo‘lda arxivga yuborilganda shu yerda ko‘rinadi.',
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
            itemCount: history.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return HeroPanel(
                  icon: Icons.archive_rounded,
                  title: '${history.length} ta arxiv',
                  subtitle: 'Tugagan to‘ylar asosiy ro‘yxatdan alohida saqlanadi.',
                );
              }
              final w = history[index - 1];
              return AppCard(
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(color: AppTheme.primary.withOpacity(.10), borderRadius: BorderRadius.circular(18)),
                      child: const Icon(Icons.celebration_rounded, color: AppTheme.primary, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(w.location.isEmpty ? 'Noma’lum to‘yxona' : w.location, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 5),
                        Text('${w.displayDate} • ${w.timeOfDay}', style: const TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 5),
                        Text('Turi: ${w.weddingType.isEmpty ? '—' : w.weddingType}', style: const TextStyle(color: AppTheme.muted)),
                      ]),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppTheme.muted),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
