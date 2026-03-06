<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi" class="h-full">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>ClickEat – Đăng nhập</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
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
<body class="min-h-screen bg-gradient-to-br from-orange-50 via-white to-amber-50 font-sans flex items-center justify-center p-4">

<div class="w-full max-w-md">
    <!-- Logo -->
    <div class="text-center mb-8">
        <div class="inline-flex items-center justify-center w-16 h-16 bg-primary rounded-2xl shadow-lg shadow-primary/30 mb-4">
            <span class="material-symbols-outlined text-white text-3xl">restaurant</span>
        </div>
        <h1 class="text-2xl font-bold text-gray-900">ClickEat Merchant</h1>
        <p class="text-gray-500 mt-1">Đăng nhập để quản lý cửa hàng</p>
    </div>

    <!-- Card -->
    <div class="bg-white rounded-3xl shadow-xl shadow-black/5 border border-gray-100 p-8 space-y-5">

        <!-- Error -->
        <c:if test="${not empty error}">
            <div class="flex items-center gap-2 bg-red-50 text-red-600 border border-red-200 rounded-xl px-4 py-3 text-sm">
                <span class="material-symbols-outlined text-base">error</span>
                <span>${error}</span>
            </div>
        </c:if>

        <!-- Success (e.g. from logout) -->
        <c:if test="${not empty success}">
            <div class="flex items-center gap-2 bg-green-50 text-green-700 border border-green-200 rounded-xl px-4 py-3 text-sm">
                <span class="material-symbols-outlined text-base">check_circle</span>
                <span>${success}</span>
            </div>
        </c:if>

        <form method="POST" action="${pageContext.request.contextPath}/merchant/login" class="space-y-5">
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
                </div>
                <div class="relative">
                    <input type="password" name="password" id="pwInput" required
                           placeholder="••••••••"
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

            <!-- Submit -->
            <button type="submit"
                    class="w-full h-14 bg-primary hover:bg-primary-dark text-white font-semibold rounded-xl
                           shadow-lg shadow-primary/20 transition-all text-lg flex items-center justify-center gap-2 group">
                <span>Đăng nhập</span>
                <span class="material-symbols-outlined group-hover:translate-x-1 transition-transform">arrow_forward</span>
            </button>
        </form>
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
</script>
</body>
</html>
