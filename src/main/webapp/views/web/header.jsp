<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="activePage" value="${param.activePage}" />

<header class="bg-white sticky top-0 z-50">
    <div class="max-w-7xl mx-auto px-6">
        <div class="h-16 flex items-center justify-between">

            <!-- Logo -->
            <a href="${ctx}/home" class="flex items-center gap-2">
                <div class="w-9 h-9 rounded-xl bg-orange-500 flex items-center justify-center shadow-sm">
                    <span class="block w-4 h-4 bg-white rounded-sm"
                          style="clip-path: polygon(0 20%, 70% 20%, 70% 0, 100% 0, 100% 100%, 0 100%);"></span>
                </div>
                <span class="text-xl font-extrabold tracking-tight text-gray-900">ClickEat</span>
            </a>

            <!-- Menu -->
            <nav class="hidden lg:flex items-center gap-8">
                <a href="${ctx}/home"
                   class="text-[15px] font-semibold transition border-b-2 pb-1
                   ${activePage == 'home' ? 'text-orange-500 border-orange-500' : 'text-gray-900 border-transparent hover:text-orange-500'}">
                    Trang chủ
                </a>

                <a href="${ctx}/about"
                   class="text-[15px] font-semibold transition border-b-2 pb-1
                   ${activePage == 'about' ? 'text-orange-500 border-orange-500' : 'text-gray-900 border-transparent hover:text-orange-500'}">
                    Về chúng tôi
                </a>

                <a href="${ctx}/menu"
                   class="text-[15px] font-semibold transition border-b-2 pb-1
                   ${activePage == 'menu' ? 'text-orange-500 border-orange-500' : 'text-gray-900 border-transparent hover:text-orange-500'}">
                    Thực đơn
                </a>

                <a href="${ctx}/promotion"
                   class="text-[15px] font-semibold transition border-b-2 pb-1
                   ${activePage == 'promotion' ? 'text-orange-500 border-orange-500' : 'text-gray-900 border-transparent hover:text-orange-500'}">
                    Khuyến mãi
                </a>

                <a href="${ctx}/store"
                   class="text-[15px] font-semibold transition border-b-2 pb-1
                   ${activePage == 'store' ? 'text-orange-500 border-orange-500' : 'text-gray-900 border-transparent hover:text-orange-500'}">
                    Cửa hàng
                </a>

                <a href="${ctx}/ai"
                   class="text-[15px] font-extrabold transition border-b-2 pb-1 flex items-center gap-1
                   ${activePage == 'ai' ? 'text-orange-500 border-orange-500' : 'text-gray-900 border-transparent hover:text-orange-500'}">
                    AI gợi ý <span class="text-orange-500">✨</span>
                </a>
            </nav>

            <!-- Right -->
            <div class="flex items-center gap-3">
                <button type="button" id="cartBtn"
                        class="relative w-10 h-10 rounded-full hover:bg-gray-100 flex items-center justify-center transition"
                        aria-label="Giỏ hàng">
                    <i class="fa-solid fa-bag-shopping text-gray-800 text-lg"></i>
                    <span class="absolute -top-1 -right-1 bg-orange-500 text-white text-[11px] font-extrabold rounded-full h-5 min-w-[20px] px-1 flex items-center justify-center shadow">
                        <c:out value="${cartCount != null ? cartCount : 0}" />
                    </span>
                </button>

                <c:choose>
                    <c:when test="${not empty sessionScope.account}">
                        <div class="hidden sm:flex items-center gap-3">
                            <span class="text-sm font-semibold text-gray-700">
                                Chào, ${sessionScope.account.fullName}
                            </span>
                            <a href="${ctx}/logout"
                               class="text-sm font-semibold text-gray-500 hover:text-red-500 transition">
                                Đăng xuất
                            </a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <a href="${ctx}/login"
                           class="h-10 px-5 rounded-full border border-gray-200 text-gray-900 font-extrabold text-sm hover:bg-gray-50 flex items-center justify-center whitespace-nowrap leading-none">
                            Đăng nhập
                        </a>
                        <a href="${ctx}/register"
                           class="h-10 px-5 rounded-full bg-orange-500 text-white font-extrabold text-sm hover:bg-orange-600 flex items-center justify-center whitespace-nowrap leading-none shadow">
                            Đăng ký
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>

        </div>
    </div>
    <div class="h-px bg-gray-100"></div>
</header>

    <c:if test="${not empty sessionScope.toastError}">
        <div id="toast-error" class="fixed bottom-5 right-5 bg-red-500 text-white px-6 py-4 rounded-xl shadow-2xl z-50 flex items-center gap-3 animate-bounce">
            <i class="fa-solid fa-triangle-exclamation text-xl"></i>
            <span class="font-medium">${sessionScope.toastError}</span>
        </div>
        <c:remove var="toastError" scope="session" />

        <script>
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

<!-- Gọi popup cart từ file riêng -->
<jsp:include page="cart.jsp">
    <jsp:param name="cartMode" value="popup" />
</jsp:include>