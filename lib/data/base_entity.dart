/// Lớp cơ sở generic cho các thực thể của FINCARE.
/// T là kiểu dữ liệu của khóa định danh (int, String, ...).
abstract class BaseEntity<T> {
  final T id;
  final String name;

  const BaseEntity({required this.id, required this.name});

  /// Chuyển đối tượng thành Map để lưu trữ (SQLite/Firestore).
  Map<String, Object?> toMap();
}
