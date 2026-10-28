import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final NumberFormat _nf = NumberFormat('#,##0', 'en_US');

/// 1234567 -> "1.234.567"
String money(num v) => _nf.format(v.round()).replaceAll(',', '.');

/// 1234567 -> "1.234.567 đ"
String moneyD(num v) => '${money(v)} đ';

/// Rút gọn số tiền cho trục biểu đồ: 1.500.000 -> "1,5tr"
String moneyShort(num v) {
  final a = v.abs();
  if (a >= 1e9) return '${(v / 1e9).toStringAsFixed(1)}tỷ';
  if (a >= 1e6) return '${(v / 1e6).toStringAsFixed(1)}tr';
  if (a >= 1e3) return '${(v / 1e3).toStringAsFixed(0)}k';
  return v.toStringAsFixed(0);
}

String ymd(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
String ym(DateTime d) => DateFormat('yyyy-MM').format(d);

DateTime parseYmd(String s) => DateTime.parse(s);

/// "2026-10-19" -> "19/10/2026"
String dmy(String s) {
  try {
    return DateFormat('dd/MM/yyyy').format(DateTime.parse(s));
  } catch (_) {
    return s;
  }
}

Color hexColor(String hex, [Color fallback = const Color(0xFF1796A4)]) {
  try {
    var h = hex.replaceAll('#', '');
    if (h.length == 6) h = 'FF$h';
    return Color(int.parse(h, radix: 16));
  } catch (_) {
    return fallback;
  }
}

String colorToHex(Color c) =>
    '#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
