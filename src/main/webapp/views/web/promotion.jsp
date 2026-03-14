<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Khuyến mãi hot - ClickEat</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; }
        .promo-card:hover .promo-img { transform: scale(1.05); }
        .glass-effect {
            background: rgba(255, 255, 255, 0.82);
            backdrop-filter: blur(10px);
            -webkit-backdrop-filter: blur(10px);
        }
        .gradient-text {
            background: linear-gradient(135deg, #f97316 0%, #ed8936 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
    </style>
</head>
<body class="bg-gray-50 flex flex-col min-h-screen">

    <jsp:include page="header.jsp" />

    <!-- Hero Section -->
    <div class="relative bg-orange-500 overflow-hidden">
        <div class="absolute inset-0 opacity-10">
            <div class="absolute -top-24 -left-24 w-96 h-96 bg-white rounded-full blur-3xl"></div>
            <div class="absolute -bottom-24 -right-24 w-96 h-96 bg-white rounded-full blur-3xl"></div>
        </div>
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16 relative z-10">
            <div class="text-center">
                <span class="inline-block px-4 py-1.5 bg-white/20 text-white rounded-full text-sm font-bold uppercase tracking-wider mb-4 border border-white/30 backdrop-blur-sm">
                    Tiệc khuyến mãi
                </span>
                <h1 class="text-4xl md:text-6xl font-black text-white mb-6">
                    Săn Deal Ăn Sập <br/> <span class="text-orange-100">ClickEat</span>
                </h1>
                <p class="text-orange-100 text-lg md:text-xl max-w-2xl mx-auto mb-10">
                    Cơ hội thưởng thức ngàn món ngon với giá cực hời. Ưu đãi lên đến 50% cùng vô vàn mã giảm giá hấp dẫn.
                </p>
                <div class="flex flex-wrap justify-center gap-4">
                    <a href="#all-deals" class="px-8 py-4 bg-white text-orange-600 rounded-2xl font-bold text-lg hover:bg-orange-50 transition-all shadow-xl shadow-orange-900/20">
                        Khám phá ngay
                    </a>
                </div>
            </div>
        </div>
    </div>

    <!-- Main Content -->
    <main id="all-deals" class="flex-grow max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12 w-full">
        
        <div class="flex items-center justify-between mb-10">
            <div>
                <h2 class="text-3xl font-black text-gray-900 mb-2">Siêu Deal Đang Cháy</h2>
                <div class="h-1.5 w-20 bg-orange-500 rounded-full"></div>
            </div>
            <div class="hidden md:flex gap-2">
                <button class="p-2.5 rounded-xl border border-gray-200 hover:bg-white hover:shadow-md transition-all text-gray-400 hover:text-orange-500">
                    <i class="fa-solid fa-chevron-left"></i>
                </button>
                <button class="p-2.5 rounded-xl border border-gray-200 hover:bg-white hover:shadow-md transition-all text-gray-400 hover:text-orange-500">
                    <i class="fa-solid fa-chevron-right"></i>
                </button>
            </div>
        </div>

        <!-- Grid Deals -->
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-8">
            <c:forEach var="food" items="${promotedFoods}">
                <div class="promo-card bg-white rounded-[2rem] overflow-hidden shadow-sm hover:shadow-2xl transition-all duration-500 border border-gray-100 group">
                    <div class="relative h-56 overflow-hidden">
                        <img src="${food.imageUrl}" alt="${food.name}" class="promo-img w-full h-full object-cover transition-transform duration-700">
                        <div class="absolute top-4 left-4 bg-orange-500 text-white px-4 py-1.5 rounded-full text-sm font-bold shadow-lg">
                            -${food.discountPercent}%
                        </div>
                        <button class="absolute top-4 right-4 w-10 h-10 bg-white/90 backdrop-blur-md rounded-full flex items-center justify-center text-gray-400 hover:text-red-500 transition-colors shadow-lg">
                            <i class="fa-regular fa-heart"></i>
                        </button>
                    </div>
                    
                    <div class="p-6">
                        <div class="flex items-center gap-2 mb-3">
                            <span class="text-xs font-bold text-orange-500 uppercase tracking-wider">${food.categoryName}</span>
                            <span class="w-1 h-1 bg-gray-300 rounded-full"></span>
                            <span class="text-xs text-gray-500">${food.merchantName}</span>
                        </div>
                        
                        <h3 class="text-lg font-bold text-gray-900 mb-2 group-hover:text-orange-500 transition-colors line-clamp-1">
                            ${food.name}
                        </h3>
                        
                        <div class="flex items-center gap-1 text-sm text-yellow-400 mb-4">
                            <i class="fa-solid fa-star"></i>
                            <i class="fa-solid fa-star"></i>
                            <i class="fa-solid fa-star"></i>
                            <i class="fa-solid fa-star"></i>
                            <i class="fa-solid fa-star-half-stroke text-gray-200"></i>
                            <span class="text-gray-400 font-medium ml-1">(4.5)</span>
                        </div>

                        <div class="flex items-center justify-between mt-auto">
                            <div class="flex flex-col">
                                <span class="text-gray-400 line-through text-sm font-medium">
                                    <fmt:formatNumber value="${food.originalPrice}" pattern="#,###" />đ
                                </span>
                                <span class="text-xl font-black text-orange-500">
                                    <fmt:formatNumber value="${food.price}" pattern="#,###" />đ
                                </span>
                            </div>
                            <form action="${pageContext.request.contextPath}/cart" method="POST">
                                <input type="hidden" name="action" value="add">
                                <input type="hidden" name="foodItemId" value="${food.id}">
                                <input type="hidden" name="id" value="${food.id}">
                                <input type="hidden" name="quantity" value="1">
                                <button type="submit" class="w-12 h-12 bg-gray-900 group-hover:bg-orange-500 text-white rounded-2xl flex items-center justify-center transition-all shadow-lg hover:shadow-orange-500/40 hover:-translate-y-1">
                                    <i class="fa-solid fa-plus text-lg"></i>
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </div>

        <c:if test="${empty promotedFoods}">
            <div class="text-center py-24 bg-white rounded-3xl border border-dashed border-gray-200">
                <div class="w-20 h-20 bg-orange-50 rounded-full flex items-center justify-center mx-auto mb-6">
                    <i class="fa-solid fa-tag text-3xl text-orange-500"></i>
                </div>
                <h3 class="text-xl font-bold text-gray-900 mb-2">Chưa có khuyến mãi nào</h3>
                <p class="text-gray-500">Hãy quay lại sau để săn deal hời nhé!</p>
            </div>
        </c:if>

    </main>

    <jsp:include page="footer.jsp" />

</body>
</html>
