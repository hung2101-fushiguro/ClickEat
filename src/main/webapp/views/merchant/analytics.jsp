<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<% request.setAttribute("currentPage", "analytics");%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Phân tích – ClickEat Merchant</title>
        <script>
            const originalWarn = console.warn;
            console.warn = function() {
                if (arguments[0] && typeof arguments[0] === 'string' && arguments[0].includes('cdn.tailwindcss.com should not be used in production')) return;
                originalWarn.apply(console, arguments);
            };
        </script>
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
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet"/>
        <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.2/dist/chart.umd.min.js" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
        <style>
            body {
                font-family: 'Inter', sans-serif;
            }
            .material-symbols-outlined {
                font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
            }
        </style>
    </head>
    <body class="bg-[#f8f7f5] min-h-screen flex">

        <%@ include file="_nav.jsp" %>

        <main class="flex-1 flex flex-col h-screen overflow-y-auto">
            <header class="bg-white border-b border-gray-100 px-8 py-5 sticky top-0 z-10 flex justify-between items-center shadow-sm">
                <div>
                    <h1 class="text-2xl font-black text-gray-900 tracking-tight">Phân tích kinh doanh</h1>
                    <p class="text-sm text-gray-500 font-medium mt-1">Dữ liệu thống kê hiệu quả bán hàng của bạn</p>
                </div>

                <div class="flex items-center gap-3">
                    <select onchange="changePeriod(this.value)" class="bg-white border border-gray-200 text-gray-700 text-sm font-bold rounded-xl px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-primary/20 transition-all cursor-pointer">
                        <option value="7" ${period == 7 ? 'selected' : ''}>7 ngày qua</option>
                        <option value="30" ${period == 30 ? 'selected' : ''}>30 ngày qua</option>
                        <option value="90" ${period == 90 ? 'selected' : ''}>90 ngày qua</option>
                    </select>
                </div>
            </header>

            <div class="p-8 max-w-7xl mx-auto w-full space-y-8">

                <div class="bg-white rounded-[2rem] shadow-[0_8px_30px_rgb(0,0,0,0.04)] border border-gray-50 p-8">
                    <div class="flex justify-between items-center mb-8">
                        <h3 class="text-lg font-bold text-gray-900 flex items-center gap-2">
                            <span class="material-symbols-outlined text-primary">monitoring</span>
                            Biểu đồ doanh thu (${period} ngày qua)
                        </h3>
                    </div>
                    <div class="h-80 w-full">
                        <canvas id="mainRevenueChart"></canvas>
                    </div>
                </div>

                <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
                    <div class="bg-white rounded-[2rem] shadow-[0_8px_30px_rgb(0,0,0,0.04)] border border-gray-50 p-8">
                        <h3 class="text-lg font-bold text-gray-900 mb-6 flex items-center gap-2">
                            <span class="material-symbols-outlined text-primary">workspace_premium</span>
                            Top món ăn bán chạy
                        </h3>
                        <div class="space-y-4">
                            <c:forEach var="item" items="${topFoods}" varStatus="loop">
                                <div class="flex items-center gap-4 p-4 rounded-2xl bg-gray-50/50 border border-gray-100 hover:bg-white hover:shadow-md transition-all">
                                    <span class="w-8 h-8 flex items-center justify-center bg-primary/10 text-primary font-black rounded-lg text-sm">${loop.index + 1}</span>
                                    <div class="flex-1">
                                        <p class="font-bold text-gray-900">${item.name}</p>
                                        <p class="text-xs text-gray-500 font-medium">Đã bán: ${item.qty} món</p>
                                    </div>
                                    <div class="text-right">
                                        <p class="font-black text-gray-900 text-sm">
                                            <fmt:formatNumber value="${item.revenue}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                        </p>
                                    </div>
                                </div>
                            </c:forEach>
                            <c:if test="${empty topFoods}">
                                <p class="text-center py-10 text-gray-400 font-medium">Chưa có dữ liệu bán hàng</p>
                            </c:if>
                        </div>
                    </div>

                    <div class="bg-white rounded-[2rem] shadow-[0_8px_30px_rgb(0,0,0,0.04)] border border-gray-50 p-8">
                        <h3 class="text-lg font-bold text-gray-900 mb-6 flex items-center gap-2">
                            <span class="material-symbols-outlined text-primary">bar_chart</span>
                            Hiệu suất đơn hàng
                        </h3>
                        <div class="h-64 w-full">
                            <canvas id="orderStatusChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>
        </main>

        <script>
            // 1. Chuyển đổi dữ liệu từ Java sang Javascript
            const rawLabels = [<c:forEach var="entry" items="${revenueData}">"${entry.key}",</c:forEach>];
            const rawData = [<c:forEach var="entry" items="${revenueData}">${entry.value},</c:forEach>];
            
            const statusLabels = ['Chờ xử lý', 'Đang chuẩn bị', 'Sẵn sàng lấy', 'Đang giao', 'Đã giao', 'Đã hủy'];
            const statusData = [
            ${orderStatusData.PENDING},
            ${orderStatusData.PREPARING},
            ${orderStatusData.READY_FOR_PICKUP},
            ${orderStatusData.DELIVERING},
            ${orderStatusData.DELIVERED},
            ${orderStatusData.CANCELLED}
            ];
            
            // 2. Vẽ biểu đồ chính
            (function initMainChart() {
                const ctx = document.getElementById('mainRevenueChart').getContext('2d');
                let gradient = ctx.createLinearGradient(0, 0, 0, 400);
                gradient.addColorStop(0, 'rgba(200, 102, 1, 0.15)');
                gradient.addColorStop(1, 'rgba(200, 102, 1, 0)');
                
                new Chart(ctx, {
                    type: 'line',
                    data: {
                        labels: rawLabels,
                        datasets: [{
                            label: 'Doanh thu (đ)',
                            data: rawData,
                            borderColor: '#c86601',
                            backgroundColor: gradient,
                            fill: true,
                            tension: 0.4,
                            borderWidth: 3,
                            pointBackgroundColor: '#fff',
                            pointBorderColor: '#c86601',
                            pointBorderWidth: 2,
                            pointRadius: 4
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {legend: {display: false}},
                        scales: {
                            y: {grid: {color: '#f0f0f0'}, ticks: {font: {size: 11}}},
                            x: {grid: {display: false}, ticks: {font: {size: 11}}}
                        }
                    }
                });
            })();
            
            (function initOrderStatusChart() {
                const canvas = document.getElementById('orderStatusChart');
                if (!canvas)
                return;
                
                const total = statusData.reduce((sum, v) => sum + v, 0);
                const chartData = total > 0 ? statusData : [1];
                const chartLabels = total > 0 ? statusLabels : ['Chưa có dữ liệu'];
                const chartColors = total > 0
                ? ['#f59e0b', '#3b82f6', '#8b5cf6', '#06b6d4', '#22c55e', '#ef4444']
                : ['#e5e7eb'];
                
                new Chart(canvas.getContext('2d'), {
                    type: 'doughnut',
                    data: {
                        labels: chartLabels,
                        datasets: [{
                            data: chartData,
                            backgroundColor: chartColors,
                            borderWidth: 0
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: {position: 'bottom'}
                        }
                    }
                });
            })();
            
            function changePeriod(v) {
                window.location.href = '${pageContext.request.contextPath}/merchant/analytics?period=' + v;
            }
        </script>
    </body>
</html>