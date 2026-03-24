<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ClickEat - Lịch sử đơn hàng</title>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <link rel="shortcut icon" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
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
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>
            </section>
        </div>
    </main>
</body>
</html>