<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Thanh toán - ClickEat</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
        <style>
            body { font-family: 'Inter', sans-serif; }
            .input-focus:focus {
                border-color: #f97316;
                box-shadow: 0 0 0 4px rgba(249, 115, 22, 0.1);
            }
            .step-card {
                transition: all 0.3s ease;
            }
            .step-card:hover {
                border-color: #fed7aa;
            }
        </style>
    </head>
    <body class="bg-[#f8fafc] flex flex-col min-h-screen">

        <jsp:include page="header.jsp" />

        <main class="flex-grow max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12 w-full">
            <div class="flex items-center gap-4 mb-10">
                <h1 class="text-4xl font-black text-gray-900 tracking-tight">Thanh toán</h1>
                <div class="h-1 flex-1 bg-gray-100 rounded-full mt-2"></div>
            </div>

            <c:if test="${not empty toastError}">
                <div class="mb-6 px-4 py-3 bg-red-50 border border-red-200 rounded-xl text-sm text-red-700 font-semibold">
                    ${toastError}
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/checkout" method="POST" class="grid grid-cols-1 lg:grid-cols-3 gap-10">

                <div class="lg:col-span-2 space-y-8">

                    <!-- Giao hàng -->
                    <div class="step-card bg-white p-8 rounded-[2rem] shadow-sm border border-gray-100">
                        <div class="flex items-center gap-4 mb-8">
                            <div class="w-12 h-12 bg-orange-100 text-orange-600 rounded-2xl flex items-center justify-center text-xl shadow-inner">
                                <i class="fa-solid fa-location-dot"></i>
                            </div>
                            <h2 class="text-2xl font-black text-gray-900">Thông tin giao hàng</h2>
                        </div>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <div class="space-y-2">
                                <label class="block text-sm font-bold text-gray-700 ml-1">Người nhận</label>
                                <input type="text" name="receiverName" value="${user.fullName}" required
                                class="w-full bg-gray-50 border border-gray-200 rounded-2xl px-5 py-4 input-focus outline-none transition-all font-medium">
                            </div>
                            <div class="space-y-2">
                                <label class="block text-sm font-bold text-gray-700 ml-1">Số điện thoại</label>
                                <input type="tel" name="receiverPhone" value="${user.phone}" required
                                class="w-full bg-gray-50 border border-gray-200 rounded-2xl px-5 py-4 input-focus outline-none transition-all font-medium">
                            </div>
                            <div class="md:col-span-2 space-y-2">
                                <label class="block text-sm font-bold text-gray-700 ml-1">Địa chỉ giao hàng</label>
                                <input type="text" name="addressLine" required placeholder="Số nhà, tên đường, phường, quận..."
                                class="w-full bg-gray-50 border border-gray-200 rounded-2xl px-5 py-4 input-focus outline-none transition-all font-medium">
                            </div>
                            <div class="md:col-span-2 space-y-2">
                                <label class="block text-sm font-bold text-gray-700 ml-1">Ghi chú cho tài xế</label>
                                <textarea name="note" rows="2" placeholder="VD: Giao trước 5h chiều, gọi khi đến cổng..."
                                class="w-full bg-gray-50 border border-gray-200 rounded-2xl px-5 py-4 input-focus outline-none transition-all font-medium resize-none"></textarea>
                            </div>
                        </div>
                    </div>

                    <!-- Thanh toán -->
                    <div class="step-card bg-white p-8 rounded-[2rem] shadow-sm border border-gray-100">
                        <div class="flex items-center gap-4 mb-8">
                            <div class="w-12 h-12 bg-blue-100 text-blue-600 rounded-2xl flex items-center justify-center text-xl shadow-inner">
                                <i class="fa-solid fa-credit-card"></i>
                            </div>
                            <h2 class="text-2xl font-black text-gray-900">Phương thức thanh toán</h2>
                        </div>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <label class="group relative flex items-center p-6 border-2 border-gray-100 rounded-[1.5rem] cursor-pointer hover:border-orange-200 transition-all has-[:checked]:border-orange-500 has-[:checked]:bg-orange-50/50">
                                <input type="radio" name="paymentMethod" value="COD" checked class="hidden">
                                <div class="flex items-center gap-4 w-full">
                                    <div class="w-6 h-6 border-2 border-gray-300 rounded-full flex items-center justify-center group-hover:border-orange-300 transition-colors bg-white">
                                        <div class="w-3 h-3 bg-orange-500 rounded-full opacity-0 [input:checked+&]:opacity-100 transition-opacity"></div>
                                    </div>
                                    <span class="font-bold text-gray-900">Tiền mặt (COD)</span>
                                    <i class="fa-solid fa-money-bill-wave ml-auto text-green-500 text-2xl"></i>
                                </div>
                            </label>

                            <label class="group relative flex items-center p-6 border-2 border-gray-100 rounded-[1.5rem] cursor-pointer hover:border-orange-200 transition-all has-[:checked]:border-orange-500 has-[:checked]:bg-orange-50/50">
                                <input type="radio" name="paymentMethod" value="VNPAY" class="hidden">
                                <div class="flex items-center gap-4 w-full">
                                    <div class="w-6 h-6 border-2 border-gray-300 rounded-full flex items-center justify-center group-hover:border-orange-300 transition-colors bg-white">
                                        <div class="w-3 h-3 bg-orange-500 rounded-full opacity-0 [input:checked+&]:opacity-100 transition-opacity"></div>
                                    </div>
                                    <span class="font-bold text-gray-900">Ví VNPAY</span>
                                    <img src="https://vnpay.vn/s1/statics.vnpay.vn/2023/6/0oxhzjmxbksr1686814746087.png" alt="VNPAY" class="h-6 ml-auto grayscale group-hover:grayscale-0 transition-all">
                                </div>
                            </label>
                        </div>
                    </div>

                </div>

                <!-- Tóm tắt -->
                <div class="space-y-8">
                    <div class="bg-white p-8 rounded-[2.5rem] shadow-xl border border-gray-100 sticky top-24">
                        <h2 class="text-2xl font-black text-gray-900 mb-6">Đơn hàng</h2>

                        <div class="space-y-5 mb-8 max-h-[400px] overflow-y-auto pr-2 custom-scrollbar">
                            <c:forEach var="item" items="${cartItems}">
                                <div class="flex gap-4 group">
                                    <div class="w-16 h-16 rounded-2xl bg-gray-50 overflow-hidden shrink-0">
                                        <img src="${item.imageUrl}" class="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500">
                                    </div>
                                    <div class="flex-1 min-w-0">
                                        <h4 class="font-bold text-gray-900 truncate text-sm">${item.name}</h4>
                                        <div class="flex justify-between items-center mt-1">
                                            <span class="text-xs text-gray-400 font-bold">${item.quantity} × <fmt:formatNumber value="${item.unitPrice}" pattern="#,###"/>đ</span>
                                            <span class="font-black text-gray-900 text-sm"><fmt:formatNumber value="${item.unitPrice * item.quantity}" pattern="#,###"/>đ</span>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>

                        <div class="bg-gray-50 rounded-3xl p-6 space-y-4">
                            <div class="flex justify-between text-gray-500 font-bold text-sm">
                                <span>Tạm tính</span>
                                <span><fmt:formatNumber value="${subTotal}" pattern="#,###"/>đ</span>
                            </div>
                            <div class="flex justify-between text-gray-500 font-bold text-sm">
                                <span>Phí giao hàng</span>
                                <span><fmt:formatNumber value="${deliveryFee}" pattern="#,###"/>đ</span>
                            </div>
                            <div class="border-t border-dashed border-gray-200 pt-4 flex justify-between items-center">
                                <span class="font-black text-gray-900 uppercase tracking-wider text-xs">Tổng cộng</span>
                                <span class="font-black text-3xl text-orange-500"><fmt:formatNumber value="${totalAmount}" pattern="#,###"/>đ</span>
                            </div>
                        </div>

                        <input type="hidden" name="totalAmount" value="${totalAmount}">

                        <button type="submit" class="w-full mt-8 bg-gray-900 text-white py-5 rounded-[1.5rem] font-bold text-lg hover:bg-orange-500 transition-all shadow-xl hover:shadow-orange-500/40 hover:-translate-y-1">
                            Đặt hàng ngay
                        </button>

                        <p class="text-center text-gray-400 text-xs mt-6 font-medium">
                            Bằng việc đặt hàng, bạn đồng ý với <a href="#" class="text-orange-500 hover:underline">Điều khoản dịch vụ</a> của ClickEat
                        </p>
                    </div>
                </div>

            </form>
        </main>

        <jsp:include page="footer.jsp" />

    </body>
</html>
