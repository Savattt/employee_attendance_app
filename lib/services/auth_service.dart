import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign up with email & password
  Future<UserCredential> signUp(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    // Save user data to Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(cred.user!.uid)
        .set({
          'email': email,
          'displayName': cred.user!.displayName,
          'role': 'employee',
        });
    return cred;
  }

  // Sign in with email & password
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Fetch user data from Firestore, create if missing
  Future<UserModel?> getUserData(String uid) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final doc = await docRef.get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, uid);
    } else {
      // If missing, create with default role
      final user = _auth.currentUser;
      if (user != null) {
        final userData = {
          'email': user.email ?? '',
          'displayName': user.displayName,
          'role': 'employee',
        };
        await docRef.set(userData);
        return UserModel.fromMap(userData, uid);
      }
    }
    return null;
  }

  // Promote a user to admin or HR
  Future<void> setUserRole(String uid, String role) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'role': role,
    });
  }
}
