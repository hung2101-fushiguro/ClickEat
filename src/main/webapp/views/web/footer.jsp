<%@page contentType="text/html" pageEncoding="UTF-8"%>

<footer class="bg-gray-900 text-gray-300 py-12">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="grid grid-cols-1 md:grid-cols-4 gap-8">
            <div class="col-span-1 md:col-span-2">
                <div class="flex items-center gap-2 mb-4">
                    <div class="w-8 h-8 bg-orange-500 rounded-lg flex items-center justify-center">
                        <i class="fa-solid fa-utensils text-white font-bold"></i>
                    </div>
                    <span class="text-xl font-bold text-white">ClickEat</span>
                </div>
                <p class="text-gray-400 max-w-sm">
                    Giao đồ ăn nhanh chóng, tiện lợi đến tận cửa nhà bạn. Trải nghiệm hương vị tuyệt vời nhất ngay hôm nay.
                </p>
            </div>

            <div>
                <h3 class="text-white font-semibold mb-4">ClickEat</h3>
                <ul class="space-y-2">
                    <li><a href="${pageContext.request.contextPath}/about" class="hover:text-white transition-colors">Về chúng tôi</a></li>
                    <li><a href="${pageContext.request.contextPath}/home" class="hover:text-white transition-colors">Đặt món ngay</a></li>
                    <li><a href="${pageContext.request.contextPath}/register" class="hover:text-white transition-colors">Đăng ký tài khoản</a></li>
                </ul>
            </div>

            <div>
                <h3 class="text-white font-semibold mb-4">Tài khoản</h3>
                <ul class="space-y-2">
                    <li><a href="${pageContext.request.contextPath}/my-orders" class="hover:text-white transition-colors">Đơn hàng của tôi</a></li>
                    <li><a href="${pageContext.request.contextPath}/my-account" class="hover:text-white transition-colors">Hồ sơ cá nhân</a></li>
                    <li><a href="${pageContext.request.contextPath}/cart" class="hover:text-white transition-colors">Giỏ hàng</a></li>
                </ul>
            </div>
        </div>

        <div class="border-t border-gray-800 mt-12 pt-8 flex flex-col md:flex-row justify-between items-center gap-4">
            <p>© 2026 ClickEat. All rights reserved.</p>
        </div>
    </div>
</footer>