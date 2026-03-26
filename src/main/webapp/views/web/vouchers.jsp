<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@taglib prefix="fn" uri="jakarta.tags.functions" %>

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
        <style>
            .voucher-pop{
                transition:transform .22s ease, box-shadow .22s ease;
            }
            .voucher-pop:hover{
                transform:translateY(-5px);
                box-shadow:0 18px 36px rgba(15,23,42,.12);
            }
            .voucher-notch{
                position:absolute;
                top:50%;
                width:18px;
                height:18px;
                border-radius:999px;
                background:#f4f5f7;
                transform:translateY(-50%);
            }
            .voucher-notch.left{ left:-9px; }
            .voucher-notch.right{ right:-9px; }
        </style>
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
                    <div class="mb-5 grid grid-cols-1 sm:grid-cols-3 gap-3">
                        <div class="bg-white rounded-2xl border border-orange-100 px-4 py-3">
                            <div class="text-xs font-bold uppercase tracking-[.12em] text-orange-400">Voucher khả dụng</div>
                            <div class="mt-1 text-2xl font-black text-orange-500">${totalVouchers}</div>
                        </div>
                        <div class="bg-white rounded-2xl border border-orange-100 px-4 py-3">
                            <div class="text-xs font-bold uppercase tracking-[.12em] text-orange-400">Mức giảm nổi bật</div>
                            <div class="mt-1 text-base font-black text-gray-900">Giảm sâu theo từng quán</div>
                        </div>
                        <div class="bg-white rounded-2xl border border-orange-100 px-4 py-3">
                            <div class="text-xs font-bold uppercase tracking-[.12em] text-orange-400">Mẹo dùng nhanh</div>
                            <div class="mt-1 text-sm font-semibold text-gray-600">Sao chép mã và dán ở bước thanh toán</div>
                        </div>
                    </div>

                    <div class="bg-white border border-gray-200 rounded-[24px] p-4 md:p-5 mb-5 shadow-[0_6px_20px_rgba(15,23,42,.05)]">
                        <form action="${pageContext.request.contextPath}/customer/vouchers" method="get"
                        class="flex flex-col md:flex-row gap-3 md:items-center">
                        <div class="flex-1 h-11 rounded-full border border-gray-200 px-4 flex items-center gap-3">
                            <i class="fa-solid fa-magnifying-glass text-gray-400"></i>
                            <input type="text" name="keyword" value="${keyword}" placeholder="Tìm theo mã, tên voucher, cửa hàng..."
                            class="flex-1 outline-none bg-transparent text-sm">
                        </div>

                        <select name="sort" class="h-11 rounded-full border border-gray-200 px-4 text-sm font-semibold text-gray-700 outline-none">
                            <option value="expiring" ${sort == 'expiring' || empty sort ? 'selected' : ''}>Sắp hết hạn</option>
                            <option value="discount_desc" ${sort == 'discount_desc' ? 'selected' : ''}>Giảm nhiều nhất</option>
                            <option value="min_order_asc" ${sort == 'min_order_asc' ? 'selected' : ''}>Đơn tối thiểu thấp nhất</option>
                        </select>

                        <button type="submit"
                        class="h-11 px-6 rounded-full bg-orange-500 hover:bg-orange-600 text-white font-extrabold transition">
                        Lọc
                    </button>
                </form>

                <c:if test="${totalVouchers > 0}">
                    <p class="mt-3 text-sm text-gray-500">
                        Hiển thị <strong>${fn:length(vouchers)}</strong> / <strong>${totalVouchers}</strong> voucher khả dụng.
                    </p>
                </c:if>
            </div>

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
                            <div class="voucher-pop relative overflow-hidden rounded-[28px] border border-orange-100 bg-white shadow-[0_10px_30px_rgba(15,23,42,.06)]">
                                <div class="absolute top-0 right-0 w-28 h-28 bg-orange-100 rounded-full blur-2xl opacity-60 -translate-y-1/2 translate-x-1/3"></div>
                                <span class="voucher-notch left"></span>
                                <span class="voucher-notch right"></span>

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
                                            <div class="text-xs uppercase tracking-[0.18em] text-orange-400 font-black">Mã ưu đãi</div>
                                            <div class="mt-1 px-3 py-2 rounded-2xl bg-gray-900 text-white font-black text-sm break-all">
                                                <c:out value="${empty v.code ? 'N/A' : v.code}" />
                                            </div>
                                            <div class="mt-2 inline-flex items-center gap-1 text-[11px] font-bold text-red-500 bg-red-50 px-2 py-1 rounded-full">
                                                <i class="fa-regular fa-clock"></i>
                                                Ưu tiên dùng sớm
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

                                    <c:if test="${totalPages > 1}">
                                        <div class="mt-6 flex items-center justify-center gap-2">
                                            <a href="${pageContext.request.contextPath}/customer/vouchers?keyword=${keyword}&sort=${sort}&page=${page - 1}"
                                            class="px-4 h-10 rounded-full border inline-flex items-center justify-center font-bold ${page <= 1 ? 'pointer-events-none opacity-40 bg-gray-100 border-gray-200 text-gray-400' : 'bg-white border-gray-200 text-gray-700 hover:border-orange-300'}">
                                            <i class="fa-solid fa-chevron-left"></i>
                                        </a>

                                        <c:forEach var="p" begin="1" end="${totalPages}">
                                            <c:if test="${p >= page - 2 && p <= page + 2}">
                                                <a href="${pageContext.request.contextPath}/customer/vouchers?keyword=${keyword}&sort=${sort}&page=${p}"
                                                class="min-w-[40px] h-10 px-3 rounded-full border inline-flex items-center justify-center font-bold ${p == page ? 'bg-orange-500 border-orange-500 text-white' : 'bg-white border-gray-200 text-gray-700 hover:border-orange-300'}">
                                                ${p}
                                            </a>
                                        </c:if>
                                    </c:forEach>

                                    <a href="${pageContext.request.contextPath}/customer/vouchers?keyword=${keyword}&sort=${sort}&page=${page + 1}"
                                    class="px-4 h-10 rounded-full border inline-flex items-center justify-center font-bold ${page >= totalPages ? 'pointer-events-none opacity-40 bg-gray-100 border-gray-200 text-gray-400' : 'bg-white border-gray-200 text-gray-700 hover:border-orange-300'}">
                                    <i class="fa-solid fa-chevron-right"></i>
                                </a>
                            </div>
                        </c:if>
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