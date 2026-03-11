<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<% request.setAttribute("currentPage", "orders"); %>
<!DOCTYPE html>
<html lang="vi" class="h-full">
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Đơn hàng – ClickEat Merchant</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
        <script>
            tailwind.config = {
                theme: {
                    extend: {
                        fontFamily: {sans: ['Inter', 'sans-serif']},
                        colors: {primary: '#c86601', 'primary-dark': '#a05201'}
                    }
                }
            }
        </script>
        <style>
            .tab-active { background: #c86601; color: white; }
        </style>
    </head>
    <body class="h-full bg-[#f8f7f5] font-sans">
        <div class="flex h-full">
            <%@ include file="_nav.jsp" %>

            <main class="flex-1 overflow-y-auto pb-20 md:pb-0">
                <!-- Header -->
                <div class="sticky top-0 bg-white/90 backdrop-blur-sm border-b border-gray-100 px-6 py-4 z-10 flex items-center justify-between gap-4">
                    <div class="flex items-center gap-3 flex-1 min-w-0">
                        <h1 class="font-bold text-gray-900 text-lg whitespace-nowrap">Đơn hàng</h1>
                        <!-- Feature 4: Search -->
                        <div class="flex-1 max-w-xs hidden md:block">
                            <div class="relative">
                                <span class="material-symbols-outlined absolute left-2.5 top-1/2 -translate-y-1/2 text-gray-400 text-[18px]">search</span>
                                <input type="text" id="orderSearch" placeholder="Tìm mã đơn, tên, SĐT..."
                                       class="w-full pl-9 pr-3 py-1.5 text-sm border border-gray-200 rounded-xl focus:outline-none focus:border-primary bg-gray-50"/>
                            </div>
                        </div>
                    </div>
                    <span class="text-xs text-gray-400 whitespace-nowrap" id="refreshTimer">Tự động làm mới sau 30s</span>
                </div>

                <div class="p-4 md:p-6 max-w-7xl mx-auto space-y-5">

                    <!-- Status filter tabs -->
                    <div class="flex gap-2 overflow-x-auto pb-1">
                        <c:forEach var="tab" items="${statusTabs}">
                            <a href="?status=${tab.key}"
                            class="flex items-center gap-1.5 px-3 py-1.5 rounded-full text-sm font-medium whitespace-nowrap border transition-all
                            ${param.status == tab.key || (empty param.status && tab.key == 'ALL')
                            ? 'border-primary bg-primary text-white'
                            : 'border-gray-200 bg-white text-gray-600 hover:border-gray-300'}">
                            ${tab.value}
                            <c:if test="${tab.key == 'CREATED' || tab.key == 'PAID'}">
                                <c:if test="${newOrderCount > 0}">
                                    <span class="bg-white text-primary text-[10px] font-bold px-1.5 rounded-full">${newOrderCount}</span>
                                </c:if>
                            </c:if>
                        </a>
                    </c:forEach>
                </div>

                <!-- Order cards -->
                <c:if test="${empty orders}">
                    <div class="bg-white rounded-2xl border border-gray-200 p-16 text-center">
                        <span class="material-symbols-outlined text-5xl text-gray-200">receipt_long</span>
                        <p class="text-gray-400 mt-3 font-medium">Không có đơn hàng nào</p>
                    </div>
                </c:if>

                <div class="space-y-4">
                    <c:forEach var="order" items="${orders}">
                        <div class="bg-white rounded-2xl border border-gray-200 overflow-hidden order-search-card"
                             data-created-ms="${order.createdAt.time}"
                             data-order-status="${order.orderStatus}"
                             data-search-text="${fn:toLowerCase(order.orderCode)} ${fn:toLowerCase(order.receiverName)} ${order.receiverPhone}">
                        <!-- Order header -->
                        <div class="flex items-center justify-between px-5 py-4 border-b border-gray-100">
                            <div class="flex items-center gap-3">
                                <div>
                                    <p class="font-bold text-gray-900 flex items-center gap-2">
                                        #${order.orderCode}
                                        <span class="order-timer hidden text-[11px] font-bold px-2 py-0.5 rounded-full"></span>
                                    </p>
                                    <p class="text-xs text-gray-400">
                                        <fmt:formatDate value="${order.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                    </p>
                                </div>
                            </div>
                            <span class="text-xs px-3 py-1 rounded-full font-semibold
                            ${order.orderStatus == 'CREATED' || order.orderStatus == 'PAID' ? 'bg-blue-100 text-blue-700' :
                            order.orderStatus == 'MERCHANT_ACCEPTED' || order.orderStatus == 'PREPARING' ? 'bg-yellow-100 text-yellow-700' :
                            order.orderStatus == 'READY_FOR_PICKUP' ? 'bg-green-100 text-green-700' :
                            order.orderStatus == 'DELIVERING' ? 'bg-purple-100 text-purple-700' :
                            order.orderStatus == 'DELIVERED' ? 'bg-gray-100 text-gray-700' :
                            'bg-red-100 text-red-700'}">
                            <c:choose>
                                <c:when test="${order.orderStatus == 'CREATED' || order.orderStatus == 'PAID'}">🔵 Mới</c:when>
                                    <c:when test="${order.orderStatus == 'MERCHANT_ACCEPTED'}">🟡 Đã nhận</c:when>
                                        <c:when test="${order.orderStatus == 'PREPARING'}">🟡 Đang nấu</c:when>
                                            <c:when test="${order.orderStatus == 'READY_FOR_PICKUP'}">🟢 Sẵn sàng</c:when>
                                                <c:when test="${order.orderStatus == 'DELIVERING'}">🟣 Đang giao</c:when>
                                                    <c:when test="${order.orderStatus == 'DELIVERED'}">✅ Hoàn tất</c:when>
                                                        <c:when test="${order.orderStatus == 'CANCELLED'}">❌ Đã hủy</c:when>
                                                        <c:when test="${order.orderStatus == 'MERCHANT_REJECTED'}">🚫 Đã từ chối</c:when>
                                                            <c:otherwise>${order.orderStatus}</c:otherwise>
                                                            </c:choose>
                                                        </span>
                                                    </div>

                                                    <!-- Customer + address -->
                                                    <div class="px-5 py-3 bg-gray-50 flex flex-col md:flex-row md:items-center gap-2 md:gap-6 text-sm">
                                                        <div class="flex items-center gap-2 text-gray-700">
                                                            <span class="material-symbols-outlined text-base text-gray-400">person</span>
                                                            <span>${order.receiverName} · ${order.receiverPhone}</span>
                                                        </div>
                                                        <div class="flex items-center gap-2 text-gray-500">
                                                            <span class="material-symbols-outlined text-base text-gray-400">location_on</span>
                                                            <span class="truncate max-w-xs">${order.deliveryAddressLine}</span>
                                                        </div>
                                                    </div>

                                                    <!-- Total + actions -->
                                                    <div class="flex flex-wrap items-center justify-between gap-3 px-5 py-4">
                                                        <div>
                                                            <p class="text-xs text-gray-400">Tổng tiền</p>
                                                            <p class="font-bold text-gray-900">
                                                                <fmt:formatNumber value="${order.totalAmount}" type="number" groupingUsed="true"/>đ
                                                                </p>
                                                            </div>

                                                            <!-- Action buttons based on status -->
                                                            <div class="flex items-center gap-2">
                                                                <a href="${pageContext.request.contextPath}/merchant/orders/detail?id=${order.id}"
                                                                class="flex items-center gap-1 px-3 py-2 border border-gray-200 text-gray-700 text-sm font-semibold rounded-xl hover:border-primary hover:text-primary transition-all">
                                                                <span class="material-symbols-outlined text-base">visibility</span>
                                                                Chi tiết
                                                            </a>
                                                            <c:choose>
                                                                <c:when test="${order.orderStatus == 'CREATED' || order.orderStatus == 'PAID'}">
                                                                    <!-- Feature 5: prep time modal -->
                                                                    <button type="button"
                                                                            onclick="openPrepModal('${order.id}')"
                                                                            class="flex items-center gap-1.5 px-4 py-2 bg-primary text-white text-sm font-semibold rounded-xl hover:bg-primary-dark transition-all">
                                                                        <span class="material-symbols-outlined text-base">check</span>
                                                                        Nhận đơn
                                                                    </button>
                                                                    <!-- Feature 3: cancel reason modal -->
                                                                    <button type="button"
                                                                            onclick="openCancelModal('${order.id}', '${order.orderCode}')"
                                                                            class="flex items-center gap-1.5 px-4 py-2 border border-gray-200 text-gray-600 text-sm font-semibold rounded-xl hover:bg-red-50 hover:text-red-600 hover:border-red-200 transition-all">
                                                                        <span class="material-symbols-outlined text-base">close</span>
                                                                        Từ chối
                                                                    </button>
                                                        </c:when>
                                                        <c:when test="${order.orderStatus == 'MERCHANT_ACCEPTED' || order.orderStatus == 'PREPARING'}">
                                                            <form method="POST" action="${pageContext.request.contextPath}/merchant/orders">
                                                                <input type="hidden" name="orderId" value="${order.id}"/>
                                                                <input type="hidden" name="action" value="ready"/>
                                                                <button type="submit"
                                                                class="flex items-center gap-1.5 px-4 py-2 bg-green-600 text-white text-sm font-semibold rounded-xl hover:bg-green-700 transition-all">
                                                                <span class="material-symbols-outlined text-base">done_all</span>
                                                                Sẵn sàng
                                                            </button>
                                                        </form>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-xs text-gray-400 italic">
                                                            <c:if test="${order.orderStatus == 'DELIVERED'}">
                                                                Đã giao <fmt:formatDate value="${order.deliveredAt}" pattern="HH:mm"/>
                                                            </c:if>
                                                        </span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>

                            <!-- Pagination -->
                            <c:if test="${totalPages > 1}">
                                <div class="flex justify-center items-center gap-2 py-6">
                                    <c:if test="${currentPageNum > 1}">
                                        <a href="?status=${param.status}&page=${currentPageNum - 1}"
                                           class="px-3 py-2 text-sm font-medium text-gray-600 border border-gray-200 rounded-xl hover:border-primary hover:text-primary transition-all">
                                            ←
                                        </a>
                                    </c:if>
                                    <c:forEach var="p" begin="1" end="${totalPages}">
                                        <a href="?status=${param.status}&page=${p}"
                                           class="px-3 py-2 text-sm font-medium rounded-xl transition-all
                                           ${p == currentPageNum ? 'bg-primary text-white' : 'border border-gray-200 text-gray-600 hover:border-primary hover:text-primary'}">
                                            ${p}
                                        </a>
                                    </c:forEach>
                                    <c:if test="${currentPageNum < totalPages}">
                                        <a href="?status=${param.status}&page=${currentPageNum + 1}"
                                           class="px-3 py-2 text-sm font-medium text-gray-600 border border-gray-200 rounded-xl hover:border-primary hover:text-primary transition-all">
                                            →
                                        </a>
                                    </c:if>
                                    <span class="text-xs text-gray-400 ml-2">${totalOrders} đơn</span>
                                </div>
                            </c:if>
                        </div>
                    </main>
                </div>

                <!-- ═══ Feature 3: Cancel Reason Modal ═══ -->
                <div id="cancelModal" class="fixed inset-0 z-50 hidden bg-black/40 backdrop-blur-sm flex items-center justify-center p-4">
                    <div class="bg-white rounded-2xl w-full max-w-sm shadow-2xl overflow-hidden">
                        <div class="px-6 py-4 border-b border-gray-100 flex items-center justify-between bg-gray-50">
                            <h3 class="font-bold text-gray-900">Lý do từ chối</h3>
                            <button onclick="closeCancelModal()" class="text-gray-400 hover:text-gray-600 p-1 rounded-lg hover:bg-gray-100">
                                <span class="material-symbols-outlined">close</span>
                            </button>
                        </div>
                        <form id="cancelForm" method="POST" action="${pageContext.request.contextPath}/merchant/orders" class="p-5 space-y-3">
                            <input type="hidden" name="action" value="reject"/>
                            <input type="hidden" name="orderId" id="cancelOrderId"/>
                            <input type="hidden" name="cancelReason" id="cancelReasonInput"/>
                            <p class="text-sm text-gray-500 mb-4">Vui lòng chọn lý do để thông báo cho khách hàng:</p>
                            <div id="cancelReasons" class="space-y-2">
                                <button type="button" onclick="selectReason('Hết nguyên liệu')"
                                        class="reason-btn w-full text-left px-4 py-3 rounded-xl border border-gray-200 hover:border-primary hover:bg-orange-50 text-sm font-medium text-gray-700 transition-all">
                                    🥡 Hết nguyên liệu
                                </button>
                                <button type="button" onclick="selectReason('Bếp quá bận, không thể nhận thêm')"
                                        class="reason-btn w-full text-left px-4 py-3 rounded-xl border border-gray-200 hover:border-primary hover:bg-orange-50 text-sm font-medium text-gray-700 transition-all">
                                    🔥 Bếp quá bận
                                </button>
                                <button type="button" onclick="selectReason('Cửa hàng đóng cửa sớm')"
                                        class="reason-btn w-full text-left px-4 py-3 rounded-xl border border-gray-200 hover:border-primary hover:bg-orange-50 text-sm font-medium text-gray-700 transition-all">
                                    🔒 Cửa hàng đóng cửa sớm
                                </button>
                                <button type="button" onclick="selectReason('Không giao được khu vực này')"
                                        class="reason-btn w-full text-left px-4 py-3 rounded-xl border border-gray-200 hover:border-primary hover:bg-orange-50 text-sm font-medium text-gray-700 transition-all">
                                    📍 Ngoài khu vực giao hàng
                                </button>
                            </div>
                        </form>
                    </div>
                </div>

                <!-- ═══ Feature 5: Prep Time Modal ═══ -->
                <div id="prepModal" class="fixed inset-0 z-50 hidden bg-black/40 backdrop-blur-sm flex items-center justify-center p-4">
                    <div class="bg-white rounded-2xl w-full max-w-sm shadow-2xl overflow-hidden">
                        <div class="px-6 py-4 border-b border-gray-100 flex items-center justify-between bg-gray-50">
                            <h3 class="font-bold text-gray-900">Thời gian chuẩn bị</h3>
                            <button onclick="closePrepModal()" class="text-gray-400 hover:text-gray-600 p-1 rounded-lg hover:bg-gray-100">
                                <span class="material-symbols-outlined">close</span>
                            </button>
                        </div>
                        <form id="prepForm" method="POST" action="${pageContext.request.contextPath}/merchant/orders" class="p-5">
                            <input type="hidden" name="action" value="accept"/>
                            <input type="hidden" name="orderId" id="prepOrderId"/>
                            <input type="hidden" name="prepMinutes" id="prepMinutesInput" value="20"/>
                            <p class="text-sm text-gray-500 mb-4">Món sẽ sẵn sàng sau bao lâu?</p>
                            <div class="grid grid-cols-3 gap-2 mb-5">
                                <button type="button" onclick="selectPrep(10)" class="prep-btn px-3 py-3 rounded-xl border-2 border-gray-200 hover:border-primary text-sm font-bold text-gray-700 transition-all">10 phút</button>
                                <button type="button" onclick="selectPrep(15)" class="prep-btn px-3 py-3 rounded-xl border-2 border-gray-200 hover:border-primary text-sm font-bold text-gray-700 transition-all">15 phút</button>
                                <button type="button" onclick="selectPrep(20)" class="prep-btn px-3 py-3 rounded-xl border-2 border-primary bg-orange-50 text-sm font-bold text-primary transition-all">20 phút</button>
                                <button type="button" onclick="selectPrep(30)" class="prep-btn px-3 py-3 rounded-xl border-2 border-gray-200 hover:border-primary text-sm font-bold text-gray-700 transition-all">30 phút</button>
                                <button type="button" onclick="selectPrep(45)" class="prep-btn px-3 py-3 rounded-xl border-2 border-gray-200 hover:border-primary text-sm font-bold text-gray-700 transition-all">45 phút</button>
                                <button type="button" onclick="selectPrep(60)" class="prep-btn px-3 py-3 rounded-xl border-2 border-gray-200 hover:border-primary text-sm font-bold text-gray-700 transition-all">60 phút</button>
                            </div>
                            <button type="submit" class="w-full py-3 bg-primary text-white font-bold rounded-xl hover:bg-primary-dark transition-all flex items-center justify-center gap-2">
                                <span class="material-symbols-outlined text-base">skillet</span>
                                Xác nhận &amp; Nhận đơn
                            </button>
                        </form>
                    </div>
                </div>

                <!-- Order Detail Modal -->
                <div id="detailModal" class="fixed inset-0 z-50 hidden bg-black/40 backdrop-blur-sm flex items-center justify-center p-4">
                    <div class="bg-white rounded-2xl w-full max-w-md overflow-hidden shadow-2xl flex flex-col max-h-[90vh]">
                        <!-- Modal Header -->
                        <div class="px-6 py-4 border-b border-gray-100 flex items-center justify-between bg-gray-50/60">
                            <div>
                                <h3 class="font-bold text-lg text-gray-900">Chi tiết đơn hàng</h3>
                                <p class="text-sm font-semibold text-primary mt-0.5" id="detailTitle">#</p>
                            </div>
                            <button type="button" onclick="closeDetail()" class="text-gray-400 hover:text-gray-600 transition-colors p-1.5 rounded-xl hover:bg-gray-100">
                                <span class="material-symbols-outlined">close</span>
                            </button>
                        </div>

                        <!-- Modal Body -->
                        <div class="p-6 overflow-y-auto flex-1 custom-scrollbar">
                            <div id="detailSpinner" class="hidden flex justify-center py-8">
                                <span class="material-symbols-outlined animate-spin text-4xl text-primary">progress_activity</span>
                            </div>
                            <div id="detailItems" class="space-y-3"></div>
                        </div>

                        <!-- Modal Footer -->
                        <div class="px-6 py-4 border-t border-gray-100 bg-gray-50 flex items-center justify-between">
                            <span class="text-gray-600 font-medium">Tổng cộng</span>
                            <span class="text-lg font-bold text-primary" id="detailTotal">0đ</span>
                        </div>
                    </div>
                </div>

                <script>
                    // ── Feature 4: Search/filter order cards ───────────────
                    const orderSearch = document.getElementById('orderSearch');
                    const orderCards  = document.querySelectorAll('.order-search-card');
                    if (orderSearch) {
                        orderSearch.addEventListener('input', function() {
                            const q = this.value.trim().toLowerCase();
                            orderCards.forEach(card => {
                                card.style.display = q === '' || card.dataset.searchText.includes(q) ? '' : 'none';
                            });
                        });
                    }

                    // ── Feature 3: Cancel reason modal ─────────────────────
                    const cancelModal = document.getElementById('cancelModal');
                    function openCancelModal(orderId, code) {
                        document.getElementById('cancelOrderId').value = orderId;
                        document.querySelectorAll('.reason-btn').forEach(b => b.classList.remove('border-primary','bg-orange-50','text-primary'));
                        document.getElementById('cancelReasonInput').value = '';
                        cancelModal.classList.remove('hidden');
                    }
                    function closeCancelModal() { cancelModal.classList.add('hidden'); }
                    function selectReason(reason) {
                        document.getElementById('cancelReasonInput').value = reason;
                        document.querySelectorAll('.reason-btn').forEach(b => {
                            const active = b.textContent.trim().includes(reason.substring(2,10));
                            b.classList.toggle('border-primary', active);
                            b.classList.toggle('bg-orange-50', active);
                            b.classList.toggle('text-primary', active);
                        });
                        // Small delay then auto submit
                        setTimeout(() => {
                            if (document.getElementById('cancelReasonInput').value) {
                                document.getElementById('cancelForm').submit();
                            }
                        }, 300);
                    }
                    cancelModal && cancelModal.addEventListener('click', e => { if (e.target === cancelModal) closeCancelModal(); });

                    // ── Feature 5: Prep time modal ──────────────────────────
                    const prepModal = document.getElementById('prepModal');
                    function openPrepModal(orderId) {
                        document.getElementById('prepOrderId').value = orderId;
                        prepModal.classList.remove('hidden');
                    }
                    function closePrepModal() { prepModal.classList.add('hidden'); }
                    function selectPrep(mins) {
                        document.getElementById('prepMinutesInput').value = mins;
                        document.querySelectorAll('.prep-btn').forEach(b => {
                            const active = b.textContent.includes(mins + ' phút');
                            b.classList.toggle('border-primary', active);
                            b.classList.toggle('bg-orange-50', active);
                            b.classList.toggle('text-primary', active);
                            b.classList.toggle('border-gray-200', !active);
                            b.classList.toggle('text-gray-700', !active);
                        });
                    }
                    prepModal && prepModal.addEventListener('click', e => { if (e.target === prepModal) closePrepModal(); });
                </script>
                <script>
                    const detailTitle = document.getElementById('detailTitle');
                    const detailItems = document.getElementById('detailItems');
                    const detailTotal = document.getElementById('detailTotal');
                    const detailSpinner = document.getElementById('detailSpinner');
                    const detailButtons = document.querySelectorAll('.detail-trigger');
                    const detailUrlBase = '${pageContext.request.contextPath}/merchant/orders?action=detail&id=';
                    
                    function showDetail(orderId, orderCode) {
                        if (!detailModal) return;
                        detailTitle.textContent = '#' + orderCode;
                        detailItems.innerHTML = '';
                        detailTotal.textContent = '0đ';
                        detailSpinner.classList.remove('hidden');
                        
                        // Show modal
                        detailModal.classList.remove('hidden');
                        
                        fetch(detailUrlBase + encodeURIComponent(orderId))
                        .then(res => res.json())
                        .then(data => {
                            const itemsList = Array.isArray(data) ? data : (data.items || []);
                            if (itemsList && itemsList.length) {
                                let total = 0;
                                let inner = '';
                                itemsList.forEach(it => {
                                    const name = it.name || it.itemName || 'Món ăn';
                                    const qty = it.qty || it.quantity || 1;
                                    const price = it.price || it.unit_price_snapshot || 0;
                                    const sub = price * qty;
                                    const notesHtml = it.notes
                                    ? '<p class="text-red-500 text-xs italic mt-0.5">Note: ' + it.notes + '</p>'
                                    : '';
                                    total += sub;
                                    inner += ''
                                    + '<div class="flex items-start justify-between text-sm border-b border-gray-100 pb-3 last:border-0 last:pb-0">'
                                    + '  <div class="flex items-start gap-3">'
                                    + '    <span class="w-7 h-7 flex-shrink-0 flex items-center justify-center bg-primary/10 text-primary font-bold text-sm rounded-lg">' + qty + '</span>'
                                    + '    <div>'
                                    + '      <p class="font-semibold text-gray-900 leading-tight">' + name + '</p>'
                                    +        notesHtml
                                    + '      <p class="text-gray-400 text-xs mt-0.5">' + new Intl.NumberFormat('vi-VN').format(price) + 'đ / món</p>'
                                    + '    </div>'
                                    + '  </div>'
                                    + '  <span class="font-semibold text-gray-800 whitespace-nowrap">' + new Intl.NumberFormat('vi-VN').format(sub) + 'đ</span>'
                                    + '</div>';
                                });
                                detailItems.innerHTML = inner;
                                detailTotal.textContent = new Intl.NumberFormat('vi-VN').format(total) + 'đ';
                                } else {
                                    detailItems.innerHTML = '<p class="text-gray-500 italic text-center text-sm py-6">Không có thông tin chi tiết.</p>';
                                }
                            })
                            .catch(() => {
                                detailItems.innerHTML = '<p class="text-red-500 text-center text-sm py-6">Không thể tải chi tiết đơn.</p>';
                            })
                            .finally(() => {
                                detailSpinner.classList.add('hidden');
                            });
                        }
                        
                        function closeDetail() {
                            if (detailModal) {
                                detailModal.classList.add('hidden');
                            }
                        }
                        
                        detailButtons.forEach(button => {
                            button.addEventListener('click', () => {
                                showDetail(button.dataset.orderId, button.dataset.orderCode || '');
                            });
                        });
                        
                        if (detailModal) {
                            detailModal.addEventListener('click', e => {
                                if (e.target === detailModal) closeDetail();
                            });
                        }
                        
                        window.closeDetail = closeDetail;
                    </script>

                    <script>
                        // Per-card countdown timer
                        const ACTIVE_STATUSES = ['CREATED','PAID','MERCHANT_ACCEPTED','PREPARING'];
                        function updateOrderTimers() {
                            document.querySelectorAll('[data-created-ms]').forEach(function(card) {
                                const status = card.dataset.orderStatus;
                                if (!ACTIVE_STATUSES.includes(status)) return;
                                const elapsed = Math.floor((Date.now() - parseInt(card.dataset.createdMs)) / 1000);
                                const mins = Math.floor(elapsed / 60);
                                const secs = elapsed % 60;
                                const isLate = elapsed >= 300;
                                const timerEl = card.querySelector('.order-timer');
                                if (!timerEl) return;
                                timerEl.classList.remove('hidden');
                                timerEl.innerHTML = '<span class="material-symbols-outlined" style="font-size:12px;line-height:1;vertical-align:middle">timer</span> ' + String(mins).padStart(2,'0') + ':' + String(secs).padStart(2,'0');
                                timerEl.className = 'order-timer inline-flex items-center gap-0.5 text-[11px] font-bold px-2 py-0.5 rounded-full ' + (isLate ? 'bg-red-100 text-red-600 animate-pulse' : 'bg-gray-100 text-gray-600');
                            });
                        }
                        updateOrderTimers();
                        setInterval(updateOrderTimers, 1000);
                    </script>

                    <script>
                        // ── Feature 2: New order sound + Auto refresh ──────────────
                        // Store new order count from server on each page load
                        const NEW_ORDER_COUNT = ${newOrderCount};
                        const PREV_KEY = 'clickeat_prev_new_orders';
                        const prev = parseInt(localStorage.getItem(PREV_KEY) || '0');
                        if (NEW_ORDER_COUNT > prev) {
                            // Play alert sound via Web Audio API
                            try {
                                const ctx = new (window.AudioContext || window.webkitAudioContext)();
                                function beep(freq, start, dur) {
                                    const o = ctx.createOscillator();
                                    const g = ctx.createGain();
                                    o.connect(g); g.connect(ctx.destination);
                                    o.frequency.value = freq;
                                    g.gain.setValueAtTime(0.3, ctx.currentTime + start);
                                    g.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + start + dur);
                                    o.start(ctx.currentTime + start);
                                    o.stop(ctx.currentTime + start + dur);
                                }
                                beep(880, 0, 0.15); beep(1100, 0.2, 0.15); beep(880, 0.4, 0.15);
                            } catch(e) {}
                            // Flash page title
                            let flash = true;
                            const origTitle = document.title;
                            const flashInterval = setInterval(() => {
                                document.title = flash ? '\uD83D\uDD14 ' + (NEW_ORDER_COUNT) + ' Đơn mới!' : origTitle;
                                flash = !flash;
                            }, 800);
                            setTimeout(() => { clearInterval(flashInterval); document.title = origTitle; }, 10000);
                        }
                        localStorage.setItem(PREV_KEY, NEW_ORDER_COUNT);

                        let countdown = 30;
                        const timerEl = document.getElementById('refreshTimer');
                        setInterval(() => {
                            const anyModalOpen = !document.getElementById('detailModal').classList.contains('hidden')
                                || !document.getElementById('cancelModal').classList.contains('hidden')
                                || !document.getElementById('prepModal').classList.contains('hidden');
                            if (anyModalOpen) return;
                            countdown--;
                            if (countdown <= 0) { location.reload(); return; }
                            timerEl.textContent = 'Tự động làm mới sau ' + countdown + 's';
                        }, 1000);
                    </script>
                </body>
            </html>

