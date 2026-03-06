<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<% request.setAttribute("currentPage", "orders"); %>
<!DOCTYPE html>
<html lang="vi" class="h-full">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Đơn hàng – ClickEat Merchant</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
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
        .tab-active { background: #c86601; color: white; }
    </style>
</head>
<body class="h-full bg-[#f8f7f5] font-sans">
<div class="flex h-full">
    <%@ include file="_nav.jsp" %>

    <main class="flex-1 overflow-y-auto pb-20 md:pb-0">
        <!-- Header -->
        <div class="sticky top-0 bg-white/90 backdrop-blur-sm border-b border-gray-100 px-6 py-4 z-10 flex items-center justify-between">
            <h1 class="font-bold text-gray-900 text-lg">Đơn hàng</h1>
            <!-- Auto refresh every 30s -->
            <span class="text-xs text-gray-400" id="refreshTimer">Tự động làm mới sau 30s</span>
        </div>

        <div class="p-4 md:p-6 max-w-7xl mx-auto space-y-5">

            <!-- Status filter tabs -->
            <div class="flex gap-2 overflow-x-auto pb-1">
                <c:forEach var="tab" items="${statusTabs}">
                    <a href="?status=${tab.key}"
                       class="flex items-center gap-1.5 px-3 py-1.5 rounded-full text-sm font-medium whitespace-nowrap border transition-all
                           ${param.status == tab.key || (empty param.status && tab.key == 'ALL')
                               ? 'border-primary bg-primary text-white'
                               : 'border-gray-200 bg-white text-gray-600 hover:border-gray-300'}">
                        ${tab.value}
                        <c:if test="${tab.key == 'CREATED' || tab.key == 'PAID'}">
                            <c:if test="${newOrderCount > 0}">
                                <span class="bg-white text-primary text-[10px] font-bold px-1.5 rounded-full">${newOrderCount}</span>
                            </c:if>
                        </c:if>
                    </a>
                </c:forEach>
            </div>

            <!-- Order cards -->
            <c:if test="${empty orders}">
                <div class="bg-white rounded-2xl border border-gray-200 p-16 text-center">
                    <span class="material-symbols-outlined text-5xl text-gray-200">receipt_long</span>
                    <p class="text-gray-400 mt-3 font-medium">Không có đơn hàng nào</p>
                </div>
            </c:if>

            <div class="space-y-4">
                <c:forEach var="order" items="${orders}">
                    <div class="bg-white rounded-2xl border border-gray-200 overflow-hidden">
                        <!-- Order header -->
                        <div class="flex items-center justify-between px-5 py-4 border-b border-gray-100">
                            <div class="flex items-center gap-3">
                                <div>
                                    <p class="font-bold text-gray-900">#${order.orderCode}</p>
                                    <p class="text-xs text-gray-400">
                                        <fmt:formatDate value="${order.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                    </p>
                                </div>
                            </div>
                            <span class="text-xs px-3 py-1 rounded-full font-semibold
                                ${order.orderStatus == 'CREATED' || order.orderStatus == 'PAID' ? 'bg-blue-100 text-blue-700' :
                                  order.orderStatus == 'MERCHANT_ACCEPTED' || order.orderStatus == 'PREPARING' ? 'bg-yellow-100 text-yellow-700' :
                                  order.orderStatus == 'READY_FOR_PICKUP' ? 'bg-green-100 text-green-700' :
                                  order.orderStatus == 'DELIVERING' ? 'bg-purple-100 text-purple-700' :
                                  order.orderStatus == 'DELIVERED' ? 'bg-gray-100 text-gray-700' :
                                  'bg-red-100 text-red-700'}">
                                <c:choose>
                                    <c:when test="${order.orderStatus == 'CREATED' || order.orderStatus == 'PAID'}">🔵 Mới</c:when>
                                    <c:when test="${order.orderStatus == 'MERCHANT_ACCEPTED'}">🟡 Đã nhận</c:when>
                                    <c:when test="${order.orderStatus == 'PREPARING'}">🟡 Đang nấu</c:when>
                                    <c:when test="${order.orderStatus == 'READY_FOR_PICKUP'}">🟢 Sẵn sàng</c:when>
                                    <c:when test="${order.orderStatus == 'DELIVERING'}">🟣 Đang giao</c:when>
                                    <c:when test="${order.orderStatus == 'DELIVERED'}">✅ Hoàn tất</c:when>
                                    <c:when test="${order.orderStatus == 'CANCELLED'}">❌ Đã hủy</c:when>
                                    <c:otherwise>${order.orderStatus}</c:otherwise>
                                </c:choose>
                            </span>
                        </div>

                        <!-- Customer + address -->
                        <div class="px-5 py-3 bg-gray-50 flex flex-col md:flex-row md:items-center gap-2 md:gap-6 text-sm">
                            <div class="flex items-center gap-2 text-gray-700">
                                <span class="material-symbols-outlined text-base text-gray-400">person</span>
                                <span>${order.receiverName} · ${order.receiverPhone}</span>
                            </div>
                            <div class="flex items-center gap-2 text-gray-500">
                                <span class="material-symbols-outlined text-base text-gray-400">location_on</span>
                                <span class="truncate max-w-xs">${order.deliveryAddressLine}</span>
                            </div>
                        </div>

                        <!-- Total + actions -->
                        <div class="flex items-center justify-between px-5 py-4">
                            <div>
                                <p class="text-xs text-gray-400">Tổng tiền</p>
                                <p class="font-bold text-gray-900">
                                    <fmt:formatNumber value="${order.totalAmount}" type="number" groupingUsed="true"/>đ
                                </p>
                            </div>

                            <!-- Action buttons based on status -->
                            <div class="flex gap-2">
                                <c:choose>
                                    <c:when test="${order.orderStatus == 'CREATED' || order.orderStatus == 'PAID'}">
                                        <form method="POST" action="${pageContext.request.contextPath}/merchant/orders">
                                            <input type="hidden" name="orderId" value="${order.id}"/>
                                            <input type="hidden" name="action" value="accept"/>
                                            <button type="submit"
                                                    class="flex items-center gap-1.5 px-4 py-2 bg-primary text-white text-sm font-semibold rounded-xl hover:bg-primary-dark transition-all">
                                                <span class="material-symbols-outlined text-base">check</span>
                                                Nhận đơn
                                            </button>
                                        </form>
                                        <form method="POST" action="${pageContext.request.contextPath}/merchant/orders">
                                            <input type="hidden" name="orderId" value="${order.id}"/>
                                            <input type="hidden" name="action" value="cancel"/>
                                            <button type="submit"
                                                    onclick="return confirm('Hủy đơn #${order.orderCode}?')"
                                                    class="flex items-center gap-1.5 px-4 py-2 border border-gray-200 text-gray-600 text-sm font-semibold rounded-xl hover:bg-red-50 hover:text-red-600 hover:border-red-200 transition-all">
                                                <span class="material-symbols-outlined text-base">close</span>
                                                Từ chối
                                            </button>
                                        </form>
                                    </c:when>
                                    <c:when test="${order.orderStatus == 'MERCHANT_ACCEPTED' || order.orderStatus == 'PREPARING'}">
                                        <form method="POST" action="${pageContext.request.contextPath}/merchant/orders">
                                            <input type="hidden" name="orderId" value="${order.id}"/>
                                            <input type="hidden" name="action" value="ready"/>
                                            <button type="submit"
                                                    class="flex items-center gap-1.5 px-4 py-2 bg-green-600 text-white text-sm font-semibold rounded-xl hover:bg-green-700 transition-all">
                                                <span class="material-symbols-outlined text-base">done_all</span>
                                                Sẵn sàng
                                            </button>
                                        </form>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="text-xs text-gray-400 italic">
                                            <c:if test="${order.orderStatus == 'DELIVERED'}">
                                                Đã giao <fmt:formatDate value="${order.deliveredAt}" pattern="HH:mm"/>
                                            </c:if>
                                        </span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </main>
</div>

<script>
    // Auto refresh every 30 seconds
    let countdown = 30;
    const timerEl = document.getElementById('refreshTimer');
    setInterval(() => {
        countdown--;
        if (countdown <= 0) { location.reload(); return; }
        timerEl.textContent = `Tự động làm mới sau ${countdown}s`;
    }, 1000);
</script>
</body>
</html>
