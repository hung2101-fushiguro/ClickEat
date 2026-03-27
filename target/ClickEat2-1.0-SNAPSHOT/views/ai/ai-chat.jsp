<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/responsive-global.css">
        <title>Trợ lý AI ClickEat</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <script>
            tailwind.config = {theme: {extend: {colors: {primary: '#f97316', primaryLight: '#fff7ed'}}}};
        </script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
        <style>
            body {
                font-family: 'Inter', sans-serif;
                background-color: #fdfbf9;
            }
            .material-symbols-outlined {
                font-variation-settings: 'FILL' 1, 'wght' 400;
            }
            ::-webkit-scrollbar {
                width: 4px;
            }
            ::-webkit-scrollbar-thumb {
                background: #e5e7eb;
                border-radius: 4px;
            }
            #messagesList {
                scroll-behavior: smooth;
            }
            .ai-content {
                white-space: normal;
                line-height: 1.55;
                text-indent: 0;
                word-break: break-word;
            }
        </style>
    </head>
    <body class="h-screen flex flex-col overflow-hidden">

        <jsp:include page="../web/header.jsp">
            <jsp:param name="activePage" value="ai" />
        </jsp:include>

        <div class="flex-1 max-w-[1400px] mx-auto w-full px-4 sm:px-6 lg:px-8 py-6 flex flex-col min-h-0">

            <div class="mb-6 shrink-0">
                <div class="flex items-center gap-3 mb-1">
                    <h1 class="text-3xl font-extrabold text-gray-900 tracking-tight">Trợ lý AI ClickEat</h1>
                    <div class="flex items-center gap-1 bg-orange-100 text-orange-600 px-2 py-0.5 rounded-md text-[10px] font-bold tracking-wider">
                        <span class="material-symbols-outlined text-[12px]">bolt</span>
                        AI GỢI Ý • CÁ NHÂN HOÁ
                    </div>
                </div>
                <p class="text-gray-500 font-medium">Chào bạn! Bụng đói rồi đúng không? Chọn đồ cùng ClickEat nhé 😉</p>
                <c:if test="${feedbackStatus == 'ok'}">
                    <p class="mt-2 text-sm font-semibold text-green-600">Cảm ơn bạn đã đánh giá câu trả lời của AI.</p>
                </c:if>
                <c:if test="${feedbackStatus == 'invalid'}">
                    <p class="mt-2 text-sm font-semibold text-amber-600">Đánh giá chưa hợp lệ, vui lòng thử lại.</p>
                </c:if>
                <c:if test="${feedbackStatus == 'fail'}">
                    <p class="mt-2 text-sm font-semibold text-red-600">Không thể lưu đánh giá lúc này, vui lòng thử lại sau.</p>
                </c:if>
            </div>

            <div class="flex gap-6 flex-1 min-h-0">
                <div class="flex-1 bg-white rounded-[2rem] shadow-sm border border-gray-100 flex flex-col overflow-hidden">

                    <div class="px-6 py-4 border-b border-gray-50 flex justify-between items-center shrink-0">
                        <div class="flex items-center gap-3">
                            <div class="w-10 h-10 bg-orange-100 rounded-xl flex items-center justify-center">
                                <span class="material-symbols-outlined text-primary">robot_2</span>
                            </div>
                            <div>
                                <h3 class="font-bold text-gray-900 leading-tight">Hỗ trợ lý AI ClickEat</h3>
                                <div class="flex items-center gap-1 mt-0.5">
                                    <span class="w-2 h-2 bg-green-500 rounded-full"></span>
                                    <span class="text-xs text-green-600 font-medium">Online</span>
                                </div>
                            </div>
                        </div>
                        <button class="text-gray-400 hover:text-gray-600"><span class="material-symbols-outlined">more_horiz</span></button>
                    </div>

                    <div class="flex-1 overflow-y-auto p-6 space-y-6" id="messagesList">

                        <div class="flex gap-4">
                            <div class="w-8 h-8 rounded-full bg-orange-100 flex items-center justify-center shrink-0 mt-1">
                                <span class="material-symbols-outlined text-primary text-sm">robot_2</span>
                            </div>
                            <div>
                                <div class="bg-gray-50 text-gray-800 p-4 rounded-2xl rounded-tl-sm text-[15px] font-medium leading-relaxed max-w-2xl border border-gray-100">
                                    <c:out value="${welcomeAiMessage}"/>
                                </div>
                                <span class="text-[10px] text-gray-400 font-semibold mt-1 ml-1 block">Vừa xong</span>
                            </div>
                        </div>

                        <c:forEach var="turn" items="${chatHistoryView}" varStatus="st">
                            <c:choose>
                                <c:when test="${turn.isModel}">
                                    <div class="flex gap-4">
                                        <div class="w-8 h-8 rounded-full bg-orange-100 flex items-center justify-center shrink-0 mt-1">
                                            <span class="material-symbols-outlined text-primary text-sm">robot_2</span>
                                        </div>
                                        <div>
                                            <div class="bg-gray-50 text-gray-800 p-4 rounded-2xl rounded-tl-sm text-[15px] font-medium max-w-2xl border border-gray-100 ai-content shadow-sm">
                                                ${turn.text}
                                            </div>
                                            <c:if test="${st.last}">
                                                <c:choose>
                                                    <c:when test="${not empty aiStructuredRecommendations}">
                                                        <div class="mt-3 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3 max-w-4xl">
                                                            <c:forEach var="rec" items="${aiStructuredRecommendations}">
                                                                <div class="rounded-2xl border border-gray-100 bg-white shadow-sm overflow-hidden">
                                                                    <c:choose>
                                                                        <c:when test="${not empty rec.imageUrl}">
                                                                            <img src="${rec.imageUrl}" class="w-full h-28 object-cover" alt="${rec.dishName}"/>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <div class="w-full h-28 bg-orange-50 flex items-center justify-center">
                                                                                <span class="material-symbols-outlined text-orange-300 text-4xl">restaurant</span>
                                                                            </div>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                    <div class="p-3">
                                                                        <div class="flex items-start justify-between gap-2">
                                                                            <p class="text-sm font-bold text-gray-900 line-clamp-1">${rec.dishName}</p>
                                                                            <span class="text-[10px] font-bold px-2 py-0.5 rounded-full ${rec.isHealthyAlternative ? 'bg-emerald-100 text-emerald-700' : 'bg-gray-100 text-gray-600'}">
                                                                                ${rec.isHealthyAlternative ? 'Healthy' : 'Đậm vị'}
                                                                            </span>
                                                                        </div>
                                                                        <p class="text-xs text-gray-500 mt-0.5 line-clamp-1">${rec.merchantName}</p>
                                                                        <p class="mt-1 text-[11px] text-gray-600 line-clamp-2">${rec.reason}</p>
                                                                        <div class="mt-2 flex flex-wrap gap-1">
                                                                            <span class="text-[10px] font-semibold bg-orange-100 text-orange-700 px-2 py-0.5 rounded-full">Health ${rec.healthScore}/10</span>
                                                                            <c:if test="${not empty rec.estimatedCalories}">
                                                                                <span class="text-[10px] font-semibold bg-blue-100 text-blue-700 px-2 py-0.5 rounded-full">~${rec.estimatedCalories} kcal</span>
                                                                            </c:if>
                                                                            <c:if test="${not empty rec.priceLevel and rec.priceLevel != 'unknown'}">
                                                                                <span class="text-[10px] font-semibold bg-gray-100 text-gray-600 px-2 py-0.5 rounded-full">${rec.priceLevel}</span>
                                                                            </c:if>
                                                                        </div>
                                                                        <c:if test="${not empty rec.tags}">
                                                                            <div class="mt-2 flex flex-wrap gap-1">
                                                                                <c:forEach var="tag" items="${rec.tags}">
                                                                                    <span class="text-[10px] font-semibold bg-green-50 text-green-700 px-2 py-0.5 rounded-full">#${tag}</span>
                                                                                </c:forEach>
                                                                            </div>
                                                                        </c:if>
                                                                        <div class="mt-2 flex items-center justify-between gap-2">
                                                                            <c:choose>
                                                                                <c:when test="${not empty rec.price}">
                                                                                    <span class="text-sm font-extrabold text-orange-600">
                                                                                        <fmt:formatNumber value="${rec.price}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                                                                                        </span>
                                                                                    </c:when>
                                                                                    <c:otherwise>
                                                                                        <span class="text-xs font-semibold text-gray-400">Giá đang cập nhật</span>
                                                                                    </c:otherwise>
                                                                                </c:choose>
                                                                                <c:if test="${not empty rec.foodId}">
                                                                                    <a href="${pageContext.request.contextPath}/cart?action=add&id=${rec.foodId}"
                                                                                    class="inline-flex items-center gap-1 rounded-full bg-primary px-3 py-1.5 text-[11px] font-bold text-white hover:bg-orange-600 transition-colors">
                                                                                    <span class="material-symbols-outlined text-[14px]">add_shopping_cart</span>
                                                                                    Thêm vào giỏ
                                                                                </a>
                                                                            </c:if>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </c:forEach>
                                                        </div>
                                                        <c:if test="${not empty aiNutritionNote}">
                                                            <div class="mt-2 max-w-4xl rounded-xl border border-blue-100 bg-blue-50 px-3 py-2 text-xs font-medium text-blue-800">
                                                                <span class="font-bold">Lưu ý dinh dưỡng:</span> ${aiNutritionNote}
                                                            </div>
                                                        </c:if>
                                                    </c:when>
                                                    <c:when test="${not empty suggestedFoods}">
                                                        <div class="mt-3 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-3 max-w-4xl">
                                                            <c:forEach var="food" items="${suggestedFoods}">
                                                                <div class="rounded-2xl border border-gray-100 bg-white shadow-sm overflow-hidden">
                                                                    <c:choose>
                                                                        <c:when test="${not empty food.imageUrl}">
                                                                            <img src="${food.imageUrl}" class="w-full h-28 object-cover" alt="${food.name}"/>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                            <div class="w-full h-28 bg-orange-50 flex items-center justify-center">
                                                                                <span class="material-symbols-outlined text-orange-300 text-4xl">restaurant</span>
                                                                            </div>
                                                                        </c:otherwise>
                                                                    </c:choose>
                                                                    <div class="p-3">
                                                                        <p class="text-sm font-bold text-gray-900 line-clamp-1">${food.name}</p>
                                                                        <p class="text-xs text-gray-500 mt-0.5 line-clamp-1">${food.merchantName}</p>
                                                                        <div class="mt-2 flex items-center justify-between gap-2">
                                                                            <span class="text-sm font-extrabold text-orange-600">
                                                                                <fmt:formatNumber value="${food.price}" type="number" groupingUsed="true" maxFractionDigits="0"/>đ
                                                                                </span>
                                                                                <a href="${pageContext.request.contextPath}/cart?action=add&id=${food.id}"
                                                                                class="inline-flex items-center gap-1 rounded-full bg-primary px-3 py-1.5 text-[11px] font-bold text-white hover:bg-orange-600 transition-colors">
                                                                                <span class="material-symbols-outlined text-[14px]">add_shopping_cart</span>
                                                                                Thêm vào giỏ
                                                                            </a>
                                                                        </div>
                                                                    </div>
                                                                </div>
                                                            </c:forEach>
                                                        </div>
                                                    </c:when>
                                                </c:choose>
                                            </c:if>
                                            <c:if test="${st.last and not empty aiInteractionId}">
                                                <form method="POST" action="${pageContext.request.contextPath}/ai/feedback" class="mt-2 flex flex-wrap items-center gap-2 text-xs">
                                                    <input type="hidden" name="eventId" value="${aiInteractionId}"/>
                                                    <button type="submit" name="score" value="1" class="inline-flex items-center gap-1 rounded-full border border-green-300 bg-green-50 px-3 py-1 font-semibold text-green-700 hover:bg-green-100 transition-colors">
                                                        <i class="fa-regular fa-thumbs-up"></i>
                                                        Hữu ích
                                                    </button>
                                                    <button type="submit" name="score" value="-1" class="inline-flex items-center gap-1 rounded-full border border-red-300 bg-red-50 px-3 py-1 font-semibold text-red-700 hover:bg-red-100 transition-colors">
                                                        <i class="fa-regular fa-thumbs-down"></i>
                                                        Chưa phù hợp
                                                    </button>
                                                    <input type="text" name="category" placeholder="Category (VD: nutrition/menu/safety)" class="min-w-[220px] rounded-lg border border-gray-200 px-2 py-1 text-xs font-medium"/>
                                                    <input type="text" name="errorType" placeholder="Error type (hallucination/wrong-store/...)" class="min-w-[220px] rounded-lg border border-gray-200 px-2 py-1 text-xs font-medium"/>
                                                    <input type="text" name="groundTruth" placeholder="Ground truth ngắn (đáp án đúng)" class="min-w-[280px] rounded-lg border border-gray-200 px-2 py-1 text-xs font-medium"/>
                                                    <input type="text" name="note" placeholder="Ghi chú lý do đánh giá" class="min-w-[260px] rounded-lg border border-gray-200 px-2 py-1 text-xs font-medium"/>
                                                </form>
                                            </c:if>
                                        </div>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="flex gap-4 justify-end">
                                        <div>
                                            <div class="bg-primary text-white p-4 rounded-2xl rounded-tr-sm text-[15px] font-medium leading-relaxed max-w-xl shadow-md shadow-orange-200">
                                                ${turn.text}
                                            </div>
                                        </div>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </c:forEach>

                        <div id="loading" class="hidden flex gap-4">
                            <div class="w-8 h-8 rounded-full bg-orange-100 flex items-center justify-center shrink-0 mt-1">
                                <span class="material-symbols-outlined text-primary text-sm animate-spin">sync</span>
                            </div>
                            <div class="bg-gray-50 text-gray-500 p-4 rounded-2xl rounded-tl-sm text-[14px] font-medium flex items-center gap-1">
                                AI đang suy nghĩ<span class="animate-pulse">...</span>
                            </div>
                        </div>
                    </div>

                    <div class="p-4 bg-white shrink-0">
                        <div class="flex gap-2 mb-3 overflow-x-auto pb-1" style="-ms-overflow-style:none;scrollbar-width:none;">
                            <button onclick="setQuickAsk('Mình muốn ăn Cơm')" class="flex items-center gap-1.5 px-3 py-1.5 rounded-full border border-gray-200 text-xs font-semibold text-gray-600 hover:border-primary hover:text-primary transition-colors whitespace-nowrap"><span class="material-symbols-outlined text-[14px]">restaurant</span> Cơm</button>
                            <button onclick="setQuickAsk('Gợi ý đồ uống giải khát')" class="flex items-center gap-1.5 px-3 py-1.5 rounded-full border border-gray-200 text-xs font-semibold text-gray-600 hover:border-primary hover:text-primary transition-colors whitespace-nowrap"><span class="material-symbols-outlined text-[14px]">local_drink</span> Giải khát</button>
                            <button onclick="setQuickAsk('Muốn ăn Fast food')" class="flex items-center gap-1.5 px-3 py-1.5 rounded-full border border-gray-200 text-xs font-semibold text-gray-600 hover:border-primary hover:text-primary transition-colors whitespace-nowrap"><span class="material-symbols-outlined text-[14px]">lunch_dining</span> Fast food</button>
                            <button onclick="setQuickAsk('Đồ nướng thì sao?')" class="flex items-center gap-1.5 px-3 py-1.5 rounded-full border border-gray-200 text-xs font-semibold text-gray-600 hover:border-primary hover:text-primary transition-colors whitespace-nowrap"><span class="material-symbols-outlined text-[14px]">kebab_dining</span> Nướng</button>
                            <button onclick="setQuickAsk('Ăn Bún/Phở cho nhẹ bụng')" class="flex items-center gap-1.5 px-3 py-1.5 rounded-full border border-gray-200 text-xs font-semibold text-gray-600 hover:border-primary hover:text-primary transition-colors whitespace-nowrap"><span class="material-symbols-outlined text-[14px]">ramen_dining</span> Bún/Phở</button>
                        </div>

                        <form method="POST" action="${pageContext.request.contextPath}/ai" onsubmit="showLoading()" class="flex items-center gap-2 bg-gray-50 p-1.5 rounded-full border border-gray-200 focus-within:border-primary/50 focus-within:ring-2 focus-within:ring-primary/10 transition-all">
                            <input type="hidden" name="latitude" id="geoLat"/>
                            <input type="hidden" name="longitude" id="geoLng"/>
                            <button type="button" class="p-2 text-gray-400 hover:text-gray-600 ml-1 shrink-0"><span class="material-symbols-outlined">attach_file</span></button>
                            <input type="text" name="message" id="msgInput" placeholder="Hỏi AI ClickEat bất cứ điều gì..." required autocomplete="off" autofocus class="flex-1 bg-transparent border-none outline-none text-sm font-medium text-gray-900 placeholder:text-gray-400 py-2"/>
                            <button type="submit" class="w-10 h-10 bg-primary text-white rounded-full flex items-center justify-center hover:bg-orange-600 shadow-md shrink-0 transition-transform active:scale-95"><span class="material-symbols-outlined text-[20px]">send</span></button>
                        </form>
                    </div>
                </div>

                <div class="w-80 hidden lg:flex flex-col gap-4 overflow-y-auto pb-4 shrink-0" style="-ms-overflow-style:none;scrollbar-width:none;">

                    <div class="bg-white p-5 rounded-3xl shadow-sm border border-gray-100">
                        <div class="flex items-center gap-2 mb-4">
                            <span class="material-symbols-outlined text-orange-500 text-[18px]">local_fire_department</span>
                            <h3 class="font-bold text-gray-900 text-sm">Gợi ý nhanh hôm nay</h3>
                        </div>
                        <div class="flex flex-wrap gap-2">
                            <span class="text-xs font-bold text-gray-700 bg-gray-100 px-3 py-1.5 rounded-lg cursor-pointer hover:bg-gray-200">#ComboTietKiem</span>
                            <span class="text-xs font-bold text-gray-700 bg-gray-100 px-3 py-1.5 rounded-lg cursor-pointer hover:bg-gray-200">#TraSua1Dong</span>
                            <span class="text-xs font-bold text-gray-700 bg-gray-100 px-3 py-1.5 rounded-lg cursor-pointer hover:bg-gray-200">#Healthy</span>
                            <span class="text-xs font-bold text-gray-700 bg-gray-100 px-3 py-1.5 rounded-lg cursor-pointer hover:bg-gray-200">#AnDem</span>
                        </div>
                    </div>

                    <div class="bg-white p-5 rounded-3xl shadow-sm border border-gray-100">
                        <div class="flex items-center gap-2 mb-4">
                            <span class="material-symbols-outlined text-orange-500 text-[18px]">history</span>
                            <h3 class="font-bold text-gray-900 text-sm">Đã ăn hôm qua</h3>
                        </div>
                        <c:choose>
                            <c:when test="${not empty yesterdayOrders}">
                                <div class="space-y-4">
                                    <c:forEach var="ord" items="${yesterdayOrders}">
                                        <div class="flex items-center justify-between">
                                            <div class="flex items-center gap-3">
                                                <c:choose>
                                                    <c:when test="${not empty ord.shopAvatar}">
                                                        <img src="${ord.shopAvatar}" class="w-10 h-10 rounded-full object-cover"/>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <div class="w-10 h-10 rounded-full bg-orange-100 flex items-center justify-center">
                                                            <span class="material-symbols-outlined text-primary text-sm">restaurant</span>
                                                        </div>
                                                    </c:otherwise>
                                                </c:choose>
                                                <div>
                                                    <p class="text-sm font-bold text-gray-900 truncate w-28">${ord.shopName}</p>
                                                    <p class="text-[10px] text-gray-500 font-medium">Đơn #${ord.orderCode}</p>
                                                    <c:if test="${not empty ord.itemSummary}">
                                                        <p class="text-[10px] text-gray-500 font-medium truncate w-36" title="${ord.itemSummary}">
                                                            ${ord.totalItems} món: ${ord.itemSummary}
                                                        </p>
                                                    </c:if>
                                                </div>
                                            </div>
                                            <a href="${pageContext.request.contextPath}/order-tracking?orderId=${ord.orderId}"
                                            class="px-3 py-1 rounded-full border border-primary text-primary text-[11px] font-bold hover:bg-primary hover:text-white transition-colors">
                                            Chi tiết
                                        </a>
                                    </div>
                                </c:forEach>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <p class="text-xs text-gray-400 italic">Hôm qua bạn chưa đặt đơn nào.</p>
                        </c:otherwise>
                    </c:choose>
                </div>

                <c:choose>
                    <c:when test="${not empty favoriteMerchant}">
                        <div class="bg-primaryLight p-5 rounded-3xl border border-orange-100 relative overflow-hidden">
                            <div class="flex items-center gap-2 mb-4 relative z-10">
                                <span class="material-symbols-outlined text-orange-500 text-[18px]">star</span>
                                <h3 class="font-bold text-gray-900 text-sm">Cửa hàng yêu thích</h3>
                            </div>
                            <c:choose>
                                <c:when test="${not empty favoriteMerchant.shopAvatar}">
                                    <div class="relative rounded-xl overflow-hidden shadow-sm">
                                        <img src="${favoriteMerchant.shopAvatar}" class="w-full h-32 object-cover"/>
                                        <div class="absolute top-2 right-2 bg-white/90 backdrop-blur text-gray-900 text-[10px] font-bold px-2 py-1 rounded-md flex items-center gap-0.5">
                                            <span class="material-symbols-outlined text-[12px] text-yellow-500" style="font-variation-settings:'FILL' 1">star</span>
                                            ${favoriteMerchant.avgRating}
                                        </div>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <div class="relative rounded-xl overflow-hidden shadow-sm bg-orange-50 h-32 flex items-center justify-center">
                                        <span class="material-symbols-outlined text-orange-300 text-5xl">storefront</span>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                            <h4 class="font-bold text-gray-900 mt-3 mb-1">${favoriteMerchant.shopName}</h4>
                            <p class="text-[11px] text-gray-500 font-semibold">Đã đặt ${favoriteMerchant.orderCount} lần</p>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div class="bg-gray-50 p-5 rounded-3xl border border-gray-100">
                            <div class="flex items-center gap-2 mb-2">
                                <span class="material-symbols-outlined text-gray-400 text-[18px]">star</span>
                                <h3 class="font-bold text-gray-400 text-sm">Cửa hàng yêu thích</h3>
                            </div>
                            <p class="text-xs text-gray-400 italic">Chưa có dữ liệu. Hãy đặt đơn đầu tiên!</p>
                        </div>
                    </c:otherwise>
                </c:choose>

                <div class="bg-gray-50 p-5 rounded-3xl border border-gray-100 text-sm text-gray-600 font-medium italic">
                    <p class="text-xs font-bold text-gray-400 uppercase tracking-widest mb-2 not-italic">Mẹo cho bạn</p>
                    "Thử hỏi AI: 'Hãy gợi ý cho mình một bữa trưa dưới 60k, nhiều đạm và không có hành tây' nhé!"
                </div>

            </div>
        </div>
    </div>

    <script>
        function scrollToBottom() {
            const el = document.getElementById('messagesList');
            if (el)
            el.scrollTop = el.scrollHeight;
        }
        window.onload = scrollToBottom;
        
        function showLoading() {
            document.getElementById('loading').classList.remove('hidden');
            scrollToBottom();
        }
        
        function setQuickAsk(text) {
            const input = document.getElementById('msgInput');
            input.value = text;
            input.focus();
        }
        
        function bindUserLocation() {
            if (!navigator.geolocation) {
                return;
            }
            navigator.geolocation.getCurrentPosition(function (position) {
                const latInput = document.getElementById('geoLat');
                const lngInput = document.getElementById('geoLng');
                if (latInput && lngInput) {
                    latInput.value = position.coords.latitude;
                    lngInput.value = position.coords.longitude;
                }
                }, function () {
                    // User denied location or device cannot provide coordinates.
                    }, {
                        enableHighAccuracy: false,
                        timeout: 5000,
                        maximumAge: 120000
                    });
                }
                
                bindUserLocation();
            </script>
        </body>
    </html>