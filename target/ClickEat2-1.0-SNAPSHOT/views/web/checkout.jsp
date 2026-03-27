<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

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

            <!-- Form riêng để áp voucher -->
            <form id="voucherForm" action="${pageContext.request.contextPath}/checkout" method="GET" class="hidden">
                <input type="hidden" name="shippingAddress" id="voucherShippingAddress" value="${shippingAddress}">
                <input type="hidden" name="note" id="voucherNote" value="${note}">
            </form>

            <!-- Form chính để đặt hàng -->
            <form action="${pageContext.request.contextPath}/checkout" method="POST" id="checkoutForm"
                  class="grid grid-cols-1 lg:grid-cols-3 gap-8">

                <div class="lg:col-span-2 space-y-6">

                    <!-- THÔNG TIN GIAO HÀNG -->
                    <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
                        <h2 class="text-xl font-bold text-gray-900 mb-4 flex items-center gap-2">
                            <i class="fa-solid fa-location-dot text-orange-500"></i> Thông tin giao hàng
                        </h2>

                        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-1">Người nhận</label>
                                <input type="text"
                                       value="${displayFullName}"
                                       readonly
                                       class="w-full border border-gray-300 rounded-lg px-4 py-2 bg-gray-100 text-gray-700 cursor-not-allowed">
                            </div>

                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-1">Số điện thoại</label>
                                <input type="text"
                                       value="${displayPhone}"
                                       readonly
                                       class="w-full border border-gray-300 rounded-lg px-4 py-2 bg-gray-100 text-gray-700 cursor-not-allowed">
                            </div>

                            <c:if test="${not empty displayEmail}">
                                <div class="md:col-span-2">
                                    <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
                                    <input type="text"
                                           value="${displayEmail}"
                                           readonly
                                           class="w-full border border-gray-300 rounded-lg px-4 py-2 bg-gray-100 text-gray-700 cursor-not-allowed">
                                </div>
                            </c:if>

                            <div class="md:col-span-2">
                                <div class="flex items-center justify-between mb-1 gap-3 flex-wrap">
                                    <div class="flex items-center gap-2 flex-wrap">
                                        <label class="block text-sm font-medium text-gray-700">
                                            Địa chỉ chi tiết (Số nhà, Đường...)
                                        </label>

                                        <c:choose>
                                            <c:when test="${deliverySource eq 'GPS'}">
                                                <span class="inline-flex items-center rounded-full bg-green-100 text-green-700 px-2.5 py-1 text-xs font-semibold">
                                                    Đang dùng GPS hiện tại
                                                </span>
                                            </c:when>
                                            <c:when test="${deliverySource eq 'DEFAULT_ADDRESS'}">
                                                <span class="inline-flex items-center rounded-full bg-orange-100 text-orange-700 px-2.5 py-1 text-xs font-semibold">
                                                    Đang dùng địa chỉ mặc định
                                                </span>
                                            </c:when>
                                            <c:when test="${deliverySource eq 'GUEST_ADDRESS'}">
                                                <span class="inline-flex items-center rounded-full bg-blue-100 text-blue-700 px-2.5 py-1 text-xs font-semibold">
                                                    Đang dùng địa chỉ đã lưu
                                                </span>
                                            </c:when>
                                        </c:choose>
                                    </div>

                                    <button type="button"
                                            id="toggleAddressBtn"
                                            onclick="toggleAddressEdit()"
                                            class="text-sm font-semibold text-orange-500 hover:text-orange-600">
                                        Cập nhật
                                    </button>
                                </div>

                                <input type="text"
                                       id="addressLine"
                                       name="addressLine"
                                       value="${shippingAddress}"
                                       readonly
                                       required
                                       placeholder="VD: 12 Nguyễn Huệ, Quận 1, TP.HCM"
                                       class="w-full border border-gray-300 rounded-lg px-4 py-2 bg-gray-100 text-gray-700 outline-none transition">

                                <div class="mt-2 text-xs text-gray-500 leading-5">
                                    <c:choose>
                                        <c:when test="${deliverySource eq 'GPS'}">
                                            Phí giao hàng hiện đang được tính theo vị trí GPS bạn đã cập nhật gần nhất.
                                        </c:when>
                                        <c:when test="${deliverySource eq 'DEFAULT_ADDRESS'}">
                                            Phí giao hàng hiện đang được tính theo địa chỉ mặc định trong tài khoản của bạn.
                                        </c:when>
                                        <c:when test="${deliverySource eq 'GUEST_ADDRESS'}">
                                            Phí giao hàng hiện đang được tính theo địa chỉ giao hàng bạn đã cung cấp.
                                        </c:when>
                                        <c:otherwise>
                                            Hệ thống sẽ dùng địa chỉ này để tính phí giao hàng.
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>

                            <div class="md:col-span-2">
                                <label class="block text-sm font-medium text-gray-700 mb-1">Ghi chú cho tài xế (Tùy chọn)</label>
                                <input type="text"
                                       id="noteInput"
                                       name="note"
                                       value="${note}"
                                       placeholder="VD: Gọi trước khi giao, Giao giờ hành chính..."
                                       class="w-full border border-gray-300 rounded-lg px-4 py-2 focus:ring-orange-500 focus:border-orange-500 outline-none transition">
                            </div>
                        </div>
                    </div>

                    <!-- PHƯƠNG THỨC THANH TOÁN -->
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

                <!-- SIDEBAR -->
                <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 h-fit sticky top-24">
                    <h2 class="text-xl font-bold text-gray-900 mb-4">Tóm tắt đơn hàng</h2>

                    <div class="space-y-4 mb-6 max-h-64 overflow-y-auto pr-2">
                        <c:forEach var="item" items="${checkoutItems}">
                            <c:set var="food" value="${foodDAO.findById(item.foodItemId)}" />
                            <div class="flex justify-between items-start gap-3 text-sm">
                                <div class="flex gap-2 min-w-0">
                                    <span class="font-bold text-gray-900 shrink-0">${item.quantity}x</span>
                                    <span class="text-gray-700">${food.name}</span>
                                </div>
                                <span class="font-medium text-gray-900 shrink-0">
                                    <fmt:formatNumber value="${item.unitPriceSnapshot * item.quantity}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                                </span>
                            </div>
                        </c:forEach>
                    </div>

                    <!-- VOUCHER -->
                    <div class="border-t border-gray-100 pt-4 mt-4">
                        <label class="block text-sm font-semibold text-gray-700 mb-2">Mã giảm giá</label>

                        <p class="text-xs text-gray-500 mb-2">
                            Chỉ voucher đã lưu trong
                            <a href="${pageContext.request.contextPath}/customer/vouchers"
                               class="text-orange-500 font-semibold hover:underline">kho voucher của bạn</a>
                            mới được áp dụng.
                        </p>

                        <div class="flex gap-2">
                            <input type="text"
                                   name="voucherCode"
                                   value="${voucherCode}"
                                   form="voucherForm"
                                   placeholder="Nhập mã đã lưu"
                                   class="flex-1 border border-gray-300 rounded-lg px-4 py-2 focus:ring-orange-500 focus:border-orange-500 outline-none transition">

                            <button type="submit"
                                    form="voucherForm"
                                    class="px-4 py-2 rounded-lg bg-gray-900 hover:bg-black text-white font-bold">
                                Áp dụng
                            </button>
                        </div>

                        <c:if test="${not empty voucherMessage}">
                            <div class="mt-2 text-sm text-green-600 font-medium">${voucherMessage}</div>
                        </c:if>

                        <c:if test="${not empty voucherError}">
                            <div class="mt-2 text-sm text-red-500 font-medium">${voucherError}</div>
                        </c:if>
                    </div>

                    <div class="border-t border-gray-100 pt-4 space-y-3 text-sm mt-4">
                        <div class="flex justify-between text-gray-600">
                            <span>Tạm tính</span>
                            <span>
                                <fmt:formatNumber value="${subTotal}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                            </span>
                        </div>

                        <div class="flex justify-between text-gray-600">
                            <span>Phí giao hàng</span>
                            <span>
                                <fmt:formatNumber value="${deliveryFee}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                            </span>
                        </div>

                        <c:if test="${shippingDistanceKm > 0}">
                            <div class="rounded-xl border border-orange-100 bg-orange-50 px-4 py-3 space-y-2">
                                <div class="flex items-center justify-between text-sm">
                                    <span class="text-gray-700 font-medium">Khoảng cách giao hàng</span>
                                    <span class="font-bold text-orange-600">
                                        <fmt:formatNumber value="${shippingDistanceKm}" type="number" minFractionDigits="1" maxFractionDigits="2"/> km
                                    </span>
                                </div>

                                <c:if test="${shippingDurationMinutes > 0}">
                                    <div class="flex items-center justify-between text-sm">
                                        <span class="text-gray-700 font-medium">Thời gian dự kiến</span>
                                        <span class="font-semibold text-gray-900">
                                            ${shippingDurationMinutes} phút
                                        </span>
                                    </div>
                                </c:if>

                                <div class="text-xs">
                                    <c:choose>
                                        <c:when test="${shippingQuoteFromApi}">
                                            <span class="inline-flex items-center rounded-full bg-green-100 text-green-700 px-2.5 py-1 font-semibold">
                                                Tính bằng tuyến đường thực tế
                                            </span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="inline-flex items-center rounded-full bg-yellow-100 text-yellow-700 px-2.5 py-1 font-semibold">
                                                Đang dùng ước lượng khoảng cách
                                            </span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <c:if test="${not empty shippingQuoteMessage}">
                                    <div class="text-xs text-gray-500 leading-5">
                                        ${shippingQuoteMessage}
                                    </div>
                                </c:if>
                            </div>
                        </c:if>

                        <c:if test="${discountAmount > 0}">
                            <div class="flex justify-between text-green-600">
                                <span>Giảm giá</span>
                                <span>
                                    - <fmt:formatNumber value="${discountAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                                </span>
                            </div>
                        </c:if>

                        <div class="border-t border-dashed border-gray-200 pt-3 flex justify-between items-center">
                            <span class="font-bold text-gray-900">Tổng thanh toán</span>
                            <span class="font-black text-2xl text-orange-500">
                                <fmt:formatNumber value="${totalAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                            </span>
                        </div>
                    </div>

                    <input type="hidden" name="voucherCode" value="${voucherCode}">
                    <input type="hidden" name="discountAmount" value="${discountAmount}">
                    <input type="hidden" name="totalAmount" value="${totalAmount}">

                    <button type="submit"
                            class="w-full mt-6 bg-orange-500 text-white py-3.5 rounded-xl font-bold text-lg hover:bg-orange-600 transition-colors shadow-lg shadow-orange-500/30">
                        Đặt Hàng
                    </button>
                </div>

            </form>
        </main>

        <jsp:include page="footer.jsp" />

        <script>
            let addressEditing = false;

            function toggleAddressEdit() {
                const addressInput = document.getElementById('addressLine');
                const btn = document.getElementById('toggleAddressBtn');

                if (!addressInput || !btn)
                    return;

                if (!addressEditing) {
                    addressInput.removeAttribute('readonly');
                    addressInput.classList.remove('bg-gray-100', 'text-gray-700', 'cursor-not-allowed');
                    addressInput.classList.add('bg-white');
                    addressInput.focus();
                    btn.textContent = 'Xong';
                    addressEditing = true;
                } else {
                    addressInput.setAttribute('readonly', 'readonly');
                    addressInput.classList.add('bg-gray-100', 'text-gray-700');
                    btn.textContent = 'Cập nhật';
                    addressEditing = false;
                }

                syncVoucherForm();
            }

            function syncVoucherForm() {
                const addressInput = document.getElementById('addressLine');
                const noteInput = document.getElementById('noteInput');
                const voucherShippingAddress = document.getElementById('voucherShippingAddress');
                const voucherNote = document.getElementById('voucherNote');

                if (addressInput && voucherShippingAddress) {
                    voucherShippingAddress.value = addressInput.value;
                }
                if (noteInput && voucherNote) {
                    voucherNote.value = noteInput.value;
                }
            }

            document.addEventListener('DOMContentLoaded', function () {
                const addressInput = document.getElementById('addressLine');
                const noteInput = document.getElementById('noteInput');

                if (addressInput) {
                    addressInput.addEventListener('input', syncVoucherForm);
                }

                if (noteInput) {
                    noteInput.addEventListener('input', syncVoucherForm);
                }

                syncVoucherForm();
            });
        </script>
    </body>
</html>