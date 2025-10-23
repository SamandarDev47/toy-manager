import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../models/wedding.dart';
import '../services/firebase_services.dart';

class StatsPage extends StatefulWidget {
  const StatsPage({super.key});

  @override
  State<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage>
    with SingleTickerProviderStateMixin {
  final service = FirebaseService();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isOnline = true;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // 🔌 Internet kuzatuvi (yangi versiyaga mos)
    _connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
          final connected = results.contains(ConnectivityResult.mobile) ||
              results.contains(ConnectivityResult.wifi);

          setState(() {
            _isOnline = connected;
          });
        });
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOnline) {
      // 🟥 Internet yo‘q holati
      return Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xff232526), Color(0xff414345)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off, color: Colors.white, size: 70),
                const SizedBox(height: 16),
                Text(
                  "Internet ulanmagan",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Iltimos, ulanib qayta urinib ko‘ring.",
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("📊 Statistika"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.lerp(
                    const Color(0xff6A11CB),
                    const Color(0xff2575FC),
                    _controller.value,
                  )!,
                  Color.lerp(
                    const Color(0xff2575FC),
                    const Color(0xff6A11CB),
                    _controller.value,
                  )!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: child,
          );
        },
        child: StreamBuilder<List<Wedding>>(
          stream: service.getWeddings(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  "Hozircha to‘ylar yo‘q 🎉",
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              );
            }

            final weddings = snapshot.data!;
            final total = weddings.length;

            // === To‘y turlari statistikasi
            final Map<String, int> types = {};
            for (final w in weddings) {
              types[w.weddingType] = (types[w.weddingType] ?? 0) + 1;
            }

            // Eng ko‘p uchraydigan to‘y turi
            final mostCommonType = types.entries.reduce(
                  (a, b) => a.value >= b.value ? a : b,
            );

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _animatedStatCard(
                    icon: Icons.favorite,
                    title: "Jami to‘ylar",
                    value: "$total ta",
                    delay: 0,
                  ),
                  const SizedBox(height: 16),
                  _animatedStatCard(
                    icon: Icons.celebration,
                    title: "Eng mashhur turi",
                    value: mostCommonType.key,
                    subtitle: "${mostCommonType.value} ta to‘y",
                    delay: 0.2,
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Turlarga ko‘ra taqsimot:",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...types.entries.mapIndexed((i, e) {
                    final percent = (e.value / total * 100).toStringAsFixed(1);
                    return _animatedProgressTile(
                      title: e.key,
                      count: e.value,
                      percent: percent,
                      delay: i * 0.15,
                    );
                  }),
                  const SizedBox(height: 40),
                  Text(
                    "📅 Ma’lumotlar real vaqt rejimida yangilanadi",
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _animatedStatCard({
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
    double delay = 0,
  }) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 600 + (delay * 1000).toInt()),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, double opacity, _) {
        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: opacity,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.25),
                    radius: 28,
                    child: Icon(icon, size: 28, color: Colors.white),
                  ),
                  const SizedBox(width: 18),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: GoogleFonts.poppins(
                              fontSize: 15, color: Colors.white70)),
                      Text(value,
                          style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      if (subtitle != null)
                        Text(subtitle,
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _animatedProgressTile({
    required String title,
    required int count,
    required String percent,
    double delay = 0,
  }) {
    final p = double.parse(percent);
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 800 + (delay * 1000).toInt()),
      tween: Tween(begin: 0.0, end: p / 100),
      builder: (context, double value, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              title: Text(title,
                  style:
                  GoogleFonts.poppins(color: Colors.white, fontSize: 16)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: LinearProgressIndicator(
                  value: value,
                  color: Colors.white,
                  backgroundColor: Colors.white24,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              trailing: Text(
                "$percent%",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// 🔹 Extension — index bilan map qilish uchun
extension _MapIndex<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(int index, E e) f) {
    int i = 0;
    return map((e) => f(i++, e));
  }
}
