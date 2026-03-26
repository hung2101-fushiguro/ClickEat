<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ClickEat - Khuyến mãi</title>
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    </head>
    <body class="bg-[#f4f5f7] text-gray-900">
        <c:set var="ctx" value="${pageContext.request.contextPath}" />

        <jsp:include page="header.jsp">
            <jsp:param name="activePage" value="promotion" />
        </jsp:include>

        <main class="max-w-7xl mx-auto px-6 py-8">
            <div class="mb-6">
                <h1 class="text-4xl font-black tracking-tight">Khuyến mãi</h1>
                <p class="mt-2 text-gray-500">Tổng hợp voucher đang hoạt động từ các cửa hàng đối tác.</p>
            </div>

            <form action="${ctx}/promotion" method="get" class="bg-white border border-gray-200 rounded-2xl p-4 mb-6 flex flex-col md:flex-row gap-3 md:items-center">
                <div class="flex-1 h-11 rounded-full border border-gray-200 px-4 flex items-center gap-3">
                    <i class="fa-solid fa-magnifying-glass text-gray-400"></i>
                    <input type="text" name="keyword" value="${keyword}" placeholder="Tìm theo mã, tên voucher, cửa hàng..."
                    class="flex-1 outline-none bg-transparent text-sm">
                </div>

                <select name="sort" class="h-11 rounded-full border border-gray-200 px-4 text-sm font-semibold text-gray-700 outline-none">
                    <option value="expiring" ${sort == 'expiring' || empty sort ? 'selected' : ''}>Sắp hết hạn</option>
                    <option value="discount_desc" ${sort == 'discount_desc' ? 'selected' : ''}>Giảm nhiều nhất</option>
                    <option value="merchant_asc" ${sort == 'merchant_asc' ? 'selected' : ''}>Tên cửa hàng A-Z</option>
                </select>

                <button type="submit" class="h-11 px-6 rounded-full bg-orange-500 hover:bg-orange-600 text-white font-extrabold transition">
                    Lọc ưu đãi
                </button>
            </form>

            <c:if test="${totalItems > 0}">
                <p class="mb-4 text-sm text-gray-500">Hiển thị <strong>${fn:length(vouchers)}</strong> / <strong>${totalItems}</strong> voucher.</p>
            </c:if>

            <c:choose>
                <c:when test="${empty vouchers}">
                    <div class="bg-white border border-gray-200 rounded-[24px] p-10 text-center shadow-[0_10px_30px_rgba(15,23,42,.06)]">
                        <div class="w-20 h-20 mx-auto rounded-full bg-orange-100 text-orange-500 flex items-center justify-center text-3xl">
                            <i class="fa-solid fa-ticket"></i>
                        </div>
                        <h2 class="mt-5 text-2xl font-black">Hiện chưa có khuyến mãi phù hợp</h2>
                        <p class="mt-2 text-gray-500">Vui lòng thử từ khóa khác hoặc quay lại sau.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                        <c:forEach var="v" items="${vouchers}">
                            <div class="relative overflow-hidden rounded-[24px] border border-orange-100 bg-white shadow-[0_8px_24px_rgba(15,23,42,.06)]">
                                <div class="relative p-6">
                                    <div class="flex items-start justify-between gap-4">
                                        <div class="min-w-0">
                                            <div class="inline-flex px-3 py-1 rounded-full bg-orange-100 text-orange-600 text-xs font-extrabold">
                                                <c:out value="${empty v.displayDiscount ? 'Ưu đãi' : v.displayDiscount}" />
                                            </div>

                                            <h3 class="mt-4 text-xl font-black text-gray-900">
                                                <c:out value="${empty v.title ? 'Voucher khuyến mãi' : v.title}" />
                                            </h3>

                                            <p class="mt-2 text-sm text-gray-500 leading-6">
                                                <c:out value="${empty v.description ? 'Áp dụng theo điều kiện của cửa hàng.' : v.description}" />
                                            </p>
                                        </div>

                                        <div class="text-right shrink-0">
                                            <div class="text-xs uppercase tracking-[0.18em] text-gray-400 font-bold">Mã</div>
                                            <div class="mt-1 px-3 py-2 rounded-xl bg-gray-900 text-white font-black text-sm break-all">
                                                <c:out value="${empty v.code ? 'N/A' : v.code}" />
                                            </div>
                                        </div>
                                    </div>

                                    <div class="mt-5 grid grid-cols-1 sm:grid-cols-2 gap-3 text-sm text-gray-600">
                                        <div>
                                            <span class="font-bold text-gray-800">Cửa hàng:</span>
                                            <c:out value="${empty v.merchantName ? 'ClickEat Partner' : v.merchantName}" />
                                        </div>
                                        <div>
                                            <span class="font-bold text-gray-800">Đơn tối thiểu:</span>
                                            <c:choose>
                                                <c:when test="${v.minOrderAmount != null}">
                                                    <fmt:formatNumber value="${v.minOrderAmount}" type="number" groupingUsed="true"/>đ
                                                    </c:when>
                                                    <c:otherwise>Không yêu cầu</c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <div>
                                                    <span class="font-bold text-gray-800">Giảm tối đa:</span>
                                                    <c:choose>
                                                        <c:when test="${v.maxDiscountAmount != null}">
                                                            <fmt:formatNumber value="${v.maxDiscountAmount}" type="number" groupingUsed="true"/>đ
                                                            </c:when>
                                                            <c:otherwise>Không giới hạn</c:otherwise>
                                                            </c:choose>
                                                        </div>
                                                        <div>
                                                            <span class="font-bold text-gray-800">Hết hạn:</span>
                                                            <c:choose>
                                                                <c:when test="${not empty v.endAt}">
                                                                    <fmt:formatDate value="${v.endAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                                </c:when>
                                                                <c:otherwise>Chưa xác định</c:otherwise>
                                                                </c:choose>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </div>

                                        <c:if test="${totalPages > 1}">
                                            <div class="mt-7 flex items-center justify-center gap-2">
                                                <a href="${ctx}/promotion?keyword=${keyword}&sort=${sort}&page=${page - 1}"
                                                class="px-4 h-10 rounded-full border inline-flex items-center justify-center font-bold ${page <= 1 ? 'pointer-events-none opacity-40 bg-gray-100 border-gray-200 text-gray-400' : 'bg-white border-gray-200 text-gray-700 hover:border-orange-300'}">
                                                <i class="fa-solid fa-chevron-left"></i>
                                            </a>

                                            <c:forEach var="p" begin="1" end="${totalPages}">
                                                <c:if test="${p >= page - 2 && p <= page + 2}">
                                                    <a href="${ctx}/promotion?keyword=${keyword}&sort=${sort}&page=${p}"
                                                    class="min-w-[40px] h-10 px-3 rounded-full border inline-flex items-center justify-center font-bold ${p == page ? 'bg-orange-500 border-orange-500 text-white' : 'bg-white border-gray-200 text-gray-700 hover:border-orange-300'}">
                                                    ${p}
                                                </a>
                                            </c:if>
                                        </c:forEach>

                                        <a href="${ctx}/promotion?keyword=${keyword}&sort=${sort}&page=${page + 1}"
                                        class="px-4 h-10 rounded-full border inline-flex items-center justify-center font-bold ${page >= totalPages ? 'pointer-events-none opacity-40 bg-gray-100 border-gray-200 text-gray-400' : 'bg-white border-gray-200 text-gray-700 hover:border-orange-300'}">
                                        <i class="fa-solid fa-chevron-right"></i>
                                    </a>
                                </div>
                            </c:if>
                        </c:otherwise>
                    </c:choose>
                </main>
            </body>
        </html>
