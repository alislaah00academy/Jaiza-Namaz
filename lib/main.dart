// Jaiza (Namaz) — bootstrap: Firebase, first auth tick, Riverpod root.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Wait until Firebase restores session to avoid auth redirect flicker.
  await FirebaseAuth.instance.authStateChanges().first;
  runApp(
    const ProviderScope(
      child: JaizaNamazApp(),
    ),
  );
}
