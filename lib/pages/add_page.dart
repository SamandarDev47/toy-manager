import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/wedding.dart';
import '../services/firebase_services.dart';
import '../theme/app_theme.dart';
import '../widgets/app_shell.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();

  final _ownerController = TextEditingController();
  final _noteController = TextEditingController();
  final _dateController = TextEditingController();
  final _customLocationController = TextEditingController();
  final _customTypeController = TextEditingController();
  final _customHostController = TextEditingController();

  String? selectedLocation;
  String? selectedType;
  String timeOfDay = 'Kunduzi';
  String? selectedHost;
  List<String> selectedSingers = [];
  List<String> selectedMusicians = [];
  bool hasInternet = true;
  bool saving = false;

  final List<String> locations = ['Risolat Ona', 'Malika', 'Yakka Saroy', 'Tabassum', 'Oq Saroy', 'Boshqa'];
  final List<String> weddingTypes = ['Kelin Kuyov', 'Sunnat', 'Qiz bazmi', 'Osh', 'Boshqa'];
  final List<String> singers = ['Javlon Usmonov', 'Shoxsanam', 'Qodirali'];
  final List<String> musicians = ['Alisher', 'Dilmurod', 'Mirzohid', 'Abdusattor'];
  final List<String> hosts = ['Qodirali', 'Boshqa'];

  @override
  void initState() {
    super.initState();
    _checkInternet();
    Connectivity().onConnectivityChanged.listen((status) {
      if (!mounted) return;
      setState(() => hasInternet = !status.contains(ConnectivityResult.none));
    });
  }

  @override
  void dispose() {
    _ownerController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    _customLocationController.dispose();
    _customTypeController.dispose();
    _customHostController.dispose();
    super.dispose();
  }

  Future<void> _checkInternet() async {
    final status = await Connectivity().checkConnectivity();
    if (mounted) setState(() => hasInternet = !status.contains(ConnectivityResult.none));
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: Wedding.parseDate(_dateController.text) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _dateController.text = DateFormat('dd-MM-yyyy').format(picked);
      setState(() {});
    }
  }

  Future<void> _saveWedding() async {
    if (!_formKey.currentState!.validate()) return;
    if (!hasInternet) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Internet ulanmagan')));
      return;
    }

    setState(() => saving = true);
    try {
      final wedding = Wedding(
        eventName: '',
        location: selectedLocation == 'Boshqa' ? _customLocationController.text.trim() : (selectedLocation ?? ''),
        weddingType: selectedType == 'Boshqa' ? _customTypeController.text.trim() : (selectedType ?? ''),
        starterType: '',
        date: Wedding.normalizeDateString(_dateController.text.trim()),
        timeOfDay: timeOfDay,
        singers: selectedSingers,
        femaleSingers: const [],
        musicians: selectedMusicians,
        host: selectedHost == 'Boshqa' ? _customHostController.text.trim() : (selectedHost ?? ''),
        owner: _ownerController.text.trim(),
        note: _noteController.text.trim(),
      );

      await _firebaseService.addWedding(wedding);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('To‘y jadvalga saqlandi')));
      _clearForm();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saqlashda xato: $e')));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _ownerController.clear();
    _noteController.clear();
    _dateController.clear();
    _customLocationController.clear();
    _customTypeController.clear();
    _customHostController.clear();
    setState(() {
      selectedLocation = null;
      selectedType = null;
      selectedHost = null;
      selectedSingers = [];
      selectedMusicians = [];
      timeOfDay = 'Kunduzi';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Yangi to‘y',
      scrollable: false,
      padding: EdgeInsets.zero,
      child: hasInternet ? _buildForm() : const _OfflineView(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        children: [
          const HeroPanel(
            icon: Icons.add_circle_rounded,
            title: 'To‘y qo‘shish',
            subtitle: 'Sana, to‘yxona, ijrochilar va izohlarni bitta joyda tartibli kiriting.',
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              children: [
                _dateField(),
                const SizedBox(height: 12),
                _segmentedTime(),
                const SizedBox(height: 12),
                _dropdown(label: 'To‘yxona', icon: Icons.home_work_outlined, value: selectedLocation, items: locations, onChanged: (v) => setState(() => selectedLocation = v), validator: (v) => v == null ? 'To‘yxona tanlang' : null),
                if (selectedLocation == 'Boshqa') ...[
                  const SizedBox(height: 12),
                  _text(_customLocationController, 'Boshqa to‘yxona nomi', Icons.edit_location_alt_outlined, validator: _required),
                ],
                const SizedBox(height: 12),
                _dropdown(label: 'To‘y turi', icon: Icons.favorite_border_rounded, value: selectedType, items: weddingTypes, onChanged: (v) => setState(() => selectedType = v), validator: (v) => v == null ? 'To‘y turini tanlang' : null),
                if (selectedType == 'Boshqa') ...[
                  const SizedBox(height: 12),
                  _text(_customTypeController, 'Boshqa to‘y turi', Icons.edit_note_rounded, validator: _required),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Jamoa', 'Qo‘shiqchilar, sozandalar va boshlovchini tanlang'),
                const SizedBox(height: 14),
                _chipSection('Qo‘shiqchilar', Icons.mic_external_on_outlined, singers, selectedSingers),
                const SizedBox(height: 14),
                _chipSection('Sozandalar', Icons.music_note_rounded, musicians, selectedMusicians),
                const SizedBox(height: 14),
                _dropdown(label: 'Boshlovchi', icon: Icons.record_voice_over_outlined, value: selectedHost, items: hosts, onChanged: (v) => setState(() => selectedHost = v), validator: (v) => v == null ? 'Boshlovchini tanlang' : null),
                if (selectedHost == 'Boshqa') ...[
                  const SizedBox(height: 12),
                  _text(_customHostController, 'Boshqa boshlovchi ismi', Icons.person_outline, validator: _required),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          AppCard(
            child: Column(
              children: [
                _text(_ownerController, 'Hudud / to‘y egasi', Icons.location_on_outlined),
                const SizedBox(height: 12),
                _text(_noteController, 'Izoh', Icons.notes_rounded, maxLines: 3),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: saving ? null : _saveWedding,
                  icon: saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save_rounded),
                  label: Text(saving ? 'Saqlanmoqda...' : 'Jadvalga saqlash'),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateField() => TextFormField(
        controller: _dateController,
        readOnly: true,
        onTap: _selectDate,
        decoration: const InputDecoration(labelText: 'Sana tanlang', prefixIcon: Icon(Icons.calendar_month_rounded)),
        validator: (v) => v == null || v.isEmpty ? 'Sana tanlang' : null,
      );

  Widget _segmentedTime() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'Kunduzi', label: Text('Kunduzi'), icon: Icon(Icons.wb_sunny_outlined)),
        ButtonSegment(value: 'Kechqurun', label: Text('Kechqurun'), icon: Icon(Icons.nightlight_round)),
      ],
      selected: {timeOfDay},
      onSelectionChanged: (v) => setState(() => timeOfDay = v.first),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? AppTheme.primary.withOpacity(.12) : Colors.white),
        foregroundColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? AppTheme.primary : AppTheme.ink),
        side: WidgetStateProperty.all(const BorderSide(color: AppTheme.stroke)),
        shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      ),
    );
  }

  Widget _dropdown({required String label, required IconData icon, required List<String> items, required ValueChanged<String?> onChanged, String? value, String? Function(String?)? validator}) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      dropdownColor: Colors.white,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      style: const TextStyle(color: AppTheme.ink, fontWeight: FontWeight.w700),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: AppTheme.ink)))).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _text(TextEditingController controller, String label, IconData icon, {int maxLines = 1, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: validator,
    );
  }

  Widget _sectionTitle(String title, String subtitle) {
    return Row(children: [
      Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(color: AppTheme.primary.withOpacity(.10), borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.groups_rounded, color: AppTheme.primary),
      ),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        Text(subtitle, style: const TextStyle(color: AppTheme.muted, height: 1.25)),
      ])),
    ]);
  }

  Widget _chipSection(String title, IconData icon, List<String> list, List<String> selected) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Icon(icon, color: AppTheme.primary, size: 20), const SizedBox(width: 7), Text(title, style: const TextStyle(fontWeight: FontWeight.w900))]),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: list.map((item) {
          final isSelected = selected.contains(item);
          return FilterChip(
            label: Text(item),
            selected: isSelected,
            onSelected: (_) => setState(() => isSelected ? selected.remove(item) : selected.add(item)),
            avatar: isSelected ? const Icon(Icons.check_rounded, size: 18, color: AppTheme.primary) : null,
          );
        }).toList(),
      ),
    ]);
  }

  String? _required(String? v) => v == null || v.trim().isEmpty ? 'Majburiy maydon' : null;
}

class _OfflineView extends StatelessWidget {
  const _OfflineView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: EmptyState(
          icon: Icons.wifi_off_rounded,
          title: 'Internet ulanmagan',
          subtitle: 'To‘y qo‘shish uchun internetni yoqing va qayta urinib ko‘ring.',
        ),
      ),
    );
  }
}
