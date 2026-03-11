<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
    <%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Đánh giá – ClickEat Merchant</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <script>
            tailwind.config = { theme: { extend: { colors: { primary: '#c86601' } } } };
        </script>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
        <style>
            body { font-family: 'Inter', sans-serif; }
            .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
            .star-filled { font-variation-settings: 'FILL' 1, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
        </style>
    </head>
    <body class="bg-gray-50 min-h-screen flex">

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
                            class="flex-1 md:flex-none px-4 py-1.5 rounded-md text-sm font-semibold shadow-sm transition-all whitespace-nowrap ${filter == 'all' || empty filter ? 'bg-primary text-white' : 'text-gray-600 hover:bg-gray-50'}">
                            Tất cả
                        </a>
                        <a href="${pageContext.request.contextPath}/merchant/reviews?filter=unanswered"
                        class="flex-1 md:flex-none px-4 py-1.5 rounded-md text-sm font-semibold shadow-sm transition-all whitespace-nowrap ${filter == 'unanswered' ? 'bg-primary text-white' : 'text-gray-600 hover:bg-gray-50'}">
                        Chưa trả lời
                    </a>
                    <a href="${pageContext.request.contextPath}/merchant/reviews?filter=negative"
                    class="flex-1 md:flex-none px-4 py-1.5 rounded-md text-sm font-semibold shadow-sm transition-all whitespace-nowrap ${filter == 'negative' ? 'bg-primary text-white' : 'text-gray-600 hover:bg-gray-50'}">
                    Tiêu cực
                </a>
            </div>
        </div>

        <!-- Summary Cards -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
            <div class="bg-white p-6 rounded-xl border border-gray-200 shadow-sm text-center">
                <h3 class="text-4xl font-bold text-gray-900">${avgStars}</h3>
                <div class="flex justify-center text-yellow-400 my-2">
                    <c:forEach begin="1" end="5" var="i">
                        <span class="material-symbols-outlined text-2xl ${i <= avgStars ? 'star-filled' : 'text-gray-200'}">star</span>
                    </c:forEach>
                </div>
                <p class="text-gray-500 text-sm font-semibold uppercase tracking-wide">Điểm trung bình</p>
            </div>
            <div class="bg-white p-6 rounded-xl border border-gray-200 shadow-sm text-center">
                <h3 class="text-4xl font-bold text-gray-900">${totalCount}</h3>
                <p class="text-gray-500 text-sm font-semibold uppercase tracking-wide mt-4">Tổng đánh giá</p>
            </div>
            <div class="bg-white p-6 rounded-xl border border-gray-200 shadow-sm text-center">
                <h3 class="text-4xl font-bold text-gray-900">${positivePercent}%</h3>
                <p class="text-gray-500 text-sm font-semibold uppercase tracking-wide mt-4">Tích cực</p>
            </div>
        </div>

        <!-- Reviews List -->
        <div class="space-y-4">
            <c:choose>
                <c:when test="${empty reviews}">
                    <div class="text-center py-12 bg-white rounded-xl border border-dashed border-gray-200">
                        <p class="text-gray-500 font-semibold">Không tìm thấy đánh giá nào.</p>
                    </div>
                </c:when>
                <c:otherwise>
                    <c:forEach var="r" items="${reviews}">
                        <c:set var="rName"    value="${r[0]}"/>
                        <c:set var="rStars"   value="${r[1]}"/>
                        <c:set var="rComment" value="${r[2]}"/>
                        <c:set var="rDate"    value="${r[3]}"/>
                        <c:set var="rId"      value="${r[4]}"/>
                        <c:set var="rReply"   value="${r[5]}"/>
                        <div class="bg-white p-6 rounded-xl border border-gray-200 shadow-sm hover:shadow-md transition-shadow">
                            <div class="flex justify-between items-start mb-3">
                                <div class="flex items-center gap-3">
                                    <div class="w-10 h-10 rounded-full flex items-center justify-center font-semibold text-white shadow-sm ${rStars > 3 ? 'bg-green-500' : 'bg-orange-500'}">
                                        ${fn:substring(rName, 0, 1)}
                                    </div>
                                    <div>
                                        <h4 class="font-semibold text-gray-900">${rName}</h4>
                                        <p class="text-xs text-gray-400">
                                            ${rDate}
                                            <c:if test="${not empty rReply}">
                                                <span class="ml-2 text-green-600 font-semibold">✓ Đã trả lời</span>
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
                            <p class="text-gray-700 mb-4">${rComment}</p>

                            <c:choose>
                                <c:when test="${not empty rReply}">
                                    <%-- Show existing reply --%>
                                    <div class="border-t border-gray-100 pt-3 pl-4 border-l-4 border-l-primary/30 mt-2">
                                        <p class="text-xs font-semibold text-primary mb-1">Phản hồi từ cửa hàng:</p>
                                        <p class="text-sm text-gray-700">${rReply}</p>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <%-- Reply form --%>
                                    <form method="POST" action="${pageContext.request.contextPath}/merchant/reviews"
                                    class="border-t border-gray-100 pt-3 flex gap-2">
                                    <input type="hidden" name="action" value="reply"/>
                                    <input type="hidden" name="ratingId" value="${rId}"/>
                                    <input type="text" name="replyText" placeholder="Viết câu trả lời..."
                                    required
                                    oninput="this.nextElementSibling.disabled = !this.value.trim()"
                                    class="flex-1 bg-gray-50 border border-gray-200 rounded-lg px-4 py-2 text-sm focus:outline-none focus:border-primary focus:bg-white transition-all"/>
                                    <button type="submit" disabled
                                    class="bg-primary hover:bg-orange-600 disabled:bg-gray-200 disabled:text-gray-400 disabled:cursor-not-allowed text-white px-4 py-2 rounded-lg text-sm font-semibold transition-colors shadow-sm">
                                    Trả lời
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
