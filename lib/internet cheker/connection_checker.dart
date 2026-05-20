import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../widgets/no_internet_view.dart';

class ConnectionChecker extends StatefulWidget {
  final Widget child;

  const ConnectionChecker({
    super.key,
    required this.child,
  });

  @override
  State<ConnectionChecker> createState() => _ConnectionCheckerState();
}

class _ConnectionCheckerState extends State<ConnectionChecker> {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _offline = false;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _checkConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateStatus(results);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _offline = false;
        _checking = false;
      });
    }
  }

  void _updateStatus(List<ConnectivityResult> results) {
    if (!mounted) return;
    final isOffline = results.isEmpty || results.contains(ConnectivityResult.none);
    setState(() {
      _offline = isOffline;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) return widget.child;
    if (_offline) {
      return NoInternetView(
        onRetry: _checkConnection,
      );
    }
    return widget.child;
  }
}
