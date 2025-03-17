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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: "AIzaSyAHvA0yfRKhg-tjjyL1HHGIP1nTMxmSHvs",
    authDomain: "fir-app-f68a4.firebaseapp.com",
    databaseURL: "https://fir-app-f68a4-default-rtdb.firebaseio.com",
    projectId: "fir-app-f68a4",
    storageBucket: "fir-app-f68a4.firebasestorage.app",
    messagingSenderId: "921962657285",
    appId: "1:921962657285:web:8eeb8b98086e6fc31ace6c",
    measurementId: "G-P10TZQDV0H",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCzoh7oJXwuymGuXg1LBGUa096hJqwwAFs',
    appId: '1:921962657285:android:eca2f88ad19e4cdd1ace6c',
    messagingSenderId: '921962657285',
    projectId: 'fir-app-f68a4',
    storageBucket: 'fir-app-f68a4.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDibCF_0jk-nX-t8FiNEGbE65b5-aoxo4c',
    appId: '1:921962657285:ios:c9e7e0fb6944486e1ace6c',
    messagingSenderId: '921962657285',
    projectId: 'fir-app-f68a4',
    storageBucket: 'fir-app-f68a4.firebasestorage.app',
    iosBundleId: 'com.example.firebaseAuth',
  );
}

