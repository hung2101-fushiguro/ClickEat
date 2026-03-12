<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Đơn hàng của tôi - ClickEat</title>
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
        <style>body { font-family: 'Inter', sans-serif; }</style>
    </head>
    <body class="bg-gray-50 flex flex-col min-h-screen">

        <jsp:include page="header.jsp" />

        <main class="flex-grow max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-10 w-full">

            <div class="flex items-center justify-between mb-8">
                <h1 class="text-2xl font-bold text-gray-900">Đơn hàng của tôi</h1>
                <a href="${pageContext.request.contextPath}/home" class="text-sm text-orange-500 font-semibold hover:text-orange-600 transition-colors">
                    <i class="fa-solid fa-plus mr-1"></i> Đặt thêm
                </a>
            </div>

            <%-- Filter tabs --%>
            <div class="flex gap-2 mb-6 bg-white rounded-2xl p-1 shadow-sm border border-gray-100 w-fit">
                <a href="?status=all"
                   class="px-4 py-2 rounded-xl text-sm font-semibold transition-colors
                          ${statusFilter == 'all' || empty statusFilter ? 'bg-orange-500 text-white shadow' : 'text-gray-500 hover:text-gray-700'}">
                    Tất cả
                </a>
                <a href="?status=active"
                   class="px-4 py-2 rounded-xl text-sm font-semibold transition-colors
                          ${statusFilter == 'active' ? 'bg-orange-500 text-white shadow' : 'text-gray-500 hover:text-gray-700'}">
                    Đang giao
                </a>
                <a href="?status=DELIVERED"
                   class="px-4 py-2 rounded-xl text-sm font-semibold transition-colors
                          ${statusFilter == 'DELIVERED' ? 'bg-orange-500 text-white shadow' : 'text-gray-500 hover:text-gray-700'}">
                    Hoàn thành
                </a>
                <a href="?status=cancelled"
                   class="px-4 py-2 rounded-xl text-sm font-semibold transition-colors
                          ${statusFilter == 'cancelled' ? 'bg-orange-500 text-white shadow' : 'text-gray-500 hover:text-gray-700'}">
                    Đã hủy
                </a>
            </div>

            <%-- Empty state --%>
            <c:if test="${empty orders}">
                <div class="bg-white rounded-2xl border border-dashed border-gray-200 p-14 text-center">
                    <i class="fa-solid fa-receipt text-6xl text-gray-200 mb-4"></i>
                    <h2 class="text-lg font-bold text-gray-700 mb-2">Chưa có đơn hàng nào</h2>
                    <p class="text-gray-400 text-sm mb-6">Hãy đặt món ăn yêu thích của bạn ngay!</p>
                    <a href="${pageContext.request.contextPath}/home"
                       class="inline-block bg-orange-500 text-white px-6 py-3 rounded-xl font-bold text-sm hover:bg-orange-600 transition-colors shadow-sm">
                        Khám phá thực đơn
                    </a>
                </div>
            </c:if>

            <%-- Order list --%>
            <div class="space-y-4">
                <c:forEach var="order" items="${orders}">
                    <div class="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden hover:shadow-md transition-shadow">

                        <%-- Header row --%>
                        <div class="flex items-center justify-between px-6 py-4 border-b border-gray-50">
                            <div class="flex items-center gap-3">
                                <div class="w-10 h-10 bg-orange-50 rounded-xl flex items-center justify-center">
                                    <i class="fa-solid fa-store text-orange-500"></i>
                                </div>
                                <div>
                                    <p class="font-bold text-gray-900 text-sm">${not empty order.shopName ? order.shopName : 'Nhà hàng'}</p>
                                    <p class="text-xs text-gray-400 font-medium">#${order.orderCode}</p>
                                </div>
                            </div>
                            <%-- Status badge --%>
                            <c:choose>
                                <c:when test="${order.orderStatus == 'CREATED'}">
                                    <span class="bg-yellow-100 text-yellow-700 text-xs font-bold px-3 py-1.5 rounded-full">
                                        <i class="fa-solid fa-clock mr-1"></i>Chờ quán nhận
                                    </span>
                                </c:when>
                                <c:when test="${order.orderStatus == 'MERCHANT_ACCEPTED' || order.orderStatus == 'PREPARING'}">
                                    <span class="bg-blue-100 text-blue-700 text-xs font-bold px-3 py-1.5 rounded-full">
                                        <i class="fa-solid fa-fire-burner mr-1"></i>Đang chuẩn bị
                                    </span>
                                </c:when>
                                <c:when test="${order.orderStatus == 'READY_FOR_PICKUP' || order.orderStatus == 'DELIVERING' || order.orderStatus == 'PICKED_UP'}">
                                    <span class="bg-indigo-100 text-indigo-700 text-xs font-bold px-3 py-1.5 rounded-full">
                                        <i class="fa-solid fa-motorcycle mr-1"></i>Đang giao
                                    </span>
                                </c:when>
                                <c:when test="${order.orderStatus == 'DELIVERED'}">
                                    <span class="bg-green-100 text-green-700 text-xs font-bold px-3 py-1.5 rounded-full">
                                        <i class="fa-solid fa-circle-check mr-1"></i>Đã giao
                                    </span>
                                </c:when>
                                <c:otherwise>
                                    <span class="bg-red-100 text-red-600 text-xs font-bold px-3 py-1.5 rounded-full">
                                        <i class="fa-solid fa-xmark mr-1"></i>Đã hủy
                                    </span>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <%-- Body --%>
                        <div class="px-6 py-4 flex items-center justify-between">
                            <div class="flex items-center gap-6 text-sm text-gray-500">
                                <span>
                                    <i class="fa-regular fa-calendar text-gray-300 mr-1"></i>
                                    <fmt:formatDate value="${order.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                </span>
                                <span class="font-black text-gray-900 text-base">
                                    <fmt:formatNumber value="${order.totalAmount}" type="number" maxFractionDigits="0"/>đ
                                </span>
                            </div>

                            <%-- Actions --%>
                            <div class="flex items-center gap-2">
                                <a href="${pageContext.request.contextPath}/track-order?id=${order.id}"
                                   class="bg-orange-500 hover:bg-orange-600 text-white text-xs font-bold px-4 py-2 rounded-xl transition-colors shadow-sm">
                                    <i class="fa-solid fa-location-arrow mr-1"></i>
                                    <c:choose>
                                        <c:when test="${order.orderStatus == 'DELIVERED'}">Xem chi tiết</c:when>
                                        <c:otherwise>Theo dõi</c:otherwise>
                                    </c:choose>
                                </a>
                                <c:if test="${order.orderStatus == 'CREATED'}">
                                    <form action="${pageContext.request.contextPath}/my-orders" method="POST"
                                          onsubmit="return confirm('Bạn chắc chắn muốn hủy đơn hàng này?');">
                                        <input type="hidden" name="action" value="CANCEL">
                                        <input type="hidden" name="orderId" value="${order.id}">
                                        <button type="submit"
                                                class="bg-red-50 hover:bg-red-100 text-red-600 text-xs font-bold px-4 py-2 rounded-xl transition-colors border border-red-100">
                                            Hủy đơn
                                        </button>
                                    </form>
                                </c:if>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </main>

        <jsp:include page="footer.jsp" />
    </body>
</html>
