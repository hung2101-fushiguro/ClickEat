<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/responsive-global.css">
        <title>ClickEat - Lịch sử đơn hàng</title>
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <link rel="shortcut icon" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
        <style>
            .rating-star-btn.active {
                background-color: #f97316;
                color: #fff;
                border-color: #f97316;
                box-shadow: 0 8px 18px rgba(249, 115, 22, 0.28);
            }
        </style>
    </head>
    <body class="bg-[#f4f5f7] text-gray-900">
        <jsp:include page="/views/web/header.jsp">
            <jsp:param name="activePage" value="profile" />
        </jsp:include>

        <main class="max-w-7xl mx-auto px-6 py-8">
            <div class="mb-8">
                <div class="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-orange-100 text-orange-600 text-sm font-extrabold">
                    <i class="fa-solid fa-clock-rotate-left"></i>
                    Đơn hàng của bạn
                </div>
                <h1 class="mt-4 text-4xl font-black tracking-tight">Lịch sử đơn hàng</h1>
                <p class="mt-2 text-gray-500 text-lg">Theo dõi các đơn bạn đã đặt trên ClickEat.</p>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-[280px_minmax(0,1fr)] gap-7">
                <jsp:include page="sidebar.jsp">
                    <jsp:param name="menu" value="orders" />
                </jsp:include>

                <section class="min-w-0 space-y-5">
                    <c:if test="${reviewStatus == 'success'}">
                        <div class="rounded-2xl border border-green-200 bg-green-50 px-5 py-4 text-green-700 font-semibold">
                            Đánh giá đã được gửi thành công.
                        </div>
                    </c:if>
                    <c:if test="${reviewStatus == 'exists'}">
                        <div class="rounded-2xl border border-amber-200 bg-amber-50 px-5 py-4 text-amber-700 font-semibold">
                            Đơn này đã được đánh giá hoặc dữ liệu không hợp lệ.
                        </div>
                    </c:if>
                    <c:if test="${reviewStatus == 'invalid'}">
                        <div class="rounded-2xl border border-red-200 bg-red-50 px-5 py-4 text-red-700 font-semibold">
                            Không thể gửi đánh giá cho đơn này.
                        </div>
                    </c:if>

                    <c:choose>
                        <c:when test="${empty orders}">
                            <div class="bg-white border border-gray-200 rounded-[32px] p-10 text-center shadow-[0_10px_30px_rgba(15,23,42,.06)]">
                                <div class="w-20 h-20 mx-auto rounded-full bg-orange-100 text-orange-500 flex items-center justify-center text-3xl">
                                    <i class="fa-solid fa-bag-shopping"></i>
                                </div>
                                <h2 class="mt-5 text-2xl font-black">Bạn chưa có đơn hàng nào</h2>
                                <p class="mt-2 text-gray-500">Hãy khám phá cửa hàng và đặt món đầu tiên của bạn.</p>
                                <a href="${pageContext.request.contextPath}/store"
                                class="inline-flex mt-6 h-12 px-6 items-center justify-center rounded-full bg-orange-500 text-white font-extrabold hover:bg-orange-600 transition">
                                Đi tới cửa hàng
                            </a>
                        </div>
                    </c:when>

                    <c:otherwise>
                        <c:forEach var="o" items="${orders}">
                            <div class="bg-white border border-gray-200 rounded-[28px] p-6 shadow-[0_10px_30px_rgba(15,23,42,.06)]">
                                <div class="flex flex-col lg:flex-row lg:items-start lg:justify-between gap-5">
                                    <div class="min-w-0">
                                        <div class="flex items-center flex-wrap gap-3">
                                            <h3 class="text-xl font-black text-gray-900 break-all">
                                                Đơn #<c:out value="${empty o.orderCode ? o.id : o.orderCode}" />
                                            </h3>

                                            <span class="inline-flex items-center px-3 py-1 rounded-full text-xs font-extrabold
                                            ${o.orderStatus == 'DELIVERED' ? 'bg-green-100 text-green-700' :
                                            o.orderStatus == 'CANCELLED' ? 'bg-red-100 text-red-600' :
                                            'bg-orange-100 text-orange-600'}">
                                            <c:out value="${empty o.orderStatus ? 'PENDING' : o.orderStatus}" />
                                        </span>
                                    </div>

                                    <div class="mt-3 grid grid-cols-1 md:grid-cols-2 gap-3 text-sm text-gray-600">
                                        <div>
                                            <span class="font-bold text-gray-800">Người nhận:</span>
                                            <c:out value="${empty o.receiverName ? 'Chưa có' : o.receiverName}" />
                                        </div>
                                        <div>
                                            <span class="font-bold text-gray-800">SĐT nhận:</span>
                                            <c:out value="${empty o.receiverPhone ? 'Chưa có' : o.receiverPhone}" />
                                        </div>
                                        <div>
                                            <span class="font-bold text-gray-800">Thanh toán:</span>
                                            <c:out value="${empty o.paymentMethod ? 'Chưa có' : o.paymentMethod}" />
                                        </div>
                                        <div>
                                            <span class="font-bold text-gray-800">Trạng thái TT:</span>
                                            <c:out value="${empty o.paymentStatus ? 'Chưa có' : o.paymentStatus}" />
                                        </div>
                                    </div>

                                    <div class="mt-3 text-sm text-gray-600 leading-6">
                                        <span class="font-bold text-gray-800">Địa chỉ giao:</span>
                                        <c:out value="${empty o.deliveryAddressLine ? 'Chưa có địa chỉ' : o.deliveryAddressLine}" />
                                        <c:if test="${not empty o.wardName}">, <c:out value="${o.wardName}" /></c:if>
                                            <c:if test="${not empty o.districtName}">, <c:out value="${o.districtName}" /></c:if>
                                                <c:if test="${not empty o.provinceName}">, <c:out value="${o.provinceName}" /></c:if>
                                                </div>

                                                <div class="mt-2 text-sm text-gray-500">
                                                    <span class="font-bold text-gray-800">Ghi chú:</span>
                                                    <c:out value="${empty o.deliveryNote ? 'Không có' : o.deliveryNote}" />
                                                </div>
                                            </div>

                                            <div class="lg:text-right shrink-0">
                                                <div class="text-sm text-gray-500">Ngày đặt</div>
                                                <div class="font-bold text-gray-900">
                                                    <c:choose>
                                                        <c:when test="${not empty o.createdAt}">
                                                            <fmt:formatDate value="${o.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                                        </c:when>
                                                        <c:otherwise>Chưa có</c:otherwise>
                                                        </c:choose>
                                                    </div>

                                                    <div class="mt-5 text-sm text-gray-500">Tổng tiền</div>
                                                    <div class="text-2xl font-black text-orange-500">
                                                        <c:choose>
                                                            <c:when test="${not empty o.totalAmount}">
                                                                <fmt:formatNumber value="${o.totalAmount}" type="number" groupingUsed="true"/>đ
                                                                </c:when>
                                                                <c:otherwise>0đ</c:otherwise>
                                                                </c:choose>
                                                            </div>

                                                            <a href="${pageContext.request.contextPath}/customer/order-tracking?orderId=${o.id}"
                                                            class="mt-4 inline-flex h-10 px-4 items-center justify-center rounded-lg bg-gray-900 text-white text-sm font-bold hover:bg-black transition">
                                                            Theo dõi đơn
                                                        </a>

                                                        <button type="button"
                                                        onclick="openOrderDetailModal('${o.id}')"
                                                        class="mt-3 inline-flex h-10 px-4 items-center justify-center rounded-lg border border-gray-300 bg-white text-sm font-bold text-gray-700 hover:bg-gray-50 transition">
                                                        Xem chi tiết đơn
                                                    </button>

                                                    <div id="order-detail-template-${o.id}" class="hidden">
                                                        <div class="flex items-center justify-between gap-3 border-b border-gray-100 pb-3">
                                                            <div class="font-black text-gray-900">Chi tiết đơn hàng</div>
                                                            <div class="text-xs font-semibold text-gray-500">Mã đơn #<c:out value="${empty o.orderCode ? o.id : o.orderCode}" /></div>
                                                        </div>

                                                        <div class="mt-3 space-y-2">
                                                            <c:choose>
                                                                <c:when test="${not empty orderItemsMap[o.id]}">
                                                                    <c:forEach var="it" items="${orderItemsMap[o.id]}">
                                                                        <div class="flex items-start justify-between gap-3 rounded-xl border border-gray-100 bg-gray-50 p-3">
                                                                            <div class="min-w-0">
                                                                                <div class="font-bold text-gray-900 break-words"><c:out value="${it.itemNameSnapshot}" /></div>
                                                                                <div class="text-xs text-gray-500 mt-1">
                                                                                    Số lượng: <span class="font-semibold text-gray-700"><c:out value="${it.quantity}" /></span>
                                                                                    <c:if test="${not empty it.selectedSize}"> | Size: <span class="font-semibold text-gray-700"><c:out value="${it.selectedSize}" /></span></c:if>
                                                                                    </div>
                                                                                    <c:if test="${not empty it.note}">
                                                                                        <div class="mt-1 text-xs text-gray-500">Ghi chú món: <c:out value="${it.note}" /></div>
                                                                                    </c:if>
                                                                                </div>
                                                                                <div class="text-sm font-extrabold text-gray-800 shrink-0">
                                                                                    <fmt:formatNumber value="${it.unitPriceSnapshot * it.quantity}" type="number" groupingUsed="true"/>đ
                                                                                    </div>
                                                                                </div>
                                                                            </c:forEach>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <div class="rounded-xl border border-dashed border-gray-200 bg-gray-50 p-3 text-sm text-gray-500">
                                                                                Chưa có dữ liệu món trong đơn hàng này.
                                                                            </div>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                </div>

                                                                <div class="mt-4 rounded-xl bg-gray-900 text-white p-3 text-sm space-y-1">
                                                                    <div class="flex justify-between"><span>Tạm tính</span><span class="font-bold"><fmt:formatNumber value="${o.subtotalAmount}" type="number" groupingUsed="true"/>đ</span></div>
                                                                    <div class="flex justify-between"><span>Phí giao hàng</span><span class="font-bold"><fmt:formatNumber value="${o.deliveryFee}" type="number" groupingUsed="true"/>đ</span></div>
                                                                    <div class="flex justify-between"><span>Giảm giá</span><span class="font-bold">-<fmt:formatNumber value="${o.discountAmount}" type="number" groupingUsed="true"/>đ</span></div>
                                                                    <div class="border-t border-white/20 pt-1 mt-1 flex justify-between text-base"><span class="font-semibold">Tổng cộng</span><span class="font-black text-orange-300"><fmt:formatNumber value="${o.totalAmount}" type="number" groupingUsed="true"/>đ</span></div>
                                                                </div>
                                                            </div>

                                                            <c:if test="${o.orderStatus == 'DELIVERED'}">
                                                                <c:set var="merchantRated" value="${merchantRatedMap[o.id] == true}" />
                                                                <c:set var="shipperRated" value="${shipperRatedMap[o.id] == true}" />
                                                                <c:set var="shipperRequired" value="${o.shipperUserId > 0}" />
                                                                <c:set var="fullyRated" value="${merchantRated and ((not shipperRequired) or shipperRated)}" />
                                                                <c:set var="partiallyRated" value="${not fullyRated and (merchantRated or shipperRated)}" />

                                                                <div class="mt-3 flex justify-end">
                                                                    <span class="inline-flex items-center px-3 py-1 rounded-full text-[11px] font-extrabold ${fullyRated ? 'bg-green-100 text-green-700' : partiallyRated ? 'bg-amber-100 text-amber-700' : 'bg-slate-100 text-slate-600'}">
                                                                        ${fullyRated ? 'Đã đánh giá đầy đủ' : partiallyRated ? 'Đã đánh giá một phần' : 'Chưa đánh giá'}
                                                                    </span>
                                                                </div>

                                                                <button type="button"
                                                                data-toggle-target="review"
                                                                onclick="toggleReviewForm('${o.id}')"
                                                                class="mt-3 inline-flex h-10 px-4 items-center justify-center rounded-lg text-sm font-bold transition ${fullyRated ? 'bg-green-100 text-green-700' : 'bg-orange-500 text-white hover:bg-orange-600'}">
                                                                ${fullyRated ? 'Đã đánh giá' : 'Đánh giá đơn'}
                                                            </button>

                                                            <c:if test="${not fullyRated}">
                                                                <form id="review-form-${o.id}" method="post" action="${pageContext.request.contextPath}/customer/orders"
                                                                class="hidden review-form mt-4 space-y-5 rounded-3xl border border-orange-200 bg-gradient-to-br from-orange-50 via-white to-amber-50 p-5 text-left shadow-[0_12px_30px_rgba(249,115,22,.10)]">
                                                                <input type="hidden" name="orderId" value="${o.id}" />

                                                                <c:if test="${not merchantRated}">
                                                                    <div class="rounded-2xl border border-white bg-white/90 p-4">
                                                                        <div class="flex items-center gap-2 mb-3">
                                                                            <div class="h-8 w-8 rounded-full bg-orange-100 text-orange-500 flex items-center justify-center"><i class="fa-solid fa-store"></i></div>
                                                                            <label class="text-sm font-black text-gray-800">Đánh giá cửa hàng</label>
                                                                        </div>
                                                                        <input type="hidden" name="merchantStars" />
                                                                        <div class="rating-stars flex flex-wrap gap-2" data-target="merchantStars">
                                                                            <button type="button" class="rating-star-btn h-9 w-9 rounded-lg border border-gray-300 bg-white text-sm font-extrabold text-gray-600" data-value="1">1</button>
                                                                            <button type="button" class="rating-star-btn h-9 w-9 rounded-lg border border-gray-300 bg-white text-sm font-extrabold text-gray-600" data-value="2">2</button>
                                                                            <button type="button" class="rating-star-btn h-9 w-9 rounded-lg border border-gray-300 bg-white text-sm font-extrabold text-gray-600" data-value="3">3</button>
                                                                            <button type="button" class="rating-star-btn h-9 w-9 rounded-lg border border-gray-300 bg-white text-sm font-extrabold text-gray-600" data-value="4">4</button>
                                                                            <button type="button" class="rating-star-btn h-9 w-9 rounded-lg border border-gray-300 bg-white text-sm font-extrabold text-gray-600" data-value="5">5</button>
                                                                        </div>
                                                                        <div class="mt-2 text-xs text-gray-500">Chọn mức sao để phản hồi trải nghiệm với cửa hàng.</div>
                                                                        <textarea name="merchantComment" rows="2" maxlength="1000"
                                                                        class="mt-3 w-full rounded-xl border border-gray-300 p-3 text-sm focus:outline-none focus:ring-2 focus:ring-orange-200"
                                                                        placeholder="Nhận xét về cửa hàng (không bắt buộc)"></textarea>
                                                                    </div>
                                                                </c:if>

                                                                <c:if test="${merchantRated}">
                                                                    <div class="rounded-xl border border-green-200 bg-green-50 p-3 text-sm font-semibold text-green-700">Bạn đã đánh giá cửa hàng cho đơn này.</div>
                                                                </c:if>

                                                                <c:if test="${shipperRequired and not shipperRated}">
                                                                    <div class="rounded-2xl border border-white bg-white/90 p-4">
                                                                        <div class="flex items-center gap-2 mb-3">
                                                                            <div class="h-8 w-8 rounded-full bg-sky-100 text-sky-600 flex items-center justify-center"><i class="fa-solid fa-motorcycle"></i></div>
                                                                            <label class="text-sm font-black text-gray-800">Đánh giá shipper</label>
                                                                        </div>
                                                                        <input type="hidden" name="shipperStars" />
                                                                        <div class="rating-stars flex flex-wrap gap-2" data-target="shipperStars">
                                                                            <button type="button" class="rating-star-btn h-9 w-9 rounded-lg border border-gray-300 bg-white text-sm font-extrabold text-gray-600" data-value="1">1</button>
                                                                            <button type="button" class="rating-star-btn h-9 w-9 rounded-lg border border-gray-300 bg-white text-sm font-extrabold text-gray-600" data-value="2">2</button>
                                                                            <button type="button" class="rating-star-btn h-9 w-9 rounded-lg border border-gray-300 bg-white text-sm font-extrabold text-gray-600" data-value="3">3</button>
                                                                            <button type="button" class="rating-star-btn h-9 w-9 rounded-lg border border-gray-300 bg-white text-sm font-extrabold text-gray-600" data-value="4">4</button>
                                                                            <button type="button" class="rating-star-btn h-9 w-9 rounded-lg border border-gray-300 bg-white text-sm font-extrabold text-gray-600" data-value="5">5</button>
                                                                        </div>
                                                                        <div class="mt-2 text-xs text-gray-500">Đánh giá tốc độ giao hàng và thái độ phục vụ.</div>
                                                                        <textarea name="shipperComment" rows="2" maxlength="1000"
                                                                        class="mt-3 w-full rounded-xl border border-gray-300 p-3 text-sm focus:outline-none focus:ring-2 focus:ring-orange-200"
                                                                        placeholder="Nhận xét về shipper (không bắt buộc)"></textarea>
                                                                    </div>
                                                                </c:if>

                                                                <c:if test="${shipperRequired and shipperRated}">
                                                                    <div class="rounded-xl border border-green-200 bg-green-50 p-3 text-sm font-semibold text-green-700">Bạn đã đánh giá shipper cho đơn này.</div>
                                                                </c:if>

                                                                <div class="flex items-center justify-between gap-3 pt-1">
                                                                    <div class="text-xs text-gray-500">Phản hồi của bạn giúp cải thiện chất lượng dịch vụ.</div>
                                                                    <button type="submit"
                                                                    class="inline-flex h-10 px-5 items-center justify-center rounded-xl bg-gray-900 text-white text-sm font-bold hover:bg-black transition">
                                                                    Gửi đánh giá
                                                                </button>
                                                            </div>
                                                        </form>
                                                    </c:if>
                                                </c:if>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </section>
                </div>
            </main>

            <div id="orderDetailModal" class="fixed inset-0 z-[70] hidden">
                <div class="absolute inset-0 bg-black/45" onclick="closeOrderDetailModal()"></div>
                <div class="relative z-[71] min-h-full flex items-center justify-center p-4">
                    <div class="w-full max-w-2xl rounded-3xl border border-gray-200 bg-white shadow-2xl overflow-hidden">
                        <div class="flex items-center justify-between gap-3 px-5 py-4 border-b border-gray-100">
                            <h3 class="text-lg font-black text-gray-900">Chi tiết đơn hàng</h3>
                            <button type="button"
                            onclick="closeOrderDetailModal()"
                            class="inline-flex h-9 w-9 items-center justify-center rounded-full border border-gray-200 text-gray-500 hover:text-gray-700 hover:bg-gray-50 transition"
                            aria-label="Đóng">
                            <i class="fa-solid fa-xmark"></i>
                        </button>
                    </div>
                    <div id="orderDetailModalBody" class="max-h-[70vh] overflow-y-auto px-5 py-4"></div>
                </div>
            </div>
        </div>

        <script>
            const focusedOrderId = '${param.focusOrderId}';
            
            function toggleReviewForm(orderId) {
                const form = document.getElementById('review-form-' + orderId);
                if (!form) {
                    return;
                }
                
                const shouldOpen = form.classList.contains('hidden');
                closeAllReviewForms();
                if (shouldOpen) {
                    form.classList.remove('hidden');
                }
            }
            
            function closeAllReviewForms() {
                const forms = document.querySelectorAll('.review-form');
                forms.forEach((form) => form.classList.add('hidden'));
            }
            
            function openOrderDetailModal(orderId) {
                const template = document.getElementById('order-detail-template-' + orderId);
                const modal = document.getElementById('orderDetailModal');
                const modalBody = document.getElementById('orderDetailModalBody');
                if (!template || !modal || !modalBody) {
                    return;
                }
                
                modalBody.innerHTML = template.innerHTML;
                modal.classList.remove('hidden');
                document.body.classList.add('overflow-hidden');
            }
            
            function closeOrderDetailModal() {
                const modal = document.getElementById('orderDetailModal');
                const modalBody = document.getElementById('orderDetailModalBody');
                if (!modal || !modalBody) {
                    return;
                }
                
                modal.classList.add('hidden');
                modalBody.innerHTML = '';
                document.body.classList.remove('overflow-hidden');
            }
            
            function setupRatingStars() {
                const groups = document.querySelectorAll('.rating-stars');
                groups.forEach((group) => {
                    const target = group.dataset.target;
                    const hiddenInput = group.closest('form')?.querySelector('input[name="' + target + '"]');
                    const buttons = group.querySelectorAll('.rating-star-btn');
                    buttons.forEach((button) => {
                        button.addEventListener('click', () => {
                            const value = button.dataset.value;
                            if (hiddenInput) {
                                hiddenInput.value = value;
                            }
                            buttons.forEach((btn) => {
                                const btnValue = Number(btn.dataset.value || '0');
                                const currentValue = Number(value || '0');
                                btn.classList.toggle('active', btnValue <= currentValue);
                            });
                        });
                    });
                });
            }
            
            function setupReviewValidation() {
                const forms = document.querySelectorAll('.review-form');
                forms.forEach((form) => {
                    form.addEventListener('submit', (event) => {
                        const merchantInput = form.querySelector('input[name="merchantStars"]');
                        const shipperInput = form.querySelector('input[name="shipperStars"]');
                        if (merchantInput && !merchantInput.value) {
                            event.preventDefault();
                            alert('Vui lòng chọn số sao cho cửa hàng trước khi gửi.');
                            return;
                        }
                        if (shipperInput && !shipperInput.value) {
                            event.preventDefault();
                            alert('Vui lòng chọn số sao cho shipper trước khi gửi.');
                        }
                    });
                });
            }
            
            function setupOrderDetailAutoOpen() {
                if (!focusedOrderId) {
                    return;
                }
                const id = String(focusedOrderId).trim();
                if (!id) {
                    return;
                }
                const template = document.getElementById('order-detail-template-' + id);
                if (!template) {
                    return;
                }
                openOrderDetailModal(id);
            }
            
            document.addEventListener('keydown', (event) => {
                if (event.key === 'Escape') {
                    closeOrderDetailModal();
                }
            });
            
            setupRatingStars();
            setupReviewValidation();
            setupOrderDetailAutoOpen();
        </script>
    </body>
</html>