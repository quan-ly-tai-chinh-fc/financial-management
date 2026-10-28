import 'package:fincare/core/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('định dạng tiền Việt', () {
    expect(money(1234567), '1.234.567');
    expect(moneyD(50000), '50.000 đ');
    expect(moneyShort(1500000), '1.5tr');
  });

  test('định dạng ngày', () {
    expect(dmy('2026-10-19'), '19/10/2026');
    expect(ym(DateTime(2026, 3, 5)), '2026-03');
  });
}
