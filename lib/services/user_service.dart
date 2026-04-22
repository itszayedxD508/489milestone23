import '../models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsi;

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> _processFirebaseCredential(fba.UserCredential cred) async {
    final uid = cred.user!.uid;
    final email = cred.user!.email ?? 'google_user';
    final doc = await _firestore.collection('users').doc(uid).get();

    if (doc.exists && doc.data() != null) {
      final user = User.fromMap(doc.data()!);
      await _saveUserId(uid);
      return user;
    } else {
      final user = User(id: uid, username: email);
      await _firestore.collection('users').doc(uid).set(user.toMap());
      await _saveUserId(uid);
      return user;
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      final cred = await fba.FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await _processFirebaseCredential(cred);
    } catch (e) {
      return null;
    }
  }

  Future<User?> signup(String email, String password) async {
    try {
      final cred = await fba.FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return await _processFirebaseCredential(cred);
    } catch (e) {
      return null;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final authProvider = fba.GoogleAuthProvider();
        final cred = await fba.FirebaseAuth.instance.signInWithPopup(
          authProvider,
        );
        return await _processFirebaseCredential(cred);
      } else {
        final googleSignIn = gsi.GoogleSignIn.instance;
        // Optionally pass configuration to initialize if needed; usually defaults are fine.
        await googleSignIn.initialize();
        final googleUser = await googleSignIn.authenticate();
        final googleAuth = googleUser.authentication;
        final authz = await googleUser.authorizationClient
            .authorizationForScopes([]);
        final credential = fba.GoogleAuthProvider.credential(
          accessToken: authz?.accessToken,
          idToken: googleAuth.idToken,
        );
        final cred = await fba.FirebaseAuth.instance.signInWithCredential(
          credential,
        );
        return await _processFirebaseCredential(cred);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Google Sign-In Error: $e");
      }
      return null;
    }
  }

  Future<void> _saveUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user_id', id);
  }

  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('current_user_id');
    if (id != null) {
      final doc = await _firestore.collection('users').doc(id).get();
      if (doc.exists && doc.data() != null) {
        return User.fromMap(doc.data()!);
      }
    }
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user_id');
    await fba.FirebaseAuth.instance.signOut();
  }

  Future<void> addXp(User user, int xp) async {
    if (user.id == null) return;
    await _firestore.collection('users').doc(user.id!).update({
      'total_xp': FieldValue.increment(xp),
    });
  }
}
