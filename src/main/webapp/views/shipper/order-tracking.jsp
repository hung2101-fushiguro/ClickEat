<%--
Document   : order-tracking
Created on : Mar 4, 2026, 4:26:53 PM
Author     : DELL
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Theo dõi Đơn hàng - ClickEat Shipper</title>
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/assets/images/shipperlogo.png">
        <script src="https://cdn.tailwindcss.com"></script>
        <script>
            tailwind.config = {
                theme: {
                    extend: {
                        fontFamily: {sans: ['Inter', 'sans-serif']},
                        colors: {primary: '#c86601', 'primary-dark': '#a05201'}
                    }
                }
            };
        </script>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/vendor/leaflet/leaflet.css" />
        <script src="${pageContext.request.contextPath}/assets/vendor/leaflet/leaflet.js"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
        <style>body { font-family: 'Inter', sans-serif; }</style>
    </head>
    <body class="bg-gray-100 flex justify-center min-h-screen">

        <div class="bg-gray-50 w-full max-w-md shadow-2xl flex flex-col h-screen relative">

            <div class="bg-white px-4 py-4 flex items-center justify-between shadow-sm z-10 sticky top-0 border-b border-gray-100">
                <a href="${pageContext.request.contextPath}/shipper/dashboard" class="w-10 h-10 flex items-center justify-center text-gray-700 hover:bg-gray-100 rounded-full transition">
                    <i class="fa-solid fa-arrow-left text-xl"></i>
                </a>
                <h1 class="text-lg font-black text-gray-900">Trạng thái giao hàng</h1>
                <div class="w-10"></div>
            </div>

            <div class="flex-1 overflow-y-auto p-4 space-y-4 pb-40">

                <c:choose>
                    <c:when test="${order.orderStatus == 'DELIVERING'}">
                        <div class="bg-blue-500 rounded-2xl p-6 text-white text-center shadow-md">
                            <i class="fa-solid fa-store text-4xl mb-2 animate-bounce"></i>
                            <h2 class="text-2xl font-black">Đang đến nhà hàng</h2>
                            <p class="text-blue-100 text-sm mt-1">Mã đơn: ${order.orderCode}</p>
                        </div>
                    </c:when>
                    <c:when test="${order.orderStatus == 'PICKED_UP'}">
                        <div class="bg-orange-500 rounded-2xl p-6 text-white text-center shadow-md">
                            <i class="fa-solid fa-motorcycle text-4xl mb-2 animate-bounce"></i>
                            <h2 class="text-2xl font-black">Đang giao đến khách</h2>
                            <p class="text-orange-100 text-sm mt-1">Mã đơn: ${order.orderCode}</p>
                        </div>
                    </c:when>
                </c:choose>
                <div class="bg-white p-4 z-10 shadow-sm border-b border-gray-200 mb-2 rounded-2xl">
                    <label class="block text-xs font-bold text-gray-500 uppercase mb-2">Vị trí hiện tại của bạn</label>
                    <div class="flex gap-2">
                        <button onclick="getGPSLocation()" class="bg-blue-500 text-white px-4 py-2 rounded-xl hover:bg-blue-600 transition shadow-sm flex items-center justify-center shrink-0" title="Dùng GPS hiện tại">
                            <i class="fa-solid fa-location-crosshairs"></i>
                        </button>
                        <input type="text" id="custom-address" placeholder="Hoặc nhập địa chỉ..." class="w-full text-sm border border-gray-200 rounded-xl px-3 py-2 focus:outline-none focus:border-orange-500 shadow-sm">
                        <button onclick="searchAddress()" class="bg-orange-500 text-white px-4 py-2 rounded-xl hover:bg-orange-600 transition shadow-sm flex items-center justify-center shrink-0">
                            <i class="fa-solid fa-magnifying-glass"></i>
                        </button>
                    </div>
                    <p id="tracking-last-updated" class="text-[11px] text-gray-400 mt-2">Chưa có lần cập nhật vị trí nào</p>
                </div>
                <div class="bg-white rounded-2xl p-2 shadow-sm border border-gray-100 relative z-0 mb-2">
                    <div id="map" class="w-full h-64 rounded-xl z-0 relative"></div>

                    <div class="absolute bottom-4 left-4 z-[400] bg-white px-3 py-2 rounded-lg shadow-lg border border-gray-100 flex items-center gap-2">
                        <i class="fa-solid fa-route text-blue-500"></i>
                        <span id="distance-text" class="font-bold text-gray-800 text-sm">Đang tính toán...</span>
                    </div>
                </div>

                <div class="bg-white rounded-2xl p-5 shadow-sm border border-gray-100">
                    <div class="flex justify-between items-center mb-3">
                        <span class="text-xs font-bold text-blue-500 bg-blue-50 px-2 py-1 rounded uppercase tracking-wider">Lấy hàng tại</span>
                    </div>
                    <h3 class="font-bold text-gray-900 text-lg line-clamp-1">${merchant.shopName}</h3>
                    <p class="text-sm text-gray-500 mt-1 line-clamp-2">${merchant.shopAddressLine}</p>
                    <div class="mt-4 flex gap-3">
                        <a href="tel:${merchant.shopPhone}" class="flex-1 bg-gray-50 hover:bg-gray-100 text-gray-700 py-2.5 rounded-xl text-center font-bold text-sm transition border border-gray-200">
                            <i class="fa-solid fa-phone text-green-500 mr-1"></i> Gọi Quán
                        </a>
                    </div>
                </div>

                <div class="bg-white rounded-2xl p-5 shadow-sm border border-gray-100">
                    <div class="flex justify-between items-center mb-3">
                        <span class="text-xs font-bold text-orange-500 bg-orange-50 px-2 py-1 rounded uppercase tracking-wider">Giao hàng đến</span>
                    </div>
                    <h3 class="font-bold text-gray-900 text-lg">${order.receiverName}</h3>
                    <p class="text-sm text-gray-500 mt-1 line-clamp-2">${order.deliveryAddressLine}</p>

                    <div class="mt-4 flex gap-3">
                        <a href="tel:${order.receiverPhone}" class="flex-1 bg-green-500 hover:bg-green-600 text-white py-2.5 rounded-xl text-center font-bold text-sm transition shadow-sm">
                            <i class="fa-solid fa-phone mr-1"></i> Gọi điện
                        </a>
                        <button class="flex-1 bg-blue-500 hover:bg-blue-600 text-white py-2.5 rounded-xl text-center font-bold text-sm transition shadow-sm">
                            <i class="fa-solid fa-message mr-1"></i> Nhắn tin
                        </button>
                    </div>
                </div>

                <div class="pt-4 pb-2 text-center">
                    <a href="${pageContext.request.contextPath}/shipper/report-issue?orderId=${order.id}" class="text-red-500 font-bold text-sm hover:underline flex items-center justify-center gap-1">
                        <i class="fa-solid fa-triangle-exclamation"></i> Báo cáo sự cố đơn hàng
                    </a>
                </div>

            </div>

            <div class="absolute bottom-0 left-0 w-full bg-white p-4 border-t border-gray-200 shadow-[0_-10px_15px_-3px_rgba(0,0,0,0.05)] z-20">
                <form action="${pageContext.request.contextPath}/shipper/order-tracking" method="POST">
                    <input type="hidden" name="orderId" value="${order.id}">

                    <c:choose>
                        <c:when test="${order.orderStatus == 'DELIVERING'}">
                            <input type="hidden" name="action" value="picked_up">
                            <button type="submit" class="w-full bg-blue-600 hover:bg-blue-700 text-white font-black text-lg py-4 rounded-xl transition shadow-xl">
                                XÁC NHẬN ĐÃ LẤY HÀNG
                            </button>
                        </c:when>
                        <c:when test="${order.orderStatus == 'PICKED_UP'}">
                            <input type="hidden" name="action" value="delivered">
                            <button type="submit" class="w-full bg-green-500 hover:bg-green-600 text-white font-black text-lg py-4 rounded-xl transition shadow-xl flex justify-center items-center gap-2">
                                <i class="fa-solid fa-camera"></i> GIAO HÀNG THÀNH CÔNG
                            </button>
                        </c:when>
                    </c:choose>

                </form>
            </div>
            <script>
                let map, shipperMarker, targetMarker, routeLine;
                let lastLocationSyncAt = 0;
                let locationWatchId = null;
                let routeRequestAt = 0;
                let lastRouteLat = null;
                let lastRouteLng = null;
                let isRouting = false;
                let lastTrackingUpdateAt = 0;
                let trackingTickerId = null;
                
                // ĐÃ FIX CHỐNG SẬP: Bọc dấu nháy và dùng parseFloat, dự phòng tọa độ mặc định
                let targetLat = parseFloat('${order.orderStatus == "DELIVERING" ? merchant.latitude : order.latitude}') || 16.0736;
                let targetLng = parseFloat('${order.orderStatus == "DELIVERING" ? merchant.longitude : order.longitude}') || 108.2240;
                const targetName = "${order.orderStatus == 'DELIVERING' ? 'Quán ăn' : 'Khách hàng'}";
                
                document.addEventListener('DOMContentLoaded', function () {
                    // 1. Lấy tọa độ
                    const shopLat = ${not empty merchant.latitude ? merchant.latitude : 10.7769};
                    const shopLng = ${not empty merchant.longitude ? merchant.longitude : 106.7009};
                    
                    const customerLat = ${not empty order.latitude && order.latitude != 0.0 ? order.latitude : 10.7926};
                    const customerLng = ${not empty order.longitude && order.longitude != 0.0 ? order.longitude : 106.6853};
                    
                    // 2. Khởi tạo bản đồ
                    map = L.map('map').setView([shopLat, shopLng], 14);
                    
                    // 3. Load lớp bản đồ (OpenStreetMap)
                    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                        attribution: '© OpenStreetMap contributors'
                    }).addTo(map);
                    
                    // 4. Tạo icon Tùy chỉnh
                    const shopIcon = L.divIcon({
                        html: '<div class="w-8 h-8 bg-blue-500 text-white rounded-full flex items-center justify-center border-2 border-white shadow-lg"><i class="fa-solid fa-store"></i></div>',
                        className: '', iconSize: [32, 32], iconAnchor: [16, 16]
                    });
                    
                    const customerIcon = L.divIcon({
                        html: '<div class="w-8 h-8 bg-orange-500 text-white rounded-full flex items-center justify-center border-2 border-white shadow-lg"><i class="fa-solid fa-house"></i></div>',
                        className: '', iconSize: [32, 32], iconAnchor: [16, 16]
                    });
                    
                    // Gắn Marker
                    L.marker([shopLat, shopLng], {icon: shopIcon}).addTo(map).bindPopup("<b>Lấy hàng tại đây</b>");
                    L.marker([customerLat, customerLng], {icon: customerIcon}).addTo(map).bindPopup("<b>Giao hàng đến đây</b>");
                    
                    // 5. Gọi OSRM API để vẽ đường
                    const osrmUrl = `https://router.project-osrm.org/route/v1/driving/\${shopLng},\${shopLat};\${customerLng},\${customerLat}?overview=full&geometries=geojson`;
                    
                    fetch(osrmUrl)
                    .then(response => response.json())
                    .then(data => {
                        if (data.routes && data.routes.length > 0) {
                            const route = data.routes[0];
                            
                            // Cập nhật text khoảng cách
                            const distanceKm = (route.distance / 1000).toFixed(1);
                            const durationMin = Math.round(route.duration / 60);
                            document.getElementById('distance-text').innerHTML = `\${distanceKm} km • \${durationMin} phút`;
                            
                            // Vẽ đường đi
                            const coordinates = route.geometry.coordinates.map(coord => [coord[1], coord[0]]);
                            const polyline = L.polyline(coordinates, {
                                color: '#3B82F6',
                                weight: 5,
                                opacity: 0.8,
                                dashArray: '10, 10'
                            }).addTo(map);
                            
                            // Zoom bản đồ vừa vặn
                            map.fitBounds(polyline.getBounds(), {padding: [30, 30]});
                        }
                    })
                    .catch(err => {
                        console.error("Lỗi vẽ đường đi: ", err);
                        document.getElementById('distance-text').innerHTML = "Không thể tính khoảng cách";
                    });
                    
                    startLiveTracking();
                    
                    if (trackingTickerId === null) {
                        trackingTickerId = setInterval(renderTrackingLastUpdated, 1000);
                    }
                    renderTrackingLastUpdated();
                });
                
                function renderTrackingLastUpdated() {
                    const label = document.getElementById('tracking-last-updated');
                    if (!label) {
                        return;
                    }
                    if (!lastTrackingUpdateAt) {
                        label.textContent = 'Chưa có lần cập nhật vị trí nào';
                        return;
                    }
                    
                    const sec = Math.max(0, Math.floor((Date.now() - lastTrackingUpdateAt) / 1000));
                    if (sec < 60) {
                        label.textContent = 'Cập nhật vị trí ' + sec + ' giây trước';
                        return;
                    }
                    
                    const min = Math.floor(sec / 60);
                    label.textContent = 'Cập nhật vị trí ' + min + ' phút trước';
                }
                
                function markTrackingUpdatedNow() {
                    lastTrackingUpdateAt = Date.now();
                    renderTrackingLastUpdated();
                }
                
                function toRad(value) {
                    return value * (Math.PI / 180);
                }
                
                function distanceMeters(lat1, lng1, lat2, lng2) {
                    const earthRadius = 6371000;
                    const dLat = toRad(lat2 - lat1);
                    const dLng = toRad(lng2 - lng1);
                    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2)
                    + Math.cos(toRad(lat1)) * Math.cos(toRad(lat2))
                    * Math.sin(dLng / 2) * Math.sin(dLng / 2);
                    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
                    return earthRadius * c;
                }
                
                function animateMarkerTo(marker, lat, lng, durationMs) {
                    const from = marker.getLatLng();
                    const start = performance.now();
                    const duration = Math.max(400, Number(durationMs) || 700);
                    
                    function frame(now) {
                        const progress = Math.min(1, (now - start) / duration);
                        const nextLat = from.lat + (lat - from.lat) * progress;
                        const nextLng = from.lng + (lng - from.lng) * progress;
                        marker.setLatLng([nextLat, nextLng]);
                        if (progress < 1) {
                            requestAnimationFrame(frame);
                        }
                    }
                    
                    requestAnimationFrame(frame);
                }
                
                function shouldRefreshRoute(lat, lng, forceRefresh) {
                    if (forceRefresh || lastRouteLat === null || lastRouteLng === null) {
                        return true;
                    }
                    
                    const moved = distanceMeters(lastRouteLat, lastRouteLng, lat, lng);
                    const ageMs = Date.now() - routeRequestAt;
                    return moved >= 35 || ageMs >= 15000;
                }
                
                function drawRouteFromShipper(lat, lng, forceRefresh) {
                    if (isRouting || !shouldRefreshRoute(lat, lng, forceRefresh)) {
                        return;
                    }
                    
                    isRouting = true;
                    routeRequestAt = Date.now();
                    lastRouteLat = lat;
                    lastRouteLng = lng;
                    
                    const osrmUrl = `https://router.project-osrm.org/route/v1/driving/\${lng},\${lat};\${targetLng},\${targetLat}?overview=full&geometries=geojson`;
                    
                    fetch(osrmUrl)
                    .then(res => res.json())
                    .then(data => {
                        if (!data.routes || data.routes.length === 0) {
                            throw new Error('no-route');
                        }
                        
                        const route = data.routes[0];
                        const distanceKm = (route.distance / 1000).toFixed(1);
                        const durationMin = Math.max(1, Math.round(route.duration / 60));
                        document.getElementById('distance-text').innerHTML = `\${distanceKm} km • ~\${durationMin} phút`;
                        
                        if (routeLine) {
                            map.removeLayer(routeLine);
                        }
                        
                        const coordinates = route.geometry.coordinates.map(coord => [coord[1], coord[0]]);
                        routeLine = L.polyline(coordinates, {color: '#3B82F6', weight: 5, dashArray: '10, 10'}).addTo(map);
                        
                        const bounds = L.latLngBounds([lat, lng], [targetLat, targetLng]);
                        map.fitBounds(bounds, {padding: [50, 50]});
                    })
                    .catch(() => {
                        document.getElementById('distance-text').innerHTML = 'Không thể cập nhật lộ trình';
                    })
                    .finally(() => {
                        isRouting = false;
                    });
                }
                
                function syncLocationToServer(lat, lng, force) {
                    const now = Date.now();
                    if (!force && now - lastLocationSyncAt < 10000) {
                        return;
                    }
                    
                    const body = new URLSearchParams();
                    body.set('latitude', String(lat));
                    body.set('longitude', String(lng));
                    
                    fetch('${pageContext.request.contextPath}/shipper/update-location', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
                        },
                        credentials: 'same-origin',
                        body: body.toString()
                        }).then(function (res) {
                            if (res.ok) {
                                lastLocationSyncAt = now;
                                markTrackingUpdatedNow();
                            }
                            }).catch(function () {
                            });
                        }
                        
                        // Hàm 1: Lấy GPS từ điện thoại/trình duyệt
                        function getGPSLocation() {
                            document.getElementById('distance-text').innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang định vị...';
                            if (navigator.geolocation) {
                                navigator.geolocation.getCurrentPosition(
                                (position) => {
                                    updateShipperLocation(position.coords.latitude, position.coords.longitude, true);
                                },
                                () => {
                                    alert("Vui lòng bật GPS hoặc tự nhập địa chỉ ở thanh phía trên!");
                                    document.getElementById('distance-text').innerHTML = 'Chưa có vị trí';
                                },
                                {
                                    enableHighAccuracy: true,
                                    maximumAge: 0,
                                    timeout: 12000
                                }
                                );
                                } else {
                                    alert("Trình duyệt không hỗ trợ GPS.");
                                }
                            }
                            
                            function startLiveTracking() {
                                if (!navigator.geolocation) {
                                    getGPSLocation();
                                    return;
                                }
                                
                                if (locationWatchId !== null) {
                                    navigator.geolocation.clearWatch(locationWatchId);
                                }
                                
                                locationWatchId = navigator.geolocation.watchPosition(
                                (position) => {
                                    updateShipperLocation(position.coords.latitude, position.coords.longitude, false);
                                },
                                () => {
                                    getGPSLocation();
                                },
                                {
                                    enableHighAccuracy: true,
                                    maximumAge: 7000,
                                    timeout: 15000
                                }
                                );
                            }
                            
                            // Hàm 2: Lấy tọa độ từ địa chỉ gõ tay
                            function searchAddress() {
                                const address = document.getElementById('custom-address').value.trim();
                                if (!address)
                                return alert("Vui lòng nhập địa chỉ!");
                                
                                document.getElementById('distance-text').innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Đang tìm...';
                                
                                const url = `https://nominatim.openstreetmap.org/search?format=json&q=\${encodeURIComponent(address + ", Vietnam")}&limit=1`;
                                
                                fetch(url).then(res => res.json()).then(data => {
                                    if (data.length > 0)
                                    updateShipperLocation(data[0].lat, data[0].lon);
                                    else {
                                        alert("Không tìm thấy địa chỉ này!");
                                        document.getElementById('distance-text').innerHTML = 'Không tìm thấy';
                                    }
                                }).catch(err => alert("Lỗi mạng!"));
                            }
                            
                            // Hàm 3: Cập nhật vị trí Shipper và Vẽ lại đường đi
                            function updateShipperLocation(lat, lng, forceRouteRefresh) {
                                lat = Number(lat);
                                lng = Number(lng);
                                
                                if (Number.isNaN(lat) || Number.isNaN(lng)) {
                                    return;
                                }
                                
                                syncLocationToServer(lat, lng, false);
                                
                                // Cập nhật Marker Shipper
                                if (shipperMarker) {
                                    animateMarkerTo(shipperMarker, lat, lng, 700);
                                    } else {
                                        const shipperIcon = L.divIcon({
                                            html: `<div class="w-10 h-10 bg-blue-500 text-white rounded-full flex items-center justify-center border-2 border-white shadow-lg text-lg"><i class="fa-solid fa-motorcycle"></i></div>`,
                                            className: '', iconSize: [40, 40], iconAnchor: [20, 40]
                                        });
                                        shipperMarker = L.marker([lat, lng], {icon: shipperIcon}).addTo(map).bindPopup("<b>Vị trí của bạn</b>");
                                    }
                                    
                                    drawRouteFromShipper(lat, lng, !!forceRouteRefresh);
                                }
                                
                                window.addEventListener('beforeunload', function () {
                                    if (locationWatchId !== null && navigator.geolocation) {
                                        navigator.geolocation.clearWatch(locationWatchId);
                                        locationWatchId = null;
                                    }
                                    if (trackingTickerId !== null) {
                                        clearInterval(trackingTickerId);
                                        trackingTickerId = null;
                                    }
                                });
                            </script>

                        </body>
                    </html>