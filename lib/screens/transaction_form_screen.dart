import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../data/models.dart';
import '../widgets/common.dart';

class TransactionFormScreen extends StatefulWidget {
  final TxItem? edit;
  const TransactionFormScreen({super.key, this.edit});
  @override
  State<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends State<TransactionFormScreen> {
  late String _type;
  final _amount = TextEditingController();
  final _note = TextEditingController();
  DateTime _date = DateTime.now();
  int? _catId, _walletId;
  String? _receipt;
  List<Category> _cats = [];
  List<Wallet> _wallets = [];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final e = widget.edit;
    _type = e?.type ?? 'expense';
    if (e != null) {
      _amount.text = amountText(e.amount);
      _note.text = e.note;
      _date = parseYmd(e.date);
      _catId = e.categoryId;
      _walletId = e.walletId;
      _receipt = e.receiptImage;
    }
    _loadLists();
  }

  Future<void> _loadLists() async {
    final app = context.read<AppState>();
    final cats = await app.db.categories(app.uid);
    final wallets = await app.db.wallets(app.uid);
    if (!mounted) return;
    setState(() {
      _cats = cats;
      _wallets = wallets;
      _walletId ??= widget.edit == null && wallets.isNotEmpty ? wallets.first.id : _walletId;
    });
  }

  List<Category> get _typeCats => _cats.where((c) => c.type == _type).toList();

  Future<void> _pickImage(ImageSource src) async {
    try {
      final x = await ImagePicker().pickImage(source: src, imageQuality: 80, maxWidth: 1600);
      if (x == null) return;
      final dir = await getApplicationDocumentsDirectory();
      final folder = Directory(p.join(dir.path, 'receipts'));
      if (!await folder.exists()) await folder.create(recursive: true);
      final dest = p.join(folder.path, '${DateTime.now().millisecondsSinceEpoch}${p.extension(x.path)}');
      await File(x.path).copy(dest);
      setState(() => _receipt = dest);
    } catch (e) {
      if (mounted) snack(context, 'Không lấy được ảnh: $e');
    }
  }

  Future<void> _save() async {
    final amount = parseAmount(_amount.text);
    if (amount <= 0) return snack(context, 'Số tiền phải lớn hơn 0.');
    if (_catId == null) return snack(context, 'Vui lòng chọn danh mục.');
    final app = context.read<AppState>();
    final nav = Navigator.of(context);
    setState(() => _busy = true);
    try {
      await app.db.saveTransaction(
        app.uid,
        id: widget.edit?.id,
        type: _type,
        amount: amount,
        categoryId: _catId,
        walletId: _walletId,
        note: _note.text,
        date: ymd(_date),
        receipt: _receipt,
      );
      app.bump();
      nav.pop();
    } catch (e) {
      if (mounted) snack(context, e.toString());
      setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    if (!await confirmDialog(context, 'Xoá giao dịch này?')) return;
    final app = context.read<AppState>();
    final nav = Navigator.of(context);
    await app.db.deleteTransaction(app.uid, widget.edit!.id);
    app.bump();
    nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final cats = _typeCats;
    final color = _type == 'income' ? kIncome : kExpense;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.edit == null ? 'Thêm giao dịch' : 'Sửa giao dịch'),
        actions: [if (widget.edit != null) IconButton(icon: const Icon(Icons.delete_outline), onPressed: _delete)],
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'expense', label: Text('Chi tiêu'), icon: Icon(Icons.north_east)),
            ButtonSegment(value: 'income', label: Text('Thu nhập'), icon: Icon(Icons.south_west)),
          ],
          selected: {_type},
          onSelectionChanged: (s) => setState(() {
            _type = s.first;
            if (!_cats.any((c) => c.id == _catId && c.type == _type)) _catId = null;
          }),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _amount,
          keyboardType: TextInputType.number,
          inputFormatters: [LengthLimitingTextInputFormatter(15), ThousandsFormatter()],
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color),
          decoration: const InputDecoration(labelText: 'Số tiền (đ)'),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<int>(
          value: cats.any((c) => c.id == _catId) ? _catId : null,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Danh mục'),
          items: [for (final c in cats) DropdownMenuItem(value: c.id, child: Text('${c.icon}  ${c.name}'))],
          onChanged: (v) => setState(() => _catId = v),
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<int>(
          value: _wallets.any((w) => w.id == _walletId) ? _walletId : null,
          isExpanded: true,
          decoration: const InputDecoration(labelText: 'Ví / Tài khoản'),
          items: [for (final w in _wallets) DropdownMenuItem(value: w.id, child: Text('${w.icon}  ${w.name}'))],
          onChanged: (v) => setState(() => _walletId = v),
        ),
        const SizedBox(height: 14),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () async {
            final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2000), lastDate: DateTime(2100));
            if (d != null) setState(() => _date = d);
          },
          child: InputDecorator(
            decoration: const InputDecoration(labelText: 'Ngày giao dịch', suffixIcon: Icon(Icons.calendar_today)),
            child: Text(dmy(ymd(_date))),
          ),
        ),
        const SizedBox(height: 14),
        TextField(controller: _note, maxLines: 2, decoration: const InputDecoration(labelText: 'Ghi chú')),
        const SizedBox(height: 14),
        const Text('Ảnh hoá đơn', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (_receipt != null && File(_receipt!).existsSync())
          Stack(children: [
            ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(_receipt!), height: 180, width: double.infinity, fit: BoxFit.cover)),
            Positioned(
              right: 6,
              top: 6,
              child: CircleAvatar(
                backgroundColor: Colors.black54,
                child: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => setState(() => _receipt = null)),
              ),
            ),
          ])
        else
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: () => _pickImage(ImageSource.camera), icon: const Icon(Icons.photo_camera_outlined), label: const Text('Chụp ảnh'))),
            const SizedBox(width: 12),
            Expanded(child: OutlinedButton.icon(onPressed: () => _pickImage(ImageSource.gallery), icon: const Icon(Icons.photo_outlined), label: const Text('Thư viện'))),
          ]),
        const SizedBox(height: 24),
        FilledButton(onPressed: _busy ? null : _save, child: const Text('Lưu giao dịch')),
      ]),
    );
  }
}
