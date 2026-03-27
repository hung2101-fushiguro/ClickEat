<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ClickEat - Khuyến mãi</title>
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <link rel="shortcut icon" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    </head>
    <body class="bg-[#f4f5f7] text-gray-900">
        <jsp:include page="/views/web/header.jsp">
    <jsp:param name="activePage" value="promotion" />
</jsp:include>

        <main class="max-w-7xl mx-auto px-6 py-10">
            <div class="max-w-4xl">
                <h1 class="text-5xl font-black tracking-tight">Khuyến mãi</h1>
                <p class="mt-3 text-lg text-gray-500">
                    Tìm và lưu mã giảm giá để dùng khi thanh toán.
                </p>
            </div>

            <c:if test="${not empty sessionScope.toastMsg}">
                <div class="mt-6 rounded-[24px] border border-green-200 bg-green-50 px-5 py-4 text-green-700 font-semibold shadow-sm">
                    <i class="fa-solid fa-circle-check mr-2"></i>
                    ${sessionScope.toastMsg}
                </div>
                <c:remove var="toastMsg" scope="session"/>
            </c:if>

            <c:if test="${not empty sessionScope.toastError}">
                <div class="mt-6 rounded-[24px] border border-red-200 bg-red-50 px-5 py-4 text-red-700 font-semibold shadow-sm">
                    <i class="fa-solid fa-circle-exclamation mr-2"></i>
                    ${sessionScope.toastError}
                </div>
                <c:remove var="toastError" scope="session"/>
            </c:if>

            <!-- Search -->
            <form method="get" action="${pageContext.request.contextPath}/promotions"
                  class="mt-8 flex flex-col md:flex-row gap-4">
                <input type="hidden" name="tab" value="${empty tab ? 'all' : tab}">
                <div class="flex-1 relative">
                    <span class="absolute left-5 top-1/2 -translate-y-1/2 text-gray-400">
                        <i class="fa-solid fa-magnifying-glass"></i>
                    </span>
                    <input type="text"
                           name="keyword"
                           value="${keyword}"
                           placeholder="Tìm mã giảm giá, tên voucher, tên quán..."
                           class="w-full h-14 pl-14 pr-5 rounded-full border border-gray-200 bg-white outline-none focus:ring-2 focus:ring-orange-300 text-gray-800">
                </div>

                <button type="submit"
                        class="h-14 px-8 rounded-full bg-orange-500 text-white font-extrabold hover:bg-orange-600 transition shadow-sm">
                    Tìm kiếm
                </button>
            </form>

            <!-- Tabs -->
            <div class="mt-6 flex flex-wrap gap-3">
                <a href="${pageContext.request.contextPath}/promotions?tab=all&keyword=${keyword}"
                   class="px-5 h-11 rounded-full inline-flex items-center font-bold border transition
                          ${tab eq 'all' ? 'bg-orange-100 text-orange-600 border-orange-200' : 'bg-white text-gray-700 border-gray-200 hover:bg-gray-50'}">
                    Tất cả
                </a>

                <a href="${pageContext.request.contextPath}/promotions?tab=freeship&keyword=${keyword}"
                   class="px-5 h-11 rounded-full inline-flex items-center font-bold border transition
                          ${tab eq 'freeship' ? 'bg-orange-100 text-orange-600 border-orange-200' : 'bg-white text-gray-700 border-gray-200 hover:bg-gray-50'}">
                    Freeship
                </a>

                <a href="${pageContext.request.contextPath}/promotions?tab=percent&keyword=${keyword}"
                   class="px-5 h-11 rounded-full inline-flex items-center font-bold border transition
                          ${tab eq 'percent' ? 'bg-orange-100 text-orange-600 border-orange-200' : 'bg-white text-gray-700 border-gray-200 hover:bg-gray-50'}">
                    % Giảm
                </a>

                <a href="${pageContext.request.contextPath}/promotions?tab=fixed&keyword=${keyword}"
                   class="px-5 h-11 rounded-full inline-flex items-center font-bold border transition
                          ${tab eq 'fixed' ? 'bg-orange-100 text-orange-600 border-orange-200' : 'bg-white text-gray-700 border-gray-200 hover:bg-gray-50'}">
                    Giảm tiền
                </a>

                <a href="${pageContext.request.contextPath}/promotions?tab=saved&keyword=${keyword}"
                   class="px-5 h-11 rounded-full inline-flex items-center font-bold border transition
                          ${tab eq 'saved' ? 'bg-orange-100 text-orange-600 border-orange-200' : 'bg-white text-gray-700 border-gray-200 hover:bg-gray-50'}">
                    Đã lưu
                </a>
            </div>

            <!-- Grid -->
            <c:choose>
                <c:when test="${empty systemVouchers}">
                    <div class="mt-10 bg-white border border-gray-200 rounded-[32px] p-12 text-center shadow-[0_10px_30px_rgba(15,23,42,.06)]">
                        <div class="w-20 h-20 mx-auto rounded-full bg-orange-100 text-orange-500 flex items-center justify-center text-3xl">
                            <i class="fa-solid fa-ticket"></i>
                        </div>
                        <h2 class="mt-5 text-2xl font-black">Không tìm thấy voucher phù hợp</h2>
                        <p class="mt-2 text-gray-500">
                            Hãy thử tìm theo mã, tên quán, từ khóa như “miễn phí”, “15k”, “giảm”.
                        </p>
                    </div>
                </c:when>

                <c:otherwise>
                    <div class="mt-10 grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
                        <c:forEach var="v" items="${systemVouchers}">
                            <div class="overflow-hidden rounded-[30px] border border-gray-200 bg-white shadow-[0_10px_30px_rgba(15,23,42,.06)] hover:-translate-y-1 transition">
                                <div class="p-6 bg-gradient-to-br from-orange-50 to-white">
                                    <div class="flex items-start justify-between gap-3">
                                        <div class="inline-flex px-3 py-1 rounded-full bg-orange-100 text-orange-600 text-xs font-extrabold">
                                            <c:out value="${empty v.displayDiscount ? 'Ưu đãi' : v.displayDiscount}" />
                                        </div>

                                        <div class="text-right">
                                            <div class="text-[11px] uppercase tracking-[0.18em] text-gray-400 font-bold">Mã</div>
                                            <div class="mt-1 text-sm font-black text-gray-700">
                                                <c:out value="${empty v.code ? '---' : v.code}" />
                                            </div>
                                        </div>
                                    </div>

                                    <h3 class="mt-5 text-3xl font-black text-gray-900 break-words">
                                        <c:out value="${empty v.title ? v.code : v.title}" />
                                    </h3>

                                    <p class="mt-2 text-sm text-gray-500">
                                        <c:out value="${empty v.description ? 'Áp dụng theo điều kiện của cửa hàng.' : v.description}" />
                                    </p>
                                </div>

                                <div class="p-6">
                                    <div class="space-y-3 text-sm text-gray-600">
                                        <div>
                                            <span class="font-bold text-gray-800">Quán:</span>
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
                                            <span class="font-bold text-gray-800">Hạn dùng:</span>
                                            <c:choose>
                                                <c:when test="${not empty v.endAt}">
                                                    <fmt:formatDate value="${v.endAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                </c:when>
                                                <c:otherwise>Chưa xác định</c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>

                                    <div class="mt-6">
                                        <c:choose>
                                            <c:when test="${savedVoucherIds.contains(v.id)}">
                                                <button type="button"
                                                        disabled
                                                        class="w-full h-12 rounded-full bg-gray-200 text-gray-500 font-extrabold cursor-not-allowed">
                                                    Đã lưu
                                                </button>
                                            </c:when>

                                            <c:otherwise>
                                                <form method="post" action="${pageContext.request.contextPath}/customer/vouchers">
                                                    <input type="hidden" name="action" value="save">
                                                    <input type="hidden" name="voucherId" value="${v.id}">
                                                    <button type="submit"
                                                            class="w-full h-12 rounded-full bg-orange-500 text-white font-extrabold hover:bg-orange-600 transition">
                                                        Lưu vào kho
                                                    </button>
                                                </form>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:otherwise>
            </c:choose>
        </main>
    </body>
</html>