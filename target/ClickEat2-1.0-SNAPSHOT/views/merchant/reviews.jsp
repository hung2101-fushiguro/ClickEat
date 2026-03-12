<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<% request.setAttribute("currentPage", "reviews");%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Đánh giá – ClickEat Merchant</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <script>
            tailwind.config = {theme: {extend: {colors: {primary: '#c86601'}}}};
        </script>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
        <style>
            body {
                font-family: 'Inter', sans-serif;
            }
            .material-symbols-outlined {
                font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
            }
            .star-filled {
                font-variation-settings: 'FILL' 1, 'wght' 400, 'GRAD' 0, 'opsz' 24;
            }
        </style>
    </head>
    <body class="bg-[#f8f7f5] min-h-screen flex">

        <%@ include file="_nav.jsp" %>

        <div class="flex-1 flex flex-col min-h-screen pb-16 md:pb-0">

            <div class="flex-1 overflow-y-auto">
                <div class="p-4 md:p-8 max-w-5xl mx-auto space-y-6">

                    <div class="flex flex-col md:flex-row justify-between items-start md:items-end gap-4 mb-4">
                        <div>
                            <h1 class="text-3xl font-bold text-gray-900 tracking-tight">Đánh giá Khách hàng</h1>
                            <p class="text-gray-500 text-sm mt-1">Quản lý phản hồi và danh tiếng</p>
                        </div>
                        <div class="flex bg-white rounded-lg p-1 border border-gray-200 shadow-sm w-full md:w-auto overflow-x-auto">
                            <a href="${pageContext.request.contextPath}/merchant/reviews?filter=all"
                               class="flex-1 md:flex-none px-4 py-1.5 rounded-md text-sm font-semibold shadow-sm transition-all whitespace-nowrap 
                               ${filter == 'all' || empty filter ? 'bg-primary text-white' : 'text-gray-600 hover:bg-gray-50'}">
                                Tất cả
                            </a>
                            <a href="${pageContext.request.contextPath}/merchant/reviews?filter=unanswered"
                               class="flex-1 md:flex-none px-4 py-1.5 rounded-md text-sm font-semibold shadow-sm transition-all whitespace-nowrap 
                               ${filter == 'unanswered' ? 'bg-primary text-white' : 'text-gray-600 hover:bg-gray-50'}">
                                Chưa trả lời
                            </a>
                            <a href="${pageContext.request.contextPath}/merchant/reviews?filter=negative"
                               class="flex-1 md:flex-none px-4 py-1.5 rounded-md text-sm font-semibold shadow-sm transition-all whitespace-nowrap 
                               ${filter == 'negative' ? 'bg-primary text-white' : 'text-gray-600 hover:bg-gray-50'}">
                                Tiêu cực (1-3 sao)
                            </a>
                        </div>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
                        <div class="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm text-center">
                            <h3 class="text-4xl font-black text-gray-900">${avgStars}</h3>
                            <div class="flex justify-center text-yellow-400 my-2">
                                <c:forEach begin="1" end="5" var="i">
                                    <span class="material-symbols-outlined text-2xl ${i <= avgRating ? 'star-filled' : 'text-gray-200'}">star</span>
                                </c:forEach>
                            </div>
                            <p class="text-gray-400 text-xs font-bold uppercase tracking-widest mt-2">Điểm trung bình</p>
                        </div>
                        <div class="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm text-center">
                            <h3 class="text-4xl font-black text-gray-900">${totalCount}</h3>
                            <p class="text-gray-400 text-xs font-bold uppercase tracking-widest mt-4">Tổng đánh giá</p>
                        </div>
                        <div class="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm text-center">
                            <h3 class="text-4xl font-black text-green-600">${positivePercent}%</h3>
                            <p class="text-gray-400 text-xs font-bold uppercase tracking-widest mt-4">Tỷ lệ tích cực</p>
                        </div>
                    </div>

                    <div class="space-y-4">
                        <c:choose>
                            <c:when test="${empty reviews}">
                                <div class="text-center py-16 bg-white rounded-2xl border border-dashed border-gray-200">
                                    <span class="material-symbols-outlined text-5xl text-gray-300 mb-3">forum</span>
                                    <p class="text-gray-500 font-semibold">Chưa có đánh giá nào trong mục này.</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="r" items="${reviews}">
                                    <c:set var="rName"    value="${not empty r.customerName ? r.customerName : 'Khách ẩn danh'}"/>
                                    <c:set var="rStars"   value="${r.stars}"/>
                                    <c:set var="rComment" value="${r.comment}"/>
                                    <c:set var="rDate"    value="${r.createdAt}"/>
                                    <c:set var="rId"      value="${r.id}"/>
                                    <c:set var="rReply"   value="${r.replyComment}"/>
                                    <c:set var="rCode"    value="${r.orderCode}"/>

                                    <div class="bg-white p-6 rounded-2xl border border-gray-100 shadow-sm hover:shadow-md transition-shadow">
                                        <div class="flex justify-between items-start mb-4">
                                            <div class="flex items-center gap-3">
                                                <div class="w-10 h-10 rounded-full flex items-center justify-center font-bold text-white shadow-sm ${rStars > 3 ? 'bg-green-500' : 'bg-red-500'}">
                                                    ${fn:substring(rName, 0, 1)}
                                                </div>
                                                <div>
                                                    <h4 class="font-bold text-gray-900">${rName}</h4>
                                                    <p class="text-xs text-gray-400 font-medium mt-0.5">
                                                        <fmt:formatDate value="${rDate}" pattern="HH:mm - dd/MM/yyyy"/>
                                                        <c:if test="${not empty rCode}">
                                                            <span class="mx-1">•</span> Đơn #${rCode}
                                                        </c:if>
                                                        <c:if test="${not empty rReply}">
                                                            <span class="ml-2 text-green-600 font-bold bg-green-50 px-2 py-0.5 rounded-md">✓ Đã trả lời</span>
                                                        </c:if>
                                                    </p>
                                                </div>
                                            </div>
                                            <div class="flex text-yellow-400 text-sm">
                                                <c:forEach begin="1" end="5" var="s">
                                                    <span class="material-symbols-outlined text-lg ${s <= rStars ? 'star-filled' : 'text-gray-200'}">star</span>
                                                </c:forEach>
                                            </div>
                                        </div>

                                        <p class="text-gray-800 font-medium mb-4 ml-1">${rComment}</p>

                                        <c:choose>
                                            <c:when test="${not empty rReply}">
                                                <%-- Hiện câu trả lời đã có --%>
                                                <div class="bg-gray-50 rounded-xl p-4 ml-4 border border-gray-100">
                                                    <p class="text-xs font-bold text-primary mb-1.5 flex items-center gap-1">
                                                        <span class="material-symbols-outlined text-[14px]">storefront</span> Phản hồi từ cửa hàng
                                                    </p>
                                                    <p class="text-sm text-gray-700 font-medium">${rReply}</p>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <%-- Form để trả lời --%>
                                                <form method="POST" action="${pageContext.request.contextPath}/merchant/reviews" class="border-t border-gray-100 pt-4 mt-2 flex gap-3 ml-4">
                                                    <input type="hidden" name="action" value="reply"/>
                                                    <input type="hidden" name="ratingId" value="${rId}"/>
                                                    <input type="hidden" name="filter" value="${filter}"/>

                                                    <input type="text" name="replyText" placeholder="Viết phản hồi cho khách hàng..." required
                                                           oninput="this.nextElementSibling.disabled = !this.value.trim()"
                                                           class="flex-1 bg-gray-50 border border-gray-200 rounded-xl px-4 py-2.5 text-sm focus:outline-none focus:border-primary focus:bg-white font-medium transition-all shadow-sm"/>

                                                    <button type="submit" disabled
                                                            class="bg-gray-900 hover:bg-black disabled:bg-gray-200 disabled:text-gray-400 disabled:cursor-not-allowed text-white px-5 py-2.5 rounded-xl text-sm font-bold transition-colors shadow-sm">
                                                        Gửi trả lời
                                                    </button>
                                                </form>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </div>

    </body>
</html>