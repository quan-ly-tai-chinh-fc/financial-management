class FinancialProfile {
  String accountName = "Ví Cá Nhân";
  double balance = 15000000; // Số dư tài khoản: 15.000.000 VNĐ
  String currency = "VND";

  // Phương thức thiết lập/cập nhật thông tin tài chính
  void setFinancialProfile(String accountName, double balance, String currency) {
    this.accountName = accountName;
    this.balance = balance;
    this.currency = currency;
  }

  // Phương thức trả về chuỗi thông tin tài chính
  String getFinancialProfile() {
    return "$accountName: ${balance.toStringAsFixed(0)} $currency";
  }
}