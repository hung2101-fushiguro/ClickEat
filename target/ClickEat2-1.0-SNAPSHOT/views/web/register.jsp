<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Đăng ký - ClickEat</title>
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <link rel="shortcut icon" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">

        <style>
            :root{
                --bg:#f3f4f6;
                --card:#ffffff;
                --text:#111827;
                --muted:#6b7280;
                --line:#e5e7eb;
                --primary:#ff7a1a;
                --primary-hover:#ff6a00;
                --shadow:0 22px 60px rgba(0,0,0,.08);
                --radius:22px;
                --danger:#dc2626;
            }

            *{
                box-sizing:border-box
            }

            body{
                margin:0;
                font-family:Inter,system-ui,-apple-system,Segoe UI,Roboto,Arial,sans-serif;
                background:var(--bg);
                color:var(--text);
            }

            .topbar{
                height:72px;
                background:#fff;
                border-bottom:1px solid #eee;
                display:flex;
                align-items:center;
                justify-content:center;
            }

            .topbar-inner{
                width:min(1200px, 100%);
                padding:0 24px;
                display:flex;
                align-items:center;
                justify-content:space-between;
            }

            .brand{
                display:flex;
                align-items:center;
                gap:12px;
                text-decoration:none;
                color:#111827;
                font-weight:800;
                font-size:20px;
                line-height:1;
            }

            .brand-logo{
                width:34px;
                height:34px;
                border-radius:10px;
                background:var(--primary);
                display:flex;
                align-items:center;
                justify-content:center;
                flex:0 0 34px;
            }

            .brand-logo::before{
                content:"";
                width:14px;
                height:14px;
                background:#fff;
                border-radius:3px;
                display:block;
                clip-path: polygon(0 20%, 70% 20%, 70% 0, 100% 0, 100% 100%, 0 100%);
            }

            .topbar-link{
                color:var(--primary);
                text-decoration:none;
                font-weight:700;
                display:flex;
                align-items:center;
                height:100%;
            }

            .page{
                width:min(1100px, 100%);
                margin:32px auto 72px;
                padding:0 20px;
            }

            .back-link{
                display:inline-flex;
                align-items:center;
                gap:8px;
                margin-bottom:20px;
                text-decoration:none;
                color:#374151;
                font-weight:700;
            }

            .card{
                background:var(--card);
                border-radius:var(--radius);
                box-shadow:var(--shadow);
                overflow:hidden;
                border:1px solid #f1f1f1;
            }

            .card-head{
                padding:28px 28px 16px;
                border-bottom:1px solid #f1f1f1;
            }

            .title{
                margin:0 0 8px;
                font-size:22px;
                font-weight:800;
            }

            .subtitle{
                margin:0;
                color:var(--muted);
                font-size:15px;
            }

            .form-body{
                padding:28px;
            }

            .section{
                margin-bottom:32px;
            }

            .section-title{
                font-size:15px;
                font-weight:800;
                margin:0 0 18px;
                display:flex;
                align-items:center;
                gap:10px;
            }

            .section-title::before{
                content:"";
                width:4px;
                height:18px;
                border-radius:999px;
                background:var(--primary);
                display:block;
            }

            .grid-2{
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:18px;
            }

            .grid-3{
                display:grid;
                grid-template-columns:1fr 1fr 1fr;
                gap:18px;
            }

            .field{
                margin-bottom:16px;
            }

            label{
                display:block;
                font-size:14px;
                font-weight:700;
                margin-bottom:8px;
                color:#374151;
            }

            input,
            select{
                width:100%;
                height:54px;
                border:1px solid var(--line);
                border-radius:999px;
                outline:none;
                background:#fff;
                transition:.15s ease;
                padding:0 22px;
                font-size:15px;
                color:var(--text);
            }

            textarea{
                width:100%;
                min-height:124px;
                border:1px solid var(--line);
                border-radius:24px;
                padding:20px 22px;
                font-size:15px;
                line-height:1.7;
                outline:none;
                background:#fff;
                transition:.15s ease;
                color:var(--text);
                resize:none;
                overflow:auto;
                display:block;
            }

            input::placeholder,
            textarea::placeholder{
                color:#9ca3af;
                opacity:1;
            }

            select{
                appearance:none;
                -webkit-appearance:none;
                -moz-appearance:none;
                padding-left:22px;
                padding-right:42px;
                background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='18' height='18' viewBox='0 0 24 24' fill='none' stroke='%239ca3af' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='m6 9 6 6 6-6'/%3E%3C/svg%3E");
                background-repeat:no-repeat;
                background-position:right 16px center;
                background-size:18px;
            }

            input:focus,
            textarea:focus,
            select:focus{
                border-color:rgba(255,122,26,.65);
                box-shadow:0 0 0 4px rgba(255,122,26,.14);
                padding: 10px;
            }

            .password-wrap input{
                padding:0 48px 0 22px;
            }

            input.error-input,
            textarea.error-input,
            select.error-input{
                border-color:#fca5a5;
                box-shadow:0 0 0 4px rgba(220,38,38,.10);
            }

            .hint{
                margin-top:6px;
                font-size:12px;
                color:#9ca3af;
            }

            .field-error{
                min-height:18px;
                margin-top:6px;
                font-size:12px;
                color:var(--danger);
                font-weight:600;
            }

            .alert{
                border-radius:14px;
                padding:12px 14px;
                font-size:14px;
                margin-bottom:18px;
                border:1px solid;
            }

            .alert.error{
                background:#fff1f2;
                border-color:#fecdd3;
                color:#9f1239;
            }

            .check-line{
                display:flex;
                align-items:flex-start;
                gap:10px;
                margin:10px 0;
                color:#6b7280;
                font-size:14px;
            }

            .check-line input{
                width:18px;
                height:18px;
                margin-top:1px;
                accent-color:var(--primary);
            }

            .submit-btn{
                width:100%;
                height:52px;
                border:none;
                border-radius:999px;
                background:var(--primary);
                color:#fff;
                font-size:18px;
                font-weight:800;
                cursor:pointer;
                box-shadow:0 14px 30px rgba(255,122,26,.28);
                transition:.15s ease;
            }

            .submit-btn:hover{
                background:var(--primary-hover);
                transform:translateY(-1px);
            }

            .divider{
                display:flex;
                align-items:center;
                gap:12px;
                margin:20px 0 18px;
                color:#9ca3af;
                font-size:13px;
                font-weight:700;
            }

            .divider::before, .divider::after{
                content:"";
                flex:1;
                height:1px;
                background:#e5e7eb;
            }

            .google-btn{
                width:100%;
                height:52px;
                border:1px solid var(--line);
                border-radius:999px;
                background:#fff;
                color:#111827;
                font-size:16px;
                font-weight:800;
                cursor:pointer;
                display:flex;
                align-items:center;
                justify-content:center;
                gap:10px;
                transition:.15s ease;
                box-shadow:0 8px 20px rgba(0,0,0,.04);
            }

            .google-btn:hover{
                background:#fafafa;
                border-color:#d1d5db;
                transform:translateY(-1px);
            }

            .googleIcon{
                width:18px;
                height:18px;
                flex:0 0 auto;
            }

            .bottom-link{
                margin-top:18px;
                text-align:center;
                color:#6b7280;
                font-size:14px;
            }

            .bottom-link a{
                color:var(--primary);
                text-decoration:none;
                font-weight:800;
            }

            input[type="number"]::-webkit-outer-spin-button,
            input[type="number"]::-webkit-inner-spin-button{
                -webkit-appearance:none;
                margin:0;
            }

            input[type="number"]{
                -moz-appearance:textfield;
            }

            .password-wrap{
                position:relative;
            }

            .password-wrap input{
                padding-right:48px;
            }

            .password-toggle{
                position:absolute;
                right:12px;
                top:50%;
                transform:translateY(-50%);
                width:30px;
                height:30px;
                border:none;
                background:transparent;
                color:#9ca3af;
                cursor:pointer;
                display:flex;
                align-items:center;
                justify-content:center;
            }

            .password-toggle:hover{
                color:#6b7280;
            }

            @media (max-width: 900px){
                .grid-2, .grid-3{
                    grid-template-columns:1fr;
                }
                .form-body, .card-head{
                    padding:20px;
                }
            }
        </style>
    </head>
    <body>

        <div class="topbar">
            <div class="topbar-inner">
                <a href="${pageContext.request.contextPath}/home" class="brand">
                    <div class="brand-logo"></div>
                    <span>ClickEat</span>
                </a>
                <a href="${pageContext.request.contextPath}/about" class="topbar-link">Về chúng tôi</a>
            </div>
        </div>

        <div class="page">
            <a href="${pageContext.request.contextPath}/home" class="back-link">← Quay lại trang chủ</a>

            <div class="card">
                <div class="card-head">
                    <h1 class="title">Đăng ký tài khoản</h1>
                    <p class="subtitle">Tạo tài khoản để đặt món nhanh hơn và nhận ưu đãi.</p>
                </div>

                <div class="form-body">
                    <c:if test="${not empty error}">
                        <div class="alert error">❌ ${error}</div>
                    </c:if>

                    <form id="registerForm" action="${pageContext.request.contextPath}/register" method="post" accept-charset="UTF-8" novalidate>
                        <input type="hidden" name="provinceNameText" id="provinceNameText">
                        <input type="hidden" name="districtNameText" id="districtNameText">
                        <input type="hidden" name="wardNameText" id="wardNameText">

                        <div class="section">
                            <h2 class="section-title">Thông tin cá nhân</h2>

                            <div class="grid-2">
                                <div class="field">
                                    <label for="fullName">Họ và tên</label>
                                    <input type="text" id="fullName" name="fullName" value="${param.fullName}" required placeholder="Nhập họ và tên">
                                    <div class="field-error" id="fullNameError"></div>
                                </div>

                                <div class="field">
                                    <label for="phone">Số điện thoại</label>
                                    <input type="text" id="phone" name="phone" value="${param.phone}" required placeholder="Nhập số điện thoại">
                                    <div class="field-error" id="phoneError"></div>
                                </div>
                            </div>

                            <div class="grid-2">
                                <div class="field">
                                    <label for="email">E-mail</label>
                                    <input type="email" id="email" name="email" value="${param.email}" placeholder="example@email.com">
                                    <div class="hint">Email có thể để trống, nhưng nếu nhập thì phải là duy nhất.</div>
                                    <div class="field-error" id="emailError"></div>
                                </div>

                                <div class="field">
                                    <label for="dailyCalorieTarget">Calo mục tiêu/ngày</label>
                                    <input type="number" id="dailyCalorieTarget" name="dailyCalorieTarget" value="${param.dailyCalorieTarget}" placeholder="Ví dụ: 1800">
                                    <div class="field-error" id="dailyCalorieTargetError"></div>
                                </div>
                            </div>

                            <div class="field">
                                <label for="foodPreferences">Thói quen ăn uống</label>
                                <textarea id="foodPreferences" name="foodPreferences" placeholder="Ví dụ: Ăn chay, thích cay, không ăn hành...">${param.foodPreferences}</textarea>
                                <div class="field-error" id="foodPreferencesError"></div>
                            </div>

                            <div class="grid-2">
                                <div class="field">
                                    <label for="allergies">Dị ứng thực phẩm</label>
                                    <textarea id="allergies" name="allergies" placeholder="Ví dụ: Dị ứng tôm, đậu phộng...">${param.allergies}</textarea>
                                    <div class="field-error" id="allergiesError"></div>
                                </div>

                                <div class="field">
                                    <label for="healthGoal">Mục tiêu sức khỏe</label>
                                    <textarea id="healthGoal" name="healthGoal" placeholder="Ví dụ: Eat clean, giảm cân, tăng cơ...">${param.healthGoal}</textarea>
                                    <div class="field-error" id="healthGoalError"></div>
                                </div>
                            </div>
                        </div>

                        <div class="section">
                            <h2 class="section-title">Địa chỉ giao hàng mặc định (tùy chọn)</h2>

                            <div class="grid-3">
                                <div class="field">
                                    <label for="provinceName">Tỉnh/Thành</label>
                                    <select id="provinceName" name="provinceName">
                                        <option value="">Chọn tỉnh/thành</option>
                                    </select>
                                    <div class="field-error" id="provinceNameError"></div>
                                </div>

                                <div class="field">
                                    <label for="districtName">Quận/Huyện</label>
                                    <select id="districtName" name="districtName" disabled>
                                        <option value="">Chọn quận/huyện</option>
                                    </select>
                                    <div class="field-error" id="districtNameError"></div>
                                </div>

                                <div class="field">
                                    <label for="wardName">Phường/Xã</label>
                                    <select id="wardName" name="wardName" disabled>
                                        <option value="">Chọn phường/xã</option>
                                    </select>
                                    <div class="field-error" id="wardNameError"></div>
                                </div>
                            </div>

                            <div class="field">
                                <label for="addressLine">Địa chỉ chi tiết</label>
                                <input type="text" id="addressLine" name="addressLine" value="${param.addressLine}" placeholder="Số nhà, tên đường...">
                                <div class="field-error" id="addressLineError"></div>
                            </div>

                            <div class="grid-2">
                                <div class="field">
                                    <label for="receiverName">Tên người nhận</label>
                                    <input type="text" id="receiverName" name="receiverName" value="${param.receiverName}" placeholder="Nhập tên người nhận">
                                    <div class="field-error" id="receiverNameError"></div>
                                </div>

                                <div class="field">
                                    <label for="receiverPhone">SĐT người nhận</label>
                                    <input type="text" id="receiverPhone" name="receiverPhone" value="${param.receiverPhone}" placeholder="Nhập số điện thoại người nhận">
                                    <div class="field-error" id="receiverPhoneError"></div>
                                </div>
                            </div>

                            <div class="hint">
                                Nếu bạn chưa muốn lưu địa chỉ ngay, có thể để trống toàn bộ phần này.
                            </div>
                        </div>

                        <div class="section">
                            <h2 class="section-title">Bảo mật</h2>

                            <div class="grid-2">
                                <div class="field">
                                    <label for="password">Mật khẩu</label>
                                    <div class="password-wrap">
                                        <input type="password" id="password" name="password" required placeholder="Nhập mật khẩu">
                                        <button type="button" class="password-toggle" onclick="togglePassword('password', this)" aria-label="Hiện hoặc ẩn mật khẩu">
                                            <i class="fa-regular fa-eye"></i>
                                        </button>
                                    </div>
                                    <div class="field-error" id="passwordError"></div>
                                </div>

                                <div class="field">
                                    <label for="confirmPassword">Nhập lại mật khẩu</label>
                                    <div class="password-wrap">
                                        <input type="password" id="confirmPassword" name="confirmPassword" required placeholder="Nhập lại mật khẩu">
                                        <button type="button" class="password-toggle" onclick="togglePassword('confirmPassword', this)" aria-label="Hiện hoặc ẩn mật khẩu">
                                            <i class="fa-regular fa-eye"></i>
                                        </button>
                                    </div>
                                    <div class="field-error" id="confirmPasswordError"></div>
                                </div>
                            </div>

                            <label class="check-line">
                                <input type="checkbox" id="agreeTerms" name="agreeTerms" value="1" required>
                                <span>Tôi đồng ý với <b>Điều khoản sử dụng</b> và <b>Chính sách bảo mật</b> của ClickEat.</span>
                            </label>
                            <div class="field-error" id="agreeTermsError"></div>
                        </div>

                        <button type="submit" class="submit-btn">Đăng ký</button>

                        <div class="divider">Hoặc</div>

                        <button class="google-btn" type="button"
                                onclick="location.href = '${pageContext.request.contextPath}/google-login'">
                            <svg class="googleIcon" viewBox="0 0 48 48" aria-hidden="true">
                            <path fill="#FFC107" d="M43.6 20.5H42V20H24v8h11.3C33.7 32.7 29.3 36 24 36c-6.6 0-12-5.4-12-12s5.4-12 12-12c3.1 0 5.9 1.2 8 3.1l5.7-5.7C34.2 6.1 29.3 4 24 4 12.9 4 4 12.9 4 24s8.9 20 20 20 20-8.9 20-20c0-1.1-.1-2.3-.4-3.5z"/>
                            <path fill="#FF3D00" d="M6.3 14.7l6.6 4.8C14.7 15.5 19 12 24 12c3.1 0 5.9 1.2 8 3.1l5.7-5.7C34.2 6.1 29.3 4 24 4 16.3 4 9.6 8.3 6.3 14.7z"/>
                            <path fill="#4CAF50" d="M24 44c5.2 0 10-2 13.6-5.2l-6.3-5.1C29.2 35.6 26.7 36 24 36c-5.3 0-9.7-3.4-11.3-8.1l-6.5 5C9.4 39.6 16.2 44 24 44z"/>
                            <path fill="#1976D2" d="M43.6 20.5H42V20H24v8h11.3c-.8 2.3-2.4 4.2-4.6 5.7l.1-.1 6.3 5.1C36.8 39 44 34 44 24c0-1.1-.1-2.3-.4-3.5z"/>
                            </svg>
                            <span>Tiếp tục với Google</span>
                        </button>

                        <div class="bottom-link">
                            Đã có tài khoản? <a href="${pageContext.request.contextPath}/login">Đăng nhập</a>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <jsp:include page="footer.jsp" />

        <script>
            const provinceSelect = document.getElementById('provinceName');
            const districtSelect = document.getElementById('districtName');
            const wardSelect = document.getElementById('wardName');

            const provinceNameTextInput = document.getElementById('provinceNameText');
            const districtNameTextInput = document.getElementById('districtNameText');
            const wardNameTextInput = document.getElementById('wardNameText');

            let provincesData = [];
            const provinceMap = new Map();
            let provincesDepth3Data = null;

            function togglePassword(inputId, btn) {
                const input = document.getElementById(inputId);
                const icon = btn.querySelector('i');
                if (!input || !icon)
                    return;

                if (input.type === 'password') {
                    input.type = 'text';
                    icon.className = 'fa-regular fa-eye-slash';
                } else {
                    input.type = 'password';
                    icon.className = 'fa-regular fa-eye';
                }
            }

            function updateAddressTextFields() {
                if (provinceSelect && provinceNameTextInput) {
                    provinceNameTextInput.value =
                            provinceSelect.selectedIndex > 0
                            ? provinceSelect.options[provinceSelect.selectedIndex].text
                            : '';
                }

                if (districtSelect && districtNameTextInput) {
                    districtNameTextInput.value =
                            districtSelect.selectedIndex > 0
                            ? districtSelect.options[districtSelect.selectedIndex].text
                            : '';
                }

                if (wardSelect && wardNameTextInput) {
                    wardNameTextInput.value =
                            wardSelect.selectedIndex > 0
                            ? wardSelect.options[wardSelect.selectedIndex].text
                            : '';
                }
            }

            async function fetchJson(url) {
                const res = await fetch(url, {
                    method: 'GET',
                    headers: {
                        'Accept': 'application/json'
                    }
                });

                if (!res.ok) {
                    throw new Error('Không tải được dữ liệu từ: ' + url + ' | status=' + res.status);
                }

                return await res.json();
            }

            function resetSelect(selectEl, placeholder, disabled = true) {
                selectEl.innerHTML = `<option value="">${placeholder}</option>`;
                selectEl.disabled = disabled;
            }

            function fillSelect(selectEl, items, placeholder) {
                selectEl.innerHTML = `<option value="">${placeholder}</option>`;

                if (!Array.isArray(items) || items.length === 0) {
                    selectEl.disabled = true;
                    return;
                }

                items.forEach(item => {
                    const option = document.createElement('option');
                    option.value = String(item.code ?? '');
                    option.textContent = item.name ?? '';
                    option.dataset.name = item.name ?? '';
                    selectEl.appendChild(option);
                });

                selectEl.disabled = false;
            }

            function setError(inputId, message) {
                const input = document.getElementById(inputId);
                const error = document.getElementById(inputId + 'Error');
                if (!error)
                    return false;

                error.textContent = message || '';
                if (input) {
                    input.classList.toggle('error-input', !!message);
                }
                return !message;
            }

            function clearAddressErrors() {
                setError('provinceName', '');
                setError('districtName', '');
                setError('wardName', '');
            }

            async function loadProvinces() {
                try {
                    resetSelect(provinceSelect, 'Đang tải tỉnh/thành...', true);
                    resetSelect(districtSelect, 'Chọn quận/huyện', true);
                    resetSelect(wardSelect, 'Chọn phường/xã', true);

                    provincesData = await fetchJson('https://provinces.open-api.vn/api/v1/?depth=2');

                    provinceMap.clear();
                    provincesData.forEach(province => {
                        provinceMap.set(String(province.code), province);
                    });

                    fillSelect(provinceSelect, provincesData, 'Chọn tỉnh/thành');
                    clearAddressErrors();
                    updateAddressTextFields();
                } catch (e) {
                    console.error('Lỗi load provinces:', e);
                    resetSelect(provinceSelect, 'Không tải được tỉnh/thành', true);
                    setError('provinceName', 'Không tải được danh sách tỉnh/thành.');
                }
            }

            function loadDistrictsFromLoadedProvince(provinceCode) {
                const province = provinceMap.get(String(provinceCode));

                resetSelect(districtSelect, 'Chọn quận/huyện', true);
                resetSelect(wardSelect, 'Chọn phường/xã', true);
                updateAddressTextFields();

                if (!province) {
                    setError('districtName', 'Không tìm thấy dữ liệu tỉnh/thành đã chọn.');
                    return;
                }

                if (Array.isArray(province.districts) && province.districts.length > 0) {
                    fillSelect(districtSelect, province.districts, 'Chọn quận/huyện');
                    setError('districtName', '');
                } else {
                    resetSelect(districtSelect, 'Không có quận/huyện', true);
                    setError('districtName', 'Tỉnh/thành này không có dữ liệu quận/huyện.');
                }
            }

            async function findDistrictWithWardsFromProvince(provinceCode, districtCode) {
                if (!provincesDepth3Data) {
                    provincesDepth3Data = await fetchJson('https://provinces.open-api.vn/api/v1/?depth=3');
                }

                if (!Array.isArray(provincesDepth3Data)) {
                    return null;
                }

                const province = provincesDepth3Data.find(
                        p => String(p.code) === String(provinceCode)
                );

                if (!province || !Array.isArray(province.districts)) {
                    return null;
                }

                return province.districts.find(
                        d => String(d.code) === String(districtCode)
                ) || null;
            }

            async function loadWardsByDistrictCode(districtCode) {
                try {
                    resetSelect(wardSelect, 'Đang tải phường/xã...', true);
                    updateAddressTextFields();

                    const provinceCode = provinceSelect.value;
                    if (!provinceCode) {
                        resetSelect(wardSelect, 'Chọn phường/xã', true);
                        setError('wardName', 'Vui lòng chọn tỉnh/thành trước.');
                        return;
                    }

                    const districtDetail = await findDistrictWithWardsFromProvince(provinceCode, districtCode);

                    if (districtDetail && Array.isArray(districtDetail.wards) && districtDetail.wards.length > 0) {
                        fillSelect(wardSelect, districtDetail.wards, 'Chọn phường/xã');
                        setError('wardName', '');
                    } else {
                        resetSelect(wardSelect, 'Không có phường/xã', true);
                        setError('wardName', 'Quận/huyện này không có dữ liệu phường/xã.');
                    }
                } catch (e) {
                    console.error('Lỗi load wards:', e);
                    resetSelect(wardSelect, 'Không tải được phường/xã', true);
                    setError('wardName', 'Không tải được phường/xã.');
                }
            }

            provinceSelect.addEventListener('change', function () {
                const provinceCode = this.value;

                resetSelect(districtSelect, 'Chọn quận/huyện', true);
                resetSelect(wardSelect, 'Chọn phường/xã', true);
                setError('provinceName', '');
                setError('districtName', '');
                setError('wardName', '');
                updateAddressTextFields();

                if (!provinceCode)
                    return;

                loadDistrictsFromLoadedProvince(provinceCode);
            });

            districtSelect.addEventListener('change', async function () {
                const districtCode = this.value;

                resetSelect(wardSelect, 'Chọn phường/xã', true);
                setError('districtName', '');
                setError('wardName', '');
                updateAddressTextFields();

                if (!districtCode)
                    return;

                await loadWardsByDistrictCode(districtCode);
            });

            wardSelect.addEventListener('change', function () {
                setError('wardName', '');
                updateAddressTextFields();
            });

            function validateFullName() {
                const value = document.getElementById('fullName').value.trim();
                if (value.length < 2)
                    return setError('fullName', 'Họ tên phải có ít nhất 2 ký tự.');
                if (value.length > 60)
                    return setError('fullName', 'Họ tên không được vượt quá 60 ký tự.');
                if (!/^[A-Za-zÀ-ỹ\s]+$/.test(value))
                    return setError('fullName', 'Họ tên chỉ được chứa chữ cái và khoảng trắng.');
                return setError('fullName', '');
            }

            function validatePhone() {
                const value = document.getElementById('phone').value.trim();
                if (!/^[0-9]{8,11}$/.test(value))
                    return setError('phone', 'Số điện thoại chỉ được chứa 8-11 chữ số.');
                return setError('phone', '');
            }

            function validateEmail() {
                const value = document.getElementById('email').value.trim();
                if (value === '')
                    return setError('email', '');
                if (value.length > 100)
                    return setError('email', 'Email không được vượt quá 100 ký tự.');
                if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value))
                    return setError('email', 'Email không đúng định dạng.');
                return setError('email', '');
            }

            function validateDailyCalorieTarget() {
                const value = document.getElementById('dailyCalorieTarget').value.trim();
                if (value === '')
                    return setError('dailyCalorieTarget', '');
                const num = Number(value);
                if (!Number.isInteger(num) || num < 500 || num > 10000) {
                    return setError('dailyCalorieTarget', 'Calo mục tiêu nên nằm trong khoảng 500 - 10000.');
                }
                return setError('dailyCalorieTarget', '');
            }

            function validateReceiverName() {
                const value = document.getElementById('receiverName').value.trim();
                if (value === '')
                    return setError('receiverName', '');
                if (value.length < 2)
                    return setError('receiverName', 'Tên người nhận quá ngắn.');
                if (value.length > 60)
                    return setError('receiverName', 'Tên người nhận quá dài.');
                if (!/^[A-Za-zÀ-ỹ\s]+$/.test(value))
                    return setError('receiverName', 'Tên người nhận chỉ được chứa chữ cái và khoảng trắng.');
                return setError('receiverName', '');
            }

            function validateReceiverPhone() {
                const value = document.getElementById('receiverPhone').value.trim();
                if (value === '')
                    return setError('receiverPhone', '');
                if (!/^[0-9]{8,11}$/.test(value))
                    return setError('receiverPhone', 'SĐT người nhận chỉ được chứa 8-11 chữ số.');
                return setError('receiverPhone', '');
            }

            function validateTextAreaField(id, maxLen, label) {
                const value = document.getElementById(id).value.trim();
                if (value === '')
                    return setError(id, '');
                if (value.length > maxLen)
                    return setError(id, `${label} không được vượt quá ${maxLen} ký tự.`);
                if (!/^[A-Za-zÀ-ỹ0-9\s,.;:()\-/%]+$/.test(value)) {
                    return setError(id, `${label} chứa ký tự không hợp lệ.`);
                }
                return setError(id, '');
            }

            function validateAddressLine() {
                const value = document.getElementById('addressLine').value.trim();
                if (value === '')
                    return setError('addressLine', '');
                if (value.length < 5)
                    return setError('addressLine', 'Địa chỉ chi tiết quá ngắn.');
                if (value.length > 255)
                    return setError('addressLine', 'Địa chỉ chi tiết quá dài.');
                if (!/^[A-Za-zÀ-ỹ0-9\s,./\-]+$/.test(value)) {
                    return setError('addressLine', 'Địa chỉ chứa ký tự không hợp lệ.');
                }
                return setError('addressLine', '');
            }

            function validateProvinceDistrictWard() {
                const province = provinceSelect.value.trim();
                const district = districtSelect.value.trim();
                const ward = wardSelect.value.trim();
                const addressLine = document.getElementById('addressLine').value.trim();
                const receiverName = document.getElementById('receiverName').value.trim();
                const receiverPhone = document.getElementById('receiverPhone').value.trim();

                const hasAny = province || district || ward || addressLine || receiverName || receiverPhone;

                if (!hasAny) {
                    clearAddressErrors();
                    return true;
                }

                let ok = true;

                if (!province) {
                    setError('provinceName', 'Vui lòng chọn tỉnh/thành.');
                    ok = false;
                } else {
                    setError('provinceName', '');
                }

                if (!district) {
                    setError('districtName', 'Vui lòng chọn quận/huyện.');
                    ok = false;
                } else {
                    setError('districtName', '');
                }

                if (!ward) {
                    setError('wardName', 'Vui lòng chọn phường/xã.');
                    ok = false;
                } else {
                    setError('wardName', '');
                }

                return ok;
            }

            function validatePassword() {
                const value = document.getElementById('password').value;
                if (value.length < 8)
                    return setError('password', 'Mật khẩu phải có ít nhất 8 ký tự.');
                if (value.length > 50)
                    return setError('password', 'Mật khẩu không được vượt quá 50 ký tự.');
                if (!/[A-Z]/.test(value))
                    return setError('password', 'Mật khẩu phải có ít nhất 1 chữ in hoa.');
                if (!/[a-z]/.test(value))
                    return setError('password', 'Mật khẩu phải có ít nhất 1 chữ thường.');
                if (!/[0-9]/.test(value))
                    return setError('password', 'Mật khẩu phải có ít nhất 1 chữ số.');
                if (!/[!@#$%^&*(),.?":{}|<>_\-\\/\[\];'+=]/.test(value)) {
                    return setError('password', 'Mật khẩu phải có ít nhất 1 ký tự đặc biệt.');
                }
                return setError('password', '');
            }

            function validateConfirmPassword() {
                const password = document.getElementById('password').value;
                const confirm = document.getElementById('confirmPassword').value;
                if (confirm.length === 0)
                    return setError('confirmPassword', 'Vui lòng nhập lại mật khẩu.');
                if (password !== confirm)
                    return setError('confirmPassword', 'Mật khẩu xác nhận không khớp.');
                return setError('confirmPassword', '');
            }

            function validateAgreeTerms() {
                const checked = document.getElementById('agreeTerms').checked;
                const error = document.getElementById('agreeTermsError');
                error.textContent = checked ? '' : 'Bạn cần đồng ý điều khoản để tiếp tục.';
                return checked;
            }

            document.getElementById('fullName').addEventListener('input', validateFullName);
            document.getElementById('phone').addEventListener('input', validatePhone);
            document.getElementById('email').addEventListener('input', validateEmail);
            document.getElementById('dailyCalorieTarget').addEventListener('input', validateDailyCalorieTarget);

            document.getElementById('receiverName').addEventListener('input', validateReceiverName);
            document.getElementById('receiverPhone').addEventListener('input', validateReceiverPhone);
            document.getElementById('addressLine').addEventListener('input', validateAddressLine);

            document.getElementById('foodPreferences').addEventListener('input', function () {
                validateTextAreaField('foodPreferences', 300, 'Thói quen ăn uống');
            });

            document.getElementById('allergies').addEventListener('input', function () {
                validateTextAreaField('allergies', 200, 'Dị ứng thực phẩm');
            });

            document.getElementById('healthGoal').addEventListener('input', function () {
                validateTextAreaField('healthGoal', 200, 'Mục tiêu sức khỏe');
            });

            document.getElementById('password').addEventListener('input', function () {
                validatePassword();
                validateConfirmPassword();
            });

            document.getElementById('confirmPassword').addEventListener('input', validateConfirmPassword);
            document.getElementById('agreeTerms').addEventListener('change', validateAgreeTerms);

            document.getElementById('registerForm').addEventListener('submit', function (e) {
                updateAddressTextFields();

                const results = [
                    validateFullName(),
                    validatePhone(),
                    validateEmail(),
                    validateDailyCalorieTarget(),
                    validateReceiverName(),
                    validateReceiverPhone(),
                    validateAddressLine(),
                    validateProvinceDistrictWard(),
                    validateTextAreaField('foodPreferences', 300, 'Thói quen ăn uống'),
                    validateTextAreaField('allergies', 200, 'Dị ứng thực phẩm'),
                    validateTextAreaField('healthGoal', 200, 'Mục tiêu sức khỏe'),
                    validatePassword(),
                    validateConfirmPassword(),
                    validateAgreeTerms()
                ];

                if (results.includes(false)) {
                    e.preventDefault();
                }
            });

            loadProvinces();
        </script>
    </body>
</html>