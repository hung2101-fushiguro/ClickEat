<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="customerMenu" value="${param.menu}" />

<aside class="w-full lg:w-[280px] shrink-0">
    <div class="bg-white border border-gray-200 rounded-[28px] shadow-[0_10px_30px_rgba(15,23,42,.06)] p-5 sticky top-28">
        <div class="flex items-center gap-3 pb-4 border-b border-gray-100">
            <c:choose>
                <c:when test="${not empty sessionScope.account.avatarUrl}">
                    <img src="${sessionScope.account.avatarUrl}"
                    alt="${sessionScope.account.fullName}"
                    class="w-14 h-14 rounded-full object-cover border-2 border-orange-100"
                    onerror="this.onerror=null;this.src='https://ui-avatars.com/api/?name=${sessionScope.account.fullName}&background=fff3e8&color=f97316&bold=true';">
                </c:when>
                <c:otherwise>
                    <img src="https://ui-avatars.com/api/?name=${sessionScope.account.fullName}&background=fff3e8&color=f97316&bold=true"
                    alt="${sessionScope.account.fullName}"
                    class="w-14 h-14 rounded-full object-cover border-2 border-orange-100">
                </c:otherwise>
            </c:choose>

            <div class="min-w-0">
                <div class="text-xs uppercase tracking-[0.2em] font-bold text-orange-500">Tài khoản</div>
                <div class="font-black text-gray-900 truncate">${sessionScope.account.fullName}</div>
                <div class="text-sm text-gray-500 truncate">${sessionScope.account.email}</div>
            </div>
        </div>

        <nav class="mt-5 space-y-2">
            <a href="${ctx}/customer/profile"
            class="flex items-center gap-3 rounded-2xl px-4 py-3 font-semibold transition
            ${customerMenu == 'profile' ? 'bg-orange-500 text-white shadow' : 'text-gray-700 hover:bg-orange-50 hover:text-orange-600'}">
            <i class="fa-regular fa-user w-5 text-center"></i>
            Thông tin cá nhân
        </a>

        <a href="${ctx}/customer/orders"
        class="flex items-center gap-3 rounded-2xl px-4 py-3 font-semibold transition
        ${customerMenu == 'orders' ? 'bg-orange-500 text-white shadow' : 'text-gray-700 hover:bg-orange-50 hover:text-orange-600'}">
        <i class="fa-solid fa-clock-rotate-left w-5 text-center"></i>
        Lịch sử đơn hàng
    </a>

    <a href="${ctx}/customer/vouchers"
    class="flex items-center gap-3 rounded-2xl px-4 py-3 font-semibold transition
    ${customerMenu == 'vouchers' ? 'bg-orange-500 text-white shadow' : 'text-gray-700 hover:bg-orange-50 hover:text-orange-600'}">
    <i class="fa-solid fa-ticket w-5 text-center"></i>
    Kho voucher
</a>

<a href="${ctx}/customer/register-role"
class="flex items-center gap-3 rounded-2xl px-4 py-3 font-semibold transition
${customerMenu == 'register-role' ? 'bg-orange-500 text-white shadow' : 'text-gray-700 hover:bg-orange-50 hover:text-orange-600'}">
<i class="fa-solid fa-store w-5 text-center"></i>
Đăng ký Shipper / Merchant
</a>
</nav>
</div>
</aside>