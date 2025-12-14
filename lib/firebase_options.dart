import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Konfigurasi Firebase.
/// Jika Anda menambah platform lain, jalankan `flutterfire configure` supaya
/// nilai di bawah diperbarui otomatis.
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
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'REPLACE_WITH_API_KEY',
    appId: 'REPLACE_WITH_APP_ID',
    messagingSenderId: 'REPLACE_WITH_MESSAGING_SENDER_ID',
    projectId: 'REPLACE_WITH_PROJECT_ID',
    authDomain: 'REPLACE_WITH_AUTH_DOMAIN',
    storageBucket: 'REPLACE_WITH_STORAGE_BUCKET',
    measurementId: 'REPLACE_WITH_MEASUREMENT_ID',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD7hZVacHXsp9g-0SHOJHBB1B-xN65DrrA',
    appId: '1:674685439403:android:74eb6f7986c4750ead96ee',
    messagingSenderId: '674685439403',
    projectId: 'projectdht11-72d14',
    storageBucket: 'projectdht11-72d14.firebasestorage.app',
    databaseURL:
        'https://projectdht11-72d14-default-rtdb.asia-southeast1.firebasedatabase.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'REPLACE_WITH_API_KEY',
    appId: 'REPLACE_WITH_APP_ID',
    messagingSenderId: 'REPLACE_WITH_MESSAGING_SENDER_ID',
    projectId: 'REPLACE_WITH_PROJECT_ID',
    storageBucket: 'REPLACE_WITH_STORAGE_BUCKET',
    iosClientId: 'REPLACE_WITH_IOS_CLIENT_ID',
    iosBundleId: 'REPLACE_WITH_IOS_BUNDLE_ID',
  );

  static const FirebaseOptions macos = ios;

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyD7hZVacHXsp9g-0SHOJHBB1B-xN65DrrA',
    appId: '1:674685439403:android:74eb6f7986c4750ead96ee',
    messagingSenderId: '674685439403',
    projectId: 'projectdht11-72d14',
    storageBucket: 'projectdht11-72d14.firebasestorage.app',
    databaseURL:
        'https://projectdht11-72d14-default-rtdb.asia-southeast1.firebasedatabase.app',
  );

  static const FirebaseOptions linux = windows;
}
