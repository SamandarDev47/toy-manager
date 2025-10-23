import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:animations/animations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/wedding.dart';
import '../services/firebase_services.dart';

class AddPage extends StatefulWidget {

  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();

  // Controllerlar
  final _ownerController = TextEditingController();
  final _noteController = TextEditingController();
  final _dateController = TextEditingController();
  final _customLocationController = TextEditingController();
  final _customTypeController = TextEditingController();

  String? selectedLocation;
  String? selectedType;
  String timeOfDay = "Kunduzi";
  String? selectedHost;
  List<String> selectedSingers = [];
  List<String> selectedMusicians = [];

  bool hasInternet = true;

  // Ma’lumotlar
  final List<String> locations = [
    "Risolat Ona",
    "Malika",
    "Yakka Saroy",
    "Tabassum",
    "Oq Saroy",
    "Boshqa"
  ];

  final List<String> weddingTypes = [
    "Kelin Kuyov",
    "Sunnat",
    "Qiz bazmi",
    "Osh",
    "Boshqa"
  ];

  final List<String> singers = [
    "Javlon Usmonov",
    "Shoxsanam",
    "Qodirali",
  ];

  final List<String> musicians = [
    "Alisher",
    "Dilmurod",
    "Mirzohid",
    "Abdusattor",
  ];

  final List<String> hosts = [
    "Qodirali",
  ];

  @override
  void initState() {
    super.initState();
    _checkInternet();
    Connectivity().onConnectivityChanged.listen((status) {
      setState(() {
        hasInternet = status != ConnectivityResult.none;
      });
    });
  }

  Future<void> _checkInternet() async {
    final status = await Connectivity().checkConnectivity();
    setState(() => hasInternet = status != ConnectivityResult.none);
  }

  // Sana tanlash
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      _dateController.text = DateFormat('dd-MM-yyyy').format(picked);
      setState(() {});
    }
  }

  // Saqlash
  Future<void> _saveWedding() async {
    if (!_formKey.currentState!.validate()) return;

    final wedding = Wedding(
      eventName: "",
      location: selectedLocation == "Boshqa"
          ? _customLocationController.text.trim()
          : (selectedLocation ?? ""),
      weddingType: selectedType == "Boshqa"
          ? _customTypeController.text.trim()
          : (selectedType ?? ""),
      date: _dateController.text.trim(),
      timeOfDay: timeOfDay,
      singers: selectedSingers,
      femaleSingers: [],
      musicians: selectedMusicians,
      host: selectedHost ?? "",
      owner: _ownerController.text.trim(),
      note: _noteController.text.trim(),
    );

    await _firebaseService.addWedding(wedding);

    if (!mounted) return;

    // ✅ Dialog chiqaramiz
    await showDialog(
      context: context,
      builder: (_) => const _SuccessDialog(),
    );

    // ✅ HomePagega o‘tamiz (bottom nav bar orqali)

    // ✅ Formani tozalaymiz
    _formKey.currentState!.reset();
    _dateController.clear();
    setState(() {
      selectedLocation = null;
      selectedType = null;
      selectedHost = null;
      selectedSingers.clear();
      selectedMusicians.clear();
      timeOfDay = "Kunduzi";
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          "📝 Yangi to‘y qo‘shish",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal.withOpacity(0.9),
        elevation: 5,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          /// Gradient fon
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1FA2FF), Color(0xFF12D8FA), Color(0xFFA6FFCB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// Blur overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: Container(color: Colors.white.withOpacity(0.1)),
          ),

          if (!hasInternet)
          /// Internet yo‘q holat
            Center(
              child: Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off, color: Colors.white, size: 70),
                    const SizedBox(height: 10),
                    Text(
                      "Internet ulanmagan",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Iltimos, internetni yoqing",
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
          /// Forma ishlaganda
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 110, 16, 30),
              child: Form(
                key: _formKey,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOutCubic,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _dateController,
                        label: "📅 Sana tanlang",
                        icon: Icons.date_range,
                        readOnly: true,
                        onTap: _selectDate,
                        validator: (v) => v!.isEmpty ? "Sana tanlang" : null,
                      ),
                      const SizedBox(height: 14),

                      _buildDropdown(
                        label: "🕓 Vaqt",
                        value: timeOfDay,
                        items: ["Kunduzi", "Kechqurun"],
                        onChanged: (v) => setState(() => timeOfDay = v!),
                      ),
                      const SizedBox(height: 14),

                      _buildDropdown(
                        label: "🏠 To‘yxona tanlang",
                        value: selectedLocation,
                        items: locations,
                        onChanged: (v) => setState(() => selectedLocation = v),
                        validator: (v) =>
                        v == null ? "To‘yxona tanlang" : null,
                      ),
                      if (selectedLocation == "Boshqa")
                        _buildTextField(
                          controller: _customLocationController,
                          label: "Boshqa to‘yxona nomi",
                        ),
                      const SizedBox(height: 14),

                      _buildDropdown(
                        label: "💍 To‘y turi",
                        value: selectedType,
                        items: weddingTypes,
                        onChanged: (v) => setState(() => selectedType = v),
                        validator: (v) =>
                        v == null ? "To‘y turini tanlang" : null,
                      ),
                      if (selectedType == "Boshqa")
                        _buildTextField(
                          controller: _customTypeController,
                          label: "Boshqa to‘y turi nomi",
                        ),
                      const SizedBox(height: 14),

                      _buildSection("🎤 Qo‘shiqchilar", singers, selectedSingers),
                      const SizedBox(height: 12),
                      _buildSection("🎶 Sozandalar", musicians, selectedMusicians),
                      const SizedBox(height: 12),

                      _buildDropdown(
                        label: "🎙 Boshlovchi",
                        value: selectedHost,
                        items: hosts,
                        onChanged: (v) => setState(() => selectedHost = v),
                      ),
                      const SizedBox(height: 14),

                      _buildTextField(
                        controller: _ownerController,
                        label: "📍 Qaysi hudud to‘yi",
                        icon: Icons.location_on,
                        validator: (v) =>
                        v!.isEmpty ? "Hududni kiriting" : null,
                      ),
                      const SizedBox(height: 14),

                      _buildTextField(
                        controller: _noteController,
                        label: "📝 Izoh (ixtiyoriy)",
                        icon: Icons.note_alt,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 25),

                      Hero(
                        tag: "save-btn",

                        child: ElevatedButton.icon(
                          onPressed: _saveWedding,
                          icon: const Icon(Icons.save),
                          label: const Text("Saqlash"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.tealAccent.shade400,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(56),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            textStyle: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            elevation: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.poppins(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
        GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w500),
        prefixIcon: icon != null ? Icon(icon, color: Colors.white70) : null,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white70),
          borderRadius: BorderRadius.circular(16),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      maxLines: maxLines,
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required Function(String?) onChanged,
    String? value,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      dropdownColor: Colors.black.withOpacity(0.8),
      value: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
        GoogleFonts.poppins(color: Colors.white70, fontWeight: FontWeight.w500),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white24),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      style: GoogleFonts.poppins(color: Colors.white),
      items:
      items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildSection(String title, List<String> list, List<String> selected) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.poppins(
                fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: list.map((item) {
            final isSelected = selected.contains(item);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.tealAccent.withOpacity(0.3)
                    : Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: isSelected
                        ? Colors.tealAccent
                        : Colors.white24,
                    width: 1),
              ),
              child: InkWell(
                onTap: () {
                  setState(() {
                    isSelected
                        ? selected.remove(item)
                        : selected.add(item);
                  });
                },
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    item,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  const _SuccessDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("✅ Muvaffaqiyat!"),
      content: const Text("To‘y muvaffaqiyatli saqlandi!"),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Yopish"),
        ),
      ],
    );
  }
}
