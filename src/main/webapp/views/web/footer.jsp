<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<footer class="bg-gray-900 text-gray-300 py-12">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="grid grid-cols-1 md:grid-cols-4 gap-8">
            <div class="col-span-1 md:col-span-2">
                <div class="mb-4">
                    <a href="${ctx}/home" class="inline-flex items-center">
                        <img src="${ctx}/assets/images/FullLogo.jpg"
                             alt="ClickEat"
                             class="h-16 w-auto max-w-[300px] object-contain rounded-lg"
                             onerror="this.style.display='none';" />
                    </a>
                </div>

                <p class="text-gray-400 max-w-sm">
                    Giao đồ ăn nhanh chóng, tiện lợi đến tận cửa nhà bạn. Trải nghiệm hương vị tuyệt vời nhất ngay hôm nay.
                </p>
            </div>

            <div>
                <h3 class="text-white font-semibold mb-4">ClickEat</h3>
                <ul class="space-y-2">
                    <li><a href="#" class="hover:text-white transition-colors">Về chúng tôi</a></li>
                    <li><a href="#" class="hover:text-white transition-colors">Nghề nghiệp</a></li>
                    <li><a href="#" class="hover:text-white transition-colors">Liên hệ</a></li>
                </ul>
            </div>

            <div>
                <h3 class="text-white font-semibold mb-4">Pháp lý</h3>
                <ul class="space-y-2">
                    <li><a href="#" class="hover:text-white transition-colors">Điều khoản</a></li>
                    <li><a href="#" class="hover:text-white transition-colors">Bảo mật</a></li>
                </ul>
            </div>
        </div>

        <div class="border-t border-gray-800 mt-12 pt-8 flex flex-col md:flex-row justify-between items-center gap-4">
            <p>© 2026 ClickEat. All rights reserved.</p>
        </div>
    </div>
</footer>