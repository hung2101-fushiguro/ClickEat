<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Đăng nhập – ClickEat</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet"/>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css"/>
        <script>
            tailwind.config = {
                theme: {
                    extend: {
                        fontFamily: {sans: ['Inter', 'sans-serif']}
                    }
                }
            }
        </script>
    </head>
    <body class="min-h-screen font-sans flex bg-gray-50">

        <!-- Left hero panel -->
        <div class="hidden md:flex w-1/2 bg-orange-500 relative overflow-hidden flex-col">
            <div class="absolute inset-0 bg-black/25"></div>
            <div class="absolute inset-0 bg-cover bg-center opacity-50"
            style="background-image:url('https://images.unsplash.com/photo-1476224203421-9ac39bcb3327?auto=format&fit=crop&w=1200&q=80'); mix-blend-mode:overlay"></div>
            <div class="relative z-10 flex flex-col justify-between p-12 text-white h-full">
                <!-- Brand -->
                <div class="flex items-center gap-3">
                    <div class="w-10 h-10 bg-white rounded-xl flex items-center justify-center text-orange-500 shadow-lg">
                        <i class="fa-solid fa-utensils text-lg"></i>
                    </div>
                    <span class="text-2xl font-bold">ClickEat</span>
                </div>
                <!-- Tagline -->
                <div class="max-w-md">
                    <h1 class="text-5xl font-bold mb-4 leading-tight">Giao thức ẩm thực thông minh.</h1>
                    <p class="text-lg font-medium opacity-90">Hệ thống quản lý toàn diện cho Admin, Merchant và Shipper — tất cả trên một nền tảng.</p>
                </div>
                <!-- Role cards -->
                <div class="grid grid-cols-3 gap-3">
                    <div class="bg-white/15 backdrop-blur-sm rounded-2xl p-4 text-center border border-white/20">
                        <i class="fa-solid fa-shield-halved text-2xl mb-2 block"></i>
                        <p class="text-xs font-bold">Admin</p>
                        <p class="text-[10px] opacity-75 mt-0.5">Quản trị hệ thống</p>
                    </div>
                    <div class="bg-white/15 backdrop-blur-sm rounded-2xl p-4 text-center border border-white/20">
                        <i class="fa-solid fa-store text-2xl mb-2 block"></i>
                        <p class="text-xs font-bold">Merchant</p>
                        <p class="text-[10px] opacity-75 mt-0.5">Quản lý cửa hàng</p>
                    </div>
                    <div class="bg-white/15 backdrop-blur-sm rounded-2xl p-4 text-center border border-white/20">
                        <i class="fa-solid fa-motorcycle text-2xl mb-2 block"></i>
                        <p class="text-xs font-bold">Shipper</p>
                        <p class="text-[10px] opacity-75 mt-0.5">Giao hàng nhanh</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Right form panel -->
        <div class="flex-1 flex flex-col justify-center p-8 bg-white overflow-y-auto">
            <div class="max-w-md w-full mx-auto space-y-5">

                <!-- Mobile brand -->
                <div class="flex md:hidden items-center gap-2 mb-2">
                    <div class="w-8 h-8 bg-orange-500 rounded-lg flex items-center justify-center">
                        <i class="fa-solid fa-utensils text-white text-sm"></i>
                    </div>
                    <span class="text-xl font-bold text-gray-900">ClickEat</span>
                </div>

                <!-- Tab switcher -->
                <div class="flex bg-gray-100 rounded-2xl p-1">
                    <button id="tabLogin" onclick="switchTab('login')"
                        class="flex-1 h-10 rounded-xl font-semibold text-sm transition-all bg-white text-gray-900 shadow-sm">
                        <i class="fa-solid fa-right-to-bracket mr-1.5"></i>Đăng nhập
                    </button>
                    <button id="tabRegister" onclick="switchTab('register')"
                        class="flex-1 h-10 rounded-xl font-semibold text-sm transition-all text-gray-500 hover:text-gray-700">
                        <i class="fa-solid fa-user-plus mr-1.5"></i>Đăng ký
                    </button>
                </div>

                <!-- ===== LOGIN PANEL ===== -->
                <div id="panelLogin" class="space-y-5">
                    <div>
                        <h2 class="text-2xl font-bold text-gray-900">Chào mừng trở lại!</h2>
                        <p class="text-gray-500 mt-1 text-sm">Hệ thống tự điều hướng theo vai trò của bạn.</p>
                    </div>

                    <c:if test="${not empty error}">
                        <div class="flex items-center gap-2 bg-red-50 border border-red-200 text-red-700 rounded-xl px-4 py-3 text-sm font-medium">
                            <i class="fa-solid fa-circle-exclamation"></i>
                            ${error}
                        </div>
                    </c:if>
                    <c:if test="${not empty message}">
                        <div class="flex items-center gap-2 bg-green-50 border border-green-200 text-green-700 rounded-xl px-4 py-3 text-sm font-medium">
                            <i class="fa-solid fa-circle-check"></i>
                            ${message}
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/login" method="post" class="space-y-4">
                        <div>
                            <label class="block text-sm font-semibold text-gray-800 mb-2">Tài khoản (SĐT / Email)</label>
                            <div class="relative">
                                <i class="fa-solid fa-user absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-400 text-sm"></i>
                                <input type="text" name="username" required autofocus
                                    class="w-full h-12 pl-10 pr-4 rounded-xl border border-gray-200 bg-gray-50 text-gray-900 focus:bg-white focus:ring-4 focus:ring-orange-500/10 focus:border-orange-500 outline-none transition-all placeholder:text-gray-400"
                                    placeholder="Nhập số điện thoại hoặc email">
                            </div>
                        </div>
                        <div>
                            <label class="block text-sm font-semibold text-gray-800 mb-2">Mật khẩu</label>
                            <div class="relative">
                                <i class="fa-solid fa-lock absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-400 text-sm"></i>
                                <input type="password" name="password" required
                                    class="w-full h-12 pl-10 pr-4 rounded-xl border border-gray-200 bg-gray-50 text-gray-900 focus:bg-white focus:ring-4 focus:ring-orange-500/10 focus:border-orange-500 outline-none transition-all placeholder:text-gray-400"
                                    placeholder="••••••••">
                            </div>
                        </div>
                        <button type="submit" id="loginBtn"
                            class="w-full h-12 bg-orange-500 hover:bg-orange-600 text-white font-semibold rounded-xl shadow-lg shadow-orange-500/20 transition-all flex items-center justify-center gap-2 text-base">
                            <i class="fa-solid fa-right-to-bracket"></i> Đăng nhập
                        </button>
                    </form>

                    <!-- Role auto-route info -->
                    <div class="bg-gray-50 rounded-2xl p-4 border border-gray-100">
                        <p class="text-xs font-semibold text-gray-500 uppercase tracking-wide mb-3">Tự động điều hướng theo vai trò</p>
                        <div class="grid grid-cols-3 gap-2 text-center">
                            <div class="bg-white rounded-xl p-3 border border-gray-200">
                                <i class="fa-solid fa-shield-halved text-orange-500 mb-1 block"></i>
                                <p class="text-xs font-bold text-gray-700">Admin</p>
                                <p class="text-[10px] text-gray-400 mt-0.5">Bảng điều khiển</p>
                            </div>
                            <div class="bg-white rounded-xl p-3 border border-gray-200">
                                <i class="fa-solid fa-store text-orange-500 mb-1 block"></i>
                                <p class="text-xs font-bold text-gray-700">Merchant</p>
                                <p class="text-[10px] text-gray-400 mt-0.5">Quản lý cửa hàng</p>
                            </div>
                            <div class="bg-white rounded-xl p-3 border border-gray-200">
                                <i class="fa-solid fa-motorcycle text-orange-500 mb-1 block"></i>
                                <p class="text-xs font-bold text-gray-700">Shipper</p>
                                <p class="text-[10px] text-gray-400 mt-0.5">Giao hàng</p>
                            </div>
                        </div>
                    </div>

                    <p class="text-center text-sm text-gray-500">
                        Chưa có tài khoản?
                        <button type="button" onclick="switchTab('register')"
                            class="text-orange-500 font-semibold hover:underline">Đăng ký ngay</button>
                    </p>
                </div>

                <!-- ===== REGISTER PANEL ===== -->
                <div id="panelRegister" class="hidden space-y-5">
                    <div>
                        <h2 class="text-2xl font-bold text-gray-900">Tạo tài khoản mới</h2>
                        <p class="text-gray-500 mt-1 text-sm">Chọn vai trò của bạn để bắt đầu đăng ký.</p>
                    </div>

                    <!-- Role cards -->
                    <div class="space-y-3">

                        <!-- Customer -->
                        <a href="${pageContext.request.contextPath}/register"
                            class="flex items-center gap-4 p-4 bg-white border-2 border-gray-200 rounded-2xl hover:border-orange-400 hover:bg-orange-50 transition-all group cursor-pointer">
                            <div class="w-12 h-12 rounded-xl bg-blue-50 group-hover:bg-orange-100 flex items-center justify-center flex-shrink-0 transition-colors">
                                <i class="fa-solid fa-user text-blue-500 group-hover:text-orange-500 text-xl transition-colors"></i>
                            </div>
                            <div class="flex-1 min-w-0">
                                <p class="font-bold text-gray-900 text-base">Khách hàng</p>
                                <p class="text-sm text-gray-500 mt-0.5">Đặt món ăn yêu thích từ các nhà hàng gần bạn</p>
                            </div>
                            <i class="fa-solid fa-chevron-right text-gray-300 group-hover:text-orange-400 transition-colors"></i>
                        </a>

                        <!-- Merchant -->
                        <a href="${pageContext.request.contextPath}/merchant/register"
                            class="flex items-center gap-4 p-4 bg-white border-2 border-gray-200 rounded-2xl hover:border-orange-400 hover:bg-orange-50 transition-all group cursor-pointer">
                            <div class="w-12 h-12 rounded-xl bg-orange-50 group-hover:bg-orange-100 flex items-center justify-center flex-shrink-0 transition-colors">
                                <i class="fa-solid fa-store text-orange-500 text-xl"></i>
                            </div>
                            <div class="flex-1 min-w-0">
                                <p class="font-bold text-gray-900 text-base">Merchant <span class="text-xs font-medium text-orange-500 bg-orange-50 border border-orange-200 rounded-full px-2 py-0.5 ml-1">Đối tác</span></p>
                                <p class="text-sm text-gray-500 mt-0.5">Đăng ký cửa hàng, quản lý thực đơn & doanh thu</p>
                            </div>
                            <i class="fa-solid fa-chevron-right text-gray-300 group-hover:text-orange-400 transition-colors"></i>
                        </a>

                        <!-- Shipper -->
                        <a href="${pageContext.request.contextPath}/shipper/register"
                            class="flex items-center gap-4 p-4 bg-white border-2 border-gray-200 rounded-2xl hover:border-orange-400 hover:bg-orange-50 transition-all group cursor-pointer">
                            <div class="w-12 h-12 rounded-xl bg-green-50 group-hover:bg-orange-100 flex items-center justify-center flex-shrink-0 transition-colors">
                                <i class="fa-solid fa-motorcycle text-green-500 group-hover:text-orange-500 text-xl transition-colors"></i>
                            </div>
                            <div class="flex-1 min-w-0">
                                <p class="font-bold text-gray-900 text-base">Shipper <span class="text-xs font-medium text-green-600 bg-green-50 border border-green-200 rounded-full px-2 py-0.5 ml-1">Đối tác</span></p>
                                <p class="text-sm text-gray-500 mt-0.5">Giao hàng linh hoạt, thu nhập hấp dẫn mỗi ngày</p>
                            </div>
                            <i class="fa-solid fa-chevron-right text-gray-300 group-hover:text-orange-400 transition-colors"></i>
                        </a>

                    </div>

                    <p class="text-center text-sm text-gray-500">
                        Đã có tài khoản?
                        <button type="button" onclick="switchTab('login')"
                            class="text-orange-500 font-semibold hover:underline">Đăng nhập ngay</button>
                    </p>
                </div>

                <p class="text-center text-xs text-gray-400">© 2024 Hệ thống ClickEat. Bảo lưu mọi quyền.</p>
            </div>
        </div>

        <script>
            // Auto-open register tab if URL has ?tab=register
            (function () {
                const params = new URLSearchParams(window.location.search);
                if (params.get('tab') === 'register') switchTab('register');
            })();

            function switchTab(tab) {
                const isLogin = tab === 'login';
                document.getElementById('panelLogin').classList.toggle('hidden', !isLogin);
                document.getElementById('panelRegister').classList.toggle('hidden', isLogin);

                const tl = document.getElementById('tabLogin');
                const tr = document.getElementById('tabRegister');
                if (isLogin) {
                    tl.classList.add('bg-white', 'text-gray-900', 'shadow-sm');
                    tl.classList.remove('text-gray-500');
                    tr.classList.remove('bg-white', 'text-gray-900', 'shadow-sm');
                    tr.classList.add('text-gray-500');
                } else {
                    tr.classList.add('bg-white', 'text-gray-900', 'shadow-sm');
                    tr.classList.remove('text-gray-500');
                    tl.classList.remove('bg-white', 'text-gray-900', 'shadow-sm');
                    tl.classList.add('text-gray-500');
                }
            }
        </script>

    </body>
</html>