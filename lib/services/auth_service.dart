import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cipherx/services/sharedpreference_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Email and Password Sign Up
  Future<User?> signUpWithEmail(String email, String password, String name) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(name);
      await _saveUserData(userCredential.user, name);
      await _saveUserToFirestore(userCredential.user, name);
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  // Email and Password Login
  Future<User?> loginWithEmail(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _saveUserData(userCredential.user, userCredential.user?.displayName ?? '');
      await _saveLoginTimestamp(userCredential.user);
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  // Google Sign Up/Login
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      if (googleAuth == null || googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Google authentication failed');
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);
      await _saveUserData(userCredential.user, userCredential.user?.displayName ?? '');
      await _saveUserToFirestore(userCredential.user, userCredential.user?.displayName ?? '');
      await _saveLoginTimestamp(userCredential.user);
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _saveUserData(User? user, String name) async {
    if (user == null) return;

    await SharedPreferencesHelper.setLoggedIn(true);
    await SharedPreferencesHelper.setName(name);
  }

  Future<void> _saveUserToFirestore(User? user, String name) async {
    if (user == null) return;

    final userRef = _firestore.collection('users').doc(user.email);
    final userData = {
      'name': name,
      'email': user.email,
      'createdAt': FieldValue.serverTimestamp(),
    };

    final doc = await userRef.get();
    if (!doc.exists) {
      await userRef.set(userData);
    }
  }

  Future<void> _saveLoginTimestamp(User? user) async {
    if (user == null) return;

    final userRef = _firestore.collection('users').doc(user.email);
    await userRef.update({
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }

  // Logout
  Future<void> logout() async {
    try {
      if (_googleSignIn.currentUser != null) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
      await SharedPreferencesHelper.setLoggedIn(false);
    } catch (e) {
      rethrow;
    }
  }

  bool isUserSignedIn() {
    return _auth.currentUser != null;
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}
