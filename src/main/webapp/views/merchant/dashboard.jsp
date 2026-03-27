<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<% request.setAttribute("currentPage", "dashboard");%>
<!DOCTYPE html>
<html lang="vi" class="h-full">
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/responsive-global.css">
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
        </style>
    </head>
    <body class="h-full bg-[#f8f7f5] text-gray-800 flex overflow-hidden">

        <jsp:include page="_nav.jsp" />

        <main class="flex-1 flex flex-col h-screen overflow-y-auto">
            <header class="bg-white border-b border-gray-100 px-4 md:px-8 py-5 sticky top-0 z-10 shadow-sm">
                <h1 class="text-2xl font-black text-gray-900 tracking-tight">Tổng quan kinh doanh</h1>
                <p class="text-sm text-gray-500 font-medium mt-1">Doanh thu, đơn hàng, tỉ lệ hủy và hiệu quả voucher</p>
            </header>

            <div class="p-8 max-w-7xl mx-auto w-full space-y-6">
                <div class="bg-white rounded-2xl p-5 border border-gray-100 shadow-sm">
                    <form method="get" action="${pageContext.request.contextPath}/merchant/dashboard" class="flex flex-col md:flex-row md:items-end gap-3">
                        <div>
                            <label class="block text-xs font-bold text-gray-500 mb-1 uppercase">Từ ngày</label>
                            <input type="date" name="fromDate" value="${fromDate}" class="px-3 py-2 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-primary/25"/>
                        </div>
                        <div>
                            <label class="block text-xs font-bold text-gray-500 mb-1 uppercase">Đến ngày</label>
                            <input type="date" name="toDate" value="${toDate}" class="px-3 py-2 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-primary/25"/>
                        </div>
                        <div class="flex items-center gap-2">
                            <button type="submit" class="px-4 py-2 rounded-xl bg-primary text-white font-bold text-sm hover:bg-primary-dark">Lọc</button>
                            <a href="${pageContext.request.contextPath}/merchant/dashboard" class="px-4 py-2 rounded-xl border border-gray-200 text-sm font-bold text-gray-600 hover:bg-gray-50">Mặc định</a>
                        </div>
                    </form>
                    <c:if test="${not empty dashboardError}">
                        <p class="mt-3 text-sm text-red-600 font-semibold">${dashboardError}</p>
                    </c:if>
                </div>

                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                    <div class="bg-white rounded-2xl p-5 border border-gray-100 shadow-sm">
                        <p class="text-xs font-bold text-gray-400 uppercase">${isRangeMode ? 'Doanh thu trong khoảng' : 'Doanh thu hôm nay'}</p>
                        <p class="text-2xl font-black text-gray-900 mt-1"><fmt:formatNumber value="${todayRevenue}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></p>
                    </div>
                    <div class="bg-white rounded-2xl p-5 border border-gray-100 shadow-sm">
                        <p class="text-xs font-bold text-gray-400 uppercase">${isRangeMode ? 'Đơn trong khoảng' : 'Doanh thu hôm qua'}</p>
                        <c:choose>
                            <c:when test="${isRangeMode}">
                                <p class="text-2xl font-black text-gray-900 mt-1">${todayOrders}</p>
                            </c:when>
                            <c:otherwise>
                                <p class="text-2xl font-black text-gray-900 mt-1"><fmt:formatNumber value="${yesterdayRevenue}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></p>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="bg-white rounded-2xl p-5 border border-gray-100 shadow-sm">
                        <p class="text-xs font-bold text-gray-400 uppercase">${isRangeMode ? 'Doanh thu tham chiếu' : 'Doanh thu 7 ngày'}</p>
                        <p class="text-2xl font-black text-gray-900 mt-1"><fmt:formatNumber value="${revenue7d}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></p>
                    </div>
                    <div class="bg-white rounded-2xl p-5 border border-gray-100 shadow-sm">
                        <p class="text-xs font-bold text-gray-400 uppercase">${isRangeMode ? 'Tổng đơn (khoảng)' : 'Đơn hôm nay'}</p>
                        <p class="text-2xl font-black text-gray-900 mt-1">${todayOrders}</p>
                    </div>
                    <div class="bg-white rounded-2xl p-5 border border-gray-100 shadow-sm">
                        <p class="text-xs font-bold text-gray-400 uppercase">${isRangeMode ? 'Đơn hủy (khoảng)' : 'Đơn hủy hôm nay'}</p>
                        <p class="text-2xl font-black text-red-600 mt-1">${canceledToday}</p>
                    </div>
                    <div class="bg-white rounded-2xl p-5 border border-gray-100 shadow-sm">
                        <p class="text-xs font-bold text-gray-400 uppercase">Tỉ lệ hủy</p>
                        <p class="text-2xl font-black text-orange-600 mt-1"><fmt:formatNumber value="${cancelRate}" maxFractionDigits="1"/>%</p>
                    </div>
                </div>

                <div class="grid grid-cols-1 xl:grid-cols-3 gap-6">
                    <div class="xl:col-span-2 bg-white rounded-2xl p-6 border border-gray-100 shadow-sm">
                        <h3 class="text-lg font-bold text-gray-900 mb-4">${isRangeMode ? 'Số đơn theo giờ trong khoảng đã lọc' : 'Số đơn theo giờ trong ngày'}</h3>
                        <div class="h-72"><canvas id="hourlyOrdersChart"></canvas></div>
                    </div>
                    <div class="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm">
                        <h3 class="text-lg font-bold text-gray-900 mb-4">${isRangeMode ? 'Tỉ lệ đơn dùng voucher (khoảng lọc)' : 'Tỉ lệ đơn dùng voucher (7 ngày)'}</h3>
                        <div class="h-72"><canvas id="voucherRatioChart"></canvas></div>
                    </div>
                </div>

                <div class="bg-white rounded-2xl p-6 border border-gray-100 shadow-sm">
                    <div class="flex items-center justify-between mb-4">
                        <h3 class="text-lg font-bold text-gray-900">${isRangeMode ? 'Top 5 món bán chạy (khoảng lọc)' : 'Top 5 món bán chạy'}</h3>
                        <a href="${pageContext.request.contextPath}/merchant/catalog" class="text-sm font-bold text-primary hover:underline">Xem Catalog</a>
                    </div>
                    <div class="space-y-2">
                        <c:forEach var="food" items="${topFoods}" varStatus="s">
                            <div class="flex items-center justify-between px-4 py-3 rounded-xl border border-gray-100 bg-gray-50">
                                <div>
                                    <p class="text-sm font-bold text-gray-900">#${s.index + 1} - ${food.name}</p>
                                    <p class="text-xs text-gray-500">Số lượng: ${food.qty}</p>
                                </div>
                                <p class="text-sm font-black text-primary"><fmt:formatNumber value="${food.revenue}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></p>
                            </div>
                        </c:forEach>
                        <c:if test="${empty topFoods}">
                            <p class="text-sm text-gray-400">Chưa có dữ liệu món bán chạy.</p>
                        </c:if>
                    </div>
                </div>
            </div>
        </main>

        <script>
            const hourlyLabels = [
            <c:forEach var="entry" items="${hourlyOrders}" varStatus="st">'${entry.key}h'${not st.last ? ',' : ''}</c:forEach>
            ];
            const hourlyData = [
            <c:forEach var="entry" items="${hourlyOrders}" varStatus="st">${entry.value}${not st.last ? ',' : ''}</c:forEach>
            ];
            
            new Chart(document.getElementById('hourlyOrdersChart').getContext('2d'), {
                type: 'bar',
                data: {
                    labels: hourlyLabels,
                    datasets: [{
                        data: hourlyData,
                        backgroundColor: '#c86601',
                        borderRadius: 8
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {legend: {display: false}},
                    scales: {
                        y: {beginAtZero: true, ticks: {precision: 0}, grid: {color: '#f3f4f6'}},
                        x: {grid: {display: false}}
                    }
                }
            });
            
            const usedVoucher = ${voucherUsed7d};
            const noVoucher = ${voucherNotUsed7d};
            new Chart(document.getElementById('voucherRatioChart').getContext('2d'), {
                type: 'doughnut',
                data: {
                    labels: ['Có voucher', 'Không voucher'],
                    datasets: [{
                        data: [usedVoucher, noVoucher],
                        backgroundColor: ['#c86601', '#e5e7eb'],
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
        </script>
    </body>
</html>