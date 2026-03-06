<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<% request.setAttribute("currentPage", "dashboard"); %>
<!DOCTYPE html>
<html lang="vi" class="h-full">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Dashboard – ClickEat Merchant</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: {sans: ['Inter', 'sans-serif']},
                    colors: {primary: '#c86601', 'primary-dark': '#a05201', 'bg-light': '#f8f7f5'}
                }
            }
        }
    </script>
</head>
<body class="h-full bg-[#f8f7f5] font-sans">
<div class="flex h-full">
    <%@ include file="_nav.jsp" %>

    <!-- Main content -->
    <main class="flex-1 overflow-y-auto pb-20 md:pb-0">
        <!-- Header -->
        <div class="sticky top-0 bg-white/90 backdrop-blur-sm border-b border-gray-100 px-6 py-4 z-10 flex items-center justify-between">
            <div>
                <h1 class="font-bold text-gray-900 text-lg">Dashboard</h1>
                <p class="text-xs text-gray-400">Xin chào, ${sessionScope.merchantName}</p>
            </div>
            <a href="${pageContext.request.contextPath}/merchant/orders"
               class="flex items-center gap-1.5 text-sm font-medium text-primary hover:underline">
                <span class="material-symbols-outlined text-base">receipt_long</span>
                Xem đơn hàng
            </a>
        </div>

        <div class="p-4 md:p-6 max-w-7xl mx-auto space-y-6">

            <!-- New-shop guided empty state -->
            <c:if test="${isNewShop}">
                <div class="bg-gradient-to-r from-orange-50 to-amber-50 border border-orange-200 rounded-2xl p-6">
                    <div class="flex items-center gap-3 mb-4">
                        <span class="material-symbols-outlined text-primary text-3xl">rocket_launch</span>
                        <div>
                            <h3 class="font-bold text-gray-900">Bắt đầu với ClickEat</h3>
                            <p class="text-sm text-gray-500">Hoàn thành các bước để sẵn sàng nhận đơn hàng</p>
                        </div>
                    </div>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
                        <c:forEach var="step" items="${setupSteps}">
                            <div class="flex items-center gap-3 bg-white rounded-xl p-3 border border-orange-100">
                                <div class="w-8 h-8 rounded-full flex items-center justify-center ${step.done ? 'bg-green-100' : 'bg-gray-100'}">
                                    <span class="material-symbols-outlined text-base ${step.done ? 'text-green-600' : 'text-gray-400'}">${step.icon}</span>
                                </div>
                                <span class="text-sm text-gray-700 font-medium">${step.label}</span>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </c:if>

            <!-- Stats cards -->
            <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
                <div class="bg-white rounded-2xl border border-gray-200 p-5">
                    <div class="w-10 h-10 bg-primary/10 rounded-xl flex items-center justify-center mb-3">
                        <span class="material-symbols-outlined text-primary">payments</span>
                    </div>
                    <p class="text-xs text-gray-500 font-medium">Doanh thu hôm nay</p>
                    <p class="text-xl font-bold text-gray-900 mt-1">
                        <fmt:formatNumber value="${todayRevenue}" type="number" groupingUsed="true"/>đ
                    </p>
                </div>
                <div class="bg-white rounded-2xl border border-gray-200 p-5">
                    <div class="w-10 h-10 bg-blue-50 rounded-xl flex items-center justify-center mb-3">
                        <span class="material-symbols-outlined text-blue-600">receipt_long</span>
                    </div>
                    <p class="text-xs text-gray-500 font-medium">Đơn hôm nay</p>
                    <p class="text-xl font-bold text-gray-900 mt-1">${todayOrders}</p>
                </div>
                <div class="bg-white rounded-2xl border border-gray-200 p-5">
                    <div class="w-10 h-10 bg-yellow-50 rounded-xl flex items-center justify-center mb-3">
                        <span class="material-symbols-outlined text-yellow-600">pending</span>
                    </div>
                    <p class="text-xs text-gray-500 font-medium">Đơn đang chờ</p>
                    <p class="text-xl font-bold text-gray-900 mt-1">${pendingOrders}</p>
                </div>
                <div class="bg-white rounded-2xl border border-gray-200 p-5">
                    <div class="w-10 h-10 bg-green-50 rounded-xl flex items-center justify-center mb-3">
                        <span class="material-symbols-outlined text-green-600">star</span>
                    </div>
                    <p class="text-xs text-gray-500 font-medium">Tổng đơn tháng</p>
                    <p class="text-xl font-bold text-gray-900 mt-1">${monthOrders}</p>
                </div>
            </div>

            <!-- Chart + Recent Orders -->
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <!-- Revenue chart -->
                <div class="lg:col-span-2 bg-white rounded-2xl border border-gray-200 p-6">
                    <div class="flex items-center justify-between mb-4">
                        <h2 class="font-semibold text-gray-900">Doanh thu 7 ngày</h2>
                    </div>
                    <canvas id="revenueChart" height="180"></canvas>
                </div>

                <!-- Recent orders -->
                <div class="bg-white rounded-2xl border border-gray-200 p-6">
                    <div class="flex items-center justify-between mb-4">
                        <h2 class="font-semibold text-gray-900">Đơn gần đây</h2>
                        <a href="${pageContext.request.contextPath}/merchant/orders"
                           class="text-xs text-primary hover:underline font-medium">Xem tất cả</a>
                    </div>
                    <div class="space-y-2">
                        <c:forEach var="order" items="${recentOrders}">
                            <div class="flex items-center justify-between py-2 border-b border-gray-50 last:border-0">
                                <div class="min-w-0">
                                    <p class="text-sm font-medium text-gray-900 truncate">#${order.orderCode}</p>
                                    <p class="text-xs text-gray-400 truncate">${order.receiverName}</p>
                                </div>
                                <span class="ml-2 text-xs px-2 py-1 rounded-full font-medium whitespace-nowrap
                                    ${order.orderStatus == 'DELIVERED' ? 'bg-green-100 text-green-700' :
                                      order.orderStatus == 'CANCELLED' ? 'bg-red-100 text-red-700' :
                                      order.orderStatus == 'CREATED' || order.orderStatus == 'PAID' ? 'bg-blue-100 text-blue-700' :
                                      'bg-yellow-100 text-yellow-700'}">
                                    <c:choose>
                                        <c:when test="${order.orderStatus == 'CREATED' || order.orderStatus == 'PAID'}">Mới</c:when>
                                        <c:when test="${order.orderStatus == 'MERCHANT_ACCEPTED' || order.orderStatus == 'PREPARING'}">Đang nấu</c:when>
                                        <c:when test="${order.orderStatus == 'READY_FOR_PICKUP'}">Sẵn sàng</c:when>
                                        <c:when test="${order.orderStatus == 'DELIVERING'}">Đang giao</c:when>
                                        <c:when test="${order.orderStatus == 'DELIVERED'}">Hoàn tất</c:when>
                                        <c:when test="${order.orderStatus == 'CANCELLED'}">Đã hủy</c:when>
                                        <c:otherwise>${order.orderStatus}</c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                        </c:forEach>
                        <c:if test="${empty recentOrders}">
                            <div class="text-center py-8">
                                <span class="material-symbols-outlined text-3xl text-gray-300">inbox</span>
                                <p class="text-sm text-gray-400 mt-2">Chưa có đơn hàng</p>
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>

<script>
    const labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    const revenueData = [${weeklyRevenueJson}];
    new Chart(document.getElementById('revenueChart'), {
        type: 'line',
        data: {
            labels,
            datasets: [{
                label: 'Doanh thu (đ)',
                data: revenueData,
                borderColor: '#c86601',
                backgroundColor: 'rgba(200,102,1,0.07)',
                tension: 0.4,
                fill: true,
                pointBackgroundColor: '#c86601',
                pointRadius: 4,
            }]
        },
        options: {
            responsive: true,
            plugins: {legend: {display: false}},
            scales: {
                y: {beginAtZero: true, grid: {color: '#f3f4f6'}},
                x: {grid: {display: false}}
            }
        }
    });
</script>
</body>
</html>
