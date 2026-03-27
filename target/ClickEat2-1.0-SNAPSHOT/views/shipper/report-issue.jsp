<%--
Document   : report-issue
Created on : Mar 6, 2026, 1:58:38 PM
Author     : DELL
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/responsive-global.css">
        <title>Báo cáo sự cố - ClickEat Shipper</title>
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/assets/images/shipperlogo.png">
        <script src="https://cdn.tailwindcss.com"></script>
        <script>
            tailwind.config = {
                theme: {
                    extend: {
                        fontFamily: {sans: ['Inter', 'sans-serif']},
                        colors: {primary: '#c86601', 'primary-dark': '#a05201'}
                    }
                }
            };
        </script>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
        <style>body { font-family: 'Inter', sans-serif; }</style>
    </head>
    <body class="bg-gray-100 flex justify-center min-h-screen">

        <div class="bg-white w-full max-w-md shadow-2xl flex flex-col h-screen relative">

            <div class="bg-red-500 text-white px-4 py-4 flex items-center justify-between shadow-md z-10 sticky top-0">
                <a href="javascript:history.back()" class="w-10 h-10 flex items-center justify-center hover:bg-red-600 rounded-full transition">
                    <i class="fa-solid fa-arrow-left text-xl"></i>
                </a>
                <h1 class="text-lg font-bold">Báo cáo sự cố</h1>
                <div class="w-10"></div>
            </div>

            <div class="flex-1 overflow-y-auto p-6 bg-gray-50 pb-32">

                <div class="text-center mb-6">
                    <div class="w-16 h-16 bg-red-100 text-red-500 rounded-full flex items-center justify-center mx-auto mb-3 text-3xl">
                        <i class="fa-solid fa-triangle-exclamation"></i>
                    </div>
                    <h2 class="text-xl font-black text-gray-900">Mã đơn: ORD-00${orderId}</h2>
                    <p class="text-sm text-gray-500 mt-1">Vui lòng chọn lý do chính xác. Báo cáo sai sự thật có thể dẫn đến khóa tài khoản.</p>
                </div>

                <form action="${pageContext.request.contextPath}/shipper/report-issue" method="POST" id="issueForm">
                    <input type="hidden" name="orderId" value="${orderId}">

                    <h3 class="font-bold text-gray-900 mb-3 uppercase text-sm tracking-wider">Chọn lý do</h3>

                    <div class="space-y-3 mb-6">
                        <label class="flex items-center p-4 border border-gray-200 rounded-xl bg-white cursor-pointer hover:border-red-500 transition shadow-sm">
                            <input type="radio" name="issueType" value="QUAN_DONG_CUA" class="w-5 h-5 text-red-600" required>
                            <span class="ml-3 font-medium text-gray-800">Quán đóng cửa / Không tìm thấy quán</span>
                        </label>

                        <label class="flex items-center p-4 border border-gray-200 rounded-xl bg-white cursor-pointer hover:border-red-500 transition shadow-sm">
                            <input type="radio" name="issueType" value="QUAN_HET_MON" class="w-5 h-5 text-red-600">
                            <span class="ml-3 font-medium text-gray-800">Quán thông báo hết món</span>
                        </label>

                        <label class="flex items-center p-4 border border-gray-200 rounded-xl bg-white cursor-pointer hover:border-red-500 transition shadow-sm">
                            <input type="radio" name="issueType" value="KHACH_HUNG_DON" class="w-5 h-5 text-red-600">
                            <span class="ml-3 font-medium text-gray-800">Khách không nghe máy / Từ chối nhận</span>
                        </label>

                        <label class="flex items-center p-4 border border-gray-200 rounded-xl bg-white cursor-pointer hover:border-red-500 transition shadow-sm">
                            <input type="radio" name="issueType" value="XE_HONG" class="w-5 h-5 text-red-600">
                            <span class="ml-3 font-medium text-gray-800">Xe hỏng / Tai nạn dọc đường</span>
                        </label>
                    </div>

                    <h3 class="font-bold text-gray-900 mb-3 uppercase text-sm tracking-wider">Chi tiết thêm</h3>
                    <textarea name="description" rows="4" class="w-full p-4 border border-gray-200 rounded-xl bg-white focus:outline-none focus:border-red-500 focus:ring-1 focus:ring-red-500 transition shadow-sm" placeholder="Mô tả rõ hơn về tình huống (Không bắt buộc)..."></textarea>

                    <div class="absolute bottom-0 left-0 w-full bg-white p-4 border-t border-gray-200 shadow-[0_-10px_15px_-3px_rgba(0,0,0,0.05)] z-20">
                        <button type="submit" class="w-full bg-red-500 hover:bg-red-600 text-white font-black text-lg py-4 rounded-xl transition shadow-xl flex justify-center items-center gap-2">
                            GỬI BÁO CÁO & HỦY ĐƠN
                        </button>
                    </div>
                </form>

            </div>
        </div>

    </body>
</html>