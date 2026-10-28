import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../core/format.dart';
import '../data/models.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});
  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  void _shift(int d) => setState(() => _month = DateTime(_month.year, _month.month + d));

  Future<void> _add() async {
    final app = context.read<AppState>();
    final cats = await app.db.categories(app.uid, type: 'expense');
    if (!mounted) return;
    int? catId;
    final limit = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setS) => AlertDialog(
          title: Text('Đặt ngân sách ${_month.month}/${_month.year}'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<int>(
              value: catId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Danh mục chi tiêu'),
              items: [for (final x in cats) DropdownMenuItem(value: x.id, child: Text('${x.icon}  ${x.name}'))],
              onChanged: (v) => setS(() => catId = v),
            ),
            const SizedBox(height: 12),
            amountField(limit, label: 'Hạn mức (đ)'),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Huỷ')),
            FilledButton(style: FilledButton.styleFrom(minimumSize: const Size(80, 40)), onPressed: () => Navigator.pop(c, true), child: const Text('Lưu')),
          ],
        ),
      ),
    );
    if (ok != true) return;
    final v = parseAmount(limit.text);
    if (catId == null || v <= 0) {
      if (mounted) snack(context, 'Vui lòng chọn danh mục và nhập hạn mức hợp lệ.');
      return;
    }
    await app.db.saveBudget(app.uid, categoryId: catId!, month: ym(_month), limit: v);
    app.bump();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    final m = ym(_month);
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
        child: Row(children: [
          Expanded(child: Text('Ngân sách', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))),
          FilledButton.icon(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
            onPressed: _add,
            icon: const Icon(Icons.add),
            label: const Text('Đặt hạn mức'),
          ),
          const SizedBox(width: 8),
        ]),
      ),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => _shift(-1)),
        Text('Tháng ${_month.month}/${_month.year}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => _shift(1)),
      ]),
      Expanded(
        child: DataView<List<Budget>>(
          deps: [m],
          load: () => app.db.budgets(app.uid, m),
          builder: (context, list) {
            if (list.isEmpty) return const EmptyState(emoji: '🎯', text: 'Chưa có ngân sách cho tháng này.\nHãy đặt hạn mức cho các danh mục chi tiêu.');
            final totalLimit = list.fold<double>(0, (s, b) => s + b.limit);
            final totalSpent = list.fold<double>(0, (s, b) => s + b.spent);
            return ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Tổng hạn mức'),
                      Text(moneyD(totalLimit), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    ]),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      const Text('Đã chi'),
                      Text(moneyD(totalSpent), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    ]),
                  ]),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: Column(children: [
                    for (final b in list)
                      BudgetTile(
                        b: b,
                        onDelete: () async {
                          if (await confirmDialog(context, 'Xoá ngân sách "${b.catName}"?')) {
                            await app.db.deleteBudget(app.uid, b.id);
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
      ),
    ]);
  }
}
