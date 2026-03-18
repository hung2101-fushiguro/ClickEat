<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đặt hàng thành công - ClickEat</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; }
        .glass-card {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
    </style>
</head>
<body class="bg-[#f8fafc] min-h-screen flex flex-col">

    <jsp:include page="header.jsp" />

    <main class="flex-grow flex items-center justify-center p-4 py-20">
        <div class="max-w-2xl w-full">
            <!-- Success Animation / Icon -->
            <div class="text-center mb-10">
                <div class="w-24 h-24 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-6 shadow-lg shadow-green-200 animate-bounce">
                    <i class="fa-solid fa-check text-4xl text-green-600"></i>
                </div>
                <h1 class="text-4xl font-black text-gray-900 mb-2">Đặt hàng thành công!</h1>
                <p class="text-gray-500 font-medium text-lg">Cảm ơn bạn đã tin tưởng ClickEat. Đơn hàng của bạn đang được chuẩn bị.</p>
            </div>

            <!-- Order Details Card -->
            <div class="glass-card rounded-[2.5rem] shadow-xl overflow-hidden mb-8 border border-gray-100">
                <div class="bg-gray-900 p-8 text-white flex justify-between items-center">
                    <div>
                        <p class="text-gray-400 text-sm font-bold uppercase tracking-widest mb-1">Mã đơn hàng</p>
                        <h2 class="text-2xl font-black">${order.orderCode}</h2>
                    </div>
                    <div class="text-right">
                        <p class="text-gray-400 text-sm font-bold uppercase tracking-widest mb-1">Ngày đặt</p>
                        <p class="text-lg font-bold"><fmt:formatDate value="${order.createdAt}" pattern="dd/MM/yyyy HH:mm"/></p>
                    </div>
                </div>

                <div class="p-8">
                    <div class="space-y-6 mb-8">
                        <div class="flex items-start gap-4">
                            <div class="w-10 h-10 bg-orange-50 text-orange-500 rounded-2xl flex items-center justify-center shrink-0">
                                <i class="fa-solid fa-location-dot"></i>
                            </div>
                            <div>
                                <p class="text-sm text-gray-400 font-bold uppercase mb-1">Địa chỉ giao hàng</p>
                                <p class="text-gray-900 font-bold">${order.receiverName} - ${order.receiverPhone}</p>
                                <p class="text-gray-600">${order.deliveryAddressLine}</p>
                            </div>
                        </div>

                        <div class="flex items-start gap-4">
                            <div class="w-10 h-10 bg-blue-50 text-blue-500 rounded-2xl flex items-center justify-center shrink-0">
                                <i class="fa-solid fa-credit-card"></i>
                            </div>
                            <div>
                                <p class="text-sm text-gray-400 font-bold uppercase mb-1">Phương thức thanh toán</p>
                                <p class="text-gray-900 font-bold">${order.paymentMethod == 'COD' ? 'Tiền mặt khi nhận hàng' : 'Thanh toán điện tử'}</p>
                            </div>
                        </div>
                    </div>

                    <!-- Items List -->
                    <div class="border-t border-gray-100 pt-8">
                        <h3 class="font-black text-gray-900 mb-4 uppercase tracking-wider text-sm">Chi tiết món ăn</h3>
                        <div class="space-y-4">
                            <c:forEach var="item" items="${items}">
                                <div class="flex justify-between items-center">
                                    <div class="flex items-center gap-3">
                                        <div class="w-8 h-8 bg-gray-100 rounded-lg flex items-center justify-center text-sm font-black text-gray-600">
                                            ${item.quantity}
                                        </div>
                                        <span class="font-bold text-gray-700">${item.itemNameSnapshot}</span>
                                    </div>
                                    <span class="font-bold text-gray-900"><fmt:formatNumber value="${item.unitPriceSnapshot * item.quantity}" pattern="#,###"/>đ</span>
                                </div>
                            </c:forEach>
                        </div>
                    </div>

                    <!-- Summary -->
                    <div class="border-t border-gray-100 mt-8 pt-8 space-y-3">
                        <div class="flex justify-between text-gray-500 font-medium">
                            <span>Tạm tính</span>
                            <span><fmt:formatNumber value="${order.subtotalAmount}" pattern="#,###"/>đ</span>
                        </div>
                        <div class="flex justify-between text-gray-500 font-medium">
                            <span>Phí giao hàng</span>
                            <span><fmt:formatNumber value="${order.deliveryFee}" pattern="#,###"/>đ</span>
                        </div>
                        <div class="flex justify-between items-center pt-2">
                            <span class="text-xl font-black text-gray-900">Tổng cộng</span>
                            <span class="text-3xl font-black text-orange-500"><fmt:formatNumber value="${order.totalAmount}" pattern="#,###"/>đ</span>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Actions -->
            <div class="flex flex-col sm:flex-row gap-4">
                <a href="${pageContext.request.contextPath}/home" class="flex-1 bg-gray-900 text-white py-4 rounded-[1.5rem] font-bold text-center hover:bg-gray-800 transition shadow-lg shadow-gray-200">
                    Tiếp tục mua sắm
                </a>
                <a href="${pageContext.request.contextPath}/account/orders" class="flex-1 bg-white text-gray-900 py-4 rounded-[1.5rem] font-bold text-center border border-gray-200 hover:bg-gray-50 transition shadow-sm">
                    Xem lịch sử đơn hàng
                </a>
            </div>
        </div>
    </main>

    <jsp:include page="footer.jsp" />

</body>
</html>
