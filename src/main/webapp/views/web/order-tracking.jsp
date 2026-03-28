<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Theo dõi đơn hàng - ClickEat</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <link rel="shortcut icon" href="${pageContext.request.contextPath}/logo-icon.png?v=2">

        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
        <link rel="stylesheet" href="https://unpkg.com/leaflet/dist/leaflet.css"/>
        <script src="https://unpkg.com/leaflet/dist/leaflet.js"></script>
    </head>
    <body class="bg-[#f4f5f7] text-gray-900">
        <jsp:include page="/views/web/header.jsp" />

        <main class="max-w-6xl mx-auto px-4 py-8">
            <div class="grid grid-cols-1 lg:grid-cols-[minmax(0,1fr)_360px] gap-6">

                <section class="bg-white rounded-3xl border border-gray-200 overflow-hidden shadow-sm">
                    <div class="p-6 border-b border-gray-100">
                        <div class="flex flex-wrap items-center justify-between gap-4">
                            <div>
                                <div class="text-sm font-bold text-orange-500 uppercase tracking-wide">
                                    Theo dõi đơn hàng
                                </div>
                                <h1 class="text-3xl font-black mt-1">${order.orderCode}</h1>
                                <p id="status-label" class="mt-2 text-gray-500 font-medium">
                                    Đang tải trạng thái...
                                </p>
                            </div>

                            <div class="flex gap-3">
                                <button id="call-shipper-btn"
                                        type="button"
                                        class="px-5 py-3 rounded-2xl bg-green-500 hover:bg-green-600 text-white font-black shadow">
                                    <i class="fa-solid fa-phone mr-2"></i>Gọi
                                </button>

                                <button type="button"
                                        class="px-5 py-3 rounded-2xl bg-gray-200 text-gray-500 font-black cursor-not-allowed">
                                    <i class="fa-solid fa-message mr-2"></i>Chat
                                </button>
                            </div>
                        </div>
                    </div>

                    <div class="p-4">
                        <div class="relative rounded-2xl overflow-hidden border border-gray-200">
                            <div id="map" class="w-full h-[460px]"></div>

                            <div class="absolute left-4 bottom-4 bg-white/95 backdrop-blur px-4 py-3 rounded-xl shadow border border-gray-100 z-[500]">
                                <div class="text-xs uppercase font-bold text-gray-400">Tuyến hiện tại</div>
                                <div id="route-text" class="font-black text-gray-800 mt-1">Đang tải...</div>
                            </div>
                        </div>
                    </div>

                    <div class="px-6 pb-6">
                        <div class="grid grid-cols-5 gap-3 text-center">
                            <div class="step-item" data-step="1">
                                <div class="step-dot w-11 h-11 mx-auto rounded-full bg-gray-200 flex items-center justify-center font-black">1</div>
                                <div class="mt-2 text-xs font-bold text-gray-500">Đặt đơn</div>
                            </div>
                            <div class="step-item" data-step="2">
                                <div class="step-dot w-11 h-11 mx-auto rounded-full bg-gray-200 flex items-center justify-center font-black">2</div>
                                <div class="mt-2 text-xs font-bold text-gray-500">Chuẩn bị</div>
                            </div>
                            <div class="step-item" data-step="3">
                                <div class="step-dot w-11 h-11 mx-auto rounded-full bg-gray-200 flex items-center justify-center font-black">3</div>
                                <div class="mt-2 text-xs font-bold text-gray-500">Đến quán</div>
                            </div>
                            <div class="step-item" data-step="4">
                                <div class="step-dot w-11 h-11 mx-auto rounded-full bg-gray-200 flex items-center justify-center font-black">4</div>
                                <div class="mt-2 text-xs font-bold text-gray-500">Đang giao</div>
                            </div>
                            <div class="step-item" data-step="5">
                                <div class="step-dot w-11 h-11 mx-auto rounded-full bg-gray-200 flex items-center justify-center font-black">5</div>
                                <div class="mt-2 text-xs font-bold text-gray-500">Hoàn tất</div>
                            </div>
                        </div>
                    </div>
                </section>

                <aside class="space-y-6">
                    <div class="bg-white rounded-3xl border border-gray-200 p-6 shadow-sm">
                        <div class="text-sm font-bold uppercase tracking-wide text-blue-500">Cửa hàng</div>
                        <div id="merchant-name" class="text-2xl font-black mt-2">---</div>
                        <div id="merchant-address" class="mt-2 text-gray-500">---</div>
                    </div>

                    <div class="bg-white rounded-3xl border border-gray-200 p-6 shadow-sm">
                        <div class="text-sm font-bold uppercase tracking-wide text-orange-500">Giao đến</div>
                        <div id="customer-name" class="text-2xl font-black mt-2">---</div>
                        <div id="customer-phone" class="mt-1 text-gray-600 font-semibold">---</div>
                        <div id="customer-address" class="mt-2 text-gray-500">---</div>
                    </div>

                    <div class="bg-white rounded-3xl border border-gray-200 p-6 shadow-sm">
                        <div class="text-sm font-bold uppercase tracking-wide text-green-500">Shipper</div>
                        <div id="shipper-name" class="text-2xl font-black mt-2">Chưa có shipper</div>
                        <div id="shipper-phone" class="mt-1 text-gray-600 font-semibold">---</div>
                        <div id="shipper-meta" class="mt-2 text-gray-500 text-sm">Hệ thống sẽ cập nhật khi có người nhận đơn.</div>
                    </div>

                    <div class="bg-white rounded-3xl border border-gray-200 p-6 shadow-sm space-y-3">
                        <button id="confirm-received-btn"
                                type="button"
                                class="hidden w-full h-12 rounded-2xl bg-green-600 hover:bg-green-700 text-white font-black">
                            <i class="fa-solid fa-circle-check mr-2"></i>
                            Xác nhận đã nhận đơn
                        </button>

                        <button id="view-review-btn"
                                type="button"
                                class="hidden w-full h-12 rounded-2xl bg-gray-900 hover:bg-black text-white font-black">
                            <i class="fa-solid fa-eye mr-2"></i>
                            Xem đánh giá
                        </button>
                    </div>
                </aside>
            </div>
        </main>

        <div id="phone-modal" class="fixed inset-0 hidden items-center justify-center bg-black/45 z-[9999]">
            <div class="bg-white rounded-3xl shadow-2xl w-full max-w-md p-6">
                <div class="flex items-center justify-between">
                    <h3 class="text-2xl font-black">Số điện thoại shipper</h3>
                    <button type="button" onclick="closePhoneModal()" class="w-10 h-10 rounded-full hover:bg-gray-100">
                        <i class="fa-solid fa-xmark"></i>
                    </button>
                </div>

                <p class="mt-3 text-gray-500">Bạn có thể sao chép số điện thoại này để dán vào điện thoại và gọi trực tiếp.</p>

                <div class="mt-5 rounded-2xl bg-gray-100 px-4 py-4 flex items-center justify-between gap-3">
                    <div id="modal-shipper-phone" class="text-xl font-black text-gray-800">Chưa có số điện thoại</div>
                    <button type="button"
                            onclick="copyShipperPhone()"
                            class="px-4 py-2 rounded-xl bg-blue-600 hover:bg-blue-700 text-white font-bold">
                        Sao chép
                    </button>
                </div>
            </div>
        </div>

        <div id="review-modal" class="fixed inset-0 hidden items-center justify-center bg-black/45 z-[9999] p-4">
            <div class="bg-white rounded-3xl shadow-2xl w-full max-w-2xl p-6 max-h-[90vh] overflow-y-auto">
                <div class="flex items-center justify-between">
                    <h3 class="text-2xl font-black">Đánh giá đơn hàng</h3>
                    <button type="button" onclick="closeReviewModal()" class="w-10 h-10 rounded-full hover:bg-gray-100">
                        <i class="fa-solid fa-xmark"></i>
                    </button>
                </div>

                <form id="review-form" method="post" action="${pageContext.request.contextPath}/customer/submit-review" class="mt-6 space-y-6">
                    <input type="hidden" name="orderId" value="${order.id}">

                    <div class="rounded-2xl border border-gray-200 p-5">
                        <div class="text-sm font-bold uppercase tracking-wide text-blue-500">Đánh giá cửa hàng</div>
                        <div id="review-merchant-name" class="text-xl font-black mt-2">Cửa hàng</div>

                        <div class="mt-4">
                            <label class="block text-sm font-bold mb-2">Số sao</label>
                            <select name="merchantStars" class="w-full h-12 rounded-xl border border-gray-300 px-4" required>
                                <option value="">Chọn số sao</option>
                                <option value="5">5 sao</option>
                                <option value="4">4 sao</option>
                                <option value="3">3 sao</option>
                                <option value="2">2 sao</option>
                                <option value="1">1 sao</option>
                            </select>
                        </div>

                        <div class="mt-4">
                            <label class="block text-sm font-bold mb-2">Nhận xét</label>
                            <textarea name="merchantComment" rows="4" class="w-full rounded-xl border border-gray-300 px-4 py-3" placeholder="Chia sẻ cảm nhận về cửa hàng..."></textarea>
                        </div>
                    </div>

                    <div id="shipper-review-block" class="rounded-2xl border border-gray-200 p-5 hidden">
                        <div class="text-sm font-bold uppercase tracking-wide text-green-500">Đánh giá shipper</div>
                        <div id="review-shipper-name" class="text-xl font-black mt-2">Shipper</div>

                        <div class="mt-4">
                            <label class="block text-sm font-bold mb-2">Số sao</label>
                            <select name="shipperStars" class="w-full h-12 rounded-xl border border-gray-300 px-4">
                                <option value="">Chọn số sao</option>
                                <option value="5">5 sao</option>
                                <option value="4">4 sao</option>
                                <option value="3">3 sao</option>
                                <option value="2">2 sao</option>
                                <option value="1">1 sao</option>
                            </select>
                        </div>

                        <div class="mt-4">
                            <label class="block text-sm font-bold mb-2">Nhận xét</label>
                            <textarea name="shipperComment" rows="4" class="w-full rounded-xl border border-gray-300 px-4 py-3" placeholder="Chia sẻ cảm nhận về shipper..."></textarea>
                        </div>
                    </div>

                    <div class="flex justify-end gap-3">
                        <button type="button" onclick="closeReviewModal()" class="h-12 px-6 rounded-2xl bg-gray-200 text-gray-700 font-black">
                            Đóng
                        </button>
                        <button type="submit" class="h-12 px-6 rounded-2xl bg-orange-500 hover:bg-orange-600 text-white font-black">
                            Hoàn tất
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <div id="view-review-modal" class="fixed inset-0 hidden items-center justify-center bg-black/45 z-[9999] p-4">
            <div class="bg-white rounded-3xl shadow-2xl w-full max-w-2xl p-6 max-h-[90vh] overflow-y-auto">
                <div class="flex items-center justify-between">
                    <h3 class="text-2xl font-black">Đánh giá đã gửi</h3>
                    <button type="button" onclick="closeViewReviewModal()" class="w-10 h-10 rounded-full hover:bg-gray-100">
                        <i class="fa-solid fa-xmark"></i>
                    </button>
                </div>

                <div id="view-review-content" class="mt-6 space-y-4 text-gray-700">
                    Đang tải...
                </div>
            </div>
        </div>

        <script>
            const trackingUrl = '${pageContext.request.contextPath}/api/customer-order-tracking?orderId=${order.id}';
                const reviewViewUrl = '${pageContext.request.contextPath}/api/customer-review?orderId=${order.id}';

                    let map;
                    let merchantMarker = null;
                    let customerMarker = null;
                    let routeLine = null;
                    let shipperPhone = '';
                    let currentTrackingData = null;

                    function initMap() {
                        map = L.map('map').setView([10.7769, 106.7009], 13);

                        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                            attribution: '© OpenStreetMap',
                            maxZoom: 19
                        }).addTo(map);
                    }

                    function buildIcon(bgClass, iconClass) {
                        return L.divIcon({
                            html: `<div style="width:38px;height:38px;border-radius:9999px;background:${bgClass};color:white;display:flex;align-items:center;justify-content:center;border:3px solid white;box-shadow:0 8px 20px rgba(0,0,0,.18)">
                                <i class="${iconClass}"></i>
                           </div>`,
                            className: '',
                            iconSize: [38, 38],
                            iconAnchor: [19, 19]
                        });
                    }

                    const merchantIcon = buildIcon('#3B82F6', 'fa-solid fa-store');
                    const customerIcon = buildIcon('#F97316', 'fa-solid fa-house');

                    function updateOrCreateMarker(oldMarker, lat, lng, icon, popupText) {
                        if (!lat || !lng)
                            return oldMarker;

                        if (oldMarker) {
                            oldMarker.setLatLng([lat, lng]).bindPopup(popupText);
                            return oldMarker;
                        }

                        return L.marker([lat, lng], {icon}).addTo(map).bindPopup(popupText);
                    }

                    function updateSteps(activeStep) {
                        document.querySelectorAll('.step-item').forEach(item => {
                            const step = parseInt(item.dataset.step);
                            const dot = item.querySelector('.step-dot');

                            if (step < activeStep) {
                                dot.className = 'step-dot w-11 h-11 mx-auto rounded-full bg-green-500 text-white flex items-center justify-center font-black';
                            } else if (step === activeStep) {
                                dot.className = 'step-dot w-11 h-11 mx-auto rounded-full bg-orange-500 text-white flex items-center justify-center font-black';
                            } else {
                                dot.className = 'step-dot w-11 h-11 mx-auto rounded-full bg-gray-200 text-gray-700 flex items-center justify-center font-black';
                            }
                        });
                    }

                    function drawRoute(data) {
                        if (routeLine) {
                            map.removeLayer(routeLine);
                            routeLine = null;
                        }

                        const merchant = data.merchant || {};
                        const customer = data.customer || {};

                        if (merchant.lat && merchant.lng && customer.lat && customer.lng) {
                            routeLine = L.polyline([
                                [merchant.lat, merchant.lng],
                                [customer.lat, customer.lng]
                            ], {
                                color: '#2563EB',
                                weight: 5,
                                opacity: 0.9,
                                dashArray: '10,8'
                            }).addTo(map);

                            map.fitBounds([
                                [merchant.lat, merchant.lng],
                                [customer.lat, customer.lng]
                            ], {padding: [40, 40]});
                        }
                    }

                    function updateActionButtons(data) {
                        const confirmBtn = document.getElementById('confirm-received-btn');
                        const viewBtn = document.getElementById('view-review-btn');

                        confirmBtn.classList.add('hidden');
                        viewBtn.classList.add('hidden');

                        if (data.showReviewButton) {
                            confirmBtn.classList.remove('hidden');
                        }

                        if (data.showViewReviewButton) {
                            viewBtn.classList.remove('hidden');
                        }
                    }

                    function renderTracking(data) {
                        currentTrackingData = data;

                        document.getElementById('status-label').textContent =
                                data.statusLabel || 'Đơn hàng đang được cập nhật';

                        updateSteps(data.statusStep || 1);

                        const merchant = data.merchant || {};
                        const customer = data.customer || {};
                        const shipper = data.shipper || {};
                        const routeInfo = data.routeInfo || {};

                        document.getElementById('merchant-name').textContent = merchant.name || '---';
                        document.getElementById('merchant-address').textContent = merchant.address || '---';

                        document.getElementById('customer-name').textContent = customer.name || '---';
                        document.getElementById('customer-phone').textContent = customer.phone || '---';
                        document.getElementById('customer-address').textContent = customer.address || '---';

                        document.getElementById('shipper-name').textContent = shipper.name || 'Chưa có shipper';
                        document.getElementById('shipper-phone').textContent = shipper.phone || '---';
                        document.getElementById('shipper-meta').textContent =
                                shipper.meta || 'Hệ thống sẽ cập nhật khi có người nhận đơn.';

                        shipperPhone = shipper.phone || '';

                        document.getElementById('route-text').textContent =
                                routeInfo.text || 'Tuyến giao hàng từ quán đến địa chỉ nhận';

                        merchantMarker = updateOrCreateMarker(
                                merchantMarker, merchant.lat, merchant.lng, merchantIcon, 'Cửa hàng'
                                );

                        customerMarker = updateOrCreateMarker(
                                customerMarker, customer.lat, customer.lng, customerIcon, 'Điểm giao hàng'
                                );

                        drawRoute(data);
                        updateActionButtons(data);
                    }

                    async function loadTracking() {
                        try {
                            const res = await fetch(trackingUrl);

                            if (!res.ok) {
                                const text = await res.text();
                                document.getElementById('status-label').textContent = `API tracking lỗi ${res.status}`;
                                console.error('Tracking API failed:', res.status, trackingUrl, text);
                                return;
                            }

                            const data = await res.json();

                            if (!data.success) {
                                document.getElementById('status-label').textContent =
                                        data.message || 'Không tải được dữ liệu tracking';
                                console.error('Tracking API business error:', data);
                                return;
                            }

                            renderTracking(data);
                        } catch (e) {
                            document.getElementById('status-label').textContent =
                                    'Không thể kết nối hệ thống tracking';
                            console.error(e);
                        }
                    }

                    document.getElementById('call-shipper-btn').addEventListener('click', function () {
                        const modalPhone = document.getElementById('modal-shipper-phone');
                        modalPhone.textContent = shipperPhone || 'Chưa có số điện thoại';
                        document.getElementById('phone-modal').classList.remove('hidden');
                        document.getElementById('phone-modal').classList.add('flex');
                    });

                    document.getElementById('confirm-received-btn').addEventListener('click', function () {
                        openReviewModal();
                    });

                    document.getElementById('view-review-btn').addEventListener('click', function () {
                        openViewReviewModal();
                    });

                    function openReviewModal() {
                        if (!currentTrackingData)
                            return;

                        document.getElementById('review-merchant-name').textContent =
                                currentTrackingData.merchant?.name || 'Cửa hàng';

                        if (currentTrackingData.shipper && currentTrackingData.shipper.id > 0) {
                            document.getElementById('shipper-review-block').classList.remove('hidden');
                            document.getElementById('review-shipper-name').textContent =
                                    currentTrackingData.shipper.name || 'Shipper';
                        } else {
                            document.getElementById('shipper-review-block').classList.add('hidden');
                        }

                        document.getElementById('review-modal').classList.remove('hidden');
                        document.getElementById('review-modal').classList.add('flex');
                    }

                    function closeReviewModal() {
                        document.getElementById('review-modal').classList.add('hidden');
                        document.getElementById('review-modal').classList.remove('flex');
                    }

                    async function openViewReviewModal() {
                        const content = document.getElementById('view-review-content');
                        content.innerHTML = 'Đang tải...';

                        document.getElementById('view-review-modal').classList.remove('hidden');
                        document.getElementById('view-review-modal').classList.add('flex');

                        try {
                            const res = await fetch(reviewViewUrl);
                            const data = await res.json();

                            if (!data.success) {
                                content.innerHTML = `<div class="text-red-500 font-bold">${data.message || 'Không tải được đánh giá.'}</div>`;
                                return;
                            }

                            if (!data.reviews || data.reviews.length === 0) {
                                content.innerHTML = `<div class="text-gray-500">Chưa có đánh giá nào.</div>`;
                                return;
                            }

                            let html = '';
                            data.reviews.forEach(function (item) {
                                const stars = '★'.repeat(item.stars) + '☆'.repeat(5 - item.stars);
                                const targetLabel = item.targetType === 'MERCHANT' ? 'Cửa hàng' : 'Shipper';
                                const targetColor = item.targetType === 'MERCHANT' ? 'text-blue-500' : 'text-green-500';
                                const targetName = item.targetName || '';
                                const comment = item.comment || 'Không có nhận xét.';
                                const replyBlock = item.replyComment
                                        ? '<div class="mt-3 p-3 rounded-xl bg-gray-50 border border-gray-200">'
                                        + '<div class="font-bold text-sm mb-1">Phản hồi:</div>'
                                        + '<div>' + item.replyComment + '</div>'
                                        + '</div>'
                                        : '';

                                html += ''
                                        + '<div class="rounded-2xl border border-gray-200 p-4">'
                                        + '<div class="text-sm font-bold uppercase tracking-wide ' + targetColor + '">'
                                        + targetLabel
                                        + '</div>'
                                        + '<div class="text-xl font-black mt-2">' + targetName + '</div>'
                                        + '<div class="mt-2 text-yellow-500 text-lg">' + stars + '</div>'
                                        + '<div class="mt-3 text-gray-700 whitespace-pre-line">' + comment + '</div>'
                                        + replyBlock
                                        + '</div>';
                            });
                            content.innerHTML = html;

                        } catch (e) {
                            content.innerHTML = `<div class="text-red-500 font-bold">Không thể tải đánh giá.</div>`;
                        }
                    }

                    function closeViewReviewModal() {
                        document.getElementById('view-review-modal').classList.add('hidden');
                        document.getElementById('view-review-modal').classList.remove('flex');
                    }

                    function closePhoneModal() {
                        document.getElementById('phone-modal').classList.add('hidden');
                        document.getElementById('phone-modal').classList.remove('flex');
                    }

                    function copyShipperPhone() {
                        const text = document.getElementById('modal-shipper-phone').textContent.trim();
                        if (!text || text === 'Chưa có số điện thoại')
                            return;

                        navigator.clipboard.writeText(text).then(() => {
                            alert('Đã sao chép số điện thoại shipper');
                        });
                    }

                    initMap();
                    loadTracking();
                    setInterval(loadTracking, 15000);
        </script>
    </body>
</html>