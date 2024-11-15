// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
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
    apiKey: 'AIzaSyA3dcmgspdJurKLxoymNTt_c-fmF08rRjM',
    appId: '1:457835806108:web:6635e63166e964cbefdc59',
    messagingSenderId: '457835806108',
    projectId: 'flutterproyectnotes',
    authDomain: 'flutterproyectnotes.firebaseapp.com',
    storageBucket: 'flutterproyectnotes.firebasestorage.app',
    measurementId: 'G-68VK13QRTC',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAscy3LQSm69Vcy3lyB6zQY9IWXp-pswUU',
    appId: '1:457835806108:android:a5a710b7c36603d7efdc59',
    messagingSenderId: '457835806108',
    projectId: 'flutterproyectnotes',
    storageBucket: 'flutterproyectnotes.firebasestorage.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyA3dcmgspdJurKLxoymNTt_c-fmF08rRjM',
    appId: '1:457835806108:web:99363fe65b873892efdc59',
    messagingSenderId: '457835806108',
    projectId: 'flutterproyectnotes',
    authDomain: 'flutterproyectnotes.firebaseapp.com',
    storageBucket: 'flutterproyectnotes.firebasestorage.app',
    measurementId: 'G-1GBL4ZQ4NH',
  );
}
