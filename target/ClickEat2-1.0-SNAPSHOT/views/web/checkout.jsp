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
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <link rel="shortcut icon" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    </head>
    <body class="bg-gray-50 flex flex-col min-h-screen">

        <jsp:include page="header.jsp" />

        <main class="flex-grow max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10 w-full">
            <h1 class="text-3xl font-bold text-gray-900 mb-8">Thanh toán đơn hàng</h1>

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
                                       value="${user.fullName}"
                                       readonly
                                       class="w-full border border-gray-300 rounded-lg px-4 py-2 bg-gray-100 text-gray-700 cursor-not-allowed">
                            </div>

                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-1">Số điện thoại</label>
                                <input type="text"
                                       value="${user.phone}"
                                       readonly
                                       class="w-full border border-gray-300 rounded-lg px-4 py-2 bg-gray-100 text-gray-700 cursor-not-allowed">
                            </div>

                            <!-- Vùng thả xuống Tỉnh/Huyện/Xã -->
                            <div class="md:col-span-2 grid grid-cols-1 md:grid-cols-3 gap-4 mb-2">
                                <div>
                                    <label class="block text-sm font-medium text-gray-700 mb-1">Tỉnh / Thành phố <span class="text-red-500">*</span></label>
                                    <select id="provinceSelect" name="provinceCode" required
                                            class="w-full border border-gray-300 rounded-lg px-4 py-2 bg-white focus:border-orange-500 focus:ring-1 focus:ring-orange-500 text-gray-700 outline-none transition">
                                        <option value="">Chọn Tỉnh / Thành phố</option>
                                    </select>
                                    <input type="hidden" id="provinceName" name="provinceName" value="">
                                </div>
                                <div>
                                    <label class="block text-sm font-medium text-gray-700 mb-1">Quận / Huyện <span class="text-red-500">*</span></label>
                                    <select id="districtSelect" name="districtCode" required disabled
                                            class="w-full border border-gray-300 rounded-lg px-4 py-2 bg-white focus:border-orange-500 focus:ring-1 focus:ring-orange-500 text-gray-700 outline-none transition disabled:bg-gray-100 disabled:cursor-not-allowed">
                                        <option value="">Chọn Quận / Huyện</option>
                                    </select>
                                    <input type="hidden" id="districtName" name="districtName" value="">
                                </div>
                                <div>
                                    <label class="block text-sm font-medium text-gray-700 mb-1">Phường / Xã <span class="text-red-500">*</span></label>
                                    <select id="wardSelect" name="wardCode" required disabled
                                            class="w-full border border-gray-300 rounded-lg px-4 py-2 bg-white focus:border-orange-500 focus:ring-1 focus:ring-orange-500 text-gray-700 outline-none transition disabled:bg-gray-100 disabled:cursor-not-allowed">
                                        <option value="">Chọn Phường / Xã</option>
                                    </select>
                                    <input type="hidden" id="wardName" name="wardName" value="">
                                </div>
                            </div>

                            <div class="md:col-span-2">
                                <label class="block text-sm font-medium text-gray-700 mb-1">Địa chỉ chi tiết (Số nhà, Đường...) <span class="text-red-500">*</span></label>
                                <input type="text"
                                       id="addressLine"
                                       name="addressLine"
                                       value="${shippingAddress}"
                                       required
                                       placeholder="VD: 12 Nguyễn Huệ"
                                       class="w-full border border-gray-300 rounded-lg px-4 py-2 bg-white focus:border-orange-500 focus:ring-1 focus:ring-orange-500 text-gray-700 outline-none transition">
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
                            <div class="flex justify-between items-start gap-3 text-sm">
                                <div class="flex gap-2 min-w-0">
                                    <span class="font-bold text-gray-900 shrink-0">${item.quantity}x</span>
                                    <span class="text-gray-700">${not empty item.name ? item.name : 'Món ăn'}</span>
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

                        <div class="flex gap-2">
                            <input type="text"
                                   name="voucherCode"
                                   value="${voucherCode}"
                                   form="voucherForm"
                                   placeholder="Nhập mã voucher"
                                   class="flex-1 border border-gray-300 rounded-lg px-4 py-2 focus:ring-orange-500 focus:border-orange-500 outline-none transition">

                            <button type="submit"
                                    form="voucherForm"
                                    class="px-4 py-2 rounded-lg bg-gray-900 hover:bg-black text-white font-bold">
                                Áp dụng
                            </button>
                        </div>

                        <form id="voucherForm" action="${pageContext.request.contextPath}/checkout" method="GET">
                            <input type="hidden" name="shippingAddress" id="voucherShippingAddress" value="${shippingAddress}">
                            <input type="hidden" name="note" id="voucherNote" value="${note}">
                        </form>

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


            function syncVoucherForm() {
                const addressInput = document.getElementById('addressLine');
                const noteInput = document.getElementById('noteInput');
                const voucherShippingAddress = document.getElementById('voucherShippingAddress');
                const voucherNote = document.getElementById('voucherNote');

                if (addressInput && voucherShippingAddress) {
                    let provinceName = document.getElementById('provinceSelect').options[document.getElementById('provinceSelect').selectedIndex]?.text || '';
                    let districtName = document.getElementById('districtSelect').options[document.getElementById('districtSelect').selectedIndex]?.text || '';
                    let wardName = document.getElementById('wardSelect').options[document.getElementById('wardSelect').selectedIndex]?.text || '';
                    let addr = addressInput.value || '';
                    
                    let parts = [addr];
                    if (document.getElementById('wardSelect').value) parts.push(wardName);
                    if (document.getElementById('districtSelect').value) parts.push(districtName);
                    if (document.getElementById('provinceSelect').value) parts.push(provinceName);
                    
                    voucherShippingAddress.value = parts.filter(p => p.trim() !== '' && !p.includes("Chọn")).join(', ');
                }
                if (noteInput && voucherNote) {
                    voucherNote.value = noteInput.value;
                }
            }

            document.addEventListener('DOMContentLoaded', function () {
                const provinceSelect = document.getElementById('provinceSelect');
                const districtSelect = document.getElementById('districtSelect');
                const wardSelect = document.getElementById('wardSelect');
                
                const provinceNameInput = document.getElementById('provinceName');
                const districtNameInput = document.getElementById('districtName');
                const wardNameInput = document.getElementById('wardName');
                
                const addressInput = document.getElementById('addressLine');
                const noteInput = document.getElementById('noteInput');

                if (addressInput) addressInput.addEventListener('input', syncVoucherForm);
                if (noteInput) noteInput.addEventListener('input', syncVoucherForm);

                // Fetch Provinces
                fetch('https://provinces.open-api.vn/api/?depth=1')
                    .then(response => response.json())
                    .then(data => {
                        data.forEach(province => {
                            let option = document.createElement('option');
                            option.value = province.code;
                            option.text = province.name;
                            provinceSelect.appendChild(option);
                        });
                    }).catch(err => console.error("Error loading provinces", err));

                provinceSelect.addEventListener('change', function() {
                    provinceNameInput.value = this.options[this.selectedIndex].text;
                    districtSelect.innerHTML = '<option value="">Chọn Quận / Huyện</option>';
                    wardSelect.innerHTML = '<option value="">Chọn Phường / Xã</option>';
                    districtSelect.disabled = true;
                    wardSelect.disabled = true;
                    districtNameInput.value = "";
                    wardNameInput.value = "";
                    
                    const provinceCode = this.value;
                    if (provinceCode) {
                        fetch(`https://provinces.open-api.vn/api/p/${provinceCode}?depth=2`)
                            .then(response => response.json())
                            .then(data => {
                                data.districts.forEach(district => {
                                    let option = document.createElement('option');
                                    option.value = district.code;
                                    option.text = district.name;
                                    districtSelect.appendChild(option);
                                });
                                districtSelect.disabled = false;
                            });
                    }
                    syncVoucherForm();
                });

                districtSelect.addEventListener('change', function() {
                    districtNameInput.value = this.options[this.selectedIndex].text;
                    wardSelect.innerHTML = '<option value="">Chọn Phường / Xã</option>';
                    wardSelect.disabled = true;
                    wardNameInput.value = "";
                    
                    const districtCode = this.value;
                    if (districtCode) {
                        fetch(`https://provinces.open-api.vn/api/d/${districtCode}?depth=2`)
                            .then(response => response.json())
                            .then(data => {
                                data.wards.forEach(ward => {
                                    let option = document.createElement('option');
                                    option.value = ward.code;
                                    option.text = ward.name;
                                    wardSelect.appendChild(option);
                                });
                                wardSelect.disabled = false;
                            });
                    }
                    syncVoucherForm();
                });

                wardSelect.addEventListener('change', function() {
                    wardNameInput.value = this.options[this.selectedIndex].text;
                    syncVoucherForm();
                });

                syncVoucherForm();
            });
        </script>
    </body>
</html>