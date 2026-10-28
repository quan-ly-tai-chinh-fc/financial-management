# 💰 FINCARE — Ứng dụng quản lý tài chính cá nhân

**FINCARE** là ứng dụng quản lý tài chính cá nhân được phát triển bằng Flutter và ngôn ngữ Dart. Ứng dụng giúp người dùng quản lý thu nhập, chi tiêu, ví tiền, ngân sách và các khoản vay một cách trực quan, thuận tiện.

Dự án được phát triển theo hướng ứng dụng di động, kế thừa các nghiệp vụ chính của hệ thống quản lý tài chính cá nhân và tối ưu trải nghiệm sử dụng trên điện thoại.

---

## 1. Thông tin dự án

| Thông tin | Chi tiết |
|---|---|
| Tên dự án | FINCARE |
| Lĩnh vực | Quản lý tài chính cá nhân |
| Nền tảng | Ứng dụng di động |
| Framework | Flutter |
| Ngôn ngữ lập trình | Dart |
| Cơ sở dữ liệu chính | SQLite |
| Quản lý trạng thái | Provider |
| Biểu đồ | FL Chart |
| Phiên bản | 1.0.0 |
| Mục đích | Học tập và phát triển ứng dụng quản lý tài chính cá nhân |

## 2. Mục tiêu dự án

FINCARE được xây dựng nhằm hỗ trợ người dùng theo dõi và kiểm soát tình hình tài chính cá nhân thông qua các chức năng:

- Quản lý các khoản thu nhập và chi tiêu.
- Theo dõi số dư và tình hình tài chính tổng quan.
- Quản lý nhiều ví tiền.
- Phân loại giao dịch theo danh mục.
- Thiết lập và theo dõi ngân sách.
- Thống kê thu chi bằng biểu đồ.
- Quản lý các khoản cho vay, đi vay và trả nợ.
- Thiết lập giao dịch định kỳ.
- Bảo vệ dữ liệu tài chính theo tài khoản người dùng.

## 3. Các chức năng chính

### 3.1. Quản lý tài khoản
- Đăng ký tài khoản mới.
- Đăng nhập bằng email và mật khẩu.
- Khôi phục mật khẩu bằng câu hỏi bảo mật.
- Giới hạn đăng nhập sai và khóa tài khoản tạm thời.
- Quản lý thông tin cá nhân.
- Đăng xuất khỏi ứng dụng.

### 3.2. Tổng quan tài chính
- Hiển thị số dư hiện tại.
- Tổng hợp thu nhập và chi tiêu.
- Theo dõi tình hình tài chính theo thời gian.
- Hiển thị biểu đồ thu chi.
- Theo dõi các giao dịch gần đây.
- Hỗ trợ nhận biết tình hình chi tiêu thông qua các thông tin tổng hợp.

### 3.3. Quản lý giao dịch
- Thêm giao dịch thu nhập.
- Thêm giao dịch chi tiêu.
- Chỉnh sửa thông tin giao dịch.
- Xóa giao dịch.
- Tìm kiếm và lọc giao dịch.
- Phân loại giao dịch theo danh mục.
- Liên kết giao dịch với ví tiền.
- Lưu thông tin ngày giao dịch và ghi chú.
- Hỗ trợ đính kèm ảnh hóa đơn theo chức năng được triển khai.
- Xuất và chia sẻ danh sách giao dịch dưới dạng CSV.

### 3.4. Quản lý ví tiền
- Tạo và quản lý các ví tiền.
- Theo dõi số dư ban đầu.
- Tính toán số dư dựa trên các giao dịch thu chi.
- Phân biệt các ví theo tên, loại và biểu tượng.

### 3.5. Quản lý danh mục
- Quản lý danh mục thu nhập.
- Quản lý danh mục chi tiêu.
- Phân loại giao dịch theo mục đích sử dụng.
- Hỗ trợ biểu tượng và màu sắc cho danh mục.

### 3.6. Quản lý ngân sách
- Thiết lập ngân sách theo danh mục và tháng.
- Theo dõi mức chi tiêu so với hạn mức.
- Tính tỷ lệ sử dụng ngân sách.
- Cảnh báo khi chi tiêu đạt ngưỡng hoặc vượt ngân sách.

### 3.7. Báo cáo và thống kê
- Theo dõi tổng thu nhập và chi tiêu.
- Xem biểu đồ tài chính theo thời gian.
- Phân tích cơ cấu chi tiêu theo danh mục.
- Hỗ trợ người dùng đánh giá tình hình tài chính cá nhân.

### 3.8. Quản lý khoản vay
- Ghi nhận các khoản cho vay và đi vay.
- Theo dõi số tiền đã trả.
- Theo dõi số dư nợ còn lại.
- Lưu ngày đến hạn và ghi chú.
- Quản lý các lần trả nợ.

### 3.9. Quản lý giao dịch định kỳ
- Thiết lập các khoản thu chi định kỳ.
- Cấu hình số tiền, danh mục và ví liên quan.
- Bật hoặc tắt giao dịch định kỳ.
- Hỗ trợ tạo giao dịch khi đến kỳ theo logic của ứng dụng.

### 3.10. Giao diện
- Giao diện được xây dựng bằng Flutter.
- Các thành phần giao diện được tổ chức thành những widget có thể tái sử dụng.
- Hỗ trợ tùy chỉnh giao diện sáng và tối theo phần cài đặt được triển khai.

---

## 4. Công nghệ sử dụng

| Công nghệ | Vai trò |
|---|---|
| Flutter | Xây dựng giao diện và ứng dụng di động |
| Dart | Ngôn ngữ lập trình chính |
| SQLite | Lưu trữ dữ liệu cục bộ |
| sqflite | Kết nối và thao tác với SQLite |
| Provider | Quản lý trạng thái ứng dụng |
| FL Chart | Hiển thị biểu đồ tài chính |
| Shared Preferences | Lưu trữ các thiết lập đơn giản |
| Crypto | Hỗ trợ băm mật khẩu và dữ liệu bảo mật |
| Intl | Định dạng ngày tháng và số tiền |
| Image Picker | Chọn hoặc chụp ảnh |
| Share Plus | Chia sẻ dữ liệu |
| Firebase Core | Thư viện nền tảng Firebase |
| Cloud Firestore | Hỗ trợ tích hợp lưu trữ dữ liệu trên Firebase |

**Lưu ý:** SQLite là cơ sở dữ liệu hoạt động chính trong phiên bản hiện tại. Việc có các thư viện Firebase trong dự án không đồng nghĩa ứng dụng đã được kết nối và vận hành với Firebase.

---

## 5. Cấu trúc thư mục

```text
fincare_flutter/
│
├── lib/
│   ├── main.dart
│   ├── app_state.dart
│   │
│   ├── core/
│   │   ├── theme.dart
│   │   └── format.dart
│   │
│   ├── data/
│   │   ├── base_entity.dart
│   │   ├── db.dart
│   │   ├── firestore_repository.dart
│   │   └── models.dart
│   │
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── forgot_password_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── transactions_screen.dart
│   │   ├── transaction_form_screen.dart
│   │   ├── wallets_screen.dart
│   │   ├── categories_screen.dart
│   │   ├── budgets_screen.dart
│   │   ├── reports_screen.dart
│   │   ├── loans_screen.dart
│   │   ├── recurring_screen.dart
│   │   ├── profile_screen.dart
│   │   ├── more_screen.dart
│   │   └── home_shell.dart
│   │
│   └── widgets/
│       ├── charts.dart
│       └── common.dart
│
├── docs/
│   └── BAO_CAO_DO_AN.md
│
├── test/
│   └── widget_test.dart
│
├── pubspec.yaml
├── analysis_options.yaml
├── .gitignore
└── README.md
```

### Vai trò của các thư mục

- **`lib/screens/`**: Chứa các màn hình và giao diện chính.
- **`lib/widgets/`**: Chứa các thành phần giao diện có thể tái sử dụng.
- **`lib/data/`**: Chứa các lớp dữ liệu, mô hình và logic truy cập cơ sở dữ liệu.
- **`lib/core/`**: Chứa cấu hình giao diện và các hàm tiện ích.
- **`lib/app_state.dart`**: Quản lý trạng thái ứng dụng.
- **`docs/`**: Chứa tài liệu phân tích và báo cáo đồ án.
- **`test/`**: Chứa mã nguồn kiểm thử.

---

## 6. Yêu cầu môi trường

Trước khi chạy dự án, cần chuẩn bị:

- Flutter SDK tương thích với dự án.
- Dart SDK phiên bản từ `3.3.0` đến dưới `4.0.0`.
- Android Studio hoặc Visual Studio Code.
- Android SDK nếu chạy trên Android.
- Git nếu muốn quản lý mã nguồn bằng Git.
- Thiết bị Android hoặc trình giả lập để chạy thử.

Có thể kiểm tra môi trường bằng lệnh:

```bash
flutter doctor
```

Kiểm tra phiên bản Flutter:

```bash
flutter --version
```

---

## 7. Hướng dẫn cài đặt và chạy dự án

### Bước 1: Tải mã nguồn

Clone dự án từ GitHub:

```bash
git clone <GITHUB_REPOSITORY_URL>
```

Di chuyển vào thư mục dự án:

```bash
cd fincare_flutter
```

Thay `<GITHUB_REPOSITORY_URL>` bằng địa chỉ repository thực tế của nhóm.

Nếu đã tải file ZIP, hãy giải nén và mở thư mục `fincare_flutter` bằng Android Studio hoặc Visual Studio Code.

### Bước 2: Kiểm tra cấu hình nền tảng

Nếu dự án chưa có các thư mục `android/` và `ios/`, hãy tạo cấu hình nền tảng bằng lệnh:

```bash
flutter create --org vn.fincare --project-name fincare .
```

Lệnh này được sử dụng tại thư mục gốc của dự án Flutter để bổ sung cấu hình nền tảng còn thiếu.

Nếu các thư mục nền tảng đã tồn tại và được cấu hình đầy đủ, có thể bỏ qua bước này.

### Bước 3: Cài đặt thư viện

Chạy lệnh:

```bash
flutter pub get
```

Flutter sẽ tải các thư viện được khai báo trong `pubspec.yaml`.

### Bước 4: Kiểm tra thiết bị

Chạy:

```bash
flutter devices
```

Đảm bảo đã kết nối điện thoại hoặc khởi động trình giả lập.

### Bước 5: Chạy ứng dụng

```bash
flutter run
```

Nếu muốn chạy trên một thiết bị cụ thể:

```bash
flutter run -d <DEVICE_ID>
```

Trong đó, `<DEVICE_ID>` là mã thiết bị hiển thị sau khi chạy lệnh `flutter devices`.

### Bước 6: Kiểm tra mã nguồn

Để kiểm tra các lỗi phân tích Dart:

```bash
flutter analyze
```

Để chạy các bài kiểm thử:

```bash
flutter test
```

---

## 8. Cơ sở dữ liệu

FINCARE sử dụng SQLite để lưu dữ liệu cục bộ trên thiết bị.

Cơ sở dữ liệu được khởi tạo và quản lý chủ yếu trong:

```text
lib/data/db.dart
```

Các bảng dữ liệu chính gồm:

| Bảng | Chức năng |
|---|---|
| `users` | Lưu thông tin tài khoản |
| `categories` | Lưu danh mục thu chi |
| `wallets` | Lưu thông tin ví tiền |
| `transactions` | Lưu các giao dịch |
| `budgets` | Lưu ngân sách |
| `loans` | Lưu các khoản vay và cho vay |
| `loan_repayments` | Lưu lịch sử trả nợ |
| `recurring_transactions` | Lưu các giao dịch định kỳ |

### Quan hệ dữ liệu

- Một người dùng có thể sở hữu nhiều ví tiền.
- Một người dùng có thể tạo nhiều giao dịch.
- Giao dịch có thể liên kết với danh mục và ví tiền.
- Ngân sách được thiết lập theo danh mục và tháng.
- Một khoản vay có thể có nhiều lần trả nợ.
- Người dùng có thể thiết lập nhiều giao dịch định kỳ.

### Nguyên tắc xử lý dữ liệu

- Các truy vấn nghiệp vụ cần giới hạn dữ liệu theo tài khoản người dùng.
- Số dư ví được tính dựa trên số dư ban đầu và các giao dịch liên quan.
- Dữ liệu liên quan được xử lý theo các ràng buộc khóa ngoại.
- Các nghiệp vụ trả nợ cần cập nhật thông tin khoản vay và các giao dịch tương ứng.

**Lưu ý:** SQLite lưu dữ liệu trên thiết bị. Dữ liệu không tự động đồng bộ giữa nhiều điện thoại chỉ bằng việc sử dụng SQLite.

---

## 9. Bảo mật và quyền riêng tư

Dự án triển khai một số biện pháp bảo vệ dữ liệu:

- Mật khẩu không được lưu trực tiếp dưới dạng văn bản thuần.
- Sử dụng SHA-256 kết hợp salt trong logic băm mật khẩu hiện tại.
- Giới hạn số lần đăng nhập sai và hỗ trợ khóa tài khoản tạm thời.
- Các truy vấn dữ liệu cần lọc theo tài khoản đang đăng nhập.
- Sử dụng ràng buộc khóa ngoại để duy trì tính nhất quán dữ liệu.

Đây là các biện pháp bảo vệ cơ bản phục vụ phạm vi dự án học tập. Trước khi sử dụng thực tế, cần đánh giá thêm về cơ chế xác thực, quản lý phiên đăng nhập, lưu trữ thông tin nhạy cảm và khả năng chống tấn công.

Đặc biệt, SHA-256 tự triển khai không phải lựa chọn tối ưu để lưu trữ mật khẩu trong hệ thống sản xuất. Nên cân nhắc thuật toán chuyên dụng cho mật khẩu như Argon2id hoặc bcrypt.

---

## 10. Phân công công việc nhóm

Dự án có thể được phát triển bởi nhóm 3 thành viên theo các nhóm chức năng sau:

| Thành viên | Phạm vi công việc |
|---|---|
| NGUYEN MUNH TUAN | Đăng nhập, đăng ký, khôi phục mật khẩu, quản lý tài khoản và tích hợp các thành phần dùng chung |
| NGUYEN ANH TAI | Giao dịch thu chi, tổng quan tài chính, báo cáo và biểu đồ |
| NGUYEN HUU TRUNG | Ví tiền, danh mục, ngân sách, khoản vay và giao dịch định kỳ |

Tên thành viên, mã sinh viên và nội dung đóng góp cụ thể cần được cập nhật theo công việc thực tế.

### Quy trình phối hợp

1. Thống nhất yêu cầu và cấu trúc dữ liệu trước khi lập trình.
2. Phân chia chức năng và file phụ trách cho từng thành viên.
3. Sử dụng Git để quản lý các phiên bản mã nguồn.
4. Tích hợp code thông qua Pull Request hoặc quy trình kiểm tra tương đương.
5. Kiểm thử toàn bộ ứng dụng sau khi tích hợp.
6. Hoàn thiện tài liệu và chuẩn bị bản demo.

---

## 11. Kiểm thử

Nhóm nên kiểm thử tối thiểu các tình huống sau:

| Nhóm chức năng | Nội dung kiểm thử |
|---|---|
| Tài khoản | Đăng ký, đăng nhập, nhập sai mật khẩu, đăng xuất |
| Giao dịch | Thêm, sửa, xóa và tìm kiếm giao dịch |
| Ví tiền | Tạo ví và kiểm tra số dư |
| Danh mục | Tạo và quản lý danh mục thu chi |
| Ngân sách | Kiểm tra tỷ lệ sử dụng và cảnh báo |
| Báo cáo | Đối chiếu số liệu biểu đồ với dữ liệu giao dịch |
| Khoản vay | Ghi nhận khoản vay và kiểm tra số dư nợ |
| Giao dịch định kỳ | Kiểm tra việc tạo giao dịch đến hạn |
| Dữ liệu | Đóng và mở lại ứng dụng để kiểm tra dữ liệu đã lưu |

Kết quả kiểm thử cần được cập nhật dựa trên quá trình chạy ứng dụng thực tế. Không nên đánh dấu một chức năng là đã kiểm thử thành công nếu chưa thực hiện kiểm tra.

---

## 12. Hướng phát triển

Trong các phiên bản tiếp theo, FINCARE có thể được mở rộng theo các hướng:

- Đồng bộ dữ liệu giữa nhiều thiết bị bằng backend hoặc Firebase.
- Bổ sung sao lưu và khôi phục dữ liệu.
- Hoàn thiện xuất báo cáo PDF.
- Phát triển hệ thống thông báo nhắc nhở thanh toán.
- Bổ sung thống kê và phân tích chi tiêu nâng cao.
- Cải thiện cơ chế xác thực và bảo vệ dữ liệu.
- Hoàn thiện kiểm thử tự động.
- Phát triển giao diện quản trị nếu phạm vi dự án yêu cầu.

Các nội dung trên là định hướng phát triển, không đồng nghĩa tất cả đã có trong phiên bản hiện tại.

---
**FINCARE — Quản lý tài chính thông minh, kiểm soát chi tiêu hiệu quả.**
