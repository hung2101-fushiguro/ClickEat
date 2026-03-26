<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Đặt hàng nhanh - ClickEat</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    </head>
    <body class="bg-[#f7f5f3] text-gray-900 min-h-screen flex flex-col">

        <jsp:include page="header.jsp" />

        <main class="flex-grow max-w-7xl mx-auto w-full px-6 py-8">
            <a href="javascript:history.back()"
               class="inline-flex items-center gap-2 text-[#8e6d57] font-bold mb-6 hover:text-orange-500 transition">
                <i class="fa-solid fa-arrow-left"></i> Quay lại
            </a>

            <div class="mb-8">
                <div class="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-orange-100 text-orange-600 text-sm font-extrabold">
                    <i class="fa-solid fa-bolt"></i>
                    Đặt hàng nhanh
                </div>
                <h1 class="mt-4 text-4xl font-black tracking-tight">Thông tin giao hàng</h1>
                <p class="mt-2 text-gray-500 text-lg">Nhập thông tin cần thiết và xác thực OTP để tiếp tục thanh toán mà không cần đăng nhập.</p>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-2 bg-white rounded-[32px] overflow-hidden border border-[#eee4dc] shadow-[0_18px_45px_rgba(15,23,42,.08)]">
                <div class="relative min-h-[640px] bg-[#fff3eb]">
                    <img src="${pageContext.request.contextPath}/assets/images/guest-food-banner.jpg"
                         alt="Đặt hàng nhanh"
                         class="absolute inset-0 w-full h-full object-cover"
                         onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/images/default-store-cover.jpg';">
                    <div class="absolute inset-0 bg-gradient-to-t from-black/55 via-black/15 to-transparent"></div>
                    <div class="absolute left-8 right-8 bottom-8 text-white">
                        <div class="inline-flex items-center justify-center w-16 h-16 rounded-full bg-white/20 backdrop-blur text-3xl mb-5">
                            <i class="fa-solid fa-bag-shopping"></i>
                        </div>
                        <h2 class="text-4xl font-black">Đặt món cực nhanh</h2>
                        <p class="mt-3 text-lg text-white/90 leading-relaxed">
                            Chỉ cần xác thực số điện thoại, hoàn tất thông tin giao hàng và tiếp tục thanh toán với giỏ hàng hiện tại.
                        </p>
                    </div>
                </div>

                <div class="p-8 md:p-10">
                    <c:if test="${not empty message}">
                        <div class="mb-4 rounded-2xl border border-green-200 bg-green-50 text-green-700 px-4 py-3 font-semibold">
                            ${message}
                        </div>
                    </c:if>

                    <c:if test="${not empty error}">
                        <div class="mb-4 rounded-2xl border border-red-200 bg-red-50 text-red-700 px-4 py-3 font-semibold">
                            ${error}
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/guest-send-otp" method="post" class="space-y-4">
                        <div>
                            <label class="block text-sm font-bold text-gray-800 mb-2">Họ và tên</label>
                            <input type="text" name="fullName" value="${fullName}" required
                                   class="w-full h-12 px-4 rounded-2xl border border-gray-200 bg-white outline-none focus:ring-4 focus:ring-orange-100 focus:border-orange-400">
                        </div>

                        <div>
                            <label class="block text-sm font-bold text-gray-800 mb-2">Email</label>
                            <input type="email" name="email" value="${email}" required
                                   class="w-full h-12 px-4 rounded-2xl border border-gray-200 bg-white outline-none focus:ring-4 focus:ring-orange-100 focus:border-orange-400">
                        </div>

                        <div>
                            <label class="block text-sm font-bold text-gray-800 mb-2">Số điện thoại</label>
                            <input type="text" name="phone" value="${phone}" required placeholder="VD: 0900000012"
                                   class="w-full h-12 px-4 rounded-2xl border border-gray-200 bg-white outline-none focus:ring-4 focus:ring-orange-100 focus:border-orange-400">
                        </div>

                        <div>
                            <label class="block text-sm font-bold text-gray-800 mb-2">Địa chỉ giao hàng</label>
                            <textarea name="addressLine" required rows="4"
                                      class="w-full px-4 py-3 rounded-2xl border border-gray-200 bg-white outline-none focus:ring-4 focus:ring-orange-100 focus:border-orange-400 resize-none">${addressLine}</textarea>
                        </div>

                        <button type="submit"
                                class="w-full h-12 rounded-full bg-orange-500 hover:bg-orange-600 text-white font-black shadow">
                            Gửi mã OTP
                        </button>
                    </form>

                    <c:if test="${otpSent}">
                        <form action="${pageContext.request.contextPath}/guest-verify-otp" method="post"
                              class="mt-6 space-y-4 border-t border-gray-100 pt-6">
                            <input type="hidden" name="fullName" value="${fullName}">
                            <input type="hidden" name="email" value="${email}">
                            <input type="hidden" name="phone" value="${phone}">
                            <input type="hidden" name="addressLine" value="${addressLine}">

                            <div>
                                <label class="block text-sm font-bold text-gray-800 mb-2">Nhập mã OTP</label>
                                <input type="text" name="otpCode" required maxlength="6" placeholder="Nhập mã gồm 6 số"
                                       class="w-full h-12 px-4 rounded-2xl border border-gray-200 bg-white outline-none focus:ring-4 focus:ring-orange-100 focus:border-orange-400">
                            </div>

                            <button type="submit"
                                    class="w-full h-12 rounded-full bg-gray-900 hover:bg-black text-white font-black shadow">
                                Tiếp tục thanh toán
                            </button>
                        </form>
                    </c:if>
                </div>
            </div>
        </main>

        <jsp:include page="footer.jsp" />
    </body>
</html>