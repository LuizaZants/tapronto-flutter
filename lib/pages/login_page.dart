import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _auth      = AuthService();
  bool _isLogin    = true;
  bool _loading    = false;

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) return;
    setState(() => _loading = true);
    final error = _isLogin
        ? await _auth.signIn(email, pass)
        : await _auth.signUp(email, pass);
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red.shade700));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            // Logo
            const Text('Tá', style: TextStyle(fontFamily: 'Georgia', fontSize: 48,
                color: AppTheme.textDark, fontWeight: FontWeight.w700)),
            const Text('Pronto!', style: TextStyle(fontFamily: 'Georgia', fontSize: 48,
                color: AppTheme.primary, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Container(height: 2, width: 60, color: AppTheme.primary),
            const SizedBox(height: 8),
            Text(_isLogin ? 'Bem-vindo de volta' : 'Crie sua conta',
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, letterSpacing: 0.5)),
            const SizedBox(height: 40),

            // Campos
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textMuted, size: 20),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _passCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha',
                prefixIcon: Icon(Icons.lock_outline, color: AppTheme.textMuted, size: 20),
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                child: _loading
                    ? const SizedBox(height: 18, width: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(_isLogin ? 'ENTRAR' : 'CADASTRAR',
                        style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.5)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => setState(() => _isLogin = !_isLogin),
              child: Text(
                _isLogin ? 'Não tem conta? Cadastre-se' : 'Já tem conta? Entre aqui',
                style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
      ),
    );
  }
}
