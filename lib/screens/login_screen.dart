import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _hide = true, _busy = false;

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final app = context.read<AppState>();
    setState(() => _busy = true);
    try {
      final u = await app.db.login(_email.text, _pass.text);
      await app.signIn(u);
    } catch (e) {
      if (mounted) snack(context, e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _form,
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  const Icon(Icons.account_balance_wallet_rounded, size: 64, color: kPrimary),
                  const SizedBox(height: 8),
                  Text('FINCARE', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: kPrimary)),
                  const SizedBox(height: 4),
                  Text('Quản lý thu chi cá nhân', textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).hintColor)),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.mail_outline)),
                    validator: (v) => (v == null || !v.contains('@')) ? 'Email không hợp lệ' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _pass,
                    obscureText: _hide,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(icon: Icon(_hide ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _hide = !_hide)),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Nhập mật khẩu' : null,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                      child: const Text('Quên mật khẩu?'),
                    ),
                  ),
                  FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: _busy ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Đăng nhập'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                    child: const Text('Chưa có tài khoản? Đăng ký'),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
