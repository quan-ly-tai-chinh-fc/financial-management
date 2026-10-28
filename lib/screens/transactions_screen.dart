import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../app_state.dart';
import '../core/format.dart';
import '../data/models.dart';
import '../widgets/common.dart';
import 'transaction_form_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});
  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String? _type;
  String _search = '';
  DateTimeRange? _range;

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final r = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _range,
    );
    if (r != null) setState(() => _range = r);
  }

  Future<void> _export() async {
    final app = context.read<AppState>();
    try {
      final csv = await app.db.exportCsv(app.uid);
      final dir = await getTemporaryDirectory();
      final f = File('${dir.path}/fincare_giao_dich_${ymd(DateTime.now())}.csv');
      await f.writeAsString(csv);
      await Share.shareXFiles([XFile(f.path)], subject: 'Giao dịch FINCARE');
    } catch (e) {
      if (mounted) snack(context, 'Không xuất được CSV: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 8, 0),
        child: Row(children: [
          Expanded(child: Text('Giao dịch', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800))),
          IconButton(
            tooltip: 'Lọc theo ngày',
            icon: Icon(Icons.date_range, color: _range != null ? Theme.of(context).colorScheme.primary : null),
            onPressed: _pickRange,
          ),
          IconButton(tooltip: 'Xuất CSV', icon: const Icon(Icons.ios_share), onPressed: _export),
        ]),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
        child: TextField(
          decoration: const InputDecoration(hintText: 'Tìm theo ghi chú, danh mục…', prefixIcon: Icon(Icons.search), isDense: true),
          onChanged: (v) => setState(() => _search = v),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(children: [
          for (final e in const [(null, 'Tất cả'), ('income', 'Thu'), ('expense', 'Chi')])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(label: Text(e.$2), selected: _type == e.$1, onSelected: (_) => setState(() => _type = e.$1)),
            ),
          if (_range != null)
            InputChip(
              label: Text('${dmy(ymd(_range!.start))} → ${dmy(ymd(_range!.end))}', style: const TextStyle(fontSize: 12)),
              onDeleted: () => setState(() => _range = null),
            ),
        ]),
      ),
      Expanded(
        child: DataView<List<TxItem>>(
          deps: [_type, _search, _range],
          load: () => app.db.transactions(
            app.uid,
            type: _type,
            search: _search,
            from: _range == null ? null : ymd(_range!.start),
            to: _range == null ? null : ymd(_range!.end),
          ),
          builder: (context, list) {
            if (list.isEmpty) return const EmptyState(text: 'Không có giao dịch nào phù hợp.');
            final inc = list.where((t) => t.isIncome).fold<double>(0, (s, t) => s + t.amount);
            final exp = list.where((t) => !t.isIncome).fold<double>(0, (s, t) => s + t.amount);
            return Column(children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('${list.length} giao dịch', style: TextStyle(color: Theme.of(context).hintColor)),
                  Text('+${money(inc)}  /  -${money(exp)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                ]),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 96),
                  itemCount: list.length,
                  itemBuilder: (c, i) {
                    final t = list[i];
                    return Dismissible(
                      key: ValueKey('tx${t.id}'),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (_) => confirmDialog(context, 'Xoá giao dịch này?'),
                      onDismissed: (_) async {
                        await app.db.deleteTransaction(app.uid, t.id);
                        app.bump();
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 3),
                        child: TxTile(t: t, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TransactionFormScreen(edit: t)))),
                      ),
                    );
                  },
                ),
              ),
            ]);
          },
        ),
      ),
    ]);
  }
}
