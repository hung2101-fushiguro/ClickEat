# BÁO CÁO CHI TIẾT - AUTOMATION TESTING (SELENIUM)

Thông tin sinh viên
- Họ tên: ........................................................
- MSSV: ........................................................
- Lớp: ........................................................
- Môn học: Automation Testing
- Ngày nộp: ........................................................

## 1. Mục tiêu báo cáo
- Trình bày quá trình thực hiện Exercise 5 và Exercise 6 theo yêu cầu môn học.
- Chứng minh việc áp dụng mô hình Page Object Model (POM), BasePage, BaseTest.
- Ghi nhận kết quả chạy test, phân tích nguyên nhân lỗi và cách khắc phục.

---

## 2. Exercise 5 - DemoQA Practice Form

### 2.1 Mục tiêu
- Kiểm thử form tại: https://demoqa.com/automation-practice-form
- Áp dụng POM, tái sử dụng lớp nền `BasePage` và `BaseTest`.

### 2.2 Thiết kế và cấu trúc
- Base lớp:
  - BaseTest: cấu hình WebDriver, đọc cấu hình, teardown.
  - BasePage: click/type/wait/scroll dùng chung.
- Page object:
  - PracticeFormPage: gom locator + thao tác trang DemoQA.
- Test class:
  - PracticeFormRegisterTest: kiểm thử luồng đăng ký đầy đủ.

### 2.3 Các bước thực hiện
1. Tạo project Maven cho Exercise 5.
2. Khai báo dependency Selenium, JUnit5, WebDriverManager trong pom.
3. Tạo BaseTest và BasePage.
4. Tạo PracticeFormPage (form field, chọn date, subject, hobby, state/city, submit).
5. Viết test shouldSubmitPracticeFormSuccessfully.
6. Chạy test và xác nhận dữ liệu trả về trong modal kết quả.

### 2.4 Vấn đề phát sinh và cách xử lý
- Lỗi click bị chặn (ElementClickInterceptedException):
  - Nguyên nhân: lớp phủ/ads/fixed footer che element.
  - Khắc phục: bổ sung safe click (scroll + fallback JS click), ẩn fixed ban/footer.
- Lỗi không tìm thấy option NCR:
  - Nguyên nhân: react-select hiển thị động.
  - Khắc phục: chọn State/City bằng input id react-select và Enter.

### 2.5 Kết quả chạy
- Test case chính Exercise 5 chạy thành công.
- Kết quả: pass.

### 2.6 Ảnh minh chứng (đã tạo tự động)
- Form đã điền trước submit:
  - Automation Testing/Exercise 5/docs/screenshots/ex5_form_filled_before_submit.png
- Modal kết quả sau submit:
  - Automation Testing/Exercise 5/docs/screenshots/ex5_submit_result_modal.png

---

## 3. Exercise 6 - Project nhóm ClickEat

### 3.1 Mục tiêu
- Áp dụng POM cho ứng dụng nhóm.
- Kiểm thử tối thiểu 2 chức năng: Login và Register.
- Có phần nâng cao: CI workflow.
- Có file System Test theo mẫu Excel.

### 3.2 Chức năng đã kiểm thử
1. Login
- Đăng nhập sai mật khẩu -> kiểm tra dấu hiệu thất bại.
- Đăng nhập đúng -> điều hướng về trang đúng role hoặc home.

2. Register
- Password và confirm không khớp -> hiển thị validation.
- Positive register có điều kiện cấu hình dữ liệu.

### 3.3 Thiết kế framework
- BaseTest:
  - Setup/teardown driver.
  - Đọc config test.
  - Kiểm tra server reachable trước test hệ thống để giảm fail do môi trường.
- BasePage:
  - Hàm thao tác UI dùng chung.
- Page objects:
  - LoginPage, RegisterPage, HomePage.
- Test classes:
  - LoginSystemTest, RegisterSystemTest.

### 3.4 Kết quả chạy và phân tích
- Lần đầu: có lỗi ERR_CONNECTION_REFUSED vì server chưa chạy.
- Sau khi khởi động môi trường và ổn định assertion/precondition:
  - Tổng quan chạy lại: Passed 7, Failed 0.

### 3.5 Nâng cao (CI/CD)
- Đã cấu hình workflow:
  - Automation Testing/Exercise 6/.github/workflows/ci.yml
- Tự động chạy test khi push hoặc chạy thủ công workflow_dispatch.

### 3.6 File test case System Test
- File Excel/CSV:
  - Automation Testing/Exercise 6/docs/System_Test_Exercise6.csv
- Gồm các mã test case:
  - LGN_01, LGN_02, LGN_03
  - REG_01, REG_02, REG_03, REG_04, REG_05

### 3.7 Ảnh minh chứng (đã tạo tự động)
- Login page:
  - Automation Testing/Exercise 6/docs/screenshots/ex6_login_page.png
- Login invalid result:
  - Automation Testing/Exercise 6/docs/screenshots/ex6_login_invalid_result.png
- Login valid result:
  - Automation Testing/Exercise 6/docs/screenshots/ex6_login_valid_result.png
- Register page:
  - Automation Testing/Exercise 6/docs/screenshots/ex6_register_page.png
- Register mismatch result:
  - Automation Testing/Exercise 6/docs/screenshots/ex6_register_mismatch_result.png

---

## 4. Kết luận
- Đã hoàn thành Exercise 5 và Exercise 6 theo đúng yêu cầu cốt lõi.
- Đã áp dụng đầy đủ POM, BasePage, BaseTest.
- Đã xây dựng test case system test cho 2 chức năng (Login, Register).
- Đã bổ sung phần nâng cao CI workflow.
- Đã chuẩn bị ảnh minh chứng để chèn vào Word nộp Edunext.

---

## 5. Checklist trước khi nộp
- [ ] Điền đầy đủ thông tin sinh viên trong báo cáo.
- [ ] Chèn toàn bộ ảnh minh chứng vào file Word.
- [ ] Đính kèm giải thích expected/actual cho từng phần.
- [ ] Kiểm tra repo GitHub có đủ 2 thư mục Exercise 5, Exercise 6.
- [ ] Kiểm tra có file System_Test_Exercise6.csv.

---

## 6. Tham chiếu
- Repo: https://github.com/dinocuzy/Automation-Testing
- Báo cáo chuẩn rút gọn: Automation Testing/Exercise 6/docs/Word_Report_Submission.md
- Hướng dẫn nộp: Automation Testing/Exercise 6/docs/Word_Report_Guide.md
