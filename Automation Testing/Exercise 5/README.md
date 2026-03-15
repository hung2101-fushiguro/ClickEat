# Exercise 5 - DemoQA Practice Form (POM)

## Mục tiêu
- Kiểm thử form đăng ký tại: https://demoqa.com/automation-practice-form
- Áp dụng mô hình Page Object Model (POM)
- Kế thừa từ `BasePage`, `BaseTest`

## Cấu trúc
- `base/BaseTest.java`: setup/teardown WebDriver
- `base/BasePage.java`: thao tác chung với element
- `pages/PracticeFormPage.java`: các action cho Practice Form
- `tests/PracticeFormRegisterTest.java`: test case system test chính

## Cách chạy
```bash
mvn test
```

Hoặc chạy có UI:
```bash
mvn test -Dheadless=false
```

## Minh chứng để chụp report Word
1. Cấu trúc package và class POM
2. Đoạn code `PracticeFormPage` + `PracticeFormRegisterTest`
3. Kết quả test pass trên terminal/IDE
4. Popup kết quả "Thanks for submitting the form"
