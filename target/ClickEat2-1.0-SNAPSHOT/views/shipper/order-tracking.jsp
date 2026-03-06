<%-- 
    Document   : order-tracking
    Created on : Mar 4, 2026, 4:26:53 PM
    Author     : DELL
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Theo dõi Đơn hàng - ClickEat Shipper</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    </head>
    <body class="bg-gray-100 flex justify-center min-h-screen">

        <div class="bg-gray-50 w-full max-w-md shadow-2xl flex flex-col h-screen relative">

            <div class="bg-white px-4 py-4 flex items-center justify-between shadow-sm z-10 sticky top-0 border-b border-gray-100">
                <a href="${pageContext.request.contextPath}/shipper/dashboard" class="w-10 h-10 flex items-center justify-center text-gray-700 hover:bg-gray-100 rounded-full transition">
                    <i class="fa-solid fa-arrow-left text-xl"></i>
                </a>
                <h1 class="text-lg font-black text-gray-900">Trạng thái giao hàng</h1>
                <div class="w-10"></div>
            </div>

            <div class="flex-1 overflow-y-auto p-4 space-y-4 pb-40">

                <c:choose>
                    <c:when test="${order.orderStatus == 'DELIVERING'}">
                        <div class="bg-blue-500 rounded-2xl p-6 text-white text-center shadow-md">
                            <i class="fa-solid fa-store text-4xl mb-2 animate-bounce"></i>
                            <h2 class="text-2xl font-black">Đang đến nhà hàng</h2>
                            <p class="text-blue-100 text-sm mt-1">Mã đơn: ${order.orderCode}</p>
                        </div>
                    </c:when>
                    <c:when test="${order.orderStatus == 'PICKED_UP'}">
                        <div class="bg-orange-500 rounded-2xl p-6 text-white text-center shadow-md">
                            <i class="fa-solid fa-motorcycle text-4xl mb-2 animate-bounce"></i>
                            <h2 class="text-2xl font-black">Đang giao đến khách</h2>
                            <p class="text-orange-100 text-sm mt-1">Mã đơn: ${order.orderCode}</p>
                        </div>
                    </c:when>
                </c:choose>

                <div class="bg-white rounded-2xl p-5 shadow-sm border border-gray-100">
                    <div class="flex justify-between items-center mb-3">
                        <span class="text-xs font-bold text-blue-500 bg-blue-50 px-2 py-1 rounded uppercase tracking-wider">Lấy hàng tại</span>
                    </div>
                    <h3 class="font-bold text-gray-900 text-lg line-clamp-1">${merchant.shopName}</h3>
                    <p class="text-sm text-gray-500 mt-1 line-clamp-2">${merchant.shopAddressLine}</p>
                    <div class="mt-4 flex gap-3">
                        <a href="tel:${merchant.shopPhone}" class="flex-1 bg-gray-50 hover:bg-gray-100 text-gray-700 py-2.5 rounded-xl text-center font-bold text-sm transition border border-gray-200">
                            <i class="fa-solid fa-phone text-green-500 mr-1"></i> Gọi Quán
                        </a>
                    </div>
                </div>

                <div class="bg-white rounded-2xl p-5 shadow-sm border border-gray-100">
                    <div class="flex justify-between items-center mb-3">
                        <span class="text-xs font-bold text-orange-500 bg-orange-50 px-2 py-1 rounded uppercase tracking-wider">Giao hàng đến</span>
                    </div>
                    <h3 class="font-bold text-gray-900 text-lg">${order.receiverName}</h3>
                    <p class="text-sm text-gray-500 mt-1 line-clamp-2">${order.deliveryAddressLine}</p>

                    <div class="mt-4 flex gap-3">
                        <a href="tel:${order.receiverPhone}" class="flex-1 bg-green-500 hover:bg-green-600 text-white py-2.5 rounded-xl text-center font-bold text-sm transition shadow-sm">
                            <i class="fa-solid fa-phone mr-1"></i> Gọi điện
                        </a>
                        <button class="flex-1 bg-blue-500 hover:bg-blue-600 text-white py-2.5 rounded-xl text-center font-bold text-sm transition shadow-sm">
                            <i class="fa-solid fa-message mr-1"></i> Nhắn tin
                        </button>
                    </div>
                </div>

                <div class="pt-4 pb-2 text-center">
                    <a href="${pageContext.request.contextPath}/shipper/report-issue?orderId=${order.id}" class="text-red-500 font-bold text-sm hover:underline flex items-center justify-center gap-1">
                        <i class="fa-solid fa-triangle-exclamation"></i> Báo cáo sự cố đơn hàng
                    </a>
                </div>

            </div>

            <div class="absolute bottom-0 left-0 w-full bg-white p-4 border-t border-gray-200 shadow-[0_-10px_15px_-3px_rgba(0,0,0,0.05)] z-20">
                <form action="${pageContext.request.contextPath}/shipper/order-tracking" method="POST">
                    <input type="hidden" name="orderId" value="${order.id}">

                    <c:choose>
                        <c:when test="${order.orderStatus == 'DELIVERING'}">
                            <input type="hidden" name="action" value="picked_up">
                            <button type="submit" class="w-full bg-blue-600 hover:bg-blue-700 text-white font-black text-lg py-4 rounded-xl transition shadow-xl">
                                XÁC NHẬN ĐÃ LẤY HÀNG
                            </button>
                        </c:when>
                        <c:when test="${order.orderStatus == 'PICKED_UP'}">
                            <input type="hidden" name="action" value="delivered">
                            <button type="submit" class="w-full bg-green-500 hover:bg-green-600 text-white font-black text-lg py-4 rounded-xl transition shadow-xl flex justify-center items-center gap-2">
                                <i class="fa-solid fa-camera"></i> GIAO HÀNG THÀNH CÔNG
                            </button>
                        </c:when>
                    </c:choose>

                </form>
            </div>

        </div>

    </body>
</html>
