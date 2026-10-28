import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../core/theme.dart';
import '../widgets/common.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _name;
  final _old = TextEditingController();
  final _new1 = TextEditingController();
  final _new2 = TextEditingController();

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: context.read<AppState>().user!.name);
  }

  Future<void> _saveName() async {
    if (_name.text.trim().length < 2) return snack(context, 'Tên phải có ít nhất 2 ký tự.');
    await context.read<AppState>().renameUser(_name.text);
    if (mounted) snack(context, 'Đã cập nhật hồ sơ.');
  }

  Future<void> _changePw() async {
    final n = _new1.text;
    if (n.length < 8 || !RegExp(r'[A-Za-z]').hasMatch(n) || !RegExp(r'\d').hasMatch(n)) {
      return snack(context, 'Mật khẩu mới tối thiểu 8 ký tự, gồm chữ và số.');
    }
    if (n != _new2.text) return snack(context, 'Mật khẩu nhập lại không khớp.');
    final app = context.read<AppState>();
    try {
      await app.db.changePassword(app.uid, _old.text, n);
      _old.clear();
      _new1.clear();
      _new2.clear();
      if (mounted) snack(context, 'Đổi mật khẩu thành công.');
    } catch (e) {
      if (mounted) snack(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Center(
          child: CircleAvatar(
            radius: 40,
            backgroundColor: kPrimary,
            child: Text(app.user!.name.isNotEmpty ? app.user!.name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 8),
        Center(child: Text(app.user!.email, style: TextStyle(color: Theme.of(context).hintColor))),
        const SizedBox(height: 20),
        TextField(controller: _name, decoration: const InputDecoration(labelText: 'Họ và tên')),
        const SizedBox(height: 12),
        FilledButton(onPressed: _saveName, child: const Text('Lưu thông tin')),
        const SizedBox(height: 28),
        const Text('Đổi mật khẩu', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        const SizedBox(height: 12),
        TextField(controller: _old, obscureText: true, decoration: const InputDecoration(labelText: 'Mật khẩu hiện tại')),
        const SizedBox(height: 12),
        TextField(controller: _new1, obscureText: true, decoration: const InputDecoration(labelText: 'Mật khẩu mới')),
        const SizedBox(height: 12),
        TextField(controller: _new2, obscureText: true, decoration: const InputDecoration(labelText: 'Nhập lại mật khẩu mới')),
        const SizedBox(height: 12),
        FilledButton.tonal(onPressed: _changePw, style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)), child: const Text('Đổi mật khẩu')),
      ]),
    );
  }
}
