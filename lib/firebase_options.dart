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
    apiKey: 'AIzaSyChSoFBqYT7UzMnridshGuIyMYTViwQm0Y',
    appId: '1:1098265368760:web:bb9cf4dc5ea69afc407c4d',
    messagingSenderId: '1098265368760',
    projectId: 'qrshare-3e33e',
    authDomain: 'qrshare-3e33e.firebaseapp.com',
    storageBucket: 'qrshare-3e33e.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBCvgqUVphXZ-i8liorSMSIgeNa27cYjL8',
    appId: '1:1098265368760:android:84273d5d96460092407c4d',
    messagingSenderId: '1098265368760',
    projectId: 'qrshare-3e33e',
    storageBucket: 'qrshare-3e33e.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBYRfgjpGUsOM5Zqgn5VpJIGjVXxRt_HHc',
    appId: '1:1098265368760:ios:a65cfccc01f8c7c2407c4d',
    messagingSenderId: '1098265368760',
    projectId: 'qrshare-3e33e',
    storageBucket: 'qrshare-3e33e.appspot.com',
    iosClientId: '1098265368760-i0s4kslmkqn8kr57h27ircm5qsejck90.apps.googleusercontent.com',
    iosBundleId: 'com.example.schoolapPush',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBYRfgjpGUsOM5Zqgn5VpJIGjVXxRt_HHc',
    appId: '1:1098265368760:ios:a65cfccc01f8c7c2407c4d',
    messagingSenderId: '1098265368760',
    projectId: 'qrshare-3e33e',
    storageBucket: 'qrshare-3e33e.appspot.com',
    iosClientId: '1098265368760-i0s4kslmkqn8kr57h27ircm5qsejck90.apps.googleusercontent.com',
    iosBundleId: 'com.example.schoolapPush',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyChSoFBqYT7UzMnridshGuIyMYTViwQm0Y',
    appId: '1:1098265368760:web:d766efcd295ff9f7407c4d',
    messagingSenderId: '1098265368760',
    projectId: 'qrshare-3e33e',
    authDomain: 'qrshare-3e33e.firebaseapp.com',
    storageBucket: 'qrshare-3e33e.appspot.com',
  );
}
