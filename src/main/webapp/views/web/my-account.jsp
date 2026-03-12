<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Tài khoản của tôi - ClickEat</title>
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
        <style>
            body { font-family: 'Inter', sans-serif; }
            .tab-btn.active { background-color: #c86601; color: #fff; }
        </style>
    </head>
    <body class="bg-gray-50 flex flex-col min-h-screen">

        <jsp:include page="header.jsp" />

        <main class="flex-grow max-w-3xl mx-auto px-4 sm:px-6 lg:px-8 py-8 w-full">

            <%-- Page heading --%>
            <div class="mb-8">
                <h1 class="text-2xl font-black text-gray-900">Tài khoản của tôi</h1>
                <p class="text-sm text-gray-400 mt-1">Quản lý thông tin cá nhân và bảo mật tài khoản</p>
            </div>

            <%-- Stats cards --%>
            <div class="grid grid-cols-2 gap-4 mb-8">
                <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5 flex items-center gap-4">
                    <div class="w-12 h-12 rounded-xl bg-green-50 flex items-center justify-center">
                        <i class="fa-solid fa-bag-shopping text-xl text-green-500"></i>
                    </div>
                    <div>
                        <p class="text-2xl font-black text-gray-900">${completedCount}</p>
                        <p class="text-xs text-gray-400">Đơn hàng hoàn thành</p>
                    </div>
                </div>
                <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5 flex items-center gap-4">
                    <div class="w-12 h-12 rounded-xl bg-orange-50 flex items-center justify-center">
                        <i class="fa-solid fa-coins text-xl text-orange-500"></i>
                    </div>
                    <div>
                        <p class="text-xl font-black text-gray-900">
                            <fmt:formatNumber value="${totalSpent}" type="number" maxFractionDigits="0"/>đ
                        </p>
                        <p class="text-xs text-gray-400">Tổng đã chi tiêu</p>
                    </div>
                </div>
            </div>

            <%-- Tab switcher --%>
            <div class="flex gap-2 mb-6 bg-white border border-gray-100 rounded-2xl p-1 w-fit shadow-sm">
                <button class="tab-btn active px-5 py-2 rounded-xl text-sm font-semibold transition-all"
                        onclick="showTab('profile', this)">
                    <i class="fa-solid fa-user mr-1.5"></i> Thông tin
                </button>
                <button class="tab-btn px-5 py-2 rounded-xl text-sm font-semibold transition-all text-gray-500 hover:bg-gray-50"
                        onclick="showTab('password', this)">
                    <i class="fa-solid fa-lock mr-1.5"></i> Mật khẩu
                </button>
            </div>

            <%-- Profile edit form --%>
            <div id="tab-profile">
                <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
                    <div class="flex items-center gap-5 mb-6 pb-6 border-b border-gray-50">
                        <div class="w-16 h-16 rounded-2xl bg-orange-50 flex items-center justify-center overflow-hidden border border-orange-100">
                            <c:choose>
                                <c:when test="${not empty user.avatarUrl}">
                                    <img src="${user.avatarUrl}" class="w-full h-full object-cover" alt="Avatar">
                                </c:when>
                                <c:otherwise>
                                    <i class="fa-solid fa-user text-2xl text-orange-300"></i>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div>
                            <p class="font-bold text-gray-900">${user.fullName}</p>
                            <p class="text-sm text-gray-400">${user.email}</p>
                            <span class="inline-block mt-1 px-2 py-0.5 rounded-full bg-blue-50 text-blue-600 text-xs font-semibold">
                                ${user.role}
                            </span>
                        </div>
                    </div>

                    <form method="post" action="${pageContext.request.contextPath}/my-account">
                        <input type="hidden" name="action" value="UPDATE_PROFILE">

                        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4 mb-4">
                            <div>
                                <label class="block text-sm font-semibold text-gray-700 mb-1.5">Họ và tên</label>
                                <input type="text" name="fullName" value="${user.fullName}" required
                                       class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-orange-200 focus:border-orange-400 transition-all">
                            </div>
                            <div>
                                <label class="block text-sm font-semibold text-gray-700 mb-1.5">Số điện thoại</label>
                                <input type="tel" name="phone" value="${user.phone}"
                                       class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-orange-200 focus:border-orange-400 transition-all">
                            </div>
                        </div>

                        <div class="mb-6">
                            <label class="block text-sm font-semibold text-gray-700 mb-1.5">Email</label>
                            <input type="email" name="email" value="${user.email}" required
                                   class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-orange-200 focus:border-orange-400 transition-all">
                        </div>

                        <c:if test="${not empty toastMsg || not empty requestScope.successMsg}">
                            <div class="bg-green-50 border border-green-200 text-green-700 rounded-xl px-4 py-3 text-sm mb-4 flex items-center gap-2">
                                <i class="fa-solid fa-circle-check"></i>
                                ${not empty requestScope.successMsg ? requestScope.successMsg : toastMsg}
                            </div>
                        </c:if>
                        <c:if test="${not empty toastError || not empty requestScope.errorMsg}">
                            <div class="bg-red-50 border border-red-200 text-red-600 rounded-xl px-4 py-3 text-sm mb-4 flex items-center gap-2">
                                <i class="fa-solid fa-circle-exclamation"></i>
                                ${not empty requestScope.errorMsg ? requestScope.errorMsg : toastError}
                            </div>
                        </c:if>

                        <button type="submit"
                                class="bg-orange-500 hover:bg-orange-600 text-white font-bold px-8 py-2.5 rounded-xl transition-colors shadow-sm text-sm">
                            <i class="fa-solid fa-floppy-disk mr-1.5"></i> Lưu thay đổi
                        </button>
                    </form>
                </div>
            </div>

            <%-- Change password form --%>
            <div id="tab-password" class="hidden">
                <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-6">
                    <h2 class="font-bold text-gray-900 mb-5 flex items-center gap-2">
                        <i class="fa-solid fa-shield-halved text-orange-400"></i> Đổi mật khẩu
                    </h2>

                    <form method="post" action="${pageContext.request.contextPath}/my-account" onsubmit="return validatePasswordForm()">
                        <input type="hidden" name="action" value="CHANGE_PASSWORD">

                        <div class="space-y-4 mb-6">
                            <div>
                                <label class="block text-sm font-semibold text-gray-700 mb-1.5">Mật khẩu hiện tại</label>
                                <input type="password" name="oldPassword" required
                                       class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-orange-200 focus:border-orange-400 transition-all">
                            </div>
                            <div>
                                <label class="block text-sm font-semibold text-gray-700 mb-1.5">Mật khẩu mới</label>
                                <input type="password" name="newPassword" id="newPassword" required minlength="6"
                                       class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-orange-200 focus:border-orange-400 transition-all">
                                <p class="text-xs text-gray-400 mt-1">Tối thiểu 6 ký tự</p>
                            </div>
                            <div>
                                <label class="block text-sm font-semibold text-gray-700 mb-1.5">Xác nhận mật khẩu mới</label>
                                <input type="password" name="confirmPassword" id="confirmPassword" required
                                       class="w-full border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:ring-2 focus:ring-orange-200 focus:border-orange-400 transition-all">
                                <p id="pw-mismatch" class="text-xs text-red-500 mt-1 hidden">Mật khẩu không khớp</p>
                            </div>
                        </div>

                        <c:if test="${not empty requestScope.pwSuccess}">
                            <div class="bg-green-50 border border-green-200 text-green-700 rounded-xl px-4 py-3 text-sm mb-4 flex items-center gap-2">
                                <i class="fa-solid fa-circle-check"></i> ${requestScope.pwSuccess}
                            </div>
                        </c:if>
                        <c:if test="${not empty requestScope.pwError}">
                            <div class="bg-red-50 border border-red-200 text-red-600 rounded-xl px-4 py-3 text-sm mb-4 flex items-center gap-2">
                                <i class="fa-solid fa-circle-exclamation"></i> ${requestScope.pwError}
                            </div>
                        </c:if>

                        <button type="submit"
                                class="bg-orange-500 hover:bg-orange-600 text-white font-bold px-8 py-2.5 rounded-xl transition-colors shadow-sm text-sm">
                            <i class="fa-solid fa-key mr-1.5"></i> Cập nhật mật khẩu
                        </button>
                    </form>
                </div>
            </div>

        </main>

        <jsp:include page="footer.jsp" />

        <script>
            function showTab(name, btn) {
                document.getElementById('tab-profile').classList.add('hidden');
                document.getElementById('tab-password').classList.add('hidden');
                document.getElementById('tab-' + name).classList.remove('hidden');
                document.querySelectorAll('.tab-btn').forEach(b => {
                    b.classList.remove('active');
                    b.classList.add('text-gray-500');
                    b.classList.remove('text-white');
                });
                btn.classList.add('active');
                btn.classList.remove('text-gray-500');
            }

            function validatePasswordForm() {
                const np = document.getElementById('newPassword').value;
                const cp = document.getElementById('confirmPassword').value;
                const msg = document.getElementById('pw-mismatch');
                if (np !== cp) {
                    msg.classList.remove('hidden');
                    return false;
                }
                msg.classList.add('hidden');
                return true;
            }

            <%-- Auto-switch to password tab if there's a pw error/success --%>
            <c:if test="${not empty requestScope.pwError || not empty requestScope.pwSuccess}">
            showTab('password', document.querySelectorAll('.tab-btn')[1]);
            </c:if>
        </script>
    </body>
</html>
