<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Theo dõi đơn hàng - ClickEat</title>
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
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
        <style>
            body { font-family: 'Inter', sans-serif; }
            .step-line { width: 2px; background: #e5e7eb; flex-shrink: 0; }
            .step-line.done { background: #22c55e; }
        </style>
    </head>
    <body class="bg-gray-50 flex flex-col min-h-screen">

        <jsp:include page="header.jsp" />

        <main class="flex-grow max-w-3xl mx-auto px-4 sm:px-6 py-10 w-full">

            <%-- Back link --%>
            <a href="${pageContext.request.contextPath}/my-orders" class="inline-flex items-center gap-2 text-sm font-medium text-gray-500 hover:text-orange-500 mb-6 transition-colors">
                <i class="fa-solid fa-arrow-left"></i> Quay về đơn hàng
            </a>

            <%-- Order header --%>
            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 mb-5">
                <div class="flex items-start justify-between mb-4">
                    <div>
                        <p class="text-xs text-gray-400 font-medium mb-1">Mã đơn hàng</p>
                        <h2 class="text-xl font-black text-gray-900">#${order.orderCode}</h2>
                        <p class="text-xs text-gray-400 mt-1">
                            <i class="fa-regular fa-clock mr-1"></i>Đặt lúc <fmt:formatDate value="${order.createdAt}" pattern="HH:mm, dd/MM/yyyy"/>
                        </p>
                    </div>
                    <%-- Final status badge --%>
                    <c:choose>
                        <c:when test="${order.orderStatus == 'DELIVERED'}">
                            <span class="bg-green-100 text-green-700 text-sm font-bold px-4 py-2 rounded-full">
                                <i class="fa-solid fa-circle-check mr-1"></i>Giao thành công
                            </span>
                        </c:when>
                        <c:when test="${order.orderStatus == 'CANCELLED' || order.orderStatus == 'MERCHANT_REJECTED' || order.orderStatus == 'FAILED'}">
                            <span class="bg-red-100 text-red-600 text-sm font-bold px-4 py-2 rounded-full">
                                <i class="fa-solid fa-xmark-circle mr-1"></i>Đã hủy
                            </span>
                        </c:when>
                        <c:otherwise>
                            <span class="bg-blue-100 text-blue-700 text-sm font-bold px-4 py-2 rounded-full animate-pulse">
                                <i class="fa-solid fa-motorcycle mr-1"></i>Đang xử lý
                            </span>
                        </c:otherwise>
                    </c:choose>
                </div>

                <%-- Delivery address --%>
                <div class="bg-gray-50 rounded-xl p-4 flex items-start gap-3">
                    <i class="fa-solid fa-location-dot text-orange-500 mt-0.5"></i>
                    <div>
                        <p class="text-sm font-bold text-gray-900">${order.receiverName}  •  ${order.receiverPhone}</p>
                        <p class="text-xs text-gray-500 mt-0.5">${order.deliveryAddressLine}, ${order.wardName}, ${order.districtName}, ${order.provinceName}</p>
                        <c:if test="${not empty order.deliveryNote}">
                            <p class="text-xs text-gray-400 mt-1 italic">"${order.deliveryNote}"</p>
                        </c:if>
                    </div>
                </div>
            </div>

            <%-- Steps timeline --%>
            <c:set var="s" value="${order.orderStatus}"/>
            <c:set var="done1" value="${s == 'CREATED' || s == 'MERCHANT_ACCEPTED' || s == 'PREPARING' || s == 'READY_FOR_PICKUP' || s == 'DELIVERING' || s == 'PICKED_UP' || s == 'DELIVERED'}"/>
            <c:set var="done2" value="${s == 'MERCHANT_ACCEPTED' || s == 'PREPARING' || s == 'READY_FOR_PICKUP' || s == 'DELIVERING' || s == 'PICKED_UP' || s == 'DELIVERED'}"/>
            <c:set var="done3" value="${s == 'READY_FOR_PICKUP' || s == 'DELIVERING' || s == 'PICKED_UP' || s == 'DELIVERED'}"/>
            <c:set var="done4" value="${s == 'DELIVERED' || s == 'PICKED_UP' || s == 'DELIVERING'}"/>
            <c:set var="done5" value="${s == 'DELIVERED'}"/>
            <c:set var="cancelled" value="${s == 'CANCELLED' || s == 'MERCHANT_REJECTED' || s == 'FAILED'}"/>

            <c:if test="${!cancelled}">
                <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 mb-5">
                    <h3 class="font-bold text-gray-900 mb-6 flex items-center gap-2">
                        <i class="fa-solid fa-timeline text-orange-500"></i> Trạng thái đơn hàng
                    </h3>
                    <div class="space-y-0">
                        <%-- Step macro using include pattern --%>
                        <div class="flex gap-4 items-start">
                            <div class="flex flex-col items-center">
                                <div class="w-9 h-9 rounded-full flex items-center justify-center flex-shrink-0 ${done1 ? 'bg-green-500 text-white' : 'bg-gray-100 text-gray-400'}">
                                    <i class="fa-solid fa-check text-sm"></i>
                                </div>
                                <div class="step-line ${done2 ? 'done' : ''} h-10 mt-1"></div>
                            </div>
                            <div class="pt-1 pb-8">
                                <p class="font-bold text-sm ${done1 ? 'text-gray-900' : 'text-gray-400'}">Đặt hàng thành công</p>
                                <c:if test="${done1}"><p class="text-xs text-gray-400 mt-0.5"><fmt:formatDate value="${order.createdAt}" pattern="HH:mm dd/MM"/></p></c:if>
                                </div>
                            </div>
                            <div class="flex gap-4 items-start">
                                <div class="flex flex-col items-center">
                                    <div class="w-9 h-9 rounded-full flex items-center justify-center flex-shrink-0 ${done2 ? 'bg-green-500 text-white' : 'bg-gray-100 text-gray-400'}">
                                        <i class="fa-solid fa-store text-sm"></i>
                                    </div>
                                    <div class="step-line ${done3 ? 'done' : ''} h-10 mt-1"></div>
                                </div>
                                <div class="pt-1 pb-8">
                                    <p class="font-bold text-sm ${done2 ? 'text-gray-900' : 'text-gray-400'}">Quán đã nhận đơn</p>
                                    <c:if test="${done2 && not empty order.acceptedAt}"><p class="text-xs text-gray-400 mt-0.5"><fmt:formatDate value="${order.acceptedAt}" pattern="HH:mm dd/MM"/></p></c:if>
                                    </div>
                                </div>
                                <div class="flex gap-4 items-start">
                                    <div class="flex flex-col items-center">
                                        <div class="w-9 h-9 rounded-full flex items-center justify-center flex-shrink-0 ${done3 ? 'bg-green-500 text-white' : 'bg-gray-100 text-gray-400'}">
                                            <i class="fa-solid fa-fire-burner text-sm"></i>
                                        </div>
                                        <div class="step-line ${done4 ? 'done' : ''} h-10 mt-1"></div>
                                    </div>
                                    <div class="pt-1 pb-8">
                                        <p class="font-bold text-sm ${done3 ? 'text-gray-900' : 'text-gray-400'}">Đang chuẩn bị / Sẵn sàng giao</p>
                                        <c:if test="${done3 && not empty order.readyAt}"><p class="text-xs text-gray-400 mt-0.5"><fmt:formatDate value="${order.readyAt}" pattern="HH:mm dd/MM"/></p></c:if>
                                        </div>
                                    </div>
                                    <div class="flex gap-4 items-start">
                                        <div class="flex flex-col items-center">
                                            <div class="w-9 h-9 rounded-full flex items-center justify-center flex-shrink-0 ${done4 ? 'bg-green-500 text-white' : 'bg-gray-100 text-gray-400'}">
                                                <i class="fa-solid fa-motorcycle text-sm"></i>
                                            </div>
                                            <div class="step-line ${done5 ? 'done' : ''} h-10 mt-1"></div>
                                        </div>
                                        <div class="pt-1 pb-8">
                                            <p class="font-bold text-sm ${done4 ? 'text-gray-900' : 'text-gray-400'}">Shipper đang giao hàng</p>
                                            <c:if test="${done4 && not empty order.pickedUpAt}"><p class="text-xs text-gray-400 mt-0.5"><fmt:formatDate value="${order.pickedUpAt}" pattern="HH:mm dd/MM"/></p></c:if>
                                            </div>
                                        </div>
                                        <div class="flex gap-4 items-start">
                                            <div class="flex flex-col items-center">
                                                <div class="w-9 h-9 rounded-full flex items-center justify-center flex-shrink-0 ${done5 ? 'bg-green-500 text-white shadow-lg' : 'bg-gray-100 text-gray-400'}">
                                                    <i class="fa-solid fa-house text-sm"></i>
                                                </div>
                                            </div>
                                            <div class="pt-1">
                                                <p class="font-bold text-sm ${done5 ? 'text-green-600' : 'text-gray-400'}">Giao hàng thành công</p>
                                                <c:if test="${done5 && not empty order.deliveredAt}"><p class="text-xs text-gray-400 mt-0.5"><fmt:formatDate value="${order.deliveredAt}" pattern="HH:mm dd/MM"/></p></c:if>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </c:if>

                                <%-- Items --%>
                                <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-6 mb-5">
                                    <h3 class="font-bold text-gray-900 mb-4 flex items-center gap-2">
                                        <i class="fa-solid fa-utensils text-orange-500"></i> Chi tiết đơn hàng
                                        <span class="text-xs bg-gray-100 text-gray-500 px-2 py-0.5 rounded-full font-medium">${not empty order.shopName ? order.shopName : ''}</span>
                                    </h3>

                                    <div class="divide-y divide-gray-50">
                                        <c:forEach var="item" items="${items}">
                                            <div class="flex items-center justify-between py-3">
                                                <div class="flex items-center gap-3">
                                                    <span class="bg-orange-100 text-orange-600 text-xs font-black w-6 h-6 rounded-lg flex items-center justify-center flex-shrink-0">${item.quantity}</span>
                                                    <span class="text-sm font-semibold text-gray-800">${item.itemNameSnapshot}</span>
                                                    <c:if test="${not empty item.note}">
                                                        <span class="text-xs text-gray-400 italic">(${item.note})</span>
                                                    </c:if>
                                                </div>
                                                <span class="text-sm font-bold text-gray-700">
                                                    <fmt:formatNumber value="${item.unitPriceSnapshot * item.quantity}" type="number" maxFractionDigits="0"/>đ
                                                    </span>
                                                </div>
                                            </c:forEach>
                                        </div>

                                        <div class="mt-4 pt-4 border-t border-gray-100 space-y-2">
                                            <div class="flex justify-between text-sm text-gray-500">
                                                <span>Tạm tính</span>
                                                <span><fmt:formatNumber value="${order.subtotalAmount}" type="number" maxFractionDigits="0"/>đ</span>
                                            </div>
                                            <div class="flex justify-between text-sm text-gray-500">
                                                <span>Phí giao hàng</span>
                                                <span><fmt:formatNumber value="${order.deliveryFee}" type="number" maxFractionDigits="0"/>đ</span>
                                            </div>
                                            <c:if test="${order.discountAmount > 0}">
                                                <div class="flex justify-between text-sm text-green-600">
                                                    <span>Giảm giá</span>
                                                    <span>-<fmt:formatNumber value="${order.discountAmount}" type="number" maxFractionDigits="0"/>đ</span>
                                                </div>
                                            </c:if>
                                            <div class="flex justify-between font-black text-gray-900 text-lg pt-2 border-t border-dashed border-gray-200 mt-2">
                                                <span>Tổng cộng</span>
                                                <span class="text-orange-500"><fmt:formatNumber value="${order.totalAmount}" type="number" maxFractionDigits="0"/>đ</span>
                                            </div>
                                        </div>
                                    </div>

                                    <%-- Rating form (only for DELIVERED + not yet rated) --%>
                                    <c:if test="${order.orderStatus == 'DELIVERED' && !hasRatedMerchant}">
                                        <div class="bg-white rounded-2xl border border-orange-200 shadow-sm p-6 mb-5">
                                            <h3 class="font-bold text-gray-900 mb-1 flex items-center gap-2">
                                                <i class="fa-solid fa-star text-yellow-400"></i> Đánh giá trải nghiệm
                                            </h3>
                                            <p class="text-xs text-gray-400 mb-5">Chia sẻ cảm nhận của bạn về "${not empty order.shopName ? order.shopName : 'nhà hàng'}"</p>

                                            <form action="${pageContext.request.contextPath}/rate-order" method="POST">
                                                <input type="hidden" name="orderId" value="${order.id}">

                                                <%-- Star selector --%>
                                                <div class="flex items-center gap-2 mb-4" id="starRating">
                                                    <c:forEach begin="1" end="5" var="i">
                                                        <button type="button" onclick="setRating(${i})"
                                                        class="star-btn text-3xl text-gray-200 hover:text-yellow-400 transition-colors"
                                                        data-value="${i}">
                                                        <i class="fa-solid fa-star"></i>
                                                    </button>
                                                </c:forEach>
                                                <span id="ratingLabel" class="text-sm text-gray-400 ml-2">Chọn số sao</span>
                                            </div>
                                            <input type="hidden" name="stars" id="starsInput" value="0">

                                            <textarea name="comment" rows="3" placeholder="Chia sẻ nhận xét của bạn (tùy chọn)..."
                                            class="w-full border border-gray-200 rounded-xl px-4 py-3 text-sm text-gray-700 focus:outline-none focus:border-orange-400 focus:ring-1 focus:ring-orange-300 resize-none mb-4"></textarea>

                                            <button type="submit" id="submitRating"
                                            class="w-full bg-orange-500 hover:bg-orange-600 text-white font-bold py-3 rounded-xl transition-colors shadow-sm disabled:opacity-50 disabled:cursor-not-allowed text-sm"
                                            disabled>
                                            <i class="fa-solid fa-paper-plane mr-2"></i>Gửi đánh giá
                                        </button>
                                    </form>
                                </div>
                            </c:if>

                            <c:if test="${order.orderStatus == 'DELIVERED' && hasRatedMerchant}">
                                <div class="bg-green-50 border border-green-200 rounded-2xl p-5 text-center">
                                    <i class="fa-solid fa-circle-check text-green-500 text-2xl mb-2"></i>
                                    <p class="text-sm font-bold text-green-700">Bạn đã đánh giá đơn hàng này. Cảm ơn!</p>
                                </div>
                            </c:if>

                        </main>

                        <jsp:include page="footer.jsp" />

                        <script>
                            const labels = ['', 'Rất tệ', 'Chưa tốt', 'Bình thường', 'Tốt', 'Tuyệt vời!'];
                            function setRating(val) {
                                document.getElementById('starsInput').value = val;
                                document.getElementById('ratingLabel').textContent = labels[val];
                                document.querySelectorAll('.star-btn').forEach(function(btn) {
                                    const v = parseInt(btn.getAttribute('data-value'));
                                    btn.querySelector('i').style.color = v <= val ? '#facc15' : '#d1d5db';
                                });
                                document.getElementById('submitRating').disabled = false;
                            }
                        </script>
                    </body>
                </html>
