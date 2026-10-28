class AppError implements Exception {
  final String message;
  AppError(this.message);
  @override
  String toString() => message;
}

double _d(Object? v) => (v as num?)?.toDouble() ?? 0;

class AppUser {
  final int id;
  final String name;
  final String email;
  AppUser({required this.id, required this.name, required this.email});

  factory AppUser.fromMap(Map<String, Object?> m) => AppUser(
        id: m['id'] as int,
        name: m['name'] as String,
        email: m['email'] as String,
      );
}

class Category {
  final int id;
  final int? userId; // null = danh mục mặc định của hệ thống
  final String name;
  final String type; // income | expense
  final String icon;
  final String color;
  Category({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
  });

  bool get isDefault => userId == null;

  factory Category.fromMap(Map<String, Object?> m) => Category(
        id: m['id'] as int,
        userId: m['user_id'] as int?,
        name: m['name'] as String,
        type: m['type'] as String,
        icon: (m['icon'] as String?) ?? '💳',
        color: (m['color'] as String?) ?? '#1796A4',
      );
}

class Wallet {
  final int id;
  final String name;
  final String type; // cash | bank | ewallet | other
  final String icon;
  final String color;
  final double initialBalance;
  final double income;
  final double expense;
  Wallet({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    required this.initialBalance,
    this.income = 0,
    this.expense = 0,
  });

  double get balance => initialBalance + income - expense;

  factory Wallet.fromMap(Map<String, Object?> m) => Wallet(
        id: m['id'] as int,
        name: m['name'] as String,
        type: (m['type'] as String?) ?? 'cash',
        icon: (m['icon'] as String?) ?? '💳',
        color: (m['color'] as String?) ?? '#1796A4',
        initialBalance: _d(m['initial_balance']),
        income: _d(m['total_inc']),
        expense: _d(m['total_exp']),
      );
}

class TxItem {
  final int id;
  final int? categoryId;
  final int? walletId;
  final String type;
  final double amount;
  final String note;
  final String? receiptImage;
  final String date; // yyyy-MM-dd
  final String catName;
  final String catIcon;
  final String catColor;
  final String? walletName;
  TxItem({
    required this.id,
    required this.categoryId,
    required this.walletId,
    required this.type,
    required this.amount,
    required this.note,
    required this.receiptImage,
    required this.date,
    required this.catName,
    required this.catIcon,
    required this.catColor,
    required this.walletName,
  });

  bool get isIncome => type == 'income';

  factory TxItem.fromMap(Map<String, Object?> m) => TxItem(
        id: m['id'] as int,
        categoryId: m['category_id'] as int?,
        walletId: m['wallet_id'] as int?,
        type: m['type'] as String,
        amount: _d(m['amount']),
        note: (m['note'] as String?) ?? '',
        receiptImage: m['receipt_image'] as String?,
        date: m['transaction_date'] as String,
        catName: (m['cat_name'] as String?) ?? 'Khác',
        catIcon: (m['cat_icon'] as String?) ?? '📦',
        catColor: (m['cat_color'] as String?) ?? '#64748b',
        walletName: m['wallet_name'] as String?,
      );
}

class Budget {
  final int id;
  final int categoryId;
  final String month;
  final double limit;
  final double spent;
  final String catName;
  final String catIcon;
  final String catColor;
  Budget({
    required this.id,
    required this.categoryId,
    required this.month,
    required this.limit,
    required this.spent,
    required this.catName,
    required this.catIcon,
    required this.catColor,
  });

  double get percent => limit > 0 ? spent / limit * 100 : 0;

  factory Budget.fromMap(Map<String, Object?> m) => Budget(
        id: m['id'] as int,
        categoryId: m['category_id'] as int,
        month: m['month'] as String,
        limit: _d(m['limit_amount']),
        spent: _d(m['spent']),
        catName: (m['cat_name'] as String?) ?? '',
        catIcon: (m['cat_icon'] as String?) ?? '💳',
        catColor: (m['cat_color'] as String?) ?? '#1796A4',
      );
}

class Loan {
  final int id;
  final String borrowerName;
  final String type; // give = cho vay (phải thu) | take = đi vay (phải trả)
  final double amount;
  final double paid;
  final String? dueDate;
  final String note;
  final String status; // unpaid | partially_paid | paid
  Loan({
    required this.id,
    required this.borrowerName,
    required this.type,
    required this.amount,
    required this.paid,
    required this.dueDate,
    required this.note,
    required this.status,
  });

  double get remaining => amount - paid;
  bool get isPaid => status == 'paid';
  bool get isGive => type == 'give';
  bool get isOverdue =>
      !isPaid && dueDate != null && dueDate!.compareTo(DateTime.now().toIso8601String().substring(0, 10)) < 0;

  factory Loan.fromMap(Map<String, Object?> m) => Loan(
        id: m['id'] as int,
        borrowerName: m['borrower_name'] as String,
        type: m['type'] as String,
        amount: _d(m['amount']),
        paid: _d(m['paid_amount']),
        dueDate: m['due_date'] as String?,
        note: (m['note'] as String?) ?? '',
        status: (m['status'] as String?) ?? 'unpaid',
      );
}

class Repayment {
  final double amount;
  final String date;
  final String note;
  Repayment({required this.amount, required this.date, required this.note});

  factory Repayment.fromMap(Map<String, Object?> m) => Repayment(
        amount: _d(m['amount']),
        date: m['repayment_date'] as String,
        note: (m['note'] as String?) ?? '',
      );
}

class Recurring {
  final int id;
  final int? categoryId;
  final int? walletId;
  final String type;
  final double amount;
  final String title;
  final int day;
  final bool active;
  final String catName;
  final String catIcon;
  Recurring({
    required this.id,
    required this.categoryId,
    required this.walletId,
    required this.type,
    required this.amount,
    required this.title,
    required this.day,
    required this.active,
    required this.catName,
    required this.catIcon,
  });

  factory Recurring.fromMap(Map<String, Object?> m) => Recurring(
        id: m['id'] as int,
        categoryId: m['category_id'] as int?,
        walletId: m['wallet_id'] as int?,
        type: m['type'] as String,
        amount: _d(m['amount']),
        title: m['title'] as String,
        day: m['day_of_month'] as int,
        active: (m['is_active'] as int? ?? 1) == 1,
        catName: (m['cat_name'] as String?) ?? 'Khác',
        catIcon: (m['cat_icon'] as String?) ?? '📦',
      );
}

class Totals {
  final double income;
  final double expense;
  Totals(this.income, this.expense);
  double get balance => income - expense;
}

class MonthStat {
  final String ym; // yyyy-MM
  final double income;
  final double expense;
  MonthStat(this.ym, this.income, this.expense);
}

class CatTotal {
  final String name;
  final String color;
  final double total;
  CatTotal(this.name, this.color, this.total);
}

/// Cảnh báo / nhận xét của "Trợ lý AI" (port từ ai_analyzer.php)
class Insight {
  final String level; // danger | warning | success | info
  final String text;
  Insight(this.level, this.text);
}
