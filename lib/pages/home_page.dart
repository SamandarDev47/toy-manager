import 'package:flutter/material.dart';
import '../models/wedding.dart';
import '../services/firebase_services.dart';
import '../theme/app_theme.dart';
import 'history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _service = FirebaseService();

  @override
  void initState() {
    super.initState();
    _service.archivePastWeddings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To‘y jadvali', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Arxiv',
            icon: const Icon(Icons.history_rounded),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPage())),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _service.archivePastWeddings,
        child: StreamBuilder<List<Wedding>>(
          stream: _service.getWeddings(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final weddings = snapshot.data ?? [];
            if (weddings.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 180),
                  Icon(Icons.event_busy_rounded, size: 76, color: AppTheme.muted),
                  SizedBox(height: 12),
                  Center(child: Text('Hozircha faol to‘ylar yo‘q')),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
              itemCount: weddings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _WeddingTile(
                wedding: weddings[index],
                onTap: () => _openDetails(weddings[index]),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _openDetails(Wedding wedding) async {
    final location = TextEditingController(text: wedding.location);
    final type = TextEditingController(text: wedding.weddingType);
    final date = TextEditingController(text: wedding.displayDate);
    final timeOfDay = TextEditingController(text: wedding.timeOfDay);
    final owner = TextEditingController(text: wedding.owner);
    final host = TextEditingController(text: wedding.host);
    final singers = TextEditingController(text: wedding.singers.join(', '));
    final musicians = TextEditingController(text: wedding.musicians.join(', '));
    final note = TextEditingController(text: wedding.note);
    bool editing = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) {
          return Padding(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(wedding.location, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text('${wedding.displayDate} • ${wedding.timeOfDay}', style: const TextStyle(color: AppTheme.muted)),
                  const SizedBox(height: 16),
                  _detailField('To‘yxona', location, editing),
                  _detailField('To‘y turi', type, editing),
                  _detailField('Sana', date, editing),
                  _detailField('Vaqt', timeOfDay, editing),
                  _detailField('Hudud / egasi', owner, editing),
                  _detailField('Boshlovchi', host, editing),
                  _detailField('Qo‘shiqchilar', singers, editing),
                  _detailField('Sozandalar', musicians, editing),
                  _detailField('Izoh', note, editing, maxLines: 3),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      if (!editing)
                        FilledButton.icon(onPressed: () => setSheet(() => editing = true), icon: const Icon(Icons.edit), label: const Text('Tahrirlash')),
                      if (editing)
                        FilledButton.icon(
                          onPressed: () async {
                            await _service.updateWedding(wedding.copyWith(
                              location: location.text,
                              weddingType: type.text,
                              date: date.text,
                              timeOfDay: timeOfDay.text,
                              owner: owner.text,
                              host: host.text,
                              singers: _split(singers.text),
                              musicians: _split(musicians.text),
                              note: note.text,
                            ));
                            if (context.mounted) Navigator.pop(context);
                          },
                          icon: const Icon(Icons.save),
                          label: const Text('Saqlash'),
                        ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await _service.moveToHistory(wedding);
                          if (context.mounted) Navigator.pop(context);
                        },
                        icon: const Icon(Icons.archive_outlined),
                        label: const Text('Arxivga'),
                      ),
                      TextButton.icon(
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('O‘chirishni tasdiqlang'),
                              content: const Text('Bu to‘y asosiy jadvaldan butunlay o‘chiriladi.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Bekor')),
                                FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('O‘chirish')),
                              ],
                            ),
                          );
                          if (ok == true && wedding.id != null) {
                            await _service.deleteWedding(wedding.id!);
                            if (context.mounted) Navigator.pop(context);
                          }
                        },
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        label: const Text('O‘chirish', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    for (final c in [location, type, date, timeOfDay, owner, host, singers, musicians, note]) {
      c.dispose();
    }
  }

  Widget _detailField(String label, TextEditingController controller, bool editing, {int maxLines = 1}) {
    if (editing) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(controller: controller, maxLines: maxLines, decoration: InputDecoration(labelText: label)),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
        const SizedBox(height: 2),
        Text(controller.text.isEmpty ? '—' : controller.text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  List<String> _split(String value) => value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
}

class _WeddingTile extends StatelessWidget {
  final Wedding wedding;
  final VoidCallback onTap;

  const _WeddingTile({required this.wedding, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final days = _daysLeft(wedding);
    final color = wedding.isToday ? Colors.orange : AppTheme.primary;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(18)),
                child: Icon(Icons.celebration_rounded, color: color, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(wedding.location.isEmpty ? 'Noma’lum to‘yxona' : wedding.location, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900))),
                    _Badge(text: days, color: color),
                  ]),
                  const SizedBox(height: 6),
                  Text('${wedding.displayDate} • ${wedding.timeOfDay}', style: const TextStyle(color: AppTheme.muted)),
                  const SizedBox(height: 4),
                  Text('📍 ${wedding.owner.isEmpty ? 'Hudud kiritilmagan' : wedding.owner}', maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _daysLeft(Wedding w) {
    final d = w.dateTime;
    if (d == null) return 'Sana yo‘q';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final event = DateTime(d.year, d.month, d.day);
    final diff = event.difference(today).inDays;
    if (diff == 0) return 'Bugun';
    if (diff == 1) return 'Ertaga';
    return '$diff kun';
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(99)),
      child: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12)),
    );
  }
}
