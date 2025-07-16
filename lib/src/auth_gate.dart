import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';

import '../firebase_options.dart';
import 'home.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  // TODO: Enable better mechanism for admin identity.
  static const _admins = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            providers: [
              EmailAuthProvider(),
              GoogleProvider(
                  clientId: Platform.isAndroid
                      ? (DefaultFirebaseOptions.ios.androidClientId ?? "")
                      : (DefaultFirebaseOptions.ios.iosClientId ?? "")),
            ],
            showPasswordVisibilityToggle: true,
          );
        }
        final isCurrentUserAdmin =
            _admins.contains(FirebaseAuth.instance.currentUser?.email);
        return HomeController(isCurrentUserAdmin: isCurrentUserAdmin);
      },
    );
  }
}
