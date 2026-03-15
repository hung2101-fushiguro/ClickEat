# Exercise 6 - ClickEat System Test (POM)

## Chức năng kiểm thử
- Login
- Đăng ký tài khoản

## Áp dụng kỹ thuật
- POM: `BasePage`, `BaseTest`, page classes riêng cho từng màn hình
- System test theo test case (tham chiếu file CSV mở bằng Excel trong `docs`)
- Nâng cao: có CI workflow mẫu trong `.github/workflows/ci.yml`

## Cấu trúc chính
- `base/`: lớp dùng chung
- `pages/`: `LoginPage`, `RegisterPage`, `HomePage`
- `tests/`: `LoginSystemTest`, `RegisterSystemTest`
- `docs/System_Test_Exercise6.csv`: test case theo mẫu excel

## Cách chạy
```bash
mvn test
```

Chạy có UI:
```bash
mvn test -Dheadless=false
```

Ghi đè URL hệ thống:
```bash
mvn test -Dbase.url=http://localhost:8080/ClickEat2
```

Bật case đăng ký thành công (ghi dữ liệu DB mới):
```bash
mvn test -Drun.register.positive=true
```

## Gợi ý chụp hình cho file Word
1. Cây thư mục POM
2. Code BasePage/BaseTest
3. Code từng Page + Test class
4. Kết quả chạy test pass/fail
5. Giải thích nguyên nhân và expected/actual
