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
  final _service = FirebaseService();
  final _ownerController = TextEditingController();
  final _noteController = TextEditingController();
  final _dateController = TextEditingController();
  final _customLocationController = TextEditingController();
  final _customTypeController = TextEditingController();
  final _customStarterController = TextEditingController();

  bool _saving = false;
  String? selectedLocation;
  String? selectedType;
  String? selectedStarter;
  String? selectedHost;
  String timeOfDay = 'Kunduzi';
  final selectedSingers = <String>[];
  final selectedMusicians = <String>[];

  final locations = const ['Risolat Ona', 'Toj Mahal', 'Malika', 'Yakka Saroy', 'Tabassum', 'Oq Saroy', 'Boshqa'];
  final weddingTypes = const ['Kelin Kuyov', 'Sunnat', 'Qiz bazmi', 'Osh', 'Boshqa'];
  final starterTypes = const ['Fotiha', 'Nikoh', 'Tug‘ilgan kun', 'Banket', 'Boshqa'];
  final singers = const ['Javlon Usmonov', 'Shoxsanam', 'Qodirali'];
  final musicians = const ['Alisher', 'Dilmurod', 'Mirzohid', 'Abdusattor'];
  final hosts = const ['Qodirali', 'Boshqa'];

  @override
  void dispose() {
    _ownerController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    _customLocationController.dispose();
    _customTypeController.dispose();
    _customStarterController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2035));
    if (picked != null) setState(() => _dateController.text = DateFormat('dd-MM-yyyy').format(picked));
  }

  Future<void> _saveWedding() async {
    if (_saving || !_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final wedding = Wedding(
        eventName: '',
        location: selectedLocation == 'Boshqa' ? _customLocationController.text.trim() : (selectedLocation ?? ''),
        weddingType: selectedType == 'Boshqa' ? _customTypeController.text.trim() : (selectedType ?? ''),
        starterType: selectedStarter == 'Boshqa' ? _customStarterController.text.trim() : (selectedStarter ?? ''),
        date: Wedding.normalizeDateString(_dateController.text.trim()),
        timeOfDay: timeOfDay,
        singers: selectedSingers,
        femaleSingers: const [],
        musicians: selectedMusicians,
        host: selectedHost ?? '',
        owner: _ownerController.text.trim(),
        note: _noteController.text.trim(),
      );
      await _service.addWedding(wedding);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('To‘y jadvalga qo‘shildi')));
      _clearForm();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saqlashda xato: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _ownerController.clear();
    _noteController.clear();
    _dateController.clear();
    _customLocationController.clear();
    _customTypeController.clear();
    _customStarterController.clear();
    setState(() {
      selectedLocation = null;
      selectedType = null;
      selectedStarter = null;
      selectedHost = null;
      selectedSingers.clear();
      selectedMusicians.clear();
      timeOfDay = 'Kunduzi';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Yangi to‘y',
      subtitle: 'To‘y ma’lumotlarini tartibli kiriting',
      icon: Icons.add_circle_rounded,
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SectionTitle(title: 'Asosiy ma’lumotlar'),
            _DropdownField(label: 'To‘yxona', value: selectedLocation, items: locations, onChanged: (v) => setState(() => selectedLocation = v), validator: (v) => v == null ? 'To‘yxona tanlang' : null),
            if (selectedLocation == 'Boshqa') ...[const SizedBox(height: 12), TextFormField(controller: _customLocationController, decoration: const InputDecoration(labelText: 'To‘yxona nomi'), validator: _required)],
            const SizedBox(height: 12),
            _DropdownField(label: 'To‘y turi', value: selectedType, items: weddingTypes, onChanged: (v) => setState(() => selectedType = v), validator: (v) => v == null ? 'To‘y turini tanlang' : null),
            if (selectedType == 'Boshqa') ...[const SizedBox(height: 12), TextFormField(controller: _customTypeController, decoration: const InputDecoration(labelText: 'To‘y turi'), validator: _required)],
            const SizedBox(height: 12),
            _DropdownField(label: 'Boshlanish turi', value: selectedStarter, items: starterTypes, onChanged: (v) => setState(() => selectedStarter = v)),
            if (selectedStarter == 'Boshqa') ...[const SizedBox(height: 12), TextFormField(controller: _customStarterController, decoration: const InputDecoration(labelText: 'Boshlanish turi'))],
            const SizedBox(height: 12),
            TextFormField(controller: _dateController, readOnly: true, decoration: const InputDecoration(labelText: 'Sana', prefixIcon: Icon(Icons.calendar_month_rounded)), onTap: _selectDate, validator: _required),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: AppChip(label: 'Kunduzi', icon: Icons.wb_sunny_rounded, selected: timeOfDay == 'Kunduzi', onTap: () => setState(() => timeOfDay = 'Kunduzi'))),
              const SizedBox(width: 10),
              Expanded(child: AppChip(label: 'Kechqurun', icon: Icons.nightlight_round, selected: timeOfDay == 'Kechqurun', onTap: () => setState(() => timeOfDay = 'Kechqurun'))),
            ]),
          ])),
          const SizedBox(height: 14),
          AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SectionTitle(title: 'Jamoa va izoh'),
            _DropdownField(label: 'Boshlovchi', value: selectedHost, items: hosts, onChanged: (v) => setState(() => selectedHost = v)),
            const SizedBox(height: 14),
            Text('Hofizlar', style: TextStyle(color: AppTheme.text(context), fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            _MultiSelect(items: singers, selected: selectedSingers, onToggle: (name) => setState(() => selectedSingers.contains(name) ? selectedSingers.remove(name) : selectedSingers.add(name))),
            const SizedBox(height: 14),
            Text('Sozandalar', style: TextStyle(color: AppTheme.text(context), fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            _MultiSelect(items: musicians, selected: selectedMusicians, onToggle: (name) => setState(() => selectedMusicians.contains(name) ? selectedMusicians.remove(name) : selectedMusicians.add(name))),
            const SizedBox(height: 14),
            TextFormField(controller: _ownerController, decoration: const InputDecoration(labelText: 'Hudud / egasi', prefixIcon: Icon(Icons.person_rounded))),
            const SizedBox(height: 12),
            TextFormField(controller: _noteController, maxLines: 3, decoration: const InputDecoration(labelText: 'Izoh')),
          ])),
          const SizedBox(height: 16),
          FilledButton.icon(onPressed: _saving ? null : _saveWedding, icon: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save_rounded), label: const Text('To‘yni saqlash'), style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54))),
        ]),
      ),
    );
  }

  String? _required(String? value) => value == null || value.trim().isEmpty ? 'Majburiy maydon' : null;
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;
  const _DropdownField({required this.label, required this.value, required this.items, required this.onChanged, this.validator});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}

class _MultiSelect extends StatelessWidget {
  final List<String> items;
  final List<String> selected;
  final ValueChanged<String> onToggle;
  const _MultiSelect({required this.items, required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8, runSpacing: 8, children: items.map((e) => AppChip(label: e, selected: selected.contains(e), onTap: () => onToggle(e))).toList());
  }
}
