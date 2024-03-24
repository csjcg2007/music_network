// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDo4d8xbVgb9dONnqiTZvrZLGj7UNtnwdg',
    appId: '1:943859691073:web:1397db80a5876b98cde0c0',
    messagingSenderId: '943859691073',
    projectId: 'capstone-app-4a4ff',
    authDomain: 'capstone-app-4a4ff.firebaseapp.com',
    storageBucket: 'capstone-app-4a4ff.appspot.com',
    measurementId: 'G-5ED3LYD2WV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCku9xfuRcsPgUX-DVac5Hl5vza2pbuU5I',
    appId: '1:943859691073:android:319f0bfc426d40d6cde0c0',
    messagingSenderId: '943859691073',
    projectId: 'capstone-app-4a4ff',
    storageBucket: 'capstone-app-4a4ff.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAY6CVGxh13v1l79i6yTalfn2_u3z9EXQU',
    appId: '1:943859691073:ios:b2fc25cabe7c1613cde0c0',
    messagingSenderId: '943859691073',
    projectId: 'capstone-app-4a4ff',
    storageBucket: 'capstone-app-4a4ff.appspot.com',
    iosBundleId: 'com.example.flutterApplication1',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAY6CVGxh13v1l79i6yTalfn2_u3z9EXQU',
    appId: '1:943859691073:ios:7942c3eaad145c68cde0c0',
    messagingSenderId: '943859691073',
    projectId: 'capstone-app-4a4ff',
    storageBucket: 'capstone-app-4a4ff.appspot.com',
    iosBundleId: 'com.example.flutterApplication1.RunnerTests',
  );
}
