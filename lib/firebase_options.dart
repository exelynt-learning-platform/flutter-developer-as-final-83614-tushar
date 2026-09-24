// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDOMW7Kr0d4EdnxmAVj4QEmwsXToD46GeA',
    appId: '1:74409749630:android:d151447e1f052331f1bc2f',
    messagingSenderId: '74409749630',
    projectId: 'exelynt',
    storageBucket: 'exelynt.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDZJ24xhc75pe1A32HZPuCgGGyLhMJB9Ew',
    appId: '1:74409749630:ios:35f706e030e42cddf1bc2f',
    messagingSenderId: '74409749630',
    projectId: 'exelynt',
    storageBucket: 'exelynt.firebasestorage.app',
    androidClientId: '74409749630-qmht38k4bjq3hbhs57bnodojcfi5kjsb.apps.googleusercontent.com',
    iosClientId: '74409749630-148p9gjiohfa8n0q62gpldb2279atg03.apps.googleusercontent.com',
    iosBundleId: 'com.tushar.employeeManagement',
  );
}
