<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/responsive-global.css">
        <title>Thanh toán - ClickEat</title>
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <link rel="shortcut icon" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <link rel="shortcut icon" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
        integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY="
        crossorigin=""/>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
        <style>
            #leafletCheckoutMap {
                position: relative;
                z-index: 0;
            }
            
            #leafletCheckoutMap .leaflet-pane,
            #leafletCheckoutMap .leaflet-top,
            #leafletCheckoutMap .leaflet-bottom {
                z-index: 1;
            }
            
            #leafletCheckoutMap .leaflet-control {
                z-index: 2;
            }
        </style>
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
                            value="${not empty user ? user.fullName : guestFullName}"
                            readonly
                            class="w-full border border-gray-300 rounded-lg px-4 py-2 bg-gray-100 text-gray-700 cursor-not-allowed">
                        </div>

                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-1">Số điện thoại</label>
                            <input type="text"
                            value="${not empty user ? user.phone : guestPhone}"
                            readonly
                            class="w-full border border-gray-300 rounded-lg px-4 py-2 bg-gray-100 text-gray-700 cursor-not-allowed">
                        </div>

                        <div class="md:col-span-2">
                            <label class="block text-sm font-medium text-gray-700 mb-1">Tìm địa chỉ trên bản đồ</label>
                            <div class="flex gap-2 mb-2">
                                <input type="search"
                                id="addressSearchInput"
                                autocomplete="off"
                                autocapitalize="off"
                                spellcheck="false"
                                placeholder="Nhập từ khóa địa chỉ để tìm (VD: 12 Nguyễn Huệ, Quận 1)"
                                class="flex-1 border border-gray-300 rounded-lg px-4 py-2 focus:ring-orange-500 focus:border-orange-500 outline-none transition">
                                <button type="button"
                                id="mapSearchBtn"
                                class="px-4 py-2 rounded-lg bg-gray-900 hover:bg-black text-white font-bold">
                                Tìm
                            </button>
                        </div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Địa chỉ giao hàng đã chọn</label>
                        <input type="text"
                        id="addressLine"
                        value="${not empty shippingAddress ? shippingAddress : (not empty user ? user.address : guestAddress)}"
                        required
                        autocomplete="off"
                        placeholder="Chọn từ bản đồ hoặc nhập thủ công địa chỉ chính xác"
                        class="w-full border border-gray-300 rounded-lg px-4 py-2 mb-2 focus:ring-orange-500 focus:border-orange-500 outline-none transition">
                        <input type="text"
                        id="addressDetail"
                        placeholder="Chi tiết bổ sung: số nhà, tầng, tên tòa nhà, cổng..."
                        class="w-full border border-gray-300 rounded-lg px-4 py-2 mb-2 focus:ring-orange-500 focus:border-orange-500 outline-none transition">
                        <div id="nearbySuggestionWrap" class="mb-2 hidden">
                            <p class="text-xs font-semibold text-gray-500 mb-1">Địa chỉ gợi ý gần bạn</p>
                            <div id="nearbySuggestionList" class="flex flex-wrap gap-2"></div>
                        </div>
                        <div id="leafletCheckoutMap" class="w-full h-56 rounded-xl border border-gray-200 overflow-hidden"></div>
                        <p id="mapHint" class="mt-2 text-xs text-gray-500">
                            Nhập địa chỉ và bấm Tìm, hoặc chọn trực tiếp điểm trên bản đồ.
                        </p>
                        <p id="locationPrecision" class="mt-1 text-xs text-gray-500"></p>
                        <input type="hidden" id="addressLineSubmit" name="addressLine" value="${not empty shippingAddress ? shippingAddress : (not empty user ? user.address : guestAddress)}">
                        <input type="hidden" id="shippingLat" name="shippingLat" value="${shippingLat}">
                        <input type="hidden" id="shippingLng" name="shippingLng" value="${shippingLng}">
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
                    <%-- COD: chỉ dành cho customer đã đăng nhập --%>
                    <c:if test="${not empty user}">
                        <label class="flex items-center p-4 border border-gray-200 rounded-xl cursor-pointer hover:bg-gray-50 transition">
                            <input type="radio" name="paymentMethod" value="COD" checked class="w-5 h-5 text-orange-500 focus:ring-orange-500">
                            <span class="ml-3 font-medium text-gray-900">Thanh toán tiền mặt khi nhận hàng (COD)</span>
                            <i class="fa-solid fa-money-bill-wave ml-auto text-green-500 text-xl"></i>
                        </label>
                    </c:if>

                    <%-- VNPAY: luôn hiển thị, pre-check khi là guest --%>
                    <label class="flex items-center p-4 border border-gray-200 rounded-xl cursor-pointer hover:bg-gray-50 transition">
                        <input type="radio" name="paymentMethod" value="VNPAY"
                        ${empty user ? 'checked' : ''} class="w-5 h-5 text-orange-500 focus:ring-orange-500">
                        <span class="ml-3 font-medium text-gray-900">Thanh toán trực tuyến qua VNPAY</span>
                        <img src="https://vnpay.vn/s1/statics.vnpay.vn/2023/6/0oxhzjmxbksr1686814746087.png" alt="VNPAY" class="h-6 ml-auto">
                    </label>

                    <%-- Thông báo cho guest --%>
                    <c:if test="${empty user}">
                        <div class="flex items-start gap-2 rounded-lg border border-blue-100 bg-blue-50 px-4 py-3 text-xs text-blue-700">
                            <i class="fa-solid fa-circle-info mt-0.5 shrink-0"></i>
                            <span>Đơn hàng của khách yêu cầu thanh toán qua <strong>VNPAY</strong>. Sau khi thanh toán bạn sẽ nhận được mã đơn để theo dõi.</span>
                        </div>
                    </c:if>
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
                            <div>
                                <span class="text-gray-700">${food.name}</span>
                                <c:if test="${not empty item.selectedSize}">
                                    <div class="text-[11px] text-gray-500">Size: ${item.selectedSize}</div>
                                </c:if>
                                <c:if test="${not empty item.selectedToppings}">
                                    <div class="text-[11px] text-gray-500">Topping: ${item.selectedToppings}</div>
                                </c:if>
                            </div>
                        </div>
                        <span class="font-medium text-gray-900 shrink-0">
                            <fmt:formatNumber value="${item.unitPriceSnapshot * item.quantity}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                            </span>
                        </div>
                    </c:forEach>
                </div>

                <%-- ===================== VOUCHER SECTION ===================== --%>
                <div class="border-t border-gray-100 pt-4 mt-4">
                    <label class="block text-sm font-semibold text-gray-700 mb-2">
                        <i class="fa-solid fa-tag text-orange-400 mr-1"></i>Mã giảm giá
                    </label>

                    <c:choose>
                        <%-- GUEST: Yêu cầu đăng nhập để dùng voucher --%>
                        <c:when test="${empty user}">
                            <div class="rounded-xl border border-dashed border-orange-300 bg-orange-50 p-4 text-center">
                                <i class="fa-solid fa-lock text-orange-400 text-2xl mb-2"></i>
                                <p class="text-sm font-semibold text-orange-700 mb-1">Voucher chỉ dành cho thành viên</p>
                                <p class="text-xs text-orange-600 mb-3">Đăng nhập để áp dụng mã giảm giá và nhận ưu đãi tốt nhất.</p>
                                <a href="${pageContext.request.contextPath}/login"
                                class="inline-flex items-center gap-2 px-4 py-2 rounded-lg bg-orange-500 text-white text-sm font-bold hover:bg-orange-600 transition">
                                <i class="fa-solid fa-right-to-bracket"></i> Đăng nhập ngay
                            </a>
                        </div>
                    </c:when>

                    <%-- CUSTOMER: Hiển thị đầy đủ voucher UI --%>
                    <c:otherwise>
                        <%-- Card gợi ý voucher tối ưu --%>
                        <c:if test="${not empty suggestedVoucher}">
                            <div class="mb-3 rounded-xl border border-orange-200 bg-gradient-to-br from-orange-50 to-amber-50 p-3 shadow-sm">
                                <div class="flex items-start justify-between gap-2 mb-1">
                                    <div class="flex items-center gap-2">
                                        <span class="flex h-7 w-7 items-center justify-center rounded-full bg-orange-100 text-orange-500 text-xs">
                                            <i class="fa-solid fa-star"></i>
                                        </span>
                                        <span class="text-xs font-bold text-orange-700 uppercase tracking-wide">Gợi ý tối ưu</span>
                                    </div>
                                    <%-- Nút lưu mã / copy --%>
                                    <button type="button"
                                    id="saveVoucherBtn"
                                    data-code="${suggestedVoucher.code}"
                                    onclick="saveVoucherCode(this)"
                                    title="Lưu mã vào clipboard"
                                    class="flex items-center gap-1 text-[11px] font-semibold px-2 py-1 rounded-md border border-orange-200 bg-white text-orange-500 hover:bg-orange-50 transition">
                                    <i class="fa-regular fa-bookmark"></i> Lưu mã
                                </button>
                            </div>

                            <div class="flex items-center gap-2 mb-2">
                                <span class="font-black text-orange-600 text-base tracking-widest">${suggestedVoucher.code}</span>
                            </div>

                            <p class="text-xs text-orange-700 mb-2">
                                Tiết kiệm
                                <span class="font-bold">
                                    <fmt:formatNumber value="${suggestedDiscount}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                                    </span>
                                    với đơn hàng hiện tại.
                                </p>

                                <button type="button"
                                data-code="${suggestedVoucher.code}"
                                onclick="applySuggestedVoucher(this)"
                                class="w-full text-sm font-bold px-3 py-1.5 rounded-lg bg-orange-500 text-white hover:bg-orange-600 transition">
                                <i class="fa-solid fa-circle-check mr-1"></i> Dùng mã này
                            </button>
                        </div>
                    </c:if>

                    <%-- Input nhập mã thủ công --%>
                    <%-- Danh sách Voucher có thể áp dụng --%>
                    <div class="space-y-3 mt-3 max-h-64 overflow-y-auto pr-2">
                        <c:if test="${empty availableVouchers}">
                            <div class="text-sm text-gray-500 italic p-3 bg-gray-50 rounded border border-dashed border-gray-200">Không có mã giảm giá nào phù hợp cho đơn hàng này.</div>
                        </c:if>
                        <c:forEach var="v" items="${availableVouchers}">
                            <label class="flex items-start gap-3 p-3 border border-gray-200 rounded-lg cursor-pointer hover:bg-orange-50 transition relative overflow-hidden group">
                                <input type="checkbox" name="voucherCodes" value="${v.code}"
                                data-type="${v.voucherType}"
                                data-discount-type="${v.discountType}"
                                data-discount-value="${v.discountValue}"
                                data-max-discount="${v.maxDiscountAmount}"
                                class="mt-1 w-4 h-4 text-orange-500 rounded border-gray-300 focus:ring-orange-500 transition-transform hover:scale-110 voucher-checkbox"
                                onclick="handleVoucherSelection(this)">
                                <div class="flex-1">
                                    <div class="flex items-center gap-2 mb-1">
                                        <span class="text-sm font-bold text-gray-900 tracking-widest uppercase">${v.code}</span>
                                        <c:choose>
                                            <c:when test="${v.voucherType eq 'SYSTEM'}">
                                                <span class="text-[10px] font-bold px-1.5 py-0.5 rounded uppercase bg-blue-100 text-blue-700 border border-blue-200 shadow-sm"><i class="fa-solid fa-bolt text-yellow-500 mr-1"></i>Sàn</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-[10px] font-bold px-1.5 py-0.5 rounded uppercase bg-orange-100 text-orange-700 border border-orange-200 shadow-sm"><i class="fa-solid fa-store mr-1"></i>Quán</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="text-xs text-gray-600 line-clamp-2">${v.title}</div>
                                </div>
                            </label>
                        </c:forEach>
                    </div>
                    <%-- Nhắc nhở lưu ý --%>
                    <p class="mt-2 text-[11px] text-gray-400 font-medium">* Chọn tối đa 1 Voucher Quán và 1 Voucher Sàn</p>
                </c:otherwise>
            </c:choose>

            <%-- Upsell (hiển thị cho cả guest và customer) --%>
            <c:if test="${not empty upsellFoods}">
                <div class="mt-4 rounded-lg border border-amber-200 bg-amber-50 p-3">
                    <div class="text-sm font-bold text-amber-700">Thêm món để mở ưu đãi</div>
                    <div class="text-xs text-amber-700 mt-1">
                        Chỉ cần thêm khoảng
                        <fmt:formatNumber value="${upsellTargetAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                            để đạt điều kiện voucher.
                        </div>
                        <div class="mt-3 space-y-2">
                            <c:forEach var="u" items="${upsellFoods}">
                                <div class="flex items-center justify-between gap-2 bg-white border border-amber-100 rounded-lg px-3 py-2">
                                    <div>
                                        <div class="text-sm font-semibold text-gray-800">${u.name}</div>
                                        <div class="text-xs text-gray-500">${u.categoryName}</div>
                                    </div>
                                    <div class="text-right flex flex-col items-end gap-1">
                                        <div class="text-sm font-black text-orange-500">
                                            <fmt:formatNumber value="${u.price}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                                            </div>
                                            <button type="button"
                                            data-food-id="${u.id}"
                                            onclick="quickAddUpsell(this)"
                                            class="inline-flex items-center gap-1 text-[11px] font-bold px-2.5 py-1 rounded-md bg-orange-500 text-white hover:bg-orange-600 transition">
                                            <i class="fa-solid fa-plus"></i> Thêm nhanh
                                        </button>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                        <div class="mt-3">
                            <a href="${pageContext.request.contextPath}/store-detail?id=${upsellMerchantId}"
                            class="inline-flex items-center gap-2 text-xs font-bold px-3 py-2 rounded-md bg-amber-500 text-white hover:bg-amber-600 transition">
                            Chọn thêm món &amp; option <i class="fa-solid fa-arrow-right"></i>
                        </a>
                    </div>
                </div>
            </c:if>
        </div>



        <div class="border-t border-gray-100 pt-4 space-y-3 text-sm mt-4">
            <c:if test="${not empty distanceKm}">
                <div class="flex justify-between text-gray-600">
                    <span>Khoảng cách giao</span>
                    <span>
                        <fmt:formatNumber value="${distanceKm}" type="number" groupingUsed="true" maxFractionDigits="1"/> km
                        </span>
                    </div>
                </c:if>

                <c:if test="${not empty deliveryError}">
                    <div class="rounded-lg border border-red-200 bg-red-50 p-3 text-red-700 text-sm font-medium">
                        ${deliveryError}
                    </div>
                </c:if>

                <div class="flex justify-between text-gray-600">
                    <span>Tạm tính</span>
                    <span>
                        <fmt:formatNumber value="${subTotal}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                        </span>
                    </div>

                    <div class="flex justify-between text-gray-600">
                        <span>Phí cơ bản</span>
                        <span>
                            <fmt:formatNumber value="${baseShippingFee}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                            </span>
                        </div>

                        <div class="flex justify-between text-gray-600">
                            <span>Phụ phí theo km</span>
                            <span>
                                <fmt:formatNumber value="${distanceSurcharge}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                                </span>
                            </div>

                            <div class="flex justify-between text-gray-600">
                                <span>Phí sàn</span>
                                <span>
                                    <fmt:formatNumber value="${platformFee}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                                    </span>
                                </div>

                                <div class="flex justify-between text-gray-600">
                                    <span>Phí giao hàng</span>
                                    <span>
                                        <fmt:formatNumber value="${deliveryFee}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                                        </span>
                                    </div>

                                    <div id="discountContainer" class="flex justify-between text-green-600" style="${discountAmount > 0 ? '' : 'display: none;'}">
                                        <span>Giảm giá</span>
                                        <span id="displayDiscountAmount">
                                            - <fmt:formatNumber value="${discountAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                                        </span>
                                    </div>

                                    <div class="border-t border-dashed border-gray-200 pt-3 flex justify-between items-center">
                                        <span class="font-bold text-gray-900">Tổng thanh toán</span>
                                        <span id="displayTotalAmount" class="font-black text-2xl text-orange-500">
                                            <fmt:formatNumber value="${totalAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                                            </span>
                                        </div>
                                    </div>

                                    <input type="hidden" id="hiddenSubTotal" value="${subTotal}">
                                    <input type="hidden" id="hiddenDeliveryFee" value="${deliveryFee}">
                                    <input type="hidden" name="discountAmount" id="hiddenDiscountAmount" value="${discountAmount}">
                                    <input type="hidden" name="totalAmount" id="hiddenTotalAmount" value="${totalAmount}">
                                    <input type="hidden" name="shippingAddress" id="shippingAddressHidden" value="${not empty shippingAddress ? shippingAddress : (not empty user ? user.address : guestAddress)}">

                                    <c:choose>
                                        <c:when test="${deliveryBlocked}">
                                            <button type="submit"
                                            disabled
                                            class="w-full mt-6 bg-gray-300 text-gray-600 py-3.5 rounded-xl font-bold text-lg cursor-not-allowed">
                                            Vượt phạm vi giao hàng
                                        </button>
                                    </c:when>
                                    <c:otherwise>
                                        <button type="submit"
                                        class="w-full mt-6 bg-orange-500 text-white py-3.5 rounded-xl font-bold text-lg hover:bg-orange-600 transition-colors shadow-lg shadow-orange-500/30">
                                        Đặt Hàng
                                    </button>
                                </c:otherwise>
                            </c:choose>
                            <p id="autoRefreshHint" class="mt-2 text-[11px] text-gray-400">Đơn sẽ tự cập nhật khi đổi vị trí hoặc thêm món gợi ý.</p>
                        </div>

                    </form>
                </main>

                <jsp:include page="footer.jsp" />

                <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
                integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo="
                crossorigin=""></script>
                <script>
                    const checkoutCtx = '${pageContext.request.contextPath}';
                    let checkoutMap;
                    let checkoutMarker;
                    let refreshTimer;
                    let addressSuggestTimer;
                    let lastRefreshKey = '';
                    
                    function buildFinalAddress() {
                        const baseAddressInput = document.getElementById('addressLine');
                        const detailInput = document.getElementById('addressDetail');
                        const baseAddress = baseAddressInput && baseAddressInput.value ? baseAddressInput.value.trim() : '';
                        const detailAddress = detailInput && detailInput.value ? detailInput.value.trim() : '';
                        if (detailAddress && baseAddress) {
                            return detailAddress + ', ' + baseAddress;
                        }
                        return detailAddress || baseAddress;
                    }
                    
                    function saveLocationPreference(lat, lng) {
                        if (!lat || !lng) {
                            return;
                        }
                        const oneYear = 60 * 60 * 24 * 365;
                        document.cookie = 'ce_home_lat=' + encodeURIComponent(lat) + '; path=/; max-age=' + oneYear + '; SameSite=Lax';
                        document.cookie = 'ce_home_lng=' + encodeURIComponent(lng) + '; path=/; max-age=' + oneYear + '; SameSite=Lax';
                    }
                    
                    function syncVoucherForm() {
                        const shippingAddressHidden = document.getElementById('shippingAddressHidden');
                        const addressLineSubmit = document.getElementById('addressLineSubmit');
                        const shippingLat = document.getElementById('shippingLat');
                        const shippingLng = document.getElementById('shippingLng');
                        const precisionLabel = document.getElementById('locationPrecision');
                        const finalAddress = buildFinalAddress();
                        if (shippingAddressHidden) {
                            shippingAddressHidden.value = finalAddress;
                        }
                        if (addressLineSubmit) {
                            addressLineSubmit.value = finalAddress;
                        }
                        if (shippingLat && shippingLng) {
                            saveLocationPreference(shippingLat.value, shippingLng.value);
                            if (precisionLabel) {
                                precisionLabel.textContent = 'Tọa độ ghim: ' + (shippingLat.value || '--') + ', ' + (shippingLng.value || '--');
                            }
                            } else if (precisionLabel) {
                                precisionLabel.textContent = '';
                            }
                        }
                        
                        function refreshCheckoutSummary(reason) {
                            syncVoucherForm();
                            const latInput = document.getElementById('shippingLat');
                            const lngInput = document.getElementById('shippingLng');
                            const voucherInput = document.getElementById('voucherCodeInput');
                            const params = new URLSearchParams();
                            const finalAddress = buildFinalAddress();
                            if (finalAddress) {
                                params.set('addressLine', finalAddress);
                            }
                            if (latInput && latInput.value) {
                                params.set('shippingLat', latInput.value);
                            }
                            if (lngInput && lngInput.value) {
                                params.set('shippingLng', lngInput.value);
                            }
                            if (voucherInput && voucherInput.value && voucherInput.value.trim()) {
                                params.set('voucherCode', voucherInput.value.trim());
                            }
                            const key = params.toString();
                            if (!key || key === lastRefreshKey) {
                                return;
                            }
                            lastRefreshKey = key;
                            window.location.href = checkoutCtx + '/checkout?' + key;
                        }
                        
                        function scheduleCheckoutRefresh(reason) {
                            clearTimeout(refreshTimer);
                            refreshTimer = setTimeout(function () {
                                refreshCheckoutSummary(reason || 'auto');
                            }, 700);
                        }
                        
                        async function quickAddUpsell(button) {
                            if (!button) {
                                return;
                            }
                            const foodId = button.getAttribute('data-food-id');
                            if (!foodId) {
                                return;
                            }
                            const oldHtml = button.innerHTML;
                            button.disabled = true;
                            button.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i>';
                            try {
                                const body = new URLSearchParams({
                                    action: 'ajax-add',
                                    id: foodId,
                                    qty: 1,
                                    selectedSize: '',
                                    selectedToppings: ''
                                });
                                const response = await fetch(checkoutCtx + '/cart', {
                                    method: 'POST',
                                    body
                                });
                                const data = await response.json();
                                if (data && data.success) {
                                    refreshCheckoutSummary('upsell');
                                    return;
                                }
                                alert((data && data.message) ? data.message : 'Không thể thêm món gợi ý.');
                                } catch (error) {
                                    alert('Lỗi kết nối khi thêm món gợi ý.');
                                    } finally {
                                        button.disabled = false;
                                        button.innerHTML = oldHtml;
                                    }
                                }
                                
                                function applySuggestedVoucher(button) {
                                    const rawCode = button ? button.getAttribute('data-code') : '';
                                    const targetCode = rawCode ? rawCode.trim().toUpperCase() : '';
                                    if (!targetCode) {
                                        return;
                                    }
                                    
                                    const checkboxes = Array.from(document.querySelectorAll('.voucher-checkbox'));
                                    const matched = checkboxes.find((cb) => {
                                        const value = cb && cb.value ? cb.value.trim().toUpperCase() : '';
                                        return value === targetCode;
                                    });
                                    
                                    if (!matched) {
                                        alert('Không tìm thấy mã voucher này trong danh sách có thể áp dụng.');
                                        return;
                                    }
                                    
                                    if (!matched.checked) {
                                        matched.checked = true;
                                    }
                                    
                                    handleVoucherSelection(matched);
                                    
                                    const voucherCard = matched.closest('label');
                                    if (voucherCard) {
                                        voucherCard.scrollIntoView({ behavior: 'smooth', block: 'center' });
                                    }
                                }
                                
                                function handleVoucherSelection(checkbox) {
                                    const type = checkbox.getAttribute('data-type');
                                    const checkboxes = document.querySelectorAll('.voucher-checkbox');
                                    if (checkbox.checked) {
                                        checkboxes.forEach(cb => {
                                            if (cb.checked && cb.getAttribute('data-type') === type && cb !== checkbox) {
                                                cb.checked = false;
                                            }
                                        });
                                    }
                                    recalculateDiscount();
                                }
                                
                                function recalculateDiscount() {
                                    const checkboxes = document.querySelectorAll('.voucher-checkbox:checked');
                                    const subTotal = parseFloat(document.getElementById('hiddenSubTotal').value) || 0;
                                    const deliveryFee = parseFloat(document.getElementById('hiddenDeliveryFee').value) || 0;
                                    
                                    let totalDiscount = 0;
                                    checkboxes.forEach(cb => {
                                        const dType = cb.getAttribute('data-discount-type');
                                        const dVal = parseFloat(cb.getAttribute('data-discount-value')) || 0;
                                        const maxD = parseFloat(cb.getAttribute('data-max-discount')) || 0;
                                        
                                        let discount = 0;
                                        if (dType === 'PERCENT') {
                                            discount = (subTotal * dVal) / 100;
                                            if (maxD > 0 && discount > maxD) {
                                                discount = maxD;
                                            }
                                            } else {
                                                discount = dVal;
                                            }
                                            totalDiscount += discount;
                                        });
                                        
                                        if (totalDiscount > subTotal + deliveryFee) {
                                            totalDiscount = subTotal + deliveryFee;
                                            if (totalDiscount > subTotal) { totalDiscount = subTotal; }
                                        }
                                        
                                        const discountContainer = document.getElementById('discountContainer');
                                        const discountEl = document.getElementById('displayDiscountAmount');
                                        const hiddenDiscount = document.getElementById('hiddenDiscountAmount');
                                        
                                        if (totalDiscount > 0) {
                                            discountContainer.style.display = 'flex';
                                            discountEl.innerText = '- ' + new Intl.NumberFormat('vi-VN').format(totalDiscount) + 'đ';
                                            } else {
                                                discountContainer.style.display = 'none';
                                            }
                                            if (hiddenDiscount) hiddenDiscount.value = totalDiscount;
                                            
                                            const finalTotal = subTotal + deliveryFee - totalDiscount;
                                            const totalEl = document.getElementById('displayTotalAmount');
                                            const hiddenTotal = document.getElementById('hiddenTotalAmount');
                                            
                                            if (totalEl) totalEl.innerText = new Intl.NumberFormat('vi-VN').format(finalTotal > 0 ? finalTotal : 0) + 'đ';
                                            if (hiddenTotal) hiddenTotal.value = finalTotal > 0 ? finalTotal : 0;
                                        }
                                        
                                        function saveVoucherCode(button) {
                                            const code = button ? button.getAttribute('data-code') : '';
                                            if (!code) return;
                                            // Copy vào clipboard
                                            if (navigator.clipboard && navigator.clipboard.writeText) {
                                                navigator.clipboard.writeText(code).catch(() => {});
                                                } else {
                                                    // Fallback cho browser cũ
                                                    const tmp = document.createElement('input');
                                                    tmp.value = code;
                                                    document.body.appendChild(tmp);
                                                    tmp.select();
                                                    document.execCommand('copy');
                                                    document.body.removeChild(tmp);
                                                }
                                                // Visual feedback
                                                const oldHtml = button.innerHTML;
                                                button.innerHTML = '<i class="fa-solid fa-check"></i> Đã lưu!';
                                                button.disabled = true;
                                                button.classList.add('text-green-600', 'border-green-300', 'bg-green-50');
                                                button.classList.remove('text-orange-500', 'border-orange-200');
                                                setTimeout(() => {
                                                    button.innerHTML = oldHtml;
                                                    button.disabled = false;
                                                    button.classList.remove('text-green-600', 'border-green-300', 'bg-green-50');
                                                    button.classList.add('text-orange-500', 'border-orange-200');
                                                }, 2000);
                                            }
                                            
                                            
                                            async function reverseGeocode(lat, lng) {
                                                return ClickEatMap4D.reverse(lat, lng);
                                            }
                                            
                                            async function geocodeAddress(keyword) {
                                                return ClickEatMap4D.geocode(keyword, 8);
                                            }
                                            
                                            function normalizeText(text) {
                                                if (!text) {
                                                    return '';
                                                }
                                                return text
                                                .toString()
                                                .normalize('NFD')
                                                .replace(/[\u0300-\u036f]/g, '')
                                                .toLowerCase()
                                                .trim();
                                            }
                                            
                                            function scoreAddressResult(item, normalizedKeyword) {
                                                if (!item || !normalizedKeyword) {
                                                    return 0;
                                                }
                                                const label = normalizeText(item.display_name || '');
                                                if (!label) {
                                                    return 0;
                                                }
                                                let score = 0;
                                                if (label === normalizedKeyword) {
                                                    score += 220;
                                                }
                                                if (label.startsWith(normalizedKeyword)) {
                                                    score += 120;
                                                    } else if (label.includes(normalizedKeyword)) {
                                                        score += 80;
                                                    }
                                                    const tokens = normalizedKeyword.split(/\s+/).filter((token) => token.length > 1);
                                                    tokens.forEach((token) => {
                                                        if (label.includes(token)) {
                                                            score += 14;
                                                        }
                                                    });
                                                    if (/\d+/.test(normalizedKeyword) && /\d+/.test(label)) {
                                                        score += 20;
                                                    }
                                                    return score;
                                                }
                                                
                                                function setCheckoutLocation(lat, lng, addressText, moveMap, triggerRefresh) {
                                                    const latInput = document.getElementById('shippingLat');
                                                    const lngInput = document.getElementById('shippingLng');
                                                    const addressInput = document.getElementById('addressLine');
                                                    const addressSearchInput = document.getElementById('addressSearchInput');
                                                    if (latInput) {
                                                        latInput.value = Number(lat).toFixed(7);
                                                    }
                                                    if (lngInput) {
                                                        lngInput.value = Number(lng).toFixed(7);
                                                    }
                                                    saveLocationPreference(Number(lat).toFixed(7), Number(lng).toFixed(7));
                                                    if (addressText && addressInput) {
                                                        addressInput.value = addressText;
                                                    }
                                                    if (addressText && addressSearchInput) {
                                                        addressSearchInput.value = addressText;
                                                    }
                                                    if (checkoutMarker) {
                                                        checkoutMarker.setLatLng([lat, lng]);
                                                    }
                                                    if (checkoutMap && moveMap) {
                                                        checkoutMap.setView([lat, lng], Math.max(checkoutMap.getZoom(), 16));
                                                    }
                                                    syncVoucherForm();
                                                    if (triggerRefresh === true) {
                                                        scheduleCheckoutRefresh('location');
                                                    }
                                                }
                                                
                                                function hideSuggestionWrap() {
                                                    const wrap = document.getElementById('nearbySuggestionWrap');
                                                    if (wrap) {
                                                        wrap.classList.add('hidden');
                                                    }
                                                }
                                                
                                                function renderAddressSuggestions(results, keyword) {
                                                    const wrap = document.getElementById('nearbySuggestionWrap');
                                                    const list = document.getElementById('nearbySuggestionList');
                                                    const hint = document.getElementById('mapHint');
                                                    if (!wrap || !list) {
                                                        return;
                                                    }
                                                    const normalizedKeyword = normalizeText(keyword);
                                                    const ranked = (results || [])
                                                    .map((item) => {
                                                        const lat = parseFloat(item.lat);
                                                        const lng = parseFloat(item.lng);
                                                        if (Number.isNaN(lat) || Number.isNaN(lng)) {
                                                            return null;
                                                        }
                                                        const label = item.display_name || '';
                                                        if (!label) {
                                                            return null;
                                                        }
                                                        return {
                                                            lat,
                                                            lng,
                                                            label,
                                                            score: scoreAddressResult(item, normalizedKeyword)
                                                        };
                                                    })
                                                    .filter((item) => item)
                                                    .sort((a, b) => b.score - a.score)
                                                    .slice(0, 5);
                                                    list.innerHTML = '';
                                                    if (ranked.length === 0) {
                                                        wrap.classList.add('hidden');
                                                        if (hint) {
                                                            hint.textContent = 'Không tìm thấy địa chỉ phù hợp. Vui lòng nhập rõ hơn.';
                                                        }
                                                        return;
                                                    }
                                                    ranked.forEach((item) => {
                                                        const btn = document.createElement('button');
                                                        btn.type = 'button';
                                                        btn.className = 'px-3 py-1.5 text-xs rounded-full border border-orange-200 bg-orange-50 text-orange-700 hover:bg-orange-100';
                                                        btn.textContent = item.label.length > 70 ? item.label.substring(0, 70) + '...' : item.label;
                                                        btn.title = item.label;
                                                        btn.addEventListener('click', function () {
                                                            setCheckoutLocation(item.lat, item.lng, item.label, true, true);
                                                            wrap.classList.add('hidden');
                                                            if (hint) {
                                                                hint.textContent = 'Đã chọn địa chỉ từ gợi ý.';
                                                            }
                                                        });
                                                        list.appendChild(btn);
                                                    });
                                                    wrap.classList.remove('hidden');
                                                    if (hint) {
                                                        hint.textContent = 'Chọn một địa chỉ đúng trong danh sách gợi ý.';
                                                    }
                                                }
                                                
                                                async function runMapSearch(options) {
                                                    const autoSuggest = !!(options && options.autoSuggest);
                                                    const input = document.getElementById('addressSearchInput');
                                                    const hint = document.getElementById('mapHint');
                                                    if (!input || !input.value.trim()) {
                                                        hideSuggestionWrap();
                                                        return;
                                                    }
                                                    const keyword = input.value.trim();
                                                    try {
                                                        const results = await geocodeAddress(keyword);
                                                        renderAddressSuggestions(results, keyword);
                                                        if (!autoSuggest && results && results.length > 0) {
                                                            const first = results[0];
                                                            const lat = parseFloat(first.lat);
                                                            const lng = parseFloat(first.lng);
                                                            if (!Number.isNaN(lat) && !Number.isNaN(lng)) {
                                                                setCheckoutLocation(lat, lng, first.display_name || keyword, true, false);
                                                                if (hint) {
                                                                    hint.textContent = 'Đã tìm thấy kết quả. Hãy chọn địa chỉ chính xác trong danh sách gợi ý.';
                                                                }
                                                            }
                                                        }
                                                        } catch (error) {
                                                            hideSuggestionWrap();
                                                            if (hint) {
                                                                hint.textContent = ClickEatMap4D.messageFromError(error, 'Tìm kiếm tạm lỗi, vui lòng thử lại.');
                                                            }
                                                        }
                                                    }
                                                    
                                                    async function renderNearbySuggestions(centerLat, centerLng) {
                                                        const wrap = document.getElementById('nearbySuggestionWrap');
                                                        const list = document.getElementById('nearbySuggestionList');
                                                        if (!wrap || !list) {
                                                            return;
                                                        }
                                                        const offsets = [[0, 0], [0.0018, 0], [0, 0.0018]];
                                                        const suggestions = [];
                                                        for (const [dLat, dLng] of offsets) {
                                                            try {
                                                                const lat = centerLat + dLat;
                                                                const lng = centerLng + dLng;
                                                                const address = await reverseGeocode(lat, lng);
                                                                if (address) {
                                                                    suggestions.push({lat, lng, address});
                                                                }
                                                                } catch (ignore) {
                                                                }
                                                            }
                                                            list.innerHTML = '';
                                                            if (suggestions.length === 0) {
                                                                wrap.classList.add('hidden');
                                                                return;
                                                            }
                                                            suggestions.forEach((item) => {
                                                                const btn = document.createElement('button');
                                                                btn.type = 'button';
                                                                btn.className = 'px-3 py-1.5 text-xs rounded-full border border-orange-200 bg-orange-50 text-orange-700 hover:bg-orange-100';
                                                                btn.textContent = item.address.length > 45 ? item.address.substring(0, 45) + '...' : item.address;
                                                                btn.title = item.address;
                                                                btn.addEventListener('click', function () {
                                                                    setCheckoutLocation(item.lat, item.lng, item.address, true, true);
                                                                    wrap.classList.add('hidden');
                                                                });
                                                                list.appendChild(btn);
                                                            });
                                                            wrap.classList.remove('hidden');
                                                        }
                                                        
                                                        function initCheckoutMap() {
                                                            const mapEl = document.getElementById('leafletCheckoutMap');
                                                            const latInput = document.getElementById('shippingLat');
                                                            const lngInput = document.getElementById('shippingLng');
                                                            const hint = document.getElementById('mapHint');
                                                            if (!mapEl || typeof L === 'undefined') {
                                                                return;
                                                            }
                                                            const defaultLat = 10.7769;
                                                            const defaultLng = 106.7009;
                                                            const initialLat = latInput && latInput.value ? parseFloat(latInput.value) : defaultLat;
                                                            const initialLng = lngInput && lngInput.value ? parseFloat(lngInput.value) : defaultLng;
                                                            const initLat = Number.isNaN(initialLat) ? defaultLat : initialLat;
                                                            const initLng = Number.isNaN(initialLng) ? defaultLng : initialLng;
                                                            
                                                            checkoutMap = L.map(mapEl).setView([initLat, initLng], 15);
                                                            ClickEatMap4D.addBaseTileLayer(checkoutMap, {
                                                                attribution: '&copy; ClickEat Maps',
                                                                fallbackAttribution: '&copy; OpenStreetMap contributors',
                                                                maxZoom: 20,
                                                                fallbackMaxZoom: 19
                                                            });
                                                            
                                                            checkoutMarker = L.marker([initLat, initLng], {draggable: true}).addTo(checkoutMap);
                                                            
                                                            checkoutMap.on('click', async function (event) {
                                                                hideSuggestionWrap();
                                                                const lat = event.latlng.lat;
                                                                const lng = event.latlng.lng;
                                                                let address = '';
                                                                try {
                                                                    address = await reverseGeocode(lat, lng);
                                                                    } catch (error) {
                                                                        if (hint) {
                                                                            hint.textContent = ClickEatMap4D.messageFromError(error, 'Không lấy được địa chỉ vị trí đã chọn.');
                                                                        }
                                                                    }
                                                                    setCheckoutLocation(lat, lng, address, false, true);
                                                                    renderNearbySuggestions(lat, lng);
                                                                });
                                                                
                                                                checkoutMarker.on('dragend', async function () {
                                                                    hideSuggestionWrap();
                                                                    const point = checkoutMarker.getLatLng();
                                                                    let address = '';
                                                                    try {
                                                                        address = await reverseGeocode(point.lat, point.lng);
                                                                        } catch (error) {
                                                                            if (hint) {
                                                                                hint.textContent = ClickEatMap4D.messageFromError(error, 'Không lấy được địa chỉ vị trí kéo thả.');
                                                                            }
                                                                        }
                                                                        setCheckoutLocation(point.lat, point.lng, address, false, true);
                                                                        renderNearbySuggestions(point.lat, point.lng);
                                                                    });
                                                                    
                                                                    if (!(latInput && latInput.value && lngInput && lngInput.value) && navigator.geolocation) {
                                                                        navigator.geolocation.getCurrentPosition(async function (position) {
                                                                            const lat = position.coords.latitude;
                                                                            const lng = position.coords.longitude;
                                                                            let address = '';
                                                                            try {
                                                                                address = await reverseGeocode(lat, lng);
                                                                                } catch (ignore) {
                                                                                }
                                                                                setCheckoutLocation(lat, lng, address, true, false);
                                                                                renderNearbySuggestions(lat, lng);
                                                                            });
                                                                            } else {
                                                                                renderNearbySuggestions(initLat, initLng);
                                                                            }
                                                                            
                                                                            if (hint) {
                                                                                hint.textContent = 'Nhập địa chỉ để hiện gợi ý. Trang chỉ cập nhật lại khi bạn chọn vị trí.';
                                                                            }
                                                                        }
                                                                        
                                                                        document.addEventListener('DOMContentLoaded', function () {
                                                                            const addressInput = document.getElementById('addressLine');
                                                                            const addressSearchInput = document.getElementById('addressSearchInput');
                                                                            const addressDetailInput = document.getElementById('addressDetail');
                                                                            const noteInput = document.getElementById('noteInput');
                                                                            const searchBtn = document.getElementById('mapSearchBtn');
                                                                            const nearbySuggestionWrap = document.getElementById('nearbySuggestionWrap');
                                                                            
                                                                            if (searchBtn) {
                                                                                searchBtn.addEventListener('click', function () {
                                                                                    runMapSearch({autoSuggest: false});
                                                                                });
                                                                            }
                                                                            
                                                                            if (addressSearchInput) {
                                                                                addressSearchInput.addEventListener('keydown', function (e) {
                                                                                    if (e.key === 'Enter') {
                                                                                        e.preventDefault();
                                                                                        runMapSearch({autoSuggest: false});
                                                                                    }
                                                                                });
                                                                                
                                                                                addressSearchInput.addEventListener('input', function () {
                                                                                    if (addressSuggestTimer) {
                                                                                        clearTimeout(addressSuggestTimer);
                                                                                    }
                                                                                    const keyword = addressSearchInput.value ? addressSearchInput.value.trim() : '';
                                                                                    if (keyword.length < 3) {
                                                                                        if (nearbySuggestionWrap) {
                                                                                            nearbySuggestionWrap.classList.add('hidden');
                                                                                        }
                                                                                        return;
                                                                                    }
                                                                                    addressSuggestTimer = setTimeout(function () {
                                                                                        runMapSearch({autoSuggest: true});
                                                                                    }, 350);
                                                                                });
                                                                            }
                                                                            
                                                                            if (addressInput) {
                                                                                addressInput.addEventListener('input', syncVoucherForm);
                                                                            }
                                                                            
                                                                            if (addressDetailInput) {
                                                                                addressDetailInput.addEventListener('input', syncVoucherForm);
                                                                            }
                                                                            if (noteInput) {
                                                                                noteInput.addEventListener('input', syncVoucherForm);
                                                                            }
                                                                            
                                                                            syncVoucherForm();
                                                                            initCheckoutMap();
                                                                        });
                                                                        
                                                                        window.addEventListener('ce-location-updated', function (event) {
                                                                            const detail = event && event.detail ? event.detail : null;
                                                                            if (!detail || !detail.lat || !detail.lng) {
                                                                                return;
                                                                            }
                                                                            const lat = parseFloat(detail.lat);
                                                                            const lng = parseFloat(detail.lng);
                                                                            if (Number.isNaN(lat) || Number.isNaN(lng)) {
                                                                                return;
                                                                            }
                                                                            setCheckoutLocation(lat, lng, detail.address || '', true, true);
                                                                        });
                                                                    </script>
                                                                </body>
                                                            </html>