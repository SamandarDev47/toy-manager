import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../internet cheker/connection_checker.dart';
import '../../services/auth_service.dart';
import '../../widgets/main_navbar.dart';
import 'login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.instance.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.data == null) return const LoginPage();
        return const ConnectionChecker(child: MainNavBar());
      },
    );
  }
}
