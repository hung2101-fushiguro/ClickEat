<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Thanh toán - ClickEat</title>
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <link rel="shortcut icon" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    </head>
    <body class="bg-gray-50 flex flex-col min-h-screen">

        <jsp:include page="header.jsp" />

        <main class="flex-grow max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10 w-full">
            <h1 class="text-3xl font-bold text-gray-900 mb-8">Thanh toán đơn hàng</h1>

            <form action="${pageContext.request.contextPath}/checkout" method="POST" class="grid grid-cols-1 lg:grid-cols-3 gap-8">

                <div class="lg:col-span-2 space-y-6">

                    <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
                        <h2 class="text-xl font-bold text-gray-900 mb-4 flex items-center gap-2">
                            <i class="fa-solid fa-location-dot text-orange-500"></i> Thông tin giao hàng
                        </h2>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-1">Người nhận</label>
                                <input type="text" name="receiverName" value="${user.fullName}" required class="w-full border border-gray-300 rounded-lg px-4 py-2 focus:ring-orange-500 focus:border-orange-500 outline-none transition">
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-1">Số điện thoại</label>
                                <input type="text" name="receiverPhone" value="${user.phone}" required class="w-full border border-gray-300 rounded-lg px-4 py-2 focus:ring-orange-500 focus:border-orange-500 outline-none transition">
                            </div>
                            <div class="md:col-span-2">
                                <label class="block text-sm font-medium text-gray-700 mb-1">Địa chỉ chi tiết (Số nhà, Đường...)</label>
                                <input type="text" name="addressLine" required placeholder="VD: 12 Nguyễn Huệ, Quận 1, TP.HCM" class="w-full border border-gray-300 rounded-lg px-4 py-2 focus:ring-orange-500 focus:border-orange-500 outline-none transition">
                            </div>
                            <div class="md:col-span-2">
                                <label class="block text-sm font-medium text-gray-700 mb-1">Ghi chú cho tài xế (Tùy chọn)</label>
                                <input type="text" name="note" placeholder="VD: Gọi trước khi giao, Giao giờ hành chính..." class="w-full border border-gray-300 rounded-lg px-4 py-2 focus:ring-orange-500 focus:border-orange-500 outline-none transition">
                            </div>
                        </div>
                    </div>

                    <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
                        <h2 class="text-xl font-bold text-gray-900 mb-4 flex items-center gap-2">
                            <i class="fa-solid fa-credit-card text-orange-500"></i> Phương thức thanh toán
                        </h2>

                        <div class="space-y-3">
                            <label class="flex items-center p-4 border border-gray-200 rounded-xl cursor-pointer hover:bg-gray-50 transition">
                                <input type="radio" name="paymentMethod" value="COD" checked class="w-5 h-5 text-orange-500 focus:ring-orange-500">
                                <span class="ml-3 font-medium text-gray-900">Thanh toán tiền mặt khi nhận hàng (COD)</span>
                                <i class="fa-solid fa-money-bill-wave ml-auto text-green-500 text-xl"></i>
                            </label>

                            <label class="flex items-center p-4 border border-gray-200 rounded-xl cursor-pointer hover:bg-gray-50 transition">
                                <input type="radio" name="paymentMethod" value="VNPAY" class="w-5 h-5 text-orange-500 focus:ring-orange-500">
                                <span class="ml-3 font-medium text-gray-900">Thanh toán trực tuyến qua VNPAY</span>
                                <img src="https://vnpay.vn/s1/statics.vnpay.vn/2023/6/0oxhzjmxbksr1686814746087.png" alt="VNPAY" class="h-6 ml-auto">
                            </label>
                        </div>
                    </div>

                </div>

                <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 h-fit sticky top-24">
                    <h2 class="text-xl font-bold text-gray-900 mb-4">Tóm tắt đơn hàng</h2>

                    <div class="space-y-4 mb-6 max-h-64 overflow-y-auto pr-2">
                        <c:forEach var="item" items="${cartItems}">
                            <c:set var="food" value="${foodDAO.findById(item.foodItemId)}" />
                            <div class="flex justify-between items-start text-sm">
                                <div class="flex gap-2">
                                    <span class="font-bold text-gray-900">${item.quantity}x</span>
                                    <span class="text-gray-700">${food.name}</span>
                                </div>
                                <span class="font-medium text-gray-900">${item.unitPriceSnapshot * item.quantity}đ</span>
                            </div>
                        </c:forEach>
                    </div>

                    <div class="border-t border-gray-100 pt-4 space-y-3 text-sm">
                        <div class="flex justify-between text-gray-600">
                            <span>Tạm tính</span>
                            <span>${subTotal}đ</span>
                        </div>
                        <div class="flex justify-between text-gray-600">
                            <span>Phí giao hàng</span>
                            <span>${deliveryFee}đ</span>
                        </div>
                        <div class="border-t border-dashed border-gray-200 pt-3 flex justify-between items-center">
                            <span class="font-bold text-gray-900">Tổng thanh toán</span>
                            <span class="font-black text-2xl text-orange-500">${totalAmount}đ</span>
                        </div>
                    </div>

                    <input type="hidden" name="totalAmount" value="${totalAmount}">

                    <button type="submit" class="w-full mt-6 bg-orange-500 text-white py-3.5 rounded-xl font-bold text-lg hover:bg-orange-600 transition-colors shadow-lg shadow-orange-500/30">
                        Đặt Hàng
                    </button>
                </div>

            </form>
        </main>

        <jsp:include page="footer.jsp" />

    </body>
</html>