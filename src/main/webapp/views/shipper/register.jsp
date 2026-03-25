<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Đăng ký Đối tác Giao hàng - ClickEat</title>
    <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/assets/images/shipperlogo.png">
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body class="bg-gray-100 flex items-center justify-center min-h-screen p-4">

    <div class="bg-white rounded-3xl shadow-xl w-full max-w-4xl flex overflow-hidden">
        
        <div class="hidden lg:flex w-1/2 bg-orange-500 p-12 flex-col justify-between relative overflow-hidden text-white">
            <div class="relative z-10">
                <div class="w-12 h-12 bg-white rounded-xl flex items-center justify-center mb-6 shadow-sm">
                    <i class="fa-solid fa-motorcycle text-orange-500 text-xl"></i>
                </div>
                <h1 class="text-4xl font-extrabold mb-4 leading-tight">Trở thành Đối tác<br/>ClickEat Shipper</h1>
                <p class="text-orange-100 text-lg">Giao thức ăn nhanh chóng, kiếm tiền linh hoạt và chủ động thời gian của chính bạn.</p>
            </div>
            
            <div class="relative z-10 space-y-4">
                <div class="flex items-center gap-3"><i class="fa-solid fa-circle-check text-green-300"></i> Đăng ký miễn phí, duyệt nhanh</div>
                <div class="flex items-center gap-3"><i class="fa-solid fa-circle-check text-green-300"></i> Thu nhập hấp dẫn, thanh toán siêu tốc</div>
                <div class="flex items-center gap-3"><i class="fa-solid fa-circle-check text-green-300"></i> Tự do bật/tắt nhận đơn bất cứ lúc nào</div>
            </div>
            <div class="absolute -bottom-24 -right-24 opacity-20">
                <i class="fa-solid fa-burger text-[250px]"></i>
            </div>
        </div>

        <div class="w-full lg:w-1/2 p-8 sm:p-12">
            <h2 class="text-2xl font-bold text-gray-900 mb-6">Tạo tài khoản Shipper</h2>
            
            <c:if test="${not empty errorMsg}">
                <div class="bg-red-50 text-red-500 p-4 rounded-xl mb-6 flex items-center gap-3 text-sm font-medium border border-red-100">
                    <i class="fa-solid fa-circle-exclamation"></i> ${errorMsg}
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/shipper/register" method="POST" class="space-y-6">
                
                <div>
                    <h3 class="text-sm font-bold text-gray-400 uppercase tracking-wider mb-4 border-b pb-2">1. Thông tin cá nhân</h3>
                    <div class="space-y-4">
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-1">Họ và tên</label>
                            <input type="text" name="fullName" required placeholder="Nguyễn Văn A" class="w-full border border-gray-300 rounded-xl px-4 py-2.5 focus:ring-orange-500 focus:border-orange-500 outline-none transition bg-gray-50 focus:bg-white">
                        </div>
                        <div class="grid grid-cols-2 gap-4">
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-1">Số điện thoại</label>
                                <input type="text" name="phone" required placeholder="09xxxxxxxxx" class="w-full border border-gray-300 rounded-xl px-4 py-2.5 focus:ring-orange-500 focus:border-orange-500 outline-none transition bg-gray-50 focus:bg-white">
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-1">Mật khẩu</label>
                                <input type="password" name="password" required placeholder="••••••••" class="w-full border border-gray-300 rounded-xl px-4 py-2.5 focus:ring-orange-500 focus:border-orange-500 outline-none transition bg-gray-50 focus:bg-white">
                            </div>
                        </div>
                    </div>
                </div>

                <div class="pt-2">
                    <h3 class="text-sm font-bold text-gray-400 uppercase tracking-wider mb-4 border-b pb-2">2. Phương tiện giao hàng</h3>
                    <div class="space-y-4">
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-1">Loại phương tiện</label>
                            <select name="vehicleType" required class="w-full border border-gray-300 rounded-xl px-4 py-2.5 focus:ring-orange-500 focus:border-orange-500 outline-none transition bg-gray-50 focus:bg-white cursor-pointer">
                                <option value="MOTORBIKE">Xe máy</option>
                                <option value="BIKE">Xe đạp / Xe điện</option>
                            </select>
                        </div>
                        <div class="grid grid-cols-2 gap-4">
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-1">Tên xe</label>
                                <input type="text" name="vehicleName" required placeholder="VD: Honda Wave" class="w-full border border-gray-300 rounded-xl px-4 py-2.5 focus:ring-orange-500 focus:border-orange-500 outline-none transition bg-gray-50 focus:bg-white">
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-1">Biển số xe</label>
                                <input type="text" name="licensePlate" required placeholder="VD: 29X1-123.45" class="w-full border border-gray-300 rounded-xl px-4 py-2.5 focus:ring-orange-500 focus:border-orange-500 outline-none transition bg-gray-50 focus:bg-white">
                            </div>
                        </div>
                    </div>
                </div>

                <button type="submit" class="w-full mt-8 bg-gray-900 text-white py-3.5 rounded-xl font-bold text-lg hover:bg-orange-500 transition-colors shadow-lg">
                    Hoàn tất Đăng ký
                </button>
                
                <p class="text-center text-sm text-gray-500 mt-6">
                    Đã có tài khoản? <a href="${pageContext.request.contextPath}/login" class="text-orange-500 font-bold hover:underline">Đăng nhập ngay</a>
                </p>
            </form>
        </div>
    </div>

</body>
</html>