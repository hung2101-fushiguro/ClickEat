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
                    </div>
                    <a href="${pageContext.request.contextPath}/merchant/orders"
                    class="flex items-center gap-1.5 text-sm font-medium text-primary hover:text-orange-600 transition-colors bg-orange-50 hover:bg-orange-100 px-4 py-2 rounded-xl">
                    <span class="material-symbols-outlined text-[20px]">receipt_long</span>
                    Xem đơn hàng
                </a>
            </div>

            <div class="p-4 md:p-6 max-w-7xl mx-auto space-y-6">

                <!-- Greeting -->
                <div class="flex flex-col md:flex-row justify-between items-start md:items-end gap-2">
                    <div>
                        <h1 class="text-2xl md:text-3xl font-bold text-gray-900 tracking-tight" id="greetingUser">Xin chào, ${sessionScope.merchantName} 👋</h1>
                        <p class="text-gray-500 mt-1 text-sm md:text-base">Đây là tình hình kinh doanh hôm nay của bạn.</p>
                    </div>
                </div>

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
                                <div class="flex items-center gap-3 bg-white rounded-xl p-3 border border-orange-100 hover:border-primary cursor-pointer transition-colors" onclick="window.location.href='${pageContext.request.contextPath}/merchant/settings'">
                                    <div class="w-8 h-8 rounded-full flex items-center justify-center ${step.done ? 'bg-green-100' : 'bg-gray-100'}">
                                        <span class="material-symbols-outlined text-base ${step.done ? 'text-green-600' : 'text-gray-400'}">${step.icon}</span>
                                    </div>
                                    <span class="text-sm font-medium ${step.done ? 'text-gray-400 line-through opacity-60' : 'text-gray-700'}">${step.label}</span>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                </c:if>

                <!-- Stats cards -->
                <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
                    <div class="bg-white rounded-2xl border border-gray-200 p-5 hover:shadow-md transition-all group">
                        <div class="w-10 h-10 bg-primary/10 rounded-xl flex items-center justify-center mb-3 transition-transform group-hover:scale-110">
                            <span class="material-symbols-outlined text-primary">payments</span>
                        </div>
                        <p class="text-xs text-gray-500 font-medium">Doanh thu hôm nay</p>
                        <p class="text-xl font-bold text-gray-900 mt-1">
                            <fmt:formatNumber value="${todayRevenue}" type="number" groupingUsed="true"/>đ
                            </p>
                        </div>
                        <div class="bg-white rounded-2xl border border-gray-200 p-5 hover:shadow-md transition-all group">
                            <div class="w-10 h-10 bg-blue-50 rounded-xl flex items-center justify-center mb-3 transition-transform group-hover:scale-110">
                                <span class="material-symbols-outlined text-blue-600">receipt_long</span>
                            </div>
                            <p class="text-xs text-gray-500 font-medium">Đơn hôm nay</p>
                            <p class="text-xl font-bold text-gray-900 mt-1">${todayOrders}</p>
                        </div>
                        <div class="bg-white rounded-2xl border border-gray-200 p-5 hover:shadow-md transition-all group">
                            <div class="w-10 h-10 bg-purple-50 rounded-xl flex items-center justify-center mb-3 transition-transform group-hover:scale-110">
                                <span class="material-symbols-outlined text-purple-600">data_usage</span>
                            </div>
                            <p class="text-xs text-gray-500 font-medium">Giá trị TB đơn</p>
                            <p class="text-xl font-bold text-gray-900 mt-1">
                                <fmt:formatNumber value="${todayOrders > 0 ? todayRevenue / todayOrders : 0}" type="number" groupingUsed="true"/>đ
                                </p>
                            </div>
                            <div class="bg-white rounded-2xl border border-gray-200 p-5 hover:shadow-md transition-all group">
                                <div class="w-10 h-10 bg-yellow-50 rounded-xl flex items-center justify-center mb-3 transition-transform group-hover:scale-110">
                                    <span class="material-symbols-outlined text-yellow-500">star</span>
                                </div>
                                <p class="text-xs text-gray-500 font-medium">Đánh giá TB</p>
                                <p class="text-xl font-bold text-gray-900 mt-1">
                                    <c:choose>
                                        <c:when test="${avgRating > 0}">${avgRating} ⭐</c:when>
                                            <c:otherwise>—</c:otherwise>
                                            </c:choose>
                                        </p>
                                    </div>
                                </div>

                                <!-- Chart + Recent Orders -->
                                <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                                    <!-- Revenue chart -->
                                    <div class="lg:col-span-2 bg-white rounded-2xl border border-gray-200 p-6">
                                        <div class="flex items-center justify-between mb-4">
                                            <h2 class="font-semibold text-gray-900" id="chartTitle">Doanh thu 7 ngày</h2>
                                            <div class="flex gap-1 bg-gray-100 p-0.5 rounded-lg">
                                                <button id="btn7d" onclick="setChartRange('7d')" class="px-3 py-1 text-xs font-semibold rounded-md bg-white text-gray-900 shadow-sm transition-all">7 ngày</button>
                                                <button id="btn30d" onclick="setChartRange('30d')" class="px-3 py-1 text-xs font-semibold rounded-md text-gray-500 transition-all">30 ngày</button>
                                            </div>
                                        </div>
                                        <canvas id="revenueChart" height="180"></canvas>
                                    </div>

                                    <!-- Top selling items -->
                                    <div class="bg-white rounded-2xl border border-gray-200 p-6 overflow-hidden">
                                        <h2 class="font-semibold text-gray-900 mb-4">Món bán chạy</h2>
                                        <c:choose>
                                            <c:when test="${not empty topItems}">
                                                <div class="space-y-3">
                                                    <c:forEach var="ti" items="${topItems}" varStatus="st">
                                                        <div class="flex items-center justify-between">
                                                            <div class="flex items-center gap-3">
                                                                <span class="text-xs font-semibold w-6 h-6 rounded flex items-center justify-center flex-shrink-0 ${st.index == 0 ? 'bg-yellow-100 text-yellow-700' : 'bg-gray-100 text-gray-500'}">${st.index + 1}</span>
                                                                <span class="font-medium text-gray-700 text-sm truncate max-w-[140px]">${ti[0]}</span>
                                                            </div>
                                                            <span class="font-semibold text-gray-900 text-sm shrink-0">${ti[1]} đơn</span>
                                                        </div>
                                                    </c:forEach>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="flex flex-col items-center justify-center py-8 text-gray-400">
                                                    <span class="material-symbols-outlined text-3xl text-gray-200 mb-2">restaurant_menu</span>
                                                    <p class="text-sm">Chưa có dữ liệu</p>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </div>
                        </main>
                    </div>

                    <script>
                        // Time-based Greeting
                        const hour = new Date().getHours();
                        let timeGreeting = "Chào buổi sáng";
                        if(hour >= 12 && hour < 18) timeGreeting = "Chào buổi chiều";
                        else if(hour >= 18) timeGreeting = "Chào buổi tối";
                        document.getElementById('greetingUser').textContent = timeGreeting + ', ${sessionScope.merchantName} 👋';
                        
                        const labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
                        const revenueData = [${weeklyRevenueJson}];
                        let revenueChartInst;
                        function buildRevenueChart(data, lbls) {
                            if (revenueChartInst) revenueChartInst.destroy();
                            revenueChartInst = new Chart(document.getElementById('revenueChart'), {
                                type: 'line',
                                data: {
                                    labels: lbls,
                                    datasets: [{
                                        label: 'Doanh thu (đ)',
                                        data: data,
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
                        }
                        function setChartRange(range) {
                            const btn7d = document.getElementById('btn7d');
                            const btn30d = document.getElementById('btn30d');
                            const chartTitle = document.getElementById('chartTitle');
                            if (range === '7d') {
                                btn7d.className = 'px-3 py-1 text-xs font-semibold rounded-md bg-white text-gray-900 shadow-sm transition-all';
                                btn30d.className = 'px-3 py-1 text-xs font-semibold rounded-md text-gray-500 transition-all';
                                chartTitle.textContent = 'Doanh thu 7 ngày';
                                buildRevenueChart(revenueData, labels);
                                } else {
                                    btn7d.className = 'px-3 py-1 text-xs font-semibold rounded-md text-gray-500 transition-all';
                                    btn30d.className = 'px-3 py-1 text-xs font-semibold rounded-md bg-white text-gray-900 shadow-sm transition-all';
                                    chartTitle.textContent = 'Doanh thu 30 ngày';
                                    window.location.href = '${pageContext.request.contextPath}/merchant/analytics?period=30';
                                }
                            }
                            buildRevenueChart(revenueData, labels);
                        </script>
                    </body>
                </html>
