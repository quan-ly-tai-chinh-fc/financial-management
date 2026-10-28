import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../data/models.dart';
import '../widgets/common.dart';

class LoansScreen extends StatelessWidget {
  const LoansScreen({super.key});

  Future<void> _add(BuildContext context) async {
    final app = context.read<AppState>();
    final person = TextEditingController();
    final amount = TextEditingController();
    final note = TextEditingController();
    var type = 'give';
    DateTime? due;
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setS) => AlertDialog(
          title: const Text('Thêm khoản vay / nợ'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              SegmentedButton<String>(
                segments: const [ButtonSegment(value: 'give', label: Text('Cho vay')), ButtonSegment(value: 'take', label: Text('Đi vay'))],
                selected: {type},
                onSelectionChanged: (s) => setS(() => type = s.first),
              ),
              const SizedBox(height: 12),
              TextField(controller: person, decoration: InputDecoration(labelText: type == 'give' ? 'Người vay' : 'Người cho vay')),
              const SizedBox(height: 12),
              amountField(amount),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final d = await showDatePicker(context: c, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2100));
                  if (d != null) setS(() => due = d);
                },
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Ngày đến hạn (tuỳ chọn)', suffixIcon: Icon(Icons.calendar_today)),
                  child: Text(due == null ? 'Không đặt hạn' : dmy(ymd(due!))),
                ),
              ),
              const SizedBox(height: 12),
              TextField(controller: note, decoration: const InputDecoration(labelText: 'Ghi chú')),
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
    final v = parseAmount(amount.text);
    if (person.text.trim().isEmpty || v <= 0) {
      if (context.mounted) snack(context, 'Vui lòng nhập tên và số tiền hợp lệ.');
      return;
    }
    await app.db.addLoan(app.uid, person: person.text, type: type, amount: v, due: due == null ? null : ymd(due!), note: note.text);
    app.bump();
  }

  void _detail(BuildContext context, Loan l) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (c) => _LoanDetail(loan: l),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Cho vay & Nợ')),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _add(context), icon: const Icon(Icons.add), label: const Text('Thêm')),
      body: DataView<List<Loan>>(
        load: () => app.db.loans(app.uid),
        builder: (context, list) {
          if (list.isEmpty) return const EmptyState(emoji: '🤝', text: 'Chưa có khoản vay / nợ nào.');
          final recv = list.where((l) => !l.isPaid && l.isGive).fold<double>(0, (s, l) => s + l.remaining);
          final owe = list.where((l) => !l.isPaid && !l.isGive).fold<double>(0, (s, l) => s + l.remaining);
          return ListView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 96), children: [
            Row(children: [
              Expanded(child: _Sum('Phải thu', recv, kIncome)),
              const SizedBox(width: 12),
              Expanded(child: _Sum('Phải trả', owe, kExpense)),
            ]),
            const SizedBox(height: 12),
            for (final l in list)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _detail(context, l),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        CircleAvatar(
                          backgroundColor: (l.isGive ? kIncome : kExpense).withValues(alpha: 0.15),
                          child: Icon(l.isGive ? Icons.call_made : Icons.call_received, color: l.isGive ? kIncome : kExpense),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(l.borrowerName, style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text(
                              '${l.isGive ? 'Cho vay' : 'Đi vay'}${l.dueDate != null ? ' • hạn ${dmy(l.dueDate!)}' : ''}',
                              style: TextStyle(fontSize: 12, color: l.isOverdue ? kExpense : Theme.of(context).hintColor),
                            ),
                          ]),
                        ),
                        if (l.isPaid)
                          const Chip(label: Text('Đã xong'), visualDensity: VisualDensity.compact)
                        else
                          Text(moneyD(l.remaining), style: const TextStyle(fontWeight: FontWeight.w700)),
                      ]),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(value: l.amount > 0 ? (l.paid / l.amount).clamp(0, 1).toDouble() : 0, minHeight: 6, borderRadius: BorderRadius.circular(6)),
                      const SizedBox(height: 4),
                      Text('Đã trả ${moneyD(l.paid)} / ${moneyD(l.amount)}', style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                    ]),
                  ),
                ),
              ),
          ]);
        },
      ),
    );
  }
}

class _Sum extends StatelessWidget {
  final String label;
  final double v;
  final Color color;
  const _Sum(this.label, this.v, this.color);

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: SizedBox(
            width: double.infinity,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
              FittedBox(fit: BoxFit.scaleDown, child: Text(moneyD(v), style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color))),
            ]),
          ),
        ),
      );
}

class _LoanDetail extends StatefulWidget {
  final Loan loan;
  const _LoanDetail({required this.loan});
  @override
  State<_LoanDetail> createState() => _LoanDetailState();
}

class _LoanDetailState extends State<_LoanDetail> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  Future<List<Repayment>>? _hist;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _hist ??= context.read<AppState>().db.repayments(widget.loan.id);
  }

  Future<void> _repay() async {
    final app = context.read<AppState>();
    final nav = Navigator.of(context);
    try {
      await app.db.repay(app.uid, widget.loan, amount: parseAmount(_amount.text), date: ymd(DateTime.now()), note: _note.text);
      app.bump();
      nav.pop();
    } catch (e) {
      if (mounted) snack(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.loan;
    final app = context.read<AppState>();
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(l.borrowerName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          Text('${l.isGive ? 'Cho vay' : 'Đi vay'} ${moneyD(l.amount)} • còn ${moneyD(l.remaining)}'),
          if (l.note.isNotEmpty) Text(l.note, style: TextStyle(color: Theme.of(context).hintColor)),
          const SizedBox(height: 12),
          if (!l.isPaid) ...[
            amountField(_amount, label: l.isGive ? 'Số tiền nhận lại (đ)' : 'Số tiền trả (đ)'),
            const SizedBox(height: 10),
            TextField(controller: _note, decoration: const InputDecoration(labelText: 'Ghi chú')),
            const SizedBox(height: 12),
            FilledButton(onPressed: _repay, child: const Text('Ghi nhận thanh toán')),
            const SizedBox(height: 12),
          ],
          const Text('Lịch sử thanh toán', style: TextStyle(fontWeight: FontWeight.w700)),
          FutureBuilder<List<Repayment>>(
            future: _hist,
            builder: (c, s) {
              final h = s.data ?? [];
              if (h.isEmpty) return const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Chưa có lần thanh toán nào.'));
              return Column(children: [
                for (final r in h) ListTile(dense: true, contentPadding: EdgeInsets.zero, title: Text(moneyD(r.amount)), subtitle: Text('${dmy(r.date)}${r.note.isNotEmpty ? ' • ${r.note}' : ''}')),
              ]);
            },
          ),
          TextButton.icon(
            onPressed: () async {
              final nav = Navigator.of(context);
              if (await confirmDialog(context, 'Xoá khoản này? (Các giao dịch đã sinh ra vẫn được giữ lại)')) {
                await app.db.deleteLoan(app.uid, l.id);
                app.bump();
                nav.pop();
              }
            },
            icon: const Icon(Icons.delete_outline, color: kExpense),
            label: const Text('Xoá khoản này', style: TextStyle(color: kExpense)),
          ),
        ]),
      ),
    );
  }
}
