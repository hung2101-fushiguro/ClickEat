<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${store.shopName} - ClickEat</title>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <style>
        /* Food grid */
        .food-grid { display:grid; grid-template-columns:repeat(3,minmax(0,1fr)); gap:22px; }
        @media(max-width:1280px){ .food-grid{ grid-template-columns:repeat(2,minmax(0,1fr)); } }
        @media(max-width:640px) { .food-grid{ grid-template-columns:1fr; } }

        /* Food card */
        .food-card { background:#fff; border:1px solid #eee4dc; border-radius:24px; overflow:hidden;
                     box-shadow:0 8px 24px rgba(15,23,42,.06); transition:transform .2s,box-shadow .2s; cursor:pointer; }
        .food-card:hover { transform:translateY(-4px); box-shadow:0 18px 40px rgba(15,23,42,.10); }
        .food-img-wrap { position:relative; aspect-ratio:1/1; overflow:hidden; background:#f3f4f6; }
        .food-img { width:100%; height:100%; object-fit:cover; display:block; transition:transform .3s; }
        .food-card:hover .food-img { transform:scale(1.04); }
        .btn-add-cart { position:absolute; right:14px; bottom:14px; width:48px; height:48px; border-radius:50%;
                        background:#fff; color:#ff7a1a; border:none; font-size:18px; cursor:pointer;
                        display:flex; align-items:center; justify-content:center;
                        box-shadow:0 8px 20px rgba(255,122,26,.22); transition:.18s; z-index:2; }
        .btn-add-cart:hover { background:#ff7a1a; color:#fff; }
        .btn-add-cart:disabled { opacity:.5; cursor:not-allowed; }

        /* Badge */
        .badge-discount { position:absolute; top:12px; left:12px; background:#ff7a1a; color:#fff;
                          font-size:11px; font-weight:900; padding:4px 10px; border-radius:999px; }

        /* Cart sidebar */
        .cart-item-row { display:flex; gap:10px; align-items:flex-start; padding:10px 0; border-bottom:1px solid #f3ece7; }
        .cart-item-row:last-child { border-bottom:none; }

        /* Voucher strip */
        .voucher-strip { display:flex; gap:14px; overflow-x:auto; padding-bottom:6px; }
        .voucher-strip::-webkit-scrollbar { height:4px; }
        .voucher-strip::-webkit-scrollbar-track { background:#f1ece7; border-radius:4px; }
        .voucher-strip::-webkit-scrollbar-thumb { background:#e0c9b8; border-radius:4px; }
        .voucher-card-sm { flex-shrink:0; width:260px; background:linear-gradient(135deg,#fff7f2 0%,#fff 100%);
                           border:1px dashed #f2b895; border-radius:18px; padding:14px 16px;
                           display:flex; align-items:center; gap:12px; cursor:pointer;
                           transition:box-shadow .18s; }
        .voucher-card-sm:hover { box-shadow:0 8px 24px rgba(255,122,26,.12); }

        /* Modal */
        #foodModal { position:fixed; inset:0; z-index:9999; display:flex; align-items:flex-end;
                     justify-content:center; background:rgba(0,0,0,.45); backdrop-filter:blur(3px);
                     opacity:0; pointer-events:none; transition:opacity .25s; }
        #foodModal.open { opacity:1; pointer-events:all; }
        #foodModalBox { width:100%; max-width:520px; background:#fff; border-radius:32px 32px 0 0;
                        max-height:90vh; overflow-y:auto; transform:translateY(32px); transition:transform .28s; }
        #foodModal.open #foodModalBox { transform:translateY(0); }
        @media(min-width:640px){
            #foodModal { align-items:center; }
            #foodModalBox { border-radius:28px; max-height:80vh; }
        }

        /* Toast */
        #toast { position:fixed; bottom:28px; right:28px; z-index:99999;
                 display:flex; align-items:center; gap:10px; padding:14px 20px; border-radius:16px;
                 font-weight:700; font-size:14px; box-shadow:0 12px 32px rgba(0,0,0,.15);
                 transform:translateY(20px); opacity:0; transition:.3s; pointer-events:none; }
        #toast.show { transform:translateY(0); opacity:1; }
        #toast.success { background:#18a957; color:#fff; }
        #toast.error   { background:#e53e3e; color:#fff; }

        /* Category tabs scroll */
        .cat-tabs { display:flex; gap:10px; overflow-x:auto; padding-bottom:4px; }
        .cat-tabs::-webkit-scrollbar { display:none; }
    </style>
</head>
<body class="bg-[#f7f5f3] text-gray-900">
<c:set var="ctx" value="${pageContext.request.contextPath}" />

<jsp:include page="header.jsp">
    <jsp:param name="activePage" value="store" />
</jsp:include>

<main class="pb-24">

    <%-- ===== HERO: Cover Image ===== --%>
    <section class="pt-8">
        <div class="max-w-7xl mx-auto px-6">
            <a href="${ctx}/store" class="inline-flex items-center gap-2 text-[#8e6d57] font-bold mb-5">
                <i class="fa-solid fa-arrow-left"></i> Quay lại danh sách
            </a>

            <div class="h-[300px] md:h-[360px] rounded-[28px] overflow-hidden">
                <c:choose>
                    <c:when test="${not empty store.imageUrl}">
                        <img src="${ctx}${store.imageUrl}" alt="${store.shopName}"
                             class="w-full h-full object-cover">
                    </c:when>
                    <c:otherwise>
                        <img src="${ctx}/assets/images/default-store-cover.jpg" alt="${store.shopName}"
                             class="w-full h-full object-cover"
                             onerror="this.onerror=null;this.style.background='#f2d9c7'">
                    </c:otherwise>
                </c:choose>
            </div>

            <%-- Store info card --%>
            <div class="relative -mt-20 ml-4 mr-4 md:mr-8 bg-white rounded-[24px] shadow-xl border border-[#eee4dc] p-6 md:p-8">
                <div class="flex flex-col md:flex-row gap-6">
                    <div class="flex-1 min-w-0">
                        <h1 class="text-3xl md:text-5xl font-black tracking-tight leading-tight">${store.shopName}</h1>
                        <p class="text-[#9d7d68] mt-3 text-sm">
                            <i class="fa-solid fa-location-dot mr-1"></i>
                            ${store.shopAddressLine}<c:if test="${not empty store.districtName}">, ${store.districtName}</c:if><c:if test="${not empty store.provinceName}">, ${store.provinceName}</c:if>
                        </p>
                        <c:if test="${not empty store.shopDescription}">
                            <p class="mt-2 text-sm text-gray-500 line-clamp-2">${store.shopDescription}</p>
                        </c:if>
                    </div>
                    <div class="flex flex-wrap gap-2 items-start">
                        <span class="bg-green-50 text-green-700 text-xs font-extrabold px-4 py-2 rounded-full">
                            <i class="fa-solid fa-circle-check mr-1"></i>Đang mở cửa
                        </span>
                        <span class="bg-orange-50 text-orange-600 text-xs font-extrabold px-4 py-2 rounded-full">
                            <i class="fa-solid fa-motorcycle mr-1"></i>Giao nhanh
                        </span>
                    </div>
                </div>

                <div class="flex flex-wrap gap-3 mt-5">
                    <span class="bg-[#f7f2ee] px-4 py-2 rounded-full text-sm font-bold">
                        <i class="fa-solid fa-star text-yellow-400"></i>
                        <fmt:formatNumber value="${store.rating > 0 ? store.rating : 4.8}" type="number" minFractionDigits="1" maxFractionDigits="1"/>
                    </span>
                    <c:if test="${store.reviewCount > 0}">
                        <span class="bg-[#f7f2ee] px-4 py-2 rounded-full text-sm font-bold">
                            <i class="fa-regular fa-comment text-[#9d7d68]"></i> ${store.reviewCount} đánh giá
                        </span>
                    </c:if>
                    <span class="bg-[#f7f2ee] px-4 py-2 rounded-full text-sm font-bold">
                        <i class="fa-regular fa-clock text-[#9d7d68]"></i>
                        ${not empty store.deliveryTime ? store.deliveryTime : '25-35 phút'}
                    </span>
                    <c:if test="${store.minOrderAmount > 0}">
                        <span class="bg-[#f7f2ee] px-4 py-2 rounded-full text-sm font-bold">
                            <i class="fa-solid fa-receipt text-[#9d7d68]"></i> Tối thiểu
                            <fmt:formatNumber value="${store.minOrderAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                        </span>
                    </c:if>
                </div>
            </div>

            <%-- Voucher strip --%>
            <c:if test="${not empty storeVouchers}">
                <div class="mt-5">
                    <div class="flex items-center gap-2 mb-3">
                        <i class="fa-solid fa-ticket text-orange-500"></i>
                        <span class="font-black text-gray-800">Ưu đãi từ quán</span>
                        <span class="text-xs text-gray-400">(${fn:length(storeVouchers)} voucher)</span>
                    </div>
                    <div class="voucher-strip">
                        <c:forEach var="v" items="${storeVouchers}">
                            <div class="voucher-card-sm"
                                 onclick="copyVoucherCode('${fn:escapeXml(v.code)}', this)"
                                 title="Nhấn để sao chép mã">
                                <div class="w-11 h-11 rounded-full bg-orange-100 text-orange-500 flex items-center justify-center shrink-0 text-xl">
                                    <i class="fa-solid fa-tag"></i>
                                </div>
                                <div class="min-w-0">
                                    <div class="text-xs text-gray-400 font-semibold">
                                        <c:choose>
                                            <c:when test="${not empty v.displayDiscount}">${v.displayDiscount}</c:when>
                                            <c:otherwise>Ưu đãi</c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="font-black text-gray-900 truncate text-sm">
                                        <c:out value="${not empty v.title ? v.title : 'Voucher khuyến mãi'}"/>
                                    </div>
                                    <div class="mt-1 inline-flex items-center gap-1.5 bg-gray-900 text-white px-2.5 py-1 rounded-lg text-xs font-black">
                                        <i class="fa-regular fa-copy text-[10px]"></i>
                                        <span class="voucher-code-txt">${fn:escapeXml(v.code)}</span>
                                    </div>
                                    <c:if test="${v.minOrderAmount != null}">
                                        <div class="mt-1 text-xs text-gray-400">
                                            Đơn từ <fmt:formatNumber value="${v.minOrderAmount}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                                        </div>
                                    </c:if>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>
            </c:if>
        </div>
    </section>

    <%-- ===== MENU + CART ===== --%>
    <section class="mt-8">
        <div class="max-w-7xl mx-auto px-6 grid grid-cols-1 xl:grid-cols-[minmax(0,1fr)_340px] gap-8 items-start">

            <%-- ---- Left: Filter + Food Grid ---- --%>
            <div>
                <%-- Category tabs --%>
                <div class="cat-tabs">
                    <a href="${ctx}/store-detail?id=${store.userId}&keyword=${keyword}&filter=${filter}&sort=${sort}&page=1"
                       class="shrink-0 px-6 h-11 rounded-full inline-flex items-center font-bold border transition
                              ${empty selectedCategory ? 'bg-orange-500 text-white border-orange-500' : 'bg-white text-[#8b6b52] border-[#eadfd7] hover:border-orange-300'}">
                        Tất cả
                    </a>
                    <c:forEach var="c" items="${categories}">
                        <a href="${ctx}/store-detail?id=${store.userId}&category=${c.id}&keyword=${keyword}&filter=${filter}&sort=${sort}&page=1"
                           class="shrink-0 px-6 h-11 rounded-full inline-flex items-center font-bold border transition
                                  ${selectedCategory == c.id ? 'bg-orange-500 text-white border-orange-500' : 'bg-white text-[#8b6b52] border-[#eadfd7] hover:border-orange-300'}">
                            ${c.name}
                        </a>
                    </c:forEach>
                </div>

                <%-- Search + Quick filters --%>
                <div class="mt-5 flex flex-col sm:flex-row gap-3">
                    <form action="${ctx}/store-detail" method="get" class="flex-1">
                        <input type="hidden" name="id" value="${store.userId}">
                        <input type="hidden" name="category" value="${selectedCategory}">
                        <input type="hidden" name="filter" value="${filter}">
                        <input type="hidden" name="sort" value="${sort}">
                        <input type="hidden" name="page" value="1">
                        <div class="bg-white h-12 rounded-full border border-[#eadfd7] px-4 flex items-center gap-3">
                            <i class="fa-solid fa-magnifying-glass text-gray-400"></i>
                            <input type="text" name="keyword" value="${keyword}"
                                   placeholder="Tìm món trong quán..."
                                   class="flex-1 outline-none bg-transparent text-sm">
                            <c:if test="${not empty keyword}">
                                <a href="${ctx}/store-detail?id=${store.userId}&category=${selectedCategory}&filter=${filter}&sort=${sort}&page=1"
                                   class="text-gray-400 hover:text-gray-600">
                                    <i class="fa-solid fa-xmark"></i>
                                </a>
                            </c:if>
                        </div>
                    </form>

                    <div class="flex gap-2">
                        <a href="${ctx}/store-detail?id=${store.userId}&category=${selectedCategory}&keyword=${keyword}&filter=banchay&sort=${sort}&page=1"
                           class="px-4 h-12 rounded-full border inline-flex items-center gap-2 font-semibold text-sm transition
                                  ${filter == 'banchay' ? 'bg-orange-500 text-white border-orange-500' : 'bg-white border-[#eadfd7] hover:border-orange-300'}">
                            <i class="fa-solid fa-fire"></i> Bán chạy
                        </a>
                        <a href="${ctx}/store-detail?id=${store.userId}&category=${selectedCategory}&keyword=${keyword}&filter=giamgia&sort=${sort}&page=1"
                           class="px-4 h-12 rounded-full border inline-flex items-center gap-2 font-semibold text-sm transition
                                  ${filter == 'giamgia' ? 'bg-orange-500 text-white border-orange-500' : 'bg-white border-[#eadfd7] hover:border-orange-300'}">
                            <i class="fa-solid fa-tag"></i> Giảm giá
                        </a>
                    </div>
                </div>

                <div class="mt-3 flex items-center justify-end">
                    <form action="${ctx}/store-detail" method="get" class="flex items-center gap-2">
                        <input type="hidden" name="id" value="${store.userId}">
                        <input type="hidden" name="category" value="${selectedCategory}">
                        <input type="hidden" name="keyword" value="${keyword}">
                        <input type="hidden" name="filter" value="${filter}">
                        <input type="hidden" name="page" value="1">
                        <span class="text-sm text-gray-500 font-semibold">Sắp xếp:</span>
                        <select name="sort" onchange="this.form.submit()"
                                class="h-10 rounded-full border border-[#eadfd7] bg-white px-4 text-sm font-semibold text-[#8b6b52] outline-none">
                            <option value="" ${empty sort ? 'selected' : ''}>Mới nhất</option>
                            <option value="price_asc" ${sort == 'price_asc' ? 'selected' : ''}>Giá tăng dần</option>
                            <option value="price_desc" ${sort == 'price_desc' ? 'selected' : ''}>Giá giảm dần</option>
                            <option value="name_asc" ${sort == 'name_asc' ? 'selected' : ''}>Tên A-Z</option>
                        </select>
                    </form>
                </div>

                <%-- Result count --%>
                <c:if test="${not empty foods}">
                    <p class="mt-4 text-sm text-gray-500 font-medium">
                        Hiển thị <strong>${fn:length(foods)}</strong> / <strong>${totalFoods}</strong> món
                        <c:if test="${not empty keyword}">khớp với "<strong>${keyword}</strong>"</c:if>
                    </p>
                </c:if>

                <%-- Empty state --%>
                <c:if test="${empty foods}">
                    <div class="mt-8 bg-white rounded-[24px] border border-dashed border-[#eadfd7] p-12 text-center">
                        <i class="fa-solid fa-bowl-food text-5xl text-gray-200 mb-4 block"></i>
                        <p class="text-lg font-semibold text-gray-400">
                            <c:choose>
                                <c:when test="${not empty keyword}">Không tìm thấy món nào với từ khóa "${keyword}"</c:when>
                                <c:otherwise>Cửa hàng chưa có món hiển thị trong danh mục này.</c:otherwise>
                            </c:choose>
                        </p>
                    </div>
                </c:if>

                <%-- Food grid --%>
                <c:if test="${not empty foods}">
                    <div class="food-grid mt-5">
                        <c:forEach var="f" items="${foods}">
                            <article class="food-card"
                                     data-id="${f.id}"
                                     data-name="${fn:escapeXml(f.name)}"
                                     data-desc="${fn:escapeXml(f.description)}"
                                     data-price="${f.price}"
                                     data-original="${f.originalPrice}"
                                     data-discount="${f.discountPercent}"
                                     data-image="${fn:escapeXml(f.imageUrl)}"
                                     data-cat="${fn:escapeXml(f.categoryName)}"
                                     data-calories="${f.calories}"
                                     onclick="openFoodModal(this)">

                                <div class="food-img-wrap">
                                    <c:choose>
                                        <c:when test="${fn:startsWith(f.imageUrl, 'http')}">
                                            <img src="${f.imageUrl}" alt="${fn:escapeXml(f.name)}" class="food-img"
                                                 onerror="this.src='${ctx}/assets/images/default-store-cover.jpg'">
                                        </c:when>
                                        <c:when test="${not empty f.imageUrl}">
                                            <img src="${ctx}${f.imageUrl}" alt="${fn:escapeXml(f.name)}" class="food-img"
                                                 onerror="this.src='${ctx}/assets/images/default-store-cover.jpg'">
                                        </c:when>
                                        <c:otherwise>
                                            <img src="${ctx}/assets/images/default-store-cover.jpg" alt="${fn:escapeXml(f.name)}" class="food-img">
                                        </c:otherwise>
                                    </c:choose>

                                    <c:if test="${f.discountPercent > 0}">
                                        <span class="badge-discount">-${f.discountPercent}%</span>
                                    </c:if>

                                    <button type="button" class="btn-add-cart"
                                            title="Thêm nhanh vào giỏ"
                                            onclick="addToCartAjax(event, ${f.id})">
                                        <i class="fa-solid fa-plus"></i>
                                    </button>
                                </div>

                                <div class="p-4">
                                    <div class="flex justify-between gap-2 min-h-[48px]">
                                        <h3 class="font-black text-[15px] leading-snug line-clamp-2 text-gray-900">${fn:escapeXml(f.name)}</h3>
                                        <c:if test="${not empty f.categoryName}">
                                            <span class="shrink-0 text-xs text-[#9d7d68] font-semibold bg-orange-50 px-2 py-1 rounded-lg h-fit">${fn:escapeXml(f.categoryName)}</span>
                                        </c:if>
                                    </div>

                                    <c:if test="${not empty f.description}">
                                        <p class="mt-1.5 text-xs text-gray-400 line-clamp-2 leading-relaxed">${fn:escapeXml(f.description)}</p>
                                    </c:if>

                                    <div class="mt-3 flex items-end justify-between gap-2">
                                        <div>
                                            <div class="text-2xl font-black text-orange-500 leading-none">
                                                <fmt:formatNumber value="${f.price}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                                            </div>
                                            <c:if test="${f.originalPrice > f.price}">
                                                <div class="text-xs line-through text-gray-400 mt-1">
                                                    <fmt:formatNumber value="${f.originalPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                                                </div>
                                            </c:if>
                                        </div>
                                        <c:choose>
                                            <c:when test="${f.rating > 0}">
                                                <span class="text-sm font-bold text-yellow-500">
                                                    <i class="fa-solid fa-star"></i>
                                                    <fmt:formatNumber value="${f.rating}" type="number" minFractionDigits="1" maxFractionDigits="1"/>
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="text-sm font-bold text-gray-300">
                                                    <i class="fa-regular fa-star"></i>
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </article>
                        </c:forEach>
                    </div>
                </c:if>

                <c:if test="${totalPages > 1}">
                    <div class="mt-7 flex items-center justify-center gap-2">
                        <a href="${ctx}/store-detail?id=${store.userId}&category=${selectedCategory}&keyword=${keyword}&filter=${filter}&sort=${sort}&page=${page - 1}"
                           class="px-4 h-10 rounded-full border inline-flex items-center justify-center font-bold ${page <= 1 ? 'pointer-events-none opacity-40 bg-gray-100 border-gray-200 text-gray-400' : 'bg-white border-[#eadfd7] text-[#8b6b52] hover:border-orange-300'}">
                            <i class="fa-solid fa-chevron-left"></i>
                        </a>

                        <c:forEach var="p" begin="1" end="${totalPages}">
                            <c:if test="${p >= page - 2 && p <= page + 2}">
                                <a href="${ctx}/store-detail?id=${store.userId}&category=${selectedCategory}&keyword=${keyword}&filter=${filter}&sort=${sort}&page=${p}"
                                   class="min-w-[40px] h-10 px-3 rounded-full border inline-flex items-center justify-center font-bold ${p == page ? 'bg-orange-500 border-orange-500 text-white' : 'bg-white border-[#eadfd7] text-[#8b6b52] hover:border-orange-300'}">
                                    ${p}
                                </a>
                            </c:if>
                        </c:forEach>

                        <a href="${ctx}/store-detail?id=${store.userId}&category=${selectedCategory}&keyword=${keyword}&filter=${filter}&sort=${sort}&page=${page + 1}"
                           class="px-4 h-10 rounded-full border inline-flex items-center justify-center font-bold ${page >= totalPages ? 'pointer-events-none opacity-40 bg-gray-100 border-gray-200 text-gray-400' : 'bg-white border-[#eadfd7] text-[#8b6b52] hover:border-orange-300'}">
                            <i class="fa-solid fa-chevron-right"></i>
                        </a>
                    </div>
                </c:if>
            </div>

            <%-- ---- Right: Cart Sidebar ---- --%>
            <aside class="xl:sticky xl:top-24 space-y-4">
                <div id="cartSidebar" class="bg-white rounded-[24px] border border-[#eee4dc] shadow-sm p-6">
                    <div class="flex items-center justify-between mb-4">
                        <h3 class="text-xl font-black">Giỏ hàng</h3>
                        <span id="cartCountBadge"
                              class="bg-orange-50 text-orange-500 text-xs font-extrabold px-3 py-1.5 rounded-full">
                            ${cartCount} món
                        </span>
                    </div>

                    <div id="cartItemsList">
                        <c:choose>
                            <c:when test="${empty storeCartItems}">
                                <div id="cartEmptyMsg" class="py-12 text-center text-gray-400">
                                    <i class="fa-solid fa-bag-shopping text-3xl mb-2 block"></i>
                                    <p class="font-semibold text-sm">Chưa có món nào</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="it" items="${storeCartItems}">
                                    <div class="cart-item-row" data-item-id="${it.cartItemId}">
                                        <div class="flex-1 min-w-0">
                                            <div class="font-bold text-sm text-gray-900 line-clamp-2">${fn:escapeXml(it.name)}</div>
                                            <div class="text-xs text-[#9d7d68] mt-0.5">x${it.quantity}</div>
                                        </div>
                                        <div class="text-right shrink-0">
                                            <div class="font-black text-orange-500 text-sm">
                                                <fmt:formatNumber value="${it.unitPrice * it.quantity}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                                            </div>
                                            <button type="button"
                                                    class="mt-1 text-xs text-gray-300 hover:text-red-500 transition"
                                                    onclick="removeFromCart(event, ${it.cartItemId})">
                                                <i class="fa-solid fa-xmark"></i> Xóa
                                            </button>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <div class="mt-4 pt-4 border-t border-[#f1e9e3] space-y-2 text-sm">
                        <div class="flex justify-between text-gray-500">
                            <span>Tạm tính</span>
                            <span id="cartSubtotal" class="font-bold">
                                <fmt:formatNumber value="${cartTotal}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                            </span>
                        </div>
                        <div class="flex justify-between text-gray-500">
                            <span>Phí giao hàng</span>
                            <span class="font-bold text-green-600">15.000đ</span>
                        </div>
                    </div>

                    <div class="mt-4 pt-4 border-t border-dashed border-[#f1e9e3] flex items-center justify-between">
                        <span class="font-black text-lg">Tổng cộng</span>
                        <span id="cartTotalDisplay" class="text-2xl font-black text-orange-500">
                            <fmt:formatNumber value="${cartTotal}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                        </span>
                    </div>

                    <%-- Checkout button --%>
                    <c:choose>
                        <c:when test="${not empty sessionScope.account}">
                            <a id="checkoutBtn" href="${ctx}/checkout"
                               class="mt-5 w-full h-13 py-3.5 rounded-full bg-orange-500 hover:bg-orange-600 text-white font-black
                                      flex items-center justify-center gap-2 transition">
                                Thanh toán <i class="fa-solid fa-arrow-right"></i>
                            </a>
                        </c:when>
                        <c:otherwise>
                            <button type="button"
                                    id="checkoutBtn"
                                    onclick="openCheckoutChoiceModal()"
                                    class="mt-5 w-full py-3.5 rounded-full bg-gray-900 hover:bg-black text-white font-black
                                           flex items-center justify-center gap-2 transition">
                                Thanh toán <i class="fa-solid fa-arrow-right"></i>
                            </button>
                        </c:otherwise>
                    </c:choose>
                </div>

                <div class="bg-[#fff5ef] rounded-[20px] border border-[#f2dfd0] p-4">
                    <div class="flex items-center gap-3">
                        <div class="w-10 h-10 rounded-full bg-white text-orange-500 flex items-center justify-center shadow-sm shrink-0">
                            <i class="fa-regular fa-shield-heart"></i>
                        </div>
                        <div>
                            <div class="font-black text-orange-500 text-sm">ClickEat Đảm Bảo</div>
                            <p class="text-xs text-[#8e715d] mt-1 leading-relaxed">
                                Hoàn tiền 100% nếu món không đúng chất lượng.
                            </p>
                        </div>
                    </div>
                </div>
            </aside>
        </div>
    </section>
</main>

<%-- ===== FOOD DETAIL MODAL ===== --%>
<div id="foodModal" onclick="closeFoodModalOutside(event)">
    <div id="foodModalBox">
        <div id="modalImgWrap" class="relative h-56 bg-gray-100 overflow-hidden rounded-t-[32px] sm:rounded-[28px]">
            <img id="modalImg" src="" alt="" class="w-full h-full object-cover">
            <c:if test="${not empty storeVouchers}">
                <div class="absolute bottom-4 left-4 bg-orange-500 text-white text-xs font-black px-3 py-1.5 rounded-full">
                    <i class="fa-solid fa-ticket mr-1"></i>Có voucher giảm giá
                </div>
            </c:if>
            <button onclick="closeFoodModal()"
                    class="absolute top-4 right-4 w-10 h-10 bg-white/90 rounded-full flex items-center justify-center text-gray-700 hover:bg-white shadow">
                <i class="fa-solid fa-xmark"></i>
            </button>
        </div>

        <div class="p-6">
            <div class="flex items-start justify-between gap-3">
                <div class="min-w-0">
                    <span id="modalCat" class="text-xs font-bold text-orange-500 uppercase tracking-wider"></span>
                    <h2 id="modalName" class="mt-1 text-2xl font-black text-gray-900 leading-snug"></h2>
                </div>
                <div id="modalDiscountBadge" class="shrink-0 hidden px-4 py-2 bg-orange-500 text-white text-sm font-black rounded-full"></div>
            </div>

            <p id="modalDesc" class="mt-3 text-sm text-gray-500 leading-relaxed"></p>

            <%-- Nutrition row --%>
            <div id="modalNutrition" class="hidden mt-4 grid grid-cols-4 gap-2">
                <div class="bg-orange-50 rounded-2xl p-3 text-center">
                    <div id="modalCalories" class="font-black text-lg text-orange-500"></div>
                    <div class="text-xs text-gray-400 mt-1">kcal</div>
                </div>
                <div class="bg-blue-50 rounded-2xl p-3 text-center">
                    <div id="modalProtein" class="font-black text-lg text-blue-500"></div>
                    <div class="text-xs text-gray-400 mt-1">protein</div>
                </div>
                <div class="bg-yellow-50 rounded-2xl p-3 text-center">
                    <div id="modalCarbs" class="font-black text-lg text-yellow-500"></div>
                    <div class="text-xs text-gray-400 mt-1">carbs</div>
                </div>
                <div class="bg-red-50 rounded-2xl p-3 text-center">
                    <div id="modalFat" class="font-black text-lg text-red-400"></div>
                    <div class="text-xs text-gray-400 mt-1">fat</div>
                </div>
            </div>

            <div class="mt-5 flex items-end justify-between gap-4">
                <div>
                    <div id="modalPrice" class="text-3xl font-black text-orange-500 leading-none"></div>
                    <div id="modalOriginalPrice" class="mt-1 text-sm line-through text-gray-400 hidden"></div>
                </div>

                <div class="flex items-center gap-3 shrink-0">
                    <%-- Quantity picker --%>
                    <div class="flex items-center border border-gray-200 rounded-full overflow-hidden">
                        <button type="button" onclick="changeModalQty(-1)"
                                class="w-10 h-10 flex items-center justify-center text-gray-600 hover:bg-gray-100 font-bold text-lg">−</button>
                        <span id="modalQty" class="w-10 text-center font-black text-gray-900">1</span>
                        <button type="button" onclick="changeModalQty(1)"
                                class="w-10 h-10 flex items-center justify-center text-gray-600 hover:bg-gray-100 font-bold text-lg">+</button>
                    </div>

                    <button type="button" id="modalAddBtn"
                            onclick="addFromModal()"
                            class="h-11 px-6 rounded-full bg-orange-500 hover:bg-orange-600 text-white font-black transition flex items-center gap-2">
                        <i class="fa-solid fa-cart-plus"></i> Thêm vào giỏ
                    </button>
                </div>
            </div>
        </div>
    </div>
</div>

<%-- Toast notification --%>
<div id="toast"></div>

<jsp:include page="checkout-choice-modal.jsp" />
<jsp:include page="footer.jsp" />

<script>
    const ctx = '${ctx}';
    let currentFoodId = null;
    let modalQty = 1;

    /* ============ FORMAT HELPERS ============ */
    function fmtPrice(n) {
        return new Intl.NumberFormat('vi-VN').format(Math.round(n)) + 'đ';
    }

    /* ============ TOAST ============ */
    let toastTimer;
    function showToast(msg, type) {
        const t = document.getElementById('toast');
        t.textContent = msg;
        t.className = 'show ' + (type === 'error' ? 'error' : 'success');
        clearTimeout(toastTimer);
        toastTimer = setTimeout(() => { t.className = t.className.replace(' show', ''); }, 2800);
    }

    /* ============ AJAX: ADD TO CART ============ */
    async function addToCartAjax(event, foodId, qty = 1) {
        event.stopPropagation();
        const btn = event.currentTarget;
        btn.disabled = true;
        const origHtml = btn.innerHTML;
        btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i>';

        try {
            const body = new URLSearchParams({ action: 'ajax-add', id: foodId, qty });
            const resp = await fetch(ctx + '/cart', { method: 'POST', body });
            const data = await resp.json();

            if (data.success) {
                showToast('🛒 ' + data.message, 'success');
                updateCartSidebar(data);
            } else {
                showToast(data.message || 'Không thể thêm món.', 'error');
            }
        } catch (err) {
            showToast('Lỗi kết nối. Thử lại sau.', 'error');
        } finally {
            btn.innerHTML = origHtml;
            btn.disabled = false;
        }
    }

    /* ============ AJAX: REMOVE FROM CART ============ */
    async function removeFromCart(event, itemId) {
        event.stopPropagation();
        const row = document.querySelector('[data-item-id="' + itemId + '"]');
        if (row) row.style.opacity = '0.4';

        try {
            const body = new URLSearchParams({ action: 'ajax-remove', itemId });
            const resp = await fetch(ctx + '/cart', { method: 'POST', body });
            const data = await resp.json();

            if (data.success) {
                showToast('Đã xóa món khỏi giỏ.', 'success');
                updateCartSidebar(data);
            } else {
                if (row) row.style.opacity = '1';
                showToast(data.message || 'Không thể xóa.', 'error');
            }
        } catch (err) {
            if (row) row.style.opacity = '1';
            showToast('Lỗi kết nối.', 'error');
        }
    }

    /* ============ UPDATE CART SIDEBAR ============ */
    function updateCartSidebar(data) {
        // Badge
        document.getElementById('cartCountBadge').textContent = data.cartCount + ' món';

        // Subtotal & total
        document.getElementById('cartSubtotal').textContent = fmtPrice(data.cartTotal);
        document.getElementById('cartTotalDisplay').textContent = fmtPrice(data.cartTotal + 15000);

        // Items list
        const listEl = document.getElementById('cartItemsList');
        if (!data.items || data.items.length === 0) {
            listEl.innerHTML = '<div id="cartEmptyMsg" class="py-12 text-center text-gray-400">'
                + '<i class="fa-solid fa-bag-shopping text-3xl mb-2 block"></i>'
                + '<p class="font-semibold text-sm">Chưa có món nào</p></div>';
        } else {
            listEl.innerHTML = data.items.map(function (it) {
                return '<div class="cart-item-row" data-item-id="' + it.id + '">'
                        + '<div class="flex-1 min-w-0">'
                        + '<div class="font-bold text-sm text-gray-900 line-clamp-2">' + escHtml(it.name) + '</div>'
                        + '<div class="text-xs text-[#9d7d68] mt-0.5">x' + it.quantity + '</div>'
                        + '</div>'
                        + '<div class="text-right shrink-0">'
                        + '<div class="font-black text-orange-500 text-sm">' + fmtPrice(it.lineTotal) + '</div>'
                        + '<button type="button"'
                        + ' class="mt-1 text-xs text-gray-300 hover:text-red-500 transition"'
                        + ' onclick="removeFromCart(event, ' + it.id + ')">'
                        + '<i class="fa-solid fa-xmark"></i> Xóa'
                        + '</button>'
                        + '</div>'
                        + '</div>';
            }).join('');
        }

        const headerBadges = document.querySelectorAll('#cartBtn span');
        headerBadges.forEach(function (badge) {
            badge.textContent = data.cartCount;
        });

        window.dispatchEvent(new CustomEvent('ce-cart-updated', {
            detail: {
                cartCount: data.cartCount,
                cartTotal: data.cartTotal,
                items: data.items || []
            }
        }));
    }

    function escHtml(s) {
        return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
    }

    /* ============ FOOD DETAIL MODAL ============ */
    function openFoodModal(card) {
        currentFoodId = card.dataset.id;
        modalQty = 1;
        document.getElementById('modalQty').textContent = '1';

        const name     = card.dataset.name     || '';
        const desc     = card.dataset.desc     || '';
        const price    = parseFloat(card.dataset.price)    || 0;
        const original = parseFloat(card.dataset.original) || 0;
        const discount = parseInt(card.dataset.discount)   || 0;
        const imgRaw   = card.dataset.image    || '';
        const cat      = card.dataset.cat      || '';
        const calories = card.dataset.calories;

        const img = imgRaw.startsWith('http') ? imgRaw : (imgRaw ? ctx + imgRaw : ctx + '/assets/images/default-store-cover.jpg');
        document.getElementById('modalImg').src = img;
        document.getElementById('modalImg').alt = name;
        document.getElementById('modalName').textContent = name;
        document.getElementById('modalDesc').textContent = desc || 'Chưa có mô tả.';
        document.getElementById('modalCat').textContent  = cat;
        document.getElementById('modalPrice').textContent = fmtPrice(price);

        // Discount badge
        const badge = document.getElementById('modalDiscountBadge');
        if (discount > 0) {
            badge.textContent = 'Giảm ' + discount + '%';
            badge.classList.remove('hidden');
        } else {
            badge.classList.add('hidden');
        }

        // Original price
        const origEl = document.getElementById('modalOriginalPrice');
        if (original > price) {
            origEl.textContent = fmtPrice(original);
            origEl.classList.remove('hidden');
        } else {
            origEl.classList.add('hidden');
        }

        // Nutrition
        const nutRow = document.getElementById('modalNutrition');
        if (calories && calories !== '0') {
            document.getElementById('modalCalories').textContent = calories;
            nutRow.classList.remove('hidden');
            nutRow.classList.add('grid');
        } else {
            nutRow.classList.add('hidden');
        }

        document.getElementById('foodModal').classList.add('open');
        document.body.style.overflow = 'hidden';
    }

    function closeFoodModal() {
        document.getElementById('foodModal').classList.remove('open');
        document.body.style.overflow = '';
    }

    function closeFoodModalOutside(e) {
        if (e.target === document.getElementById('foodModal')) closeFoodModal();
    }

    function changeModalQty(delta) {
        modalQty = Math.max(1, modalQty + delta);
        document.getElementById('modalQty').textContent = modalQty;
    }

    async function addFromModal() {
        const btn = document.getElementById('modalAddBtn');
        btn.disabled = true;
        btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i>';

        try {
            const body = new URLSearchParams({ action: 'ajax-add', id: currentFoodId, qty: modalQty });
            const resp = await fetch(ctx + '/cart', { method: 'POST', body });
            const data = await resp.json();

            if (data.success) {
                showToast('🛒 ' + data.message, 'success');
                updateCartSidebar(data);
                closeFoodModal();
            } else {
                showToast(data.message || 'Không thể thêm món.', 'error');
            }
        } catch (err) {
            showToast('Lỗi kết nối.', 'error');
        } finally {
            btn.disabled = false;
            btn.innerHTML = '<i class="fa-solid fa-cart-plus"></i> Thêm vào giỏ';
        }
    }

    /* ============ VOUCHER COPY ============ */
    function copyVoucherCode(code, card) {
        navigator.clipboard.writeText(code).then(() => {
            const txt = card.querySelector('.voucher-code-txt');
            const orig = txt ? txt.textContent : code;
            if (txt) txt.textContent = '✓ Đã sao chép';
            showToast('Đã sao chép mã ' + code, 'success');
            setTimeout(() => { if (txt) txt.textContent = orig; }, 2000);
        }).catch(() => {
            showToast('Không thể sao chép tự động.', 'error');
        });
    }

    /* ============ ESC KEY ============ */
    document.addEventListener('keydown', e => {
        if (e.key === 'Escape') closeFoodModal();
    });
</script>
</body>
</html>
