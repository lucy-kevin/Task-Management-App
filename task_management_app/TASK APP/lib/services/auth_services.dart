import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  // Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Update display name
        await result.user!.updateDisplayName(displayName);

        // Create user document in Firestore
        await _firestore.collection('users').doc(result.user!.uid).set({
          'uid': result.user!.uid,
          'email': email,
          'displayName': displayName,
          'role': 'user',
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        });

        _currentUser = result.user;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  // Sign in with email and password
  Future<bool> signIn({required String email, required String password}) async {
    try {
      _errorMessage = null;
      _isLoading = true;
      notifyListeners();

      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Update last login time
        await _firestore.collection('users').doc(result.user!.uid).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });

        _currentUser = result.user;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to sign out';
      notifyListeners();
    }
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getErrorMessage(e.code);
      notifyListeners();
      return false;
    }
  }

  // Update user profile
  Future<bool> updateProfile({String? displayName, String? photoURL}) async {
    try {
      if (_currentUser != null) {
        await _currentUser!.updateDisplayName(displayName);
        await _currentUser!.updatePhotoURL(photoURL);

        // Update Firestore document
        await _firestore.collection('users').doc(_currentUser!.uid).update({
          'displayName': displayName,
          'photoURL': photoURL,
        });

        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = 'Failed to update profile';
      notifyListeners();
    }
    return false;
  }

  // Get user role from Firestore
  Future<String> getUserRole() async {
    if (_currentUser != null) {
      try {
        final doc = await _firestore
            .collection('users')
            .doc(_currentUser!.uid)
            .get();
        return doc.data()?['role'] ?? 'user';
      } catch (e) {
        return 'user';
      }
    }
    return 'user';
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Helper method to get user-friendly error messages
  String _getErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
