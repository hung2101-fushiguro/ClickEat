# FINAL SUBMISSION GUIDE - AUTOMATION TESTING (Selenium WebDriver)

Tài liệu này tổng hợp theo đúng nội dung hướng dẫn bạn đã gửi, dùng để đối chiếu trước khi nộp.

---

## 1) Chuỗi bài tập cần có trong repo

Bạn cần có đầy đủ các phần sau (không chỉ Exercise 5, 6):

- Unit Test
- Static Testing (Review code, Review Requirements, ...)
- Automation Testing with Selenium:
  - Exercise 1: Selenium Basic
  - Exercise 2: Data-driven test từ CSV
  - Exercise 3: POM
  - Exercise 4: BasePage + BaseTest
  - Exercise 5: DemoQA Practice Form (POM)
  - Exercise 6: Project nhóm (ít nhất 2 chức năng)

---

## 2) Yêu cầu cốt lõi cho từng Exercise Selenium

### Exercise 1 - Selenium Basic
- Tạo Maven project.
- Cấu hình dependency Selenium + JUnit.
- Viết test login cơ bản (Guru99 / Heroku app).
- Chụp ảnh kết quả chạy.

### Exercise 2 - Data-driven test
- Dùng `@ParameterizedTest` + `@CsvSource`.
- Dùng `@CsvFileSource` đọc từ file CSV ngoài (`src/test/resources`).
- Xử lý dữ liệu rỗng/trim để tránh lỗi do khoảng trắng.

### Exercise 3 - Page Object Model
- Tách `LoginPage` khỏi lớp test.
- Test class chỉ chứa logic kiểm thử (không thao tác DOM trực tiếp).
- Có thể tái sử dụng page class cho nhiều test case.

### Exercise 4 - BasePage + BaseTest
- `BasePage`: gom thao tác dùng chung (click, type, wait, getText, navigate...).
- `BaseTest`: gom setup/teardown WebDriver.
- Test class kế thừa `BaseTest`, page class kế thừa `BasePage`.

### Exercise 5 - DemoQA Practice Form
- Link: `https://demoqa.com/automation-practice-form`.
- Áp dụng POM, kế thừa `BasePage`, `BaseTest`.
- Có test submit form và assert kết quả.

### Exercise 6 - Project nhóm
- Áp dụng POM.
- Test ít nhất 2 chức năng (login/register/profile/upload avatar/change password/CRUD...).
- Có phần nâng cao nếu có (CI/CD, report...).
- Viết System Test theo mẫu Excel cho 2 chức năng đã chọn.

---

## 3) Yêu cầu nộp Edunext

### File Word bắt buộc có
- Exercise 5
- Exercise 6

Trong mỗi phần phải có:
- Từng bước làm.
- Ảnh chụp code tương ứng.
- Ảnh chụp kết quả chạy test tương ứng.
- Giải thích Expected / Actual / Kết luận.

### Code trên GitHub cá nhân
- Trong thư mục `Automation Testing`.
- Có 2 folder:
  - `Exercise 5`
  - `Exercise 6`
- Có file Excel System Test cho Exercise 6.

---

## 4) Trạng thái hiện tại trong repo này

Đã có:
- `Automation Testing/Exercise 5` (POM + BasePage/BaseTest + test)
- `Automation Testing/Exercise 6` (POM + Login/Register tests + CI workflow)
- `Automation Testing/Exercise 6/docs/System_Test_Exercise6.csv`
- `Automation Testing/Exercise 6/docs/Word_Report_Submission.md`

Lưu ý khi chạy test Exercise 6:
- Nếu báo `ERR_CONNECTION_REFUSED`, nghĩa là app local chưa chạy đúng URL/port.
- Cần chạy hệ thống tại `http://localhost:8080/ClickEat2` trước khi chạy test.

---

## 5) Checklist chốt nộp

- [ ] Có Word đầy đủ Exercise 5 + 6
- [ ] Có ảnh code + ảnh kết quả chạy
- [ ] Có giải thích expected/actual rõ ràng
- [ ] Có `Exercise 5`, `Exercise 6` trên GitHub
- [ ] Có file Excel system test
- [ ] (Khuyến nghị) Bổ sung Unit Test + Static Testing vào repo trước Presentation

---

## 6) Lệnh chạy nhanh

Trong từng folder exercise:

```bash
mvn test
```

Chạy có UI:

```bash
mvn test -Dheadless=false
```

Exercise 6 chạy với base URL local:

```bash
mvn test -Dbase.url=http://localhost:8080/ClickEat2
```

Exercise 6 bật test đăng ký positive:

```bash
mvn test -Drun.register.positive=true
```
