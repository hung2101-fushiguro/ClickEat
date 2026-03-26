<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Đặt hàng nhanh - ClickEat</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <script src="https://cdn.tailwindcss.com"></script>
          <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
              integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY="
              crossorigin=""/>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    </head>
    <body class="bg-[#f7f5f3] text-gray-900 min-h-screen flex flex-col">

        <jsp:include page="header.jsp" />

        <main class="flex-grow max-w-7xl mx-auto w-full px-6 py-8">
            <a href="javascript:history.back()"
               class="inline-flex items-center gap-2 text-[#8e6d57] font-bold mb-6 hover:text-orange-500 transition">
                <i class="fa-solid fa-arrow-left"></i> Quay lại
            </a>

            <div class="mb-8">
                <div class="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-orange-100 text-orange-600 text-sm font-extrabold">
                    <i class="fa-solid fa-bolt"></i>
                    Đặt hàng nhanh
                </div>
                <h1 class="mt-4 text-4xl font-black tracking-tight">Thông tin giao hàng</h1>
                <p class="mt-2 text-gray-500 text-lg">Nhập thông tin cần thiết và xác thực OTP để tiếp tục thanh toán mà không cần đăng nhập.</p>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-2 bg-white rounded-[32px] overflow-hidden border border-[#eee4dc] shadow-[0_18px_45px_rgba(15,23,42,.08)]">
                <div class="relative min-h-[640px] bg-[#fff3eb]">
                    <img src="${pageContext.request.contextPath}/assets/images/guest-food-banner.jpg"
                         alt="Đặt hàng nhanh"
                         class="absolute inset-0 w-full h-full object-cover"
                         onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/images/default-store-cover.jpg';">
                    <div class="absolute inset-0 bg-gradient-to-t from-black/55 via-black/15 to-transparent"></div>
                    <div class="absolute left-8 right-8 bottom-8 text-white">
                        <div class="inline-flex items-center justify-center w-16 h-16 rounded-full bg-white/20 backdrop-blur text-3xl mb-5">
                            <i class="fa-solid fa-bag-shopping"></i>
                        </div>
                        <h2 class="text-4xl font-black">Đặt món cực nhanh</h2>
                        <p class="mt-3 text-lg text-white/90 leading-relaxed">
                            Chỉ cần xác thực số điện thoại, hoàn tất thông tin giao hàng và tiếp tục thanh toán với giỏ hàng hiện tại.
                        </p>
                    </div>
                </div>

                <div class="p-8 md:p-10">
                    <c:if test="${not empty message}">
                        <div class="mb-4 rounded-2xl border border-green-200 bg-green-50 text-green-700 px-4 py-3 font-semibold">
                            ${message}
                        </div>
                    </c:if>

                    <c:if test="${not empty error}">
                        <div class="mb-4 rounded-2xl border border-red-200 bg-red-50 text-red-700 px-4 py-3 font-semibold">
                            ${error}
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/guest-send-otp" method="post" class="space-y-4">
                        <div>
                            <label class="block text-sm font-bold text-gray-800 mb-2">Họ và tên</label>
                            <input type="text" name="fullName" value="${fullName}" required
                                   class="w-full h-12 px-4 rounded-2xl border border-gray-200 bg-white outline-none focus:ring-4 focus:ring-orange-100 focus:border-orange-400">
                        </div>

                        <div>
                            <label class="block text-sm font-bold text-gray-800 mb-2">Email</label>
                            <input type="email" name="email" value="${email}" required
                                   class="w-full h-12 px-4 rounded-2xl border border-gray-200 bg-white outline-none focus:ring-4 focus:ring-orange-100 focus:border-orange-400">
                        </div>

                        <div>
                            <label class="block text-sm font-bold text-gray-800 mb-2">Số điện thoại</label>
                            <input type="text" name="phone" value="${phone}" required placeholder="VD: 0900000012"
                                   class="w-full h-12 px-4 rounded-2xl border border-gray-200 bg-white outline-none focus:ring-4 focus:ring-orange-100 focus:border-orange-400">
                        </div>

                        <div>
                            <label class="block text-sm font-bold text-gray-800 mb-2">Địa chỉ giao hàng</label>
                            <textarea id="guestAddressLine" name="addressLine" required rows="4"
                                      class="w-full px-4 py-3 rounded-2xl border border-gray-200 bg-white outline-none focus:ring-4 focus:ring-orange-100 focus:border-orange-400 resize-none">${addressLine}</textarea>
                        </div>

                        <div>
                            <label class="block text-sm font-bold text-gray-800 mb-2">Tìm vị trí bằng bản đồ</label>
                            <div class="flex gap-2 mb-2">
                                <input type="text"
                                       id="guestMapSearchInput"
                                       placeholder="Tìm địa chỉ gần bạn..."
                                       class="flex-1 h-12 px-4 rounded-2xl border border-gray-200 bg-white outline-none focus:ring-4 focus:ring-orange-100 focus:border-orange-400">
                                <button type="button"
                                        id="guestMapSearchBtn"
                                        class="px-4 rounded-2xl bg-gray-900 hover:bg-black text-white font-bold">
                                    Tìm
                                </button>
                            </div>
                            <div id="guestNearbyWrap" class="mb-2 hidden">
                                <p class="text-xs font-semibold text-gray-500 mb-1">Địa chỉ gợi ý gần bạn</p>
                                <div id="guestNearbyList" class="flex flex-wrap gap-2"></div>
                            </div>
                            <div id="guestLeafletMap" class="w-full h-56 rounded-2xl border border-gray-200 overflow-hidden"></div>
                            <p id="guestMapHint" class="mt-2 text-xs text-gray-500">Chọn điểm trên bản đồ để điền nhanh địa chỉ giao hàng.</p>
                            <input type="hidden" id="guestShippingLat" name="shippingLat" value="${shippingLat}">
                            <input type="hidden" id="guestShippingLng" name="shippingLng" value="${shippingLng}">
                        </div>

                        <button type="submit"
                                class="w-full h-12 rounded-full bg-orange-500 hover:bg-orange-600 text-white font-black shadow">
                            Gửi mã OTP
                        </button>
                    </form>

                    <c:if test="${otpSent}">
                        <form action="${pageContext.request.contextPath}/guest-verify-otp" method="post"
                              class="mt-6 space-y-4 border-t border-gray-100 pt-6">
                            <input type="hidden" name="fullName" value="${fullName}">
                            <input type="hidden" name="email" value="${email}">
                            <input type="hidden" name="phone" value="${phone}">
                            <input type="hidden" name="addressLine" value="${addressLine}">
                            <input type="hidden" name="shippingLat" id="otpShippingLat" value="${shippingLat}">
                            <input type="hidden" name="shippingLng" id="otpShippingLng" value="${shippingLng}">

                            <div>
                                <label class="block text-sm font-bold text-gray-800 mb-2">Nhập mã OTP</label>
                                <input type="text" name="otpCode" required maxlength="6" placeholder="Nhập mã gồm 6 số"
                                       class="w-full h-12 px-4 rounded-2xl border border-gray-200 bg-white outline-none focus:ring-4 focus:ring-orange-100 focus:border-orange-400">
                            </div>

                            <button type="submit"
                                    class="w-full h-12 rounded-full bg-gray-900 hover:bg-black text-white font-black shadow">
                                Tiếp tục thanh toán
                            </button>
                        </form>
                    </c:if>
                </div>
            </div>
        </main>

        <jsp:include page="footer.jsp" />

        <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
                integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo="
                crossorigin=""></script>
        <script>
            let guestMap;
            let guestMarker;

            function syncGuestOtpHidden() {
                const address = document.getElementById('guestAddressLine');
                const lat = document.getElementById('guestShippingLat');
                const lng = document.getElementById('guestShippingLng');
                const otpAddress = document.querySelector('input[name="addressLine"][type="hidden"]');
                const otpLat = document.getElementById('otpShippingLat');
                const otpLng = document.getElementById('otpShippingLng');

                if (address && otpAddress) {
                    otpAddress.value = address.value;
                }
                if (lat && otpLat) {
                    otpLat.value = lat.value;
                }
                if (lng && otpLng) {
                    otpLng.value = lng.value;
                }
            }

            function setGuestLocation(lat, lng, addressText, moveMap) {
                const address = document.getElementById('guestAddressLine');
                const latInput = document.getElementById('guestShippingLat');
                const lngInput = document.getElementById('guestShippingLng');

                if (latInput) {
                    latInput.value = Number(lat).toFixed(7);
                }
                if (lngInput) {
                    lngInput.value = Number(lng).toFixed(7);
                }
                if (addressText && address) {
                    address.value = addressText;
                }

                if (guestMarker) {
                    guestMarker.setLatLng([lat, lng]);
                }
                if (guestMap && moveMap) {
                    guestMap.setView([lat, lng], Math.max(guestMap.getZoom(), 16));
                }

                syncGuestOtpHidden();
            }

            async function guestReverseGeocode(lat, lng) {
                const url = 'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat='
                        + encodeURIComponent(lat)
                        + '&lon=' + encodeURIComponent(lng)
                        + '&accept-language=vi';
                const response = await fetch(url);
                if (!response.ok) {
                    throw new Error('Reverse geocode failed');
                }
                const data = await response.json();
                return data.display_name || '';
            }

            async function guestSearchAddress(keyword) {
                const url = 'https://nominatim.openstreetmap.org/search?format=jsonv2&limit=5&addressdetails=1&accept-language=vi&q='
                        + encodeURIComponent(keyword);
                const response = await fetch(url);
                if (!response.ok) {
                    throw new Error('Search failed');
                }
                return response.json();
            }

            async function renderGuestNearby(centerLat, centerLng) {
                const wrap = document.getElementById('guestNearbyWrap');
                const list = document.getElementById('guestNearbyList');
                if (!wrap || !list) {
                    return;
                }

                const offsets = [[0, 0], [0.002, 0], [0, 0.002]];
                const suggestions = [];
                for (const [dLat, dLng] of offsets) {
                    try {
                        const lat = centerLat + dLat;
                        const lng = centerLng + dLng;
                        const address = await guestReverseGeocode(lat, lng);
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
                    btn.addEventListener('click', () => setGuestLocation(item.lat, item.lng, item.address, true));
                    list.appendChild(btn);
                });

                wrap.classList.remove('hidden');
            }

            async function runGuestSearch() {
                const input = document.getElementById('guestMapSearchInput');
                const hint = document.getElementById('guestMapHint');
                if (!input || !input.value.trim()) {
                    return;
                }

                try {
                    const results = await guestSearchAddress(input.value.trim());
                    if (!results || results.length === 0) {
                        if (hint) {
                            hint.textContent = 'Không tìm thấy địa chỉ phù hợp.';
                        }
                        return;
                    }

                    const first = results[0];
                    const lat = parseFloat(first.lat);
                    const lng = parseFloat(first.lon);
                    setGuestLocation(lat, lng, first.display_name || input.value.trim(), true);
                    renderGuestNearby(lat, lng);
                    if (hint) {
                        hint.textContent = 'Đã cập nhật địa chỉ từ kết quả tìm kiếm.';
                    }
                } catch (e) {
                    if (hint) {
                        hint.textContent = 'Tìm kiếm tạm lỗi, vui lòng thử lại.';
                    }
                }
            }

            function initGuestMap() {
                const mapEl = document.getElementById('guestLeafletMap');
                if (!mapEl || typeof L === 'undefined') {
                    return;
                }

                const latInput = document.getElementById('guestShippingLat');
                const lngInput = document.getElementById('guestShippingLng');
                const initialLat = latInput && latInput.value ? parseFloat(latInput.value) : 10.7769;
                const initialLng = lngInput && lngInput.value ? parseFloat(lngInput.value) : 106.7009;

                guestMap = L.map(mapEl).setView([initialLat, initialLng], 14);
                L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                    maxZoom: 19,
                    attribution: '&copy; OpenStreetMap'
                }).addTo(guestMap);

                guestMarker = L.marker([initialLat, initialLng], {draggable: true}).addTo(guestMap);

                guestMap.on('click', async function (event) {
                    const lat = event.latlng.lat;
                    const lng = event.latlng.lng;
                    let address = '';
                    try {
                        address = await guestReverseGeocode(lat, lng);
                    } catch (e) {
                    }
                    setGuestLocation(lat, lng, address, false);
                });

                guestMarker.on('dragend', async function () {
                    const point = guestMarker.getLatLng();
                    let address = '';
                    try {
                        address = await guestReverseGeocode(point.lat, point.lng);
                    } catch (e) {
                    }
                    setGuestLocation(point.lat, point.lng, address, false);
                });

                const searchBtn = document.getElementById('guestMapSearchBtn');
                const searchInput = document.getElementById('guestMapSearchInput');
                if (searchBtn) {
                    searchBtn.addEventListener('click', runGuestSearch);
                }
                if (searchInput) {
                    searchInput.addEventListener('keydown', function (e) {
                        if (e.key === 'Enter') {
                            e.preventDefault();
                            runGuestSearch();
                        }
                    });
                }

                const addressArea = document.getElementById('guestAddressLine');
                if (addressArea) {
                    addressArea.addEventListener('input', syncGuestOtpHidden);
                }

                if (!(latInput && latInput.value && lngInput && lngInput.value) && navigator.geolocation) {
                    navigator.geolocation.getCurrentPosition(async function (position) {
                        const lat = position.coords.latitude;
                        const lng = position.coords.longitude;
                        let address = '';
                        try {
                            address = await guestReverseGeocode(lat, lng);
                        } catch (e) {
                        }
                        setGuestLocation(lat, lng, address, true);
                        renderGuestNearby(lat, lng);
                    });
                } else {
                    renderGuestNearby(initialLat, initialLng);
                }

                syncGuestOtpHidden();
            }

            document.addEventListener('DOMContentLoaded', initGuestMap);
        </script>
    </body>
</html>