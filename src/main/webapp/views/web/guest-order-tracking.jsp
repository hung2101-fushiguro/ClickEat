<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/responsive-global.css">
        <title>Theo dõi đơn hàng - ClickEat</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    </head>
    <body class="bg-[#f4f5f7] text-gray-900 flex flex-col min-h-screen">
        <jsp:include page="/views/web/header.jsp" />

        <main class="flex-grow max-w-4xl mx-auto w-full px-6 py-10">
            <div class="mb-8 text-center">
                <h1 class="text-3xl font-black mb-2">Tra cứu đơn hàng</h1>
                <p class="text-gray-500">Dành cho khách hàng đặt đơn không cần tài khoản</p>
            </div>

            <!-- Form tìm kiếm -->
            <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 max-w-2xl mx-auto mb-10">
                <form action="${pageContext.request.contextPath}/guest-order-tracking" method="get" class="flex flex-col sm:flex-row gap-3">
                    <div class="relative flex-grow">
                        <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none text-gray-400">
                            <i class="fa-solid fa-hashtag text-lg"></i>
                        </div>
                        <input type="text" name="code" value="${code}" 
                               placeholder="Nhập mã đơn hàng (VD: ORD123...)" required
                               class="w-full pl-11 pr-4 py-4 rounded-xl border border-gray-200 focus:ring-2 focus:ring-orange-500 focus:border-orange-500 outline-none transition font-semibold text-gray-800">
                    </div>
                    <button type="submit" class="px-8 py-4 rounded-xl bg-gray-900 hover:bg-black text-white font-bold whitespace-nowrap transition">
                        Tra cứu
                    </button>
                </form>
                <c:if test="${not empty error}">
                    <div class="mt-4 p-4 rounded-xl bg-red-50 text-red-600 flex gap-3 items-start border border-red-100">
                        <i class="fa-solid fa-circle-exclamation mt-0.5"></i>
                        <span class="text-sm font-medium">${error}</span>
                    </div>
                </c:if>
            </div>

            <c:if test="${searched and not empty order}">
                <div class="mt-8 grid grid-cols-1 md:grid-cols-[2fr_1fr] gap-6">
                    <!-- Chi tiết đơn hàng -->
                    <div class="bg-white rounded-3xl border border-gray-200 p-6">
                        <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6 pb-6 border-b border-gray-100">
                            <div>
                                <h2 class="text-xl font-black mb-1">Mã đơn: ${order.orderCode}</h2>
                                <p class="text-sm text-gray-500">
                                    <i class="fa-regular fa-clock mr-1"></i> 
                                    <fmt:formatDate value="${order.createdAt}" pattern="HH:mm - dd/MM/yyyy"/>
                                </p>
                            </div>
                            <div class="text-right">
                                <span class="inline-block px-4 py-2 rounded-full text-sm font-extrabold
                                    ${order.orderStatus == 'PENDING_PAYMENT' ? 'bg-orange-100 text-orange-600' :
                                      order.orderStatus == 'CREATED' ? 'bg-blue-100 text-blue-600' :
                                      (order.orderStatus == 'DELIVERED' || order.orderStatus == 'COMPLETED') ? 'bg-green-100 text-green-600' :
                                      order.orderStatus == 'CANCELLED' ? 'bg-red-100 text-red-600' : 'bg-gray-100 text-gray-700'}">
                                    ${order.orderStatus}
                                </span>
                            </div>
                        </div>

                        <div class="space-y-4">
                            <h3 class="font-bold text-gray-800">Món đã đặt</h3>
                            <c:forEach var="item" items="${orderItems}">
                                <div class="flex items-center justify-between pb-3 border-b border-dashed border-gray-100 last:border-0">
                                    <div class="flex-grow pr-4">
                                        <div class="font-bold">${empty item.itemNameSnapshot ? 'Món ăn' : item.itemNameSnapshot}</div>
                                        <div class="text-sm text-gray-500">
                                            ${item.quantity} x <fmt:formatNumber value="${item.unitPriceSnapshot}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                                        </div>
                                        <c:if test="${not empty item.selectedSize}">
                                            <div class="text-xs text-gray-500 mt-0.5">Size: ${item.selectedSize}</div>
                                        </c:if>
                                        <c:if test="${not empty item.selectedToppings}">
                                            <div class="text-xs text-gray-500 mt-0.5">Topping: ${item.selectedToppings}</div>
                                        </c:if>
                                    </div>
                                    <div class="font-black text-lg">
                                        <fmt:formatNumber value="${item.unitPriceSnapshot * item.quantity}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                                    </div>
                                </div>
                            </c:forEach>
                        </div>

                        <div class="mt-6 pt-5 border-t border-gray-100 space-y-3">
                            <div class="flex justify-between text-sm">
                                <span class="text-gray-500">Tạm tính</span>
                                <span class="font-bold text-gray-800"><fmt:formatNumber value="${order.subtotalAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ</span>
                            </div>
                            <div class="flex justify-between text-sm">
                                <span class="text-gray-500">Phí giao hàng</span>
                                <span class="font-bold text-gray-800"><fmt:formatNumber value="${order.deliveryFee}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ</span>
                            </div>
                            <c:if test="${order.discountAmount > 0}">
                                <div class="flex justify-between text-sm text-green-600">
                                    <span>Khuyến mãi</span>
                                    <span class="font-bold">-<fmt:formatNumber value="${order.discountAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ</span>
                                </div>
                            </c:if>
                            <div class="flex justify-between items-center pt-3 border-t border-gray-100 mt-3">
                                <span class="text-lg font-black text-gray-900">Tổng cộng</span>
                                <span class="text-2xl font-black text-orange-500"><fmt:formatNumber value="${order.totalAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ</span>
                            </div>
                        </div>
                    </div>

                    <!-- Thông tin giao hàng -->
                    <div class="space-y-6">
                        <div class="bg-white rounded-3xl border border-gray-200 p-6">
                            <h3 class="font-black mb-4 flex items-center gap-2">
                                <i class="fa-regular fa-credit-card text-orange-500"></i> Thanh toán
                            </h3>
                            <div class="text-sm space-y-2">
                                <div class="flex justify-between">
                                    <span class="text-gray-500">Phương thức</span>
                                    <span class="font-bold text-gray-800">${order.paymentMethod}</span>
                                </div>
                                <div class="flex justify-between">
                                    <span class="text-gray-500">Trạng thái</span>
                                    <span class="font-bold ${order.paymentStatus == 'PAID' ? 'text-green-600' : 'text-orange-600'}">
                                        ${order.paymentStatus == 'PAID' ? 'Đã thanh toán' : (order.paymentStatus == 'PENDING' ? 'Đang xử lý' : order.paymentStatus)}
                                    </span>
                                </div>
                            </div>
                        </div>

                        <div class="bg-white rounded-3xl border border-gray-200 p-6">
                            <h3 class="font-black mb-4 flex items-center gap-2">
                                <i class="fa-solid fa-location-dot text-orange-500"></i> Giao đến
                            </h3>
                            <div class="text-sm space-y-2 text-gray-700">
                                <div class="font-bold">${order.receiverName}</div>
                                <div>${order.receiverPhone}</div>
                                <div class="leading-relaxed">
                                    ${order.deliveryAddressLine}<br>
                                    ${order.wardName}, ${order.districtName}, ${order.provinceName}
                                </div>
                                <c:if test="${not empty order.deliveryNote}">
                                    <div class="pt-2 mt-2 border-t border-gray-100 text-gray-500 italic">
                                        " ${order.deliveryNote} "
                                    </div>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </div>
            </c:if>
        </main>
        
        <jsp:include page="/views/web/footer.jsp" />
    </body>
</html>
