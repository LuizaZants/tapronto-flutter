import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Ouvir mudanças no estado da autenticação (Logado ou não)
  Stream<User?> get userStream => _auth.authStateChanges();

  // Cadastro
  Future<String?> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return null; // Sucesso
    } on FirebaseAuthException catch (e) {
      return e.message; // Retorna o erro (ex: senha fraca)
    }
  }

  // Login
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  // Sair
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
