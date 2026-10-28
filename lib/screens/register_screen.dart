import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../widgets/common.dart';

const kSecurityQuestions = [
  'Tên con vật nuôi đầu tiên của bạn là gì?',
  'Tên trường tiểu học của bạn là gì?',
  'Thành phố nơi bạn sinh ra là gì?',
  'Món ăn yêu thích của bạn là gì?',
];

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _pass2 = TextEditingController();
  final _answer = TextEditingController();
  String _question = kSecurityQuestions.first;
  bool _busy = false;

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final app = context.read<AppState>();
    final nav = Navigator.of(context);
    setState(() => _busy = true);
    try {
      final u = await app.db.register(
        name: _name.text,
        email: _email.text,
        password: _pass.text,
        question: _question,
        answer: _answer.text,
      );
      await app.signIn(u);
      nav.popUntil((r) => r.isFirst);
    } catch (e) {
      if (mounted) snack(context, e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _form,
            child: Column(children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Họ và tên'),
                validator: (v) => (v == null || v.trim().length < 2) ? 'Tên phải có ít nhất 2 ký tự' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => (v == null || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) ? 'Email không hợp lệ' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _pass,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mật khẩu', helperText: 'Tối thiểu 8 ký tự, gồm chữ và số'),
                validator: (v) {
                  if (v == null || v.length < 8) return 'Mật khẩu tối thiểu 8 ký tự';
                  if (!RegExp(r'[A-Za-z]').hasMatch(v) || !RegExp(r'\d').hasMatch(v)) return 'Cần có cả chữ và số';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _pass2,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nhập lại mật khẩu'),
                validator: (v) => v != _pass.text ? 'Mật khẩu nhập lại không khớp' : null,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                value: _question,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Câu hỏi bảo mật (để khôi phục mật khẩu)'),
                items: [for (final q in kSecurityQuestions) DropdownMenuItem(value: q, child: Text(q, overflow: TextOverflow.ellipsis))],
                onChanged: (v) => setState(() => _question = v!),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _answer,
                decoration: const InputDecoration(labelText: 'Câu trả lời'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nhập câu trả lời' : null,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _busy ? null : _submit,
                child: _busy ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Tạo tài khoản'),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
