import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'root_shell.dart';
import 'screens/auth/login_screen.dart';

/// Watches auth state and routes to login or the main app shell,
/// mirroring the website's auth-context.tsx gating behavior.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return auth.isLoggedIn ? const RootShell() : const LoginScreen();
  }
}
