import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<UserCredential> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );

    final user = credential.user;
    if (user != null) {
      await user.updateDisplayName(name.trim());
      await user.reload();
    }

    return credential;
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  Future<void> sendPasswordResetEmail({required String email}) {
    return _firebaseAuth.sendPasswordResetEmail(
      email: email.trim().toLowerCase(),
    );
  }

  Future<void> updateDisplayName(String name) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    await user.updateDisplayName(name.trim());
    await user.reload();
  }

  Future<void> signOut() => _firebaseAuth.signOut();

  static String friendlyMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'Cet email est deja utilise.';
        case 'invalid-email':
          return 'Adresse email invalide.';
        case 'weak-password':
          return 'Le mot de passe est trop faible.';
        case 'user-not-found':
          return 'Aucun compte ne correspond a cet email.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'Email ou mot de passe incorrect.';
        case 'network-request-failed':
          return 'Connexion reseau indisponible. Verifiez Internet puis reessayez.';
        case 'too-many-requests':
          return 'Trop de tentatives. Patientez quelques minutes puis reessayez.';
        default:
          return error.message ?? 'Erreur Firebase Authentication.';
      }
    }

    return 'Une erreur est survenue. Verifiez la configuration Firebase.';
  }
}
