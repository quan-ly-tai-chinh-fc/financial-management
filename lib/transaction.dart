class Transaction {
  String title = "An sang";
  double amount = 50000;
  String category = "An uong";
  String type = "Chi";
  String date = "02/10/2026";

  void setTransaction(
    String title,
    double amount,
    String category,
    String type,
    String date,
  ) {
    this.title = title;
    this.amount = amount;
    this.category = category;
    this.type = type;
    this.date = date;
  }

  String getTitle() {
    return title;
  }

  String getAmount() {
    return "${amount.toStringAsFixed(0)} VND";
  }

  String getCategory() {
    return category;
  }

  String getType() {
    return type;
  }

  String getDate() {
    return date;
  }
}