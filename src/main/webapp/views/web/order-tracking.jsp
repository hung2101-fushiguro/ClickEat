<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/responsive-global.css">
        <title>Theo dõi đơn hàng - ClickEat</title>
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
        integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY="
        crossorigin=""/>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
        <style>
            #customerTrackingMap { height: 360px; }
        </style>
    </head>
    <body class="bg-gray-50 text-gray-900">
        <jsp:include page="/views/web/header.jsp">
            <jsp:param name="activePage" value="profile" />
        </jsp:include>

        <main class="max-w-5xl mx-auto px-6 py-8">
            <div class="mb-6 flex items-center justify-between gap-3 flex-wrap">
                <div>
                    <div class="text-sm font-bold text-orange-500">Theo dõi đơn hàng</div>
                    <h1 class="text-3xl font-black">Đơn #${tracking.orderCode}</h1>
                </div>
                <a href="${pageContext.request.contextPath}/customer/orders" class="px-4 py-2 rounded-lg border border-gray-200 bg-white hover:bg-gray-50 font-semibold text-sm">
                    Quay lại lịch sử
                </a>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
                <section class="lg:col-span-2 bg-white border border-gray-100 rounded-2xl shadow-sm overflow-hidden">
                    <div id="customerTrackingMap"></div>
                    <div class="p-4 border-t border-gray-100 text-sm text-gray-600" id="trackingHint">
                        Hệ thống đang cập nhật vị trí shipper theo thời gian thực.
                    </div>
                </section>

                <aside class="bg-white border border-gray-100 rounded-2xl shadow-sm p-5 space-y-4">
                    <div>
                        <div class="text-xs uppercase tracking-wide text-gray-400 font-bold">Trạng thái đơn</div>
                        <div id="orderStatusText" class="mt-1 text-lg font-black text-orange-500">${tracking.orderStatus}</div>
                    </div>
                    <div>
                        <div class="text-xs uppercase tracking-wide text-gray-400 font-bold">Thanh toán</div>
                        <div id="paymentStatusText" class="mt-1 font-semibold">${tracking.paymentMethod} - ${tracking.paymentStatus}</div>
                    </div>
                    <div>
                        <div class="text-xs uppercase tracking-wide text-gray-400 font-bold">Shipper</div>
                        <div id="shipperName" class="mt-1 font-semibold text-gray-800">
                            <c:choose>
                                <c:when test="${not empty tracking.shipperName}">${tracking.shipperName}</c:when>
                                    <c:otherwise>Đang chờ phân công</c:otherwise>
                                    </c:choose>
                                </div>
                                <div id="shipperPhone" class="text-sm text-gray-500">${tracking.shipperPhone}</div>
                            </div>
                            <div>
                                <div class="text-xs uppercase tracking-wide text-gray-400 font-bold">Địa chỉ giao</div>
                                <div class="mt-1 text-sm text-gray-700">${tracking.deliveryAddress}</div>
                            </div>
                            <div id="ratingCta" class="hidden rounded-xl border border-amber-200 bg-amber-50 p-3">
                                <div class="text-sm font-bold text-amber-700">Đơn đã giao xong</div>
                                <div class="mt-1 text-xs text-amber-700">Bạn có thể đánh giá cửa hàng và shipper ngay bây giờ.</div>
                                <a href="${pageContext.request.contextPath}/customer/orders" class="mt-2 inline-flex h-8 px-3 items-center justify-center rounded-lg bg-amber-500 text-white text-xs font-bold hover:bg-amber-600 transition">
                                    Đi tới trang đánh giá
                                </a>
                            </div>
                            <div id="shipperUpdatedAt" class="text-xs text-gray-400"></div>
                        </aside>
                    </div>
                </main>

                <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"
                integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo="
                crossorigin=""></script>
                <script>
                    window.MAP4D_API_KEY = window.MAP4D_API_KEY || '${initParam["map4d.api.key"]}';
                    window.MAP4D_TILE_URL_TEMPLATE = window.MAP4D_TILE_URL_TEMPLATE || '${initParam["map4d.tile.url.template"]}';
                </script>
                <script src="${pageContext.request.contextPath}/assets/js/map4d-api.js"></script>
                <script>
                    (function () {
                        var ctx = '${pageContext.request.contextPath}';
                        var orderId = Number('${tracking.orderId}');
                        var customerLat = Number('${tracking.customerLat}');
                        var customerLng = Number('${tracking.customerLng}');
                        var shipperLat = Number('${tracking.shipperLat}');
                        var shipperLng = Number('${tracking.shipperLng}');
                        var map = null;
                        var customerMarker = null;
                        var shipperMarker = null;
                        var routeLine = null;
                        var ratingCta = null;
                        
                        function isValidCoord(lat, lng) {
                            return !Number.isNaN(lat) && !Number.isNaN(lng)
                            && lat >= -90 && lat <= 90
                            && lng >= -180 && lng <= 180;
                        }
                        
                        function initMap() {
                            var baseLat = isValidCoord(customerLat, customerLng) ? customerLat : 10.7769;
                            var baseLng = isValidCoord(customerLat, customerLng) ? customerLng : 106.7009;
                            map = L.map('customerTrackingMap').setView([baseLat, baseLng], 14);
                            ClickEatMap4D.addBaseTileLayer(map, {
                                attribution: '&copy; ClickEat Maps',
                                fallbackAttribution: '&copy; OpenStreetMap contributors',
                                maxZoom: 20,
                                fallbackMaxZoom: 19
                            });
                            
                            if (isValidCoord(customerLat, customerLng)) {
                                customerMarker = L.marker([customerLat, customerLng]).addTo(map).bindPopup('Điểm giao hàng');
                            }
                            
                            if (isValidCoord(shipperLat, shipperLng)) {
                                shipperMarker = L.marker([shipperLat, shipperLng]).addTo(map).bindPopup('Vị trí shipper');
                            }
                            
                            refreshRoute();
                        }
                        
                        function updateText(id, value, fallback) {
                            var el = document.getElementById(id);
                            if (!el) {
                                return;
                            }
                            el.textContent = value || fallback || '';
                        }
                        
                        function toggleRatingCta(orderStatus) {
                            if (!ratingCta) {
                                return;
                            }
                            if (String(orderStatus || '').toUpperCase() === 'DELIVERED') {
                                ratingCta.classList.remove('hidden');
                                } else {
                                    ratingCta.classList.add('hidden');
                                }
                            }
                            
                            function refreshRoute() {
                                if (!map || !isValidCoord(customerLat, customerLng) || !isValidCoord(shipperLat, shipperLng)) {
                                    return;
                                }
                                ClickEatMap4D.route(shipperLat, shipperLng, customerLat, customerLng)
                                .then(function (route) {
                                    if (routeLine) {
                                        map.removeLayer(routeLine);
                                    }
                                    routeLine = L.polyline(route.coordinates, {
                                        color: '#f97316',
                                        weight: 5,
                                        opacity: 0.9,
                                        dashArray: '8, 6'
                                    }).addTo(map);
                                    map.fitBounds(routeLine.getBounds(), {padding: [30, 30]});
                                })
                                .catch(function () {
                                });
                            }
                            
                            function updateShipperMarker(lat, lng) {
                                if (!map || !isValidCoord(lat, lng)) {
                                    return;
                                }
                                shipperLat = lat;
                                shipperLng = lng;
                                if (shipperMarker) {
                                    shipperMarker.setLatLng([lat, lng]);
                                    } else {
                                        shipperMarker = L.marker([lat, lng]).addTo(map).bindPopup('Vị trí shipper');
                                    }
                                    refreshRoute();
                                }
                                
                                function formatRelativeTime(millis) {
                                    if (!millis) {
                                        return 'Chưa có bản cập nhật vị trí gần đây';
                                    }
                                    var seconds = Math.max(0, Math.floor((Date.now() - millis) / 1000));
                                    if (seconds < 60) {
                                        return 'Cập nhật vị trí ' + seconds + ' giây trước';
                                    }
                                    var minutes = Math.floor(seconds / 60);
                                    return 'Cập nhật vị trí ' + minutes + ' phút trước';
                                }
                                
                                function pollTracking() {
                                    fetch(ctx + '/customer/order-tracking?orderId=' + orderId + '&format=json', {credentials: 'same-origin'})
                                    .then(function (res) {
                                        if (!res.ok) {
                                            throw new Error('tracking-fetch-failed');
                                        }
                                        return res.json();
                                    })
                                    .then(function (data) {
                                        updateText('orderStatusText', data.orderStatus, 'N/A');
                                        updateText('paymentStatusText', (data.paymentMethod || '') + ' - ' + (data.paymentStatus || ''), 'N/A');
                                        updateText('shipperName', data.shipperName, 'Đang chờ phân công');
                                        updateText('shipperPhone', data.shipperPhone, '');
                                        updateText('shipperUpdatedAt', formatRelativeTime(data.shipperUpdatedAt), '');
                                        toggleRatingCta(data.orderStatus);
                                        
                                        var nextLat = Number(data.shipperLat);
                                        var nextLng = Number(data.shipperLng);
                                        if (isValidCoord(nextLat, nextLng)) {
                                            updateShipperMarker(nextLat, nextLng);
                                            updateText('trackingHint', 'Shipper đang di chuyển, vị trí được cập nhật tự động.', '');
                                            } else {
                                                updateText('trackingHint', 'Đơn đang chờ shipper cập nhật vị trí.', '');
                                            }
                                        })
                                        .catch(function () {
                                            updateText('trackingHint', 'Không thể cập nhật theo dõi lúc này. Hệ thống sẽ thử lại...', '');
                                        });
                                    }
                                    
                                    initMap();
                                    ratingCta = document.getElementById('ratingCta');
                                    toggleRatingCta('${tracking.orderStatus}');
                                    setInterval(pollTracking, 10000);
                                    pollTracking();
                                })();
                            </script>
                        </body>
                    </html>
