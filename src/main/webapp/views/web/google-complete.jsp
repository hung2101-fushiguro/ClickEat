<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/responsive-global.css">
        <title>Hoàn tất hồ sơ - Click Eat</title>
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <link rel="shortcut icon" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">

        <style>
            *{
                box-sizing:border-box;
            }
            body{
                margin:0;
                min-height:100vh;
                display:flex;
                align-items:center;
                justify-content:center;
                background:#f3f4f6;
                font-family:Inter,sans-serif;
                padding:22px;
            }
            .card{
                width:min(1280px,100%);
                min-height:720px;
                background:#fff;
                border-radius:22px;
                overflow:hidden;
                display:grid;
                grid-template-columns:1fr 1.05fr;
                box-shadow:0 22px 60px rgba(0,0,0,.12);
            }
            .hero{
                position:relative;
                padding:26px 28px;
                background:
                    linear-gradient(90deg, rgba(0,0,0,.70) 0%, rgba(0,0,0,.30) 55%, rgba(0,0,0,.10) 100%),
                    url("https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?auto=format&fit=crop&w=1400&q=80");
                background-size:cover;
                background-position:center;
                color:#fff;
                display:flex;
                flex-direction:column;
                justify-content:flex-start;
            }
            .brand{
                display:flex;
                align-items:center;
                gap:10px;
                font-weight:700;
            }
            .logo{
                width:42px;
                height:42px;
                border-radius:12px;
                background:#ff7a1a;
                display:grid;
                place-items:center;
                box-shadow:0 10px 24px rgba(255,122,26,.35);
            }
            .logo:before{
                content:"";
                width:16px;
                height:16px;
                background:#fff;
                border-radius:4px;
                display:block;
                clip-path: polygon(0 20%, 70% 20%, 70% 0, 100% 0, 100% 100%, 0 100%);
            }
            .hero h1{
                margin:34px 0 12px;
                font-size:58px;
                line-height:1.02;
                font-weight:800;
                max-width:420px;
            }
            .hero p{
                max-width:470px;
                opacity:.94;
                line-height:1.65;
                font-size:15px;
            }
            .formWrap{
                padding:30px 34px;
                background:#fff;
                display:flex;
                flex-direction:column;
                justify-content:center;
            }
            .title{
                margin:0 0 8px;
                font-size:30px;
                font-weight:800;
                color:#111827;
            }
            .subtitle{
                margin:0 0 20px;
                color:#6b7280;
                line-height:1.55;
                max-width:620px;
            }
            .alert{
                border-radius:12px;
                padding:12px 14px;
                border:1px solid;
                margin-bottom:14px;
                font-size:14px;
            }
            .alert.error{
                background:#fff1f2;
                border-color:#fecdd3;
                color:#9f1239;
            }
            form{
                width:100%;
            }
            .formGrid{
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:14px 14px;
                width:100%;
            }
            .field{
                min-width:0;
            }
            .field.full{
                grid-column:1 / -1;
            }
            label{
                display:block;
                margin:0 0 8px;
                font-weight:700;
                color:#374151;
                font-size:13px;
            }
            input, textarea{
                width:100%;
                max-width:100%;
                border:1px solid #d1d5db;
                border-radius:14px;
                padding:12px 14px;
                font-size:15px;
                outline:none;
                background:#fff;
                transition:.18s ease;
                font-family:inherit;
            }
            textarea{
                min-height:82px;
                max-height:120px;
                resize:vertical;
            }
            input:focus, textarea:focus{
                border-color:rgba(255,122,26,.65);
                box-shadow:0 0 0 4px rgba(255,122,26,.16);
            }
            input[readonly]{
                background:#f3f4f6;
                color:#374151;
                cursor:not-allowed;
            }
            .field-error{
                display:block;
                color:#dc2626;
                font-size:12px;
                margin-top:6px;
                min-height:16px;
                line-height:1.4;
            }
            .hint{
                color:#6b7280;
                font-size:12px;
                margin-top:6px;
                line-height:1.45;
                min-height:18px;
            }
            .btn{
                margin-top:16px;
                width:100%;
                height:52px;
                border:none;
                border-radius:14px;
                background:#ff7a1a;
                color:#fff;
                font-weight:800;
                font-size:16px;
                cursor:pointer;
                box-shadow:0 14px 30px rgba(255,122,26,.32);
                transition:.2s ease;
            }
            .btn:hover{
                background:#f26c00;
            }

            @media (max-width:1100px){
                .card{
                    grid-template-columns:1fr;
                    width:min(860px,100%);
                }
                .hero{
                    min-height:300px;
                }
                .hero h1{
                    font-size:46px;
                    max-width:none;
                }
                .formWrap{
                    padding:26px 22px;
                }
            }

            @media (max-width:680px){
                .formGrid{
                    grid-template-columns:1fr;
                }
                .hero h1{
                    font-size:38px;
                }
            }
        </style>
    </head>
    <body>

        <div class="card">
            <section class="hero">
                <div class="brand"><div class="logo"></div> Click Eat</div>
                <h1>Hoàn tất hồ sơ</h1>
                <p>Chỉ cần thêm một vài thông tin để Click Eat gợi ý món ăn phù hợp và giao hàng chính xác.</p>
            </section>

            <section class="formWrap">
                <h2 class="title">Thông tin bổ sung</h2>
                <p class="subtitle">Google đã xác thực email. Bạn vui lòng nhập thêm thông tin còn thiếu để hoàn tất tài khoản.</p>

                <c:if test="${not empty error}">
                    <div class="alert error">${error}</div>
                </c:if>

                <form id="completeProfileForm" action="${pageContext.request.contextPath}/google-complete" method="post" novalidate>
                    <div class="formGrid">

                        <div class="field">
                            <label for="email">Email (từ Google)</label>
                            <input id="email" type="text" value="${sessionScope.GOOGLE_EMAIL}" readonly>
                        </div>

                        <div class="field">
                            <label for="full_name">Họ và tên</label>
                            <input id="full_name" type="text" name="full_name" value="${sessionScope.GOOGLE_NAME}" required maxlength="100"
                                   placeholder="Nhập họ và tên đầy đủ">
                            <span class="field-error" id="full_name_error"></span>
                        </div>

                        <div class="field">
                            <label for="phone">Số điện thoại</label>
                            <input id="phone" type="tel" name="phone" placeholder="VD: 0901234567" required maxlength="10"
                                   pattern="^(0[3|5|7|8|9])[0-9]{8}$">
                            <span class="field-error" id="phone_error"></span>
                        </div>

                        <div class="field">
                            <label for="daily_calorie_target">Calo mục tiêu/ngày (tuỳ chọn)</label>
                            <input id="daily_calorie_target" type="number" name="daily_calorie_target"
                                   placeholder="VD: 1800" min="800" max="6000" step="1">
                            <span class="field-error" id="daily_calorie_target_error"></span>
                        </div>

                        <div class="field">
                            <label for="password">Mật khẩu đăng nhập</label>
                            <input id="password" type="password" name="password" required minlength="8" maxlength="50"
                                   placeholder="Tối thiểu 8 ký tự">
                            <div class="hint">Nên có chữ hoa, chữ thường và số để an toàn hơn.</div>
                            <span class="field-error" id="password_error"></span>
                        </div>

                        <div class="field">
                            <label for="confirm_password">Xác nhận mật khẩu</label>
                            <input id="confirm_password" type="password" name="confirm_password" required minlength="8" maxlength="50"
                                   placeholder="Nhập lại mật khẩu">
                            <div class="hint">&nbsp;</div>
                            <span class="field-error" id="confirm_password_error"></span>
                        </div>

                        <div class="field full">
                            <label for="health_goal">Mục tiêu sức khoẻ (tuỳ chọn)</label>
                            <input id="health_goal" type="text" name="health_goal" maxlength="100"
                                   placeholder="VD: Giảm cân / Eat clean / Tăng cơ">
                            <span class="field-error" id="health_goal_error"></span>
                        </div>

                        <div class="field">
                            <label for="food_preferences">Sở thích món ăn (tuỳ chọn)</label>
                            <textarea id="food_preferences" name="food_preferences" maxlength="500"
                                      placeholder="VD: Thích cay, thích đồ nướng, ít dầu mỡ..."></textarea>
                            <span class="field-error" id="food_preferences_error"></span>
                        </div>

                        <div class="field">
                            <label for="allergies">Dị ứng (tuỳ chọn)</label>
                            <textarea id="allergies" name="allergies" maxlength="300"
                                      placeholder="VD: Dị ứng tôm, đậu phộng..."></textarea>
                            <span class="field-error" id="allergies_error"></span>
                        </div>
                    </div>

                    <button class="btn" type="submit">Hoàn tất</button>
                </form>
            </section>
        </div>

        <script>
            const form = document.getElementById('completeProfileForm');

            const fullName = document.getElementById('full_name');
            const phone = document.getElementById('phone');
            const password = document.getElementById('password');
            const confirmPassword = document.getElementById('confirm_password');
            const calorie = document.getElementById('daily_calorie_target');
            const healthGoal = document.getElementById('health_goal');
            const foodPreferences = document.getElementById('food_preferences');
            const allergies = document.getElementById('allergies');

            function setError(id, message) {
                document.getElementById(id).textContent = message || '';
            }

            function clearAllErrors() {
                setError('full_name_error', '');
                setError('phone_error', '');
                setError('password_error', '');
                setError('confirm_password_error', '');
                setError('health_goal_error', '');
                setError('daily_calorie_target_error', '');
                setError('food_preferences_error', '');
                setError('allergies_error', '');
            }

            function validateFullName() {
                const value = fullName.value.trim();
                if (value.length < 2) {
                    setError('full_name_error', 'Họ và tên phải có ít nhất 2 ký tự.');
                    return false;
                }
                if (!/^[\p{L}\s'.-]+$/u.test(value)) {
                    setError('full_name_error', 'Họ và tên không được chứa ký tự không hợp lệ.');
                    return false;
                }
                setError('full_name_error', '');
                return true;
            }

            function validatePhone() {
                const value = phone.value.trim();
                if (!/^(0[3|5|7|8|9])[0-9]{8}$/.test(value)) {
                    setError('phone_error', 'Số điện thoại phải đúng định dạng Việt Nam, ví dụ 0901234567.');
                    return false;
                }
                setError('phone_error', '');
                return true;
            }

            function validatePassword() {
                const value = password.value;
                if (value.length < 8) {
                    setError('password_error', 'Mật khẩu phải có ít nhất 8 ký tự.');
                    return false;
                }
                if (!/(?=.*[a-z])(?=.*[A-Z])(?=.*\d)/.test(value)) {
                    setError('password_error', 'Mật khẩu cần có chữ hoa, chữ thường và số.');
                    return false;
                }
                setError('password_error', '');
                return true;
            }

            function validateConfirmPassword() {
                if (confirmPassword.value !== password.value) {
                    setError('confirm_password_error', 'Mật khẩu xác nhận không khớp.');
                    return false;
                }
                setError('confirm_password_error', '');
                return true;
            }

            function validateCalorie() {
                const value = calorie.value.trim();
                if (value === '') {
                    setError('daily_calorie_target_error', '');
                    return true;
                }
                const num = Number(value);
                if (!Number.isInteger(num) || num < 800 || num > 6000) {
                    setError('daily_calorie_target_error', 'Calo mục tiêu nên nằm trong khoảng 800 đến 6000.');
                    return false;
                }
                setError('daily_calorie_target_error', '');
                return true;
            }

            function validateOptionalLength(field, errorId, max, label) {
                const value = field.value.trim();
                if (value.length > max) {
                    setError(errorId, label + ' không được vượt quá ' + max + ' ký tự.');
                    return false;
                }
                setError(errorId, '');
                return true;
            }

            fullName.addEventListener('blur', validateFullName);
            phone.addEventListener('blur', validatePhone);
            password.addEventListener('blur', validatePassword);
            confirmPassword.addEventListener('blur', validateConfirmPassword);
            calorie.addEventListener('blur', validateCalorie);

            healthGoal.addEventListener('blur', function () {
                validateOptionalLength(healthGoal, 'health_goal_error', 100, 'Mục tiêu sức khoẻ');
            });

            foodPreferences.addEventListener('blur', function () {
                validateOptionalLength(foodPreferences, 'food_preferences_error', 500, 'Sở thích món ăn');
            });

            allergies.addEventListener('blur', function () {
                validateOptionalLength(allergies, 'allergies_error', 300, 'Dị ứng');
            });

            form.addEventListener('submit', function (e) {
                clearAllErrors();

                let isValid = true;

                if (!validateFullName())
                    isValid = false;
                if (!validatePhone())
                    isValid = false;
                if (!validatePassword())
                    isValid = false;
                if (!validateConfirmPassword())
                    isValid = false;
                if (!validateCalorie())
                    isValid = false;
                if (!validateOptionalLength(healthGoal, 'health_goal_error', 100, 'Mục tiêu sức khoẻ'))
                    isValid = false;
                if (!validateOptionalLength(foodPreferences, 'food_preferences_error', 500, 'Sở thích món ăn'))
                    isValid = false;
                if (!validateOptionalLength(allergies, 'allergies_error', 300, 'Dị ứng'))
                    isValid = false;

                if (!isValid) {
                    e.preventDefault();
                }
            });
        </script>
    </body>
</html>