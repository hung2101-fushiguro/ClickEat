<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ClickEat - Đăng ký shipper / merchant</title>
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <link rel="shortcut icon" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    </head>
    <body class="bg-[#f4f5f7] text-gray-900">
        <jsp:include page="/views/web/header.jsp">
            <jsp:param name="activePage" value="profile" />
        </jsp:include>

        <main class="max-w-7xl mx-auto px-6 py-8">
            <div class="mb-8">
                <div class="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-orange-100 text-orange-600 text-sm font-extrabold">
                    <i class="fa-solid fa-store"></i>
                    Phát triển cùng ClickEat
                </div>
                <h1 class="mt-4 text-4xl font-black tracking-tight">Đăng ký shipper / merchant</h1>
                <p class="mt-2 text-gray-500 text-lg">
                    Mở rộng vai trò của bạn để giao hàng hoặc trở thành đối tác kinh doanh trên nền tảng.
                </p>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-[280px_minmax(0,1fr)] gap-7">
                <jsp:include page="sidebar.jsp">
                    <jsp:param name="menu" value="register-role" />
                </jsp:include>

                <section class="min-w-0 grid grid-cols-1 xl:grid-cols-2 gap-6">
                    <div class="bg-white rounded-[32px] border border-gray-200 p-7 shadow-[0_10px_30px_rgba(15,23,42,.06)]">
                        <div class="w-16 h-16 rounded-2xl bg-orange-100 text-orange-500 flex items-center justify-center text-2xl">
                            <i class="fa-solid fa-motorcycle"></i>
                        </div>

                        <h2 class="mt-5 text-2xl font-black">Đăng ký Shipper</h2>
                        <p class="mt-3 text-gray-500 leading-7">
                            Phù hợp nếu bạn muốn giao đơn, kiếm thêm thu nhập và chủ động thời gian làm việc.
                        </p>

                        <ul class="mt-6 space-y-3 text-sm text-gray-600">
                            <li class="flex items-center gap-3">
                                <i class="fa-solid fa-circle-check text-green-500"></i>
                                Quản lý đơn giao theo thời gian thực
                            </li>
                            <li class="flex items-center gap-3">
                                <i class="fa-solid fa-circle-check text-green-500"></i>
                                Theo dõi lịch sử giao hàng
                            </li>
                            <li class="flex items-center gap-3">
                                <i class="fa-solid fa-circle-check text-green-500"></i>
                                Rút tiền và quản lý ví shipper
                            </li>
                        </ul>

                        <a href="${pageContext.request.contextPath}/shipper/register"
                        class="inline-flex mt-8 h-12 px-6 items-center justify-center rounded-full bg-orange-500 text-white font-extrabold hover:bg-orange-600 transition shadow">
                        Đăng ký làm shipper
                    </a>
                </div>

                <div class="bg-white rounded-[32px] border border-gray-200 p-7 shadow-[0_10px_30px_rgba(15,23,42,.06)]">
                    <div class="w-16 h-16 rounded-2xl bg-orange-100 text-orange-500 flex items-center justify-center text-2xl">
                        <i class="fa-solid fa-store"></i>
                    </div>

                    <h2 class="mt-5 text-2xl font-black">Đăng ký Merchant</h2>
                    <p class="mt-3 text-gray-500 leading-7">
                        Dành cho cửa hàng, quán ăn hoặc thương hiệu muốn mở bán và phát triển doanh thu trên ClickEat.
                    </p>

                    <ul class="mt-6 space-y-3 text-sm text-gray-600">
                        <li class="flex items-center gap-3">
                            <i class="fa-solid fa-circle-check text-green-500"></i>
                            Quản lý menu, đơn hàng và voucher
                        </li>
                        <li class="flex items-center gap-3">
                            <i class="fa-solid fa-circle-check text-green-500"></i>
                            Theo dõi doanh thu và đánh giá
                        </li>
                        <li class="flex items-center gap-3">
                            <i class="fa-solid fa-circle-check text-green-500"></i>
                            Hỗ trợ mở rộng kinh doanh trên nền tảng
                        </li>
                    </ul>

                    <a href="${pageContext.request.contextPath}/merchant-register"
                    class="inline-flex mt-8 h-12 px-6 items-center justify-center rounded-full border border-orange-200 text-orange-600 font-extrabold hover:bg-orange-50 transition">
                    Đăng ký merchant
                </a>
            </div>
        </section>
    </div>
</main>
<jsp:include page="footer.jsp" />
</body>
</html>