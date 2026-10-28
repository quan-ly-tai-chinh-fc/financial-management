import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../widgets/common.dart';
import 'budgets_screen.dart';
import 'dashboard_screen.dart';
import 'more_screen.dart';
import 'reports_screen.dart';
import 'transaction_form_screen.dart';
import 'transactions_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final n = context.read<AppState>().takeNotice();
      if (n != null && mounted) snack(context, n);
    });
  }

  @override
  Widget build(BuildContext context) {
    const pages = [DashboardScreen(), TransactionsScreen(), BudgetsScreen(), ReportsScreen(), MoreScreen()];
    return Scaffold(
      body: SafeArea(bottom: false, child: IndexedStack(index: _index, children: pages)),
      floatingActionButton: _index <= 1
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionFormScreen())),
              icon: const Icon(Icons.add),
              label: const Text('Thêm giao dịch'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Tổng quan'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Giao dịch'),
          NavigationDestination(icon: Icon(Icons.savings_outlined), selectedIcon: Icon(Icons.savings), label: 'Ngân sách'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Báo cáo'),
          NavigationDestination(icon: Icon(Icons.menu), selectedIcon: Icon(Icons.menu_open), label: 'Khác'),
        ],
      ),
    );
  }
}
