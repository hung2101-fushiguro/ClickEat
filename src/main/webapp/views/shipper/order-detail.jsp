<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Chi tiết Đơn hàng - ClickEat</title>
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
        <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css" />
        <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
        <style>body { font-family: 'Inter', sans-serif; }</style>
    </head>
    <body class="bg-gray-100 flex justify-center min-h-screen">

        <div class="bg-gray-50 w-full max-w-md shadow-2xl flex flex-col h-screen relative">

            <div class="bg-white px-4 py-4 flex items-center justify-between shadow-sm z-10 sticky top-0 border-b border-gray-100">
                <a href="${pageContext.request.contextPath}/shipper/dashboard" class="w-10 h-10 flex items-center justify-center text-gray-700 hover:bg-gray-100 rounded-full transition">
                    <i class="fa-solid fa-arrow-left text-xl"></i>
                </a>
                <h1 class="text-lg font-black text-gray-900">Chi tiết đơn hàng</h1>
                <div class="w-10"></div>
            </div>

            <div class="flex-1 overflow-y-auto p-4 space-y-4 pb-32">

                <div class="bg-orange-500 rounded-2xl p-6 text-white text-center shadow-md relative overflow-hidden">
                    <div class="absolute inset-0 bg-[url('https://www.transparenttextures.com/patterns/diagonal-stripes.png')] opacity-20"></div>
                    <div class="relative z-10">
                        <p class="text-orange-100 text-sm font-bold uppercase tracking-wider mb-1">Thu nhập dự kiến</p>
                        <h2 class="text-4xl font-black"><fmt:formatNumber value="${order.deliveryFee}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></h2>
                        <p class="text-sm mt-2 font-medium bg-orange-600/50 inline-block px-3 py-1 rounded-full">Mã: ${order.orderCode}</p>
                    </div>
                </div>

                <div class="bg-white rounded-2xl p-2 shadow-sm border border-gray-100 relative z-0">
                    <div id="map" class="w-full h-56 rounded-xl z-0 relative"></div>
                    <div class="absolute bottom-4 left-4 z-[400] bg-white px-3 py-2 rounded-lg shadow-lg border border-gray-100 flex items-center gap-2">
                        <i class="fa-solid fa-route text-orange-500"></i>
                        <span id="distance-text" class="font-bold text-gray-800 text-sm">Đang tính toán...</span>
                    </div>
                </div>

                <div class="bg-white rounded-2xl p-5 shadow-sm border border-gray-100 space-y-4 relative">
                    <div class="absolute left-8 top-10 bottom-10 w-0.5 border-l-2 border-dashed border-gray-200"></div>

                    <div class="flex gap-4 relative">
                        <div class="w-6 h-6 bg-blue-100 text-blue-500 rounded-full flex items-center justify-center shrink-0 z-10 mt-1">
                            <i class="fa-solid fa-store text-xs"></i>
                        </div>
                        <div>
                            <p class="text-xs font-bold text-gray-400 uppercase">Lấy hàng tại</p>
                            <h4 class="font-bold text-gray-900 text-lg line-clamp-1">${merchant.shopName}</h4>
                            <p class="text-sm text-gray-600 line-clamp-2 mt-1">${merchant.shopAddressLine}</p>
                        </div>
                    </div>

                    <div class="flex gap-4 relative pt-2">
                        <div class="w-6 h-6 bg-orange-100 text-orange-500 rounded-full flex items-center justify-center shrink-0 z-10 mt-1">
                            <i class="fa-solid fa-house text-xs"></i>
                        </div>
                        <div>
                            <p class="text-xs font-bold text-gray-400 uppercase">Giao hàng đến</p>
                            <h4 class="font-bold text-gray-900 text-lg">${order.receiverName}</h4>
                            <p class="text-sm text-gray-600 line-clamp-2 mt-1">${order.deliveryAddressLine}</p>
                        </div>
                    </div>
                </div>

                <div class="bg-white rounded-2xl p-5 shadow-sm border border-gray-100">
                    <h3 class="font-bold text-gray-900 mb-3 text-sm uppercase tracking-wider">Thông tin đơn hàng</h3>
                    <div class="flex justify-between text-sm mb-2 text-gray-600">
                        <span>Tổng tiền món:</span>
                        <span class="font-bold text-gray-900"><fmt:formatNumber value="${order.subtotalAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></span>
                    </div>
                    <div class="flex justify-between text-sm mb-2 text-gray-600">
                        <span>Phương thức thanh toán:</span>
                        <span class="font-bold text-green-600">${order.paymentMethod == 'CASH' ? 'Tiền mặt' : 'Chuyển khoản'}</span>
                    </div>
                    <div class="flex justify-between text-sm pt-2 border-t border-gray-100">
                        <span class="font-bold text-gray-900">Khách phải trả:</span>
                        <span class="font-black text-orange-500 text-lg"><fmt:formatNumber value="${order.totalAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></span>
                    </div>
                </div>

            </div>
            <div class="absolute bottom-0 left-0 w-full bg-white p-4 border-t border-gray-200 shadow-[0_-10px_15px_-3px_rgba(0,0,0,0.05)] z-20">
                <c:choose>
                    <c:when test="${order.shipperUserId == 0}">
                        <form action="${pageContext.request.contextPath}/shipper/order-detail" method="POST">
                            <input type="hidden" name="orderId" value="${order.id}">
                            <button type="submit" class="w-full bg-orange-500 hover:bg-orange-600 text-white font-black text-xl py-4 rounded-xl transition shadow-xl flex justify-center items-center gap-2">
                                NHẬN ĐƠN NÀY <i class="fa-solid fa-arrow-right"></i>
                            </button>
                        </form>
                    </c:when>
                    <c:otherwise>
                        <div class="flex gap-3">
                            <c:if test="${order.orderStatus.trim() == 'DELIVERING'}">
                                <form action="${pageContext.request.contextPath}/shipper/order-detail" method="POST" class="w-1/3">
                                    <input type="hidden" name="orderId" value="${order.id}">
                                    <input type="hidden" name="action" value="yield">
                                    <button type="submit" class="w-full h-full bg-red-50 hover:bg-red-100 text-red-500 font-bold text-sm py-2 rounded-xl transition border border-red-200 flex flex-col items-center justify-center" onclick="confirmAction(event, 'Bạn có chắc chắn muốn nhường đơn này không?', this);">
                                        <i class="fa-solid fa-rotate-left mb-1"></i> Nhường đơn
                                    </button>
                                </form>
                            </c:if>

                            <a href="${pageContext.request.contextPath}/shipper/order-tracking?id=${order.id}" class="flex-1 bg-green-500 hover:bg-green-600 text-white font-black text-lg py-4 rounded-xl transition shadow-xl flex justify-center items-center gap-2">
                                ĐẾN TRANG GIAO <i class="fa-solid fa-arrow-right"></i>
                            </a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
        <div id="custom-confirm-modal" class="fixed inset-0 bg-black/60 z-[100] hidden flex items-center justify-center backdrop-blur-sm transition-opacity">
            <div class="bg-white rounded-3xl w-full max-w-sm p-6 shadow-2xl relative text-center transform transition-all scale-95 opacity-0 duration-200" id="confirm-modal-content">
                <div class="w-16 h-16 bg-orange-100 text-orange-500 rounded-full flex items-center justify-center text-3xl mx-auto mb-4">
                    <i class="fa-solid fa-circle-exclamation animate-pulse"></i>
                </div>
                <h3 class="text-xl font-black text-gray-900 mb-2">Xác nhận hành động</h3>
                <p id="confirm-message" class="text-gray-500 mb-6 font-medium">Bạn có chắc chắn không?</p>

                <div class="flex gap-3">
                    <button onclick="closeConfirmModal()" type="button" class="flex-1 bg-gray-100 hover:bg-gray-200 text-gray-700 font-bold py-3 rounded-xl transition">Hủy bỏ</button>
                    <button onclick="executeConfirm()" type="button" class="flex-1 bg-orange-500 hover:bg-orange-600 text-white font-bold py-3 rounded-xl transition shadow-md">Xác nhận</button>
                </div>
            </div>
        </div>

        <script>
            document.addEventListener('DOMContentLoaded', function () {
                // Lấy tọa độ
                const shopLat = ${not empty merchant.latitude ? merchant.latitude : 10.7769};
                const shopLng = ${not empty merchant.longitude ? merchant.longitude : 106.7009};
                
                const customerLat = ${not empty order.latitude && order.latitude != 0.0 ? order.latitude : 10.7926};
                const customerLng = ${not empty order.longitude && order.longitude != 0.0 ? order.longitude : 106.6853};
                
                const map = L.map('map').setView([shopLat, shopLng], 14);
                
                L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                    attribution: '© OpenStreetMap',
                    maxZoom: 19
                }).addTo(map);
                
                const shopIcon = L.divIcon({
                    html: '<div class="w-6 h-6 bg-blue-500 text-white rounded-full flex items-center justify-center border-2 border-white shadow-md"><i class="fa-solid fa-store text-xs"></i></div>',
                    className: '', iconSize: [24, 24], iconAnchor: [12, 12]
                });
                
                const customerIcon = L.divIcon({
                    html: '<div class="w-6 h-6 bg-orange-500 text-white rounded-full flex items-center justify-center border-2 border-white shadow-md"><i class="fa-solid fa-house text-xs"></i></div>',
                    className: '', iconSize: [24, 24], iconAnchor: [12, 12]
                });
                
                L.marker([shopLat, shopLng], {icon: shopIcon}).addTo(map);
                L.marker([customerLat, customerLng], {icon: customerIcon}).addTo(map);
                
                const osrmUrl = `https://router.project-osrm.org/route/v1/driving/\${shopLng},\${shopLat};\${customerLng},\${customerLat}?overview=full&geometries=geojson`;
                
                fetch(osrmUrl)
                .then(response => response.json())
                .then(data => {
                    if (data.routes && data.routes.length > 0) {
                        const route = data.routes[0];
                        const distanceKm = (route.distance / 1000).toFixed(1);
                        const durationMin = Math.round(route.duration / 60);
                        document.getElementById('distance-text').innerHTML = `\${distanceKm} km • \${durationMin} phút`;
                        
                        const coordinates = route.geometry.coordinates.map(coord => [coord[1], coord[0]]);
                        const polyline = L.polyline(coordinates, {
                            color: '#f97316', // Cam
                            weight: 4,
                            opacity: 0.8,
                            dashArray: '8, 8'
                        }).addTo(map);
                        
                        map.fitBounds(polyline.getBounds(), {padding: [20, 20]});
                    }
                });
            });
        </script>
        <script>
            
            let targetAction = null; // Biến lưu trữ hành động đang chờ xác nhận
            
            // Hàm gọi Popblock hiện lên
            function confirmAction(event, message, element) {
                event.preventDefault(); // Chặn hành động mặc định ngay lập tức (chặn form submit / chặn link)
                
                // Xác định xem người dùng đang bấm vào Form hay thẻ Link <a>
                if (element.tagName === 'A') {
                    targetAction = {type: 'link', data: element.href};
                    } else if (element.form) {
                        targetAction = {type: 'form', data: element.form}; // Dùng cho <button type="submit">
                        } else if (element.tagName === 'FORM') {
                            targetAction = {type: 'form', data: element};
                        }
                        
                        // Cập nhật câu chữ và tạo hiệu ứng bật lên
                        document.getElementById('confirm-message').innerText = message;
                        const modal = document.getElementById('custom-confirm-modal');
                        const content = document.getElementById('confirm-modal-content');
                        
                        modal.classList.remove('hidden');
                        setTimeout(() => {
                            content.classList.remove('scale-95', 'opacity-0');
                            content.classList.add('scale-100', 'opacity-100');
                        }, 10);
                    }
                    
                    // Hàm tắt Popblock
                    function closeConfirmModal() {
                        const modal = document.getElementById('custom-confirm-modal');
                        const content = document.getElementById('confirm-modal-content');
                        
                        content.classList.remove('scale-100', 'opacity-100');
                        content.classList.add('scale-95', 'opacity-0');
                        
                        setTimeout(() => {
                            modal.classList.add('hidden');
                            targetAction = null; // Xóa dữ liệu chờ
                        }, 200);
                    }
                    
                    // Hàm thực thi khi người dùng bấm "Xác nhận"
                    function executeConfirm() {
                        if (!targetAction)
                        return;
                        
                        if (targetAction.type === 'form') {
                            targetAction.data.submit(); // Cho phép form gửi đi
                            } else if (targetAction.type === 'link') {
                                window.location.href = targetAction.data; // Cho phép link chuyển hướng
                            }
                        }
                    </script>
                </body>
            </html>