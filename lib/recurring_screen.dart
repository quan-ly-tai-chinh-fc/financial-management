import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../data/models.dart';
import '../widgets/common.dart';

class RecurringScreen extends StatelessWidget {
  const RecurringScreen({super.key});

  Future<void> _edit(BuildContext context, {Recurring? r}) async {
    final app = context.read<AppState>();
    final cats = await app.db.categories(app.uid);
    final wallets = await app.db.wallets(app.uid);
    if (!context.mounted) return;
    final title = TextEditingController(text: r?.title ?? '');
    final amount = TextEditingController(text: amountText(r?.amount ?? 0));
    var type = r?.type ?? 'expense';
    var day = r?.day ?? 1;
    int? catId = r?.categoryId;
    int? walletId = r?.walletId ?? (wallets.isNotEmpty ? wallets.first.id : null);
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setS) {
          final typed = cats.where((x) => x.type == type).toList();
          return AlertDialog(
            title: Text(r == null ? 'Thêm khoản định kỳ' : 'Sửa khoản định kỳ'),
            content: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                SegmentedButton<String>(
                  segments: const [ButtonSegment(value: 'expense', label: Text('Chi')), ButtonSegment(value: 'income', label: Text('Thu'))],
                  selected: {type},
                  onSelectionChanged: (s) => setS(() {
                    type = s.first;
                    catId = null;
                  }),
                ),
                const SizedBox(height: 12),
                TextField(controller: title, decoration: const InputDecoration(labelText: 'Tên khoản (vd: Tiền nhà)')),
                const SizedBox(height: 12),
                amountField(amount),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: day,
                  decoration: const InputDecoration(labelText: 'Ngày trong tháng'),
                  items: [for (var i = 1; i <= 31; i++) DropdownMenuItem(value: i, child: Text('Ngày $i'))],
                  onChanged: (v) => setS(() => day = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: typed.any((x) => x.id == catId) ? catId : null,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Danh mục'),
                  items: [for (final x in typed) DropdownMenuItem(value: x.id, child: Text('${x.icon}  ${x.name}'))],
                  onChanged: (v) => setS(() => catId = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: wallets.any((w) => w.id == walletId) ? walletId : null,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Ví'),
                  items: [for (final w in wallets) DropdownMenuItem(value: w.id, child: Text('${w.icon}  ${w.name}'))],
                  onChanged: (v) => setS(() => walletId = v),
                ),
              ]),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Huỷ')),
              FilledButton(style: FilledButton.styleFrom(minimumSize: const Size(80, 40)), onPressed: () => Navigator.pop(c, true), child: const Text('Lưu')),
            ],
          );
        },
      ),
    );
    if (ok != true) return;
    final v = parseAmount(amount.text);
    if (title.text.trim().isEmpty || v <= 0) {
      if (context.mounted) snack(context, 'Vui lòng nhập tên và số tiền hợp lệ.');
      return;
    }
    await app.db.saveRecurring(app.uid, id: r?.id, title: title.text, type: type, amount: v, day: day, categoryId: catId, walletId: walletId);
    final n = await app.db.processRecurring(app.uid);
    app.bump();
    if (n > 0 && context.mounted) snack(context, 'Đã ghi nhận $n khoản định kỳ đến hạn.');
  }

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Giao dịch định kỳ')),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _edit(context), icon: const Icon(Icons.add), label: const Text('Thêm')),
      body: DataView<List<Recurring>>(
        load: () => app.db.recurring(app.uid),
        builder: (context, list) {
          if (list.isEmpty) return const EmptyState(emoji: '🔁', text: 'Chưa có khoản định kỳ nào.\nVí dụ: tiền nhà, lương, internet…');
          return ListView(padding: const EdgeInsets.fromLTRB(12, 8, 12, 96), children: [
            for (final r in list)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  onTap: () => _edit(context, r: r),
                  leading: CircleAvatar(backgroundColor: (r.type == 'income' ? kIncome : kExpense).withValues(alpha: 0.15), child: Text(r.catIcon)),
                  title: Text(r.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('Ngày ${r.day} hằng tháng • ${r.type == 'income' ? '+' : '-'}${moneyD(r.amount)}'),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    Switch(
                      value: r.active,
                      onChanged: (v) async {
                        await app.db.setRecurringActive(app.uid, r.id, v);
                        app.bump();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: kExpense),
                      onPressed: () async {
                        if (await confirmDialog(context, 'Xoá khoản định kỳ "${r.title}"?')) {
                          await app.db.deleteRecurring(app.uid, r.id);
                          app.bump();
                        }
                      },
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
