<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<% request.setAttribute("currentPage", "orders");%>
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
            body {
                font-family: 'Inter', sans-serif;
            }
            .material-symbols-outlined {
                font-variation-settings: 'FILL' 1, 'wght' 400, 'GRAD' 0, 'opsz' 24;
            }
        </style>
    </head>
    <body class="h-full bg-[#f8f7f5] text-gray-800 flex overflow-hidden">

        <jsp:include page="_nav.jsp" />

        <main class="flex-1 flex flex-col h-screen overflow-hidden relative">

            <header class="bg-white border-b border-gray-100 px-8 py-5 sticky top-0 z-20 flex justify-between items-center shadow-sm">
                <div>
                    <h1 class="text-2xl font-black text-gray-900 tracking-tight">Đơn hàng</h1>
                    <p class="text-sm text-gray-500 font-medium mt-1">Quản lý và xử lý đơn hàng theo thời gian thực</p>
                </div>
                <div class="flex items-center gap-4">
                    <span id="refreshTimer" class="text-sm font-bold text-gray-400 bg-gray-50 px-3 py-1.5 rounded-lg border border-gray-200">
                        Tự động làm mới sau 30s
                    </span>
                    <button onclick="location.reload()" class="w-10 h-10 bg-orange-50 text-primary hover:bg-primary hover:text-white rounded-xl flex items-center justify-center transition-colors shadow-sm">
                        <span class="material-symbols-outlined text-[22px]">refresh</span>
                    </button>
                </div>
            </header>

            <div class="bg-white border-b border-gray-100 px-8 pt-4 sticky top-[81px] z-10">
                <div class="flex gap-8">
                    <a href="?tab=pending" class="pb-4 text-sm font-bold border-b-2 transition-all ${currentTab == 'pending' || empty currentTab ? 'border-primary text-primary' : 'border-transparent text-gray-500 hover:text-gray-800'}">
                        Mới (Chờ xác nhận)
                        <c:if test="${(currentTab == 'pending' || empty currentTab) && not empty orders}">
                            <span class="bg-red-500 text-white text-[10px] px-2 py-0.5 rounded-full ml-1" id="newOrderCount">${orders.size()}</span>
                        </c:if>
                    </a>
                    <a href="?tab=preparing" class="pb-4 text-sm font-bold border-b-2 transition-all ${currentTab == 'preparing' ? 'border-primary text-primary' : 'border-transparent text-gray-500 hover:text-gray-800'}">
                        Đang chuẩn bị
                    </a>
                    <a href="?tab=ready" class="pb-4 text-sm font-bold border-b-2 transition-all ${currentTab == 'ready' ? 'border-primary text-primary' : 'border-transparent text-gray-500 hover:text-gray-800'}">
                        Chờ giao (Shipper)
                    </a>
                    <a href="?tab=completed" class="pb-4 text-sm font-bold border-b-2 transition-all ${currentTab == 'completed' ? 'border-primary text-primary' : 'border-transparent text-gray-500 hover:text-gray-800'}">
                        Lịch sử (Hoàn tất/Hủy)
                    </a>
                </div>

                <form method="GET" action="${pageContext.request.contextPath}/merchant/orders" class="py-4 flex flex-wrap items-end gap-3">
                    <input type="hidden" name="tab" value="${currentTab}">
                    <div>
                        <label class="block text-[11px] font-bold text-gray-400 uppercase mb-1">Trạng thái</label>
                        <select name="status" class="bg-white border border-gray-200 rounded-lg px-3 py-2 text-sm font-medium text-gray-700">
                            <option value="">Tất cả</option>
                            <option value="PENDING" ${statusFilter == 'PENDING' ? 'selected' : ''}>PENDING</option>
                            <option value="CONFIRMED" ${statusFilter == 'CONFIRMED' ? 'selected' : ''}>CONFIRMED</option>
                            <option value="PREPARING" ${statusFilter == 'PREPARING' ? 'selected' : ''}>PREPARING</option>
                            <option value="READY_FOR_PICKUP" ${statusFilter == 'READY_FOR_PICKUP' ? 'selected' : ''}>READY_FOR_PICKUP</option>
                            <option value="DELIVERING" ${statusFilter == 'DELIVERING' ? 'selected' : ''}>DELIVERING</option>
                            <option value="DELIVERED" ${statusFilter == 'DELIVERED' ? 'selected' : ''}>DELIVERED</option>
                            <option value="CANCELLED" ${statusFilter == 'CANCELLED' ? 'selected' : ''}>CANCELLED</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-[11px] font-bold text-gray-400 uppercase mb-1">Từ</label>
                        <input type="datetime-local" name="from" value="${fromDateTime}" class="bg-white border border-gray-200 rounded-lg px-3 py-2 text-sm font-medium text-gray-700"/>
                    </div>
                    <div>
                        <label class="block text-[11px] font-bold text-gray-400 uppercase mb-1">Đến</label>
                        <input type="datetime-local" name="to" value="${toDateTime}" class="bg-white border border-gray-200 rounded-lg px-3 py-2 text-sm font-medium text-gray-700"/>
                    </div>
                    <button type="submit" class="h-10 px-4 bg-primary text-white rounded-lg text-sm font-bold hover:bg-primary-dark">Lọc</button>
                    <a href="${pageContext.request.contextPath}/merchant/orders?tab=${currentTab}" class="h-10 px-4 border border-gray-200 rounded-lg text-sm font-semibold text-gray-600 hover:bg-gray-50 flex items-center">Xóa lọc</a>
                </form>
            </div>

            <div class="flex-1 overflow-y-auto p-8">
                <div class="max-w-4xl mx-auto space-y-4">

                    <c:if test="${not empty successMsg}">
                        <div class="bg-green-50 text-green-700 border border-green-200 rounded-xl px-4 py-3 text-sm font-semibold">${successMsg}</div>
                    </c:if>
                    <c:if test="${not empty errorMsg}">
                        <div class="bg-red-50 text-red-700 border border-red-200 rounded-xl px-4 py-3 text-sm font-semibold">${errorMsg}</div>
                    </c:if>

                    <c:if test="${empty orders}">
                        <div class="text-center py-20">
                            <div class="w-20 h-20 bg-gray-100 text-gray-400 rounded-full flex items-center justify-center text-4xl mx-auto mb-4">
                                <span class="material-symbols-outlined text-[40px]">inbox</span>
                            </div>
                            <h3 class="text-xl font-bold text-gray-900 mb-1">Chưa có đơn hàng nào</h3>
                            <p class="text-gray-500">Khu vực này hiện đang trống ở tab hiện tại.</p>
                        </div>
                    </c:if>

                    <c:forEach var="o" items="${orders}">
                        <c:set var="normalizedStatus" value="${o.orderStatus}"/>
                        <c:if test="${o.orderStatus == 'CREATED' || o.orderStatus == 'PAID'}"><c:set var="normalizedStatus" value="PENDING"/></c:if>
                            <c:if test="${o.orderStatus == 'MERCHANT_ACCEPTED'}"><c:set var="normalizedStatus" value="CONFIRMED"/></c:if>
                                <c:if test="${o.orderStatus == 'MERCHANT_REJECTED' || o.orderStatus == 'FAILED'}"><c:set var="normalizedStatus" value="CANCELLED"/></c:if>

                                    <div class="bg-white rounded-2xl shadow-[0_8px_30px_rgb(0,0,0,0.04)] border border-gray-100 p-6 flex flex-col md:flex-row gap-6 relative overflow-hidden transition-all hover:shadow-lg">

                                        <div class="flex-1 border-b md:border-b-0 md:border-r border-gray-100 pb-4 md:pb-0 md:pr-6">
                                            <div class="flex justify-between items-start mb-3">
                                                <div>
                                                    <span class="bg-gray-100 text-gray-600 px-2.5 py-1 rounded-md text-xs font-bold uppercase tracking-wider">#${o.orderCode}</span>
                                                    <span class="ml-2 px-2.5 py-1 rounded-md text-[11px] font-bold uppercase tracking-wide ${normalizedStatus == 'DELIVERED' ? 'bg-green-100 text-green-700' : (normalizedStatus == 'CANCELLED' ? 'bg-red-100 text-red-700' : 'bg-orange-100 text-orange-700')}">${normalizedStatus}</span>
                                                    <p class="text-xs font-semibold text-gray-400 mt-2 flex items-center gap-1">
                                                        <span class="material-symbols-outlined text-[14px]">schedule</span>
                                                        <fmt:formatDate value="${o.createdAt}" pattern="HH:mm - dd/MM/yyyy"/>
                                                    </p>
                                                </div>
                                                <div class="text-right">
                                                    <p class="text-2xl font-black text-primary">
                                                        <fmt:formatNumber value="${o.totalAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                                    </p>
                                                    <p class="text-xs font-bold mt-1 uppercase ${o.paymentStatus == 'PAID' ? 'text-green-500' : 'text-orange-500'}">
                                                        ${o.paymentMethod} - ${o.paymentStatus == 'PAID' ? 'Đã thanh toán' : 'Chưa thanh toán'}
                                                    </p>
                                                </div>
                                            </div>

                                            <div class="bg-gray-50 rounded-xl p-4 mt-4">
                                                <p class="font-bold text-gray-900 flex items-center gap-2 mb-1">
                                                    <span class="material-symbols-outlined text-[18px] text-gray-400">person</span> ${o.receiverName}
                                                    <span class="text-gray-400 font-normal">|</span> ${o.receiverPhone}
                                                </p>
                                                <p class="text-sm text-gray-600 flex items-start gap-2">
                                                    <span class="material-symbols-outlined text-[18px] text-gray-400 mt-0.5">location_on</span>
                                                    ${o.deliveryAddressLine}
                                                </p>
                                                <c:if test="${not empty o.deliveryNote}">
                                                    <p class="text-sm text-orange-600 font-medium italic mt-2 flex items-center gap-1">
                                                        <span class="material-symbols-outlined text-[16px]">edit_note</span> Ghi chú: "${o.deliveryNote}"
                                                    </p>
                                                </c:if>
                                            </div>
                                        </div>

                                        <div class="w-full md:w-56 shrink-0 flex flex-col justify-center gap-3">

                                            <c:if test="${o.orderStatus == 'CREATED' || o.orderStatus == 'PAID'}">
                                                <button onclick="openPrepModal(${o.id})" class="w-full bg-primary hover:bg-primary-dark text-white font-bold py-3 rounded-xl shadow-md transition-colors flex items-center justify-center gap-2">
                                                    <span class="material-symbols-outlined">check_circle</span> Nhận đơn
                                                </button>
                                                <button onclick="openCancelModal(${o.id})" class="w-full bg-red-50 hover:bg-red-100 text-red-600 font-bold py-3 rounded-xl transition-colors flex items-center justify-center gap-2">
                                                    <span class="material-symbols-outlined">cancel</span> Từ chối
                                                </button>
                                            </c:if>

                                            <c:if test="${o.orderStatus == 'MERCHANT_ACCEPTED' || o.orderStatus == 'PREPARING'}">
                                                <form action="${pageContext.request.contextPath}/merchant/orders" method="POST">
                                                    <input type="hidden" name="action" value="ready">
                                                    <input type="hidden" name="orderId" value="${o.id}">
                                                    <input type="hidden" name="tab" value="${currentTab}">
                                                    <input type="hidden" name="status" value="${statusFilter}">
                                                    <input type="hidden" name="from" value="${fromDateTime}">
                                                    <input type="hidden" name="to" value="${toDateTime}">
                                                    <button type="submit" class="w-full bg-green-500 hover:bg-green-600 text-white font-bold py-3 rounded-xl shadow-md transition-colors flex items-center justify-center gap-2">
                                                        <span class="material-symbols-outlined">done_all</span> Xong, chờ Shipper
                                                    </button>
                                                </form>
                                            </c:if>

                                            <c:if test="${o.orderStatus == 'READY_FOR_PICKUP' || o.orderStatus == 'DELIVERING' || o.orderStatus == 'PICKED_UP' || o.orderStatus == 'DELIVERED' || o.orderStatus == 'CANCELLED' || o.orderStatus == 'MERCHANT_REJECTED' || o.orderStatus == 'FAILED'}">
                                                <div class="text-center p-3 rounded-xl ${o.orderStatus == 'DELIVERED' ? 'bg-green-50 text-green-700' : (o.orderStatus == 'READY_FOR_PICKUP' ? 'bg-blue-50 text-blue-700' : 'bg-red-50 text-red-700')}">
                                                    <p class="font-bold text-sm uppercase">
                                                        ${o.orderStatus == 'READY_FOR_PICKUP' ? 'Đang đợi Shipper' : (o.orderStatus == 'DELIVERED' ? 'Giao thành công' : (o.orderStatus == 'DELIVERING' || o.orderStatus == 'PICKED_UP' ? 'Đang giao hàng' : 'Đã hủy'))}
                                                    </p>
                                                </div>
                                            </c:if>

                                            <a href="${pageContext.request.contextPath}/merchant/orders/detail?id=${o.id}" class="w-full bg-white border-2 border-gray-200 hover:border-gray-300 text-gray-700 font-bold py-2.5 rounded-xl transition-colors flex items-center justify-center gap-2">
                                                <span class="material-symbols-outlined text-[20px]">visibility</span> Chi tiết món
                                            </a>
                                        </div>
                                    </div>
                                </c:forEach>

                            </div>
                        </div>
                    </main>

                    <div id="prepModal" class="fixed inset-0 bg-gray-900/60 z-50 hidden flex items-center justify-center backdrop-blur-sm">
                        <div class="bg-white rounded-[2rem] p-8 w-full max-w-sm shadow-2xl relative text-center">
                            <button onclick="closePrepModal()" class="absolute top-6 right-6 text-gray-400 hover:text-gray-600">
                                <span class="material-symbols-outlined">close</span>
                            </button>
                            <div class="w-16 h-16 bg-orange-100 text-primary rounded-full flex items-center justify-center text-3xl mx-auto mb-4">
                                <span class="material-symbols-outlined text-[32px]">skillet</span>
                            </div>
                            <h3 class="text-xl font-bold text-gray-900 mb-2">Nhận đơn hàng</h3>
                            <p class="text-gray-500 mb-6 text-sm">Xác nhận bắt đầu chuẩn bị món ăn?</p>

                            <form action="${pageContext.request.contextPath}/merchant/orders" method="POST">
                                <input type="hidden" name="action" value="accept">
                                <input type="hidden" name="orderId" id="prepOrderIdInput">
                                <input type="hidden" name="tab" value="${currentTab}">
                                <input type="hidden" name="status" value="${statusFilter}">
                                <input type="hidden" name="from" value="${fromDateTime}">
                                <input type="hidden" name="to" value="${toDateTime}">

                                <div class="flex gap-3">
                                    <button type="button" onclick="closePrepModal()" class="flex-1 bg-gray-100 hover:bg-gray-200 text-gray-700 font-bold py-3 rounded-xl transition-colors">Hủy</button>
                                    <button type="submit" class="flex-1 bg-primary hover:bg-primary-dark text-white font-bold py-3 rounded-xl transition-colors shadow-md">Xác nhận</button>
                                </div>
                            </form>
                        </div>
                    </div>

                    <div id="cancelModal" class="fixed inset-0 bg-gray-900/60 z-50 hidden flex items-center justify-center backdrop-blur-sm">
                        <div class="bg-white rounded-[2rem] p-8 w-full max-w-md shadow-2xl relative text-center">
                            <button onclick="closeCancelModal()" class="absolute top-6 right-6 text-gray-400 hover:text-gray-600">
                                <span class="material-symbols-outlined">close</span>
                            </button>
                            <div class="w-16 h-16 bg-red-100 text-red-500 rounded-full flex items-center justify-center text-3xl mx-auto mb-4">
                                <span class="material-symbols-outlined text-[32px]">warning</span>
                            </div>
                            <h3 class="text-xl font-bold text-gray-900 mb-2">Từ chối đơn hàng</h3>
                            <p class="text-gray-500 mb-6 text-sm">Vui lòng chọn lý do từ chối để thông báo cho khách hàng.</p>

                            <form action="${pageContext.request.contextPath}/merchant/orders" method="POST" id="cancelForm">
                                <input type="hidden" name="action" value="cancel">
                                <input type="hidden" name="orderId" id="cancelOrderIdInput">
                                <input type="hidden" name="tab" value="${currentTab}">
                                <input type="hidden" name="status" value="${statusFilter}">
                                <input type="hidden" name="from" value="${fromDateTime}">
                                <input type="hidden" name="to" value="${toDateTime}">
                                <input type="hidden" name="cancelReason" id="cancelReasonInput">

                                <div class="space-y-2 mb-8">
                                    <button type="button" onclick="selectReason('Hết món', this)" class="cancel-reason-btn w-full text-left px-4 py-3 rounded-xl border border-gray-200 text-gray-700 font-medium hover:bg-gray-50 transition-colors">Hết món trong đơn</button>
                                    <button type="button" onclick="selectReason('Quán quá tải', this)" class="cancel-reason-btn w-full text-left px-4 py-3 rounded-xl border border-gray-200 text-gray-700 font-medium hover:bg-gray-50 transition-colors">Quán đang quá tải</button>
                                    <button type="button" onclick="selectReason('Sắp đóng cửa', this)" class="cancel-reason-btn w-full text-left px-4 py-3 rounded-xl border border-gray-200 text-gray-700 font-medium hover:bg-gray-50 transition-colors">Chuẩn bị đóng cửa</button>
                                </div>

                                <div class="flex gap-3">
                                    <button type="button" onclick="closeCancelModal()" class="flex-1 bg-gray-100 hover:bg-gray-200 text-gray-700 font-bold py-3 rounded-xl transition-colors">Quay lại</button>
                                    <button type="button" onclick="submitCancel()" class="flex-1 bg-red-500 hover:bg-red-600 text-white font-bold py-3 rounded-xl transition-colors shadow-md">Từ chối đơn</button>
                                </div>
                            </form>
                        </div>
                    </div>

                    <script>
                        // Xử lý Modal Nhận đơn
                        function openPrepModal(orderId) {
                            document.getElementById('prepOrderIdInput').value = orderId;
                            const m = document.getElementById('prepModal');
                            m.classList.remove('hidden');
                            m.classList.add('flex');
                        }
                        function closePrepModal() {
                            const m = document.getElementById('prepModal');
                            m.classList.add('hidden');
                            m.classList.remove('flex');
                        }
                        
                        // Xử lý Modal Hủy đơn
                        function openCancelModal(orderId) {
                            document.getElementById('cancelOrderIdInput').value = orderId;
                            const m = document.getElementById('cancelModal');
                            m.classList.remove('hidden');
                            m.classList.add('flex');
                        }
                        function closeCancelModal() {
                            const m = document.getElementById('cancelModal');
                            m.classList.add('hidden');
                            m.classList.remove('flex');
                        }
                        function selectReason(reason, btn) {
                            document.getElementById('cancelReasonInput').value = reason;
                            document.querySelectorAll('.cancel-reason-btn').forEach(b => {
                                b.classList.remove('border-red-400', 'bg-red-50', 'text-red-700');
                                b.classList.add('border-gray-200', 'text-gray-700');
                            });
                            btn.classList.add('border-red-400', 'bg-red-50', 'text-red-700');
                            btn.classList.remove('border-gray-200', 'text-gray-700');
                        }
                        function submitCancel() {
                            if (!document.getElementById('cancelReasonInput').value) {
                                alert("Vui lòng chọn 1 lý do từ chối!");
                                return;
                            }
                            document.getElementById('cancelForm').submit();
                        }
                        
                        // Hiệu ứng nháy Title khi có đơn mới & Đồng hồ 30s
                        const newOrderSpan = document.getElementById('newOrderCount');
                        const NEW_ORDER_COUNT = newOrderSpan ? parseInt(newOrderSpan.textContent) : 0;
                        const PREV_KEY = 'clickeat_merchant_prev_orders';
                        const prevCount = parseInt(localStorage.getItem(PREV_KEY) || '0');
                        
                        if (NEW_ORDER_COUNT > prevCount) {
                            let flash = true;
                            const origTitle = document.title;
                            const flashInterval = setInterval(() => {
                                document.title = flash ? '🔔 ' + NEW_ORDER_COUNT + ' Đơn mới!' : origTitle;
                                flash = !flash;
                            }, 800);
                            setTimeout(() => {
                                clearInterval(flashInterval);
                                document.title = origTitle;
                            }, 10000);
                        }
                        localStorage.setItem(PREV_KEY, NEW_ORDER_COUNT);
                        
                        // Auto Refresh tránh lúc đang mở Modal
                        let countdown = 30;
                        const timerEl = document.getElementById('refreshTimer');
                        setInterval(() => {
                            const anyModalOpen = !document.getElementById('cancelModal').classList.contains('hidden')
                            || !document.getElementById('prepModal').classList.contains('hidden');
                            if (anyModalOpen)
                            return;
                            countdown--;
                            if (countdown <= 0) {
                                location.reload();
                                return;
                            }
                            timerEl.textContent = 'Tự động làm mới sau ' + countdown + 's';
                        }, 1000);
                    </script>
                </body>
            </html>