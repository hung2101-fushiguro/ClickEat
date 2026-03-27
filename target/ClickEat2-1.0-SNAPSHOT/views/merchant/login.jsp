<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/responsive-global.css">
        <title>ClickEat – Đăng nhập</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <script src="https://accounts.google.com/gsi/client" async defer></script>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0&display=swap" rel="stylesheet"/>
        <script>
            tailwind.config = {
                theme: {
                    extend: {
                        fontFamily: {sans: ['Inter', 'sans-serif']},
                        colors: {primary: '#c86601', 'primary-dark': '#a05201'}
                    }
                }
            }
        </script>
    </head>
    <body class="min-h-screen font-sans flex">

        <!-- Left hero panel (hidden on mobile) -->
        <div class="hidden md:flex w-1/2 bg-[#c86601] relative overflow-hidden flex-col">
            <div class="absolute inset-0 bg-black/20"></div>
            <div class="absolute inset-0 bg-cover bg-center opacity-60"
            style="background-image:url('https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=1200&q=80'); mix-blend-mode:overlay"></div>
            <div class="relative z-10 flex flex-col justify-between p-12 text-white h-full">
                <!-- Brand -->
                <div class="flex items-center gap-3">
                    <div class="w-10 h-10 bg-white rounded-lg flex items-center justify-center text-[#c86601]">
                        <span class="material-symbols-outlined">restaurant</span>
                    </div>
                    <span class="text-2xl font-bold">ClickEat Merchant</span>
                </div>
                <!-- Tagline -->
                <div class="max-w-md">
                    <h1 class="text-5xl font-bold mb-4 leading-tight">Nâng tầm gian bếp của bạn.</h1>
                    <p class="text-lg font-medium opacity-90">Quản lý đơn hàng, cập nhật thực đơn và theo dõi doanh thu — tất cả trong một.</p>
                </div>
                <!-- Footer -->
                <p class="text-sm opacity-70">© 2024 Hệ thống ClickEat.</p>
            </div>
        </div>

        <!-- Right form panel -->
        <div class="flex-1 flex flex-col justify-center p-8 bg-white">
            <div class="max-w-md w-full mx-auto space-y-8">

                <!-- Title -->
                <div>
                    <h2 class="text-4xl font-bold text-gray-900 tracking-tight mb-2">Đăng nhập</h2>
                    <p class="text-gray-500">Chào mừng trở lại! Vui lòng nhập thông tin.</p>
                </div>

                <!-- Form -->
                <form method="POST" action="${pageContext.request.contextPath}/login" class="space-y-5">

                    <!-- Email -->
                    <div>
                        <label class="block text-sm font-semibold text-gray-800 mb-2">Email</label>
                        <input type="email" name="email" value="${param.email}" required
                        placeholder="admin@clickeat.com"
                        class="w-full h-12 px-4 rounded-xl border border-gray-200 bg-gray-50 text-gray-900
                        focus:bg-white focus:ring-4 focus:ring-orange-100 focus:border-primary outline-none
                        transition-all placeholder:text-gray-400"/>
                    </div>

                    <!-- Password -->
                    <div>
                        <div class="flex justify-between mb-2">
                            <label class="block text-sm font-semibold text-gray-800">Mật khẩu</label>
                            <a href="${pageContext.request.contextPath}/merchant/forgot-password"
                            class="text-sm text-[#c86601] font-semibold hover:underline">Quên mật khẩu?</a>
                        </div>
                        <div class="relative">
                            <input type="password" name="password" id="pwInput" required
                            placeholder="..."
                            class="w-full h-12 px-4 pr-12 rounded-xl border border-gray-200 bg-gray-50 text-gray-900
                            focus:bg-white focus:ring-4 focus:ring-orange-100 focus:border-primary outline-none
                            transition-all placeholder:text-gray-400"/>
                            <button type="button" onclick="togglePw()"
                            class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-700 transition-colors"
                            tabindex="-1">
                            <span class="material-symbols-outlined text-xl" id="pwEye">visibility</span>
                        </button>
                    </div>
                </div>

                <!-- Error / Success messages -->
                <c:if test="${not empty error}">
                    <p class="text-red-500 text-sm font-medium flex items-center gap-1">
                        <span class="material-symbols-outlined text-sm">error</span>
                        <span>${error}</span>
                    </p>
                </c:if>
                <c:if test="${not empty sessionScope.googleError}">
                    <p class="text-red-500 text-sm font-medium flex items-center gap-1">
                        <span class="material-symbols-outlined text-sm">error</span>
                        <span>${sessionScope.googleError}</span>
                    </p>
                    <c:remove var="googleError" scope="session"/>
                </c:if>
                <c:if test="${not empty success}">
                    <p class="text-green-600 text-sm font-medium flex items-center gap-1">
                        <span class="material-symbols-outlined text-sm">check_circle</span>
                        <span>${success}</span>
                    </p>
                </c:if>

                <!-- Submit -->
                <button type="submit"
                class="w-full h-14 bg-[#c86601] hover:bg-[#a05201] text-white font-semibold rounded-xl
                shadow-lg shadow-orange-200 transition-all text-lg flex items-center justify-center gap-2 group">
                <span>Đăng nhập</span>
                <span class="material-symbols-outlined group-hover:translate-x-1 transition-transform">arrow_forward</span>
            </button>
        </form>

        <!-- Divider -->
        <div class="relative flex items-center gap-3 py-1">
            <div class="flex-1 h-px bg-gray-200"></div>
            <span class="text-xs font-medium text-gray-400">hoặc</span>
            <div class="flex-1 h-px bg-gray-200"></div>
        </div>

        <!-- Google Sign-In -->
        <!-- Hidden form — JS fills credential then submits -->
        <form id="googleAuthForm" method="POST" action="${pageContext.request.contextPath}/merchant/auth/google">
            <input type="hidden" id="googleCredential" name="credential"/>
            <input type="hidden" name="mode" value="login"/>
        </form>
        <div id="googleBtnContainer" class="flex justify-center"></div>

        <!-- Register link -->
        <div class="text-center border-t border-gray-100 pt-6 space-y-2">
            <p class="text-gray-500">Mới dùng ClickEat?
                <a href="${pageContext.request.contextPath}/merchant/register"
                class="text-[#c86601] font-semibold hover:underline">Đăng ký cửa hàng</a>
            </p>
            <p class="text-sm text-gray-400">
                Bạn muốn <a href="${pageContext.request.contextPath}/shipper/register" class="text-[#c86601] font-semibold hover:underline">Trở thành shipper</a>?
            </p>
        </div>

    </div>
</div>

<script>
    function togglePw() {
        const input = document.getElementById('pwInput');
        const eye = document.getElementById('pwEye');
        if (input.type === 'password') {
            input.type = 'text';
            eye.textContent = 'visibility_off';
            } else {
                input.type = 'password';
                eye.textContent = 'visibility';
            }
        }
        
        // ── Google Sign-In ─────────────────────────────────────────────────────
        function handleGoogleSignIn(response) {
            document.getElementById('googleCredential').value = response.credential;
            document.getElementById('googleAuthForm').submit();
        }
        
        window.addEventListener('load', function () {
            const clientId = '${initParam["google.client.id"]}';
            if (!clientId || clientId.startsWith('YOUR_')) return; // not configured yet
            google.accounts.id.initialize({
                client_id: clientId,
                callback: handleGoogleSignIn,
                ux_mode: 'popup'
            });
            google.accounts.id.renderButton(
            document.getElementById('googleBtnContainer'),
            { theme: 'outline', size: 'large', width: 380, text: 'signin_with', shape: 'rectangular', logo_alignment: 'left' }
            );
        });
    </script>
</body>
</html>
