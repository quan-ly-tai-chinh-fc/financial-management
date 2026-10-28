import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../data/models.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';
import 'transaction_form_screen.dart';

class _Dash {
  final Totals all, month;
  final List<MonthStat> trend;
  final List<CatTotal> cats;
  final List<Budget> budgets;
  final List<TxItem> recent;
  final List<Insight> insights;
  _Dash(this.all, this.month, this.trend, this.cats, this.budgets, this.recent, this.insights);
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  Future<_Dash> _load(AppState app) async {
    final db = app.db, uid = app.uid;
    final now = DateTime.now();
    final m = ym(now);
    return _Dash(
      await db.totals(uid),
      await db.totals(uid, month: m),
      await db.trend6(uid),
      await db.byCategory(uid, type: 'expense', from: '$m-01', to: '$m-31'),
      await db.budgets(uid, m),
      await db.transactions(uid, limit: 8),
      await db.insights(uid),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    return DataView<_Dash>(
      load: () => _load(app),
      builder: (context, d) => ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          Text('Xin chào, ${app.user!.name} 👋', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          _BalanceCard(d.all),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _MiniStat('Thu tháng này', d.month.income, kIncome, Icons.south_west)),
            const SizedBox(width: 12),
            Expanded(child: _MiniStat('Chi tháng này', d.month.expense, kExpense, Icons.north_east)),
          ]),
          if (d.insights.isNotEmpty) ...[
            const SizedBox(height: 12),
            _Section(
              title: '🧠 Trợ lý FINCARE',
              child: Column(children: [for (final i in d.insights) _InsightRow(i)]),
            ),
          ],
          const SizedBox(height: 12),
          _Section(title: 'Xu hướng 6 tháng', child: TrendBarChart(data: d.trend, label: (m) => '${m.ym.substring(5)}/${m.ym.substring(2, 4)}')),
          const SizedBox(height: 12),
          _Section(title: 'Chi tiêu tháng này theo danh mục', child: CategoryPie(data: d.cats)),
          if (d.budgets.isNotEmpty) ...[
            const SizedBox(height: 12),
            _Section(title: 'Ngân sách tháng này', child: Column(children: [for (final b in d.budgets.take(3)) BudgetTile(b: b)])),
          ],
          const SizedBox(height: 12),
          _Section(
            title: 'Giao dịch gần đây',
            child: d.recent.isEmpty
                ? const Padding(padding: EdgeInsets.all(16), child: EmptyState(text: 'Chưa có giao dịch nào.\nBấm "Thêm giao dịch" để bắt đầu!'))
                : Column(children: [
                    for (final t in d.recent)
                      TxTile(
                        t: t,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TransactionFormScreen(edit: t))),
                      ),
                  ]),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 10),
            child,
          ]),
        ),
      );
}

class _BalanceCard extends StatelessWidget {
  final Totals t;
  const _BalanceCard(this.t);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(colors: [Color(0xFF1796A4), Color(0xFF0E6F7A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('SỐ DƯ HIỆN TẠI', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
          const SizedBox(height: 6),
          Text(moneyD(t.balance), style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          Text('Tổng thu ${moneyD(t.income)}  •  Tổng chi ${moneyD(t.expense)}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
      );
}

class _MiniStat extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final IconData icon;
  const _MiniStat(this.label, this.value, this.color, this.icon);

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            CircleAvatar(backgroundColor: color.withValues(alpha: 0.15), child: Icon(icon, color: color, size: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                FittedBox(fit: BoxFit.scaleDown, child: Text(moneyD(value), style: TextStyle(fontWeight: FontWeight.w700, color: color))),
              ]),
            ),
          ]),
        ),
      );
}

class _InsightRow extends StatelessWidget {
  final Insight i;
  const _InsightRow(this.i);

  @override
  Widget build(BuildContext context) {
    final color = switch (i.level) {
      'danger' => kExpense,
      'warning' => Colors.orange,
      'success' => kIncome,
      _ => kPrimary,
    };
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10), border: Border(left: BorderSide(color: color, width: 4))),
      child: Text(i.text, style: const TextStyle(fontSize: 13)),
    );
  }
}
