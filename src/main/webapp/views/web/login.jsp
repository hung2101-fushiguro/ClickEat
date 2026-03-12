<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Đăng Nhập - ClickEat</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <script>
            tailwind.config = {
                theme: {
                    extend: {
                        fontFamily: {sans: ['Inter', 'sans-serif']},
                        colors: {primary: '#c86601', 'primary-dark': '#a05201'}
                    }
                }
            };
        </script>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
        <style>body { font-family: 'Inter', sans-serif; }</style>
    </head>
    <body class="min-h-screen bg-gradient-to-br from-orange-50 via-white to-amber-50 flex flex-col">

        <%-- Top bar --%>
        <div class="px-6 py-4">
            <a href="${pageContext.request.contextPath}/home" class="inline-flex items-center gap-2 group">
                <div class="w-9 h-9 bg-orange-500 rounded-xl flex items-center justify-center shadow-sm group-hover:bg-orange-600 transition-colors">
                    <i class="fa-solid fa-utensils text-white text-sm"></i>
                </div>
                <span class="text-xl font-black text-gray-900">ClickEat</span>
            </a>
        </div>

        <%-- Card --%>
        <div class="flex-1 flex items-center justify-center px-4 py-10">
            <div class="w-full max-w-md">
                <div class="bg-white rounded-3xl shadow-xl border border-gray-100 p-8">

                    <div class="text-center mb-8">
                        <div class="w-16 h-16 bg-orange-50 rounded-2xl flex items-center justify-center mx-auto mb-4 border border-orange-100">
                            <i class="fa-solid fa-right-to-bracket text-2xl text-orange-500"></i>
                        </div>
                        <h1 class="text-2xl font-black text-gray-900">Chào mừng trở lại!</h1>
                        <p class="text-sm text-gray-400 mt-1">Đăng nhập để tiếp tục đặt món ngon</p>
                    </div>

                    <c:if test="${not empty error}">
                        <div class="bg-red-50 border border-red-200 text-red-600 rounded-xl px-4 py-3 text-sm mb-5 flex items-center gap-2">
                            <i class="fa-solid fa-circle-exclamation"></i> ${error}
                        </div>
                    </c:if>
                    <c:if test="${not empty message}">
                        <div class="bg-green-50 border border-green-200 text-green-700 rounded-xl px-4 py-3 text-sm mb-5 flex items-center gap-2">
                            <i class="fa-solid fa-circle-check"></i> ${message}
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/login" method="post" class="space-y-4">
                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-1.5">Tài khoản (SĐT / Email)</label>
                            <div class="relative">
                                <span class="absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-400 text-sm"><i class="fa-solid fa-user"></i></span>
                                <input type="text" name="username" required autofocus
                                class="w-full border border-gray-200 rounded-xl pl-10 pr-4 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-orange-200 focus:border-orange-400 transition-all">
                            </div>
                        </div>
                        <div>
                            <label class="block text-sm font-semibold text-gray-700 mb-1.5">Mật khẩu</label>
                            <div class="relative">
                                <span class="absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-400 text-sm"><i class="fa-solid fa-lock"></i></span>
                                <input type="password" name="password" id="pw" required
                                class="w-full border border-gray-200 rounded-xl pl-10 pr-12 py-3 text-sm focus:outline-none focus:ring-2 focus:ring-orange-200 focus:border-orange-400 transition-all">
                                <button type="button" onclick="togglePw()" class="absolute right-3.5 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600">
                                    <i class="fa-solid fa-eye text-sm" id="pw-eye"></i>
                                </button>
                            </div>
                        </div>

                        <button type="submit"
                        class="w-full bg-orange-500 hover:bg-orange-600 text-white font-bold py-3 rounded-xl transition-colors shadow-sm mt-2">
                        <i class="fa-solid fa-right-to-bracket mr-2"></i>Đăng nhập
                    </button>
                </form>

                <div class="mt-6 text-center">
                    <p class="text-sm text-gray-400">
                        Chưa có tài khoản?
                        <a href="${pageContext.request.contextPath}/register" class="text-orange-500 font-bold hover:text-orange-600 transition-colors">Đăng ký ngay</a>
                    </p>
                </div>
            </div>

            <p class="text-center text-xs text-gray-400 mt-6">
                <a href="${pageContext.request.contextPath}/home" class="hover:text-orange-400 transition-colors">
                    <i class="fa-solid fa-arrow-left mr-1"></i>Quay lại trang chủ
                </a>
            </p>
        </div>
    </div>

    <script>
        function togglePw() {
            const pw = document.getElementById('pw');
            const eye = document.getElementById('pw-eye');
            if (pw.type === 'password') {
                pw.type = 'text';
                eye.className = 'fa-solid fa-eye-slash text-sm';
                } else {
                    pw.type = 'password';
                    eye.className = 'fa-solid fa-eye text-sm';
                }
            }
        </script>
    </body>
</html>