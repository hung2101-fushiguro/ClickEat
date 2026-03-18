<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Trợ lý AI ClickEat</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <script>
            tailwind.config = {theme: {extend: {colors: {primary: '#f97316', primaryLight: '#fff7ed'}}}};
        </script>
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
                white-space: pre-wrap;
                line-height: 1.6;
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
                                    Chào ${customerName}! Hôm nay bạn muốn dùng bữa kiểu gì nhỉ? Dựa trên sở thích gần đây, mình thấy bạn thường thích các món cơm văn phòng hoặc đồ uống thanh mát.
                                </div>
                                <span class="text-[10px] text-gray-400 font-semibold mt-1 ml-1 block">Vừa xong</span>
                            </div>
                        </div>

                        <c:if test="${not empty userMessage}">
                            <div class="flex gap-4 justify-end">
                                <div>
                                    <div class="bg-primary text-white p-4 rounded-2xl rounded-tr-sm text-[15px] font-medium leading-relaxed max-w-xl shadow-md shadow-orange-200">
                                        ${userMessage}
                                    </div>
                                </div>
                            </div>
                        </c:if>

                        <c:if test="${not empty aiReply}">
                            <div class="flex gap-4">
                                <div class="w-8 h-8 rounded-full bg-orange-100 flex items-center justify-center shrink-0 mt-1">
                                    <span class="material-symbols-outlined text-primary text-sm">robot_2</span>
                                </div>
                                <div>
                                    <div class="bg-gray-50 text-gray-800 p-4 rounded-2xl rounded-tl-sm text-[15px] font-medium max-w-2xl border border-gray-100 ai-content shadow-sm">
                                        ${aiReply}
                                    </div>
                                </div>
                            </div>
                        </c:if>

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
                        <div class="space-y-4">
                            <div class="flex items-center justify-between">
                                <div class="flex items-center gap-3">
                                    <img src="https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=100&q=80" class="w-10 h-10 rounded-full object-cover"/>
                                    <div>
                                        <p class="text-sm font-bold text-gray-900 truncate w-28">Cơm gà Trịnh H...</p>
                                        <p class="text-[10px] text-gray-500 font-medium">Giao lúc 12:30</p>
                                    </div>
                                </div>
                                <button class="px-3 py-1 rounded-full border border-primary text-primary text-[11px] font-bold hover:bg-primary hover:text-white transition-colors">Ăn lại</button>
                            </div>
                            <div class="flex items-center justify-between">
                                <div class="flex items-center gap-3">
                                    <img src="https://images.unsplash.com/photo-1556881286-fc6915169721?w=100&q=80" class="w-10 h-10 rounded-full object-cover"/>
                                    <div>
                                        <p class="text-sm font-bold text-gray-900 truncate w-28">Trà chanh Mixue</p>
                                        <p class="text-[10px] text-gray-500 font-medium">Giao lúc 15:15</p>
                                    </div>
                                </div>
                                <button class="px-3 py-1 rounded-full border border-primary text-primary text-[11px] font-bold hover:bg-primary hover:text-white transition-colors">Ăn lại</button>
                            </div>
                            <div class="flex items-center justify-between">
                                <div class="flex items-center gap-3">
                                    <img src="https://images.unsplash.com/photo-1585032226651-759b368d7246?w=100&q=80" class="w-10 h-10 rounded-full object-cover"/>
                                    <div>
                                        <p class="text-sm font-bold text-gray-900 truncate w-28">Bún đậu Đôn Đ...</p>
                                        <p class="text-[10px] text-gray-500 font-medium">Giao lúc 19:00</p>
                                    </div>
                                </div>
                                <button class="px-3 py-1 rounded-full border border-primary text-primary text-[11px] font-bold hover:bg-primary hover:text-white transition-colors">Ăn lại</button>
                            </div>
                        </div>
                    </div>

                    <div class="bg-primaryLight p-5 rounded-3xl border border-orange-100 relative overflow-hidden">
                        <div class="flex items-center gap-2 mb-4 relative z-10">
                            <span class="material-symbols-outlined text-orange-500 text-[18px]">star</span>
                            <h3 class="font-bold text-gray-900 text-sm">Cửa hàng yêu thích</h3>
                        </div>
                        <div class="relative rounded-xl overflow-hidden shadow-sm">
                            <img src="${favoriteStoreImg}" class="w-full h-32 object-cover"/>
                            <div class="absolute top-2 right-2 bg-white/90 backdrop-blur text-gray-900 text-[10px] font-bold px-2 py-1 rounded-md flex items-center gap-0.5">
                                <span class="material-symbols-outlined text-[12px] text-yellow-500" style="font-variation-settings:'FILL' 1">star</span> ${favoriteStoreRating}
                            </div>
                        </div>
                        <h4 class="font-bold text-gray-900 mt-3 mb-1">${favoriteStoreName}</h4>
                        <div class="flex items-center gap-2 text-[11px] font-semibold text-gray-500">
                            <span class="flex items-center gap-0.5"><span class="material-symbols-outlined text-[14px]">location_on</span> ${favoriteStoreDistance}</span>
                            <span>•</span>
                            <span class="flex items-center gap-0.5"><span class="material-symbols-outlined text-[14px]">schedule</span> ${favoriteStoreTime}</span>
                        </div>
                    </div>

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
        </script>
    </body>
</html>