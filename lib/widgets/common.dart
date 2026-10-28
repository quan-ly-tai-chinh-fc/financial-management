import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../app_state.dart';
import '../core/format.dart';
import '../core/theme.dart';
import '../data/models.dart';

/// Tải dữ liệu bất đồng bộ và tự tải lại khi AppState.rev đổi (sau thêm/sửa/xoá)
/// hoặc khi danh sách `deps` đổi (vd: tháng/năm đang xem).
class DataView<T> extends StatefulWidget {
  final Future<T> Function() load;
  final Widget Function(BuildContext context, T data) builder;
  final List<Object?> deps;
  const DataView({super.key, required this.load, required this.builder, this.deps = const []});

  @override
  State<DataView<T>> createState() => _DataViewState<T>();
}

class _DataViewState<T> extends State<DataView<T>> {
  late Future<T> _future;
  int _rev = -1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final r = Provider.of<AppState>(context).rev;
    if (r != _rev) {
      _rev = r;
      _future = widget.load();
    }
  }

  @override
  void didUpdateWidget(covariant DataView<T> old) {
    super.didUpdateWidget(old);
    if (!listEquals(old.deps, widget.deps)) _future = widget.load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future,
      builder: (c, snap) {
        if (snap.hasData) return widget.builder(c, snap.data as T);
        if (snap.hasError) return Center(child: Text('Lỗi: ${snap.error}'));
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class EmptyState extends StatelessWidget {
  final String emoji;
  final String text;
  const EmptyState({super.key, this.emoji = '🗒️', required this.text});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(emoji, style: const TextStyle(fontSize: 44)),
            const SizedBox(height: 8),
            Text(text, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).hintColor)),
          ]),
        ),
      );
}

class CatAvatar extends StatelessWidget {
  final String icon;
  final String color;
  final double size;
  const CatAvatar({super.key, required this.icon, required this.color, this.size = 44});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: hexColor(color).withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(size * 0.3),
        ),
        child: Text(icon, style: TextStyle(fontSize: size * 0.5)),
      );
}

class TxTile extends StatelessWidget {
  final TxItem t;
  final VoidCallback? onTap;
  const TxTile({super.key, required this.t, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: CatAvatar(icon: t.catIcon, color: t.catColor),
      title: Text(t.note.isNotEmpty ? t.note : t.catName, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('${t.catName} • ${dmy(t.date)}${t.walletName != null ? ' • ${t.walletName}' : ''}',
          maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        if (t.receiptImage != null && File(t.receiptImage!).existsSync())
          const Padding(padding: EdgeInsets.only(right: 6), child: Icon(Icons.attach_file, size: 16)),
        Text(
          '${t.isIncome ? '+' : '-'}${money(t.amount)}',
          style: TextStyle(fontWeight: FontWeight.w700, color: t.isIncome ? kIncome : kExpense),
        ),
      ]),
    );
  }
}

Future<bool> confirmDialog(BuildContext context, String message, {String ok = 'Xoá'}) async {
  final r = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Xác nhận'),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Huỷ')),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(80, 40)),
          onPressed: () => Navigator.pop(c, true),
          child: Text(ok),
        ),
      ],
    ),
  );
  return r ?? false;
}

void snack(BuildContext context, String msg) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
}

/// Định dạng số tiền khi gõ: 1500000 -> 1.500.000
class ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    final f = money(int.parse(digits));
    return TextEditingValue(text: f, selection: TextSelection.collapsed(offset: f.length));
  }
}

double parseAmount(String s) => double.tryParse(s.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

String amountText(double v) => v == 0 ? '' : money(v);

Widget amountField(TextEditingController c, {String label = 'Số tiền (đ)'}) => TextField(
      controller: c,
      keyboardType: TextInputType.number,
      inputFormatters: [LengthLimitingTextInputFormatter(15), ThousandsFormatter()],
      decoration: InputDecoration(labelText: label),
    );

const kEmojis = ['💼', '🎁', '📈', '🍜', '🚗', '🛍️', '📚', '🎬', '🧾', '💊', '🏠', '✈️', '🎮', '☕', '💵', '🏦', '📱', '💳', '🐶', '⚽'];
const kColors = ['#22c55e', '#0ea5e9', '#1796A4', '#f97316', '#eab308', '#ec4899', '#6366f1', '#8b5cf6', '#ef4444', '#64748b'];

/// Chọn emoji + màu cho danh mục / ví
class EmojiColorPicker extends StatelessWidget {
  final String icon;
  final String color;
  final void Function(String icon, String color) onChanged;
  const EmojiColorPicker({super.key, required this.icon, required this.color, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Biểu tượng'),
      const SizedBox(height: 6),
      Wrap(spacing: 6, runSpacing: 6, children: [
        for (final e in kEmojis)
          GestureDetector(
            onTap: () => onChanged(e, color),
            child: Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: e == icon ? kPrimary : Colors.transparent, width: 2),
                color: hexColor(color).withValues(alpha: 0.15),
              ),
              child: Text(e, style: const TextStyle(fontSize: 20)),
            ),
          ),
      ]),
      const SizedBox(height: 12),
      const Text('Màu sắc'),
      const SizedBox(height: 6),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final c in kColors)
          GestureDetector(
            onTap: () => onChanged(icon, c),
            child: CircleAvatar(
              radius: 15,
              backgroundColor: hexColor(c),
              child: c == color ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
            ),
          ),
      ]),
    ]);
  }
}
