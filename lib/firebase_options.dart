// File generated normally by the FlutterFire CLI.
//
// IMPORTANT: This is a PLACEHOLDER. You must replace this file by running:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// ...from inside the `student_corner` project folder, signed in to the SAME
// Firebase project your website (Student-Corner) already uses. This will
// regenerate this file automatically with your real project's keys, and the
// app will then read/write the exact same Firestore `resources` and `users`
// collections your website uses.
//
// Do NOT just fill in values by hand below without running flutterfire
// configure at least once — it also registers the Android/iOS apps in your
// Firebase project, which is required for auth + Firestore to work.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    authDomain: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_ME',
    appId: 'REPLACE_ME',
    messagingSenderId: 'REPLACE_ME',
    projectId: 'REPLACE_ME',
    storageBucket: 'REPLACE_ME',
    iosBundleId: 'com.example.studentCorner',
  );
}
