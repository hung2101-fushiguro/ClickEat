<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ClickEat - Thực đơn</title>
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
        <style>
            .menu-card-pop{
                position:relative;
                transition:transform .2s ease, box-shadow .2s ease;
            }
            .menu-card-pop:hover{
                transform:translateY(-4px);
                box-shadow:0 16px 34px rgba(15,23,42,.10);
            }
            .menu-card-glow{
                position:absolute;
                right:-34px;
                top:-34px;
                width:120px;
                height:120px;
                border-radius:999px;
                background:rgba(255,122,26,.16);
                filter:blur(12px);
                pointer-events:none;
            }
            .deal-chip{
                background:#fff4ec;
                color:#e36a00;
                border:1px solid #ffd8be;
            }
        </style>
    </head>
    <body class="bg-[#f7f5f3] text-gray-900">
        <c:set var="ctx" value="${pageContext.request.contextPath}" />

        <jsp:include page="header.jsp">
            <jsp:param name="activePage" value="menu" />
        </jsp:include>

        <main class="max-w-7xl mx-auto px-6 py-8">
            <div class="mb-6">
                <div class="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-orange-100 text-orange-600 text-sm font-extrabold mb-3">
                    <i class="fa-solid fa-sparkles"></i>
                    Deal nổi bật mỗi ngày
                </div>
                <h1 class="text-4xl font-black tracking-tight">Thực đơn</h1>
                <p class="mt-2 text-gray-500">Khám phá món ăn từ các cửa hàng đang mở trên ClickEat.</p>
            </div>

            <form action="${ctx}/menu" method="get" class="bg-white border border-gray-200 rounded-2xl p-4 mb-6 flex flex-col md:flex-row gap-3 md:items-center">
                <div class="flex-1 h-11 rounded-full border border-gray-200 px-4 flex items-center gap-3">
                    <i class="fa-solid fa-magnifying-glass text-gray-400"></i>
                    <input type="text" name="keyword" value="${keyword}" placeholder="Tìm món, danh mục hoặc cửa hàng..."
                    class="flex-1 outline-none bg-transparent text-sm">
                </div>

                <select name="sort" class="h-11 rounded-full border border-gray-200 px-4 text-sm font-semibold text-gray-700 outline-none">
                    <option value="" ${empty sort ? 'selected' : ''}>Mới nhất</option>
                    <option value="discount_desc" ${sort == 'discount_desc' ? 'selected' : ''}>Giảm giá cao</option>
                    <option value="price_asc" ${sort == 'price_asc' ? 'selected' : ''}>Giá tăng dần</option>
                    <option value="price_desc" ${sort == 'price_desc' ? 'selected' : ''}>Giá giảm dần</option>
                </select>

                <button type="submit" class="h-11 px-6 rounded-full bg-orange-500 hover:bg-orange-600 text-white font-extrabold transition">
                    Lọc món
                </button>
            </form>

            <c:if test="${totalItems > 0}">
                <p class="mb-4 text-sm text-gray-500">Hiển thị <strong>${fn:length(foods)}</strong> / <strong>${totalItems}</strong> món.</p>
            </c:if>

            <c:choose>
                <c:when test="${empty foods}">
                    <div class="bg-white rounded-2xl border border-dashed border-[#eadfd7] p-12 text-center">
                        <i class="fa-solid fa-bowl-food text-5xl text-gray-200 mb-4 block"></i>
                        <p class="text-lg font-semibold text-gray-400">Không tìm thấy món phù hợp.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
                        <c:forEach var="f" items="${foods}">
                            <article class="menu-card-pop bg-white rounded-2xl border border-[#eee4dc] overflow-hidden shadow-sm">
                                <div class="menu-card-glow"></div>
                                <div class="relative aspect-square bg-gray-100">
                                    <c:choose>
                                        <c:when test="${fn:startsWith(f.imageUrl, 'http')}">
                                            <img src="${f.imageUrl}" alt="${fn:escapeXml(f.name)}" class="w-full h-full object-cover"
                                            onerror="this.src='${ctx}/assets/images/default-store-cover.jpg'">
                                        </c:when>
                                        <c:when test="${not empty f.imageUrl}">
                                            <img src="${ctx}${f.imageUrl}" alt="${fn:escapeXml(f.name)}" class="w-full h-full object-cover"
                                            onerror="this.src='${ctx}/assets/images/default-store-cover.jpg'">
                                        </c:when>
                                        <c:otherwise>
                                            <img src="${ctx}/assets/images/default-store-cover.jpg" alt="${fn:escapeXml(f.name)}" class="w-full h-full object-cover">
                                        </c:otherwise>
                                    </c:choose>

                                    <c:if test="${f.discountPercent > 0}">
                                        <span class="absolute top-3 left-3 bg-orange-500 text-white text-xs font-black px-2 py-1 rounded-full">-${f.discountPercent}%</span>
                                    </c:if>
                                    <span class="absolute bottom-3 left-3 deal-chip text-[11px] font-extrabold px-3 py-1 rounded-full">
                                        <i class="fa-solid fa-ticket mr-1"></i> Có ưu đãi
                                    </span>
                                </div>

                                <div class="p-4">
                                    <h3 class="font-black text-[15px] leading-snug text-gray-900 line-clamp-2">${fn:escapeXml(f.name)}</h3>
                                    <p class="mt-1 text-xs text-[#9d7d68] font-semibold">
                                        ${fn:escapeXml(f.merchantName)}
                                        <c:if test="${not empty f.categoryName}">• ${fn:escapeXml(f.categoryName)}</c:if>
                                        </p>

                                        <div class="mt-3 flex items-center justify-between">
                                            <div>
                                                <div class="text-xl font-black text-orange-500 leading-none">
                                                    <fmt:formatNumber value="${f.price}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                                                    </div>
                                                    <c:if test="${f.originalPrice > f.price}">
                                                        <div class="text-xs line-through text-gray-400 mt-1">
                                                            <fmt:formatNumber value="${f.originalPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                                                            </div>
                                                            <div class="mt-1 text-[11px] font-extrabold text-green-600">
                                                                Tiết kiệm
                                                                <fmt:formatNumber value="${f.originalPrice - f.price}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                                                                </div>
                                                            </c:if>
                                                        </div>
                                                        <a href="${ctx}/store-detail?id=${f.merchantUserId}"
                                                        class="h-9 px-4 rounded-full bg-orange-500 text-white font-bold text-sm inline-flex items-center hover:bg-orange-600 transition">
                                                        Xem quán
                                                        <i class="fa-solid fa-arrow-right ml-2 text-[11px]"></i>
                                                    </a>
                                                </div>
                                            </div>
                                        </article>
                                    </c:forEach>
                                </div>

                                <c:if test="${totalPages > 1}">
                                    <div class="mt-7 flex items-center justify-center gap-2">
                                        <a href="${ctx}/menu?keyword=${keyword}&sort=${sort}&page=${page - 1}"
                                        class="px-4 h-10 rounded-full border inline-flex items-center justify-center font-bold ${page <= 1 ? 'pointer-events-none opacity-40 bg-gray-100 border-gray-200 text-gray-400' : 'bg-white border-[#eadfd7] text-[#8b6b52] hover:border-orange-300'}">
                                        <i class="fa-solid fa-chevron-left"></i>
                                    </a>

                                    <c:forEach var="p" begin="1" end="${totalPages}">
                                        <c:if test="${p >= page - 2 && p <= page + 2}">
                                            <a href="${ctx}/menu?keyword=${keyword}&sort=${sort}&page=${p}"
                                            class="min-w-[40px] h-10 px-3 rounded-full border inline-flex items-center justify-center font-bold ${p == page ? 'bg-orange-500 border-orange-500 text-white' : 'bg-white border-[#eadfd7] text-[#8b6b52] hover:border-orange-300'}">
                                            ${p}
                                        </a>
                                    </c:if>
                                </c:forEach>

                                <a href="${ctx}/menu?keyword=${keyword}&sort=${sort}&page=${page + 1}"
                                class="px-4 h-10 rounded-full border inline-flex items-center justify-center font-bold ${page >= totalPages ? 'pointer-events-none opacity-40 bg-gray-100 border-gray-200 text-gray-400' : 'bg-white border-[#eadfd7] text-[#8b6b52] hover:border-orange-300'}">
                                <i class="fa-solid fa-chevron-right"></i>
                            </a>
                        </div>
                    </c:if>
                </c:otherwise>
            </c:choose>
        </main>
    </body>
</html>
