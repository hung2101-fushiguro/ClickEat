<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="activePage" value="${param.activePage}" />

<header class="bg-white sticky top-0 z-50 shadow-[0_8px_30px_rgba(15,23,42,.04)]">
    <div class="max-w-7xl mx-auto px-6">
        <div class="h-20 flex items-center justify-between">

            <a href="${ctx}/home" class="flex items-center shrink-0">
                <img src="${ctx}/assets/images/FullLogo.jpg"
                     alt="ClickEat"
                     class="h-30 w-[200px] object-contain"
                     onerror="this.style.display='none';" />
            </a>

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

                <a href="${ctx}/promotions"
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

            <div class="flex items-center gap-3 shrink-0">

                <c:choose>
                    <c:when test="${not empty sessionScope.account}">
                        <button type="button" id="cartBtn"
                                class="relative w-10 h-10 rounded-full hover:bg-gray-100 flex items-center justify-center transition"
                                aria-label="Giỏ hàng">
                            <i class="fa-solid fa-bag-shopping text-gray-800 text-lg"></i>
                            <span class="absolute -top-1 -right-1 bg-orange-500 text-white text-[11px] font-extrabold rounded-full h-5 min-w-[20px] px-1 flex items-center justify-center shadow">
                                <c:out value="${cartCount != null ? cartCount : 0}" />
                            </span>
                        </button>
                    </c:when>

                    <c:otherwise>
                        <button type="button" id="cartBtn"
                                class="relative w-10 h-10 rounded-full hover:bg-gray-100 flex items-center justify-center transition"
                                aria-label="Giỏ hàng">
                            <i class="fa-solid fa-bag-shopping text-gray-800 text-lg"></i>
                            <span class="absolute -top-1 -right-1 bg-orange-500 text-white text-[11px] font-extrabold rounded-full h-5 min-w-[20px] px-1 flex items-center justify-center shadow">
                                <c:out value="${cartCount != null ? cartCount : 0}" />
                            </span>
                        </button>
                    </c:otherwise>
                </c:choose>

                <c:if test="${empty sessionScope.account and not empty sessionScope.guestLastOrderCode}">
                    <a href="${ctx}/guest-order-tracking?code=${sessionScope.guestLastOrderCode}"
                       class="relative w-10 h-10 rounded-full hover:bg-orange-50 flex items-center justify-center transition border border-orange-100 text-orange-500"
                       aria-label="Theo dõi đơn hàng guest"
                       title="Theo dõi đơn hàng gần nhất">
                        <i class="fa-solid fa-truck-fast text-lg"></i>
                        <span class="absolute -top-1 -right-1 bg-orange-500 text-white text-[10px] font-extrabold rounded-full h-5 min-w-[20px] px-1 flex items-center justify-center shadow">
                            1
                        </span>
                    </a>
                </c:if>

                <c:choose>
                    <c:when test="${not empty sessionScope.account}">
                        <div class="relative" id="userDropdownWrap">
                            <button type="button"
                                    id="userDropdownBtn"
                                    class="flex items-center gap-3 rounded-full border border-gray-200 bg-white px-2.5 py-1.5 hover:border-orange-200 hover:bg-orange-50 transition">
                                <c:choose>
                                    <c:when test="${not empty sessionScope.account.avatarUrl}">
                                        <img src="${sessionScope.account.avatarUrl}"
                                             alt="${sessionScope.account.fullName}"
                                             class="w-11 h-11 rounded-full object-cover border-2 border-orange-100"
                                             onerror="this.onerror=null;this.src='https://ui-avatars.com/api/?name=${sessionScope.account.fullName}&background=fff3e8&color=f97316&bold=true';">
                                    </c:when>
                                    <c:otherwise>
                                        <img src="https://ui-avatars.com/api/?name=${sessionScope.account.fullName}&background=fff3e8&color=f97316&bold=true"
                                             alt="${sessionScope.account.fullName}"
                                             class="w-11 h-11 rounded-full object-cover border-2 border-orange-100">
                                    </c:otherwise>
                                </c:choose>

                                <div class="hidden sm:flex flex-col items-start leading-tight max-w-[160px]">
                                    <span class="text-[11px] font-semibold uppercase tracking-wide text-orange-500">Tài khoản</span>
                                    <span class="text-sm font-bold text-gray-800 truncate w-full">
                                        ${sessionScope.account.fullName}
                                    </span>
                                </div>

                                <i class="fa-solid fa-chevron-down text-xs text-gray-500 transition" id="userDropdownIcon"></i>
                            </button>

                            <div id="userDropdownMenu"
                                 class="hidden absolute right-0 mt-3 w-64 rounded-2xl bg-white border border-gray-100 shadow-[0_18px_40px_rgba(15,23,42,.12)] overflow-hidden">
                                <div class="px-4 py-4 bg-gradient-to-r from-orange-50 to-white border-b border-orange-100">
                                    <div class="flex items-center gap-3">
                                        <c:choose>
                                            <c:when test="${not empty sessionScope.account.avatarUrl}">
                                                <img src="${sessionScope.account.avatarUrl}"
                                                     alt="${sessionScope.account.fullName}"
                                                     class="w-12 h-12 rounded-full object-cover border-2 border-white shadow"
                                                     onerror="this.onerror=null;this.src='https://ui-avatars.com/api/?name=${sessionScope.account.fullName}&background=fff3e8&color=f97316&bold=true';">
                                            </c:when>
                                            <c:otherwise>
                                                <img src="https://ui-avatars.com/api/?name=${sessionScope.account.fullName}&background=fff3e8&color=f97316&bold=true"
                                                     alt="${sessionScope.account.fullName}"
                                                     class="w-12 h-12 rounded-full object-cover border-2 border-white shadow">
                                            </c:otherwise>
                                        </c:choose>
                                        <div class="min-w-0">
                                            <div class="font-extrabold text-gray-900 truncate">${sessionScope.account.fullName}</div>
                                            <div class="text-sm text-gray-500 truncate">${sessionScope.account.email}</div>
                                        </div>
                                    </div>
                                </div>

                                <a href="${ctx}/customer/profile"
                                   class="flex items-center gap-3 px-4 py-3 text-sm font-semibold text-gray-700 hover:bg-orange-50 hover:text-orange-600 transition">
                                    <i class="fa-regular fa-user w-5 text-center"></i>
                                    Thông tin tài khoản
                                </a>

                                <a href="${ctx}/logout"
                                   class="flex items-center gap-3 px-4 py-3 text-sm font-semibold text-red-500 hover:bg-red-50 transition border-t border-gray-100">
                                    <i class="fa-solid fa-arrow-right-from-bracket w-5 text-center"></i>
                                    Đăng xuất
                                </a>
                            </div>
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
        setTimeout(() => {
            const el = document.getElementById('toast-error');
            if (el)
                el.style.display = 'none';
        }, 4000);
    </script>
</c:if>

<c:if test="${not empty sessionScope.toastMsg}">
    <div id="toast-success" class="fixed bottom-5 right-5 bg-green-500 text-white px-6 py-4 rounded-xl shadow-2xl z-50 flex items-center gap-3">
        <i class="fa-solid fa-circle-check text-xl"></i>
        <span class="font-medium">${sessionScope.toastMsg}</span>
    </div>
    <c:remove var="toastMsg" scope="session" />
    <script>
        setTimeout(() => {
            const el = document.getElementById('toast-success');
            if (el)
                el.style.display = 'none';
        }, 3000);
    </script>
</c:if>

<jsp:include page="cart.jsp">
    <jsp:param name="cartMode" value="popup" />
</jsp:include>

<jsp:include page="checkout-choice-modal.jsp" />

<script>
    (() => {
        const btn = document.getElementById('userDropdownBtn');
        const menu = document.getElementById('userDropdownMenu');
        const wrap = document.getElementById('userDropdownWrap');
        const icon = document.getElementById('userDropdownIcon');

        if (!btn || !menu || !wrap)
            return;

        btn.addEventListener('click', function (e) {
            e.stopPropagation();
            menu.classList.toggle('hidden');
            if (icon)
                icon.classList.toggle('rotate-180');
        });

        document.addEventListener('click', function (e) {
            if (!wrap.contains(e.target)) {
                menu.classList.add('hidden');
                if (icon)
                    icon.classList.remove('rotate-180');
            }
        });
    })();
</script>