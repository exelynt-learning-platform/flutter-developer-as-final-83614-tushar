import 'package:employee_management/domain/auth/entities/app_user.dart';
import 'package:employee_management/domain/core/error/exceptions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSource({
    required this.firebaseAuth,
    required this.googleSignIn,
  });

  Stream<AppUser> get authStateChanges {
    return firebaseAuth.authStateChanges().map((user) {
      if (user == null) return AppUser.empty;
      return _mapFirebaseUser(user);
    });
  }

  AppUser get currentUser {
    final user = firebaseAuth.currentUser;
    if (user == null) return AppUser.empty;
    return _mapFirebaseUser(user);
  }

  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final result = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _mapFirebaseUser(result.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _mapFirebaseAuthError(e.code),
        code: e.code,
      );
    }
  }

  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final result = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await result.user?.updateDisplayName(name);
      await result.user?.reload();
      final updatedUser = firebaseAuth.currentUser;
      return _mapFirebaseUser(updatedUser ?? result.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _mapFirebaseAuthError(e.code),
        code: e.code,
      );
    }
  }

  Future<void> forgotPassword({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(
        email: email.trim().toLowerCase(),
      );
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _mapFirebaseAuthError(e.code),
        code: e.code,
      );
    }
  }

  Future<AppUser> signInWithGoogle() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException(message: 'Google sign-in was cancelled');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await firebaseAuth.signInWithCredential(credential);
      return _mapFirebaseUser(result.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _mapFirebaseAuthError(e.code),
        code: e.code,
      );
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      firebaseAuth.signOut(),
      googleSignIn.signOut(),
    ]);
  }

  AppUser _mapFirebaseUser(User user) {
    return AppUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? '',
      photoUrl: user.photoURL ?? '',
    );
  }

  String _mapFirebaseAuthError(String code) {
    final normalized = code.replaceFirst('auth/', '').toLowerCase().trim();
    switch (normalized) {
      case 'user-not-found':
        return 'User does not exist. No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'weak-password':
        return 'Password is too weak (min 6 characters)';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'network-request-failed':
        return 'Network error. Check your connection';
      case 'invalid-credential':
        return 'Invalid email or password';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled';
      default:
        return 'Something went wrong. Please try again';
    }
  }
}
