<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ClickEat - Đặt đồ ăn trực tuyến</title>
    
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body class="bg-gray-50 flex flex-col min-h-screen">

    <jsp:include page="header.jsp" />

    <main class="flex-grow">
        <section class="relative bg-orange-500 pt-20 pb-32 overflow-hidden">
            <div class="absolute inset-0 opacity-10">
                <div class="absolute inset-0" style="background-image: radial-gradient(#000 1px, transparent 1px); background-size: 24px 24px;"></div>
            </div>
            <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10 text-center">
                <h1 class="text-4xl md:text-6xl font-bold text-white mb-6">
                    Món ngon yêu thích,<br/>giao đến tận cửa
                </h1>
                <p class="text-orange-100 text-lg md:text-xl mb-10 max-w-2xl mx-auto">
                    Khám phá hàng ngàn món ăn ngon từ các nhà hàng địa phương. Giao hàng nhanh, phục vụ tận tâm.
                </p>
                
                <div class="max-w-2xl mx-auto bg-white p-2 rounded-2xl shadow-xl flex gap-2">
                    <div class="flex-1 flex items-center bg-gray-50 rounded-xl px-4">
                        <i class="fa-solid fa-magnifying-glass text-gray-400"></i>
                        <input type="text" placeholder="Tìm kiếm món ăn, nhà hàng..." class="w-full bg-transparent border-none outline-none py-3 px-3 text-gray-700">
                    </div>
                    <button class="bg-gray-900 text-white px-8 py-3 rounded-xl font-medium hover:bg-gray-800 transition-colors">
                        Tìm kiếm
                    </button>
                </div>
            </div>
        </section>

        <section class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
            <div class="flex justify-between items-end mb-8">
                <div>
                    <h2 class="text-2xl font-bold text-gray-900 mb-2">Gợi ý hôm nay</h2>
                    <p class="text-gray-600">Những món ăn ngon đang chờ bạn thưởng thức</p>
                </div>
                <a href="#" class="text-orange-500 font-medium hover:text-orange-600 flex items-center gap-1">
                    Xem tất cả <i class="fa-solid fa-arrow-right text-sm"></i>
                </a>
            </div>

            <c:if test="${empty foods}">
                <div class="text-center py-10">
                    <i class="fa-solid fa-box-open text-4xl text-gray-300 mb-4"></i>
                    <p class="text-gray-500 text-lg">Hệ thống đang cập nhật thực đơn, bạn vui lòng quay lại sau nhé!</p>
                </div>
            </c:if>

            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                <c:forEach var="f" items="${foods}">
                    <div class="bg-white rounded-2xl overflow-hidden border border-gray-100 shadow-sm hover:shadow-md transition-shadow group cursor-pointer flex flex-col">
                        <div class="relative h-48 overflow-hidden bg-gray-100">
                            <img src="${f.imageUrl}" alt="${f.name}" class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300">
                            
                            <c:if test="${f.fried}">
                                <div class="absolute top-3 left-3 bg-yellow-400 text-white text-xs font-bold px-2 py-1 rounded">
                                    Món chiên
                                </div>
                            </c:if>
                        </div>
                        
                        <div class="p-4 flex flex-col flex-grow">
                            <h3 class="text-lg font-bold text-gray-900 group-hover:text-orange-500 transition-colors line-clamp-1">${f.name}</h3>
                            <p class="text-gray-500 text-sm mt-1 line-clamp-2 min-h-[40px]">${f.description}</p>
                            
                            <div class="flex items-center justify-between border-t border-gray-100 pt-4 mt-auto">
                                <span class="text-orange-500 font-black text-lg">${f.price} VNĐ</span>
                                <a href="cart?action=add&id=${f.id}" class="bg-gray-100 w-10 h-10 rounded-xl flex items-center justify-center hover:bg-orange-500 hover:text-white transition-colors text-gray-600">
                                    <i class="fa-solid fa-plus"></i>
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