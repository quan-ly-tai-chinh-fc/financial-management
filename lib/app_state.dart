import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/db.dart';
import 'data/models.dart';

/// Trạng thái toàn ứng dụng: người dùng đang đăng nhập, giao diện sáng/tối
/// và bộ đếm `rev` để các màn hình tự tải lại dữ liệu sau khi có thay đổi.
class AppState extends ChangeNotifier {
  AppUser? user;
  ThemeMode themeMode = ThemeMode.system;
  bool ready = false;
  int rev = 0;
  String? notice; // thông báo một lần (vd: giao dịch định kỳ vừa được tạo)

  int get uid => user!.id;
  final AppDb db = AppDb.i;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final t = prefs.getString('theme');
      themeMode = t == 'dark' ? ThemeMode.dark : t == 'light' ? ThemeMode.light : ThemeMode.system;
      final id = prefs.getInt('uid');
      if (id != null) {
        user = await db.userById(id);
        if (user != null) await _afterLogin();
      }
    } catch (_) {}
    ready = true;
    notifyListeners();
  }

  Future<void> _afterLogin() async {
    final n = await db.processRecurring(user!.id);
    if (n > 0) notice = 'Đã tự động ghi nhận $n khoản thu/chi định kỳ cho tháng này!';
  }

  Future<void> signIn(AppUser u) async {
    user = u;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('uid', u.id);
    await _afterLogin();
    rev++;
    notifyListeners();
  }

  Future<void> logout() async {
    user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
    notifyListeners();
  }

  Future<void> setTheme(ThemeMode m) async {
    themeMode = m;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', m == ThemeMode.dark ? 'dark' : m == ThemeMode.light ? 'light' : 'system');
    notifyListeners();
  }

  Future<void> renameUser(String name) async {
    await db.updateName(uid, name);
    user = AppUser(id: user!.id, name: name.trim(), email: user!.email);
    notifyListeners();
  }

  String? takeNotice() {
    final n = notice;
    notice = null;
    return n;
  }

  /// Gọi sau mỗi thao tác thêm/sửa/xoá để các màn hình tải lại dữ liệu.
  void bump() {
    rev++;
    notifyListeners();
  }
}
