<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<header class="bg-white shadow-sm sticky top-0 z-50">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center h-16">

            <div class="flex items-center gap-8">
                <a href="${pageContext.request.contextPath}/home" class="flex items-center gap-2 shrink-0">
                    <div class="w-8 h-8 bg-orange-500 rounded-lg flex items-center justify-center">
                        <i class="fa-solid fa-utensils text-white font-bold text-sm"></i>
                    </div>
                    <span class="text-xl font-bold text-gray-900 tracking-tight">ClickEat</span>
                </a>

                <nav class="hidden md:flex space-x-6">
                    <a href="${pageContext.request.contextPath}/about" class="text-sm text-gray-600 hover:text-orange-500 font-medium transition-colors">Về chúng tôi</a>
                    <a href="${pageContext.request.contextPath}/menu" class="text-sm text-gray-600 hover:text-orange-500 font-medium transition-colors">Thực đơn</a>
                    <a href="${pageContext.request.contextPath}/store" class="text-sm text-gray-600 hover:text-orange-500 font-medium transition-colors">Cửa hàng</a>
                    <a href="${pageContext.request.contextPath}/aichat" class="text-sm text-orange-500 hover:text-orange-600 font-bold flex items-center gap-1 transition-colors">
                        <i class="fa-solid fa-wand-magic-sparkles"></i> AI Gợi ý
                    </a>
                </nav>
            </div>

            <div class="flex items-center gap-4">

                <a href="${pageContext.request.contextPath}/cart" class="p-2 text-gray-600 hover:text-gray-900 transition-colors relative block cursor-pointer">
                    <i class="fa-solid fa-cart-shopping text-xl"></i>
                    <span class="absolute top-0 right-0 bg-orange-500 text-white text-[10px] font-bold rounded-full h-4 w-4 flex items-center justify-center transform translate-x-1 -translate-y-1 shadow-sm">
                        ${cartCount != null ? cartCount : 0}
                    </span>
                </a>

                <c:choose>
                    <c:when test="${not empty sessionScope.account}">
                        <div class="flex items-center gap-3">
                            <span class="text-sm font-medium text-gray-700 hidden sm:block">Chào, ${sessionScope.account.fullName}</span>
                            <a href="${pageContext.request.contextPath}/logout" class="text-sm text-gray-500 hover:text-red-500 font-medium transition-colors">Đăng xuất</a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="flex items-center gap-2">
                            <a href="${pageContext.request.contextPath}/login" class="bg-white text-gray-900 border border-gray-200 px-4 py-2 rounded-lg text-sm font-bold hover:bg-gray-50 transition-colors shadow-sm">
                                Đăng nhập
                            </a>
                            <a href="${pageContext.request.contextPath}/register" class="bg-orange-500 text-white px-4 py-2 rounded-lg text-sm font-bold hover:bg-orange-600 transition-colors shadow-sm">
                                Đăng ký
                            </a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

        </div>
    </div>
    <c:if test="${not empty sessionScope.toastError}">
        <div id="toast-error" class="fixed bottom-5 right-5 bg-red-500 text-white px-6 py-4 rounded-xl shadow-2xl z-50 flex items-center gap-3 animate-bounce">
            <i class="fa-solid fa-triangle-exclamation text-xl"></i>
            <span class="font-medium">${sessionScope.toastError}</span>
        </div>
        <c:remove var="toastError" scope="session" />

        <script>
            // Tự động ẩn sau 4 giây
            setTimeout(() => document.getElementById('toast-error').style.display = 'none', 4000);
        </script>
    </c:if>

    <c:if test="${not empty sessionScope.toastMsg}">
        <div id="toast-success" class="fixed bottom-5 right-5 bg-green-500 text-white px-6 py-4 rounded-xl shadow-2xl z-50 flex items-center gap-3">
            <i class="fa-solid fa-circle-check text-xl"></i>
            <span class="font-medium">${sessionScope.toastMsg}</span>
        </div>
        <c:remove var="toastMsg" scope="session" />

        <script>
            setTimeout(() => document.getElementById('toast-success').style.display = 'none', 3000);
        </script>
    </c:if>
</header>