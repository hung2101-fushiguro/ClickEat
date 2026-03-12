<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Đăng Ký - ClickEat</title>
        <style>
            body { font-family: 'Inter', sans-serif; display: flex; justify-content: center; margin-top: 30px; }
            .register-container { border: 1px solid #ccc; padding: 20px; border-radius: 8px; width: 350px; }
            input { width: 100%; padding: 8px; margin: 5px 0 15px 0; box-sizing: border-box; }
            button { width: 100%; padding: 10px; background-color: #007bff; color: white; border: none; cursor: pointer; border-radius: 4px;}
            button:hover { background-color: #0056b3; }
            .error { color: red; font-size: 14px; text-align: center; }
            .link { display: block; text-align: center; margin-top: 15px; text-decoration: none; color: #007bff;}
        </style>
    </head>
    <body>
        <div class="register-container">
            <h2 style="text-align: center;">Tạo Tài Khoản ClickEat</h2>
            
            <c:if test="${not empty error}">
                <p class="error">❌ ${error}</p>
            </c:if>

            <form action="register" method="post">
                <label>Họ và tên:</label>
                <input type="text" name="fullName" required placeholder="Nhập họ và tên">

                <label>Email:</label>
                <input type="email" name="email" required placeholder="Ví dụ: abc@gmail.com">

                <label>Số điện thoại:</label>
                <input type="text" name="phone" required placeholder="Nhập số điện thoại">
                
                <label>Mật khẩu:</label>
                <input type="password" name="password" required>

                <label>Xác nhận mật khẩu:</label>
                <input type="password" name="confirmPassword" required>
                
                <button type="submit">Đăng Ký</button>
            </form>
            
            <a href="login" class="link">Đã có tài khoản? Đăng nhập ngay</a>
        </div>
    </body>
</html>