import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motion_tab_bar_v2/motion-tab-bar.dart';

import '../pages/add_page.dart';
import '../pages/home_page.dart';
import '../pages/stats_page.dart';

class MainNavBar extends StatefulWidget {
  const MainNavBar({super.key});

  @override
  State<MainNavBar> createState() => _MainNavBarState();
}

class _MainNavBarState extends State<MainNavBar> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, String>> weddings = [];

  VoidCallback? get onSaved => () {
        setState(() {
          _tabController.index = 0; // HomePagega qaytadi
        });
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void addWedding(Map<String, String> data) {
    setState(() {
      weddings.add(data);
      _tabController.index = 0; // HomePagega qaytadi
    });
  }

  void editWedding(int index, Map<String, String> updatedData) {
    setState(() {
      weddings[index] = updatedData;
    });
  }

  void deleteWedding(int index) {
    setState(() {
      weddings.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(),
      AddPage(),
      StatsPage(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: pages,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xff6A11CB), Color(0xff2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, -3),
            )
          ],
        ),
        child: MotionTabBar(
          initialSelectedTab: "To‘ylar",
          useSafeArea: true,
          labels: const ["To‘ylar", "Yangi", "Statistika"],
          icons: const [
            Icons.list_rounded,
            Icons.add_circle_rounded,
            Icons.bar_chart_rounded
          ],
          tabSize: 60,
          tabBarHeight: 65,
          textStyle: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
          tabIconColor: Colors.white70,
          tabIconSelectedColor: Colors.white,
          tabBarColor: Colors.transparent,
          tabSelectedColor: Colors.white.withOpacity(0.25),
          tabIconSize: 26.0,
          tabIconSelectedSize: 30.0,
          onTabItemSelected: (int index) {
            setState(() => _tabController.index = index);
          },
        ),
      ),
    );
  }
}
