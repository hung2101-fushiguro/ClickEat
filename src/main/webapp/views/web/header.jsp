<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="activePage" value="${param.activePage}" />

<header class="bg-white/95 backdrop-blur sticky top-0 z-50 border-b border-gray-100 shadow-[0_8px_24px_rgba(15,23,42,.05)]">
    <div class="max-w-7xl mx-auto px-6">
        <div class="h-[76px] flex items-center justify-between gap-4 flex-nowrap">

            <a href="${ctx}/home" class="flex items-center shrink-0">
                <img src="${ctx}/assets/images/FullLogo.jpg"
                     alt="ClickEat"
                     class="h-12 w-[176px] object-contain"
                     onerror="this.style.display='none';" />
            </a>

            <nav class="hidden lg:flex items-center gap-6 flex-nowrap">
                <a href="${ctx}/home"
                   class="whitespace-nowrap text-[15px] font-semibold transition border-b-2 pb-1
                   ${activePage == 'home' ? 'text-orange-500 border-orange-500' : 'text-gray-900 border-transparent hover:text-orange-500'}">
                    Trang chủ
                </a>

                <a href="${ctx}/about"
                   class="whitespace-nowrap text-[15px] font-semibold transition border-b-2 pb-1
                   ${activePage == 'about' ? 'text-orange-500 border-orange-500' : 'text-gray-900 border-transparent hover:text-orange-500'}">
                    Về chúng tôi
                </a>

                <a href="${ctx}/menu"
                   class="whitespace-nowrap text-[15px] font-semibold transition border-b-2 pb-1
                   ${activePage == 'menu' ? 'text-orange-500 border-orange-500' : 'text-gray-900 border-transparent hover:text-orange-500'}">
                    Thực đơn
                </a>

                <a href="${ctx}/promotion"
                   class="whitespace-nowrap text-[15px] font-semibold transition border-b-2 pb-1
                   ${activePage == 'promotion' ? 'text-orange-500 border-orange-500' : 'text-gray-900 border-transparent hover:text-orange-500'}">
                    Khuyến mãi
                </a>

                <a href="${ctx}/store"
                   class="whitespace-nowrap text-[15px] font-semibold transition border-b-2 pb-1
                   ${activePage == 'store' ? 'text-orange-500 border-orange-500' : 'text-gray-900 border-transparent hover:text-orange-500'}">
                    Cửa hàng
                </a>

                <a href="${ctx}/ai"
                   class="whitespace-nowrap text-[15px] font-extrabold transition border-b-2 pb-1 flex items-center gap-1
                   ${activePage == 'ai' ? 'text-orange-500 border-orange-500' : 'text-gray-900 border-transparent hover:text-orange-500'}">
                    AI gợi ý <span class="text-orange-500">✨</span>
                </a>
            </nav>

            <div class="flex items-center gap-2 shrink-0 flex-nowrap">

                <button type="button"
                        id="headerLocationBtn"
                        class="hidden xl:flex items-center gap-2 w-[230px] min-w-[230px] h-10 px-3 rounded-full border border-gray-200 bg-white hover:border-orange-200 hover:bg-orange-50 transition overflow-hidden">
                    <i class="fa-solid fa-location-dot text-orange-500"></i>
                    <span class="text-[12px] font-bold text-gray-700 truncate min-w-0 flex-1 text-left" id="headerLocationText">Chọn vị trí giao hàng</span>
                </button>

                <c:choose>
                    <c:when test="${not empty sessionScope.account}">
                        <button type="button" id="cartBtn"
                                class="relative w-10 h-10 rounded-full border border-gray-200 bg-white hover:bg-gray-50 flex items-center justify-center transition"
                                aria-label="Giỏ hàng">
                            <i class="fa-solid fa-bag-shopping text-gray-800 text-lg"></i>
                            <span class="absolute -top-1 -right-1 bg-orange-500 text-white text-[11px] font-extrabold rounded-full h-5 min-w-[20px] px-1 flex items-center justify-center shadow">
                                <c:out value="${cartCount != null ? cartCount : 0}" />
                            </span>
                        </button>
                    </c:when>

                    <c:otherwise>
                        <button type="button" id="cartBtn"
                                class="relative w-10 h-10 rounded-full border border-gray-200 bg-white hover:bg-gray-50 flex items-center justify-center transition"
                                aria-label="Giỏ hàng">
                            <i class="fa-solid fa-bag-shopping text-gray-800 text-lg"></i>
                            <span class="absolute -top-1 -right-1 bg-orange-500 text-white text-[11px] font-extrabold rounded-full h-5 min-w-[20px] px-1 flex items-center justify-center shadow">
                                <c:out value="${cartCount != null ? cartCount : 0}" />
                            </span>
                        </button>
                    </c:otherwise>
                </c:choose>

                <c:choose>
                    <c:when test="${not empty sessionScope.account}">
                        <div class="relative" id="userDropdownWrap">
                            <button type="button"
                                    id="userDropdownBtn"
                                    class="flex items-center gap-2 rounded-full border border-gray-200 bg-white px-2 py-1.5 hover:border-orange-200 hover:bg-orange-50 transition shadow-sm">
                                <c:choose>
                                    <c:when test="${not empty sessionScope.account.avatarUrl}">
                                        <img src="${sessionScope.account.avatarUrl}"
                                             alt="${sessionScope.account.fullName}"
                                             class="w-11 h-11 rounded-full object-cover border-2 border-orange-100"
                                             onerror="this.onerror=null;this.src='https://ui-avatars.com/api/?name=${sessionScope.account.fullName}&background=fff3e8&color=f97316&bold=true';">
                                    </c:when>
                                    <c:otherwise>
                                        <img src="https://ui-avatars.com/api/?name=${sessionScope.account.fullName}&background=fff3e8&color=f97316&bold=true"
                                             alt="${sessionScope.account.fullName}"
                                             class="w-11 h-11 rounded-full object-cover border-2 border-orange-100">
                                    </c:otherwise>
                                </c:choose>

                                <div class="hidden sm:flex flex-col items-start leading-tight max-w-[160px]">
                                    <span class="text-[11px] font-semibold uppercase tracking-wide text-orange-500">Tài khoản</span>
                                    <span class="text-[13px] font-bold text-gray-800 truncate w-full">
                                        ${sessionScope.account.fullName}
                                    </span>
                                </div>

                                <i class="fa-solid fa-chevron-down text-xs text-gray-500 transition" id="userDropdownIcon"></i>
                            </button>

                            <div id="userDropdownMenu"
                                 class="hidden absolute right-0 mt-3 w-64 rounded-2xl bg-white border border-gray-100 shadow-[0_18px_40px_rgba(15,23,42,.12)] overflow-hidden">
                                <div class="px-4 py-4 bg-gradient-to-r from-orange-50 to-white border-b border-orange-100">
                                    <div class="flex items-center gap-3">
                                        <c:choose>
                                            <c:when test="${not empty sessionScope.account.avatarUrl}">
                                                <img src="${sessionScope.account.avatarUrl}"
                                                     alt="${sessionScope.account.fullName}"
                                                     class="w-12 h-12 rounded-full object-cover border-2 border-white shadow"
                                                     onerror="this.onerror=null;this.src='https://ui-avatars.com/api/?name=${sessionScope.account.fullName}&background=fff3e8&color=f97316&bold=true';">
                                            </c:when>
                                            <c:otherwise>
                                                <img src="https://ui-avatars.com/api/?name=${sessionScope.account.fullName}&background=fff3e8&color=f97316&bold=true"
                                                     alt="${sessionScope.account.fullName}"
                                                     class="w-12 h-12 rounded-full object-cover border-2 border-white shadow">
                                            </c:otherwise>
                                        </c:choose>
                                        <div class="min-w-0">
                                            <div class="font-extrabold text-gray-900 truncate">${sessionScope.account.fullName}</div>
                                            <div class="text-sm text-gray-500 truncate">${sessionScope.account.email}</div>
                                        </div>
                                    </div>
                                </div>

                                <a href="${ctx}/customer/profile"
                                   class="flex items-center gap-3 px-4 py-3 text-sm font-semibold text-gray-700 hover:bg-orange-50 hover:text-orange-600 transition">
                                    <i class="fa-regular fa-user w-5 text-center"></i>
                                    Thông tin tài khoản
                                </a>

                                <a href="${ctx}/logout"
                                   class="flex items-center gap-3 px-4 py-3 text-sm font-semibold text-red-500 hover:bg-red-50 transition border-t border-gray-100">
                                    <i class="fa-solid fa-arrow-right-from-bracket w-5 text-center"></i>
                                    Đăng xuất
                                </a>
                            </div>
                        </div>
                    </c:when>

                    <c:otherwise>
                        <a href="${ctx}/login"
                           class="h-10 px-4 rounded-full border border-gray-200 text-gray-900 font-extrabold text-sm hover:bg-gray-50 flex items-center justify-center whitespace-nowrap leading-none">
                            Đăng nhập
                        </a>
                        <a href="${ctx}/register"
                           class="h-10 px-4 rounded-full bg-orange-500 text-white font-extrabold text-sm hover:bg-orange-600 flex items-center justify-center whitespace-nowrap leading-none shadow">
                            Đăng ký
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <div class="h-px bg-gray-100"></div>
</header>

<div id="headerLocationModal" class="hidden fixed inset-0 z-[120] bg-black/45 px-4">
    <div class="mx-auto mt-16 w-full max-w-xl rounded-2xl bg-white shadow-2xl border border-gray-100 overflow-hidden">
        <div class="px-5 py-4 border-b border-gray-100 flex items-center justify-between">
            <h3 class="font-black text-lg text-gray-900">Chọn vị trí giao hàng</h3>
            <button type="button" id="closeHeaderLocationModal" class="w-9 h-9 rounded-full hover:bg-gray-100">
                <i class="fa-solid fa-xmark text-gray-500"></i>
            </button>
        </div>

        <div class="p-5 space-y-4">
            <div class="flex gap-2">
                <input type="text"
                       id="headerLocationSearchInput"
                       placeholder="Tìm đường, phường, quận..."
                       class="flex-1 h-11 rounded-xl border border-gray-200 px-4 outline-none focus:border-orange-400 focus:ring-4 focus:ring-orange-100">
                <button type="button"
                        id="headerLocationSearchBtn"
                        class="h-11 px-4 rounded-xl bg-gray-900 text-white font-bold hover:bg-black">
                    Tìm
                </button>
            </div>

            <button type="button"
                    id="headerUseCurrentLocationBtn"
                    class="h-11 px-4 rounded-xl bg-orange-500 text-white font-bold hover:bg-orange-600 inline-flex items-center gap-2">
                <i class="fa-solid fa-location-crosshairs"></i>
                Dùng vị trí hiện tại
            </button>

            <div id="headerLocationHint" class="text-xs text-gray-500">Địa chỉ đã chọn sẽ được dùng để tính khoảng cách giao hàng và gợi ý quán gần bạn.</div>

            <div id="headerLocationResults" class="max-h-72 overflow-y-auto rounded-xl border border-gray-100 divide-y"></div>
        </div>
    </div>
</div>

<c:if test="${not empty sessionScope.toastError}">
    <div id="toast-error" class="fixed bottom-5 right-5 bg-red-500 text-white px-6 py-4 rounded-xl shadow-2xl z-50 flex items-center gap-3 animate-bounce">
        <i class="fa-solid fa-triangle-exclamation text-xl"></i>
        <span class="font-medium">${sessionScope.toastError}</span>
    </div>
    <c:remove var="toastError" scope="session" />
    <script>
        setTimeout(() => {
            const el = document.getElementById('toast-error');
            if (el)
                el.style.display = 'none';
        }, 4000);
    </script>
</c:if>

<c:if test="${not empty sessionScope.toastMsg}">
    <div id="toast-success" class="fixed bottom-5 right-5 bg-green-500 text-white px-6 py-4 rounded-xl shadow-2xl z-50 flex items-center gap-3">
        <i class="fa-solid fa-circle-check text-xl"></i>
        <span class="font-medium">${sessionScope.toastMsg}</span>
    </div>
    <c:remove var="toastMsg" scope="session" />
    <script>
        setTimeout(() => {
            const el = document.getElementById('toast-success');
            if (el)
                el.style.display = 'none';
        }, 3000);
    </script>
</c:if>

<jsp:include page="cart.jsp">
    <jsp:param name="cartMode" value="popup" />
</jsp:include>

<jsp:include page="checkout-choice-modal.jsp" />

<script>
    (() => {
        const btn = document.getElementById('userDropdownBtn');
        const menu = document.getElementById('userDropdownMenu');
        const wrap = document.getElementById('userDropdownWrap');
        const icon = document.getElementById('userDropdownIcon');

        if (!btn || !menu || !wrap)
            return;

        btn.addEventListener('click', function (e) {
            e.stopPropagation();
            menu.classList.toggle('hidden');
            if (icon)
                icon.classList.toggle('rotate-180');
        });

        document.addEventListener('click', function (e) {
            if (!wrap.contains(e.target)) {
                menu.classList.add('hidden');
                if (icon)
                    icon.classList.remove('rotate-180');
            }
        });
    })();

    (() => {
        const locationBtn = document.getElementById('headerLocationBtn');
        const locationText = document.getElementById('headerLocationText');
        const modal = document.getElementById('headerLocationModal');
        const closeBtn = document.getElementById('closeHeaderLocationModal');
        const searchInput = document.getElementById('headerLocationSearchInput');
        const searchBtn = document.getElementById('headerLocationSearchBtn');
        const useCurrentBtn = document.getElementById('headerUseCurrentLocationBtn');
        const hint = document.getElementById('headerLocationHint');
        const results = document.getElementById('headerLocationResults');

        if (!locationBtn || !locationText || !modal || !closeBtn || !searchInput || !searchBtn || !useCurrentBtn || !hint || !results) {
            return;
        }

        function setCookie(name, value) {
            const oneYear = 60 * 60 * 24 * 365;
            document.cookie = name + '=' + encodeURIComponent(value) + '; path=/; max-age=' + oneYear + '; SameSite=Lax';
        }

        function getCookie(name) {
            const prefix = name + '=';
            const parts = document.cookie ? document.cookie.split(';') : [];
            for (const partRaw of parts) {
                const part = partRaw.trim();
                if (part.startsWith(prefix)) {
                    return decodeURIComponent(part.substring(prefix.length));
                }
            }
            return '';
        }

        function renderSelectedAddress(address) {
            locationText.textContent = address || 'Chọn vị trí giao hàng';
        }

        function persistLocation(lat, lng, address) {
            const latText = Number(lat).toFixed(7);
            const lngText = Number(lng).toFixed(7);
            const addressText = (address || '').trim();

            localStorage.setItem('ce_home_lat', latText);
            localStorage.setItem('ce_home_lng', lngText);
            if (addressText) {
                localStorage.setItem('ce_home_addr', addressText);
            }
            localStorage.setItem('ce_home_location_updated_at', String(Date.now()));

            setCookie('ce_home_lat', latText);
            setCookie('ce_home_lng', lngText);
            if (addressText) {
                setCookie('ce_home_addr', addressText);
            }

            renderSelectedAddress(addressText);
            window.dispatchEvent(new CustomEvent('ce-location-updated', {
                detail: {lat: latText, lng: lngText, address: addressText}
            }));
        }

        function loadSavedLocation() {
            const addr = localStorage.getItem('ce_home_addr') || getCookie('ce_home_addr');
            renderSelectedAddress(addr);
        }

        async function reverseGeocode(lat, lng) {
            const url = 'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat='
                    + encodeURIComponent(lat)
                    + '&lon=' + encodeURIComponent(lng)
                    + '&accept-language=vi';
            const response = await fetch(url);
            if (!response.ok) {
                throw new Error('reverse_geocode_error');
            }
            const data = await response.json();
            return data.display_name || '';
        }

        async function searchLocation(keyword) {
            const url = 'https://nominatim.openstreetmap.org/search?format=jsonv2&limit=8&addressdetails=1&accept-language=vi&q='
                    + encodeURIComponent(keyword);
            const response = await fetch(url);
            if (!response.ok) {
                throw new Error('search_error');
            }
            return response.json();
        }

        function closeModal() {
            modal.classList.add('hidden');
        }

        function openModal() {
            modal.classList.remove('hidden');
            searchInput.focus();
        }

        function renderResults(items) {
            results.innerHTML = '';
            if (!items || items.length === 0) {
                results.innerHTML = '<div class="px-4 py-3 text-sm text-gray-500">Không tìm thấy địa chỉ phù hợp.</div>';
                return;
            }

            items.forEach((item) => {
                const row = document.createElement('button');
                row.type = 'button';
                row.className = 'w-full text-left px-4 py-3 hover:bg-orange-50 transition';
                const displayName = item.display_name || 'Địa chỉ';
                const latText = Number(item.lat).toFixed(6);
                const lngText = Number(item.lon).toFixed(6);
                row.innerHTML = '<div class="text-sm font-bold text-gray-800">' + displayName + '</div>'
                        + '<div class="text-xs text-gray-500 mt-1">Lat: ' + latText + ', Lng: ' + lngText + '</div>';
                row.addEventListener('click', () => {
                    persistLocation(item.lat, item.lon, item.display_name || '');
                    hint.textContent = 'Đã lưu vị trí giao hàng.';
                    closeModal();
                });
                results.appendChild(row);
            });
        }

        async function runSearch() {
            const keyword = (searchInput.value || '').trim();
            if (!keyword) {
                return;
            }

            hint.textContent = 'Đang tìm vị trí...';
            try {
                const items = await searchLocation(keyword);
                renderResults(items);
                hint.textContent = 'Chọn 1 địa chỉ để lưu.';
            } catch (e) {
                hint.textContent = 'Không thể tìm vị trí lúc này, vui lòng thử lại.';
            }
        }

        async function useCurrentLocation() {
            if (!navigator.geolocation) {
                hint.textContent = 'Trình duyệt không hỗ trợ định vị.';
                return;
            }

            hint.textContent = 'Đang lấy vị trí hiện tại...';
            navigator.geolocation.getCurrentPosition(async function (position) {
                const lat = position.coords.latitude;
                const lng = position.coords.longitude;
                let address = '';
                try {
                    address = await reverseGeocode(lat, lng);
                } catch (e) {
                }
                persistLocation(lat, lng, address);
                hint.textContent = 'Đã cập nhật vị trí hiện tại.';
                closeModal();
            }, function () {
                hint.textContent = 'Không lấy được vị trí hiện tại. Hãy kiểm tra quyền truy cập vị trí.';
            }, {enableHighAccuracy: true, timeout: 10000});
        }

        locationBtn.addEventListener('click', openModal);
        closeBtn.addEventListener('click', closeModal);
        modal.addEventListener('click', function (e) {
            if (e.target === modal) {
                closeModal();
            }
        });

        searchBtn.addEventListener('click', runSearch);
        searchInput.addEventListener('keydown', function (e) {
            if (e.key === 'Enter') {
                e.preventDefault();
                runSearch();
            }
        });

        useCurrentBtn.addEventListener('click', useCurrentLocation);

        loadSavedLocation();
    })();
</script>