<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>${merchant.shopName} - ClickEat</title>
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
            .star-filled { color: #facc15; }
        </style>
    </head>
    <body class="bg-gray-50 flex flex-col min-h-screen">

        <jsp:include page="header.jsp" />

        <%-- Hero --%>
        <div class="bg-white border-b border-gray-100">
            <div class="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
                <div class="flex items-start gap-6">
                    <div class="w-24 h-24 rounded-2xl bg-orange-50 flex items-center justify-center overflow-hidden flex-shrink-0 border border-orange-100 shadow-sm">
                        <c:choose>
                            <c:when test="${not empty merchant.shopAvatar}">
                                <img src="${merchant.shopAvatar}" class="w-full h-full object-cover" alt="${merchant.shopName}">
                            </c:when>
                            <c:otherwise>
                                <i class="fa-solid fa-store text-4xl text-orange-300"></i>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div class="flex-1">
                        <h1 class="text-2xl font-black text-gray-900 mb-1">${merchant.shopName}</h1>
                        <div class="flex items-center gap-4 text-sm text-gray-500 mb-2 flex-wrap">
                            <span class="flex items-center gap-1">
                                <i class="fa-solid fa-star text-yellow-400"></i>
                                <strong class="text-gray-800"><fmt:formatNumber value="${avgRating}" maxFractionDigits="1"/></strong>
                                <span class="text-gray-400">(${totalRatings} đánh giá)</span>
                            </span>
                            <span class="flex items-center gap-1">
                                <i class="fa-solid fa-bowl-rice text-orange-400"></i>
                                <span>${fn:length(foods)} món</span>
                            </span>
                            <c:if test="${not empty merchant.shopPhone}">
                                <span class="flex items-center gap-1">
                                    <i class="fa-solid fa-phone text-gray-400"></i>
                                    <span>${merchant.shopPhone}</span>
                                </span>
                            </c:if>
                        </div>
                        <p class="text-sm text-gray-500 flex items-start gap-1">
                            <i class="fa-solid fa-location-dot text-orange-400 mt-0.5 flex-shrink-0"></i>
                            ${merchant.shopAddressLine}<c:if test="${not empty merchant.districtName}">, ${merchant.districtName}</c:if><c:if test="${not empty merchant.provinceName}">, ${merchant.provinceName}</c:if>
                        </p>
                        <c:if test="${not empty merchant.shopDescription}">
                            <p class="text-sm text-gray-400 mt-2 italic">${merchant.shopDescription}</p>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>

        <main class="flex-grow max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-8 w-full">
            <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">

                <%-- Menu section --%>
                <div class="lg:col-span-2">
                    <h2 class="text-lg font-bold text-gray-900 mb-4 flex items-center gap-2">
                        <i class="fa-solid fa-utensils text-orange-500"></i> Thực đơn
                    </h2>

                    <c:if test="${empty foods}">
                        <div class="bg-white rounded-2xl border border-dashed border-gray-200 p-10 text-center">
                            <i class="fa-solid fa-box-open text-4xl text-gray-200 mb-3"></i>
                            <p class="text-gray-400 text-sm">Nhà hàng chưa có món ăn.</p>
                        </div>
                    </c:if>

                    <div class="space-y-3">
                        <c:forEach var="food" items="${foods}">
                            <div class="bg-white rounded-2xl border border-gray-100 shadow-sm hover:shadow-md transition-shadow p-4 flex gap-4">
                                <%-- Food image --%>
                                <div class="w-20 h-20 rounded-xl bg-gray-100 overflow-hidden flex-shrink-0">
                                    <c:choose>
                                        <c:when test="${not empty food.imageUrl}">
                                            <img src="${food.imageUrl}" class="w-full h-full object-cover" alt="${food.name}">
                                        </c:when>
                                        <c:otherwise>
                                            <div class="w-full h-full flex items-center justify-center bg-orange-50">
                                                <i class="fa-solid fa-burger text-2xl text-orange-200"></i>
                                            </div>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                                <%-- Info --%>
                                <div class="flex-1 min-w-0">
                                    <h3 class="font-bold text-gray-900 text-sm leading-tight">${food.name}</h3>
                                    <c:if test="${not empty food.description}">
                                        <p class="text-xs text-gray-400 mt-0.5 line-clamp-2">${food.description}</p>
                                    </c:if>
                                    <c:if test="${food.calories > 0}">
                                        <p class="text-xs text-gray-300 mt-1"><i class="fa-solid fa-fire-flame-curved text-orange-300"></i> ${food.calories} kcal</p>
                                    </c:if>
                                </div>
                                <%-- Price + add --%>
                                <div class="flex flex-col items-end justify-between flex-shrink-0">
                                    <span class="font-black text-orange-500 text-sm">
                                        <fmt:formatNumber value="${food.price}" type="number" maxFractionDigits="0"/>đ
                                        </span>
                                        <c:choose>
                                            <c:when test="${not empty sessionScope.account}">
                                                <a href="${pageContext.request.contextPath}/cart?action=add&id=${food.id}"
                                                class="bg-orange-500 hover:bg-orange-600 text-white w-8 h-8 rounded-xl flex items-center justify-center transition-colors shadow-sm">
                                                <i class="fa-solid fa-plus text-xs"></i>
                                            </a>
                                        </c:when>
                                        <c:otherwise>
                                            <a href="${pageContext.request.contextPath}/login"
                                            class="bg-gray-100 hover:bg-gray-200 text-gray-500 w-8 h-8 rounded-xl flex items-center justify-center transition-colors"
                                            title="Đăng nhập để thêm vào giỏ">
                                            <i class="fa-solid fa-plus text-xs"></i>
                                        </a>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>

            <%-- Reviews sidebar --%>
            <div class="lg:col-span-1">
                <h2 class="text-lg font-bold text-gray-900 mb-4 flex items-center gap-2">
                    <i class="fa-solid fa-comments text-blue-500"></i> Đánh giá
                </h2>

                <%-- Rating summary --%>
                <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5 mb-4 text-center">
                    <p class="text-5xl font-black text-gray-900 mb-1"><fmt:formatNumber value="${avgRating}" maxFractionDigits="1"/></p>
                    <div class="flex items-center justify-center gap-1 mb-2">
                        <c:forEach begin="1" end="5" var="i">
                            <i class="fa-solid fa-star text-sm ${i <= avgRating ? 'text-yellow-400' : 'text-gray-200'}"></i>
                        </c:forEach>
                    </div>
                    <p class="text-xs text-gray-400">${totalRatings} lượt đánh giá</p>
                </div>

                <%-- Review list --%>
                <div class="space-y-3">
                    <c:forEach var="review" items="${reviews}">
                        <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-4">
                            <div class="flex items-center justify-between mb-2">
                                <p class="text-sm font-bold text-gray-800">${not empty review.customerName ? review.customerName : 'Khách hàng'}</p>
                                <div class="flex items-center gap-0.5">
                                    <c:forEach begin="1" end="5" var="i">
                                        <i class="fa-solid fa-star text-xs ${i <= review.stars ? 'text-yellow-400' : 'text-gray-200'}"></i>
                                    </c:forEach>
                                </div>
                            </div>
                            <c:if test="${not empty review.comment}">
                                <p class="text-xs text-gray-600 line-clamp-3">${review.comment}</p>
                            </c:if>
                            <c:if test="${not empty review.replyComment}">
                                <div class="mt-2 pl-3 border-l-2 border-orange-200">
                                    <p class="text-xs text-orange-600 font-semibold">Phản hồi của quán:</p>
                                    <p class="text-xs text-gray-500">${review.replyComment}</p>
                                </div>
                            </c:if>
                            <p class="text-[10px] text-gray-300 mt-2">
                                <fmt:formatDate value="${review.createdAt}" pattern="dd/MM/yyyy"/>
                            </p>
                        </div>
                    </c:forEach>
                    <c:if test="${empty reviews}">
                        <div class="bg-white rounded-2xl border border-dashed border-gray-200 p-6 text-center">
                            <p class="text-xs text-gray-400">Chưa có đánh giá nào.</p>
                        </div>
                    </c:if>
                </div>
            </div>

        </div>
    </main>

    <jsp:include page="footer.jsp" />
</body>
</html>
