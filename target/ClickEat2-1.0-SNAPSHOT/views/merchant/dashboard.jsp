<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<% request.setAttribute("currentPage", "dashboard");%>
<!DOCTYPE html>
<html lang="vi" class="h-full">
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Tổng quan – ClickEat Merchant</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
        <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
        <script>
            tailwind.config = {
                theme: {
                    extend: {
                        fontFamily: {sans: ['Inter', 'sans-serif']},
                        colors: {primary: '#c86601', 'primary-dark': '#a05201'}
                    }
                }
            }
        </script>
        <style>
            body {
                font-family: 'Inter', sans-serif;
            }
            .material-symbols-outlined {
                font-variation-settings: 'FILL' 1, 'wght' 400, 'GRAD' 0, 'opsz' 24;
            }
        </style>
    </head>
    <body class="h-full bg-[#f8f7f5] font-sans text-gray-800 flex overflow-hidden">

        <jsp:include page="_nav.jsp" />

        <main class="flex-1 flex flex-col h-screen overflow-y-auto">
            <header class="bg-white border-b border-gray-100 px-8 py-5 sticky top-0 z-10 flex justify-between items-center shadow-sm">
                <div>
                    <h1 class="text-2xl font-black text-gray-900 tracking-tight">Tổng quan</h1>
                    <p class="text-sm text-gray-500 font-medium mt-1">Theo dõi hoạt động kinh doanh của bạn hôm nay</p>
                </div>

                <div class="hidden md:flex items-center gap-4">
                    <div class="flex items-center gap-2 bg-green-50 text-green-700 px-4 py-2 rounded-full border border-green-100">
                        <span class="relative flex h-3 w-3">
                            <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-green-400 opacity-75"></span>
                            <span class="relative inline-flex rounded-full h-3 w-3 bg-green-500"></span>
                        </span>
                        <span class="text-sm font-bold">Đang mở cửa</span>
                    </div>
                </div>
            </header>

            <div class="p-8 max-w-7xl mx-auto w-full">

                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">

                    <div class="bg-white rounded-3xl p-6 shadow-[0_8px_30px_rgb(0,0,0,0.04)] border border-gray-50 relative overflow-hidden group hover:-translate-y-1 transition-all duration-300">
                        <div class="absolute -right-4 -top-4 w-24 h-24 bg-green-50 rounded-full group-hover:scale-150 transition-transform duration-500 ease-out z-0"></div>
                        <div class="relative z-10">
                            <div class="flex justify-between items-start mb-4">
                                <div class="w-12 h-12 bg-green-100 text-green-600 rounded-2xl flex items-center justify-center text-2xl shadow-sm">
                                    <span class="material-symbols-outlined">payments</span>
                                </div>
                            </div>
                            <p class="text-sm font-bold text-gray-400 uppercase tracking-wider">Doanh thu hôm nay</p>
                            <h3 class="text-3xl font-black text-gray-900 mt-1">
                                <fmt:formatNumber value="${not empty todayRevenue ? todayRevenue : 0}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                            </h3>
                        </div>
                    </div>

                    <div class="bg-white rounded-3xl p-6 shadow-[0_8px_30px_rgb(0,0,0,0.04)] border border-gray-50 relative overflow-hidden group hover:-translate-y-1 transition-all duration-300">
                        <div class="absolute -right-4 -top-4 w-24 h-24 bg-blue-50 rounded-full group-hover:scale-150 transition-transform duration-500 ease-out z-0"></div>
                        <div class="relative z-10">
                            <div class="flex justify-between items-start mb-4">
                                <div class="w-12 h-12 bg-blue-100 text-blue-600 rounded-2xl flex items-center justify-center text-2xl shadow-sm">
                                    <span class="material-symbols-outlined">receipt_long</span>
                                </div>
                            </div>
                            <p class="text-sm font-bold text-gray-400 uppercase tracking-wider">Đơn hàng hôm nay</p>
                            <h3 class="text-3xl font-black text-gray-900 mt-1">
                                ${not empty todayOrders ? todayOrders : 0}
                            </h3>
                        </div>
                    </div>

                    <div class="bg-white rounded-3xl p-6 shadow-[0_8px_30px_rgb(0,0,0,0.04)] border border-gray-50 relative overflow-hidden group hover:-translate-y-1 transition-all duration-300">
                        <div class="absolute -right-4 -top-4 w-24 h-24 bg-orange-50 rounded-full group-hover:scale-150 transition-transform duration-500 ease-out z-0"></div>
                        <div class="relative z-10">
                            <div class="flex justify-between items-start mb-4">
                                <div class="w-12 h-12 bg-orange-100 text-orange-600 rounded-2xl flex items-center justify-center text-2xl shadow-sm">
                                    <span class="material-symbols-outlined">visibility</span>
                                </div>
                            </div>
                            <p class="text-sm font-bold text-gray-400 uppercase tracking-wider">Lượt khách xem quán</p>
                            <h3 class="text-3xl font-black text-gray-900 mt-1">342</h3>
                        </div>
                    </div>

                    <div class="bg-white rounded-3xl p-6 shadow-[0_8px_30px_rgb(0,0,0,0.04)] border border-gray-50 relative overflow-hidden group hover:-translate-y-1 transition-all duration-300">
                        <div class="absolute -right-4 -top-4 w-24 h-24 bg-yellow-50 rounded-full group-hover:scale-150 transition-transform duration-500 ease-out z-0"></div>
                        <div class="relative z-10">
                            <div class="flex justify-between items-start mb-4">
                                <div class="w-12 h-12 bg-yellow-100 text-yellow-600 rounded-2xl flex items-center justify-center text-2xl shadow-sm">
                                    <span class="material-symbols-outlined">star</span>
                                </div>
                            </div>
                            <p class="text-sm font-bold text-gray-400 uppercase tracking-wider">Đánh giá trung bình</p>
                            <h3 class="text-3xl font-black text-gray-900 mt-1">4.8 <span class="text-lg text-gray-400 font-medium">/ 5</span></h3>
                        </div>
                    </div>
                </div>

                <div class="bg-white rounded-3xl shadow-[0_8px_30px_rgb(0,0,0,0.04)] border border-gray-50 p-6 md:p-8">
                    <div class="flex justify-between items-center mb-6">
                        <h3 id="chartTitle" class="text-xl font-bold text-gray-900">Biểu đồ doanh thu (7 ngày qua)</h3>
                        <div class="bg-gray-100 p-1 rounded-lg flex">
                            <button id="btn7d" onclick="setChartRange('7d')" class="px-4 py-1.5 text-sm font-bold rounded-md bg-white text-gray-900 shadow-sm transition-all">7 Ngày</button>
                            <button id="btn30d" onclick="setChartRange('30d')" class="px-4 py-1.5 text-sm font-bold rounded-md text-gray-500 hover:text-gray-900 transition-all">30 Ngày</button>
                        </div>
                    </div>

                    <div class="w-full h-80 relative">
                        <canvas id="revenueChart"></canvas>
                    </div>
                </div>

            </div>
        </main>

        <script>
            // Dữ liệu mẫu cho biểu đồ
            let chartInstance = null;
            const labels7d = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
            const data7d = [1200000, 1900000, 1500000, 2200000, 3100000, 4500000, 3800000];

            function buildRevenueChart(data, labels) {
                const ctx = document.getElementById('revenueChart').getContext('2d');
                if (chartInstance) {
                    chartInstance.destroy();
                }

                // Tạo Gradient màu cam cho biểu đồ
                let gradient = ctx.createLinearGradient(0, 0, 0, 400);
                gradient.addColorStop(0, 'rgba(200, 102, 1, 0.2)');
                gradient.addColorStop(1, 'rgba(200, 102, 1, 0)');

                chartInstance = new Chart(ctx, {
                    type: 'line',
                    data: {
                        labels: labels,
                        datasets: [{
                                label: 'Doanh thu (VNĐ)',
                                data: data,
                                borderColor: '#c86601',
                                backgroundColor: gradient,
                                borderWidth: 3,
                                pointBackgroundColor: '#fff',
                                pointBorderColor: '#c86601',
                                pointBorderWidth: 2,
                                pointRadius: 4,
                                pointHoverRadius: 6,
                                fill: true,
                                tension: 0.4
                            }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: {display: false},
                            tooltip: {
                                backgroundColor: '#1f2937',
                                padding: 12,
                                titleFont: {family: 'Inter', size: 13},
                                bodyFont: {family: 'Inter', size: 14, weight: 'bold'},
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
                                border: {display: false},
                                grid: {color: '#f3f4f6', drawTicks: false},
                                ticks: {
                                    font: {family: 'Inter', size: 12},
                                    color: '#9ca3af',
                                    callback: function (value) {
                                        return (value / 1000000) + ' Tr';
                                    }
                                }
                            },
                            x: {
                                border: {display: false},
                                grid: {display: false},
                                ticks: {font: {family: 'Inter', size: 12, weight: '500'}, color: '#6b7280'}
                            }
                        }
                    }
                });
            }

            function setChartRange(range) {
                const btn7d = document.getElementById('btn7d');
                const btn30d = document.getElementById('btn30d');
                const chartTitle = document.getElementById('chartTitle');

                if (range === '7d') {
                    btn7d.className = 'px-4 py-1.5 text-sm font-bold rounded-md bg-white text-gray-900 shadow-sm transition-all';
                    btn30d.className = 'px-4 py-1.5 text-sm font-bold rounded-md text-gray-500 hover:text-gray-900 transition-all';
                    chartTitle.textContent = 'Biểu đồ doanh thu (7 ngày qua)';
                    // Ở dự án thực tế, bạn có thể gọi AJAX để lấy data 7 ngày
                    buildRevenueChart(data7d, labels7d);
                } else {
                    // Chuyển sang trang Analytics chi tiết hơn khi bấm 30 ngày
                    window.location.href = '${pageContext.request.contextPath}/merchant/analytics';
                }
            }

            // Khởi tạo biểu đồ lúc mới load trang
            window.addEventListener('DOMContentLoaded', () => {
                buildRevenueChart(data7d, labels7d);
            });
        </script>
    </body>
</html>