<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Giỏ hàng của bạn - ClickEat</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    </head>
    <body class="bg-gray-50 flex flex-col min-h-screen">

        <jsp:include page="header.jsp" />

        <main class="flex-grow max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10 w-full">
            <h1 class="text-3xl font-bold text-gray-900 mb-8">Giỏ hàng của bạn</h1>

            <c:choose>
                <c:when test="${empty cartItems}">
                    <div class="bg-white p-10 rounded-2xl shadow-sm text-center border border-gray-100">
                        <i class="fa-solid fa-cart-shopping text-6xl text-gray-200 mb-4"></i>
                        <h2 class="text-xl font-medium text-gray-600 mb-4">Giỏ hàng đang trống</h2>
                        <a href="${pageContext.request.contextPath}/home" class="inline-block bg-orange-500 text-white px-6 py-3 rounded-lg font-medium hover:bg-orange-600 transition">
                            Khám phá thực đơn ngay
                        </a>
                    </div>
                </c:when>

                <c:otherwise>
                    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                        <div class="lg:col-span-2 space-y-4">
                            <c:forEach var="item" items="${cartItems}">
                                <c:set var="food" value="${foodDAO.findById(item.foodItemId.intValue())}" />

                                <div class="bg-white p-4 rounded-2xl shadow-sm border border-gray-100 flex items-center gap-4">
                                    <img src="${food.imageUrl}" alt="${food.name}" class="w-20 h-20 object-cover rounded-xl bg-gray-100">

                                    <div class="flex-grow">
                                        <h3 class="text-lg font-bold text-gray-900">${food.name}</h3>
                                        <p class="text-orange-500 font-bold">${item.unitPriceSnapshot} VNĐ</p>
                                    </div>

                                    <div class="flex items-center gap-3 bg-gray-50 px-3 py-1 rounded-lg border border-gray-200">
                                        <span class="font-medium text-gray-700">SL: ${item.quantity}</span>
                                    </div>

                                    <a href="${pageContext.request.contextPath}/cart?action=delete&itemId=${item.id}" 
                                       class="p-2 text-red-500 hover:bg-red-50 rounded-lg transition-colors ml-2"
                                       onclick="return confirm('Bạn có chắc chắn muốn xóa món này không?');">
                                        <i class="fa-solid fa-trash"></i>
                                    </a>
                                </div>
                            </c:forEach>
                        </div>

                        <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 h-fit sticky top-24">
                            <h3 class="text-xl font-bold text-gray-900 mb-4">Tổng cộng</h3>

                            <div class="flex justify-between items-center mb-4 text-gray-600">
                                <span>Tạm tính:</span>
                                <span class="font-bold text-gray-900">${totalMoney} VNĐ</span>
                            </div>

                            <div class="border-t border-gray-100 pt-4 mb-6">
                                <div class="flex justify-between items-center">
                                    <span class="font-bold text-gray-900">Thành tiền:</span>
                                    <span class="font-black text-2xl text-orange-500">${totalMoney} VNĐ</span>
                                </div>
                            </div>

                            <a href="checkout" class="block w-full text-center bg-gray-900 text-white py-3 rounded-xl font-bold hover:bg-gray-800 transition-colors">
                                Tiến hành Thanh toán
                            </a>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </main>

        <jsp:include page="footer.jsp" />

    </body>
</html>