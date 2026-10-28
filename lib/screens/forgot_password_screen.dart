import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../widgets/common.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  final _answer = TextEditingController();
  final _pass = TextEditingController();
  String? _question; // != null => đang ở bước 2
  bool _busy = false;

  Future<void> _step1() async {
    final app = context.read<AppState>();
    setState(() => _busy = true);
    try {
      final q = await app.db.securityQuestion(_email.text);
      setState(() => _question = q);
    } catch (e) {
      if (mounted) snack(context, e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _step2() async {
    if (_pass.text.length < 8 || !RegExp(r'[A-Za-z]').hasMatch(_pass.text) || !RegExp(r'\d').hasMatch(_pass.text)) {
      snack(context, 'Mật khẩu mới tối thiểu 8 ký tự, gồm chữ và số.');
      return;
    }
    final app = context.read<AppState>();
    final nav = Navigator.of(context);
    setState(() => _busy = true);
    try {
      await app.db.resetPassword(_email.text, _answer.text, _pass.text);
      if (mounted) snack(context, 'Đã đặt lại mật khẩu. Hãy đăng nhập lại.');
      nav.pop();
    } catch (e) {
      if (mounted) snack(context, e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quên mật khẩu')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            TextField(
              controller: _email,
              enabled: _question == null,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email đã đăng ký'),
            ),
            const SizedBox(height: 16),
            if (_question == null)
              FilledButton(onPressed: _busy ? null : _step1, child: const Text('Tiếp tục'))
            else ...[
              Align(alignment: Alignment.centerLeft, child: Text(_question!, style: const TextStyle(fontWeight: FontWeight.w600))),
              const SizedBox(height: 10),
              TextField(controller: _answer, decoration: const InputDecoration(labelText: 'Câu trả lời')),
              const SizedBox(height: 14),
              TextField(controller: _pass, obscureText: true, decoration: const InputDecoration(labelText: 'Mật khẩu mới')),
              const SizedBox(height: 16),
              FilledButton(onPressed: _busy ? null : _step2, child: const Text('Đặt lại mật khẩu')),
            ],
          ]),
        ),
      ),
    );
  }
}
