<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>ClickEat Shipper - Bảng điều khiển</title>
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
        <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        <style>body { font-family: 'Inter', sans-serif; }</style>
    </head>
    <body class="bg-gray-50 flex h-screen overflow-hidden text-gray-800">

        <aside class="w-64 bg-white border-r border-gray-200 flex flex-col justify-between hidden md:flex z-20">
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
                    <button onclick="switchTab('history')" id="nav-history" class="w-full flex items-center gap-3 px-4 py-3 text-gray-600 hover:bg-gray-50 hover:text-gray-900 rounded-xl font-medium transition-colors">
                        <i class="fa-solid fa-clock-rotate-left w-5"></i> Lịch sử giao hàng
                    </button>
                    <button onclick="switchTab('issues')" id="nav-issues" class="w-full flex items-center gap-3 px-4 py-3 text-gray-600 hover:bg-gray-50 hover:text-gray-900 rounded-xl font-medium transition-colors">
                        <i class="fa-solid fa-triangle-exclamation w-5"></i> Báo cáo sự cố
                    </button>
                    <a href="${pageContext.request.contextPath}/shipper/profile" class="w-full flex items-center gap-3 px-4 py-3 text-gray-600 hover:bg-gray-50 hover:text-gray-900 rounded-xl font-medium transition-colors">
                        <i class="fa-solid fa-user w-5"></i> Hồ sơ
                    </a>
                </nav>
            </div>
            <div class="p-6 border-t border-gray-100 bg-white">
                <label class="block text-xs font-bold text-gray-500 uppercase mb-2">Vị trí hiện tại của bạn</label>
                <div class="flex gap-2">
                    <input type="text" id="shipper-address" placeholder="VD: Phường Diên Hồng, Pleiku..." class="w-full text-sm border border-gray-200 rounded-xl px-3 py-2 focus:outline-none focus:border-orange-500 shadow-sm">
                    <button type="button" onclick="updateLocationFromAddress()" class="bg-blue-500 text-white px-4 py-2 rounded-xl hover:bg-blue-600 transition shadow-sm flex items-center justify-center shrink-0">
                        <i class="fa-solid fa-location-crosshairs"></i>
                    </button>
                </div>
                <p id="location-status" class="text-xs text-gray-400 mt-2 font-medium"></p>
            </div>
            <div class="p-6 border-t border-gray-100 bg-gray-50/50">
                <div class="flex items-center justify-between mb-2">
                    <span class="font-bold text-gray-700 text-sm">Trạng thái nhận đơn</span>
                </div>
                <label class="relative inline-flex items-center cursor-pointer w-full justify-between bg-white p-3 rounded-xl border border-gray-200 shadow-sm">
                    <div class="flex items-center gap-2" id="status-text-container">
                        <span id="status-dot" class="w-3 h-3 rounded-full ${isOnline ? 'bg-green-500 animate-pulse' : 'bg-red-500'}"></span>
                        <span id="status-text" class="text-sm font-bold ${isOnline ? 'text-green-600' : 'text-red-600'}">
                            ${isOnline ? 'Trực tuyến' : 'Ngoại tuyến'}
                        </span>
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
                        <div class="text-xs font-bold text-orange-500 mt-0.5">
                            <i class="fa-solid fa-star text-yellow-400"></i> ${avgRating > 0 ? avgRating : '5.0'} (${totalReviews != null ? totalReviews : 0} đánh giá)
                        </div>
                        <p class="text-xs text-gray-500 mt-0.5">ID: SP-${sessionScope.account.id}</p>
                    </div>

                    <div class="w-10 h-10 bg-orange-100 rounded-full flex items-center justify-center overflow-hidden border-2 border-orange-500">
                        <c:choose>
                            <c:when test="${not empty sessionScope.account.avatarUrl}">
                                <img src="${sessionScope.account.avatarUrl}" alt="Avatar" class="w-full h-full object-cover">
                            </c:when>
                            <c:otherwise>
                                <i class="fa-solid fa-user-astronaut text-orange-400"></i>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <a href="${pageContext.request.contextPath}/logout" 
                       class="w-10 h-10 bg-red-50 text-red-500 hover:bg-red-500 hover:text-white rounded-full flex items-center justify-center transition-colors shadow-sm border border-red-100" 
                       title="Đăng xuất">
                        <i class="fa-solid fa-right-from-bracket"></i>
                    </a>
                </div>
            </header>

            <div class="p-8 relative">

                <div id="tab-overview" class="block">
                    <div class="bg-gradient-to-r from-gray-900 to-gray-800 rounded-3xl p-8 text-white shadow-xl mb-6 flex flex-col md:flex-row justify-between items-center gap-6">
                        <div>
                            <p class="text-gray-400 font-medium mb-1">Số dư hiện tại</p>
                            <h3 class="text-4xl font-black text-orange-400">
                                <fmt:formatNumber value="${currentBalance}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                            </h3>
                        </div>
                        <button onclick="openWithdrawModal()" class="bg-orange-500 hover:bg-orange-600 text-white px-8 py-3.5 rounded-xl font-bold text-lg transition-colors shadow-lg shadow-orange-500/30 flex items-center gap-2">
                            <i class="fa-solid fa-wallet"></i> Rút tiền ngay
                        </button>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                        <div class="bg-white p-5 rounded-2xl shadow-sm border border-gray-100 flex items-center gap-4 border-b-4 border-green-500">
                            <div class="w-12 h-12 bg-green-50 text-green-500 rounded-xl flex items-center justify-center text-xl">
                                <i class="fa-solid fa-check-double"></i>
                            </div>
                            <div>
                                <p class="text-gray-500 font-medium text-xs uppercase tracking-wider">Hoàn thành hôm nay</p>
                                <p class="text-2xl font-black text-gray-900">${todayOrders} <span class="text-sm font-medium text-gray-500">đơn</span></p>
                            </div>
                        </div>

                        <div class="bg-white p-5 rounded-2xl shadow-sm border border-gray-100 flex items-center gap-4 border-b-4 border-orange-500">
                            <div class="w-12 h-12 bg-orange-50 text-orange-500 rounded-xl flex items-center justify-center text-xl">
                                <i class="fa-solid fa-sack-dollar"></i>
                            </div>
                            <div>
                                <p class="text-gray-500 font-medium text-xs uppercase tracking-wider">Thu nhập hôm nay</p>
                                <p class="text-2xl font-black text-gray-900"><fmt:formatNumber value="${todayIncome}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></p>
                            </div>
                        </div>

                        <div class="bg-white p-5 rounded-2xl shadow-sm border border-gray-100 flex items-center gap-4 border-b-4 border-blue-500">
                            <div class="w-12 h-12 bg-blue-50 text-blue-500 rounded-xl flex items-center justify-center text-xl">
                                <i class="fa-solid fa-calendar-week"></i>
                            </div>
                            <div>
                                <p class="text-gray-500 font-medium text-xs uppercase tracking-wider">Thu nhập tuần này</p>
                                <p class="text-2xl font-black text-gray-900"><fmt:formatNumber value="${weekIncome}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></p>
                            </div>
                        </div>
                    </div>

                    <div class="bg-white p-6 rounded-3xl shadow-sm border border-gray-100 mb-8">
                        <h3 class="font-bold text-gray-900 mb-6 flex items-center gap-2">
                            <i class="fa-solid fa-chart-column text-orange-500"></i> BIỂU ĐỒ THU NHẬP 7 NGÀY QUA
                        </h3>
                        <div class="relative h-64 w-full">
                            <canvas id="incomeChart"></canvas>
                        </div>
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

                        <c:if test="${not empty currentOrders}">
                            <div class="mb-8">
                                <h3 class="text-lg font-black text-gray-900 mb-4 flex items-center gap-2">
                                    <span class="relative flex h-3 w-3">
                                        <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-orange-400 opacity-75"></span>
                                        <span class="relative inline-flex rounded-full h-3 w-3 bg-orange-500"></span>
                                    </span>
                                    ĐƠN HÀNG ĐANG THỰC HIỆN
                                </h3>

                                <div class="space-y-4">
                                    <c:forEach var="currOrder" items="${currentOrders}">
                                        <c:set var="currMerchant" value="${merchantDAO.findById(currOrder.merchantId)}" />

                                        <div class="bg-white rounded-2xl p-4 shadow-sm border-l-4 border-orange-500 flex flex-col md:flex-row justify-between items-center gap-4 hover:shadow-md transition">

                                            <div class="flex-1 w-full">
                                                <div class="flex justify-between items-start mb-1">
                                                    <h4 class="font-bold text-lg text-gray-900 line-clamp-1">${currMerchant.shopName}</h4>
                                                    <span class="text-xs font-bold px-2 py-1 rounded bg-orange-100 text-orange-600 shrink-0">
                                                        Mã: ${currOrder.orderCode}
                                                    </span>
                                                </div>
                                                <p class="text-sm text-gray-500 mb-2 line-clamp-1">
                                                    <i class="fa-solid fa-location-dot text-gray-400 w-4"></i> Giao đến: <span class="font-medium text-gray-700">${currOrder.receiverName}</span>
                                                </p>
                                                <div class="flex items-center gap-3 text-sm font-bold">
                                                    <span class="text-orange-500"><fmt:formatNumber value="${currOrder.deliveryFee}" type="currency" currencySymbol="đ" maxFractionDigits="0"/> phí ship</span>
                                                    <span class="text-gray-300">|</span>
                                                    <span class="${currOrder.orderStatus == 'DELIVERING' ? 'text-blue-500' : 'text-green-500'}">
                                                        <i class="${currOrder.orderStatus == 'DELIVERING' ? 'fa-solid fa-store' : 'fa-solid fa-motorcycle'} mr-1"></i>
                                                        ${currOrder.orderStatus == 'DELIVERING' ? 'Đang đến quán' : 'Đang giao khách'}
                                                    </span>
                                                </div>
                                            </div>

                                            <div class="flex flex-row md:flex-col gap-2 w-full md:w-32 shrink-0">
                                                <a href="${pageContext.request.contextPath}/shipper/order-detail?id=${currOrder.id}" class="flex-1 md:flex-none bg-orange-50 hover:bg-orange-100 text-orange-600 font-bold py-2.5 px-4 rounded-xl text-center transition text-sm">
                                                    Xem chi tiết
                                                </a>
                                                <a href="${pageContext.request.contextPath}/shipper/order-tracking?id=${currOrder.id}" class="flex-1 md:flex-none bg-green-500 hover:bg-green-600 text-white font-bold py-2.5 px-4 rounded-xl text-center transition shadow-sm text-sm">
                                                    Cập nhật
                                                </a>
                                            </div>

                                        </div>
                                    </c:forEach>
                                </div>
                            </div>
                        </c:if>
                        <div class="flex justify-between items-center mb-6 mt-4">
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

                <div id="tab-history" class="hidden">
                    <div class="mb-6">
                        <h3 class="text-xl font-bold text-gray-900 flex items-center gap-2">
                            <i class="fa-solid fa-clock-rotate-left text-blue-500"></i> Lịch sử giao hàng
                        </h3>
                        <p class="text-sm text-gray-500 mt-1">Các đơn hàng bạn đã hoàn thành hoặc bị hủy.</p>
                    </div>

                    <c:if test="${empty historyOrders}">
                        <div class="text-center py-10 bg-white rounded-2xl border border-gray-200">
                            <p class="text-gray-500 font-medium">Bạn chưa có lịch sử giao hàng nào.</p>
                        </div>
                    </c:if>

                    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                        <c:forEach var="histOrder" items="${historyOrders}">
                            <div class="bg-white rounded-2xl p-4 shadow-sm border ${histOrder.orderStatus == 'DELIVERED' ? 'border-green-200 border-l-4 border-l-green-500' : 'border-red-200 border-l-4 border-l-red-500'}">
                                <div class="flex justify-between items-start mb-2">
                                    <span class="text-xs font-bold px-2 py-1 rounded ${histOrder.orderStatus == 'DELIVERED' ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}">
                                        ${histOrder.orderStatus == 'DELIVERED' ? 'Hoàn thành' : 'Đã hủy'}
                                    </span>
                                    <span class="text-xs text-gray-400 font-medium"><fmt:formatDate value="${histOrder.createdAt}" pattern="dd/MM HH:mm"/></span>
                                </div>
                                <h4 class="font-bold text-gray-900 line-clamp-1">${histOrder.receiverName}</h4>
                                <p class="text-sm text-gray-500 mb-3 line-clamp-1">${histOrder.deliveryAddressLine}</p>
                                <div class="flex justify-between items-center border-t border-gray-100 pt-3">
                                    <span class="text-xs text-gray-400 font-bold">Mã: ${histOrder.orderCode}</span>
                                    <span class="font-black text-gray-900"><fmt:formatNumber value="${histOrder.deliveryFee}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></span>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <div id="tab-issues" class="hidden">
                    <div class="mb-6">
                        <h3 class="text-xl font-bold text-gray-900 flex items-center gap-2">
                            <i class="fa-solid fa-clock-rotate-left text-red-500"></i> Lịch sử Báo cáo Sự cố
                        </h3>
                        <p class="text-sm text-gray-500 mt-1">Theo dõi các đơn hàng bạn đã báo cáo lỗi.</p>
                    </div>

                    <c:if test="${empty reportedIssues}">
                        <div class="bg-white rounded-2xl border border-gray-200 p-10 text-center shadow-sm">
                            <i class="fa-solid fa-check-circle text-5xl text-green-400 mb-4"></i>
                            <h3 class="text-lg font-bold text-gray-900">Tuyệt vời!</h3>
                            <p class="text-gray-500">Bạn chưa gặp sự cố nào trong quá trình giao hàng.</p>
                        </div>
                    </c:if>

                    <div class="space-y-4">
                        <c:forEach var="issue" items="${reportedIssues}">
                            <div class="bg-white rounded-2xl border border-gray-200 shadow-sm overflow-hidden transition-all">
                                <div class="p-5 flex justify-between items-center cursor-pointer hover:bg-gray-50 transition" onclick="toggleIssueDetail(${issue.id})">
                                    <div class="flex items-center gap-4">
                                        <div class="w-10 h-10 bg-red-50 text-red-500 rounded-full flex items-center justify-center">
                                            <i class="fa-solid fa-triangle-exclamation"></i>
                                        </div>
                                        <div>
                                            <h4 class="font-bold text-gray-900 text-lg">Đơn hàng: ORD-00${issue.orderId}</h4>
                                            <p class="text-sm text-gray-500 mt-1">Ngày báo cáo: <fmt:formatDate value="${issue.createdAt}" pattern="dd/MM/yyyy HH:mm"/></p>
                                        </div>
                                    </div>
                                    <div class="flex items-center gap-3">
                                        <span class="px-3 py-1 rounded-full text-xs font-bold ${issue.status == 'PENDING' ? 'bg-yellow-100 text-yellow-600' : 'bg-green-100 text-green-600'}">
                                            ${issue.status == 'PENDING' ? 'Đang chờ xử lý' : 'Đã giải quyết'}
                                        </span>
                                        <i class="fa-solid fa-chevron-down text-gray-400 transition-transform duration-300" id="icon-issue-${issue.id}"></i>
                                    </div>
                                </div>
                                <div id="detail-issue-${issue.id}" class="hidden p-5 border-t border-gray-100 bg-gray-50 text-sm">
                                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                        <div>
                                            <p class="text-gray-500 mb-1">Loại sự cố:</p>
                                            <p class="font-bold text-red-600">${issue.issueType}</p>
                                        </div>
                                        <div>
                                            <p class="text-gray-500 mb-1">Mô tả chi tiết:</p>
                                            <p class="font-medium text-gray-800">${not empty issue.description ? issue.description : 'Không có ghi chú thêm.'}</p>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>

            </div>
        </main>
        <div id="withdraw-modal" class="fixed inset-0 bg-black/60 z-50 hidden flex items-center justify-center backdrop-blur-sm">
            <div class="bg-white rounded-3xl w-full max-w-md p-8 shadow-2xl relative">
                <button onclick="closeWithdrawModal()" class="absolute top-4 right-4 text-gray-400 hover:text-gray-800 transition text-2xl"><i class="fa-solid fa-xmark"></i></button>

                <div class="text-center mb-6">
                    <div class="w-16 h-16 bg-orange-100 text-orange-500 rounded-full flex items-center justify-center text-3xl mx-auto mb-3"><i class="fa-solid fa-money-bill-transfer"></i></div>
                    <h3 class="text-2xl font-black text-gray-900">Yêu cầu rút tiền</h3>
                    <p class="text-gray-500 mt-1">Số dư khả dụng: <b class="text-orange-500"><fmt:formatNumber value="${currentBalance}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></b></p>
                </div>

                <form action="${pageContext.request.contextPath}/shipper/withdraw" method="POST">
                    <div class="mb-4">
                        <label class="block text-sm font-bold text-gray-700 mb-1">Số tiền cần rút (VNĐ) <span class="text-red-500">*</span></label>
                        <input type="number" name="amount" min="50000" max="${currentBalance}" required placeholder="Tối thiểu 50.000đ" class="w-full bg-gray-50 border border-gray-200 rounded-xl p-3 focus:outline-none focus:ring-2 focus:ring-orange-500 transition">
                    </div>
                    <div class="mb-4">
                        <label class="block text-sm font-bold text-gray-700 mb-1">Ngân hàng thụ hưởng <span class="text-red-500">*</span></label>
                        <input type="text" name="bankName" required placeholder="VD: MB Bank, Vietcombank..." class="w-full bg-gray-50 border border-gray-200 rounded-xl p-3 focus:outline-none focus:ring-2 focus:ring-orange-500 transition">
                    </div>
                    <div class="mb-6">
                        <label class="block text-sm font-bold text-gray-700 mb-1">Số tài khoản <span class="text-red-500">*</span></label>
                        <input type="text" name="bankAccountNumber" required placeholder="Nhập chính xác số tài khoản" class="w-full bg-gray-50 border border-gray-200 rounded-xl p-3 focus:outline-none focus:ring-2 focus:ring-orange-500 transition tracking-wider font-medium">
                    </div>

                    <button type="submit" onclick="confirmAction(event, 'Xác nhận thông tin chính xác và gửi yêu cầu?', this);" class="w-full bg-orange-500 hover:bg-orange-600 text-white font-bold py-3.5 rounded-xl transition shadow-lg shadow-orange-500/30">
                        Gửi Yêu Cầu
                    </button>
                </form>
            </div>
        </div>
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
        <audio id="newOrderSound" src="https://actions.google.com/sounds/v1/alarms/beep_short.ogg" preload="auto"></audio>

        <div id="new-order-popup" class="fixed top-5 left-1/2 transform -translate-x-1/2 bg-blue-600 text-white px-6 py-4 rounded-full shadow-2xl z-[100] flex items-center gap-4 transition-all duration-500 translate-y-[-150%]">
            <div class="w-10 h-10 bg-white/20 rounded-full flex items-center justify-center animate-[spin_3s_linear_infinite]">
                <i class="fa-solid fa-bell text-xl"></i>
            </div>
            <div>
                <h4 class="font-bold text-lg">Có đơn hàng mới!</h4>
                <p class="text-sm text-blue-100">Hệ thống vừa tìm thấy đơn hàng quanh khu vực của bạn.</p>
            </div>
            <button onclick="location.reload()" class="bg-white text-blue-600 font-bold px-5 py-2 rounded-full hover:bg-gray-100 transition shadow-sm ml-4">
                Tải lại trang ngay
            </button>
        </div>
        <div id="custom-confirm-modal" class="fixed inset-0 bg-black/60 z-[100] hidden flex items-center justify-center backdrop-blur-sm transition-opacity">
            <div class="bg-white rounded-3xl w-full max-w-sm p-6 shadow-2xl relative text-center transform transition-all scale-95 opacity-0 duration-200" id="confirm-modal-content">
                <div class="w-16 h-16 bg-orange-100 text-orange-500 rounded-full flex items-center justify-center text-3xl mx-auto mb-4">
                    <i class="fa-solid fa-circle-exclamation animate-pulse"></i>
                </div>
                <h3 class="text-xl font-black text-gray-900 mb-2">Xác nhận hành động</h3>
                <p id="confirm-message" class="text-gray-500 mb-6 font-medium">Bạn có chắc chắn không?</p>

                <div class="flex gap-3">
                    <button onclick="closeConfirmModal()" type="button" class="flex-1 bg-gray-100 hover:bg-gray-200 text-gray-700 font-bold py-3 rounded-xl transition">Hủy bỏ</button>
                    <button onclick="executeConfirm()" type="button" class="flex-1 bg-orange-500 hover:bg-orange-600 text-white font-bold py-3 rounded-xl transition shadow-md">Xác nhận</button>
                </div>
            </div>
        </div>
        <script>
            // Hàm chuyển Tab
            function switchTab(tabName) {
                // Ẩn tất cả nội dung
                document.getElementById('tab-overview').classList.add('hidden');
                document.getElementById('tab-orders').classList.add('hidden');
                document.getElementById('tab-history').classList.add('hidden'); // Ẩn tab lịch sử
                document.getElementById('tab-issues').classList.add('hidden');

                // Reset CSS các nút menu
                const normalClass = "w-full flex items-center gap-3 px-4 py-3 text-gray-600 hover:bg-gray-50 hover:text-gray-900 rounded-xl font-medium transition-colors";
                const activeClass = "w-full flex items-center gap-3 px-4 py-3 bg-orange-50 text-orange-600 rounded-xl font-bold transition-colors";

                document.getElementById('nav-overview').className = normalClass;
                document.getElementById('nav-orders').className = normalClass;
                document.getElementById('nav-history').className = normalClass; // Đặt về bình thường
                document.getElementById('nav-issues').className = normalClass;

                // Bật nội dung tương ứng
                if (tabName === 'overview') {
                    document.getElementById('tab-overview').classList.remove('hidden');
                    document.getElementById('nav-overview').className = activeClass;
                    document.getElementById('header-title').innerText = "Tổng quan thu nhập";
                } else if (tabName === 'orders') {
                    document.getElementById('tab-orders').classList.remove('hidden');
                    document.getElementById('nav-orders').className = activeClass;
                    document.getElementById('header-title').innerText = "Quản lý Đơn hàng";
                } else if (tabName === 'history') { // Thêm logic cho History
                    document.getElementById('tab-history').classList.remove('hidden');
                    document.getElementById('nav-history').className = activeClass;
                    document.getElementById('header-title').innerText = "Lịch sử giao hàng";
                } else if (tabName === 'issues') {
                    document.getElementById('tab-issues').classList.remove('hidden');
                    document.getElementById('nav-issues').className = activeClass;
                    document.getElementById('header-title').innerText = "Quản lý Báo cáo";
                }
            }

            document.addEventListener('DOMContentLoaded', function () {
                const activeTab = '${activeTab}';
                if (activeTab) {
                    switchTab(activeTab);
                }
            });

            // Hàm ẩn/hiện chi tiết Sự cố
            function toggleIssueDetail(issueId) {
                const detailDiv = document.getElementById('detail-issue-' + issueId);
                const icon = document.getElementById('icon-issue-' + issueId);

                if (detailDiv.classList.contains('hidden')) {
                    detailDiv.classList.remove('hidden');
                    icon.style.transform = "rotate(180deg)"; // Xoay mũi tên lên
                } else {
                    detailDiv.classList.add('hidden');
                    icon.style.transform = "rotate(0deg)"; // Xoay mũi tên xuống
                }
            }

            // AJAX Nút gạt Online / Offline
            $('#toggle-online').change(function () {
                var isOnline = $(this).is(':checked');
                $.ajax({
                    url: '${pageContext.request.contextPath}/shipper/toggle-status',
                    type: 'POST',
                    data: {isOnline: isOnline},
                    success: function (response) {
                        if (isOnline) {
                            $('#status-dot').removeClass('bg-red-500').addClass('bg-green-500 animate-pulse');
                            $('#status-text').removeClass('text-red-600').addClass('text-green-600').text('Trực tuyến');
                            $('#offline-warning').addClass('hidden');
                            $('#online-orders').removeClass('hidden');
                        } else {
                            $('#status-dot').removeClass('bg-green-500 animate-pulse').addClass('bg-red-500');
                            $('#status-text').removeClass('text-green-600').addClass('text-red-600').text('Ngoại tuyến');
                            $('#offline-warning').removeClass('hidden');
                            $('#online-orders').addClass('hidden');
                        }
                    },
                    error: function () {
                        alert("Lỗi kết nối! Vui lòng thử lại.");
                        $('#toggle-online').prop('checked', !isOnline); // Hoàn tác thao tác gạt nếu lỗi
                    }
                });
            });

            // Hàm chuyển đổi Địa chỉ thành Tọa độ (Geocoding)
            function updateLocationFromAddress() {
                const address = document.getElementById('shipper-address').value.trim();
                const statusText = document.getElementById('location-status');

                if (!address) {
                    statusText.innerHTML = '<span class="text-red-500"><i class="fa-solid fa-circle-exclamation"></i> Vui lòng nhập địa chỉ!</span>';
                    return;
                }

                statusText.innerHTML = '<span class="text-blue-500"><i class="fa-solid fa-spinner fa-spin"></i> Đang tìm tọa độ...</span>';

                // Gọi API Nominatim của OpenStreetMap
                // Thêm đuôi "Vietnam" để API ưu tiên tìm ở VN cho chính xác
                const searchQuery = encodeURIComponent(address + ", Vietnam");
                const url = `https://nominatim.openstreetmap.org/search?format=json&q=\${searchQuery}&limit=1`;

                fetch(url)
                        .then(response => response.json())
                        .then(data => {
                            if (data && data.length > 0) {
                                const lat = data[0].lat;
                                const lng = data[0].lon;

                                statusText.innerHTML = `<span class="text-green-500"><i class="fa-solid fa-circle-check"></i> Đã ghim: \${parseFloat(lat).toFixed(4)}, \${parseFloat(lng).toFixed(4)}</span>`;

                                // TODO: Gửi tọa độ này về Backend để lưu vào Database
                                // saveLocationToDatabase(lat, lng);

                                alert(`Tuyệt vời! Hệ thống đã xác định bạn đang ở tọa độ:\nVĩ độ: \${lat}\nKinh độ: \${lng}`);
                            } else {
                                statusText.innerHTML = '<span class="text-red-500"><i class="fa-solid fa-triangle-exclamation"></i> Không tìm thấy địa chỉ này!</span>';
                            }
                        })
                        .catch(error => {
                            console.error("Lỗi API: ", error);
                            statusText.innerHTML = '<span class="text-red-500"><i class="fa-solid fa-wifi"></i> Lỗi kết nối mạng!</span>';
                        });
            }
            // Hàm mở/đóng Modal Rút tiền
            function openWithdrawModal() {
                const balance = ${currentBalance != null ? currentBalance : 0};
                if (balance < 50000) {
                    alert("Số dư phải từ 50.000đ trở lên mới có thể rút!");
                    return;
                }
                document.getElementById('withdraw-modal').classList.remove('hidden');
            }
            function closeWithdrawModal() {
                document.getElementById('withdraw-modal').classList.add('hidden');
            }
        </script>
        <script>
            document.addEventListener('DOMContentLoaded', function () {
                const ctx = document.getElementById('incomeChart').getContext('2d');

                // Lấy dữ liệu từ Servlet truyền sang
                const labels = [${chartLabels}];
                const dataValues = [${chartValues}];

                new Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels: labels,
                        datasets: [{
                                label: 'Thu nhập (VNĐ)',
                                data: dataValues,
                                backgroundColor: 'rgba(249, 115, 22, 0.8)', // Màu cam Tailwind
                                borderColor: 'rgb(234, 88, 12)',
                                borderWidth: 1,
                                borderRadius: 8,
                                barThickness: 30
                            }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: {display: false},
                            tooltip: {
                                callbacks: {
                                    label: function (context) {
                                        return context.parsed.y.toLocaleString('vi-VN') + ' đ';
                                    }
                                }
                            }
                        },
                        scales: {
                            y: {
                                beginAtZero: true,
                                grid: {borderDash: [5, 5]},
                                ticks: {
                                    callback: function (value) {
                                        if (value === 0)
                                            return '0đ';
                                        return (value / 1000) + 'k'; // Hiển thị 15k, 20k cho gọn
                                    }
                                }
                            },
                            x: {grid: {display: false}}
                        }
                    }
                });
            });
            let knownOrderCount = ${availableOrders != null ? availableOrders.size() : 0};

            // Cài đặt vòng lặp: Cứ mỗi 5 giây (5000 mili-giây) lại chạy hàm này 1 lần
            setInterval(function () {
                // CHỈ chạy radar quét khi Shipper đang bật "Trực tuyến"
                if ($('#toggle-online').is(':checked')) {

                    $.ajax({
                        url: '${pageContext.request.contextPath}/shipper/check-new-orders',
                        type: 'GET',
                        dataType: 'json',
                        success: function (data) {
                            // Nếu số đơn hàng trên Server NHIỀU HƠN số đơn bạn đang thấy
                            if (data.count > knownOrderCount) {

                                // 1. Bật âm thanh "Ting Ting"
                                const audio = document.getElementById('newOrderSound');
                                audio.play().catch(e => console.log("Trình duyệt chặn phát âm thanh tự động"));

                                // 2. Hiển thị cái Popup rớt từ trên xuống
                                document.getElementById('new-order-popup').classList.remove('translate-y-[-150%]');
                                document.getElementById('new-order-popup').classList.add('translate-y-0');

                                // 3. Cập nhật lại biến đếm để nó không kêu réo liên tục
                                knownOrderCount = data.count;

                            } else if (data.count < knownOrderCount) {
                                // Nếu số đơn ít đi (do tài xế khác nhanh tay nhận mất) -> âm thầm cập nhật lại
                                knownOrderCount = data.count;
                            }
                        }
                    });
                }
            }, 5000);
        </script>
        <script>
            let targetAction = null; // Biến lưu trữ hành động đang chờ xác nhận

            // Hàm gọi Popblock hiện lên
            function confirmAction(event, message, element) {
                event.preventDefault(); // Chặn hành động mặc định ngay lập tức (chặn form submit / chặn link)

                // Xác định xem người dùng đang bấm vào Form hay thẻ Link <a>
                if (element.tagName === 'A') {
                    targetAction = {type: 'link', data: element.href};
                } else if (element.form) {
                    targetAction = {type: 'form', data: element.form}; // Dùng cho <button type="submit">
                } else if (element.tagName === 'FORM') {
                    targetAction = {type: 'form', data: element};
                }

                // Cập nhật câu chữ và tạo hiệu ứng bật lên
                document.getElementById('confirm-message').innerText = message;
                const modal = document.getElementById('custom-confirm-modal');
                const content = document.getElementById('confirm-modal-content');

                modal.classList.remove('hidden');
                setTimeout(() => {
                    content.classList.remove('scale-95', 'opacity-0');
                    content.classList.add('scale-100', 'opacity-100');
                }, 10);
            }

            // Hàm tắt Popblock
            function closeConfirmModal() {
                const modal = document.getElementById('custom-confirm-modal');
                const content = document.getElementById('confirm-modal-content');

                content.classList.remove('scale-100', 'opacity-100');
                content.classList.add('scale-95', 'opacity-0');

                setTimeout(() => {
                    modal.classList.add('hidden');
                    targetAction = null; // Xóa dữ liệu chờ
                }, 200);
            }

            // Hàm thực thi khi người dùng bấm "Xác nhận"
            function executeConfirm() {
                if (!targetAction)
                    return;

                if (targetAction.type === 'form') {
                    targetAction.data.submit(); // Cho phép form gửi đi
                } else if (targetAction.type === 'link') {
                    window.location.href = targetAction.data; // Cho phép link chuyển hướng
                }
            }
        </script>
    </body>
</html>