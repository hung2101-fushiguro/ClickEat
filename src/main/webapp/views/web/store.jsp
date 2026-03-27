<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Cửa hàng - ClickEat</title>
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <link rel="shortcut icon" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    </head>
    <body class="bg-[#f4f5f7] text-gray-900">
        <c:set var="ctx" value="${pageContext.request.contextPath}" />

        <jsp:include page="header.jsp">
            <jsp:param name="activePage" value="store" />
        </jsp:include>

        <main class="pb-20">

            <!-- PAGE HEADER -->
            <section class="pt-10">
                <div class="max-w-7xl mx-auto px-6">
                    <div class="max-w-4xl">
                        <h1 class="text-5xl font-black tracking-tight">Cửa hàng</h1>
                        <p class="mt-3 text-lg text-gray-500">
                            Chọn quán bạn thích — đặt nhanh trong vài giây.
                        </p>
                    </div>

                    <!-- SEARCH BAR -->
                    <form action="${ctx}/store" method="get" class="w-full mt-8 relative" autocomplete="off">
                        <input type="hidden" name="district" value="${district}">
                        <input type="hidden" name="sort" value="${sort}">
                        <input type="hidden" name="province" value="${province}">

                        <div class="bg-white rounded-[32px] border border-gray-200 min-h-[72px] px-5 md:px-6 flex flex-col md:flex-row md:items-center gap-3 md:gap-4 shadow-[0_10px_30px_rgba(15,23,42,.06)]">
                            <div class="relative shrink-0 flex items-center min-w-0">
                                <i class="fa-solid fa-location-dot absolute left-2 top-1/2 -translate-y-1/2 text-orange-500"></i>

                                <div class="pl-7 pr-3 min-h-[44px] flex items-center">
                                    <span class="text-orange-500 font-extrabold text-[15px] break-words">
                                        <c:out value="${empty province ? 'Khu vực hiện tại' : province}" />
                                    </span>
                                </div>
                            </div>

                            <div class="hidden md:block w-px h-8 bg-gray-200"></div>

                            <div class="flex items-center gap-3 flex-1 min-w-0">
                                <i class="fa-solid fa-magnifying-glass text-gray-400"></i>

                                <input type="text"
                                       id="storeKeyword"
                                       name="keyword"
                                       value="${keyword}"
                                       placeholder="Tìm kiếm quán ăn..."
                                       class="flex-1 outline-none bg-transparent text-[15px] h-11 leading-none placeholder:text-gray-400 min-w-0" />

                                <c:choose>
                                    <c:when test="${not empty keyword}">
                                        <c:url var="clearSearchUrl" value="/store">
                                            <c:param name="province" value="${province}" />
                                            <c:param name="district" value="${district}" />
                                            <c:param name="sort" value="${sort}" />
                                        </c:url>

                                        <a href="${clearSearchUrl}"
                                           class="shrink-0 inline-flex items-center justify-center bg-gray-100 hover:bg-gray-200 text-gray-700 font-bold px-6 h-11 rounded-full leading-none transition whitespace-nowrap">
                                            Huỷ
                                        </a>
                                    </c:when>
                                    <c:otherwise>
                                        <button type="submit"
                                                class="shrink-0 inline-flex items-center justify-center bg-orange-500 hover:bg-orange-600 text-white font-extrabold px-8 h-11 rounded-full leading-none transition shadow-sm whitespace-nowrap">
                                            Tìm kiếm
                                        </button>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>

                        <div class="mt-3 flex flex-wrap items-center gap-3">
                            <span class="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-orange-50 text-orange-600 font-bold text-sm">
                                <i class="fa-solid fa-lock"></i>
                                Khu vực đang theo vị trí giao hàng hiện tại
                            </span>

                            <span class="text-sm text-gray-500 font-medium leading-6">
                                <c:out value="${provinceLockedMessage}" />
                            </span>
                        </div>

                        <div id="storeSuggestionBox"
                             class="hidden absolute left-0 right-0 top-[126px] bg-white border border-gray-200 rounded-[24px] shadow-[0_18px_40px_rgba(15,23,42,.12)] z-50 overflow-hidden">
                        </div>
                    </form>

                    <!-- DISTRICT TABS -->
                    <div class="mt-6 flex flex-wrap gap-3">
                        <c:url var="allStoreUrl" value="/store">
                            <c:param name="keyword" value="${keyword}" />
                            <c:param name="sort" value="${sort}" />
                        </c:url>

                        <a href="${allStoreUrl}"
                           class="px-7 h-12 rounded-full border font-bold inline-flex items-center justify-center transition
                           ${empty district ? 'bg-orange-500 text-white border-orange-500 shadow-sm' : 'bg-white text-gray-700 border-gray-200 hover:bg-gray-50'}">
                            ALL
                        </a>

                        <c:forEach var="d" items="${districts}">
                            <c:url var="districtUrl" value="/store">
                                <c:param name="district" value="${d}" />
                                <c:param name="keyword" value="${keyword}" />
                                <c:param name="sort" value="${sort}" />
                            </c:url>

                            <a href="${districtUrl}"
                               class="px-7 h-12 rounded-full border font-bold inline-flex items-center justify-center transition
                               ${district == d ? 'bg-orange-500 text-white border-orange-500 shadow-sm' : 'bg-white text-gray-700 border-gray-200 hover:bg-gray-50'}">
                                ${d}
                            </a>
                        </c:forEach>
                    </div>

                    <!-- SORT + DISTRICT DROPDOWN -->
                    <div class="mt-6 flex flex-wrap items-center justify-between gap-4">
                        <div class="flex flex-wrap gap-3">
                            <c:url var="nearUrl" value="/store">
                                <c:param name="keyword" value="${keyword}" />
                                <c:param name="district" value="${district}" />
                            </c:url>

                            <c:url var="ratingUrl" value="/store">
                                <c:param name="keyword" value="${keyword}" />
                                <c:param name="district" value="${district}" />
                                <c:param name="sort" value="rating" />
                            </c:url>

                            <c:url var="nameUrl" value="/store">
                                <c:param name="keyword" value="${keyword}" />
                                <c:param name="district" value="${district}" />
                                <c:param name="sort" value="name" />
                            </c:url>

                            <a href="${nearUrl}"
                               class="px-6 h-11 rounded-full border font-semibold inline-flex items-center gap-2 transition
                               ${empty sort || sort == 'nearest' || sort == 'distance' ? 'bg-orange-500 text-white border-orange-500 shadow-sm' : 'bg-white border-gray-200 text-gray-700 hover:bg-gray-50'}">
                                <i class="fa-regular fa-paper-plane"></i> Gần tôi
                            </a>

                            <a href="${ratingUrl}"
                               class="px-6 h-11 rounded-full border font-semibold inline-flex items-center gap-2 transition
                               ${sort == 'rating' ? 'bg-orange-500 text-white border-orange-500 shadow-sm' : 'bg-white border-gray-200 text-gray-700 hover:bg-gray-50'}">
                                <i class="fa-solid fa-star"></i> Đánh giá cao
                            </a>

                            <a href="${nameUrl}"
                               class="px-6 h-11 rounded-full border font-semibold inline-flex items-center gap-2 transition
                               ${sort == 'name' ? 'bg-orange-500 text-white border-orange-500 shadow-sm' : 'bg-white border-gray-200 text-gray-700 hover:bg-gray-50'}">
                                <i class="fa-solid fa-arrow-down-a-z"></i> Tên quán
                            </a>
                        </div>

                        <form action="${ctx}/store" method="get">
                            <input type="hidden" name="keyword" value="${keyword}">
                            <input type="hidden" name="sort" value="${sort}">
                            <select name="district"
                                    onchange="this.form.submit()"
                                    class="bg-white border border-gray-200 rounded-full h-11 px-5 min-w-[220px] outline-none font-semibold text-gray-700 hover:border-gray-300 transition">
                                <option value="">Chọn Quận / huyện</option>
                                <c:forEach var="d" items="${districts}">
                                    <option value="${d}" ${district == d ? 'selected' : ''}>${d}</option>
                                </c:forEach>
                            </select>
                        </form>
                    </div>

                    <!-- EMPTY -->
                    <c:if test="${empty stores}">
                        <div class="mt-10 bg-white rounded-[30px] border border-dashed border-gray-300 p-14 text-center shadow-[0_10px_30px_rgba(15,23,42,.06)]">
                            <i class="fa-solid fa-store text-5xl text-gray-300 mb-4"></i>
                            <p class="text-lg font-semibold text-gray-500">Không tìm thấy cửa hàng phù hợp.</p>
                        </div>
                    </c:if>

                    <!-- STORES GRID -->
                    <c:if test="${not empty stores}">
                        <div class="mt-8 grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-7 items-stretch">
                            <c:forEach var="s" items="${stores}">
                                <c:url var="storeDetailUrl" value="/store-detail">
                                    <c:param name="id" value="${s.userId}" />
                                    <c:param name="province" value="${province}" />
                                    <c:param name="district" value="${district}" />
                                    <c:param name="keyword" value="${keyword}" />
                                    <c:param name="sort" value="${sort}" />
                                </c:url>

                                <article class="group bg-white rounded-[30px] overflow-hidden border border-gray-200 shadow-[0_10px_30px_rgba(15,23,42,.06)] hover:shadow-[0_18px_40px_rgba(15,23,42,.10)] hover:border-orange-400 transition h-full">
                                    <a href="${storeDetailUrl}" class="block h-full">
                                        <div class="h-full flex flex-col">

                                            <!-- IMAGE -->
                                            <div class="relative h-[240px] overflow-hidden">
                                                <c:choose>
                                                    <c:when test="${not empty s.imageUrl}">
                                                        <img src="${ctx}${s.imageUrl}" alt="${s.shopName}" class="w-full h-full object-cover transition duration-300 hover:scale-105">
                                                    </c:when>
                                                    <c:otherwise>
                                                        <img src="${ctx}/assets/images/default-store.jpg" alt="${s.shopName}" class="w-full h-full object-cover transition duration-300 hover:scale-105">
                                                    </c:otherwise>
                                                </c:choose>

                                                <div class="absolute top-4 left-4 flex gap-2 flex-wrap">
                                                    <span class="bg-red-500 text-white text-xs font-extrabold px-3 py-2 rounded-full shadow-sm">
                                                        <i class="fa-solid fa-bolt"></i> Hot Deal
                                                    </span>
                                                    <c:if test="${not empty s.voucherTitle}">
                                                        <span class="bg-orange-500 text-white text-xs font-extrabold px-3 py-2 rounded-full shadow-sm">
                                                            Ưu đãi
                                                        </span>
                                                    </c:if>
                                                </div>
                                            </div>

                                            <!-- BODY -->
                                            <div class="p-6 flex flex-col flex-1">
                                                <div class="flex items-start justify-between gap-4">
                                                    <h3 class="text-[26px] md:text-[28px] leading-[1.05] tracking-[-0.03em] font-black text-gray-900 line-clamp-2">
                                                        ${s.shopName}
                                                    </h3>

                                                    <div class="text-right shrink-0 pt-1">
                                                        <div class="text-orange-500 font-black text-sm">${s.itemCount} món</div>
                                                    </div>
                                                </div>

                                                <p class="text-sm text-gray-500 mt-3 leading-6 min-h-[44px] line-clamp-2">
                                                    ${s.shopAddressLine}, ${s.districtName}, ${s.provinceName}
                                                </p>

                                                <div class="flex flex-wrap gap-3 mt-6">
                                                    <span class="bg-[#f6f1ec] px-4 py-2 rounded-full text-sm font-bold text-gray-800">
                                                        <i class="fa-solid fa-star text-orange-400"></i>
                                                        <fmt:formatNumber value="${s.rating}" type="number" minFractionDigits="1" maxFractionDigits="1"/>
                                                    </span>

                                                    <span class="bg-[#f6f1ec] px-4 py-2 rounded-full text-sm font-bold text-gray-800">
                                                        <i class="fa-regular fa-clock text-[#9d7d68]"></i> ${s.deliveryTime}
                                                    </span>

                                                    <span class="bg-[#f6f1ec] px-4 py-2 rounded-full text-sm font-bold text-gray-800">
                                                        <i class="fa-solid fa-location-dot text-[#9d7d68]"></i> ${s.distance}
                                                    </span>

                                                    <span class="bg-[#f6f1ec] px-4 py-2 rounded-full text-sm font-bold text-gray-800">
                                                        <i class="fa-solid fa-motorcycle text-orange-500"></i> Giao nhanh
                                                    </span>
                                                </div>

                                                <div class="mt-6 flex items-end justify-between gap-4">
                                                    <div>
                                                        <div class="text-sm text-gray-500">Danh mục nổi bật</div>
                                                        <div class="font-black text-lg text-gray-900 line-clamp-1">
                                                            ${empty s.categoryName ? 'Món ngon' : s.categoryName}
                                                        </div>
                                                    </div>

                                                    <div class="text-right shrink-0">
                                                        <div class="text-sm text-gray-500">Từ</div>
                                                        <div class="text-orange-500 font-black text-3xl leading-none">
                                                            <fmt:formatNumber value="${s.minPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                                                        </div>
                                                    </div>
                                                </div>

                                                <div class="mt-auto pt-5 border-t border-gray-100 flex items-center justify-between gap-3">
                                                    <div class="text-sm text-gray-500 line-clamp-1">
                                                        ${empty s.voucherTitle ? 'Đang mở bán hôm nay' : s.voucherTitle}
                                                    </div>

                                                    <span class="inline-flex items-center justify-center gap-2 px-4 h-11 rounded-full border-2 border-orange-500 bg-white text-orange-500 font-black shrink-0 transition group-hover:bg-orange-500 group-hover:text-white">
                                                        Xem quán <i class="fa-solid fa-arrow-right"></i>
                                                    </span>
                                                </div>
                                            </div>
                                        </div>
                                    </a>
                                </article>
                            </c:forEach>
                        </div>
                    </c:if>
                </div>
            </section>
        </main>

        <jsp:include page="footer.jsp" />

        <script>
            const ctx = '${ctx}';
            const currentProvince = '${province != null ? province : ""}';
            const currentDistrict = '${district != null ? district : ""}';
            const currentSort = '${sort != null ? sort : ""}';

            const keywordInput = document.getElementById('storeKeyword');
            const suggestionBox = document.getElementById('storeSuggestionBox');

            let debounceTimer = null;

            function hideSuggestions() {
                if (!suggestionBox)
                    return;
                suggestionBox.classList.add('hidden');
                suggestionBox.innerHTML = '';
            }

            function showNoResult(message) {
                if (!suggestionBox)
                    return;
                suggestionBox.innerHTML = `
            <div class="px-4 py-3 text-sm text-gray-500">
            ${message}
            </div>
        `;
                suggestionBox.classList.remove('hidden');
            }

            function buildStoreDetailUrl(itemId, keywordValue) {
                const params = new URLSearchParams();
                params.set('id', itemId);

                if (currentDistrict)
                    params.set('district', currentDistrict);
                if (keywordValue)
                    params.set('keyword', keywordValue);
                if (currentSort)
                    params.set('sort', currentSort);

                return ctx + '/store-detail?' + params.toString();
            }

            function escapeHtml(str) {
                if (!str)
                    return '';
                return str
                        .replace(/&/g, '&amp;')
                        .replace(/</g, '&lt;')
                        .replace(/>/g, '&gt;')
                        .replace(/"/g, '&quot;')
                        .replace(/'/g, '&#39;');
            }

            function renderSuggestions(items) {
                if (!Array.isArray(items) || items.length === 0) {
                    showNoResult('Không có quán phù hợp');
                    return;
                }

                const keywordValue = keywordInput.value.trim();

                suggestionBox.innerHTML = items.map(item => {
                    const name = escapeHtml(item.shopName || '');
                    const districtName = escapeHtml(item.districtName || '');
                    const provinceName = escapeHtml(item.provinceName || '');
                    const href = buildStoreDetailUrl(item.userId, keywordValue);

                    return `
                <a href="${href}"
                   class="flex items-center justify-between px-4 py-3 hover:bg-orange-50 border-b last:border-b-0 border-gray-100 transition">
                    <div>
                        <div class="font-bold text-gray-900">${name}</div>
                        <div class="text-sm text-gray-500">${districtName}${districtName && provinceName ? ', ' : ''}${provinceName}</div>
                    </div>
                    <i class="fa-solid fa-arrow-right text-orange-500"></i>
                </a>
            `;
                }).join('');

                suggestionBox.classList.remove('hidden');
            }

            async function fetchSuggestions(keyword) {
                const url = ctx + '/store-suggest?province='
                        + encodeURIComponent(currentProvince)
                        + '&keyword=' + encodeURIComponent(keyword);

                const res = await fetch(url, {
                    method: 'GET',
                    headers: {
                        'Accept': 'application/json'
                    }
                });

                if (!res.ok) {
                    throw new Error('HTTP ' + res.status);
                }

                const text = await res.text();

                let data;
                try {
                    data = JSON.parse(text);
                } catch (e) {
                    throw new Error('Response không phải JSON hợp lệ');
                }

                renderSuggestions(data);
            }

            if (keywordInput && suggestionBox) {
                keywordInput.addEventListener('input', function () {
                    const keyword = this.value.trim();

                    clearTimeout(debounceTimer);

                    if (!keyword) {
                        hideSuggestions();
                        return;
                    }

                    debounceTimer = setTimeout(async () => {
                        try {
                            await fetchSuggestions(keyword);
                        } catch (err) {
                            console.error('Suggest error:', err);
                            showNoResult('Không tải được gợi ý');
                        }
                    }, 250);
                });

                keywordInput.addEventListener('focus', function () {
                    if (this.value.trim()) {
                        this.dispatchEvent(new Event('input'));
                    }
                });

                document.addEventListener('click', function (e) {
                    if (!suggestionBox.contains(e.target) && e.target !== keywordInput) {
                        hideSuggestions();
                    }
                });
            }
        </script>
    </body>
</html>