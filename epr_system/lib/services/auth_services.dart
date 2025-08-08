import 'package:epr_system/services/firebase_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      throw e;
    }
  }

  Future<User?> createDemoAccount() async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final demoEmail = 'demo$timestamp@erpsuite.com';

      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: demoEmail,
        password: 'demo123456',
      );

      await _firestoreService.createUser(credential.user!.uid, {
        'name': 'Demo User',
        'email': demoEmail,
        'role': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return credential.user;
    } catch (e) {
      throw e;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
