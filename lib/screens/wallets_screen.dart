import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../data/models.dart';
import '../widgets/common.dart';

const _walletTypes = {'cash': 'Tiền mặt', 'bank': 'Ngân hàng', 'ewallet': 'Ví điện tử', 'other': 'Khác'};

class WalletsScreen extends StatelessWidget {
  const WalletsScreen({super.key});

  Future<void> _edit(BuildContext context, {Wallet? w}) async {
    final app = context.read<AppState>();
    final name = TextEditingController(text: w?.name ?? '');
    final initial = TextEditingController(text: amountText(w?.initialBalance ?? 0));
    var type = w?.type ?? 'cash';
    var icon = w?.icon ?? '💵';
    var color = w?.color ?? '#1796A4';
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setS) => AlertDialog(
          title: Text(w == null ? 'Thêm ví mới' : 'Sửa ví'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Tên ví')),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(labelText: 'Loại'),
                items: [for (final e in _walletTypes.entries) DropdownMenuItem(value: e.key, child: Text(e.value))],
                onChanged: (v) => setS(() => type = v!),
              ),
              const SizedBox(height: 12),
              amountField(initial, label: 'Số dư ban đầu (đ)'),
              const SizedBox(height: 14),
              EmojiColorPicker(icon: icon, color: color, onChanged: (i, col) => setS(() {
                    icon = i;
                    color = col;
                  })),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Huỷ')),
            FilledButton(style: FilledButton.styleFrom(minimumSize: const Size(80, 40)), onPressed: () => Navigator.pop(c, true), child: const Text('Lưu')),
          ],
        ),
      ),
    );
    if (ok != true) return;
    if (name.text.trim().length < 2) {
      if (context.mounted) snack(context, 'Tên ví phải có ít nhất 2 ký tự.');
      return;
    }
    await app.db.saveWallet(app.uid, id: w?.id, name: name.text, type: type, icon: icon, color: color, initial: parseAmount(initial.text));
    app.bump();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Ví / Tài khoản')),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _edit(context), icon: const Icon(Icons.add), label: const Text('Thêm ví')),
      body: DataView<List<Wallet>>(
        load: () => app.db.wallets(app.uid),
        builder: (context, list) {
          final total = list.fold<double>(0, (s, w) => s + w.balance);
          return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 96), children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: kPrimary),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('TỔNG TÀI SẢN HIỆN CÓ', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(moneyD(total), style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
              ]),
            ),
            const SizedBox(height: 12),
            for (final w in list)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  leading: CatAvatar(icon: w.icon, color: w.color),
                  title: Text(w.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(_walletTypes[w.type] ?? w.type),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text(moneyD(w.balance), style: TextStyle(fontWeight: FontWeight.w700, color: w.balance >= 0 ? null : kExpense)),
                    PopupMenuButton<String>(
                      onSelected: (v) async {
                        if (v == 'edit') {
                          _edit(context, w: w);
                        } else if (await confirmDialog(context, 'Xoá ví "${w.name}"? Giao dịch của ví sẽ không gắn với ví nào.')) {
                          await app.db.deleteWallet(app.uid, w.id);
                          app.bump();
                        }
                      },
                      itemBuilder: (_) => const [PopupMenuItem(value: 'edit', child: Text('Sửa')), PopupMenuItem(value: 'del', child: Text('Xoá'))],
                    ),
                  ]),
                ),
              ),
          ]);
        },
      ),
    );
  }
}
