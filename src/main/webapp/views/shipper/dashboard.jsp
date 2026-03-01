<%-- 
    Document   : dashboard
    Created on : Mar 1, 2026, 1:19:49 PM
    Author     : DELL
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>ClickEat Shipper - Bảng điều khiển</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
        <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script> 
    </head>
    <body class="bg-gray-50 flex h-screen overflow-hidden text-gray-800">

        <aside class="w-64 bg-white border-r border-gray-200 flex flex-col justify-between hidden md:flex">
            <div>
                <div class="h-20 flex items-center px-6 border-b border-gray-100">
                    <div class="w-10 h-10 bg-orange-500 rounded-xl flex items-center justify-center mr-3 shadow-sm">
                        <i class="fa-solid fa-motorcycle text-white text-lg"></i>
                    </div>
                    <div>
                        <h1 class="font-black text-xl text-gray-900 leading-tight">ClickEat</h1>
                        <p class="text-xs font-bold text-orange-500 tracking-widest uppercase">Shipper</p>
                    </div>
                </div>

                <nav class="p-4 space-y-2">
                    <button onclick="switchTab('overview')" id="nav-overview" class="w-full flex items-center gap-3 px-4 py-3 bg-orange-50 text-orange-600 rounded-xl font-bold transition-colors">
                        <i class="fa-solid fa-chart-pie w-5"></i> Tổng quan
                    </button>
                    <button onclick="switchTab('orders')" id="nav-orders" class="w-full flex items-center gap-3 px-4 py-3 text-gray-600 hover:bg-gray-50 hover:text-gray-900 rounded-xl font-medium transition-colors">
                        <i class="fa-solid fa-box w-5"></i> Đơn hàng
                    </button>
                    <button class="w-full flex items-center gap-3 px-4 py-3 text-gray-600 hover:bg-gray-50 hover:text-gray-900 rounded-xl font-medium transition-colors">
                        <i class="fa-solid fa-triangle-exclamation w-5"></i> Báo cáo sự cố
                    </button>
                    <button class="w-full flex items-center gap-3 px-4 py-3 text-gray-600 hover:bg-gray-50 hover:text-gray-900 rounded-xl font-medium transition-colors">
                        <i class="fa-solid fa-user w-5"></i> Hồ sơ
                    </button>
                </nav>
            </div>

            <div class="p-6 border-t border-gray-100 bg-gray-50/50">
                <div class="flex items-center justify-between mb-2">
                    <span class="font-bold text-gray-700 text-sm">Trạng thái nhận đơn</span>
                </div>
                <label class="relative inline-flex items-center cursor-pointer w-full justify-between bg-white p-3 rounded-xl border border-gray-200 shadow-sm">
                    <div class="flex items-center gap-2" id="status-text-container">
                        <span id="status-dot" class="w-3 h-3 rounded-full bg-red-500"></span>
                        <span id="status-text" class="text-sm font-bold text-red-600">Ngoại tuyến</span>
                    </div>
                    <input type="checkbox" id="toggle-online" class="sr-only peer" ${isOnline ? 'checked' : ''}>
                    <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[14px] after:right-[50px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-green-500"></div>
                </label>
            </div>
        </aside>

        <main class="flex-1 flex flex-col h-screen overflow-y-auto relative">
            <header class="h-20 bg-white flex items-center justify-between px-8 border-b border-gray-200 sticky top-0 z-10">
                <h2 id="header-title" class="text-2xl font-bold text-gray-900">Tổng quan thu nhập</h2>
                <div class="flex items-center gap-4">
                    <div class="text-right">
                        <p class="text-sm font-bold text-gray-900">${sessionScope.account.fullName}</p>
                        <p class="text-xs text-gray-500">ID: SP-${sessionScope.account.id}</p>
                    </div>
                    <div class="w-10 h-10 bg-gray-200 rounded-full flex items-center justify-center overflow-hidden border-2 border-orange-500">
                        <i class="fa-solid fa-user text-gray-400"></i>
                    </div>
                </div>
            </header>

            <div class="p-8 relative">

                <div id="tab-overview" class="block">
                    <div class="bg-gradient-to-r from-gray-900 to-gray-800 rounded-3xl p-8 text-white shadow-xl mb-8 flex flex-col md:flex-row justify-between items-center gap-6">
                        <div>
                            <p class="text-gray-400 font-medium mb-1">Số dư hiện tại</p>
                            <h3 class="text-4xl font-black text-orange-400">
                                <fmt:formatNumber value="${currentBalance}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                            </h3>
                        </div>
                        <button class="bg-orange-500 hover:bg-orange-600 text-white px-8 py-3.5 rounded-xl font-bold text-lg transition-colors shadow-lg shadow-orange-500/30 flex items-center gap-2">
                            <i class="fa-solid fa-wallet"></i> Rút tiền ngay
                        </button>
                    </div>
                </div>

                <div id="tab-orders" class="hidden">

                    <div id="offline-warning" class="${isOnline ? 'hidden' : 'bg-white rounded-2xl border border-gray-200 p-10 text-center shadow-sm'}">
                        <div class="w-20 h-20 bg-gray-100 rounded-full flex items-center justify-center mx-auto mb-4">
                            <i class="fa-solid fa-moon text-4xl text-gray-400"></i>
                        </div>
                        <h3 class="text-xl font-bold text-gray-900 mb-2">Bạn đang Ngoại tuyến</h3>
                        <p class="text-gray-500 mb-6">Vui lòng bật trạng thái Trực tuyến để hệ thống bắt đầu phát đơn hàng cho bạn.</p>
                    </div>

                    <div id="online-orders" class="${isOnline ? 'block' : 'hidden'}">
                        <div class="flex justify-between items-center mb-6">
                            <h3 class="text-xl font-bold text-gray-900 flex items-center gap-2">
                                <i class="fa-solid fa-radar text-green-500 animate-spin-slow"></i> Đơn hàng quanh bạn
                            </h3>
                            <span class="bg-orange-100 text-orange-600 px-3 py-1 rounded-full text-xs font-bold">
                                Tìm thấy ${availableOrders.size()} đơn
                            </span>
                        </div>

                        <c:if test="${empty availableOrders}">
                            <div class="text-center py-10">
                                <i class="fa-solid fa-mug-hot text-4xl text-gray-300 mb-4"></i>
                                <p class="text-gray-500 font-medium">Hiện tại chưa có đơn hàng nào mới.</p>
                            </div>
                        </c:if>

                        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                            <c:forEach var="order" items="${availableOrders}">
                                <c:set var="merchant" value="${merchantDAO.findById(order.merchantId)}" />

                                <div class="bg-white rounded-2xl border border-gray-200 shadow-sm hover:border-orange-500 transition-colors p-5">
                                    <div class="flex justify-between items-start mb-4 border-b border-gray-100 pb-4">
                                        <div>
                                            <h4 class="font-bold text-lg text-gray-900">${merchant.shopName}</h4>
                                            <p class="text-sm text-gray-500 line-clamp-1">${merchant.shopAddressLine}</p>
                                            <p class="text-xs font-bold text-gray-400 mt-1">Mã: ${order.orderCode}</p>
                                        </div>
                                        <div class="text-right shrink-0">
                                            <p class="text-2xl font-black text-orange-500">
                                                <fmt:formatNumber value="${order.deliveryFee}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                            </p>
                                            <p class="text-xs text-gray-500">Phí giao hàng</p>
                                        </div>
                                    </div>

                                    <div class="flex items-center justify-between mb-6 text-sm">
                                        <div class="flex items-center gap-2 text-gray-700">
                                            <div class="w-8 h-8 bg-blue-50 text-blue-500 rounded-full flex items-center justify-center"><i class="fa-solid fa-location-dot"></i></div>
                                            <span class="font-bold">Giao đến:</span> <span class="text-gray-600 line-clamp-1">${order.deliveryAddressLine}</span>
                                        </div>
                                    </div>

                                    <a href="${pageContext.request.contextPath}/shipper/order-detail?id=${order.id}" class="block text-center w-full bg-orange-500 hover:bg-orange-600 text-white font-bold py-3 rounded-xl transition-colors shadow-md">
                                        Xem & Nhận Đơn
                                    </a>
                                </div>
                            </c:forEach>
                        </div>
                    </div>

                </div>

            </div>
        </main>

        <script>
            // Xử lý chuyển Tab
            function switchTab(tabName) {
                // Ẩn tất cả nội dung
                document.getElementById('tab-overview').classList.add('hidden');
                document.getElementById('tab-orders').classList.add('hidden');
                // Reset màu menu
                document.getElementById('nav-overview').className = "w-full flex items-center gap-3 px-4 py-3 text-gray-600 hover:bg-gray-50 hover:text-gray-900 rounded-xl font-medium transition-colors";
                document.getElementById('nav-orders').className = "w-full flex items-center gap-3 px-4 py-3 text-gray-600 hover:bg-gray-50 hover:text-gray-900 rounded-xl font-medium transition-colors";

                if (tabName === 'overview') {
                    document.getElementById('tab-overview').classList.remove('hidden');
                    document.getElementById('nav-overview').className = "w-full flex items-center gap-3 px-4 py-3 bg-orange-50 text-orange-600 rounded-xl font-bold transition-colors";
                    document.getElementById('header-title').innerText = "Tổng quan thu nhập";
                } else if (tabName === 'orders') {
                    document.getElementById('tab-orders').classList.remove('hidden');
                    document.getElementById('nav-orders').className = "w-full flex items-center gap-3 px-4 py-3 bg-orange-50 text-orange-600 rounded-xl font-bold transition-colors";
                    document.getElementById('header-title').innerText = "Quản lý Đơn hàng";
                }
            }

            // Xử lý nút gạt Online/Offline bằng AJAX
            $('#toggle-online').change(function () {
                var isOnline = $(this).is(':checked');

                $.ajax({
                    url: '${pageContext.request.contextPath}/shipper/toggle-status',
                    type: 'POST',
                    data: {isOnline: isOnline},
                    success: function (response) {
                        if (isOnline) {
                            // Đổi giao diện nút gạt sang Online
                            $('#status-dot').removeClass('bg-red-500').addClass('bg-green-500 animate-pulse');
                            $('#status-text').removeClass('text-red-600').addClass('text-green-600').text('Trực tuyến');
                            // Hiện danh sách đơn
                            $('#offline-warning').addClass('hidden');
                            $('#online-orders').removeClass('hidden');
                        } else {
                            // Đổi giao diện nút gạt sang Offline
                            $('#status-dot').removeClass('bg-green-500 animate-pulse').addClass('bg-red-500');
                            $('#status-text').removeClass('text-green-600').addClass('text-red-600').text('Ngoại tuyến');
                            // Ẩn danh sách đơn
                            $('#offline-warning').removeClass('hidden');
                            $('#online-orders').addClass('hidden');
                        }
                    },
                    error: function () {
                        alert("Lỗi kết nối máy chủ! Không thể đổi trạng thái.");
                        $('#toggle-online').prop('checked', !isOnline); // Hoàn tác thao tác gạt
                    }
                });
            });
        </script>
        <c:if test="${not empty sessionScope.toastMsg}">
            <div id="toast-success" class="fixed top-5 right-5 bg-green-500 text-white px-6 py-4 rounded-xl shadow-2xl z-50 flex items-center gap-3 animate-bounce">
                <i class="fa-solid fa-circle-check text-xl"></i>
                <span class="font-medium">${sessionScope.toastMsg}</span>
            </div>
            <c:remove var="toastMsg" scope="session" />
            <script>setTimeout(() => document.getElementById('toast-success').style.display = 'none', 3000);</script>
        </c:if>

        <c:if test="${not empty sessionScope.toastError}">
            <div id="toast-error" class="fixed top-5 right-5 bg-red-500 text-white px-6 py-4 rounded-xl shadow-2xl z-50 flex items-center gap-3 animate-bounce">
                <i class="fa-solid fa-triangle-exclamation text-xl"></i>
                <span class="font-medium">${sessionScope.toastError}</span>
            </div>
            <c:remove var="toastError" scope="session" />
            <script>setTimeout(() => document.getElementById('toast-error').style.display = 'none', 4000);</script>
        </c:if>
    </body>
</html>
