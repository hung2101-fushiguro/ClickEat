<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String currentPage = (String) request.getAttribute("currentPage");
    if (currentPage == null) currentPage = "";
    java.util.Set<String> mobileCollapsedItems = new java.util.HashSet<>(
        java.util.Arrays.asList("analytics", "wallet", "promotions", "reviews", "settings")
    );
    boolean isMobileMoreActive = mobileCollapsedItems.contains(currentPage);
    String[][] navItems = {
        {"dashboard",   "Dashboard",    "home"},
        {"orders",      "Đơn hàng",    "receipt_long"},
        {"catalog",     "Catalog",     "menu_book"},
        {"analytics",   "Phân tích",   "bar_chart"},
        {"wallet",      "Ví tiền",     "account_balance_wallet"},
        {"promotions",  "Khuyến mãi",  "local_offer"},
        {"reviews",     "Đánh giá",    "star"},
        {"chat",        "Tin nhắn",    "chat"},
        {"settings",    "Cài đặt",     "settings"}
    };
%>
<!-- Sidebar -->
<aside class="hidden md:flex flex-col w-64 bg-white border-r border-gray-100 h-screen sticky top-0 shrink-0 z-[60]">
    <!-- Logo + Notification Bell -->
    <div class="p-5 border-b border-gray-100">
        <div class="flex items-center gap-3">
            <div class="w-10 h-10 bg-primary/10 rounded-xl flex items-center justify-center">
                <span class="material-symbols-outlined text-primary">restaurant</span>
            </div>
            <div class="min-w-0 flex-1">
                <p class="font-bold text-gray-900 text-sm leading-tight">ClickEat</p>
                <p class="text-xs text-gray-500 truncate">
                    ${not empty sessionScope.merchantShopName ? sessionScope.merchantShopName : 'Merchant'}
                </p>
            </div>
            <!-- Bell button -->
            <div class="relative shrink-0" id="notifContainer">
                <button id="notifBtn" onclick="toggleNotifDropdown()"
                        class="relative p-2 rounded-xl text-gray-500 hover:bg-gray-100 hover:text-gray-700 transition-all">
                    <span class="material-symbols-outlined text-xl">notifications</span>
                    <span id="notifBadge"
                          class="absolute -top-0.5 -right-0.5 hidden min-w-[18px] h-[18px] px-1 bg-red-500 text-white text-[10px] font-bold rounded-full flex items-center justify-center leading-none"></span>
                </button>
                <!-- Dropdown -->
                 <div id="notifDropdown"
                     class="hidden absolute left-0 top-full mt-2 w-80 bg-white rounded-2xl shadow-xl border border-gray-100 z-[120] overflow-hidden">
                    <div class="flex items-center justify-between px-4 py-3 border-b border-gray-100 bg-gray-50">
                        <span class="text-sm font-bold text-gray-900">Thông báo</span>
                        <button onclick="markAllRead()" class="text-xs text-primary font-medium hover:underline">Đánh dấu đã đọc</button>
                    </div>
                    <div id="notifList" class="max-h-72 overflow-y-auto divide-y divide-gray-50">
                        <p class="text-xs text-gray-400 text-center py-6">Đang tải...</p>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        (function () {
            var ctx = '<%= request.getContextPath()%>';

        function fetchNotifs() {
            fetch(ctx + '/merchant/notifications', {credentials:'same-origin'})
                .then(function(r){ return r.json(); })
                .then(function(data){
                    updateBadge('notifBadge', data.unread);
                    updateBadge('mobileNotifBadge', data.unread);
                    renderList(data.items, 'notifList');
                    renderList(data.items, 'mobileNotifList');
                })
                .catch(function(){});
        }

        function renderList(items, listId) {
            var list = document.getElementById(listId);
            if (!list) return;
            if (!items || items.length === 0) {
                list.innerHTML = '<p class="text-xs text-gray-400 text-center py-6">Không có thông báo</p>';
                return;
            }

            function renderList(items, listId) {
                var list = document.getElementById(listId);
                if (!list)
                    return;
                if (!items || items.length === 0) {
                    list.innerHTML = '<p class="text-xs text-gray-400 text-center py-6">Không có thông báo</p>';
                    return;
                }
                var html = '';
                for (var i = 0; i < items.length; i++) {
                    var n = items[i];
                    var bg = n.isRead ? '' : 'bg-orange-50';
                    var dot = n.isRead ? '' : '<span class="w-2 h-2 rounded-full bg-primary shrink-0 mt-1"></span>';
                    html += '<div class="flex items-start gap-2.5 px-4 py-3 hover:bg-gray-50 transition-all ' + bg + '">'
                            + dot
                            + '<div class="min-w-0 flex-1">'
                            + '<p class="text-xs text-gray-800 leading-snug">' + escHtml(n.content) + '</p>'
                            + '<p class="text-[10px] text-gray-400 mt-0.5">' + escHtml(n.time) + '</p>'
                            + '</div></div>';
                }
                list.innerHTML = html;
            }

        function updateBadge(id, unread) {
            var badge = document.getElementById(id);
            if (!badge) return;
            if (unread > 0) {
                badge.textContent = unread > 99 ? '99+' : unread;
                badge.classList.remove('hidden');
            } else {
                badge.classList.add('hidden');
            }
        }

        function escHtml(s) {
            return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
        }

            function escHtml(s) {
                return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
            }

        window.markAllRead = function() {
            fetch(ctx + '/merchant/notifications', {method:'POST', credentials:'same-origin'})
                .then(function(){ fetchNotifs(); })
                .catch(function(){});
        };

        window.toggleMobileMenu = function(forceOpen) {
            var overlay = document.getElementById('mobileMenuOverlay');
            var sheet = document.getElementById('mobileMenuSheet');
            if (!overlay || !sheet) return;

            var shouldOpen = typeof forceOpen === 'boolean' ? forceOpen : overlay.classList.contains('hidden');
            if (shouldOpen) {
                overlay.classList.remove('hidden');
                sheet.classList.remove('translate-y-full');
                document.body.classList.add('overflow-hidden');
            } else {
                sheet.classList.add('translate-y-full');
                document.body.classList.remove('overflow-hidden');
                setTimeout(function() {
                    overlay.classList.add('hidden');
                }, 180);
            }
        };

        // Close dropdown when clicking outside
        document.addEventListener('click', function(e) {
            var container = document.getElementById('notifContainer');
            if (container && !container.contains(e.target)) {
                var dd = document.getElementById('notifDropdown');
                if (dd) dd.classList.add('hidden');
            }

            var overlay = document.getElementById('mobileMenuOverlay');
            if (overlay && e.target === overlay) {
                window.toggleMobileMenu(false);
            }
        });

        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                window.toggleMobileMenu(false);
            }
        });

            window.markAllRead = function () {
                fetch(ctx + '/merchant/notifications', {method: 'POST', credentials: 'same-origin'})
                        .then(function () {
                            fetchNotifs();
                        })
                        .catch(function () {});
            };

            window.toggleMobileMenu = function (forceOpen) {
                var overlay = document.getElementById('mobileMenuOverlay');
                var sheet = document.getElementById('mobileMenuSheet');
                if (!overlay || !sheet)
                    return;

                var shouldOpen = typeof forceOpen === 'boolean' ? forceOpen : overlay.classList.contains('hidden');
                if (shouldOpen) {
                    overlay.classList.remove('hidden');
                    sheet.classList.remove('translate-y-full');
                    document.body.classList.add('overflow-hidden');
                } else {
                    sheet.classList.add('translate-y-full');
                    document.body.classList.remove('overflow-hidden');
                    setTimeout(function () {
                        overlay.classList.add('hidden');
                    }, 180);
                }
            };

            // Close dropdown when clicking outside
            document.addEventListener('click', function (e) {
                var container = document.getElementById('notifContainer');
                if (container && !container.contains(e.target)) {
                    var dd = document.getElementById('notifDropdown');
                    if (dd)
                        dd.classList.add('hidden');
                }

                var overlay = document.getElementById('mobileMenuOverlay');
                if (overlay && e.target === overlay) {
                    window.toggleMobileMenu(false);
                }
            });

            document.addEventListener('keydown', function (e) {
                if (e.key === 'Escape') {
                    window.toggleMobileMenu(false);
                }
            });

            // Initial fetch + poll every 60 seconds
            fetchNotifs();
            setInterval(fetchNotifs, 60000);
        })();
    </script>

    <!-- Nav items -->
    <nav class="flex-1 p-4 space-y-1 overflow-y-auto">
        <% for (String[] item : navItems) {
                boolean active = item[0].equals(currentPage);%>
        <a href="<%= request.getContextPath()%>/merchant/<%= item[0]%>"
           class="flex items-center gap-3 px-3 py-2.5 rounded-xl transition-all text-sm font-medium <%= active
                   ? "bg-primary text-white shadow-sm shadow-primary/20"
                   : "text-gray-600 hover:bg-gray-50 hover:text-gray-900"%>">
            <span class="material-symbols-outlined text-[20px]"><%= item[2]%></span>
            <span><%= item[1]%></span>
        </a>
        <% } %>
    </nav>

    <!-- Logout -->
    <div class="p-4 border-t border-gray-100 space-y-2">
        <%-- Open/Close toggle --%>
        <%
            Boolean isOpenAttr = (Boolean) session.getAttribute("merchantIsOpen");
            boolean isShopOpen = isOpenAttr == null || isOpenAttr;
        %>
        <form method="POST" action="<%= request.getContextPath()%>/merchant/toggle-open">
            <button type="submit"
                    class="w-full flex items-center justify-between px-3 py-2.5 rounded-xl text-sm font-semibold transition-all
                    <%= isShopOpen ? "bg-green-50 text-green-700 hover:bg-green-100" : "bg-red-50 text-red-600 hover:bg-red-100"%>">
                <span class="flex items-center gap-2">
                    <span class="material-symbols-outlined text-[20px]"><%= isShopOpen ? "store" : "store_mall_directory"%></span>
                    <%= isShopOpen ? "Đang nhận đơn" : "Đã tạm đóng"%>
                </span>
                <span class="relative inline-flex w-10 h-5 shrink-0">
                    <span class="absolute inset-0 rounded-full transition-colors duration-200 <%= isShopOpen ? "bg-green-500" : "bg-gray-300"%>"></span>
                    <span class="absolute top-0.5 h-4 w-4 rounded-full bg-white shadow transition-transform duration-200 <%= isShopOpen ? "translate-x-5" : "translate-x-0.5"%>"></span>
                </span>
            </button>
        </form>
        <a href="${pageContext.request.contextPath}/merchant/logout"
           class="flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium text-gray-600 hover:bg-red-50 hover:text-red-600 transition-all">
            <span class="material-symbols-outlined text-[20px]">logout</span>
            <span>Đăng xuất</span>
        </a>
    </div>
</aside>

<!-- Mobile bottom nav -->
<nav class="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 flex md:hidden z-40 overflow-x-auto">
    <% for (String[] item : navItems) {
        if (item[0].equals("analytics") || item[0].equals("wallet") || item[0].equals("promotions") || item[0].equals("reviews") || item[0].equals("settings")) continue;
        boolean active = item[0].equals(currentPage); %>
    <a href="<%= request.getContextPath() %>/merchant/<%= item[0] %>"
       class="min-w-[72px] flex-1 flex flex-col items-center py-2 gap-0.5 text-[10px] font-medium <%= active ? "text-primary" : "text-gray-400" %>">
        <span class="material-symbols-outlined text-[22px]"><%= item[2] %></span>
        <%= item[1] %>
    </a>
    <% } %>
    <button type="button" onclick="toggleMobileMenu(true)"
            class="min-w-[72px] flex-1 flex flex-col items-center py-2 gap-0.5 text-[10px] font-medium <%= isMobileMoreActive ? "text-primary" : "text-gray-400" %>">
        <span class="relative">
            <span class="material-symbols-outlined text-[22px]">menu</span>
            <span id="mobileNotifBadge" class="absolute -top-1 -right-2 hidden min-w-[16px] h-[16px] px-1 bg-red-500 text-white text-[9px] font-bold rounded-full flex items-center justify-center leading-none"></span>
        </span>
        Thêm
    </button>
</nav>

<!-- Mobile full menu sheet -->
<div id="mobileMenuOverlay" class="hidden fixed inset-0 bg-black/45 z-50 md:hidden">
    <div id="mobileMenuSheet" class="absolute left-0 right-0 bottom-0 bg-white rounded-t-3xl shadow-2xl max-h-[88vh] overflow-hidden translate-y-full transition-transform duration-200">
        <div class="px-5 py-4 border-b border-gray-100 flex items-center justify-between">
            <div>
                <p class="font-black text-gray-900 text-base">Menu Merchant</p>
                <p class="text-xs text-gray-500">${not empty sessionScope.merchantShopName ? sessionScope.merchantShopName : 'Merchant'}</p>
            </div>
            <button type="button" onclick="toggleMobileMenu(false)" class="p-2 rounded-xl text-gray-500 hover:bg-gray-100">
                <span class="material-symbols-outlined">close</span>
            </button>
        </div>

        <div class="p-4 space-y-2 overflow-y-auto max-h-[calc(88vh-72px)]">
            <% for (String[] item : navItems) {
                boolean active = item[0].equals(currentPage); %>
            <a href="<%= request.getContextPath() %>/merchant/<%= item[0] %>"
               onclick="toggleMobileMenu(false)"
               class="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-semibold transition-all <%= active
                   ? "bg-primary text-white shadow-sm shadow-primary/20"
                   : "text-gray-700 hover:bg-gray-50" %>">
                <span class="material-symbols-outlined text-[20px]"><%= item[2] %></span>
                <span><%= item[1] %></span>
            </a>
            <% } %>

            <div class="mt-3 rounded-2xl border border-gray-100 bg-gray-50/70 overflow-hidden">
                <div class="px-4 py-3 flex items-center justify-between border-b border-gray-100">
                    <p class="text-xs font-black text-gray-700 uppercase">Thông báo</p>
                    <button onclick="markAllRead()" class="text-xs text-primary font-semibold hover:underline">Đánh dấu đã đọc</button>
                </div>
                <div id="mobileNotifList" class="max-h-40 overflow-y-auto divide-y divide-gray-100">
                    <p class="text-xs text-gray-400 text-center py-6">Đang tải...</p>
                </div>
            </div>

            <form method="POST" action="<%= request.getContextPath() %>/merchant/toggle-open" class="pt-2">
                <button type="submit"
                        class="w-full flex items-center justify-between px-3 py-2.5 rounded-xl text-sm font-semibold transition-all
                        <%= isShopOpen ? "bg-green-50 text-green-700 hover:bg-green-100" : "bg-red-50 text-red-600 hover:bg-red-100" %>">
                    <span class="flex items-center gap-2">
                        <span class="material-symbols-outlined text-[20px]"><%= isShopOpen ? "store" : "store_mall_directory" %></span>
                        <%= isShopOpen ? "Đang nhận đơn" : "Đã tạm đóng" %>
                    </span>
                    <span class="relative inline-flex w-10 h-5 shrink-0">
                        <span class="absolute inset-0 rounded-full transition-colors duration-200 <%= isShopOpen ? "bg-green-500" : "bg-gray-300" %>"></span>
                        <span class="absolute top-0.5 h-4 w-4 rounded-full bg-white shadow transition-transform duration-200 <%= isShopOpen ? "translate-x-5" : "translate-x-0.5" %>"></span>
                    </span>
                </button>
            </form>

            <a href="${pageContext.request.contextPath}/merchant/logout"
               class="w-full flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-semibold text-gray-700 hover:bg-red-50 hover:text-red-600 transition-all">
                <span class="material-symbols-outlined text-[20px]">logout</span>
                <span>Đăng xuất</span>
            </a>
        </div>
    </div>
</div>
