<%-- 
    Document   : order-detail
    Created on : Mar 1, 2026, 2:06:39 PM
    Author     : DELL
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chi tiết Đơn hàng - ClickEat Shipper</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body class="bg-gray-100 flex justify-center min-h-screen">

    <div class="bg-white w-full max-w-md shadow-2xl flex flex-col h-screen relative">
        
        <div class="bg-orange-500 text-white px-4 py-4 flex items-center justify-between shadow-md z-10 sticky top-0">
            <a href="${pageContext.request.contextPath}/shipper/dashboard" class="w-10 h-10 flex items-center justify-center hover:bg-orange-600 rounded-full transition">
                <i class="fa-solid fa-arrow-left text-xl"></i>
            </a>
            <h1 class="text-lg font-bold">Chi tiết Đơn hàng</h1>
            <div class="w-10"></div> </div>

        <div class="flex-1 overflow-y-auto pb-32">
            <div class="bg-orange-50 p-6 text-center border-b border-orange-100">
                <p class="text-orange-600 font-bold mb-1">Thu nhập chuyến này</p>
                <h2 class="text-4xl font-black text-orange-500">
                    <fmt:formatNumber value="${order.deliveryFee}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                </h2>
                <p class="text-xs text-gray-500 mt-2">Mã đơn: <span class="font-bold text-gray-700">${order.orderCode}</span></p>
            </div>

            <div class="p-4 space-y-6">
                <div class="relative pl-6 space-y-6 border-l-2 border-dashed border-gray-300 ml-4">
                    
                    <div class="relative">
                        <div class="absolute -left-[35px] top-1 w-6 h-6 bg-blue-100 border-4 border-white rounded-full flex items-center justify-center shadow-sm">
                            <div class="w-2.5 h-2.5 bg-blue-500 rounded-full"></div>
                        </div>
                        <p class="text-xs font-bold text-blue-500 uppercase tracking-wider mb-1">Điểm lấy hàng</p>
                        <h3 class="text-lg font-bold text-gray-900 leading-tight">${merchant.shopName}</h3>
                        <p class="text-sm text-gray-600 mt-1">${merchant.shopAddressLine}</p>
                    </div>

                    <div class="relative">
                        <div class="absolute -left-[35px] top-1 w-6 h-6 bg-orange-100 border-4 border-white rounded-full flex items-center justify-center shadow-sm">
                            <div class="w-2.5 h-2.5 bg-orange-500 rounded-full"></div>
                        </div>
                        <p class="text-xs font-bold text-orange-500 uppercase tracking-wider mb-1">Điểm giao hàng</p>
                        <h3 class="text-lg font-bold text-gray-900 leading-tight">${order.receiverName} - ${order.receiverPhone}</h3>
                        <p class="text-sm text-gray-600 mt-1">${order.deliveryAddressLine}</p>
                        <c:if test="${not empty order.deliveryNote}">
                            <p class="text-sm text-red-500 bg-red-50 p-2 rounded mt-2 border border-red-100 font-medium">
                                <i class="fa-solid fa-note-sticky"></i> ${order.deliveryNote}
                            </p>
                        </c:if>
                    </div>
                </div>

                <hr class="border-gray-100">

                <div>
                    <h3 class="font-bold text-gray-900 mb-4"><i class="fa-solid fa-bag-shopping text-gray-400 mr-2"></i>Chi tiết đơn hàng</h3>
                    <div class="space-y-3">
                        <c:forEach var="item" items="${items}">
                            <div class="flex justify-between items-start text-sm">
                                <div class="flex gap-3">
                                    <span class="font-bold text-orange-500 bg-orange-50 px-2 py-0.5 rounded">${item.quantity}x</span>
                                    <div>
                                        <span class="font-medium text-gray-800">${item.itemNameSnapshot}</span>
                                        <c:if test="${not empty item.note}">
                                            <p class="text-xs text-gray-500 mt-1">Ghi chú: ${item.note}</p>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <hr class="border-gray-100">

                <div class="bg-gray-50 p-4 rounded-xl border border-gray-200">
                    <div class="flex justify-between text-sm mb-2">
                        <span class="text-gray-600">Tổng tiền món ăn</span>
                        <span class="font-bold text-gray-900"><fmt:formatNumber value="${order.subtotalAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></span>
                    </div>
                    <div class="flex justify-between text-sm font-bold pt-2 border-t border-gray-200">
                        <span class="text-red-500">Shipper trả quán:</span>
                        <span class="text-red-500 text-lg"><fmt:formatNumber value="${order.subtotalAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></span>
                    </div>
                </div>

            </div>
        </div>

        <div class="absolute bottom-0 left-0 w-full bg-white p-4 border-t border-gray-200 shadow-[0_-10px_15px_-3px_rgba(0,0,0,0.05)] flex gap-3 z-20">
            <a href="${pageContext.request.contextPath}/shipper/dashboard" class="w-1/3 bg-gray-100 text-gray-700 font-bold py-3.5 rounded-xl text-center hover:bg-gray-200 transition">
                Nhường đơn
            </a>
            <form action="${pageContext.request.contextPath}/shipper/order-detail" method="POST" class="w-2/3">
                <input type="hidden" name="orderId" value="${order.id}">
                <button type="submit" class="w-full bg-orange-500 hover:bg-orange-600 text-white font-bold py-3.5 rounded-xl transition shadow-lg shadow-orange-500/30 text-lg">
                    NHẬN ĐƠN
                </button>
            </form>
        </div>

    </div>

</body>
</html>
