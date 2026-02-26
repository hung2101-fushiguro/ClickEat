<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<header class="bg-white shadow-sm sticky top-0 z-50">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between items-center h-16">
            <div class="flex items-center">
                <a href="${pageContext.request.contextPath}/home" class="flex items-center gap-2">
                    <div class="w-8 h-8 bg-orange-500 rounded-lg flex items-center justify-center">
                        <i class="fa-solid fa-utensils text-white font-bold"></i>
                    </div>
                    <span class="text-xl font-bold text-gray-900">ClickEat</span>
                </a>
            </div>

            <nav class="hidden md:flex space-x-8">
                <a href="${pageContext.request.contextPath}/about" class="text-gray-600 hover:text-orange-500 font-medium transition-colors">Về chúng tôi</a>
                <a href="${pageContext.request.contextPath}/menu" class="text-gray-600 hover:text-orange-500 font-medium transition-colors">Thực đơn</a>
                <a href="${pageContext.request.contextPath}/store" class="text-gray-600 hover:text-orange-500 font-medium transition-colors">Cửa hàng</a>
                <a href="${pageContext.request.contextPath}/aichat" class="text-orange-500 hover:text-orange-600 font-bold flex items-center gap-1 transition-colors">
                    <i class="fa-solid fa-wand-magic-sparkles"></i> AI Gợi ý
                </a>
            </nav>

            <div class="flex items-center gap-4">
                
                <a href="${pageContext.request.contextPath}/cart" class="p-2 text-gray-600 hover:text-gray-900 transition-colors relative block cursor-pointer">
                    <i class="fa-solid fa-cart-shopping text-xl"></i>
                    
                    <span class="absolute top-0 right-0 bg-orange-500 text-white text-xs font-bold rounded-full h-5 w-5 flex items-center justify-center transform translate-x-1 -translate-y-1">
                        ${cartCount != null ? cartCount : 0}
                    </span>
                </a>

                <c:choose>
                    <c:when test="${not empty sessionScope.account}">
                        <div class="flex items-center gap-3">
                            <span class="text-sm font-medium text-gray-700 hidden sm:block">Chào, ${sessionScope.account.fullName}</span>
                            <a href="${pageContext.request.contextPath}/logout" class="text-sm text-red-500 hover:text-red-700 font-medium bg-red-50 px-3 py-1.5 rounded-lg">Đăng xuất</a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/login" class="bg-gray-900 text-white px-5 py-2 rounded-lg text-sm font-medium hover:bg-gray-800 transition-colors">
                            Đăng nhập
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</header>