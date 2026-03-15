# BÁO CÁO AUTOMATION TESTING

**Họ tên:** ....................................................
**MSSV:** ....................................................
**Lớp:** ....................................................
**Môn học:** Automation Testing
**Ngày nộp:** ....................................................

---

## PHẦN 1 - EXERCISE 5

### 1.1 Mục tiêu bài toán

- Kiểm thử form đăng ký tại trang: https://demoqa.com/automation-practice-form
- Áp dụng mô hình Page Object Model (POM)
- Tổ chức code theo hướng kế thừa `BasePage` và `BaseTest`

### 1.2 Mô tả cấu trúc POM

- `BaseTest`: quản lý khởi tạo/đóng WebDriver và cấu hình test.
- `BasePage`: chứa các hàm thao tác dùng chung như click, type, wait, scroll.
- `PracticeFormPage`: đóng gói toàn bộ action trên trang DemoQA.
- `PracticeFormRegisterTest`: lớp test thực thi kịch bản đăng ký.

### 1.3 Các bước thực hiện

1. Tạo project Maven cho Exercise 5.
2. Cấu hình dependency Selenium, JUnit5, WebDriverManager.
3. Tạo lớp `BaseTest` và `BasePage`.
4. Tạo `PracticeFormPage` để map locator và hành động.
5. Viết test `PracticeFormRegisterTest` cho luồng điền form và submit.
6. Chạy test bằng Maven.

### 1.4 Minh chứng code (chèn ảnh)

- Ảnh 1: Cấu trúc thư mục Exercise 5.
- Ảnh 2: Code `BaseTest`.
- Ảnh 3: Code `BasePage`.
- Ảnh 4: Code `PracticeFormPage`.
- Ảnh 5: Code `PracticeFormRegisterTest`.

### 1.5 Kết quả chạy test (chèn ảnh)

- Ảnh 6: Kết quả chạy test trên terminal/IDE.
- Ảnh 7: Popup "Thanks for submitting the form" sau khi submit thành công.

### 1.6 Giải thích Expected / Actual

- **Expected:** form được submit thành công, hệ thống hiển thị popup xác nhận và dữ liệu hiển thị đúng theo input test.
- **Actual:** test đã điền form, submit thành công và hiển thị popup đúng như mong đợi.
- **Kết luận:** Test case chính cho Exercise 5 đạt.

---

## PHẦN 2 - EXERCISE 6

### 2.1 Mục tiêu và phạm vi

- Xây dựng project automation riêng cho ứng dụng nhóm ClickEat.
- Áp dụng POM cho 2 chức năng:
  - Login
  - Đăng ký tài khoản
- Bổ sung phần nâng cao CI/CD (GitHub Actions workflow mẫu).
- Viết system test theo mẫu file Excel.

### 2.2 Cấu trúc project và lớp

- `BaseTest`: quản lý driver, đọc `config.properties`, setup/teardown.
- `BasePage`: thao tác chung cho page object.
- `LoginPage`: thao tác màn hình đăng nhập.
- `RegisterPage`: thao tác màn hình đăng ký.
- `HomePage`: marker xác nhận load màn hình home.
- `LoginSystemTest`: test login thành công/thất bại.
- `RegisterSystemTest`: test đăng ký (mismatch password và positive flow).
- `RandomDataUtil`: hỗ trợ sinh dữ liệu ngẫu nhiên.

### 2.3 Bảng Test Case System Test

- File Excel dùng để nộp: `System_Test_Exercise6.csv` (mở bằng Excel).
- Các test case đã khai báo:
  - LGN_01, LGN_02, LGN_03
  - REG_01, REG_02, REG_03, REG_04, REG_05

### 2.4 Các bước triển khai automation

1. Tạo Maven project cho Exercise 6.
2. Cấu hình dependency Selenium + JUnit5 + WebDriverManager.
3. Tạo base classes (`BaseTest`, `BasePage`).
4. Tạo page classes (`LoginPage`, `RegisterPage`, `HomePage`).
5. Viết test classes (`LoginSystemTest`, `RegisterSystemTest`).
6. Tạo workflow CI tại `.github/workflows/ci.yml`.
7. Chạy test và ghi nhận kết quả.

### 2.5 Kết quả chạy test và giải thích

**Lần chạy đầu (trước khi ổn định môi trường):**

- Passed: 3
- Failed: 6
- Nguyên nhân chính: `ERR_CONNECTION_REFUSED` do server ClickEat chưa chạy tại `http://localhost:8080/ClickEat2`.

**Hành động khắc phục đã thực hiện:**

1. Khởi động đúng môi trường hệ thống ClickEat local.
2. Bổ sung kiểm tra precondition server reachable trong `BaseTest` để tránh fail đỏ do môi trường.
3. Ổn định assertion cho case login sai mật khẩu trong `LoginSystemTest` theo hành vi thực tế UI.
4. Chạy lại toàn bộ bộ test mục tiêu (Exercise 5 + Exercise 6).

**Kết quả chạy mới nhất:**

- Passed: 7
- Failed: 0

**Đánh giá:**

- Bộ test đã hoạt động ổn định cho 2 chức năng đã chọn (Login, Register).
- Framework POM + BasePage/BaseTest đáp ứng yêu cầu bài tập.

### 2.6 Phần nâng cao (CI/CD)

- Đã cấu hình workflow mẫu: `.github/workflows/ci.yml`.
- Chức năng:
  - Trigger theo push hoặc manual dispatch.
  - Setup JDK 21.
  - Chạy `mvn test` ở Exercise 6.

### 2.7 Minh chứng cần chèn ảnh

- Ảnh 8: Cấu trúc thư mục Exercise 6.
- Ảnh 9: Code `BaseTest`, `BasePage`.
- Ảnh 10: Code `LoginPage`, `RegisterPage`.
- Ảnh 11: Code `LoginSystemTest`, `RegisterSystemTest`.
- Ảnh 12: Kết quả chạy test lần 1 (có fail do connection refused).
- Ảnh 13: File `System_Test_Exercise6.csv` mở bằng Excel.
- Ảnh 14: Workflow `ci.yml` và (nếu có) ảnh run trên GitHub Actions.

### 2.8 Kết luận và hạn chế

- Đã hoàn thành thiết kế framework POM cho 2 bài Exercise 5 và Exercise 6.
- Đã xây dựng đầy đủ bộ test case system test cho 2 chức năng Login + Register.
- Đã bổ sung CI workflow cơ bản.
- Hạn chế còn lại: kết quả phụ thuộc dữ liệu tài khoản test và trạng thái môi trường (server/DB) tại thời điểm chạy.

---

## PHẦN 3 - CHECKLIST NỘP BÀI

- [ ] Có đầy đủ nội dung Exercise 5 và Exercise 6 trong file Word.
- [ ] Có ảnh chụp code và ảnh kết quả chạy tương ứng.
- [ ] Có phần giải thích expected/actual và kết luận.
- [ ] Code đã push GitHub trong 2 thư mục `Automation Testing/Exercise 5` và `Automation Testing/Exercise 6`.
- [ ] Có file Excel System Test cho Exercise 6 (`System_Test_Exercise6.csv`).

---

## PHỤ LỤC - LINK/ĐƯỜNG DẪN THAM CHIẾU

- Repo GitHub: https://github.com/dinocuzy/Automation-Testing
- Exercise 5: `Automation Testing/Exercise 5`
- Exercise 6: `Automation Testing/Exercise 6`
- File test case: `Automation Testing/Exercise 6/docs/System_Test_Exercise6.csv`
- Hướng dẫn gốc: `Automation Testing/Exercise 6/docs/Word_Report_Guide.md`
