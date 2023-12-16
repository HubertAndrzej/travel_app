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
    apiKey: 'AIzaSyAS0npYVqiaqN49bgLOjEXlxMIEhS0ddZw',
    appId: '1:691311762145:web:071a3227937307685db5a0',
    messagingSenderId: '691311762145',
    projectId: 'travel-app-93e16',
    authDomain: 'travel-app-93e16.firebaseapp.com',
    storageBucket: 'travel-app-93e16.appspot.com',
    measurementId: 'G-F0W8QNC5QD',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyATsrVwVeuyCX9idSESpRChAt5UccF9YwU',
    appId: '1:691311762145:android:dfb0e8188bfdf7a75db5a0',
    messagingSenderId: '691311762145',
    projectId: 'travel-app-93e16',
    storageBucket: 'travel-app-93e16.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBNFI9FzI0-bVK3MFkDyJZriCfOiE_FIak',
    appId: '1:691311762145:ios:8ef9680ad6b0b8375db5a0',
    messagingSenderId: '691311762145',
    projectId: 'travel-app-93e16',
    storageBucket: 'travel-app-93e16.appspot.com',
    iosBundleId: 'com.example.travelApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBNFI9FzI0-bVK3MFkDyJZriCfOiE_FIak',
    appId: '1:691311762145:ios:05a47900a3fe73945db5a0',
    messagingSenderId: '691311762145',
    projectId: 'travel-app-93e16',
    storageBucket: 'travel-app-93e16.appspot.com',
    iosBundleId: 'com.example.travelApp.RunnerTests',
  );
}
