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
    return AppShell(
      title: 'Arxiv',
      subtitle: 'Tugagan to‘ylar ro‘yxati',
      icon: Icons.archive_rounded,
      onRefresh: service.archivePastWeddings,
      child: StreamBuilder<List<Wedding>>(
        stream: service.getHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
          }
          final history = snapshot.data ?? [];
          if (history.isEmpty) {
            return const EmptyState(icon: Icons.inbox_rounded, title: 'Arxiv bo‘sh', subtitle: 'To‘y sanasi o‘tganda yoki qo‘lda arxivga o‘tkazilganda shu yerda ko‘rinadi.');
          }
          return Column(children: [
            for (final w in history) ...[
              _HistoryTile(wedding: w, onDelete: () => _delete(context, service, w)),
              const SizedBox(height: 10),
            ],
          ]);
        },
      ),
    );
  }

  Future<void> _delete(BuildContext context, FirebaseService service, Wedding wedding) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Arxivdan o‘chirish'),
        content: Text('${wedding.location} arxivdan butunlay o‘chirilsinmi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Bekor')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('O‘chirish')),
        ],
      ),
    );
    if (ok == true && wedding.id != null) {
      await service.deleteHistoryWedding(wedding.id!);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Arxivdagi to‘y o‘chirildi')));
    }
  }
}

class _HistoryTile extends StatelessWidget {
  final Wedding wedding;
  final VoidCallback onDelete;
  const _HistoryTile({required this.wedding, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(color: AppTheme.warning.withOpacity(.13), borderRadius: BorderRadius.circular(18)),
          child: const Icon(Icons.event_busy_rounded, color: AppTheme.warning),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(wedding.location.isEmpty ? 'Noma’lum to‘yxona' : wedding.location, style: TextStyle(color: AppTheme.text(context), fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Text('${wedding.displayDate} • ${wedding.timeOfDay}', style: TextStyle(color: AppTheme.subtext(context), fontWeight: FontWeight.w600)),
          if (wedding.owner.isNotEmpty) ...[const SizedBox(height: 4), Text('📍 ${wedding.owner}', style: TextStyle(color: AppTheme.subtext(context)))],
        ])),
        IconButton(tooltip: 'Arxivdan o‘chirish', onPressed: onDelete, icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.danger)),
      ]),
    );
  }
}
