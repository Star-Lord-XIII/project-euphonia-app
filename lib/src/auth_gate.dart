import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';

import '../firebase_options.dart';
import 'auth/FirestoreAdminDoc.dart';
import 'home.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

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
        final firestoreRef =
            FirebaseFirestore.instance.collection('users').doc('admins').get();
        return FutureBuilder(
            future: firestoreRef,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text(snapshot.error.toString()));
              } else if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final data =
                  FirestoreAdminDoc.fromJson(snapshot.requireData.data());
              final currentUser =
                  FirebaseAuth.instance.currentUser?.email ?? 'anonymous';
              final isCurrentUserAdmin = data.languagePackAdmins
                  .map((lpa) => lpa.emailId)
                  .toList()
                  .contains(currentUser);
              return HomeController(isCurrentUserAdmin: isCurrentUserAdmin);
            });
      },
    );
  }
}
