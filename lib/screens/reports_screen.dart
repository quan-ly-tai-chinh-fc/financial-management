import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../data/models.dart';
import '../widgets/charts.dart';
import '../widgets/common.dart';

class _Rep {
  final List<MonthStat> months;
  final List<CatTotal> expense, income;
  _Rep(this.months, this.expense, this.income);
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _year = DateTime.now().year;
  String _type = 'expense';

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Text('Báo cáo', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
      ),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => setState(() => _year--)),
        Text('Năm $_year', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => setState(() => _year++)),
      ]),
      Expanded(
        child: _ReportBody(
          app: app,
          year: _year,
          type: _type,
          onType: (t) => setState(() => _type = t),
        ),
      ),
    ]);
  }
}

class _ReportBody extends StatelessWidget {
  final AppState app;
  final int year;
  final String type;
  final ValueChanged<String> onType;
  const _ReportBody({required this.app, required this.year, required this.type, required this.onType});

  Future<_Rep> _load() async => _Rep(
        await app.db.year(app.uid, year),
        await app.db.byCategory(app.uid, type: 'expense', from: '$year-01-01', to: '$year-12-31'),
        await app.db.byCategory(app.uid, type: 'income', from: '$year-01-01', to: '$year-12-31'),
      );

  @override
  Widget build(BuildContext context) {
    return DataView<_Rep>(
      deps: [year],
      load: _load,
      builder: (context, r) {
        final inc = r.months.fold<double>(0, (s, m) => s + m.income);
        final exp = r.months.fold<double>(0, (s, m) => s + m.expense);
        return ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), children: [
          Row(children: [
            Expanded(child: _Box('Tổng thu', inc, kIncome)),
            const SizedBox(width: 12),
            Expanded(child: _Box('Tổng chi', exp, kExpense)),
          ]),
          const SizedBox(height: 12),
          _Box('Chênh lệch (tiết kiệm)', inc - exp, inc - exp >= 0 ? kPrimary : kExpense),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Thu / Chi theo tháng', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 10),
                TrendBarChart(data: r.months, label: (m) => 'T${int.parse(m.ym.substring(5))}'),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Expanded(child: Text('Cơ cấu theo danh mục', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15))),
                  SegmentedButton<String>(
                    showSelectedIcon: false,
                    style: SegmentedButton.styleFrom(visualDensity: VisualDensity.compact),
                    segments: const [ButtonSegment(value: 'expense', label: Text('Chi')), ButtonSegment(value: 'income', label: Text('Thu'))],
                    selected: {type},
                    onSelectionChanged: (s) => onType(s.first),
                  ),
                ]),
                const SizedBox(height: 10),
                CategoryPie(data: type == 'expense' ? r.expense : r.income),
              ]),
            ),
          ),
        ]);
      },
    );
  }
}

class _Box extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _Box(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: SizedBox(
            width: double.infinity,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
              const SizedBox(height: 2),
              FittedBox(fit: BoxFit.scaleDown, child: Text(moneyD(value), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: color))),
            ]),
          ),
        ),
      );
}
