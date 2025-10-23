import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/wedding.dart';
import '../services/firebase_services.dart';
import 'add_page.dart';
import 'history_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final firebaseService = FirebaseService();
  bool hasInternet = true;

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

  DateTime? _tryParseDate(String? s) {
    if (s == null || s.trim().isEmpty) return null;
    try {
      return DateTime.parse(s);
    } catch (_) {}
    try {
      final parts = s.split(RegExp(r'[.\-/]'));
      if (parts.length >= 3) {
        return DateTime(
          int.parse(parts[2]),
          int.parse(parts[1]),
          int.parse(parts[0]),
        );
      }
    } catch (_) {}
    return null;
  }

  String _displayDate(String? raw) {
    final dt = _tryParseDate(raw);
    if (dt == null) return raw ?? '';
    return DateFormat('dd.MM.yyyy').format(dt);
  }

  /// === TO‘Y TAFSILOTLARINI KO‘RSATISH FUNKSIYASI ===
  void _showWeddingDetails(BuildContext context, Wedding w) {
    final nameCtrl = TextEditingController(text: w.eventName);
    final locationCtrl = TextEditingController(text: w.location);
    final typeCtrl = TextEditingController(text: w.weddingType);
    final dateCtrl = TextEditingController(text: w.date);
    final timeCtrl = TextEditingController(text: w.timeOfDay);
    final singersCtrl = TextEditingController(text: w.singers.join(", "));
    final musiciansCtrl = TextEditingController(text: w.musicians.join(", "));
    final hostCtrl = TextEditingController(text: w.host);
    final ownerCtrl = TextEditingController(text: w.owner);
    final noteCtrl = TextEditingController(text: w.note);
    final descCtrl = TextEditingController(text: (w as dynamic).description ?? '');

    bool isEditing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> _saveChanges() async {
              final updated = w.copyWith(
                eventName: nameCtrl.text,
                location: locationCtrl.text,
                weddingType: typeCtrl.text,
                date: dateCtrl.text,
                timeOfDay: timeCtrl.text,
                singers: singersCtrl.text.isEmpty
                    ? []
                    : singersCtrl.text.split(',').map((e) => e.trim()).toList(),
                musicians: musiciansCtrl.text.isEmpty
                    ? []
                    : musiciansCtrl.text.split(',').map((e) => e.trim()).toList(),
                host: hostCtrl.text,
                owner: ownerCtrl.text,
                note: noteCtrl.text,
                description: descCtrl.text,
              );

              await firebaseService.updateWedding(updated);
              if (context.mounted) Navigator.pop(context);
            }

            Widget field(String label, TextEditingController c) {
              final bool hasValue = c.text.isNotEmpty;
              if (!hasValue && !isEditing) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 110,
                      child: Text(
                        label,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: isEditing
                          ? TextField(
                        controller: c,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.15),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                        ),
                      )
                          : Text(
                        c.text.isEmpty ? "—" : c.text,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                margin: const EdgeInsets.only(top: 60),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6D5DF6), Color(0xFF8E2DE2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 60,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.white54,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          w.eventName.isNotEmpty
                              ? w.eventName
                              : "Noma’lum tadbir",
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 🔹 Ma’lumotlar
                      field("📍 Joy:", locationCtrl),
                      field("💒 Turi:", typeCtrl),
                      field("📅 Sana:", dateCtrl),
                      field("🕒 Vaqt:", timeCtrl),
                      field("🎤 Qo‘shiqchilar:", singersCtrl),
                      field("🎹 Musiqachilar:", musiciansCtrl),
                      field("🎙️ Boshlovchi:", hostCtrl),
                      field("📍 To'y qaysi hududniki:", ownerCtrl),
                      field("📝 Izoh:", noteCtrl),

                      const SizedBox(height: 28),

                      // 🔹 Tugmalar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (!isEditing)
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.2),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                              ),
                              onPressed: () {
                                setModalState(() => isEditing = true);
                              },
                              icon: const Icon(Icons.edit, size: 20),
                              label: const Text("Tahrirlash"),
                            ),
                          if (isEditing)
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.withOpacity(0.9),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                              ),
                              onPressed: _saveChanges,
                              icon: const Icon(Icons.save, size: 20),
                              label: const Text("Saqlash"),
                            ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent.withOpacity(0.8),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                            ),
                            onPressed: () async {
                              final confirm = await showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: Colors.deepPurple[100],
                                  title:
                                  const Text("O‘chirishni tasdiqlaysizmi?"),
                                  content: Text(
                                    "Bu to‘y ma’lumotlari butunlay o‘chiriladi.",
                                    style: GoogleFonts.poppins(),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: const Text("Bekor qilish"),
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                    ),
                                    TextButton(
                                      child: const Text("Ha, o‘chir"),
                                      onPressed: () => Navigator.pop(ctx, true),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true && w.id != null) {
                                await firebaseService.deleteWedding(w.id!);
                                if (context.mounted) Navigator.pop(context);
                              }
                            },
                            icon: const Icon(Icons.delete_outline, size: 20),
                            label: const Text("O‘chirish"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }


  /// 🔹 Info tile helper
  Widget _infoTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          "📅 To‘y jadvali",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple.withOpacity(0.85),
        elevation: 6,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryPage()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          /// === Gradient background ===
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6D5DF6), Color(0xFF8E2DE2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// === Blur overlay ===
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(color: Colors.black.withOpacity(0.1)),
          ),

          /// === Internet yo‘q bo‘lsa ===
          if (!hasInternet)
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded,
                        color: Colors.white, size: 70),
                    const SizedBox(height: 12),
                    Text(
                      "Internet ulanmagan",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Iltimos, tarmoqqa ulaning",
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
          /// === Asosiy to‘ylar ro‘yxati ===
            StreamBuilder<List<Wedding>>(
              stream: firebaseService.getWeddings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xff6A11CB), Color(0xff2575FC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: const SizedBox(
                        height: 60,
                        width: 60,
                        child: CircularProgressIndicator(
                          strokeWidth: 6,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          backgroundColor: Colors.white12,
                        ),
                      ),
                    ),
                  );
                }


                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      "Hozircha to‘ylar yo‘q",
                      style: GoogleFonts.poppins(
                          fontSize: 18, color: Colors.white70),
                    ),
                  );
                }

                final weddings = snapshot.data!;
                weddings.sort((a, b) {
                  final da = _tryParseDate(a.date) ?? DateTime(2100);
                  final db = _tryParseDate(b.date) ?? DateTime(2100);
                  return da.compareTo(db);
                });

                final now = DateTime.now();

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 120, 16, 16),
                  itemCount: weddings.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final w = weddings[index];
                    final dt = _tryParseDate(w.date);
                    if (dt == null) return const SizedBox();

                    final difference =
                        dt.difference(DateTime(now.year, now.month, now.day))
                            .inDays;

                    String badge = '';
                    Color badgeColor = Colors.deepPurpleAccent;

                    if (difference == 0) {
                      badge = "Bugun";
                      badgeColor = Colors.orangeAccent;
                    } else if (difference == 1) {
                      badge = "Ertaga";
                      badgeColor = Colors.blueAccent;
                    } else if (difference < 0) {
                      badge = "O‘tgan";
                      badgeColor = Colors.redAccent;
                    }

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: InkWell(
                        onTap: () => _showWeddingDetails(context, w),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border:
                            Border.all(color: Colors.white24, width: 1.2),
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.15),
                                Colors.white.withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 18),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: badgeColor.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.calendar_month,
                                      color: badgeColor, size: 26),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${_displayDate(w.date)} • $badge",
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "🏛️ ${w.location}\n📍 ${w.owner}",
                                        style: GoogleFonts.poppins(
                                          color: Colors.white70,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios_rounded,
                                    color: Colors.white70, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}
