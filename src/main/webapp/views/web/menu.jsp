<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ClickEat - Thực đơn</title>
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">

        <style>
            :root{
                --bg:#f4f5f7;
                --card:#ffffff;
                --text:#111827;
                --muted:#6b7280;
                --line:#e5e7eb;
                --primary:#ff7a1a;
                --primary-hover:#f26c00;
                --shadow:0 10px 30px rgba(15,23,42,.06);
                --shadow-hover:0 18px 40px rgba(15,23,42,.10);
                --radius:28px;
            }

            body{
                margin:0;
                font-family:Inter,system-ui,-apple-system,Segoe UI,Roboto,Arial,sans-serif;
                background:var(--bg);
                color:var(--text);
            }

            .container-click{
                width:min(1280px, calc(100% - 56px));
                margin:0 auto;
            }

            .shadow-soft{
                box-shadow:var(--shadow);
            }

            .card-hover{
                transition:transform .22s ease, box-shadow .22s ease;
            }

            .card-hover:hover{
                transform:translateY(-5px);
                box-shadow:var(--shadow-hover);
            }

            .section-title{
                font-size:34px;
                line-height:1.05;
                font-weight:900;
                letter-spacing:-.03em;
                color:#131313;
            }

            .food-card{
                border-radius:30px;
            }

            .food-card .food-body{
                padding:24px 24px 22px;
            }

            .food-card .food-name{
                font-size:21px;
                font-weight:900;
                line-height:1.18;
                letter-spacing:-.02em;
                color:#111827;
            }

            .price-now{
                font-size:24px;
                font-weight:950;
                color:var(--primary);
                line-height:1;
                letter-spacing:-.03em;
            }

            .price-old{
                color:#9ca3af;
                text-decoration:line-through;
                font-size:14px;
                margin-top:8px;
                font-weight:700;
            }

            .add-cart-btn{
                width:48px;
                height:48px;
                border-radius:999px;
                border:none;
                background:#fff3eb;
                color:var(--primary);
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:18px;
                transition:.18s ease;
                flex-shrink:0;
            }

            .add-cart-btn:hover{
                background:var(--primary);
                color:#fff;
                transform:translateY(-1px);
            }

            .soft-icon-box{
                width:80px;
                height:80px;
                border-radius:24px;
                display:flex;
                align-items:center;
                justify-content:center;
                box-shadow:0 10px 24px rgba(0,0,0,.05);
                margin:0 auto 12px;
                transition: all 0.3s ease;
            }

            .category-item.active .soft-icon-box {
                background: var(--primary) !important;
                color: white !important;
                transform: translateY(-5px);
                box-shadow: 0 12px 28px rgba(255,122,26,0.3);
            }
            
            .category-item.active i {
                color: white !important;
            }

            .category-item.active span {
                color: var(--primary) !important;
            }

            .pill{
                display:inline-flex;
                align-items:center;
                justify-content:center;
                padding:8px 14px;
                border-radius:999px;
                font-size:12px;
                font-weight:800;
                line-height:1;
                white-space:nowrap;
            }

            .pill-orange{
                background:#fff1e8;
                color:var(--primary);
            }

            .deal-badge{
                background:#ef4444;
                color:#fff;
                font-size:12px;
                font-weight:800;
                border-radius:999px;
                padding:9px 14px;
                display:inline-flex;
                align-items:center;
                gap:6px;
                box-shadow:0 10px 22px rgba(239,68,68,.20);
            }

            .line-clamp-2{
                display:-webkit-box;
                -webkit-line-clamp:2;
                -webkit-box-orient:vertical;
                line-clamp: 2;
                overflow:hidden;
            }
        </style>
    </head>
    <body>

        <c:set var="ctx" value="${pageContext.request.contextPath}" />

        <jsp:include page="header.jsp">
            <jsp:param name="activePage" value="menu" />
        </jsp:include>

        <main class="pb-24">
            
            <!-- Category Navigation -->
            <section class="bg-white border-b border-gray-100 py-10">
                <div class="container-click">
                    <h2 class="section-title mb-10 text-center md:text-left">DANH MỤC THỰC ĐƠN</h2>
                    
                    <div class="flex flex-wrap justify-center md:justify-start gap-8">
                        <a href="${ctx}/menu" class="category-item text-center group ${empty selectedCategory ? 'active' : ''}">
                            <div class="soft-icon-box bg-gray-50 text-gray-500 group-hover:bg-orange-50 group-hover:text-orange-500">
                                <i class="fa-solid fa-utensils text-[32px]"></i>
                            </div>
                            <span class="text-[15px] font-bold text-gray-600 transition group-hover:text-orange-500">Tất cả</span>
                        </a>

                        <a href="${ctx}/menu?category=Cơm%20trưa" class="category-item text-center group ${selectedCategory == 'Cơm trưa' ? 'active' : ''}">
                            <div class="soft-icon-box bg-orange-50 text-orange-500 group-hover:-translate-y-1 transition">
                                <i class="fa-solid fa-bowl-rice text-[32px]"></i>
                            </div>
                            <span class="text-[15px] font-bold text-gray-600">Cơm trưa</span>
                        </a>

                        <a href="${ctx}/menu?category=Bún/Phở" class="category-item text-center group ${selectedCategory == 'Bún/Phở' ? 'active' : ''}">
                            <div class="soft-icon-box bg-blue-50 text-blue-500 group-hover:-translate-y-1 transition">
                                <i class="fa-solid fa-bowl-food text-[32px]"></i>
                            </div>
                            <span class="text-[15px] font-bold text-gray-600">Bún/Phở</span>
                        </a>

                        <a href="${ctx}/menu?category=Pizza" class="category-item text-center group ${selectedCategory == 'Pizza' ? 'active' : ''}">
                            <div class="soft-icon-box bg-red-50 text-red-500 group-hover:-translate-y-1 transition">
                                <i class="fa-solid fa-pizza-slice text-[32px]"></i>
                            </div>
                            <span class="text-[15px] font-bold text-gray-600">Pizza</span>
                        </a>

                        <a href="${ctx}/menu?category=Trà%20sữa" class="category-item text-center group ${selectedCategory == 'Trà sữa' ? 'active' : ''}">
                            <div class="soft-icon-box bg-pink-50 text-pink-500 group-hover:-translate-y-1 transition">
                                <i class="fa-solid fa-mug-hot text-[32px]"></i>
                            </div>
                            <span class="text-[15px] font-bold text-gray-600">Trà sữa</span>
                        </a>

                        <a href="${ctx}/menu?category=Burger" class="category-item text-center group ${selectedCategory == 'Burger' ? 'active' : ''}">
                            <div class="soft-icon-box bg-amber-50 text-amber-500 group-hover:-translate-y-1 transition">
                                <i class="fa-solid fa-burger text-[32px]"></i>
                            </div>
                            <span class="text-[15px] font-bold text-gray-600">Burger</span>
                        </a>

                        <a href="${ctx}/menu?category=Đồ%20ngọt" class="category-item text-center group ${selectedCategory == 'Đồ ngọt' ? 'active' : ''}">
                            <div class="soft-icon-box bg-purple-50 text-purple-500 group-hover:-translate-y-1 transition">
                                <i class="fa-solid fa-ice-cream text-[32px]"></i>
                            </div>
                            <span class="text-[15px] font-bold text-gray-600">Đồ ngọt</span>
                        </a>
                    </div>
                </div>
            </section>

            <!-- Menu Content -->
            <section class="pt-16">
                <div class="container-click">
                    
                    <c:if test="${empty groupedFoods}">
                        <div class="bg-white rounded-[40px] border border-dashed border-gray-200 py-32 text-center shadow-soft">
                            <i class="fa-solid fa-utensils text-7xl text-gray-200 mb-6"></i>
                            <h3 class="text-2xl font-black text-gray-900">Không tìm thấy món nào</h3>
                            <p class="text-gray-500 mt-2 font-medium">Bạn hãy thử chọn danh mục khác nhé!</p>
                            <a href="${ctx}/menu" class="mt-8 inline-flex items-center justify-center h-14 px-8 rounded-full bg-orange-500 text-white font-black text-[16px] hover:bg-orange-600 transition shadow-lg shadow-orange-200">
                                Xem tất cả thực đơn
                            </a>
                        </div>
                    </c:if>

                    <c:forEach var="entry" items="${groupedFoods}">
                        <div class="mb-20">
                            <div class="flex items-center gap-4 mb-10">
                                <h3 class="text-[28px] font-black text-gray-900 uppercase tracking-tight">${entry.key}</h3>
                                <div class="h-px flex-1 bg-gray-100"></div>
                                <span class="bg-orange-50 text-orange-500 font-black px-4 py-1.5 rounded-full text-sm">
                                    ${entry.value.size()} món
                                </span>
                            </div>

                            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-8">
                                <c:forEach var="f" items="${entry.value}">
                                    <div class="food-card bg-white overflow-hidden border border-gray-100 shadow-soft card-hover flex flex-col">
                                        <div class="relative h-[240px] overflow-hidden bg-gray-50">
                                            <c:choose>
                                                <c:when test="${not empty f.imageUrl}">
                                                    <img src="${f.imageUrl.startsWith('http') ? f.imageUrl : ctx.concat(f.imageUrl)}" 
                                                         alt="${f.name}" class="w-full h-full object-cover">
                                                </c:when>
                                                <c:otherwise>
                                                    <img src="https://placehold.co/600x400/orange/white?text=ClickEat" alt="${f.name}" class="w-full h-full object-cover">
                                                </c:otherwise>
                                            </c:choose>
                                            <c:if test="${f.discountPercent > 0}">
                                                <span class="absolute left-4 top-4 deal-badge">
                                                    -${f.discountPercent}% OFF
                                                </span>
                                            </c:if>
                                        </div>

                                        <div class="food-body flex flex-col flex-1">
                                            <div class="text-[11px] uppercase font-black tracking-widest text-orange-500 mb-3 flex items-center gap-2">
                                                <i class="fa-solid fa-store text-[10px]"></i>
                                                ${f.merchantName}
                                            </div>

                                            <h4 class="food-name line-clamp-1 mb-2">
                                                ${f.name}
                                            </h4>

                                            <p class="text-gray-500 text-[14px] line-clamp-2 leading-relaxed mb-5 min-h-[40px]">
                                                ${empty f.description ? 'Món ngon mỗi ngày từ nhà hàng.' : f.description}
                                            </p>

                                            <div class="mt-auto pt-6 border-t border-gray-50 flex items-end justify-between">
                                                <div>
                                                    <div class="price-now">
                                                        <fmt:formatNumber value="${f.price}" type="number" groupingUsed="true" maxFractionDigits="0" />đ
                                                    </div>
                                                    <c:if test="${f.originalPrice > f.price}">
                                                        <div class="price-old">
                                                            <fmt:formatNumber value="${f.originalPrice}" type="number" groupingUsed="true" maxFractionDigits="0" />đ
                                                        </div>
                                                    </c:if>
                                                </div>

                                                <a href="${ctx}/cart?action=add&id=${f.id}" class="add-cart-btn" title="Thêm vào giỏ hàng">
                                                    <i class="fa-solid fa-cart-plus"></i>
                                                </a>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </section>
        </main>

        <jsp:include page="footer.jsp" />

    </body>
</html>
