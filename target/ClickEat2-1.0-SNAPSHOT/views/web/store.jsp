<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Cửa hàng - ClickEat</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    </head>
    <body class="bg-[#f7f5f3] text-gray-900">
        <c:set var="ctx" value="${pageContext.request.contextPath}" />

        <jsp:include page="header.jsp">
            <jsp:param name="activePage" value="store" />
        </jsp:include>

        <main class="pb-20">
            <section class="pt-8">
                <div class="max-w-7xl mx-auto px-6">
                    <form action="${ctx}/store" method="get" class="max-w-4xl mx-auto">
                        <input type="hidden" name="district" value="${district}">
                        <input type="hidden" name="sort" value="${sort}">

                        <div class="bg-white rounded-2xl border border-gray-200 h-16 px-5 flex items-center gap-4 shadow-sm">
                            <div class="relative shrink-0">
                                <select name="province"
                                        onchange="this.form.submit()"
                                        class="appearance-none bg-transparent text-orange-500 font-bold pl-7 pr-8 h-11 rounded-full outline-none cursor-pointer">
                                    <c:forEach var="p" items="${provinces}">
                                        <option value="${p}" ${province == p ? 'selected' : ''}>${p}</option>
                                    </c:forEach>
                                </select>
                                <i class="fa-solid fa-location-dot absolute left-2 top-1/2 -translate-y-1/2 text-orange-500"></i>
                            </div>

                            <div class="w-px h-7 bg-gray-200"></div>

                            <i class="fa-solid fa-magnifying-glass text-gray-400"></i>

                            <input type="text"
                                   name="keyword"
                                   value="${keyword}"
                                   placeholder="Tìm kiếm quán ăn, món nổi bật..."
                                   class="flex-1 outline-none bg-transparent text-[15px] h-full leading-none" />

                            <button type="submit"
                                    class="shrink-0 inline-flex items-center justify-center bg-orange-500 hover:bg-orange-600 text-white font-bold px-8 h-11 rounded-full leading-none">
                                Tìm kiếm
                            </button>
                        </div>
                    </form>
                </div>
            </section>

            <section class="pt-10">
                <div class="max-w-7xl mx-auto px-6">
                    <h1 class="text-[56px] font-black tracking-[-0.04em] leading-none">Cửa hàng</h1>
                    <p class="text-lg text-[#9a7b66] mt-3">Chọn quán bạn thích — đặt nhanh trong vài giây.</p>

                    <div class="mt-8 flex flex-wrap gap-3">
                        <a href="${ctx}/store"
                           class="px-7 h-12 rounded-full border font-bold inline-flex items-center justify-center
                           ${empty district ? 'bg-orange-500 text-white border-orange-500' : 'bg-white text-[#8b6b52] border-[#eadfd7]'}">
                            ALL
                        </a>

                        <c:forEach var="d" items="${districts}">
                            <a href="${ctx}/store?district=${d}"
                               class="px-7 h-12 rounded-full border font-bold inline-flex items-center justify-center
                               ${district == d ? 'bg-orange-500 text-white border-orange-500' : 'bg-white text-[#8b6b52] border-[#eadfd7]'}">
                                ${d}
                            </a>
                        </c:forEach>
                    </div>

                    <div class="mt-8 flex flex-wrap items-center justify-between gap-4">
                        <div class="flex flex-wrap gap-3">
                            <a href="${ctx}/store?keyword=${keyword}&district=${district}"
                               class="px-6 h-11 rounded-full border bg-white border-[#eadfd7] font-semibold inline-flex items-center gap-2">
                                <i class="fa-regular fa-paper-plane"></i> Gần tôi
                            </a>
                            <a href="${ctx}/store?keyword=${keyword}&district=${district}&sort=rating"
                               class="px-6 h-11 rounded-full border bg-white border-[#eadfd7] font-semibold inline-flex items-center gap-2">
                                <i class="fa-solid fa-arrow-trend-up"></i> Bán chạy
                            </a>
                            <a href="${ctx}/store?keyword=${keyword}&district=${district}&sort=price"
                               class="px-6 h-11 rounded-full border bg-white border-[#eadfd7] font-semibold inline-flex items-center gap-2">
                                <i class="fa-regular fa-star"></i> Giá tốt
                            </a>
                            <a href="${ctx}/store?keyword=${keyword}&district=${district}&sort=latest"
                               class="px-6 h-11 rounded-full border bg-white border-[#eadfd7] font-semibold inline-flex items-center gap-2">
                                <i class="fa-solid fa-bolt"></i> Mới lên
                            </a>
                        </div>

                        <form action="${ctx}/store" method="get">
                            <input type="hidden" name="keyword" value="${keyword}">
                            <select name="district"
                                    onchange="this.form.submit()"
                                    class="bg-white border border-[#eadfd7] rounded-full h-11 px-5 min-w-[220px] outline-none font-semibold text-[#8b6b52]">
                                <option value="">Chọn Quận / huyện</option>
                                <c:forEach var="d" items="${districts}">
                                    <option value="${d}" ${district == d ? 'selected' : ''}>${d}</option>
                                </c:forEach>
                            </select>
                        </form>
                    </div>

                    <c:if test="${empty stores}">
                        <div class="mt-10 bg-white rounded-[28px] border border-dashed border-[#eadfd7] p-14 text-center">
                            <i class="fa-solid fa-store text-5xl text-gray-300 mb-4"></i>
                            <p class="text-lg font-semibold text-gray-500">Không tìm thấy cửa hàng phù hợp.</p>
                        </div>
                    </c:if>

                    <c:if test="${not empty stores}">
                        <div class="mt-8 grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-7 items-stretch">
                            <c:forEach var="s" items="${stores}">
                                <article class="bg-white rounded-[28px] overflow-hidden border border-[#eee4dc] shadow-sm hover:shadow-lg transition h-full">
                                    <a href="${ctx}/store-detail?id=${s.userId}" class="block h-full">
                                        <div class="h-full flex flex-col">
                                            <div class="relative h-[240px] overflow-hidden">
                                                <img src="${s.imageUrl}" alt="${s.shopName}" class="w-full h-full object-cover">
                                                <div class="absolute top-4 left-4 flex gap-2">
                                                    <span class="bg-red-500 text-white text-xs font-extrabold px-3 py-2 rounded-full">
                                                        <i class="fa-solid fa-bolt"></i> Hot Deal
                                                    </span>
                                                    <c:if test="${not empty s.voucherTitle}">
                                                        <span class="bg-orange-500 text-white text-xs font-extrabold px-3 py-2 rounded-full">
                                                            Ưu đãi
                                                        </span>
                                                    </c:if>
                                                </div>
                                            </div>

                                            <div class="p-6 flex flex-col flex-1">
                                                <div class="flex items-start justify-between gap-4 min-h-[50px]">
                                                    <h3 class="text-[32px] leading-none tracking-[-0.03em] font-black line-clamp-2">
                                                        ${s.shopName}
                                                    </h3>
                                                    <div class="text-right shrink-0">
                                                        <div class="text-orange-500 font-black text-sm">${s.itemCount} món</div>
                                                    </div>
                                                </div>

                                                <p class="text-sm text-[#9d7d68] mt-3 leading-6 min-h-[30px] line-clamp-2">
                                                    ${s.shopAddressLine}, ${s.districtName}, ${s.provinceName}
                                                </p>

                                                <div class="flex flex-wrap gap-3 mt-6 min-h-[92px] content-start">
                                                    <span class="bg-[#f6f1ec] px-4 py-2 rounded-full text-sm font-bold">
                                                        <i class="fa-solid fa-star text-orange-400"></i>
                                                        <fmt:formatNumber value="${s.rating}" type="number" minFractionDigits="1" maxFractionDigits="1"/>
                                                    </span>
                                                    <span class="bg-[#f6f1ec] px-4 py-2 rounded-full text-sm font-bold">
                                                        <i class="fa-regular fa-clock text-[#9d7d68]"></i> ${s.deliveryTime}
                                                    </span>
                                                    <span class="bg-[#f6f1ec] px-4 py-2 rounded-full text-sm font-bold">
                                                        <i class="fa-solid fa-location-dot text-[#9d7d68]"></i> ${s.distance}
                                                    </span>
                                                    <span class="bg-[#f6f1ec] px-4 py-2 rounded-full text-sm font-bold">
                                                        <i class="fa-solid fa-motorcycle text-orange-500"></i> Giao nhanh
                                                    </span>
                                                </div>

                                                <div class="mt-4 min-h-[74px] flex items-end justify-between gap-4">
                                                    <div>
                                                        <div class="text-sm text-[#9d7d68]">Danh mục nổi bật</div>
                                                        <div class="font-bold text-lg line-clamp-1">
                                                            ${empty s.categoryName ? 'Món ngon' : s.categoryName}
                                                        </div>
                                                    </div>
                                                    <div class="text-right shrink-0">
                                                        <div class="text-sm text-[#9d7d68]">Từ</div>
                                                        <div class="text-orange-500 font-black text-2xl">
                                                            <fmt:formatNumber value="${s.minPrice}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                                                        </div>
                                                    </div>
                                                </div>

                                                <div class="mt-auto pt-5 border-t border-[#f0e8e1] flex items-center justify-between gap-3 min-h-[68px]">
                                                    <div class="text-sm text-[#9d7d68] line-clamp-1">
                                                        ${empty s.voucherTitle ? 'Đang mở bán hôm nay' : s.voucherTitle}
                                                    </div>
                                                    <span class="inline-flex items-center gap-2 font-black text-orange-500 shrink-0">
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
    </body>
</html>