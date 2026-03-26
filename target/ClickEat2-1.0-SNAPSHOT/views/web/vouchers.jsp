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
                    Lưu lại các mã giảm giá còn hiệu lực để sử dụng cho đơn tiếp theo.
                </p>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-[280px_minmax(0,1fr)] gap-7">
                <jsp:include page="sidebar.jsp">
                    <jsp:param name="menu" value="vouchers" />
                </jsp:include>

                <section class="min-w-0">
                    <c:choose>
                        <c:when test="${empty vouchers}">
                            <div class="bg-white border border-gray-200 rounded-[32px] p-10 text-center shadow-[0_10px_30px_rgba(15,23,42,.06)]">
                                <div class="w-20 h-20 mx-auto rounded-full bg-orange-100 text-orange-500 flex items-center justify-center text-3xl">
                                    <i class="fa-solid fa-ticket"></i>
                                </div>
                                <h2 class="mt-5 text-2xl font-black">Hiện chưa có voucher phù hợp</h2>
                                <p class="mt-2 text-gray-500">Bạn hãy quay lại sau hoặc theo dõi các chiến dịch khuyến mãi mới.</p>
                            </div>
                        </c:when>

                        <c:otherwise>
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                                <c:forEach var="v" items="${vouchers}">
                                    <div class="relative overflow-hidden rounded-[28px] border border-orange-100 bg-white shadow-[0_10px_30px_rgba(15,23,42,.06)]">
                                        <div class="absolute top-0 right-0 w-28 h-28 bg-orange-100 rounded-full blur-2xl opacity-60 -translate-y-1/2 translate-x-1/3"></div>

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
                                                    <div class="mt-1 px-3 py-2 rounded-2xl bg-gray-900 text-white font-black text-sm break-all">
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

                                            <div class="mt-5 pt-4 border-t border-gray-100 flex items-center justify-between gap-3">
                                                <div class="text-xs text-gray-400">
                                                    Dùng mã khi thanh toán để nhận ưu đãi.
                                                </div>

                                                <button type="button"
                                                        class="copy-code-btn inline-flex items-center gap-2 px-4 h-10 rounded-full bg-orange-500 text-white font-extrabold hover:bg-orange-600 transition"
                                                        data-code="${v.code}">
                                                    <i class="fa-regular fa-copy"></i>
                                                    Sao chép mã
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
                        this.innerHTML = '<i class="fa-solid fa-check"></i> Đã sao chép';
                        this.classList.remove('bg-orange-500', 'hover:bg-orange-600');
                        this.classList.add('bg-green-500');

                        setTimeout(() => {
                            this.innerHTML = oldHtml;
                            this.classList.remove('bg-green-500');
                            this.classList.add('bg-orange-500', 'hover:bg-orange-600');
                        }, 1500);
                    } catch (e) {
                        alert('Không thể sao chép mã. Vui lòng sao chép thủ công.');
                    }
                });
            });
        </script>
    </body>
</html>