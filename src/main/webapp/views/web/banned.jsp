
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <title>Tài khoản bị khóa - ClickEat</title>
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
    <body class="bg-gray-100 h-screen flex items-center justify-center p-4">
        <div class="bg-white rounded-3xl shadow-2xl max-w-lg w-full p-8 text-center relative overflow-hidden">
            <div class="absolute top-0 left-0 w-full h-2 bg-red-500"></div>

            <div class="w-20 h-20 bg-red-100 text-red-500 rounded-full flex items-center justify-center text-4xl mx-auto mb-4">
                <i class="fa-solid fa-lock"></i>
            </div>
            <h2 class="text-3xl font-black text-gray-900 mb-2">TÀI KHOẢN BỊ KHÓA</h2>
            <p class="text-gray-600 mb-6">Rất tiếc, tài khoản của bạn đã bị ngưng hoạt động do vi phạm chính sách của ClickEat. Nếu bạn cho rằng đây là sự nhầm lẫn, vui lòng gửi đơn kháng cáo.</p>

            <c:choose>
                <%-- TRƯỜNG HỢP 1: CÓ ĐƠN ĐANG CHỜ DUYỆT --%>
                <c:when test="${not empty latestAppeal and latestAppeal.status == 'PENDING'}">
                    <div class="bg-blue-50 border border-blue-200 rounded-xl p-5 text-blue-700 font-medium">
                        <i class="fa-solid fa-clock-rotate-left text-2xl mb-2 block"></i>
                        Đơn kháng cáo của bạn đang chờ Admin xét duyệt. Vui lòng quay lại sau!
                    </div>
                </c:when>

                <%-- TRƯỜNG HỢP 2: CHƯA CÓ ĐƠN HOẶC ĐƠN VỪA BỊ TỪ CHỐI --%>
                <c:otherwise>

                    <%-- Nếu đơn trước đó bị từ chối, hiển thị lời phê của Admin --%>
                    <c:if test="${not empty latestAppeal and latestAppeal.status == 'REJECTED'}">
                        <div class="bg-red-50 border border-red-200 rounded-xl p-5 text-red-700 font-medium mb-6 text-left">
                            <h4 class="font-bold mb-1 text-lg"><i class="fa-solid fa-gavel mr-2"></i>Kháng cáo thất bại</h4>
                            <p class="text-sm mb-3">Đơn kháng cáo trước đó của bạn đã bị từ chối.</p>

                            <c:if test="${not empty latestAppeal.adminNote}">
                                <div class="p-3 bg-white/80 rounded-lg italic text-sm border border-red-100 shadow-sm text-gray-700">
                                    <span class="font-bold text-gray-900 block mb-1">Phản hồi từ Ban Quản Trị:</span>
                                    "${latestAppeal.adminNote}"
                                </div>
                            </c:if>
                        </div>
                    </c:if>

                    <%-- Form nộp đơn (Nộp lần đầu hoặc nộp LẠI) --%>
                    <form action="${pageContext.request.contextPath}/banned" method="POST" class="text-left">
                        <label class="block font-bold text-gray-700 mb-2">
                            ${not empty latestAppeal and latestAppeal.status == 'REJECTED' ? 'Cung cấp thêm bằng chứng / Giải trình lại:' : 'Lý do giải trình / Bằng chứng:'}
                        </label>
                        <textarea name="reason" rows="4" required class="w-full border border-gray-300 rounded-xl p-3 focus:ring-2 focus:ring-red-500 outline-none mb-4" placeholder="Viết chi tiết lý do tại sao tài khoản của bạn không vi phạm..."></textarea>

                        <button type="submit" class="w-full bg-red-500 hover:bg-red-600 text-white font-bold py-3 rounded-xl transition shadow-lg">
                            ${not empty latestAppeal and latestAppeal.status == 'REJECTED' ? 'Gửi Lại Đơn Kháng Cáo' : 'Gửi Đơn Kháng Cáo'}
                        </button>
                    </form>
                </c:otherwise>
            </c:choose>

            <a href="${pageContext.request.contextPath}/logout" class="block mt-6 text-gray-500 hover:text-gray-900 underline font-medium">Quay lại Đăng nhập</a>
        </div>

        <c:if test="${not empty sessionScope.toastMsg}">
            <div id="toast" class="fixed top-5 right-5 bg-green-500 text-white px-6 py-4 rounded-xl shadow-2xl z-50"><i class="fa-solid fa-check mr-2"></i>${sessionScope.toastMsg}</div>
            <c:remove var="toastMsg" scope="session" />
            <script>setTimeout(() => document.getElementById('toast').style.display = 'none', 4000);</script>
        </c:if>
    </body>
</html>