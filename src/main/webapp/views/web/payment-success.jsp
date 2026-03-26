<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đặt đơn thành công - ClickEat</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body class="bg-[#f4f5f7] text-gray-900">
    <jsp:include page="/views/web/header.jsp" />

    <main class="max-w-6xl mx-auto px-6 py-10">
        <div class="text-center">
            <div class="w-16 h-16 mx-auto rounded-full bg-green-100 text-green-600 flex items-center justify-center text-3xl">
                <i class="fa-solid fa-check"></i>
            </div>
            <h1 class="mt-5 text-4xl font-black">Đặt đơn thành công!</h1>
            <p class="mt-2 text-gray-500">Cảm ơn bạn. ClickEat đang chuẩn bị đơn hàng và sẽ giao sớm nhất.</p>

            <div class="mt-6 flex flex-wrap justify-center gap-3">
                <div class="px-5 py-3 rounded-full bg-white border border-gray-200 font-bold">
                    Mã đơn: ${order.orderCode}
                </div>
                <div class="px-5 py-3 rounded-full bg-white border border-gray-200 font-bold">
                    <fmt:formatDate value="${order.createdAt}" pattern="HH:mm • dd/MM/yyyy"/>
                </div>
            </div>
        </div>

        <div class="mt-10 grid grid-cols-1 lg:grid-cols-[minmax(0,1fr)_320px] gap-6">
            <div class="bg-white rounded-3xl border border-gray-200 p-6">
                <div class="flex items-center justify-between mb-5">
                    <h2 class="text-2xl font-black">Đơn hàng của bạn</h2>
                    <span class="px-3 py-1 rounded-full bg-green-100 text-green-600 text-sm font-extrabold">
                        ${order.paymentStatus}
                    </span>
                </div>

                <div class="space-y-4">
                    <c:forEach var="item" items="${orderItems}">
                        <div class="flex items-center justify-between border-b border-gray-100 pb-4">
                            <div>
                                <div class="font-bold text-lg">${empty item.itemNameSnapshot ? 'Món ăn' : item.itemNameSnapshot}</div>
                                <div class="text-sm text-gray-500">Số lượng: ${item.quantity}</div>
                            </div>
                            <div class="font-black text-lg text-orange-500">
                                <fmt:formatNumber value="${item.unitPriceSnapshot * item.quantity}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <div class="mt-6 pt-5 border-t border-dashed border-gray-200 space-y-3">
                    <div class="flex justify-between">
                        <span class="text-gray-500">Hình thức thanh toán</span>
                        <span class="font-bold">${order.paymentMethod}</span>
                    </div>
                    <div class="flex justify-between">
                        <span class="text-gray-500">Tạm tính</span>
                        <span class="font-bold"><fmt:formatNumber value="${order.subtotalAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ</span>
                    </div>
                    <div class="flex justify-between">
                        <span class="text-gray-500">Phí giao hàng</span>
                        <span class="font-bold"><fmt:formatNumber value="${order.deliveryFee}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ</span>
                    </div>
                    <div class="flex justify-between text-2xl">
                        <span class="font-black">Tổng cộng</span>
                        <span class="font-black text-orange-500"><fmt:formatNumber value="${order.totalAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ</span>
                    </div>
                </div>
            </div>

            <div class="bg-white rounded-3xl border border-gray-200 p-6 h-fit">
                <h3 class="text-xl font-black mb-4">Giao đến</h3>
                <div class="space-y-2 text-gray-700">
                    <div class="font-bold">${order.receiverName}</div>
                    <div>${order.receiverPhone}</div>
                    <div>${order.deliveryAddressLine}</div>
                    <div>${order.wardName}, ${order.districtName}, ${order.provinceName}</div>
                    <c:if test="${not empty order.deliveryNote}">
                        <div class="pt-2 text-sm text-gray-500">Ghi chú: ${order.deliveryNote}</div>
                    </c:if>
                </div>
            </div>
        </div>

        <div class="mt-10 text-center">
            <a href="${pageContext.request.contextPath}/home"
               class="inline-flex items-center gap-2 h-14 px-10 rounded-full bg-orange-500 hover:bg-orange-600 text-white font-black shadow">
                <i class="fa-solid fa-house"></i>
                Về trang chủ
            </a>
        </div>
    </main>
</body>
</html>