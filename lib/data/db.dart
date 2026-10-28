import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../core/format.dart';
import 'models.dart';

/// Toàn bộ truy cập SQLite của FINCARE (thay thế PHP + MySQL của bản web).
/// Mọi hàm đều lọc theo user_id để các tài khoản không thấy dữ liệu của nhau.
class AppDb {
  AppDb._();
  static final AppDb i = AppDb._();

  Database? _db;
  Future<Database> get db async => _db ??= await _open();

  Future<Database> _open() async {
    final path = p.join(await getDatabasesPath(), 'fincare.db');
    return openDatabase(
      path,
      version: 1,
      onConfigure: (d) => d.execute('PRAGMA foreign_keys = ON'),
      onCreate: _create,
    );
  }

  Future<void> _create(Database d, int v) async {
    await d.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        security_question TEXT,
        security_answer TEXT,
        failed_attempts INTEGER NOT NULL DEFAULT 0,
        locked_until TEXT,
        created_at TEXT NOT NULL
      )''');
    await d.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon TEXT NOT NULL DEFAULT '💳',
        color TEXT NOT NULL DEFAULT '#1796A4'
      )''');
    await d.execute('''
      CREATE TABLE wallets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        name TEXT NOT NULL,
        type TEXT NOT NULL DEFAULT 'cash',
        icon TEXT NOT NULL DEFAULT '💳',
        color TEXT NOT NULL DEFAULT '#1796A4',
        initial_balance REAL NOT NULL DEFAULT 0
      )''');
    await d.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        category_id INTEGER REFERENCES categories(id) ON DELETE SET NULL,
        wallet_id INTEGER REFERENCES wallets(id) ON DELETE SET NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        note TEXT,
        receipt_image TEXT,
        transaction_date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )''');
    await d.execute('CREATE INDEX idx_tx_user_date ON transactions(user_id, transaction_date)');
    await d.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        category_id INTEGER NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
        month TEXT NOT NULL,
        limit_amount REAL NOT NULL,
        UNIQUE(user_id, category_id, month)
      )''');
    await d.execute('''
      CREATE TABLE loans (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        borrower_name TEXT NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        paid_amount REAL NOT NULL DEFAULT 0,
        due_date TEXT,
        note TEXT,
        status TEXT NOT NULL DEFAULT 'unpaid',
        created_at TEXT NOT NULL
      )''');
    await d.execute('''
      CREATE TABLE loan_repayments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        loan_id INTEGER NOT NULL REFERENCES loans(id) ON DELETE CASCADE,
        amount REAL NOT NULL,
        repayment_date TEXT NOT NULL,
        note TEXT
      )''');
    await d.execute('''
      CREATE TABLE recurring_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        category_id INTEGER REFERENCES categories(id) ON DELETE SET NULL,
        wallet_id INTEGER REFERENCES wallets(id) ON DELETE SET NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        title TEXT NOT NULL,
        day_of_month INTEGER NOT NULL DEFAULT 1,
        is_active INTEGER NOT NULL DEFAULT 1,
        last_generated TEXT
      )''');

    // Danh mục mặc định (giống seed.sql của bản web, thêm 2 danh mục cho vay/đi vay)
    const defaults = [
      ['Lương', 'income', '💼', '#22c55e'],
      ['Thưởng', 'income', '🎁', '#16a34a'],
      ['Đầu tư', 'income', '📈', '#0ea5e9'],
      ['Thu khác', 'income', '➕', '#14b8a6'],
      ['Đi vay', 'income', '🤝', '#0891b2'],
      ['Ăn uống', 'expense', '🍜', '#f97316'],
      ['Đi lại', 'expense', '🚗', '#eab308'],
      ['Mua sắm', 'expense', '🛍️', '#ec4899'],
      ['Học tập', 'expense', '📚', '#6366f1'],
      ['Giải trí', 'expense', '🎬', '#8b5cf6'],
      ['Hoá đơn', 'expense', '🧾', '#ef4444'],
      ['Sức khoẻ', 'expense', '💊', '#06b6d4'],
      ['Cho vay', 'expense', '💸', '#a855f7'],
      ['Khác', 'expense', '📦', '#64748b'],
    ];
    for (final c in defaults) {
      await d.insert('categories', {'user_id': null, 'name': c[0], 'type': c[1], 'icon': c[2], 'color': c[3]});
    }
  }

  // ===================================================================
  // AUTH
  // ===================================================================
  String _hash(String pw, [String? salt]) {
    salt ??= base64Url.encode(List<int>.generate(12, (_) => Random.secure().nextInt(256)));
    final h = sha256.convert(utf8.encode('$salt:$pw')).toString();
    return '$salt:$h';
  }

  bool _verify(String pw, String stored) {
    final i = stored.indexOf(':');
    if (i < 0) return false;
    return _hash(pw, stored.substring(0, i)) == stored;
  }

  String _norm(String s) => s.trim().toLowerCase();

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required String question,
    required String answer,
  }) async {
    final d = await db;
    final e = _norm(email);
    final exists = await d.query('users', where: 'email = ?', whereArgs: [e]);
    if (exists.isNotEmpty) throw AppError('Email này đã được đăng ký.');
    final id = await d.insert('users', {
      'name': name.trim(),
      'email': e,
      'password': _hash(password),
      'security_question': question,
      'security_answer': _hash(_norm(answer)),
      'created_at': DateTime.now().toIso8601String(),
    });
    await _seedWallet(d, id);
    return AppUser(id: id, name: name.trim(), email: e);
  }

  Future<void> _seedWallet(Database d, int uid) async {
    await d.insert('wallets', {
      'user_id': uid,
      'name': 'Tiền mặt',
      'type': 'cash',
      'icon': '💵',
      'color': '#22c55e',
      'initial_balance': 0,
    });
  }

  Future<AppUser> login(String email, String password) async {
    final d = await db;
    final rows = await d.query('users', where: 'email = ?', whereArgs: [_norm(email)]);
    if (rows.isEmpty) throw AppError('Email hoặc mật khẩu không đúng.');
    final u = rows.first;

    final lockedUntil = u['locked_until'] as String?;
    if (lockedUntil != null && DateTime.parse(lockedUntil).isAfter(DateTime.now())) {
      final mins = DateTime.parse(lockedUntil).difference(DateTime.now()).inMinutes + 1;
      throw AppError('Tài khoản đang bị khoá tạm thời. Thử lại sau $mins phút.');
    }

    if (!_verify(password, u['password'] as String)) {
      final fails = (u['failed_attempts'] as int) + 1;
      if (fails >= 5) {
        await d.update(
          'users',
          {'failed_attempts': 0, 'locked_until': DateTime.now().add(const Duration(minutes: 15)).toIso8601String()},
          where: 'id = ?',
          whereArgs: [u['id']],
        );
        throw AppError('Nhập sai 5 lần. Tài khoản bị khoá 15 phút.');
      }
      await d.update('users', {'failed_attempts': fails}, where: 'id = ?', whereArgs: [u['id']]);
      throw AppError('Email hoặc mật khẩu không đúng.');
    }

    await d.update('users', {'failed_attempts': 0, 'locked_until': null}, where: 'id = ?', whereArgs: [u['id']]);
    return AppUser.fromMap(u);
  }

  Future<AppUser?> userById(int id) async {
    final d = await db;
    final r = await d.query('users', where: 'id = ?', whereArgs: [id]);
    return r.isEmpty ? null : AppUser.fromMap(r.first);
  }

  Future<String> securityQuestion(String email) async {
    final d = await db;
    final r = await d.query('users', where: 'email = ?', whereArgs: [_norm(email)]);
    if (r.isEmpty) throw AppError('Không tìm thấy tài khoản với email này.');
    return (r.first['security_question'] as String?) ?? '';
  }

  Future<void> resetPassword(String email, String answer, String newPassword) async {
    final d = await db;
    final r = await d.query('users', where: 'email = ?', whereArgs: [_norm(email)]);
    if (r.isEmpty) throw AppError('Không tìm thấy tài khoản.');
    if (!_verify(_norm(answer), (r.first['security_answer'] as String?) ?? '')) {
      throw AppError('Câu trả lời bảo mật không đúng.');
    }
    await d.update(
      'users',
      {'password': _hash(newPassword), 'failed_attempts': 0, 'locked_until': null},
      where: 'id = ?',
      whereArgs: [r.first['id']],
    );
  }

  Future<void> updateName(int uid, String name) async {
    final d = await db;
    await d.update('users', {'name': name.trim()}, where: 'id = ?', whereArgs: [uid]);
  }

  Future<void> changePassword(int uid, String oldPw, String newPw) async {
    final d = await db;
    final r = await d.query('users', where: 'id = ?', whereArgs: [uid]);
    if (r.isEmpty || !_verify(oldPw, r.first['password'] as String)) {
      throw AppError('Mật khẩu hiện tại không đúng.');
    }
    await d.update('users', {'password': _hash(newPw)}, where: 'id = ?', whereArgs: [uid]);
  }

  // ===================================================================
  // CATEGORIES
  // ===================================================================
  Future<List<Category>> categories(int uid, {String? type}) async {
    final d = await db;
    final rows = await d.query(
      'categories',
      where: '(user_id IS NULL OR user_id = ?)${type != null ? ' AND type = ?' : ''}',
      whereArgs: [uid, if (type != null) type],
      orderBy: 'user_id IS NOT NULL, id',
    );
    return rows.map(Category.fromMap).toList();
  }

  Future<void> saveCategory(int uid, {int? id, required String name, required String type, required String icon, required String color}) async {
    final d = await db;
    final data = {'name': name.trim(), 'type': type, 'icon': icon, 'color': color};
    if (id == null) {
      await d.insert('categories', {...data, 'user_id': uid});
    } else {
      await d.update('categories', data, where: 'id = ? AND user_id = ?', whereArgs: [id, uid]);
    }
  }

  Future<void> deleteCategory(int uid, int id) async {
    final d = await db;
    await d.delete('categories', where: 'id = ? AND user_id = ?', whereArgs: [id, uid]);
  }

  // ===================================================================
  // WALLETS
  // ===================================================================
  Future<List<Wallet>> wallets(int uid) async {
    final d = await db;
    final rows = await d.rawQuery('''
      SELECT w.*,
        COALESCE(SUM(CASE WHEN t.type='income' THEN t.amount ELSE 0 END),0) AS total_inc,
        COALESCE(SUM(CASE WHEN t.type='expense' THEN t.amount ELSE 0 END),0) AS total_exp
      FROM wallets w LEFT JOIN transactions t ON t.wallet_id = w.id
      WHERE w.user_id = ? GROUP BY w.id ORDER BY w.id
    ''', [uid]);
    return rows.map(Wallet.fromMap).toList();
  }

  Future<void> saveWallet(int uid, {int? id, required String name, required String type, required String icon, required String color, required double initial}) async {
    final d = await db;
    final data = {'name': name.trim(), 'type': type, 'icon': icon, 'color': color, 'initial_balance': initial};
    if (id == null) {
      await d.insert('wallets', {...data, 'user_id': uid});
    } else {
      await d.update('wallets', data, where: 'id = ? AND user_id = ?', whereArgs: [id, uid]);
    }
  }

  Future<void> deleteWallet(int uid, int id) async {
    final d = await db;
    await d.delete('wallets', where: 'id = ? AND user_id = ?', whereArgs: [id, uid]);
  }

  // ===================================================================
  // TRANSACTIONS
  // ===================================================================
  Future<List<TxItem>> transactions(
    int uid, {
    String? type,
    int? categoryId,
    String? from,
    String? to,
    String? search,
    int? limit,
  }) async {
    final d = await db;
    final where = <String>['t.user_id = ?'];
    final args = <Object?>[uid];
    if (type != null) {
      where.add('t.type = ?');
      args.add(type);
    }
    if (categoryId != null) {
      where.add('t.category_id = ?');
      args.add(categoryId);
    }
    if (from != null) {
      where.add('t.transaction_date >= ?');
      args.add(from);
    }
    if (to != null) {
      where.add('t.transaction_date <= ?');
      args.add(to);
    }
    if (search != null && search.trim().isNotEmpty) {
      where.add('(t.note LIKE ? OR c.name LIKE ?)');
      args.addAll(['%${search.trim()}%', '%${search.trim()}%']);
    }
    final rows = await d.rawQuery('''
      SELECT t.*, c.name AS cat_name, c.icon AS cat_icon, c.color AS cat_color, w.name AS wallet_name
      FROM transactions t
      LEFT JOIN categories c ON c.id = t.category_id
      LEFT JOIN wallets w ON w.id = t.wallet_id
      WHERE ${where.join(' AND ')}
      ORDER BY t.transaction_date DESC, t.id DESC
      ${limit != null ? 'LIMIT $limit' : ''}
    ''', args);
    return rows.map(TxItem.fromMap).toList();
  }

  Future<void> saveTransaction(
    int uid, {
    int? id,
    required String type,
    required double amount,
    required int? categoryId,
    required int? walletId,
    required String note,
    required String date,
    String? receipt,
  }) async {
    final d = await db;
    final data = {
      'type': type,
      'amount': amount,
      'category_id': categoryId,
      'wallet_id': walletId,
      'note': note.trim(),
      'transaction_date': date,
      'receipt_image': receipt,
    };
    if (id == null) {
      await d.insert('transactions', {...data, 'user_id': uid, 'created_at': DateTime.now().toIso8601String()});
    } else {
      await d.update('transactions', data, where: 'id = ? AND user_id = ?', whereArgs: [id, uid]);
    }
  }

  Future<void> deleteTransaction(int uid, int id) async {
    final d = await db;
    await d.delete('transactions', where: 'id = ? AND user_id = ?', whereArgs: [id, uid]);
  }

  /// Xuất CSV (UTF-8 có BOM để Excel hiển thị đúng tiếng Việt)
  Future<String> exportCsv(int uid) async {
    final list = await transactions(uid);
    String esc(String s) => '"${s.replaceAll('"', '""')}"';
    final sb = StringBuffer('﻿');
    sb.writeln('Ngày,Loại,Danh mục,Ví,Số tiền,Ghi chú');
    for (final t in list) {
      sb.writeln([
        dmy(t.date),
        t.isIncome ? 'Thu' : 'Chi',
        esc(t.catName),
        esc(t.walletName ?? ''),
        t.amount.round(),
        esc(t.note),
      ].join(','));
    }
    return sb.toString();
  }

  // ===================================================================
  // THỐNG KÊ / BÁO CÁO
  // ===================================================================
  Future<Totals> totals(int uid, {String? month}) async {
    final d = await db;
    final rows = await d.rawQuery('''
      SELECT type, COALESCE(SUM(amount),0) AS s FROM transactions
      WHERE user_id = ? ${month != null ? "AND substr(transaction_date,1,7) = ?" : ''}
      GROUP BY type
    ''', [uid, if (month != null) month]);
    double inc = 0, exp = 0;
    for (final r in rows) {
      final v = (r['s'] as num).toDouble();
      if (r['type'] == 'income') inc = v; else exp = v;
    }
    return Totals(inc, exp);
  }

  /// Thu/chi theo từng tháng trong khoảng [fromYm, toYm]
  Future<List<MonthStat>> monthly(int uid, String fromYm, String toYm) async {
    final d = await db;
    final rows = await d.rawQuery('''
      SELECT substr(transaction_date,1,7) AS ym,
        SUM(CASE WHEN type='income' THEN amount ELSE 0 END) AS inc,
        SUM(CASE WHEN type='expense' THEN amount ELSE 0 END) AS exp
      FROM transactions
      WHERE user_id = ? AND substr(transaction_date,1,7) BETWEEN ? AND ?
      GROUP BY ym
    ''', [uid, fromYm, toYm]);
    return rows
        .map((r) => MonthStat(r['ym'] as String, (r['inc'] as num).toDouble(), (r['exp'] as num).toDouble()))
        .toList();
  }

  /// 6 tháng gần nhất (đủ 6 cột, tháng không có dữ liệu = 0)
  Future<List<MonthStat>> trend6(int uid) async {
    final now = DateTime.now();
    final months = [for (var i = 5; i >= 0; i--) DateTime(now.year, now.month - i, 1)];
    final got = {for (final m in await monthly(uid, ym(months.first), ym(months.last))) m.ym: m};
    return [for (final m in months) got[ym(m)] ?? MonthStat(ym(m), 0, 0)];
  }

  /// 12 tháng của một năm
  Future<List<MonthStat>> year(int uid, int y) async {
    final got = {for (final m in await monthly(uid, '$y-01', '$y-12')) m.ym: m};
    return [for (var m = 1; m <= 12; m++) got['$y-${m.toString().padLeft(2, '0')}'] ?? MonthStat('$y-${m.toString().padLeft(2, '0')}', 0, 0)];
  }

  Future<List<CatTotal>> byCategory(int uid, {required String type, required String from, required String to}) async {
    final d = await db;
    final rows = await d.rawQuery('''
      SELECT COALESCE(c.name,'Khác') AS name, COALESCE(c.color,'#64748b') AS color, SUM(t.amount) AS total
      FROM transactions t LEFT JOIN categories c ON c.id = t.category_id
      WHERE t.user_id = ? AND t.type = ? AND t.transaction_date BETWEEN ? AND ?
      GROUP BY t.category_id ORDER BY total DESC
    ''', [uid, type, from, to]);
    return rows.map((r) => CatTotal(r['name'] as String, r['color'] as String, (r['total'] as num).toDouble())).toList();
  }

  // ===================================================================
  // BUDGETS
  // ===================================================================
  Future<List<Budget>> budgets(int uid, String month) async {
    final d = await db;
    final rows = await d.rawQuery('''
      SELECT b.*, c.name AS cat_name, c.icon AS cat_icon, c.color AS cat_color,
        COALESCE((SELECT SUM(t.amount) FROM transactions t
          WHERE t.user_id = b.user_id AND t.category_id = b.category_id
            AND substr(t.transaction_date,1,7) = b.month AND t.type = 'expense'),0) AS spent
      FROM budgets b JOIN categories c ON c.id = b.category_id
      WHERE b.user_id = ? AND b.month = ? ORDER BY c.name
    ''', [uid, month]);
    return rows.map(Budget.fromMap).toList();
  }

  Future<void> saveBudget(int uid, {required int categoryId, required String month, required double limit}) async {
    final d = await db;
    await d.insert(
      'budgets',
      {'user_id': uid, 'category_id': categoryId, 'month': month, 'limit_amount': limit},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteBudget(int uid, int id) async {
    final d = await db;
    await d.delete('budgets', where: 'id = ? AND user_id = ?', whereArgs: [id, uid]);
  }

  // ===================================================================
  // LOANS
  // ===================================================================
  Future<List<Loan>> loans(int uid) async {
    final d = await db;
    final rows = await d.query('loans', where: 'user_id = ?', whereArgs: [uid], orderBy: "status = 'paid', id DESC");
    return rows.map(Loan.fromMap).toList();
  }

  Future<int?> _catIdByName(Database d, int uid, String name) async {
    final r = await d.query('categories',
        where: '(user_id IS NULL OR user_id = ?) AND name = ?', whereArgs: [uid, name], limit: 1);
    return r.isEmpty ? null : r.first['id'] as int;
  }

  Future<void> addLoan(int uid, {required String person, required String type, required double amount, String? due, String note = ''}) async {
    final d = await db;
    // Tra danh mục NGOÀI transaction (dùng d trong txn sẽ gây deadlock với sqflite)
    final catId = await _catIdByName(d, uid, type == 'give' ? 'Cho vay' : 'Đi vay');
    await d.transaction((txn) async {
      await txn.insert('loans', {
        'user_id': uid,
        'borrower_name': person.trim(),
        'type': type,
        'amount': amount,
        'due_date': due,
        'note': note.trim(),
        'created_at': DateTime.now().toIso8601String(),
      });
      // Tự ghi nhận dòng tiền tương ứng như bản web
      await txn.insert('transactions', {
        'user_id': uid,
        'category_id': catId,
        'type': type == 'give' ? 'expense' : 'income',
        'amount': amount,
        'note': '${type == 'give' ? 'Cho ' : 'Vay từ '}${person.trim()}${note.trim().isNotEmpty ? ' (${note.trim()})' : ''}',
        'transaction_date': ymd(DateTime.now()),
        'created_at': DateTime.now().toIso8601String(),
      });
    });
  }

  Future<void> repay(int uid, Loan loan, {required double amount, required String date, String note = ''}) async {
    if (amount <= 0) throw AppError('Số tiền trả nợ không hợp lệ.');
    if (loan.paid + amount > loan.amount + 0.001) {
      throw AppError('Số tiền trả vượt quá số còn nợ (${moneyD(loan.remaining)}).');
    }
    final d = await db;
    await d.transaction((txn) async {
      await txn.insert('loan_repayments', {'loan_id': loan.id, 'amount': amount, 'repayment_date': date, 'note': note.trim()});
      final newPaid = loan.paid + amount;
      await txn.update(
        'loans',
        {'paid_amount': newPaid, 'status': newPaid >= loan.amount ? 'paid' : 'partially_paid'},
        where: 'id = ? AND user_id = ?',
        whereArgs: [loan.id, uid],
      );
      await txn.insert('transactions', {
        'user_id': uid,
        'type': loan.isGive ? 'income' : 'expense',
        'amount': amount,
        'note': '${loan.isGive ? 'Thu nợ từ ' : 'Trả nợ cho '}${loan.borrowerName}${note.trim().isNotEmpty ? ' (${note.trim()})' : ''}',
        'transaction_date': date,
        'created_at': DateTime.now().toIso8601String(),
      });
    });
  }

  Future<List<Repayment>> repayments(int loanId) async {
    final d = await db;
    final r = await d.query('loan_repayments', where: 'loan_id = ?', whereArgs: [loanId], orderBy: 'repayment_date DESC, id DESC');
    return r.map(Repayment.fromMap).toList();
  }

  Future<void> deleteLoan(int uid, int id) async {
    final d = await db;
    await d.delete('loans', where: 'id = ? AND user_id = ?', whereArgs: [id, uid]);
  }

  // ===================================================================
  // RECURRING
  // ===================================================================
  Future<List<Recurring>> recurring(int uid) async {
    final d = await db;
    final rows = await d.rawQuery('''
      SELECT r.*, c.name AS cat_name, c.icon AS cat_icon
      FROM recurring_transactions r LEFT JOIN categories c ON c.id = r.category_id
      WHERE r.user_id = ? ORDER BY r.day_of_month, r.id
    ''', [uid]);
    return rows.map(Recurring.fromMap).toList();
  }

  Future<void> saveRecurring(int uid, {int? id, required String title, required String type, required double amount, required int day, required int? categoryId, required int? walletId}) async {
    final d = await db;
    final data = {'title': title.trim(), 'type': type, 'amount': amount, 'day_of_month': day, 'category_id': categoryId, 'wallet_id': walletId};
    if (id == null) {
      await d.insert('recurring_transactions', {...data, 'user_id': uid, 'is_active': 1});
    } else {
      await d.update('recurring_transactions', data, where: 'id = ? AND user_id = ?', whereArgs: [id, uid]);
    }
  }

  Future<void> setRecurringActive(int uid, int id, bool active) async {
    final d = await db;
    await d.update('recurring_transactions', {'is_active': active ? 1 : 0}, where: 'id = ? AND user_id = ?', whereArgs: [id, uid]);
  }

  Future<void> deleteRecurring(int uid, int id) async {
    final d = await db;
    await d.delete('recurring_transactions', where: 'id = ? AND user_id = ?', whereArgs: [id, uid]);
  }

  /// Sinh giao dịch định kỳ của tháng này nếu đã đến ngày hẹn. Trả về số giao dịch được tạo.
  Future<int> processRecurring(int uid) async {
    final d = await db;
    final now = DateTime.now();
    final items = await d.query('recurring_transactions', where: 'user_id = ? AND is_active = 1', whereArgs: [uid]);
    var count = 0;
    for (final it in items) {
      final last = it['last_generated'] as String?;
      final lastYm = last == null ? '' : last.substring(0, 7);
      final day = it['day_of_month'] as int;
      if (lastYm != ym(now) && now.day >= day) {
        final lastDay = DateTime(now.year, now.month + 1, 0).day;
        final txDate = ymd(DateTime(now.year, now.month, day > lastDay ? lastDay : day));
        await d.transaction((txn) async {
          await txn.insert('transactions', {
            'user_id': uid,
            'category_id': it['category_id'],
            'wallet_id': it['wallet_id'],
            'type': it['type'],
            'amount': it['amount'],
            'note': '[Tự động định kỳ] ${it['title']}',
            'transaction_date': txDate,
            'created_at': now.toIso8601String(),
          });
          await txn.update('recurring_transactions', {'last_generated': ymd(now)}, where: 'id = ?', whereArgs: [it['id']]);
        });
        count++;
      }
    }
    return count;
  }

  // ===================================================================
  // TRỢ LÝ AI (cảnh báo ngân sách, nợ đến hạn, sức khoẻ dòng tiền)
  // ===================================================================
  Future<List<Insight>> insights(int uid) async {
    final out = <Insight>[];
    final month = ym(DateTime.now());

    for (final b in await budgets(uid, month)) {
      if (b.limit <= 0) continue;
      final pct = b.percent.round();
      if (pct >= 100) {
        out.add(Insight('danger', '⚠️ Đã chi vượt $pct% ngân sách danh mục "${b.catName}".'));
      } else if (pct >= 80) {
        out.add(Insight('warning', '⚡ Danh mục "${b.catName}" đã chạm $pct% hạn mức.'));
      }
    }

    final today = ymd(DateTime.now());
    for (final l in await loans(uid)) {
      if (l.isPaid || l.dueDate == null) continue;
      if (l.dueDate!.compareTo(today) < 0) {
        out.add(Insight('danger', l.isGive
            ? '🔴 ${l.borrowerName} chưa trả ${moneyD(l.remaining)} (hạn ${dmy(l.dueDate!)}). Hãy nhắc họ nhé!'
            : '🚨 Bạn nợ quá hạn ${moneyD(l.remaining)} trả cho ${l.borrowerName} (hạn ${dmy(l.dueDate!)}).'));
      } else if (l.dueDate == today) {
        out.add(Insight('warning', '⏰ Khoản nợ ${moneyD(l.remaining)} với ${l.borrowerName} đến hạn HÔM NAY.'));
      }
    }

    final t = await totals(uid, month: month);
    if (t.income > 0) {
      final rate = (t.expense / t.income * 100).round();
      out.add(rate > 90
          ? Insight('warning', '💡 Tháng này bạn đã chi $rate% thu nhập. Mức tích lũy đang rất thấp!')
          : Insight('success', '✅ Tốt! Bạn đã chi $rate% thu nhập tháng này, vẫn giữ được mức tiết kiệm ổn định.'));
    }
    return out;
  }
}
