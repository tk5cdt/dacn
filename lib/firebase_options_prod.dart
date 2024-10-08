// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options_prod.dart';
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
    apiKey: 'AIzaSyCfJRE004NsadgHWZNl0USmX7LXIUDZKNk',
    appId: '1:55085904959:web:e4bf736442a9977881f48a',
    messagingSenderId: '55085904959',
    projectId: 'dacn-prod',
    authDomain: 'dacn-prod.firebaseapp.com',
    storageBucket: 'dacn-prod.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCWPVrkVZ7ECJm3OPT9x021Eva4wPIjies',
    appId: '1:55085904959:android:160fe8d3375e06b481f48a',
    messagingSenderId: '55085904959',
    projectId: 'dacn-prod',
    storageBucket: 'dacn-prod.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC8cnitgroEBHq08YWfjyrLwTCkpNfv01w',
    appId: '1:55085904959:ios:2a38a7a37ef8918781f48a',
    messagingSenderId: '55085904959',
    projectId: 'dacn-prod',
    storageBucket: 'dacn-prod.appspot.com',
    androidClientId: '55085904959-djk02k488absqmgpmigpjisb50gpstnv.apps.googleusercontent.com',
    iosClientId: '55085904959-1mmi7rp9c15ra24qbdsksklk4uubu7cv.apps.googleusercontent.com',
    iosBundleId: 'com.dacn.conexion',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyC8cnitgroEBHq08YWfjyrLwTCkpNfv01w',
    appId: '1:55085904959:ios:2a38a7a37ef8918781f48a',
    messagingSenderId: '55085904959',
    projectId: 'dacn-prod',
    storageBucket: 'dacn-prod.appspot.com',
    androidClientId: '55085904959-djk02k488absqmgpmigpjisb50gpstnv.apps.googleusercontent.com',
    iosClientId: '55085904959-1mmi7rp9c15ra24qbdsksklk4uubu7cv.apps.googleusercontent.com',
    iosBundleId: 'com.dacn.conexion',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCfJRE004NsadgHWZNl0USmX7LXIUDZKNk',
    appId: '1:55085904959:web:678cf05f7ecba8de81f48a',
    messagingSenderId: '55085904959',
    projectId: 'dacn-prod',
    authDomain: 'dacn-prod.firebaseapp.com',
    storageBucket: 'dacn-prod.appspot.com',
  );
}
