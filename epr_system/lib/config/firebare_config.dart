import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static FirebaseOptions get platformOptions {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: 'AIzaSyCm4NpchbSz-ZzJMLzcHpXU4MANm0eXlDA',
        appId: '1:337910756528:web:77dcdc8a12112eacdff775',
        messagingSenderId: '337910756528',
        projectId: 'modern-erp-suite',
        authDomain: 'modern-erp-suite.firebaseapp.com',
        storageBucket: 'modern-erp-suite.appspot.com',
        measurementId: 'G-VGQPETTS9X',
      );
    } else {
      throw UnsupportedError('This platform is not supported');
    }
  }

  static Future<void> initialize() async {
    try {
      if (kIsWeb) {
        await Firebase.initializeApp(options: platformOptions);
      } else {
        await Firebase.initializeApp();
      }
    } catch (e) {
      print('Firebase initialization failed: $e');
    }
  }
}
