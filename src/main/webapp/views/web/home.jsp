<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ClickEat - Đặt đồ ăn trực tuyến</title>
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
            .no-scrollbar::-webkit-scrollbar { display: none; }
            .no-scrollbar { -ms-overflow-style: none; scrollbar-width: none; }
        </style>
    </head>
    <body class="bg-gray-50 flex flex-col min-h-screen">

        <jsp:include page="header.jsp" />

        <main class="flex-grow">
            <section class="relative bg-orange-500 pt-16 pb-24 overflow-hidden">
                <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10 text-center">
                    <h1 class="text-3xl md:text-5xl font-extrabold text-white mb-4">
                        Món ngon yêu thích,<br/>giao đến tận cửa
                    </h1>
                    <p class="text-orange-100 text-base md:text-lg mb-8 max-w-2xl mx-auto">
                        Khám phá hàng ngàn món ăn ngon từ các nhà hàng địa phương.
                    </p>

                    <div class="max-w-2xl mx-auto bg-white p-2 rounded-2xl shadow-lg flex gap-2">
                        <div class="flex-1 flex items-center bg-gray-50 rounded-xl px-4">
                            <i class="fa-solid fa-magnifying-glass text-gray-400"></i>
                            <input type="text" placeholder="Tìm kiếm món ăn, nhà hàng..." class="w-full bg-transparent border-none outline-none py-3 px-3 text-sm text-gray-700">
                        </div>
                        <button class="bg-gray-900 text-white px-6 py-3 rounded-xl text-sm font-bold hover:bg-gray-800 transition-colors">
                            Tìm kiếm
                        </button>
                    </div>
                </div>
            </section>

            <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10 -mt-10 relative z-20">
                <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 flex justify-between overflow-x-auto no-scrollbar gap-6">

                    <div class="flex flex-col items-center gap-2 cursor-pointer group min-w-[80px]">
                        <div class="w-14 h-14 bg-orange-50 text-orange-500 rounded-full flex items-center justify-center text-2xl group-hover:bg-orange-500 group-hover:text-white transition-colors duration-300">
                            <i class="fa-solid fa-bowl-rice"></i>
                        </div>
                        <span class="text-xs font-bold text-gray-700">Cơm</span>
                    </div>

                    <div class="flex flex-col items-center gap-2 cursor-pointer group min-w-[80px]">
                        <div class="w-14 h-14 bg-blue-50 text-blue-500 rounded-full flex items-center justify-center text-2xl group-hover:bg-blue-500 group-hover:text-white transition-colors duration-300">
                            <i class="fa-solid fa-bowl-food"></i>
                        </div>
                        <span class="text-xs font-bold text-gray-700">Bún/Phở</span>
                    </div>

                    <div class="flex flex-col items-center gap-2 cursor-pointer group min-w-[80px]">
                        <div class="w-14 h-14 bg-yellow-50 text-yellow-500 rounded-full flex items-center justify-center text-2xl group-hover:bg-yellow-500 group-hover:text-white transition-colors duration-300">
                            <i class="fa-solid fa-drumstick-bite"></i>
                        </div>
                        <span class="text-xs font-bold text-gray-700">Gà Rán</span>
                    </div>

                    <div class="flex flex-col items-center gap-2 cursor-pointer group min-w-[80px]">
                        <div class="w-14 h-14 bg-red-50 text-red-500 rounded-full flex items-center justify-center text-2xl group-hover:bg-red-500 group-hover:text-white transition-colors duration-300">
                            <i class="fa-solid fa-burger"></i>
                        </div>
                        <span class="text-xs font-bold text-gray-700">Burger</span>
                    </div>

                    <div class="flex flex-col items-center gap-2 cursor-pointer group min-w-[80px]">
                        <div class="w-14 h-14 bg-purple-50 text-purple-500 rounded-full flex items-center justify-center text-2xl group-hover:bg-purple-500 group-hover:text-white transition-colors duration-300">
                            <i class="fa-solid fa-glass-water"></i>
                        </div>
                        <span class="text-xs font-bold text-gray-700">Trà Sữa</span>
                    </div>

                    <div class="flex flex-col items-center gap-2 cursor-pointer group min-w-[80px]">
                        <div class="w-14 h-14 bg-green-50 text-green-500 rounded-full flex items-center justify-center text-2xl group-hover:bg-green-500 group-hover:text-white transition-colors duration-300">
                            <i class="fa-solid fa-pizza-slice"></i>
                        </div>
                        <span class="text-xs font-bold text-gray-700">Ăn Vặt</span>
                    </div>

                    <div class="flex flex-col items-center gap-2 cursor-pointer group min-w-[80px]">
                        <div class="w-14 h-14 bg-gray-100 text-gray-500 rounded-full flex items-center justify-center text-2xl group-hover:bg-gray-200 transition-colors duration-300">
                            <i class="fa-solid fa-ellipsis"></i>
                        </div>
                        <span class="text-xs font-bold text-gray-700">Xem thêm</span>
                    </div>

                </div>
            </section>

            <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
                <h2 class="text-xl font-extrabold text-gray-900 mb-4 flex items-center gap-2">
                    <i class="fa-solid fa-fire text-red-500"></i> Deal hot cho bạn
                </h2>
                <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                    <div class="bg-gradient-to-r from-orange-500 to-red-500 rounded-2xl p-6 text-white shadow-md cursor-pointer hover:shadow-lg transition">
                        <h3 class="font-black text-2xl mb-1">GIẢM 50K</h3>
                        <p class="text-sm opacity-90 mb-4">Cho đơn hàng từ 150K</p>
                        <span class="bg-white text-red-500 text-xs font-bold px-3 py-1.5 rounded-full">Lấy mã ngay</span>
                    </div>
                    <div class="bg-gradient-to-r from-blue-500 to-indigo-500 rounded-2xl p-6 text-white shadow-md cursor-pointer hover:shadow-lg transition">
                        <h3 class="font-black text-2xl mb-1">FREESHIP</h3>
                        <p class="text-sm opacity-90 mb-4">Miễn phí giao hàng tới 3km</p>
                        <span class="bg-white text-indigo-500 text-xs font-bold px-3 py-1.5 rounded-full">Lấy mã ngay</span>
                    </div>
                    <div class="hidden lg:block bg-gradient-to-r from-green-500 to-emerald-500 rounded-2xl p-6 text-white shadow-md cursor-pointer hover:shadow-lg transition">
                        <h3 class="font-black text-2xl mb-1">Hoàn tiền 10%</h3>
                        <p class="text-sm opacity-90 mb-4">Thanh toán qua VNPAY</p>
                        <span class="bg-white text-emerald-500 text-xs font-bold px-3 py-1.5 rounded-full">Xem chi tiết</span>
                    </div>
                </div>
            </section>

            <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
                <div class="flex justify-between items-end mb-4">
                    <h2 class="text-xl font-extrabold text-gray-900 flex items-center gap-2">
                        <i class="fa-solid fa-store text-orange-500"></i> Các nhà hàng nổi bật
                    </h2>
                    <a href="${pageContext.request.contextPath}/home" class="text-sm text-orange-500 font-bold hover:text-orange-600">Xem tất cả</a>
                </div>

                <c:if test="${empty merchants}">
                    <div class="text-center py-10 bg-white rounded-2xl border border-dashed border-gray-200">
                        <i class="fa-solid fa-store text-4xl text-gray-300 mb-3"></i>
                        <p class="text-gray-500 text-sm">Chưa có nhà hàng nào trong hệ thống.</p>
                    </div>
                </c:if>

                <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
                    <c:forEach var="m" items="${merchants}">
                        <a href="${pageContext.request.contextPath}/restaurant?id=${m.userId}"
                        class="bg-white rounded-2xl border border-gray-100 shadow-sm hover:shadow-md transition group overflow-hidden">
                        <div class="h-32 bg-gray-100 relative overflow-hidden">
                            <c:choose>
                                <c:when test="${not empty m.shopAvatar}">
                                    <img src="${m.shopAvatar}" class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500">
                                </c:when>
                                <c:otherwise>
                                    <div class="w-full h-full flex items-center justify-center bg-orange-50">
                                        <i class="fa-solid fa-store text-4xl text-orange-200"></i>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                            <div class="absolute top-2 right-2 bg-white px-2 py-1 rounded-md text-xs font-bold flex items-center gap-1 shadow-sm">
                                <i class="fa-solid fa-star text-yellow-400"></i>
                                <fmt:formatNumber value="${m.avgRating}" maxFractionDigits="1"/>
                            </div>
                        </div>
                        <div class="p-4">
                            <h3 class="font-bold text-gray-900 line-clamp-1">${m.shopName}</h3>
                            <p class="text-xs text-gray-500 mt-1 line-clamp-1">${m.shopAddressLine}</p>
                            <p class="text-xs text-gray-400 mt-1">
                                <i class="fa-solid fa-bowl-rice text-orange-400 mr-1"></i>${m.foodCount} món •
                                <i class="fa-solid fa-comment-dots text-blue-400 mr-1 ml-1"></i>${m.totalRatings} đánh giá
                            </p>
                        </div>
                    </a>
                </c:forEach>
            </div>
        </section>

        <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8 border-t border-gray-100">
            <div class="flex justify-between items-end mb-6">
                <div>
                    <h2 class="text-xl font-extrabold text-gray-900 flex items-center gap-2 mb-1">
                        <i class="fa-solid fa-utensils text-orange-500"></i> Gợi ý hôm nay
                    </h2>
                    <p class="text-xs text-gray-500">Các món ăn ngon được đặt nhiều nhất</p>
                </div>
            </div>

            <c:if test="${empty foods}">
                <div class="text-center py-10 bg-white rounded-2xl border border-dashed border-gray-200">
                    <i class="fa-solid fa-box-open text-4xl text-gray-300 mb-4"></i>
                    <p class="text-gray-500 text-sm">Chưa có món ăn nào trong hệ thống!</p>
                </div>
            </c:if>

            <div class="grid grid-cols-2 lg:grid-cols-4 gap-4">
                <c:forEach var="f" items="${foods}">
                    <div class="bg-white rounded-2xl overflow-hidden border border-gray-100 shadow-sm hover:shadow-md transition-shadow group cursor-pointer flex flex-col">
                        <div class="relative h-40 overflow-hidden bg-gray-100 flex items-center justify-center">
                            <img src="${not empty f.imageUrl ? f.imageUrl : 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=800'}" class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300">

                            <c:if test="${f.fried}">
                                <div class="absolute top-2 left-2 bg-yellow-400 text-white text-[10px] uppercase font-black px-2 py-1 rounded shadow-sm">
                                    Chiên Giòn
                                </div>
                            </c:if>
                        </div>

                        <div class="p-4 flex flex-col flex-grow">
                            <h3 class="text-base font-bold text-gray-900 group-hover:text-orange-500 transition-colors line-clamp-1">${f.name}</h3>
                            <p class="text-gray-500 text-xs mt-1 line-clamp-2 min-h-[32px]">${f.description}</p>

                            <div class="flex items-center justify-between mt-4">
                                <span class="text-orange-500 font-black text-base">${f.price}đ</span>
                                <a href="cart?action=add&id=${f.id}" class="bg-gray-50 border border-gray-200 w-8 h-8 rounded-full flex items-center justify-center hover:bg-orange-500 hover:text-white hover:border-orange-500 transition-colors text-gray-600">
                                    <i class="fa-solid fa-plus text-sm"></i>
                                </a>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </section>

    </main>

    <jsp:include page="footer.jsp" />

</body>
</html>