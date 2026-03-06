<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String currentPage = (String) request.getAttribute("currentPage");
    if (currentPage == null) currentPage = "";
    String[][] navItems = {
        {"dashboard",  "Dashboard",   "home"},
        {"orders",     "Đơn hàng",   "receipt_long"},
        {"catalog",    "Thực đơn",   "menu_book"},
        {"reviews",    "Đánh giá",   "star"},
        {"analytics",  "Phân tích",  "bar_chart"},
        {"settings",   "Cài đặt",    "settings"}
    };
%>
<!-- Sidebar -->
<aside class="hidden md:flex flex-col w-64 bg-white border-r border-gray-100 h-screen sticky top-0 shrink-0">
    <!-- Logo -->
    <div class="p-5 border-b border-gray-100">
        <div class="flex items-center gap-3">
            <div class="w-10 h-10 bg-primary/10 rounded-xl flex items-center justify-center">
                <span class="material-symbols-outlined text-primary">restaurant</span>
            </div>
            <div class="min-w-0">
                <p class="font-bold text-gray-900 text-sm leading-tight">ClickEat</p>
                <p class="text-xs text-gray-500 truncate">
                    ${not empty sessionScope.merchantShopName ? sessionScope.merchantShopName : 'Merchant'}
                </p>
            </div>
        </div>
    </div>

    <!-- Nav items -->
    <nav class="flex-1 p-4 space-y-1 overflow-y-auto">
        <% for (String[] item : navItems) {
            boolean active = item[0].equals(currentPage); %>
        <a href="<%= request.getContextPath() %>/merchant/<%= item[0] %>"
           class="flex items-center gap-3 px-3 py-2.5 rounded-xl transition-all text-sm font-medium <%= active
               ? "bg-primary text-white shadow-sm shadow-primary/20"
               : "text-gray-600 hover:bg-gray-50 hover:text-gray-900" %>">
            <span class="material-symbols-outlined text-[20px]"><%= item[2] %></span>
            <span><%= item[1] %></span>
        </a>
        <% } %>
    </nav>

    <!-- Logout -->
    <div class="p-4 border-t border-gray-100">
        <a href="${pageContext.request.contextPath}/merchant/logout"
           class="flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium text-gray-600 hover:bg-red-50 hover:text-red-600 transition-all">
            <span class="material-symbols-outlined text-[20px]">logout</span>
            <span>Đăng xuất</span>
        </a>
    </div>
</aside>

<!-- Mobile bottom nav -->
<nav class="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 flex md:hidden z-40">
    <% for (String[] item : navItems) {
        if (item[0].equals("analytics") || item[0].equals("settings")) continue;
        boolean active = item[0].equals(currentPage); %>
    <a href="<%= request.getContextPath() %>/merchant/<%= item[0] %>"
       class="flex-1 flex flex-col items-center py-2 gap-0.5 text-[10px] font-medium <%= active ? "text-primary" : "text-gray-400" %>">
        <span class="material-symbols-outlined text-[22px]"><%= item[2] %></span>
        <%= item[1] %>
    </a>
    <% } %>
</nav>
