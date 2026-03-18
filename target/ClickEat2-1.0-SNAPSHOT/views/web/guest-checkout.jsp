<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thông tin đặt hàng - ClickEat</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body class="bg-[#f7f5f3] min-h-screen">
    <c:set var="ctx" value="${pageContext.request.contextPath}" />

    <div class="min-h-screen flex items-center justify-center p-6">
        <div class="w-full max-w-[920px] bg-white rounded-[28px] overflow-hidden shadow-xl grid grid-cols-1 md:grid-cols-2">
            <div class="p-8 border-r border-[#f1ebe6]">
                <h2 class="text-[42px] font-black tracking-[-0.04em] flex items-center gap-3">
                    <i class="fa-regular fa-user text-orange-500 text-[28px]"></i>
                    Thông tin khách hàng
                </h2>

                <form action="${ctx}/checkout-pending" method="post" class="mt-8 space-y-5">
                    <div>
                        <label class="block font-semibold mb-2">Họ và tên*</label>
                        <input type="text" name="receiverName" placeholder="Nhập họ và tên"
                               class="w-full h-14 rounded-[18px] border border-[#eadfd7] px-4 outline-none">
                    </div>

                    <div>
                        <label class="block font-semibold mb-2">Email*</label>
                        <input type="email" name="email" placeholder="example@email.com"
                               class="w-full h-14 rounded-[18px] border border-[#eadfd7] px-4 outline-none">
                    </div>

                    <div>
                        <label class="block font-semibold mb-2">Số điện thoại*</label>
                        <div class="flex gap-3">
                            <input type="text" name="receiverPhone" placeholder="09xx xxx xxx"
                                   class="flex-1 h-14 rounded-[18px] border border-[#eadfd7] px-4 outline-none">
                            <button type="button"
                                    class="h-14 px-6 rounded-[18px] bg-orange-50 text-orange-500 font-black">
                                Gửi OTP
                            </button>
                        </div>
                    </div>

                    <div>
                        <label class="block font-semibold mb-2">Địa chỉ giao hàng*</label>
                        <textarea name="deliveryAddress" placeholder="Nhập địa chỉ chi tiết (Số nhà, tên đường, phường/xã...)"
                                  class="w-full h-28 rounded-[18px] border border-[#eadfd7] px-4 py-4 outline-none resize-none"></textarea>
                    </div>

                    <button type="submit"
                            class="w-full h-14 rounded-[18px] bg-gray-200 text-gray-500 font-black flex items-center justify-center gap-3">
                        Tiếp tục thanh toán <i class="fa-solid fa-angle-right"></i>
                    </button>
                </form>
            </div>

            <div class="p-8 bg-[#fcfbfa]">
                <h2 class="text-[34px] font-black tracking-[-0.04em]">ĐƠN HÀNG CỦA BẠN</h2>

                <div class="mt-8">
                    <div class="flex items-center gap-4">
                        <img src="https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?q=80&w=400&auto=format&fit=crop"
                             class="w-16 h-16 rounded-[16px] object-cover"
                             alt="Món ăn">
                        <div>
                            <div class="font-black text-[20px]">Trà tắc mật ong</div>
                            <div class="text-[#9d7d68]">Số lượng: 1</div>
                            <div class="text-orange-500 font-black text-[28px]">15,000đ</div>
                        </div>
                    </div>
                </div>

                <div class="mt-16 pt-8 border-t border-[#ece6e0] space-y-5">
                    <div class="flex justify-between">
                        <span class="text-[#8e715d]">Tạm tính</span>
                        <span class="font-bold">15,000đ</span>
                    </div>

                    <div class="flex justify-between">
                        <span class="text-[#8e715d]">Phí giao hàng</span>
                        <span class="font-bold text-green-600">Miễn phí</span>
                    </div>

                    <div class="flex justify-between items-end pt-6">
                        <span class="text-[34px] font-black">TỔNG CỘNG</span>
                        <span class="text-[48px] leading-none font-black text-orange-500">15,000đ</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>