import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> watchAuthState() => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> register({required String email, required String password}) async {
    final result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await ensureUserProfile(result.user!);
    return result;
  }

  Future<UserCredential> signIn({required String email, required String password}) async {
    final result = await _auth.signInWithEmailAndPassword(email: email, password: password);
    await ensureUserProfile(result.user!);
    return result;
  }

  Future<void> sendPasswordReset(String email) => _auth.sendPasswordResetEmail(email: email);
  Future<void> signOut() => _auth.signOut();

  Future<void> ensureUserProfile(User user) {
    return _firestore.collection('users').doc(user.uid).set({
      'displayName': user.displayName ?? 'Story keeper',
      'preferredLanguage': 'en',
      'timeZone': DateTime.now().timeZoneName,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
