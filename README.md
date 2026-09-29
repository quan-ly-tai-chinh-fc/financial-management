# 💰 ỨNG DỤNG QUẢN LÝ TÀI CHÍNH CÁ NHÂN

## 1. Giới thiệu

Ứng dụng Quản lý Tài chính Cá nhân được xây dựng bằng **Flutter** nhằm hỗ trợ người dùng theo dõi và quản lý tình hình tài chính cá nhân một cách thuận tiện.

Ứng dụng cho phép người dùng theo dõi số dư, thu nhập, chi tiêu, các giao dịch gần đây và xem thống kê tài chính.

---

## 2. Công nghệ sử dụng

* **Flutter**
* **Dart**
* **Material Design**
* **Android Studio / Visual Studio Code**

---

## 3. Các chức năng chính

### 🏠 Trang chủ

* Hiển thị số dư hiện tại.
* Hiển thị tổng thu nhập.
* Hiển thị tổng chi tiêu.
* Hiển thị các giao dịch gần đây.

### 💳 Giao dịch

* Quản lý các khoản thu.
* Quản lý các khoản chi.
* Theo dõi lịch sử giao dịch.

### 📊 Thống kê

* Theo dõi tình hình thu chi.
* Phân loại các khoản chi tiêu.
* Hỗ trợ người dùng kiểm soát tài chính.

### 👤 Cá nhân

* Xem thông tin tài khoản.
* Quản lý thông tin cá nhân.

---

# 4. Wireframe

## 4.1. Wireframe màn hình Trang chủ

![Wireframe Home](images/wireframe_home.png)

Màn hình Trang chủ hiển thị tổng quan tình hình tài chính của người dùng, bao gồm số dư, thu nhập, chi tiêu và các giao dịch gần đây.

---

## 4.2. Wireframe màn hình Giao dịch

![Wireframe Transaction](images/wireframe_transaction.png)

Màn hình Giao dịch cho phép người dùng theo dõi các khoản thu và chi trong tài khoản.

---

## 4.3. Wireframe màn hình Cá nhân

![Wireframe Profile](images/wireframe_profile.png)

Màn hình Cá nhân hiển thị thông tin tài khoản và các chức năng quản lý thông tin người dùng.

---

# 5. Navigation Bottom Bar

Ứng dụng sử dụng **Bottom Navigation Bar** để người dùng có thể chuyển đổi nhanh giữa các chức năng chính.

Các mục gồm:

| STT | Chức năng    |
| --- | ------------ |
| 1   | 🏠 Trang chủ |
| 2   | 💳 Giao dịch |
| 3   | 📊 Thống kê  |
| 4   | 👤 Cá nhân   |

### Hình ảnh Navigation Bottom Bar

![Navigation Bottom Bar](images/bottom_navigation.png)

---

# 6. Màn hình sinh viên phụ trách

Sinh viên phụ trách xây dựng **màn hình Trang chủ (Home Screen)**.

Màn hình bao gồm:

* Lời chào người dùng.
* Số dư hiện tại.
* Tổng thu nhập.
* Tổng chi tiêu.
* Danh sách giao dịch gần đây.
* Navigation Bottom Bar.

### Hình ảnh màn hình đã chạy

![Home Screen](images/home_screen.png)

---

# 7. Cấu trúc thư mục

```text
lib/
├── main.dart
├── screens/
│   └── home_screen.dart
└── widgets/
    └── bottom_nav_bar.dart
```

---

# 8. Thành viên nhóm

| STT | Họ và tên        | Công việc          |
| --- | ---------------- | ------------------ |
| 1   | ................ | Home Screen        |
| 2   | ................ | Transaction Screen |
| 3   | ................ | Navigation / UI    |
| 4   | ................ | Statistics Screen  |

---

# 9. Kết luận

Ứng dụng Quản lý Tài chính Cá nhân giúp người dùng theo dõi thu nhập, chi tiêu và tình hình tài chính thông qua giao diện đơn giản, dễ sử dụng.

Ứng dụng được phát triển bằng Flutter và có khả năng mở rộng thêm các chức năng như đăng nhập, lưu trữ dữ liệu, biểu đồ thống kê và thông báo tài chính.

