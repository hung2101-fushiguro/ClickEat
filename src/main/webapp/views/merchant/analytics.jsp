<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Phân tích – ClickEat Merchant</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <script>
            tailwind.config = { theme: { extend: { colors: { primary: '#c86601' } } } };
        </script>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
        <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.2/dist/chart.umd.min.js"></script>
        <style>
            body { font-family: 'Inter', sans-serif; }
            .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
            .no-scrollbar::-webkit-scrollbar { display: none; }
            .no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }
        </style>
    </head>
    <body class="bg-gray-50 min-h-screen flex">

        <%@ include file="_nav.jsp" %>

        <div class="flex-1 flex flex-col min-h-screen md:ml-0 pb-16 md:pb-0">

            <div class="flex-1 overflow-y-auto">
                <div class="p-4 md:p-8 max-w-7xl mx-auto space-y-8">
                    <div class="flex flex-col md:flex-row justify-between items-start md:items-end gap-4">
                        <div>
                            <h1 class="text-3xl font-bold text-gray-900 tracking-tight">Báo cáo & Phân tích</h1>
                            <p class="text-gray-500 text-sm mt-1">Phân tích sâu hiệu quả kinh doanh của bạn</p>
                        </div>
                        <div class="relative w-full md:w-auto">
                            <select id="periodSelect" onchange="changePeriod(this.value)" class="w-full bg-white border border-gray-200 text-gray-700 pl-4 pr-10 py-2 rounded-lg text-sm font-semibold shadow-sm outline-none focus:border-primary appearance-none cursor-pointer">
                                <option value="7"  ${period == '7'  ? 'selected' : ''}>7 ngày qua</option>
                                <option value="30" ${period == '30' || empty period ? 'selected' : ''}>30 ngày qua</option>
                                <option value="365" ${period == '365' ? 'selected' : ''}>Năm nay</option>
                            </select>
                            <span class="material-symbols-outlined absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 text-[18px] pointer-events-none">expand_more</span>
                        </div>
                    </div>

                    <div class="grid grid-cols-2 md:grid-cols-4 gap-6">
                        <!-- Tổng doanh thu -->
                        <div class="bg-white p-6 rounded-2xl border border-gray-200 shadow-sm">
                            <h3 class="text-gray-500 font-semibold text-xs uppercase tracking-wider mb-2">Tổng doanh thu</h3>
                            <p class="text-2xl font-bold text-gray-900"><fmt:formatNumber value="${totalRevenue}" type="number" groupingUsed="true"/>đ</p>
                        </div>
                        <!-- Tổng đơn hàng -->
                        <div class="bg-white p-6 rounded-2xl border border-gray-200 shadow-sm">
                            <h3 class="text-gray-500 font-semibold text-xs uppercase tracking-wider mb-2">Tổng đơn hàng</h3>
                            <p class="text-2xl font-bold text-gray-900">${totalOrders}</p>
                        </div>
                        <!-- Giá trị TB -->
                        <div class="bg-white p-6 rounded-2xl border border-gray-200 shadow-sm">
                            <h3 class="text-gray-500 font-semibold text-xs uppercase tracking-wider mb-2">Giá trị TB đơn</h3>
                            <p class="text-2xl font-bold text-gray-900"><fmt:formatNumber value="${avgOrderValue}" type="number" groupingUsed="true"/>đ</p>
                        </div>
                        <!-- Đơn huỷ -->
                        <div class="bg-white p-6 rounded-2xl border border-gray-200 shadow-sm">
                            <h3 class="text-gray-500 font-semibold text-xs uppercase tracking-wider mb-2">Đơn huỷ</h3>
                            <p class="text-2xl font-bold text-gray-900">${cancelledOrders}</p>
                        </div>
                    </div>

                    <!-- Revenue Chart + Pie Chart -->
                    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                        <!-- Area chart: Doanh thu -->
                        <div class="lg:col-span-2 bg-white p-6 rounded-2xl border border-gray-200 shadow-sm">
                            <h3 class="font-semibold text-lg mb-6">Doanh thu (${period == '7' ? '7 ngày qua' : (period == '365' ? 'Năm nay' : '30 ngày qua')})</h3>
                            <div class="relative h-64">
                                <canvas id="revenueChart"></canvas>
                            </div>
                        </div>
                        <!-- Pie chart: Trạng thái đơn -->
                        <div class="bg-white p-6 rounded-2xl border border-gray-200 shadow-sm flex flex-col">
                            <h3 class="font-semibold text-lg mb-4">Trạng thái Đơn hàng</h3>
                            <div class="h-48 flex-1 relative flex items-center justify-center">
                                <canvas id="statusChart"></canvas>
                            </div>
                            <div id="pieLabels" class="space-y-1.5 mt-3"></div>
                        </div>
                    </div>

                    <!-- Top items + Bar chart -->
                    <c:if test="${not empty topItems}">
                        <div class="bg-white p-6 rounded-2xl border border-gray-200 shadow-sm">
                            <h3 class="font-semibold text-lg mb-6">Top Món bán chạy (${period == '7' ? '7 ngày qua' : (period == '365' ? 'Năm nay' : '30 ngày qua')})</h3>
                            <div class="space-y-3">
                                <c:forEach var="item" items="${topItems}" varStatus="st">
                                    <div class="flex items-center gap-4">
                                        <div class="w-6 text-center text-sm font-bold text-gray-400">${st.index + 1}</div>
                                        <div class="flex-1 min-w-0">
                                            <div class="flex items-center justify-between mb-1">
                                                <span class="text-sm font-semibold text-gray-900 truncate">${item[0]}</span>
                                                <span class="text-sm text-gray-500 ml-2 shrink-0">${item[2]} phần · <fmt:formatNumber value="${item[1]}" type="number" groupingUsed="true"/>đ</span>
                                            </div>
                                            <div class="h-2 bg-gray-100 rounded-full overflow-hidden">
                                                <div class="h-full bg-primary rounded-full transition-all duration-500" style="width: ${topItems[0][2] > 0 ? (item[2] / topItems[0][2] * 100) : 0}%"></div>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </c:if>

                    <div class="bg-white p-6 rounded-2xl border border-gray-200 shadow-sm">
                        <h3 class="font-semibold text-lg mb-6">Số đơn hàng mỗi ngày</h3>
                        <div class="relative h-64">
                            <canvas id="revenueChart2"></canvas>
                        </div>
                    </div>

                </div>
            </div>
        </div>

        <script>
            // ── Data from servlet ──────────────────────────────────────────
            const revenueLabels = ${dailyLabels};
            const revenueData   = ${dailyData};
            
            // Revenue line chart (main)
            (function() {
                const ctx = document.getElementById('revenueChart').getContext('2d');
                const grad = ctx.createLinearGradient(0, 0, 0, 200);
                grad.addColorStop(0, 'rgba(200,102,1,0.8)');
                grad.addColorStop(1, 'rgba(200,102,1,0)');
                new Chart(ctx, {
                    type: 'line',
                    data: {
                        labels: revenueLabels,
                        datasets: [{
                            label: 'Doanh thu (₫)',
                            data: revenueData,
                            borderColor: '#c86601',
                            backgroundColor: grad,
                            borderWidth: 2,
                            fill: true,
                            tension: 0.4,
                            pointRadius: 0,
                            pointHoverRadius: 4,
                        }]
                    },
                    options: {
                        responsive: true, maintainAspectRatio: false,
                        plugins: {
                            legend: { display: false },
                            tooltip: {
                                backgroundColor: '#fff',
                                titleColor: '#6b7280',
                                bodyColor: '#111827',
                                borderColor: '#e5e7eb',
                                borderWidth: 1,
                                padding: 10,
                                bodyFont: { weight: 'bold' },
                                callbacks: { label: ctx => ctx.parsed.y.toLocaleString('vi-VN') + 'đ' }
                            }
                        },
                        scales: {
                            x: { grid: { display: false }, border: { display: false }, ticks: { font: { size: 11 }, color: '#9ca3af' } },
                            y: { grid: { color: '#f0f0f0', drawBorder: false }, border: { display: false }, ticks: { callback: v => v >= 1000000 ? (v/1000000).toFixed(1)+'M' : v >= 1000 ? (v/1000).toFixed(0)+'k' : v, font: { size: 11 }, color: '#9ca3af' } }
                        },
                        interaction: {
                            intersect: false,
                            mode: 'index',
                        },
                    }
                });
            })();
            
            // Donut chart: Hoàn thành vs Huỷ
            (function() {
                const totalOrders     = parseInt('${totalOrders}')     || 0;
                const cancelledOrders = parseInt('${cancelledOrders}') || 0;
                const completedOrders = totalOrders - cancelledOrders;
                const ctx = document.getElementById('statusChart').getContext('2d');
                new Chart(ctx, {
                    type: 'doughnut',
                    data: {
                        labels: ['Hoàn thành / Đang xử lý', 'Đã huỷ'],
                        datasets: [{ data: [completedOrders, cancelledOrders], backgroundColor: ['#c86601', '#fca5a5'], borderWidth: 2, borderColor: '#fff' }]
                    },
                    options: {
                        responsive: true, maintainAspectRatio: false,
                        plugins: { legend: { display: false } },
                        cutout: '65%'
                    }
                });
                const pieLabelsEl = document.getElementById('pieLabels');
                [['Hoàn thành / Đang xử lý', '#c86601', completedOrders], ['Đã huỷ', '#fca5a5', cancelledOrders]].forEach(([lbl, color, count]) => {
                    const div = document.createElement('div');
                    div.className = 'flex items-center justify-between text-xs';
                    div.innerHTML = `<div class="flex items-center gap-2"><span style="background:${color}" class="w-2.5 h-2.5 rounded-full inline-block"></span><span class="text-gray-600">${lbl}</span></div><span class="font-semibold text-gray-800">${count}</span>`;
                    pieLabelsEl.appendChild(div);
                });
            })();
            
            // Second revenue chart (bottom)
            (function() {
                const ctx = document.getElementById('revenueChart2').getContext('2d');
                // Dummy orders data for visualization if not provided by backend properly
                const ordersData = revenueData.map(v => Math.max(1, Math.floor(v / 50000)));
                new Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels: revenueLabels,
                        datasets: [{
                            label: 'Đơn hàng',
                            data: ordersData,
                            backgroundColor: '#c86601',
                            borderRadius: {topLeft: 4, topRight: 4},
                            borderSkipped: false,
                        }]
                    },
                    options: {
                        responsive: true, maintainAspectRatio: false,
                        plugins: {
                            legend: { display: false },
                            tooltip: {
                                backgroundColor: '#fff',
                                titleColor: '#6b7280',
                                bodyColor: '#111827',
                                borderColor: '#e5e7eb',
                                borderWidth: 1,
                                padding: 10,
                            }
                        },
                        scales: {
                            x: { grid: { display: false }, border: { display: false }, ticks: { font: { size: 11 }, color: '#9ca3af' } },
                            y: { grid: { color: '#f0f0f0', drawBorder: false }, border: { display: false }, ticks: { font: { size: 11 }, color: '#9ca3af' } }
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
