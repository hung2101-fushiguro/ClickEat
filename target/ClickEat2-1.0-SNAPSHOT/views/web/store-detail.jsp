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
        <link rel="shortcut icon" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

        <style>
            .store-food-grid{
                display:grid;
                grid-template-columns:repeat(3, minmax(0, 1fr));
                gap:24px;
            }

            .food-card-clean{
                background:#fff;
                border:1px solid #eee4dc;
                border-radius:26px;
                overflow:hidden;
                box-shadow:0 10px 30px rgba(15,23,42,.06);
                transition:transform .22s ease, box-shadow .22s ease;
                height:100%;
            }

            .food-card-clean:hover{
                transform:translateY(-4px);
                box-shadow:0 18px 40px rgba(15,23,42,.10);
            }

            .food-card-inner{
                display:flex;
                flex-direction:column;
                height:100%;
            }

            .food-image-wrap{
                position:relative;
                aspect-ratio:1 / 1;
                overflow:hidden;
                background:#f3f4f6;
            }

            .food-image{
                width:100%;
                height:100%;
                object-fit:cover;
                display:block;
            }

            .store-add-cart-btn{
                position:absolute;
                right:16px;
                bottom:16px;
                width:52px;
                height:52px;
                border-radius:999px;
                border:none;
                background:#fff3eb;
                color:#ff7a1a;
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:18px;
                box-shadow:0 14px 26px rgba(255,122,26,.16);
                cursor:pointer;
                transition:.18s ease;
            }

            .store-add-cart-btn:hover{
                background:#ff7a1a;
                color:#fff;
                transform:translateY(-1px);
            }

            .food-body-clean{
                padding:20px 20px 18px;
                display:flex;
                flex-direction:column;
                flex:1;
            }

            .food-head-row{
                display:flex;
                align-items:flex-start;
                justify-content:space-between;
                gap:12px;
                min-height:56px;
            }

            .food-title-clean{
                margin:0;
                flex:1;
                font-size:16px;
                line-height:1.25;
                font-weight:900;
                letter-spacing:-.01em;
                color:#111827;
                display:-webkit-box;
                -webkit-line-clamp:2;
                -webkit-box-orient:vertical;
                overflow:hidden;
                word-break:break-word;
            }

            .food-discount-badge{
                flex-shrink:0;
                min-width:98px;
                height:42px;
                padding:0 12px;
                border-radius:999px;
                background:#ff7a1a;
                color:#fff;
                font-size:13px;
                font-weight:900;
                display:inline-flex;
                align-items:center;
                justify-content:center;
                text-align:center;
                line-height:1;
                white-space:nowrap;
            }

            .food-store-line{
                margin-top:10px;
                min-height:24px;
                font-size:13px;
                line-height:1.5;
                color:#9d7d68;
                display:-webkit-box;
                -webkit-line-clamp:1;
                -webkit-box-orient:vertical;
                overflow:hidden;
            }

            .food-store-name{
                font-weight:700;
                text-decoration:underline;
            }

            .food-desc-clean{
                margin:10px 0 0;
                min-height:48px;
                color:#8e715d;
                font-size:14px;
                line-height:1.6;
                display:-webkit-box;
                -webkit-line-clamp:2;
                -webkit-box-orient:vertical;
                overflow:hidden;
            }

            .food-bottom-row{
                margin-top:auto;
                padding-top:16px;
                display:flex;
                align-items:flex-end;
                justify-content:space-between;
                gap:12px;
            }

            .food-price-wrap{
                min-height:64px;
                display:flex;
                flex-direction:column;
                justify-content:flex-end;
            }

            .food-price-now{
                font-size:32px;
                line-height:1;
                font-weight:950;
                letter-spacing:-.03em;
                color:#ff7a1a;
            }

            .food-price-old{
                margin-top:8px;
                color:#b8a598;
                text-decoration:line-through;
                font-size:13px;
                font-weight:700;
                line-height:1;
            }

            .food-rating-clean{
                flex-shrink:0;
                padding-bottom:2px;
                font-size:16px;
                font-weight:800;
                color:#b68618;
            }

            @media (max-width: 1280px){
                .store-food-grid{
                    grid-template-columns:repeat(2, minmax(0, 1fr));
                }
            }

            @media (max-width: 768px){
                .store-food-grid{
                    grid-template-columns:1fr;
                }
            }
        </style>
    </head>
    <body class="bg-[#f7f5f3] text-gray-900">
        <c:set var="ctx" value="${pageContext.request.contextPath}" />

        <jsp:include page="header.jsp">
            <jsp:param name="activePage" value="store" />
        </jsp:include>

        <main class="pb-20">
            <section class="pt-8">
                <div class="max-w-7xl mx-auto px-6">
                    <c:url var="backToStoreUrl" value="/store">
                        <c:param name="province" value="${param.province}" />
                        <c:param name="district" value="${param.district}" />
                        <c:param name="keyword" value="${param.keyword}" />
                        <c:param name="sort" value="${param.sort}" />
                    </c:url>

                    <a href="${backToStoreUrl}" class="text-[#8e6d57] font-bold inline-flex items-center gap-2 mb-6">
                        <i class="fa-solid fa-arrow-left"></i> Quay lại
                    </a>

                    <div class="h-[340px] rounded-[30px] overflow-hidden">
                        <c:choose>
                            <c:when test="${not empty store.imageUrl}">
                                <img src="${ctx}${store.imageUrl}" alt="${store.shopName}" class="w-full h-full object-cover">
                            </c:when>
                            <c:otherwise>
                                <img src="${ctx}/assets/images/default-store-cover.jpg" alt="${store.shopName}" class="w-full h-full object-cover">
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <div class="relative -mt-24 ml-8 mr-8 md:mr-96 bg-white rounded-[28px] shadow-xl border border-[#eee4dc] p-7">
                        <div class="flex flex-col md:flex-row md:items-start md:justify-between gap-5">
                            <div>
                                <h1 class="text-[52px] leading-none tracking-[-0.05em] font-black">${store.shopName}</h1>
                                <p class="text-[#9d7d68] mt-4">
                                    <i class="fa-solid fa-location-dot mr-2"></i>
                                    ${store.shopAddressLine}, ${store.districtName}, ${store.provinceName}
                                </p>
                            </div>

                            <div class="flex flex-col gap-2">
                                <span class="bg-[#fff3ef] text-[#ff6d3a] text-xs font-extrabold px-4 py-2 rounded-full">
                                    Mã giảm ${empty store.voucherTitle ? '16%' : store.voucherTitle}
                                </span>
                                <span class="bg-[#fff3ef] text-[#ff6d3a] text-xs font-extrabold px-4 py-2 rounded-full">
                                    Freeship
                                </span>
                                <span class="bg-[#eaf8ef] text-[#18a957] text-xs font-extrabold px-4 py-2 rounded-full">
                                    Giao nhanh
                                </span>
                            </div>
                        </div>

                        <div class="flex flex-wrap gap-4 mt-6">
                            <span class="bg-[#f7f2ee] px-4 py-3 rounded-full text-sm font-bold">
                                <i class="fa-solid fa-star text-orange-400"></i>
                                <fmt:formatNumber value="${store.rating}" type="number" minFractionDigits="1" maxFractionDigits="1"/>
                            </span>
                            <span class="bg-[#f7f2ee] px-4 py-3 rounded-full text-sm font-bold">
                                <i class="fa-regular fa-clock text-[#9d7d68]"></i> ${store.deliveryTime}
                            </span>
                            <span class="bg-[#f7f2ee] px-4 py-3 rounded-full text-sm font-bold">
                                <i class="fa-solid fa-location-dot text-[#9d7d68]"></i> ${store.distance}
                            </span>
                            <span class="bg-[#f7f2ee] px-4 py-3 rounded-full text-sm font-bold">
                                <i class="fa-solid fa-motorcycle text-orange-500"></i> Giao nhanh
                            </span>
                        </div>
                    </div>
                </div>
            </section>

            <section class="pt-10">
                <div class="max-w-7xl mx-auto px-6 grid grid-cols-1 xl:grid-cols-[minmax(0,1fr)_340px] gap-8">
                    <div>
                        <div class="flex flex-wrap gap-3">
                            <a href="${ctx}/store-detail?id=${store.userId}&keyword=${keyword}&filter=${filter}"
                               class="px-7 h-12 rounded-full inline-flex items-center justify-center font-bold border
                               ${empty selectedCategory ? 'bg-orange-500 text-white border-orange-500' : 'bg-white text-[#8b6b52] border-[#eadfd7]'}">
                                ALL
                            </a>

                            <c:forEach var="c" items="${categories}">
                                <a href="${ctx}/store-detail?id=${store.userId}&category=${c.id}&keyword=${keyword}&filter=${filter}"
                                   class="px-7 h-12 rounded-full inline-flex items-center justify-center font-bold border
                                   ${selectedCategory == c.id ? 'bg-orange-500 text-white border-orange-500' : 'bg-white text-[#8b6b52] border-[#eadfd7]'}">
                                    ${c.name}
                                </a>
                            </c:forEach>
                        </div>

                        <div class="mt-7 flex flex-col lg:flex-row lg:items-center gap-4">
                            <form action="${ctx}/store-detail" method="get" class="flex-1">
                                <input type="hidden" name="id" value="${store.userId}">
                                <input type="hidden" name="category" value="${selectedCategory}">
                                <input type="hidden" name="filter" value="${filter}">
                                <div class="bg-white h-14 rounded-full border border-[#eadfd7] px-5 flex items-center gap-3">
                                    <i class="fa-solid fa-magnifying-glass text-gray-400"></i>
                                    <input type="text" name="keyword" value="${keyword}" placeholder="Tìm món trong cửa hàng..."
                                           class="flex-1 outline-none bg-transparent">
                                </div>
                            </form>

                            <div class="flex flex-wrap gap-3">
                                <a href="${ctx}/store-detail?id=${store.userId}&category=${selectedCategory}&keyword=${keyword}&filter=banchay"
                                   class="px-5 h-12 rounded-full border border-[#eadfd7] inline-flex items-center gap-2 font-semibold
                                   ${filter == 'banchay' ? 'bg-orange-500 text-white border-orange-500' : 'bg-white'}">
                                    <i class="fa-solid fa-fire"></i> Bán chạy
                                </a>
                                <a href="${ctx}/store-detail?id=${store.userId}&category=${selectedCategory}&keyword=${keyword}&filter=giamgia"
                                   class="px-5 h-12 rounded-full border border-[#eadfd7] inline-flex items-center gap-2 font-semibold
                                   ${filter == 'giamgia' ? 'bg-orange-500 text-white border-orange-500' : 'bg-white'}">
                                    <i class="fa-solid fa-tag"></i> Giảm giá
                                </a>
                            </div>
                        </div>

                        <c:if test="${empty foods}">
                            <div class="mt-8 bg-white rounded-[28px] border border-dashed border-[#eadfd7] p-14 text-center">
                                <i class="fa-solid fa-bowl-food text-5xl text-gray-300 mb-4"></i>
                                <p class="text-lg font-semibold text-gray-500">
                                    Cửa hàng chưa có món phù hợp để hiển thị.
                                </p>
                            </div>
                        </c:if>

                        <c:if test="${not empty foods}">
                            <div class="store-food-grid mt-8">
                                <c:forEach var="f" items="${foods}">
                                    <article class="food-card-clean">
                                        <div class="food-card-inner">

                                            <div class="food-image-wrap">
                                                <c:choose>
                                                    <c:when test="${not empty f.imageUrl}">
                                                        <img src="${ctx}${f.imageUrl}"
                                                             alt="${f.name}"
                                                             class="food-image"
                                                             onerror="this.onerror=null;this.src='${ctx}/assets/images/food-placeholder.png';">
                                                    </c:when>
                                                    <c:otherwise>
                                                        <img src="${ctx}/assets/images/food-placeholder.png"
                                                             alt="${f.name}"
                                                             class="food-image">
                                                    </c:otherwise>
                                                </c:choose>

                                                <button type="button"
                                                        onclick="addToCart('${f.id}')"
                                                        class="add-cart-btn store-add-cart-btn"
                                                        title="Thêm vào giỏ hàng">
                                                    <i class="fa-solid fa-cart-plus"></i>
                                                </button>
                                            </div>

                                            <div class="food-body-clean">
                                                <div class="food-head-row">
                                                    <h3 class="food-title-clean">${f.name}</h3>

                                                    <c:if test="${f.discountPercent > 0}">
                                                        <span class="food-discount-badge">
                                                            Giảm ${f.discountPercent}%
                                                        </span>
                                                    </c:if>
                                                </div>

                                                <div class="food-store-line">
                                                    Cửa hàng:
                                                    <span class="food-store-name">${store.shopName}</span>
                                                </div>

                                                <p class="food-desc-clean">
                                                    ${f.description}
                                                </p>

                                                <div class="food-bottom-row">
                                                    <div class="food-price-wrap">
                                                        <div class="food-price-now">
                                                            <fmt:formatNumber value="${f.price}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                                                        </div>

                                                        <c:if test="${f.originalPrice > f.price}">
                                                            <div class="food-price-old">
                                                                <fmt:formatNumber value="${f.originalPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                                                            </div>
                                                        </c:if>
                                                    </div>

                                                    <div class="food-rating-clean">
                                                        <i class="fa-solid fa-star text-yellow-400"></i> 4.8
                                                    </div>
                                                </div>
                                            </div>

                                        </div>
                                    </article>
                                </c:forEach>
                            </div>
                        </c:if>
                    </div>

                    <aside class="space-y-5">
                        <div class="bg-white rounded-[28px] border border-[#eee4dc] shadow-sm p-6 sticky top-24">
                            <div class="flex items-center justify-between">
                                <h3 class="text-[22px] font-black">Giỏ hàng của bạn</h3>
                                <span class="bg-orange-50 text-orange-500 text-xs font-extrabold px-3 py-2 rounded-full">
                                    ${cartCount} món
                                </span>
                            </div>

                            <c:if test="${empty storeCartItems}">
                                <div class="py-16 text-center text-gray-400 font-semibold">
                                    Chưa có món nào được chọn
                                </div>
                            </c:if>

                            <c:if test="${not empty storeCartItems}">
                                <div class="mt-5 space-y-4">
                                    <c:forEach var="it" items="${storeCartItems}">
                                        <div class="flex items-start justify-between gap-3">
                                            <div class="min-w-0">
                                                <div class="font-bold text-gray-900 line-clamp-2">${it.name}</div>
                                                <div class="text-sm text-[#9d7d68]">SL: ${it.quantity}</div>
                                            </div>
                                            <div class="text-right shrink-0">
                                                <div class="font-black text-orange-500">
                                                    <fmt:formatNumber value="${it.unitPrice * it.quantity}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                                                </div>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:if>

                            <div class="mt-7 space-y-3 text-[15px]">
                                <div class="flex items-center justify-between gap-3">
                                    <span class="text-[#9d7d68]">Tạm tính</span>
                                    <span class="font-bold text-right shrink-0">
                                        <fmt:formatNumber value="${cartTotal}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                                    </span>
                                </div>
                                <div class="flex items-center justify-between gap-3">
                                    <span class="text-[#9d7d68]">Phí giao hàng</span>
                                    <span class="font-bold text-green-600 text-right shrink-0">Miễn phí</span>
                                </div>
                            </div>

                            <div class="mt-6 pt-5 border-t border-[#f1e9e3] flex items-center justify-between gap-4">
                                <span class="text-[20px] font-black leading-none whitespace-nowrap">Tổng cộng</span>
                                <span class="text-[32px] font-black text-orange-500 leading-none text-right shrink-0 whitespace-nowrap">
                                    <fmt:formatNumber value="${cartTotal}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                                </span>
                            </div>

                            <c:choose>
                                <c:when test="${not empty storeCartItems && not empty sessionScope.account}">
                                    <a href="${ctx}/checkout"
                                       class="mt-6 h-14 rounded-full bg-orange-500 hover:bg-orange-600 text-white font-black flex items-center justify-center gap-3">
                                        Thanh toán <i class="fa-solid fa-arrow-right"></i>
                                    </a>
                                </c:when>
                                <c:when test="${not empty storeCartItems}">
                                    <button type="button"
                                            onclick="openCheckoutChoiceModal()"
                                            class="mt-6 w-full h-14 rounded-full bg-gray-900 hover:bg-black text-white font-black flex items-center justify-center gap-3">
                                        Thanh toán <i class="fa-solid fa-arrow-right"></i>
                                    </button>
                                </c:when>
                                <c:otherwise>
                                    <button type="button"
                                            disabled
                                            class="mt-6 w-full h-14 rounded-full bg-gray-200 text-gray-500 font-black flex items-center justify-center gap-3 cursor-not-allowed">
                                        Chưa có món để thanh toán
                                    </button>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <div class="bg-[#fff5ef] rounded-[24px] border border-[#f2dfd0] p-5">
                            <div class="flex items-start gap-4">
                                <div class="w-12 h-12 rounded-full bg-white text-orange-500 flex items-center justify-center shadow-sm">
                                    <i class="fa-regular fa-shield-heart"></i>
                                </div>
                                <div>
                                    <div class="font-black text-orange-500">ClickEat Đảm Bảo</div>
                                    <p class="text-sm text-[#8e715d] mt-2">
                                        Hoàn tiền 100% nếu món ăn không đúng chất lượng cam kết.
                                    </p>
                                </div>
                            </div>
                        </div>
                    </aside>
                </div>
            </section>

        </main>

        <jsp:include page="checkout-choice-modal.jsp" />
        <jsp:include page="footer.jsp" />

        <script>
            function addToCart(foodId) {
                window.location.href = '${pageContext.request.contextPath}/cart?action=add&id=' + foodId;
            }
        </script>
    </body>
</html>