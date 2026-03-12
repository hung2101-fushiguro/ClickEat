<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<% request.setAttribute("currentPage", "orders");%>
<!DOCTYPE html>
<html lang="vi" class="h-full">
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Đơn #${order.orderCode} – ClickEat Merchant</title>
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
            .timeline-line {
                position: absolute;
                left: 1.2rem;
                top: 2.5rem;
                bottom: 0.5rem;
                width: 2px;
                background: #e5e7eb;
            }
        </style>
    </head>
    <body class="h-full bg-[#f8f7f5] font-sans">
        <div class="flex h-full">
            <%@ include file="_nav.jsp" %>

            <main class="flex-1 overflow-y-auto pb-20 md:pb-0">

                <%-- Compute status helpers once --%>
                <c:set var="st" value="${order.orderStatus}"/>
                <c:set var="isNew"       value="${st == 'CREATED'  || st == 'PAID'}"/>
                <c:set var="isPreparing" value="${st == 'MERCHANT_ACCEPTED' || st == 'PREPARING'}"/>
                <c:set var="isReady"     value="${st == 'READY_FOR_PICKUP'  || st == 'PICKED_UP' || st == 'DELIVERING'}"/>
                <c:set var="isDelivered" value="${st == 'DELIVERED'}"/>
                <c:set var="isCancelled" value="${st == 'CANCELLED' || st == 'MERCHANT_REJECTED' || st == 'FAILED'}"/>

                <%-- Timeline step states --%>
                <c:set var="step2Done"    value="${isReady || isDelivered}"/>
                <c:set var="step2Current" value="${isPreparing}"/>
                <c:set var="step3Done"    value="${isDelivered}"/>
                <c:set var="step3Current" value="${isReady}"/>

                <div class="sticky top-0 bg-white/90 backdrop-blur-sm border-b border-gray-100 px-6 py-4 z-10 flex items-center gap-4">
                    <a href="${pageContext.request.contextPath}/merchant/orders"
                       class="w-9 h-9 flex items-center justify-center rounded-xl border border-gray-200 text-gray-600 hover:border-primary hover:text-primary transition-all">
                        <span class="material-symbols-outlined text-[20px]">arrow_back</span>
                    </a>
                    <div class="flex-1 min-w-0">
                        <h1 class="font-bold text-gray-900 text-lg">Đơn #${order.orderCode}</h1>
                        <p class="text-xs text-gray-400">
                        <fmt:formatDate value="${order.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                        </p>
                    </div>
                    <div class="flex items-center gap-2.5 shrink-0">
                        <div class="w-9 h-9 rounded-full bg-primary/10 text-primary font-bold text-sm flex items-center justify-center uppercase">
                            ${fn:toUpperCase(fn:substring(sessionScope.merchantName, 0, 1))}
                        </div>
                        <span class="hidden md:block text-sm font-semibold text-gray-700 max-w-[140px] truncate">${sessionScope.merchantName}</span>
                    </div>
                </div>

                <div class="p-4 md:p-8 max-w-7xl mx-auto">
                    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">

                        <div class="space-y-4">
                            <div class="bg-white rounded-2xl shadow-xl border border-gray-100" style="border-top: 8px solid #c86601;">
                                <div class="p-6 text-center border-b border-dashed border-gray-200">
                                    <h2 class="text-2xl font-black tracking-wider text-gray-900">#${order.orderCode}</h2>
                                    <p class="text-gray-400 text-sm mt-1">
                                    <fmt:formatDate value="${order.createdAt}" pattern="HH:mm – dd/MM/yyyy"/>
                                    </p>
                                    <span class="inline-block mt-3 px-4 py-1.5 rounded-full text-sm font-semibold
                                          ${isNew ? 'bg-blue-100 text-blue-700' :
                                            isPreparing ? 'bg-yellow-100 text-yellow-700' :
                                            isReady ? 'bg-green-100 text-green-700' :
                                            isDelivered ? 'bg-gray-100 text-gray-600' : 'bg-red-100 text-red-600'}">
                                        <c:choose>
                                            <c:when test="${isNew}">🔵 Đơn mới</c:when>
                                            <c:when test="${st == 'MERCHANT_ACCEPTED'}">🟡 Đã nhận</c:when>
                                            <c:when test="${st == 'PREPARING'}">🟡 Đang nấu</c:when>
                                            <c:when test="${st == 'READY_FOR_PICKUP'}">🟢 Sẵn sàng lấy hàng</c:when>
                                            <c:when test="${st == 'PICKED_UP' || st == 'DELIVERING'}">🟣 Đang giao</c:when>
                                            <c:when test="${isDelivered}">✅ Hoàn tất</c:when>
                                            <c:when test="${isCancelled}">❌ Đã hủy</c:when>
                                            <c:otherwise>${order.orderStatus}</c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>

                                <div class="p-6 space-y-3">
                                    <c:forEach var="item" items="${items}">
                                        <div class="flex items-center gap-3">
                                            <span class="w-8 h-8 flex-shrink-0 flex items-center justify-center bg-primary/10 text-primary font-bold text-sm rounded-lg">
                                                ${item.quantity}
                                            </span>
                                            <span class="flex-1 font-medium text-gray-800 text-sm leading-snug">${item.itemNameSnapshot}</span>
                                            <span class="font-semibold text-gray-900 text-sm whitespace-nowrap">
                                                <fmt:formatNumber value="${item.unitPriceSnapshot * item.quantity}" type="number" groupingUsed="true"/>đ
                                            </span>
                                        </div>
                                        <c:if test="${not empty item.note}">
                                            <p class="ml-11 text-red-500 text-xs italic">↳ ${item.note}</p>
                                        </c:if>
                                    </c:forEach>

                                    <div class="border-t border-dashed border-gray-200 pt-4 mt-4 space-y-2">
                                        <c:if test="${order.subtotalAmount > 0 and order.subtotalAmount != order.totalAmount}">
                                            <div class="flex justify-between text-sm text-gray-500">
                                                <span>Tạm tính</span>
                                                <span><fmt:formatNumber value="${order.subtotalAmount}" type="number" groupingUsed="true"/>đ</span>
                                            </div>
                                        </c:if>
                                        <c:if test="${order.deliveryFee > 0}">
                                            <div class="flex justify-between text-sm text-gray-500">
                                                <span>Phí giao hàng</span>
                                                <span><fmt:formatNumber value="${order.deliveryFee}" type="number" groupingUsed="true"/>đ</span>
                                            </div>
                                        </c:if>
                                        <c:if test="${order.discountAmount > 0}">
                                            <div class="flex justify-between text-sm text-green-600">
                                                <span>Giảm giá</span>
                                                <span>−<fmt:formatNumber value="${order.discountAmount}" type="number" groupingUsed="true"/>đ</span>
                                            </div>
                                        </c:if>
                                        <div class="flex justify-between font-bold text-lg pt-2 border-t border-gray-100">
                                            <span>Tổng cộng</span>
                                            <span class="text-primary">
                                                <fmt:formatNumber value="${order.totalAmount}" type="number" groupingUsed="true"/>đ
                                            </span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="space-y-3">
                                <c:if test="${isNew}">
                                    <button type="button" onclick="openPrepModalDetail()"
                                            class="w-full flex items-center justify-center gap-2 px-6 py-3 bg-primary text-white font-bold rounded-xl hover:bg-primary-dark shadow-lg shadow-primary/20 transition-all">
                                        <span class="material-symbols-outlined">skillet</span>
                                        Nhận đơn &amp; Nấu
                                    </button>
                                    <button type="button" onclick="openCancelModalDetail()"
                                            class="w-full flex items-center justify-center gap-2 px-6 py-3 border-2 border-red-200 text-red-600 font-semibold rounded-xl hover:bg-red-50 transition-all">
                                        <span class="material-symbols-outlined">cancel</span>
                                        Từ chối đơn
                                    </button>
                                </c:if>
                                <c:if test="${isPreparing}">
                                    <form method="POST" action="${pageContext.request.contextPath}/merchant/orders/detail">
                                        <input type="hidden" name="orderId" value="${order.id}"/>
                                        <input type="hidden" name="action" value="ready"/>
                                        <button type="submit"
                                                class="w-full flex items-center justify-center gap-2 px-6 py-3 bg-green-600 text-white font-bold rounded-xl hover:bg-green-700 shadow-lg shadow-green-500/20 transition-all">
                                            <span class="material-symbols-outlined">check_circle</span>
                                            Báo Sẵn sàng
                                        </button>
                                    </form>
                                </c:if>
                                <c:if test="${not isCancelled and not isDelivered}">
                                    <a href="${pageContext.request.contextPath}/merchant/refund?orderId=${order.id}"
                                       class="w-full flex items-center justify-center gap-2 px-6 py-3 border-2 border-gray-300 text-gray-700 font-semibold rounded-xl hover:border-red-300 hover:text-red-600 transition-all">
                                        <span class="material-symbols-outlined">currency_exchange</span>
                                        Hoàn tiền / Hủy món
                                    </a>
                                </c:if>
                            </div>
                        </div>

                        <div class="lg:col-span-2 space-y-6">

                            <div class="bg-white rounded-2xl shadow-sm border border-gray-200 p-6">
                                <h3 class="font-bold text-gray-900 text-base mb-4 flex items-center gap-2">
                                    <span class="material-symbols-outlined text-primary text-xl">local_shipping</span>
                                    Thông tin giao nhận
                                </h3>
                                <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                                    <div class="bg-blue-50/50 rounded-xl p-4 border border-blue-100">
                                        <p class="text-xs font-semibold text-blue-400 uppercase tracking-wide mb-3">Khách hàng</p>
                                        <div class="flex items-start gap-3">
                                            <div class="w-10 h-10 rounded-full bg-blue-100 text-blue-600 font-bold text-lg flex items-center justify-center flex-shrink-0">
                                                <c:choose>
                                                    <c:when test="${not empty order.receiverName}">
                                                        ${fn:toUpperCase(fn:substring(order.receiverName, 0, 1))}
                                                    </c:when>
                                                    <c:otherwise>?</c:otherwise>
                                                </c:choose>
                                            </div>
                                            <div class="flex-1 min-w-0">
                                                <p class="font-semibold text-gray-900">${order.receiverName}</p>
                                                <p class="text-sm text-gray-500 flex items-center gap-1 mt-0.5">
                                                    <span class="material-symbols-outlined text-[14px]">phone</span>
                                                    ${order.receiverPhone}
                                                </p>
                                                <p class="text-sm text-gray-500 flex items-start gap-1 mt-1">
                                                    <span class="material-symbols-outlined text-[14px] mt-0.5">location_on</span>
                                                    <span class="leading-snug">${order.deliveryAddressLine}</span>
                                                </p>
                                                <c:if test="${not empty order.deliveryNote}">
                                                    <p class="text-xs text-amber-700 bg-amber-50 rounded-lg px-2 py-1.5 mt-2 border border-amber-200">
                                                        <span class="font-semibold">Ghi chú:</span> ${order.deliveryNote}
                                                    </p>
                                                </c:if>
                                            </div>
                                        </div>
                                        <c:if test="${order.customerUserId > 0}">
                                            <a href="${pageContext.request.contextPath}/merchant/chat?userId=${order.customerUserId}"
                                               class="mt-3 w-full flex items-center justify-center gap-1.5 py-2 rounded-lg bg-blue-600 text-white text-sm font-semibold hover:bg-blue-700 transition-colors">
                                                <span class="material-symbols-outlined text-base">chat</span>
                                                Chat
                                            </a>
                                        </c:if>
                                    </div>

                                    <c:choose>
                                        <c:when test="${order.shipperUserId > 0}">
                                            <div class="bg-green-50/50 rounded-xl p-4 border border-green-100">
                                                <p class="text-xs font-semibold text-green-400 uppercase tracking-wide mb-3">Tài xế</p>
                                                <div class="flex items-center gap-3">
                                                    <div class="w-10 h-10 rounded-full bg-green-100 text-green-600 flex items-center justify-center flex-shrink-0">
                                                        <span class="material-symbols-outlined">directions_bike</span>
                                                    </div>
                                                    <div>
                                                        <p class="font-semibold text-gray-900">Đã có tài xế</p>
                                                        <p class="text-sm text-gray-500">Mã #${order.shipperUserId}</p>
                                                    </div>
                                                </div>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="rounded-xl p-4 border-2 border-dashed border-gray-200">
                                                <p class="text-xs font-semibold text-gray-400 uppercase tracking-wide mb-3">Tài xế</p>
                                                <div class="flex flex-col items-center justify-center py-4 text-center">
                                                    <span class="material-symbols-outlined text-4xl text-gray-200 mb-2">directions_bike</span>
                                                    <p class="text-sm font-medium text-gray-400">Đang tìm tài xế...</p>
                                                </div>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <div class="bg-white rounded-2xl shadow-sm border border-gray-200 p-6">
                                <h3 class="font-bold text-gray-900 text-base mb-6 flex items-center gap-2">
                                    <span class="material-symbols-outlined text-primary text-xl">timeline</span>
                                    Trạng thái đơn hàng
                                </h3>

                                <div class="relative">
                                    <div class="timeline-line"></div>

                                    <div class="space-y-7">
                                        <c:choose>
                                            <%-- ── CANCELLED timeline ── --%>
                                            <c:when test="${isCancelled}">
                                                <div class="flex items-start gap-4">
                                                    <div class="w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0 z-10 relative bg-red-500 text-white">
                                                        <span class="material-symbols-outlined text-[18px]">cancel</span>
                                                    </div>
                                                    <div class="pt-1.5">
                                                        <p class="font-semibold text-red-600">Đơn bị hủy</p>
                                                        <c:if test="${not empty order.cancelledAt}">
                                                            <p class="text-xs text-gray-400 mt-0.5">
                                                            <fmt:formatDate value="${order.cancelledAt}" pattern="HH:mm – dd/MM/yyyy"/>
                                                            </p>
                                                        </c:if>
                                                    </div>
                                                </div>

                                                <div class="flex items-start gap-4 opacity-50">
                                                    <div class="w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0 z-10 relative bg-green-500 text-white">
                                                        <span class="material-symbols-outlined text-[18px]">check</span>
                                                    </div>
                                                    <div class="pt-1.5">
                                                        <p class="font-semibold text-gray-900">Đặt hàng thành công</p>
                                                        <p class="text-xs text-gray-400 mt-0.5">
                                                        <fmt:formatDate value="${order.createdAt}" pattern="HH:mm – dd/MM/yyyy"/>
                                                        </p>
                                                    </div>
                                                </div>
                                            </c:when>

                                            <%-- ── NORMAL timeline ── --%>
                                            <c:otherwise>
                                                <div class="flex items-start gap-4 ${isDelivered ? '' : 'opacity-40'}">
                                                    <div class="w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0 z-10 relative ${isDelivered ? 'bg-green-500 text-white' : 'bg-gray-200 text-gray-400'}">
                                                        <span class="material-symbols-outlined text-[18px]">${isDelivered ? 'check' : 'local_shipping'}</span>
                                                    </div>
                                                    <div class="pt-1.5">
                                                        <p class="font-semibold text-gray-900">Giao hàng thành công</p>
                                                        <c:if test="${not empty order.deliveredAt}">
                                                            <p class="text-xs text-gray-400 mt-0.5">
                                                            <fmt:formatDate value="${order.deliveredAt}" pattern="HH:mm – dd/MM/yyyy"/>
                                                            </p>
                                                        </c:if>
                                                    </div>
                                                </div>

                                                <div class="flex items-start gap-4 ${step3Done || step3Current ? '' : 'opacity-40'}">
                                                    <div class="w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0 z-10 relative ${step3Done ? 'bg-green-500 text-white' : step3Current ? 'bg-primary text-white' : 'bg-gray-200 text-gray-400'}">
                                                        <c:choose>
                                                            <c:when test="${step3Done}">
                                                                <span class="material-symbols-outlined text-[18px]">check</span>
                                                            </c:when>
                                                            <c:when test="${step3Current}">
                                                                <span class="material-symbols-outlined text-[18px] animate-pulse">inventory_2</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="material-symbols-outlined text-[18px]">inventory_2</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                    <div class="pt-1.5">
                                                        <p class="font-semibold text-gray-900">Sẵn sàng lấy hàng</p>
                                                        <c:if test="${not empty order.readyAt}">
                                                            <p class="text-xs text-gray-400 mt-0.5">
                                                            <fmt:formatDate value="${order.readyAt}" pattern="HH:mm – dd/MM/yyyy"/>
                                                            </p>
                                                        </c:if>
                                                    </div>
                                                </div>

                                                <div class="flex items-start gap-4 ${step2Done || step2Current ? '' : 'opacity-40'}">
                                                    <div class="w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0 z-10 relative ${step2Done ? 'bg-green-500 text-white' : step2Current ? 'bg-primary text-white' : 'bg-gray-200 text-gray-400'}">
                                                        <c:choose>
                                                            <c:when test="${step2Done}">
                                                                <span class="material-symbols-outlined text-[18px]">check</span>
                                                            </c:when>
                                                            <c:when test="${step2Current}">
                                                                <span class="material-symbols-outlined text-[18px] animate-pulse">skillet</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="material-symbols-outlined text-[18px]">skillet</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                    <div class="pt-1.5">
                                                        <p class="font-semibold text-gray-900">Đang chuẩn bị món</p>
                                                        <c:if test="${not empty order.acceptedAt}">
                                                            <p class="text-xs text-gray-400 mt-0.5">
                                                            <fmt:formatDate value="${order.acceptedAt}" pattern="HH:mm – dd/MM/yyyy"/>
                                                            </p>
                                                        </c:if>
                                                    </div>
                                                </div>

                                                <div class="flex items-start gap-4">
                                                    <div class="w-10 h-10 rounded-full flex items-center justify-center flex-shrink-0 z-10 relative bg-green-500 text-white">
                                                        <span class="material-symbols-outlined text-[18px]">check</span>
                                                    </div>
                                                    <div class="pt-1.5">
                                                        <p class="font-semibold text-gray-900">Đặt hàng thành công</p>
                                                        <p class="text-xs text-gray-400 mt-0.5">
                                                        <fmt:formatDate value="${order.createdAt}" pattern="HH:mm – dd/MM/yyyy"/>
                                                        </p>
                                                    </div>
                                                </div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </div>

                            <c:if test="${not empty order.paymentMethod}">
                                <div class="bg-white rounded-2xl shadow-sm border border-gray-200 p-6">
                                    <h3 class="font-bold text-gray-900 text-base mb-4 flex items-center gap-2">
                                        <span class="material-symbols-outlined text-primary text-xl">payments</span>
                                        Thanh toán
                                    </h3>
                                    <div class="flex items-center justify-between text-sm">
                                        <span class="text-gray-600">Phương thức</span>
                                        <span class="font-semibold text-gray-900">${order.paymentMethod}</span>
                                    </div>
                                </div>
                            </c:if>

                        </div><%-- end right panel --%>
                    </div><%-- end grid --%>
                </div>
            </main>
        </div>

        <div id="prepModalDetail" class="fixed inset-0 z-50 hidden items-center justify-center bg-black/60 backdrop-blur-sm">
            <div class="bg-white rounded-2xl shadow-2xl w-full max-w-sm mx-4 overflow-hidden">
                <div class="bg-gradient-to-r from-primary to-orange-500 px-6 py-4">
                    <h3 class="text-white font-bold text-lg">Thời gian chuẩn bị</h3>
                    <p class="text-orange-100 text-sm mt-0.5">Chọn thời gian dự kiến hoàn thành món</p>
                </div>
                <form id="prepFormDetail" method="POST" action="${pageContext.request.contextPath}/merchant/orders/detail">
                    <input type="hidden" name="action" value="accept"/>
                    <input type="hidden" name="orderId" value="${order.id}"/>
                    <input type="hidden" name="prepMinutes" id="prepMinutesDetail" value="20"/>
                    <div class="p-6">
                        <div class="grid grid-cols-3 gap-3 mb-6">
                            <button type="button" onclick="selectPrepDetail(10)" class="prep-btn-detail py-3 rounded-xl border-2 border-gray-200 text-gray-700 font-semibold text-sm hover:border-primary hover:text-primary transition-all">10 phút</button>
                            <button type="button" onclick="selectPrepDetail(15)" class="prep-btn-detail py-3 rounded-xl border-2 border-gray-200 text-gray-700 font-semibold text-sm hover:border-primary hover:text-primary transition-all">15 phút</button>
                            <button type="button" onclick="selectPrepDetail(20)" class="prep-btn-detail py-3 rounded-xl border-2 border-primary text-primary bg-orange-50 font-semibold text-sm">20 phút</button>
                            <button type="button" onclick="selectPrepDetail(30)" class="prep-btn-detail py-3 rounded-xl border-2 border-gray-200 text-gray-700 font-semibold text-sm hover:border-primary hover:text-primary transition-all">30 phút</button>
                            <button type="button" onclick="selectPrepDetail(45)" class="prep-btn-detail py-3 rounded-xl border-2 border-gray-200 text-gray-700 font-semibold text-sm hover:border-primary hover:text-primary transition-all">45 phút</button>
                            <button type="button" onclick="selectPrepDetail(60)" class="prep-btn-detail py-3 rounded-xl border-2 border-gray-200 text-gray-700 font-semibold text-sm hover:border-primary hover:text-primary transition-all">60 phút</button>
                        </div>
                        <div class="flex gap-3">
                            <button type="button" onclick="closePrepModalDetail()" class="flex-1 py-2.5 border border-gray-200 rounded-xl text-gray-600 font-semibold text-sm hover:bg-gray-50 transition-all">Hủy</button>
                            <button type="submit" class="flex-1 py-2.5 bg-primary text-white rounded-xl font-bold text-sm hover:bg-primary-dark transition-all shadow-lg shadow-primary/20">Xác nhận nhận đơn</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <div id="cancelModalDetail" class="fixed inset-0 z-50 hidden items-center justify-center bg-black/60 backdrop-blur-sm">
            <div class="bg-white rounded-2xl shadow-2xl w-full max-w-sm mx-4 overflow-hidden">
                <div class="bg-gradient-to-r from-red-500 to-red-600 px-6 py-4">
                    <h3 class="text-white font-bold text-lg">Từ chối đơn hàng</h3>
                    <p class="text-red-100 text-sm mt-0.5">Chọn lý do từ chối đơn #${order.orderCode}</p>
                </div>
                <form id="cancelFormDetail" method="POST" action="${pageContext.request.contextPath}/merchant/orders/detail">
                    <input type="hidden" name="action" value="reject"/>
                    <input type="hidden" name="orderId" value="${order.id}"/>
                    <input type="hidden" name="cancelReason" id="cancelReasonDetail" value=""/>
                    <div class="p-6 space-y-3">
                        <button type="button" onclick="selectReasonDetail('Hết nguyên liệu')" class="cancel-reason-btn-detail w-full text-left px-4 py-3 rounded-xl border-2 border-gray-200 text-gray-700 font-medium text-sm hover:border-red-300 hover:bg-red-50 hover:text-red-700 transition-all">🧂 Hết nguyên liệu</button>
                        <button type="button" onclick="selectReasonDetail('Bếp quá bận')" class="cancel-reason-btn-detail w-full text-left px-4 py-3 rounded-xl border-2 border-gray-200 text-gray-700 font-medium text-sm hover:border-red-300 hover:bg-red-50 hover:text-red-700 transition-all">🔥 Bếp quá bận</button>
                        <button type="button" onclick="selectReasonDetail('Cửa hàng đóng sớm')" class="cancel-reason-btn-detail w-full text-left px-4 py-3 rounded-xl border-2 border-gray-200 text-gray-700 font-medium text-sm hover:border-red-300 hover:bg-red-50 hover:text-red-700 transition-all">🏪 Cửa hàng đóng sớm</button>
                        <button type="button" onclick="selectReasonDetail('Ngoài khu vực giao hàng')" class="cancel-reason-btn-detail w-full text-left px-4 py-3 rounded-xl border-2 border-gray-200 text-gray-700 font-medium text-sm hover:border-red-300 hover:bg-red-50 hover:text-red-700 transition-all">📍 Ngoài khu vực giao hàng</button>
                        <button type="button" onclick="closeCancelModalDetail()" class="w-full py-2.5 border border-gray-200 rounded-xl text-gray-500 font-semibold text-sm hover:bg-gray-50 transition-all mt-2">Hủy bỏ</button>
                    </div>
                </form>
            </div>
        </div>

        <script>
            // Feature 5 — Prep time modal (detail page)
            function openPrepModalDetail() {
                const m = document.getElementById('prepModalDetail');
                m.classList.remove('hidden');
                m.classList.add('flex');
            }
            function closePrepModalDetail() {
                const m = document.getElementById('prepModalDetail');
                m.classList.add('hidden');
                m.classList.remove('flex');
            }
            function selectPrepDetail(mins) {
                document.getElementById('prepMinutesDetail').value = mins;
                document.querySelectorAll('.prep-btn-detail').forEach(btn => {
                    btn.classList.remove('border-primary', 'text-primary', 'bg-orange-50');
                    btn.classList.add('border-gray-200', 'text-gray-700');
                });
                event.target.classList.add('border-primary', 'text-primary', 'bg-orange-50');
                event.target.classList.remove('border-gray-200', 'text-gray-700');
            }
            // Close on backdrop click
            document.getElementById('prepModalDetail').addEventListener('click', function (e) {
                if (e.target === this)
                    closePrepModalDetail();
            });

            // Feature 3 — Cancel reason modal (detail page)
            function openCancelModalDetail() {
                const m = document.getElementById('cancelModalDetail');
                m.classList.remove('hidden');
                m.classList.add('flex');
            }
            function closeCancelModalDetail() {
                const m = document.getElementById('cancelModalDetail');
                m.classList.add('hidden');
                m.classList.remove('flex');
            }
            function selectReasonDetail(reason) {
                document.getElementById('cancelReasonDetail').value = reason;
                document.querySelectorAll('.cancel-reason-btn-detail').forEach(btn => {
                    btn.classList.remove('border-red-400', 'bg-red-50', 'text-red-700');
                    btn.classList.add('border-gray-200', 'text-gray-700');
                });
                event.target.classList.add('border-red-400', 'bg-red-50', 'text-red-700');
                event.target.classList.remove('border-gray-200', 'text-gray-700');
                setTimeout(() => document.getElementById('cancelFormDetail').submit(), 300);
            }
            document.getElementById('cancelModalDetail').addEventListener('click', function (e) {
                if (e.target === this)
                    closeCancelModalDetail();
            });
        </script>
    </body>
</html>