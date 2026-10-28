import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../core/theme.dart';
import '../widgets/common.dart';
import 'categories_screen.dart';
import 'loans_screen.dart';
import 'profile_screen.dart';
import 'recurring_screen.dart';
import 'wallets_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    void go(Widget w) => Navigator.push(context, MaterialPageRoute(builder: (_) => w));
    Widget item(IconData i, String t, String sub, Widget page) => ListTile(
          leading: CircleAvatar(backgroundColor: kPrimary.withValues(alpha: 0.12), child: Icon(i, color: kPrimary)),
          title: Text(t, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(sub),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => go(page),
        );

    return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), children: [
      Text('Khác', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
      const SizedBox(height: 12),
      Card(
        child: ListTile(
          contentPadding: const EdgeInsets.all(14),
          leading: CircleAvatar(
            radius: 26,
            backgroundColor: kPrimary,
            child: Text(app.user!.name.isNotEmpty ? app.user!.name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
          ),
          title: Text(app.user!.name, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(app.user!.email),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => go(const ProfileScreen()),
        ),
      ),
      const SizedBox(height: 12),
      Card(
        child: Column(children: [
          item(Icons.account_balance_wallet_outlined, 'Ví / Tài khoản', 'Tiền mặt, ngân hàng, ví điện tử', const WalletsScreen()),
          item(Icons.category_outlined, 'Danh mục', 'Quản lý danh mục thu / chi', const CategoriesScreen()),
          item(Icons.handshake_outlined, 'Cho vay & Nợ', 'Theo dõi khoản phải thu / phải trả', const LoansScreen()),
          item(Icons.event_repeat, 'Giao dịch định kỳ', 'Tiền nhà, lương, hoá đơn hằng tháng', const RecurringScreen()),
        ]),
      ),
      const SizedBox(height: 12),
      Card(
        child: SwitchListTile(
          secondary: const Icon(Icons.dark_mode_outlined),
          title: const Text('Giao diện tối'),
          value: Theme.of(context).brightness == Brightness.dark,
          onChanged: (v) => app.setTheme(v ? ThemeMode.dark : ThemeMode.light),
        ),
      ),
      const SizedBox(height: 12),
      Card(
        child: ListTile(
          leading: const Icon(Icons.logout, color: kExpense),
          title: const Text('Đăng xuất', style: TextStyle(color: kExpense, fontWeight: FontWeight.w600)),
          onTap: () async {
            if (await confirmDialog(context, 'Bạn muốn đăng xuất?', ok: 'Đăng xuất')) app.logout();
          },
        ),
      ),
    ]);
  }
}
