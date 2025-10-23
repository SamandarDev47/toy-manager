import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/wedding.dart';
import '../services/firebase_services.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirebaseService();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("📜 O‘tgan to‘ylar"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff614385), Color(0xff516395)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: StreamBuilder<List<Wedding>>(
          stream: service.getHistory(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inbox, color: Colors.white70, size: 70),
                    const SizedBox(height: 10),
                    Text(
                      "Hali o‘tgan to‘ylar yo‘q 😅",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Yangi to‘ylar tugaganda bu yerda paydo bo‘ladi",
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              );
            }

            final history = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 20),
              physics: const BouncingScrollPhysics(),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final w = history[index];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white.withOpacity(0.25),
                      child: const Icon(Icons.celebration, color: Colors.white),
                    ),
                    title: Text(
                      w.eventName,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "📅 ${w.date}\n📍 ${w.location}",
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.white70),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
