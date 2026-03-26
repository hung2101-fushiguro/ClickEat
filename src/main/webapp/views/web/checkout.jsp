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
        <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
        integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY="
        crossorigin=""/>
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
                            <label class="block text-sm font-medium text-gray-700 mb-1">Địa chỉ giao hàng (nhập để tìm trên bản đồ)</label>
                            <div class="flex gap-2 mb-2">
                                <input type="text"
                                id="addressLine"
                                value="${not empty shippingAddress ? shippingAddress : (not empty user ? user.address : guestAddress)}"
                                required
                                placeholder="VD: 12 Nguyễn Huệ, Quận 1, TP.HCM"
                                class="flex-1 border border-gray-300 rounded-lg px-4 py-2 focus:ring-orange-500 focus:border-orange-500 outline-none transition">
                                <button type="button"
                                id="mapSearchBtn"
                                class="px-4 py-2 rounded-lg bg-gray-900 hover:bg-black text-white font-bold">
                                Tìm
                            </button>
                        </div>
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

                    <c:if test="${not empty suggestedVoucher}">
                        <div class="mb-3 rounded-lg border border-orange-200 bg-orange-50 p-3 text-sm">
                            <div class="font-semibold text-orange-700">
                                Gợi ý tốt nhất: ${suggestedVoucher.code}
                            </div>
                            <div class="text-orange-700 mt-1">
                                Tiết kiệm khoảng
                                <fmt:formatNumber value="${suggestedDiscount}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                                    với đơn hiện tại.
                                </div>
                                <button type="button"
                                data-code="${suggestedVoucher.code}"
                                onclick="applySuggestedVoucher(this)"
                                class="mt-2 text-xs font-bold px-3 py-1.5 rounded-md bg-orange-500 text-white hover:bg-orange-600 transition">
                                Dùng mã này
                            </button>
                        </div>
                    </c:if>

                    <div class="flex gap-2">
                        <input type="text"
                        id="voucherCodeInput"
                        name="voucherCode"
                        value="${voucherCode}"
                        placeholder="Nhập mã voucher"
                        class="flex-1 border border-gray-300 rounded-lg px-4 py-2 focus:ring-orange-500 focus:border-orange-500 outline-none transition">

                        <button type="submit"
                        formaction="${pageContext.request.contextPath}/checkout"
                        formmethod="get"
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
                            </div>

                        </form>
                    </main>

                    <jsp:include page="footer.jsp" />

                    <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
                    integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo="
                    crossorigin=""></script>
                    <script>
                        let checkoutMap;
                        let checkoutMarker;
                        
                        function buildFinalAddress() {
                            const baseAddressInput = document.getElementById('addressLine');
                            const detailInput = document.getElementById('addressDetail');
                            
                            const baseAddress = baseAddressInput && baseAddressInput.value ? baseAddressInput.value.trim() : '';
                            const detailAddress = detailInput && detailInput.value ? detailInput.value.trim() : '';
                            
                            if (detailAddress && baseAddress) {
                                return detailAddress + ', ' + baseAddress;
                            }
                            if (detailAddress) {
                                return detailAddress;
                            }
                            return baseAddress;
                        }
                        
                        function syncVoucherForm() {
                            const addressInput = document.getElementById('addressLine');
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
                                const latText = shippingLat.value ? shippingLat.value : '--';
                                const lngText = shippingLng.value ? shippingLng.value : '--';
                                if (precisionLabel) {
                                    precisionLabel.textContent = 'Tọa độ ghim: ' + latText + ', ' + lngText;
                                }
                                } else if (precisionLabel) {
                                    precisionLabel.textContent = '';
                                }
                            }
                            
                            function saveLocationPreference(lat, lng) {
                                if (!lat || !lng) {
                                    return;
                                }
                                const oneYear = 60 * 60 * 24 * 365;
                                document.cookie = 'ce_home_lat=' + encodeURIComponent(lat) + '; path=/; max-age=' + oneYear + '; SameSite=Lax';
                                document.cookie = 'ce_home_lng=' + encodeURIComponent(lng) + '; path=/; max-age=' + oneYear + '; SameSite=Lax';
                            }
                            
                            function applySuggestedVoucher(button) {
                                const input = document.getElementById('voucherCodeInput');
                                if (!input) {
                                    return;
                                }
                                const code = button ? button.getAttribute('data-code') : '';
                                input.value = code || '';
                            }
                            
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
                                
                                setCheckoutLocation(lat, lng, detail.address || '', true);
                            });
                            
                            function setCheckoutLocation(lat, lng, addressText, moveMap) {
                                const latInput = document.getElementById('shippingLat');
                                const lngInput = document.getElementById('shippingLng');
                                const addressInput = document.getElementById('addressLine');
                                
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
                                
                                if (checkoutMarker) {
                                    checkoutMarker.setLatLng([lat, lng]);
                                }
                                if (checkoutMap && moveMap) {
                                    checkoutMap.setView([lat, lng], Math.max(checkoutMap.getZoom(), 16));
                                }
                                
                                syncVoucherForm();
                            }
                            
                            async function reverseGeocode(lat, lng) {
                                const url = 'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat='
                                + encodeURIComponent(lat)
                                + '&lon=' + encodeURIComponent(lng)
                                + '&accept-language=vi';
                                const response = await fetch(url);
                                if (!response.ok) {
                                    throw new Error('Không thể reverse geocode');
                                }
                                const data = await response.json();
                                return data.display_name || '';
                            }
                            
                            async function geocodeAddress(keyword) {
                                const url = 'https://nominatim.openstreetmap.org/search?format=jsonv2&limit=5&addressdetails=1&accept-language=vi&q='
                                + encodeURIComponent(keyword);
                                const response = await fetch(url);
                                if (!response.ok) {
                                    throw new Error('Không thể tìm địa chỉ');
                                }
                                return response.json();
                            }
                            
                            async function renderNearbySuggestions(centerLat, centerLng) {
                                const wrap = document.getElementById('nearbySuggestionWrap');
                                const list = document.getElementById('nearbySuggestionList');
                                if (!wrap || !list) {
                                    return;
                                }
                                
                                const offsets = [
                                [0, 0],
                                [0.002, 0],
                                [0, 0.002]
                                ];
                                
                                const suggestions = [];
                                for (const [dLat, dLng] of offsets) {
                                    try {
                                        const lat = centerLat + dLat;
                                        const lng = centerLng + dLng;
                                        const address = await reverseGeocode(lat, lng);
                                        if (address) {
                                            suggestions.push({lat, lng, address});
                                        }
                                        } catch (e) {
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
                                        btn.addEventListener('click', () => setCheckoutLocation(item.lat, item.lng, item.address, true));
                                        list.appendChild(btn);
                                    });
                                    
                                    wrap.classList.remove('hidden');
                                }
                                
                                async function runMapSearch() {
                                    const input = document.getElementById('addressLine');
                                    const hint = document.getElementById('mapHint');
                                    if (!input || !input.value.trim()) {
                                        return;
                                    }
                                    
                                    try {
                                        const results = await geocodeAddress(input.value.trim());
                                        if (!results || results.length === 0) {
                                            if (hint) {
                                                hint.textContent = 'Không tìm thấy địa chỉ phù hợp.';
                                            }
                                            return;
                                        }
                                        
                                        const first = results[0];
                                        const lat = parseFloat(first.lat);
                                        const lng = parseFloat(first.lon);
                                        setCheckoutLocation(lat, lng, first.display_name || input.value.trim(), true);
                                        renderNearbySuggestions(lat, lng);
                                        if (hint) {
                                            hint.textContent = 'Đã cập nhật địa chỉ từ kết quả tìm kiếm.';
                                        }
                                        } catch (e) {
                                            if (hint) {
                                                hint.textContent = 'Tìm kiếm tạm lỗi, vui lòng thử lại.';
                                            }
                                        }
                                    }
                                    
                                    function initCheckoutMap() {
                                        const mapEl = document.getElementById('leafletCheckoutMap');
                                        if (!mapEl || typeof L === 'undefined') {
                                            return;
                                        }
                                        
                                        const latInput = document.getElementById('shippingLat');
                                        const lngInput = document.getElementById('shippingLng');
                                        const initialLat = latInput && latInput.value ? parseFloat(latInput.value) : 10.7769;
                                        const initialLng = lngInput && lngInput.value ? parseFloat(lngInput.value) : 106.7009;
                                        
                                        checkoutMap = L.map(mapEl).setView([initialLat, initialLng], 14);
                                        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                                            maxZoom: 19,
                                            attribution: '&copy; OpenStreetMap'
                                        }).addTo(checkoutMap);
                                        
                                        checkoutMarker = L.marker([initialLat, initialLng], {draggable: true}).addTo(checkoutMap);
                                        
                                        checkoutMap.on('click', async function (event) {
                                            const lat = event.latlng.lat;
                                            const lng = event.latlng.lng;
                                            let address = '';
                                            try {
                                                address = await reverseGeocode(lat, lng);
                                                } catch (e) {
                                                }
                                                setCheckoutLocation(lat, lng, address, false);
                                            });
                                            
                                            checkoutMarker.on('dragend', async function () {
                                                const point = checkoutMarker.getLatLng();
                                                let address = '';
                                                try {
                                                    address = await reverseGeocode(point.lat, point.lng);
                                                    } catch (e) {
                                                    }
                                                    setCheckoutLocation(point.lat, point.lng, address, false);
                                                });
                                                
                                                const searchBtn = document.getElementById('mapSearchBtn');
                                                const searchInput = document.getElementById('addressLine');
                                                if (searchBtn) {
                                                    searchBtn.addEventListener('click', runMapSearch);
                                                }
                                                if (searchInput) {
                                                    searchInput.addEventListener('keydown', function (e) {
                                                        if (e.key === 'Enter') {
                                                            e.preventDefault();
                                                            runMapSearch();
                                                        }
                                                    });
                                                }
                                                
                                                if (!(latInput && latInput.value && lngInput && lngInput.value) && navigator.geolocation) {
                                                    navigator.geolocation.getCurrentPosition(async function (position) {
                                                        const lat = position.coords.latitude;
                                                        const lng = position.coords.longitude;
                                                        let address = '';
                                                        try {
                                                            address = await reverseGeocode(lat, lng);
                                                            } catch (e) {
                                                            }
                                                            setCheckoutLocation(lat, lng, address, true);
                                                            renderNearbySuggestions(lat, lng);
                                                        });
                                                        } else {
                                                            renderNearbySuggestions(initialLat, initialLng);
                                                        }
                                                    }
                                                    
                                                    document.addEventListener('DOMContentLoaded', function () {
                                                        const addressInput = document.getElementById('addressLine');
                                                        const addressDetailInput = document.getElementById('addressDetail');
                                                        const noteInput = document.getElementById('noteInput');
                                                        
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
                                                </script>
                                            </body>
                                        </html>