import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get user => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<String?> register(
    String email,
    String password,
    String name,
    String role, {
    String phoneNumber = '',
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firestore.collection('users').doc(result.user!.uid).set({
        'name': name,
        'email': email,
        'role': role,
        'photoUrl': '',
        'city': '',
        'bio': '',
        'phoneNumber': phoneNumber,
        'createdAt': Timestamp.now(),
      });
      // After registration, sign out so user must manually login for first time
      await _auth.signOut();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'user-not-found':
          msg = 'No account found.';
          break;
        case 'wrong-password':
          msg = 'Wrong password.';
          break;
        case 'invalid-email':
          msg = 'Invalid email.';
          break;
        default:
          msg = 'Login failed.';
      }
      return msg;
    } catch (e) {
      return 'Network error.';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
