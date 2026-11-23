import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleOnlyAccountException implements Exception {
  const GoogleOnlyAccountException();
  @override
  String toString() => 'user-signed-up-with-google';
}

class AuthRepository {
  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> watchAuthState() => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> register({
    required String email,
    required String password,
  }) async {
    final methods = await _signInMethods(email);
    if (methods.contains('google.com') && !methods.contains('password')) {
      throw const GoogleOnlyAccountException();
    }
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await ensureUserProfile(result.user!);
    return result;
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final methods = await _signInMethods(email);
    if (methods.contains('google.com') && !methods.contains('password')) {
      throw const GoogleOnlyAccountException();
    }
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await ensureUserProfile(result.user!);
      return result;
    } on FirebaseAuthException catch (error) {
      if (error.code == 'user-not-found' && methods.contains('google.com')) {
        throw const GoogleOnlyAccountException();
      }
      rethrow;
    }
  }

  Future<List<String>> _signInMethods(String email) async {
    // Firebase deprecated this client-side discovery API in favor of
    // provider-neutral errors, but it is still the only safe way to explain
    // the Google-only/password mismatch to the user in this flow.
    // ignore: deprecated_member_use
    return _auth.fetchSignInMethodsForEmail(email);
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);
  Future<void> signOut() => _auth.signOut();

  static Future<void>? _googleInitialization;

  Future<UserCredential?> signInWithGoogle() async {
    _googleInitialization ??= GoogleSignIn.instance.initialize();
    await _googleInitialization;
    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      throw UnsupportedError(
        'Google sign-in is not supported on this platform.',
      );
    }
    final account = await GoogleSignIn.instance.authenticate();
    final credential = GoogleAuthProvider.credential(
      idToken: account.authentication.idToken,
    );
    final result = await _auth.signInWithCredential(credential);
    if (result.user != null) await ensureUserProfile(result.user!);
    return result;
  }

  Future<void> ensureUserProfile(User user) {
    return _firestore.collection('users').doc(user.uid).set({
      'displayName': user.displayName ?? 'Story keeper',
      'preferredLanguage': 'en',
      'timeZone': DateTime.now().timeZoneName,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
