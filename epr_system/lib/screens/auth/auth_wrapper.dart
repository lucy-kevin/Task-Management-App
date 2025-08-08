import 'package:epr_system/screens/auth/loading_screen.dart';
import 'package:epr_system/screens/auth/login_screen.dart';
import 'package:epr_system/screens/dashboard/dashboard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingScreen();
        }

        if (snapshot.hasData) {
          return DashboardScreen();
        }

        return LoginScreen();
      },
    );
  }
}
