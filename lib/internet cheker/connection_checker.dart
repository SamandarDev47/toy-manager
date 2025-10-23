import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:lottie/lottie.dart';

class ConnectionChecker extends StatefulWidget {
  final Widget child; // ilovaning asosiy ekrani
  const ConnectionChecker({super.key, required this.child});

  @override
  State<ConnectionChecker> createState() => _ConnectionCheckerState();
}

class _ConnectionCheckerState extends State<ConnectionChecker> {
  bool _isDeviceConnected = true;
  late StreamSubscription _subscription;
  bool _showOnlineBanner = false;

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }
  void _startMonitoring() {
    _subscription = Connectivity().onConnectivityChanged.listen((_) async {
      final hasConnection = await InternetConnection().hasInternetAccess;

      if (!hasConnection && _isDeviceConnected) {
        setState(() => _isDeviceConnected = false);
      } else if (hasConnection && !_isDeviceConnected) {
        setState(() {
          _isDeviceConnected = true;
          _showOnlineBanner = true;
        });

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _showOnlineBanner = false);
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Offline holat
        if (!_isDeviceConnected)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      'assets/lottie/offline.json',
                      width: 200,
                      height: 200,
                      repeat: true,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Siz oflinesiz 😕',
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Iltimos, internetni yoqing',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        // Online bo'lganini ko'rsatish
        if (_showOnlineBanner)
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Online ✅',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
