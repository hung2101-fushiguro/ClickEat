<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/responsive-global.css">
        <title>Về chúng tôi - ClickEat</title>
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <link rel="shortcut icon" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800;900&display=swap" rel="stylesheet">
        <style>
            body {
                font-family: 'Inter', sans-serif;
            }
        </style>
    </head>
    <body class="bg-[#fafbfc] text-gray-800">

        <jsp:include page="header.jsp">
            <jsp:param name="activePage" value="about" />
        </jsp:include>

        <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10 overflow-hidden">

            <div class="text-sm font-bold text-gray-400 mb-8 flex items-center gap-2">
                <a href="${pageContext.request.contextPath}/home" class="hover:text-gray-700 transition">Trang chủ</a> 
                <span class="text-gray-300">/</span> 
                <span class="text-orange-500">Về chúng tôi</span>
            </div>

            <section class="bg-[#1c1a19] rounded-[2.5rem] p-10 md:p-16 lg:p-24 text-white mb-10 shadow-2xl relative overflow-hidden">
                <div class="relative z-10 max-w-3xl">
                    <span class="bg-orange-500 text-white text-xs font-black px-5 py-2.5 rounded-full uppercase tracking-widest mb-8 inline-block shadow-lg">
                        Câu chuyện của chúng tôi
                    </span>

                    <h1 class="text-5xl md:text-6xl lg:text-[5.5rem] font-black leading-[1.05] mb-8 tracking-tight">
                        Kết nối đam mê <br class="hidden md:block"/>
                        <span class="text-orange-500">ẩm thực</span> Việt
                    </h1>

                    <p class="text-gray-300 text-lg md:text-xl leading-relaxed max-w-2xl font-medium">
                        ClickEat không chỉ là một ứng dụng giao hàng. Chúng tôi là cầu nối mang những hương vị tinh túy nhất từ các gian bếp tâm huyết đến tận tay bạn, nhanh chóng và vẹn tròn hương vị.
                    </p>
                </div>

                <div class="absolute -top-32 -right-32 w-[30rem] h-[30rem] bg-orange-500/20 rounded-full blur-[100px] pointer-events-none"></div>
            </section>

            <section class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-24 px-2 lg:px-4">
                <div class="bg-white rounded-3xl p-8 shadow-[0_20px_50px_rgba(0,0,0,0.05)] border border-gray-50 text-center flex flex-col items-center justify-center hover:-translate-y-2 transition-transform duration-300">
                    <div class="w-14 h-14 bg-orange-50 text-orange-500 rounded-2xl flex items-center justify-center text-2xl mb-4">
                        <i class="fa-solid fa-store"></i>
                    </div>
                    <h3 class="text-3xl font-black text-gray-900 mb-1">2,500+</h3>
                    <p class="text-[10px] font-black text-gray-400 uppercase tracking-widest">Nhà hàng đối tác</p>
                </div>

                <div class="bg-white rounded-3xl p-8 shadow-[0_20px_50px_rgba(0,0,0,0.05)] border border-gray-50 text-center flex flex-col items-center justify-center hover:-translate-y-2 transition-transform duration-300">
                    <div class="w-14 h-14 bg-orange-50 text-orange-500 rounded-2xl flex items-center justify-center text-2xl mb-4">
                        <i class="fa-solid fa-user-group"></i>
                    </div>
                    <h3 class="text-3xl font-black text-gray-900 mb-1">1.2M+</h3>
                    <p class="text-[10px] font-black text-gray-400 uppercase tracking-widest">Người dùng tin tưởng</p>
                </div>

                <div class="bg-white rounded-3xl p-8 shadow-[0_20px_50px_rgba(0,0,0,0.05)] border border-gray-50 text-center flex flex-col items-center justify-center hover:-translate-y-2 transition-transform duration-300">
                    <div class="w-14 h-14 bg-orange-50 text-orange-500 rounded-2xl flex items-center justify-center text-2xl mb-4">
                        <i class="fa-solid fa-truck-fast"></i>
                    </div>
                    <h3 class="text-3xl font-black text-gray-900 mb-1">500K+</h3>
                    <p class="text-[10px] font-black text-gray-400 uppercase tracking-widest">Đơn hàng mỗi tháng</p>
                </div>

                <div class="bg-white rounded-3xl p-8 shadow-[0_20px_50px_rgba(0,0,0,0.05)] border border-gray-50 text-center flex flex-col items-center justify-center hover:-translate-y-2 transition-transform duration-300">
                    <div class="w-14 h-14 bg-orange-50 text-orange-500 rounded-2xl flex items-center justify-center text-2xl mb-4">
                        <i class="fa-solid fa-star"></i>
                    </div>
                    <h3 class="text-3xl font-black text-gray-900 mb-1">4.9/5</h3>
                    <p class="text-[10px] font-black text-gray-400 uppercase tracking-widest">Đánh giá tích cực</p>
                </div>
            </section>

            <section class="grid grid-cols-1 lg:grid-cols-2 gap-16 lg:gap-24 items-center mb-32 px-4 lg:px-8">
                <div class="relative order-2 lg:order-1">
                    <div class="absolute -inset-6 bg-gradient-to-tr from-orange-100 to-orange-50 rounded-[3rem] transform -rotate-3 z-0"></div>
                    <div class="rounded-[2.5rem] overflow-hidden shadow-2xl relative z-10 border-[8px] border-white">
                        <img src="https://images.unsplash.com/photo-1522071820081-009f0129c71c?ixlib=rb-4.0.3&auto=format&fit=crop&w=1200&q=80" alt="Đội ngũ ClickEat" class="w-full h-full object-cover aspect-[4/3] hover:scale-105 transition-transform duration-700">
                    </div>
                </div>

                <div class="order-1 lg:order-2">
                    <span class="bg-orange-50 text-orange-600 text-[10px] font-black px-4 py-2 rounded-full uppercase tracking-widest mb-6 inline-flex items-center gap-2">
                        <i class="fa-solid fa-rocket"></i> Tầm nhìn 2025
                    </span>

                    <h2 class="text-4xl lg:text-5xl font-black text-gray-900 leading-[1.1] mb-6 tracking-tight">
                        Trở thành nền tảng <span class="text-orange-500">Food-Tech</span> số 1 tại Đông Nam Á
                    </h2>

                    <p class="text-gray-500 text-lg leading-relaxed mb-10 font-medium">
                        Chúng tôi tin rằng công nghệ có thể làm cuộc sống tốt đẹp hơn. Bằng việc tối ưu hóa quy trình giao vận thông qua AI, ClickEat cam kết mang lại trải nghiệm ẩm thực liền mạch, giúp các nhà hàng nhỏ số hóa và người dùng tiếp cận món ngon dễ dàng hơn bao giờ hết.
                    </p>

                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-8">
                        <div>
                            <h4 class="text-lg font-bold text-gray-900 mb-3 flex items-center gap-3">
                                <span class="w-8 h-8 rounded-full bg-orange-100 text-orange-500 flex items-center justify-center text-sm"><i class="fa-solid fa-gauge-high"></i></span>
                                Tốc độ
                            </h4>
                            <p class="text-gray-500 text-sm leading-relaxed font-medium">Giao hàng thần tốc trong 20 phút là mục tiêu hàng đầu của chúng tôi.</p>
                        </div>
                        <div>
                            <h4 class="text-lg font-bold text-gray-900 mb-3 flex items-center gap-3">
                                <span class="w-8 h-8 rounded-full bg-orange-100 text-orange-500 flex items-center justify-center text-sm"><i class="fa-solid fa-shield-check"></i></span>
                                Chất lượng
                            </h4>
                            <p class="text-gray-500 text-sm leading-relaxed font-medium">Mọi đối tác nhà hàng đều được kiểm duyệt vệ sinh ATTP nghiêm ngặt.</p>
                        </div>
                    </div>
                </div>
            </section>

            <section class="bg-[#ff7a28] rounded-[3rem] p-12 md:p-20 text-white shadow-xl relative overflow-hidden mb-16">
                <div class="absolute inset-0 opacity-[0.03] pointer-events-none" style="background-image: radial-gradient(#fff 2px, transparent 2px); background-size: 30px 30px;"></div>

                <h2 class="text-3xl md:text-[2.5rem] font-black text-center mb-16 uppercase tracking-widest relative z-10">Giá trị cốt lõi</h2>

                <div class="grid grid-cols-1 md:grid-cols-3 gap-12 lg:gap-16 text-center relative z-10">
                    <div class="flex flex-col items-center">
                        <div class="w-16 h-16 rounded-[1.2rem] border-2 border-white/40 flex items-center justify-center text-2xl mb-6 bg-white/10 backdrop-blur-md">
                            <i class="fa-regular fa-lightbulb"></i>
                        </div>
                        <h3 class="text-2xl font-bold mb-3">Sáng tạo</h3>
                        <p class="text-white/90 font-medium leading-relaxed px-2 text-sm md:text-base">Luôn tìm ra giải pháp công nghệ mới để cải thiện dịch vụ.</p>
                    </div>

                    <div class="flex flex-col items-center">
                        <div class="w-16 h-16 rounded-[1.2rem] border-2 border-white/40 flex items-center justify-center text-2xl mb-6 bg-white/10 backdrop-blur-md">
                            <i class="fa-regular fa-heart"></i>
                        </div>
                        <h3 class="text-2xl font-bold mb-3">Tận tâm</h3>
                        <p class="text-white/90 font-medium leading-relaxed px-2 text-sm md:text-base">Lắng nghe và giải quyết mọi vấn đề của khách hàng 24/7.</p>
                    </div>

                    <div class="flex flex-col items-center">
                        <div class="w-16 h-16 rounded-[1.2rem] border-2 border-white/40 flex items-center justify-center text-2xl mb-6 bg-white/10 backdrop-blur-md">
                            <i class="fa-solid fa-leaf"></i>
                        </div>
                        <h3 class="text-2xl font-bold mb-3">Bền vững</h3>
                        <p class="text-white/90 font-medium leading-relaxed px-2 text-sm md:text-base">Hợp tác công bằng, hỗ trợ cộng đồng cùng phát triển.</p>
                    </div>
                </div>
            </section>

        </main>

        <jsp:include page="footer.jsp" />

    </body>
</html>