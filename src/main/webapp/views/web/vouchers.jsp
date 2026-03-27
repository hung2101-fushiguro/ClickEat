<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ClickEat - Kho voucher</title>
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <link rel="shortcut icon" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    </head>
    <body class="bg-[#f4f5f7] text-gray-900">
        <jsp:include page="/views/web/header.jsp">
            <jsp:param name="activePage" value="profile" />
        </jsp:include>

        <main class="max-w-7xl mx-auto px-6 py-8">
            <div class="mb-8">
                <div class="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-orange-100 text-orange-600 text-sm font-extrabold">
                    <i class="fa-solid fa-ticket"></i>
                    Ưu đãi dành cho bạn
                </div>
                <h1 class="mt-4 text-4xl font-black tracking-tight">Kho voucher</h1>
                <p class="mt-2 text-gray-500 text-lg">
                    Chỉ những voucher bạn đã lưu mới hiển thị ở đây và mới dùng được tại trang thanh toán.
                </p>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-[280px_minmax(0,1fr)] gap-7">
                <jsp:include page="sidebar.jsp">
                    <jsp:param name="menu" value="vouchers" />
                </jsp:include>

                <section class="min-w-0 space-y-6">

                    <c:if test="${not empty sessionScope.toastMsg}">
                        <div class="rounded-[24px] border border-green-200 bg-green-50 px-5 py-4 text-green-700 font-semibold shadow-sm">
                            <i class="fa-solid fa-circle-check mr-2"></i>
                            ${sessionScope.toastMsg}
                        </div>
                        <c:remove var="toastMsg" scope="session"/>
                    </c:if>

                    <c:if test="${not empty sessionScope.toastError}">
                        <div class="rounded-[24px] border border-red-200 bg-red-50 px-5 py-4 text-red-700 font-semibold shadow-sm">
                            <i class="fa-solid fa-circle-exclamation mr-2"></i>
                            ${sessionScope.toastError}
                        </div>
                        <c:remove var="toastError" scope="session"/>
                    </c:if>

                    <div class="flex flex-col xl:flex-row xl:items-center xl:justify-between gap-5">
                        <div>
                            <h2 class="text-2xl font-black text-gray-900">Voucher đã lưu của bạn</h2>
                            <p class="mt-1 text-sm text-gray-500">
                                Chỉ những voucher nằm trong kho này mới được chấp nhận khi bạn nhập mã ở checkout.
                            </p>
                        </div>

                        <div class="flex flex-col sm:flex-row items-stretch sm:items-center gap-3 shrink-0">
                            <a href="${pageContext.request.contextPath}/promotions"
                               class="inline-flex items-center justify-center gap-2 px-6 h-12 min-w-[190px] rounded-full border-2 border-orange-500 bg-white text-orange-500 font-extrabold whitespace-nowrap leading-none hover:bg-orange-500 hover:text-white transition">
                                <i class="fa-solid fa-tags"></i>
                                <span>Xem khuyến mãi</span>
                            </a>

                            <a href="${pageContext.request.contextPath}/checkout"
                               class="inline-flex items-center justify-center gap-2 px-6 h-12 min-w-[190px] rounded-full border-2 border-orange-500 bg-white text-orange-500 font-extrabold whitespace-nowrap leading-none hover:bg-orange-500 hover:text-white transition">
                                <i class="fa-solid fa-cart-shopping"></i>
                                <span>Đi tới checkout</span>
                            </a>
                        </div>
                    </div>

                    <c:choose>
                        <c:when test="${empty savedVouchers}">
                            <div class="bg-white border border-gray-200 rounded-[32px] p-10 text-center shadow-[0_10px_30px_rgba(15,23,42,.06)]">
                                <div class="w-20 h-20 mx-auto rounded-full bg-orange-100 text-orange-500 flex items-center justify-center text-3xl">
                                    <i class="fa-solid fa-box-open"></i>
                                </div>
                                <h2 class="mt-5 text-2xl font-black">Kho voucher của bạn đang trống</h2>
                                <p class="mt-2 text-gray-500">
                                    Hãy vào mục <span class="font-bold text-orange-600">Khuyến mãi</span> để lưu voucher trước.
                                </p>

                                <a href="${pageContext.request.contextPath}/promotions"
                                   class="mt-6 inline-flex items-center gap-2 px-5 h-11 rounded-full bg-orange-500 text-white font-extrabold hover:bg-orange-600 transition">
                                    <i class="fa-solid fa-ticket"></i>
                                    Đi tới khuyến mãi
                                </a>
                            </div>
                        </c:when>

                        <c:otherwise>
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                                <c:forEach var="v" items="${savedVouchers}">
                                    <div class="relative overflow-hidden rounded-[28px] border border-green-100 bg-white shadow-[0_10px_30px_rgba(15,23,42,.06)]">
                                        <div class="absolute top-0 right-0 w-28 h-28 bg-green-100 rounded-full blur-2xl opacity-60 -translate-y-1/2 translate-x-1/3"></div>

                                        <div class="relative p-6">
                                            <div class="flex items-start justify-between gap-4">
                                                <div class="min-w-0">
                                                    <div class="inline-flex px-3 py-1 rounded-full bg-green-100 text-green-600 text-xs font-extrabold">
                                                        Đã lưu vào kho
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
                                                    <div class="mt-1 px-4 h-12 rounded-2xl bg-gray-900 text-white font-black text-sm inline-flex items-center justify-center whitespace-nowrap">
                                                        <c:out value="${empty v.savedCode ? 'N/A' : v.savedCode}" />
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="mt-5 grid grid-cols-1 sm:grid-cols-2 gap-3 text-sm text-gray-600">
                                                <div>
                                                    <span class="font-bold text-gray-800">Cửa hàng:</span>
                                                    <c:out value="${empty v.merchantName ? 'ClickEat Partner' : v.merchantName}" />
                                                </div>

                                                <div>
                                                    <span class="font-bold text-gray-800">Trạng thái:</span>
                                                    <c:choose>
                                                        <c:when test="${v.status eq 'USED'}">
                                                            <span class="font-bold text-red-600">Đã dùng</span>
                                                        </c:when>
                                                        <c:when test="${v.status eq 'EXPIRED'}">
                                                            <span class="font-bold text-gray-500">Hết hạn</span>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="font-bold text-green-600">Sẵn sàng</span>
                                                        </c:otherwise>
                                                    </c:choose>
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

                                                <div>
                                                    <span class="font-bold text-gray-800">Đã lưu lúc:</span>
                                                    <c:choose>
                                                        <c:when test="${not empty v.savedAt}">
                                                            <fmt:formatDate value="${v.savedAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                        </c:when>
                                                        <c:otherwise>---</c:otherwise>
                                                    </c:choose>
                                                </div>
                                            </div>

                                            <div class="mt-5 pt-4 border-t border-gray-100 flex items-center justify-between gap-3">
                                                <div class="text-xs text-gray-400">
                                                    Dùng mã này ở trang checkout để nhận ưu đãi.
                                                </div>

                                                <button type="button"
                                                        class="copy-code-btn inline-flex items-center justify-center gap-2 px-5 h-12 min-w-[150px] rounded-full bg-green-500 text-white font-extrabold hover:bg-green-600 transition whitespace-nowrap leading-none"
                                                        data-code="${v.savedCode}">
                                                    <i class="fa-regular fa-copy"></i>
                                                    <span>Sao chép mã</span>
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:otherwise>
                    </c:choose>

                </section>
            </div>
        </main>

        <script>
            document.querySelectorAll('.copy-code-btn').forEach(btn => {
                btn.addEventListener('click', async function () {
                    const code = this.getAttribute('data-code') || '';
                    if (!code)
                        return;

                    try {
                        await navigator.clipboard.writeText(code);
                        const oldHtml = this.innerHTML;
                        this.innerHTML = '<i class="fa-solid fa-check"></i><span>Đã sao chép</span>';
                        this.classList.remove('bg-green-500', 'hover:bg-green-600');
                        this.classList.add('bg-emerald-600');

                        setTimeout(() => {
                            this.innerHTML = oldHtml;
                            this.classList.remove('bg-emerald-600');
                            this.classList.add('bg-green-500', 'hover:bg-green-600');
                        }, 1500);
                    } catch (e) {
                        alert('Không thể sao chép mã. Vui lòng sao chép thủ công.');
                    }
                });
            });
        </script>
        <jsp:include page="footer.jsp" />
    </body>
</html>