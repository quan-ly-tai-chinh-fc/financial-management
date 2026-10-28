import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/format.dart';
import '../core/theme.dart';
import '../data/models.dart';
import 'common.dart';

/// Cột đôi Thu / Chi theo tháng
class TrendBarChart extends StatelessWidget {
  final List<MonthStat> data;
  final String Function(MonthStat) label;
  const TrendBarChart({super.key, required this.data, required this.label});

  @override
  Widget build(BuildContext context) {
    final maxV = data.fold<double>(0, (m, e) => max(m, max(e.income, e.expense)));
    if (maxV == 0) {
      return const SizedBox(height: 120, child: EmptyState(emoji: '📊', text: 'Chưa có dữ liệu để vẽ biểu đồ'));
    }
    final maxY = maxV * 1.15;
    final tiny = TextStyle(fontSize: 10, color: Theme.of(context).hintColor);
    return Column(children: [
      SizedBox(
        height: 210,
        child: BarChart(BarChartData(
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          barGroups: [
            for (var i = 0; i < data.length; i++)
              BarChartGroupData(x: i, barsSpace: 3, barRods: [
                BarChartRodData(toY: data[i].income, color: kIncome, width: data.length > 6 ? 6 : 9, borderRadius: BorderRadius.circular(3)),
                BarChartRodData(toY: data[i].expense, color: kExpense, width: data.length > 6 ? 6 : 9, borderRadius: BorderRadius.circular(3)),
              ]),
          ],
          gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: maxY / 4),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 44,
                interval: maxY / 4,
                getTitlesWidget: (v, m) => Text(moneyShort(v), style: tiny),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, m) {
                  final i = v.toInt();
                  if (i < 0 || i >= data.length) return const SizedBox();
                  return Padding(padding: const EdgeInsets.only(top: 6), child: Text(label(data[i]), style: tiny));
                },
              ),
            ),
          ),
        )),
      ),
      const SizedBox(height: 8),
      const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.circle, size: 10, color: kIncome),
        SizedBox(width: 4),
        Text('Thu', style: TextStyle(fontSize: 12)),
        SizedBox(width: 16),
        Icon(Icons.circle, size: 10, color: kExpense),
        SizedBox(width: 4),
        Text('Chi', style: TextStyle(fontSize: 12)),
      ]),
    ]);
  }
}

/// Biểu đồ tròn theo danh mục + chú giải
class CategoryPie extends StatelessWidget {
  final List<CatTotal> data;
  const CategoryPie({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final total = data.fold<double>(0, (s, e) => s + e.total);
    if (total == 0) {
      return const SizedBox(height: 120, child: EmptyState(emoji: '🥧', text: 'Chưa có dữ liệu'));
    }
    return Column(children: [
      SizedBox(
        height: 180,
        child: PieChart(PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 38,
          sections: [
            for (final c in data)
              PieChartSectionData(
                value: c.total,
                color: hexColor(c.color),
                radius: 48,
                title: c.total / total >= 0.08 ? '${(c.total / total * 100).round()}%' : '',
                titleStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
              ),
          ],
        )),
      ),
      const SizedBox(height: 8),
      for (final c in data)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(children: [
            CircleAvatar(radius: 5, backgroundColor: hexColor(c.color)),
            const SizedBox(width: 8),
            Expanded(child: Text(c.name, overflow: TextOverflow.ellipsis)),
            Text(moneyD(c.total), style: const TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(width: 44, child: Text('${(c.total / total * 100).toStringAsFixed(0)}%', textAlign: TextAlign.right, style: TextStyle(color: Theme.of(context).hintColor))),
          ]),
        ),
    ]);
  }
}

class BudgetTile extends StatelessWidget {
  final Budget b;
  final VoidCallback? onDelete;
  const BudgetTile({super.key, required this.b, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final pct = b.percent;
    final color = pct >= 100 ? kExpense : pct >= 80 ? Colors.orange : kIncome;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(children: [
        Row(children: [
          CatAvatar(icon: b.catIcon, color: b.catColor, size: 36),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(b.catName, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text('${moneyD(b.spent)} / ${moneyD(b.limit)}', style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
            ]),
          ),
          Text('${pct.round()}%', style: TextStyle(fontWeight: FontWeight.w700, color: color)),
          if (onDelete != null) IconButton(icon: const Icon(Icons.delete_outline, size: 20), onPressed: onDelete),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(value: (pct / 100).clamp(0, 1).toDouble(), minHeight: 8, color: color, backgroundColor: color.withValues(alpha: 0.15)),
        ),
        if (pct >= 100)
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Vượt hạn mức ${moneyD(b.spent - b.limit)}', style: const TextStyle(fontSize: 12, color: kExpense)),
            ),
          ),
      ]),
    );
  }
}
