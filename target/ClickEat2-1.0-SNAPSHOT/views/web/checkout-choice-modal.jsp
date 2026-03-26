<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<c:if test="${empty sessionScope.account}">
    <div id="checkoutChoiceOverlay"
         class="fixed inset-0 bg-black/45 hidden z-[100]"></div>

    <div id="checkoutChoiceModal"
         class="fixed inset-0 hidden z-[101]">
        <div class="w-full h-full flex items-center justify-center p-4">
            <div class="w-full max-w-[560px] bg-white rounded-[32px] shadow-[0_30px_80px_rgba(15,23,42,.22)] p-8 md:p-9 relative">

                <div class="text-center mb-7">
                    <h3 class="text-[42px] leading-none tracking-[-0.04em] font-black text-gray-900">
                        Tiếp tục đặt hàng
                    </h3>
                    <p class="mt-4 text-[17px] leading-relaxed text-[#8e715d] max-w-[430px] mx-auto">
                        Bạn muốn đặt nhanh hay đăng nhập để quản lý đơn hàng tốt hơn?
                    </p>
                </div>

                <div class="space-y-4">
                    <a href="${ctx}/guest-checkout"
                       class="group flex items-start gap-4 rounded-[24px] border-2 border-orange-500 bg-[#fffaf6] px-5 py-5 hover:shadow-md transition">
                        <div class="w-12 h-12 rounded-full bg-orange-500 text-white flex items-center justify-center text-xl shrink-0">
                            <i class="fa-solid fa-bolt"></i>
                        </div>

                        <div class="flex-1 min-w-0">
                            <div class="flex items-center justify-between gap-3">
                                <div class="text-[30px] font-black text-gray-900 leading-none">
                                    Đặt nhanh
                                </div>
                                <span class="px-3 py-1 rounded-full bg-orange-500 text-white text-[11px] font-black uppercase tracking-wide shrink-0">
                                    Nhanh
                                </span>
                            </div>

                            <div class="mt-1 text-sm font-semibold text-[#8e715d]">
                                (không cần đăng nhập)
                            </div>

                            <p class="mt-2 text-[15px] leading-relaxed text-[#8e715d]">
                                Chỉ cần xác thực số điện thoại, theo dõi đơn hàng qua mã đơn.
                            </p>
                        </div>
                    </a>

                    <a href="${ctx}/login?redirect=${ctx}/checkout"
                       class="group flex items-start gap-4 rounded-[24px] border border-[#eadfd7] bg-white px-5 py-5 hover:border-orange-300 hover:bg-[#fffdfa] transition">
                        <div class="w-12 h-12 rounded-full bg-[#f5f1ed] text-gray-800 flex items-center justify-center text-xl shrink-0">
                            <i class="fa-solid fa-user"></i>
                        </div>

                        <div class="flex-1 min-w-0">
                            <div class="flex items-center justify-between gap-3">
                                <div class="text-[30px] font-black text-gray-900 leading-none">
                                    Đăng nhập để đặt hàng
                                </div>
                                <span class="px-3 py-1 rounded-full bg-[#fff1e8] text-orange-500 text-[11px] font-black uppercase tracking-wide shrink-0">
                                    Khuyến nghị
                                </span>
                            </div>

                            <p class="mt-3 text-[15px] leading-relaxed text-[#8e715d]">
                                Lưu lịch sử đơn, theo dõi tiến trình trong hồ sơ cá nhân.
                            </p>
                        </div>
                    </a>
                </div>

                <button type="button"
                        onclick="closeCheckoutChoiceModal()"
                        class="mt-6 w-full h-12 rounded-full bg-[#f3eeea] hover:bg-[#ebe4de] text-gray-900 font-black transition">
                    Đóng
                </button>
            </div>
        </div>
    </div>

    <script>
        function openCheckoutChoiceModal() {
            const overlay = document.getElementById('checkoutChoiceOverlay');
            const modal = document.getElementById('checkoutChoiceModal');
            if (overlay)
                overlay.classList.remove('hidden');
            if (modal)
                modal.classList.remove('hidden');
            document.body.style.overflow = 'hidden';
        }

        function closeCheckoutChoiceModal() {
            const overlay = document.getElementById('checkoutChoiceOverlay');
            const modal = document.getElementById('checkoutChoiceModal');
            if (overlay)
                overlay.classList.add('hidden');
            if (modal)
                modal.classList.add('hidden');
            document.body.style.overflow = '';
        }

        document.addEventListener('DOMContentLoaded', function () {
            const overlay = document.getElementById('checkoutChoiceOverlay');
            if (overlay) {
                overlay.addEventListener('click', closeCheckoutChoiceModal);
            }

            document.addEventListener('keydown', function (e) {
                if (e.key === 'Escape') {
                    closeCheckoutChoiceModal();
                }
            });
        });
    </script>
</c:if>