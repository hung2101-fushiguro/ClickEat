<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/responsive-global.css">
        <title>Chi tiết Người dùng - Admin</title>
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
    <body class="bg-gray-50 flex flex-col min-h-screen">

        <header class="h-20 bg-white flex items-center px-8 border-b border-gray-200 sticky top-0 z-10 shadow-sm gap-4">
            <a href="${pageContext.request.contextPath}/admin/dashboard?tab=users" class="w-10 h-10 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-full flex items-center justify-center transition">
                <i class="fa-solid fa-arrow-left"></i>
            </a>
            <h2 class="text-xl font-black text-gray-900">Hồ sơ chi tiết</h2>
        </header>

        <main class="flex-1 p-8">
            <div class="max-w-6xl mx-auto flex flex-col lg:flex-row gap-8">

                <div class="w-full lg:w-1/3">
                    <div class="bg-white rounded-3xl p-8 shadow-sm border border-gray-200 text-center relative overflow-hidden">
                        <div class="absolute top-0 left-0 w-full h-24 bg-gradient-to-r ${targetUser.role == 'CUSTOMER' ? 'from-blue-500 to-cyan-500' : (targetUser.role == 'SHIPPER' ? 'from-orange-500 to-amber-500' : 'from-purple-500 to-pink-500')}"></div>

                        <div class="relative w-24 h-24 bg-white rounded-full mx-auto mt-8 border-4 border-white shadow-lg flex items-center justify-center text-4xl overflow-hidden">
                            <c:choose>
                                <c:when test="${not empty targetUser.avatarUrl}"><img src="${targetUser.avatarUrl}" class="w-full h-full object-cover"></c:when>
                                    <c:otherwise><i class="fa-solid fa-user text-gray-300"></i></c:otherwise>
                                    </c:choose>
                                </div>

                                <h3 class="text-2xl font-black text-gray-900 mt-4">${targetUser.fullName}</h3>
                                <p class="text-sm font-bold mt-1 px-3 py-1 rounded-full inline-block ${targetUser.role == 'CUSTOMER' ? 'bg-blue-100 text-blue-600' : (targetUser.role == 'SHIPPER' ? 'bg-orange-100 text-orange-600' : 'bg-purple-100 text-purple-600')}">
                                    ${targetUser.role}
                                </p>

                                <div class="mt-6 text-left space-y-4">
                                    <div class="flex items-center gap-3 text-sm text-gray-600 border-b border-gray-100 pb-3"><i class="fa-solid fa-phone w-5 text-gray-400"></i> <span class="font-medium">${targetUser.phone}</span></div>
                                    <div class="flex items-center gap-3 text-sm text-gray-600 border-b border-gray-100 pb-3"><i class="fa-solid fa-envelope w-5 text-gray-400"></i> <span class="font-medium">${not empty targetUser.email ? targetUser.email : 'Chưa cập nhật'}</span></div>
                                    <div class="flex items-center gap-3 text-sm text-gray-600 border-b border-gray-100 pb-3"><i class="fa-solid fa-id-badge w-5 text-gray-400"></i> <span class="font-medium">ID: ${targetUser.id}</span></div>
                                    <div class="flex items-center gap-3 text-sm text-gray-600"><i class="fa-solid fa-shield-halved w-5 text-gray-400"></i>
                                        <span class="font-bold px-2 py-0.5 rounded text-xs ${targetUser.status == 'ACTIVE' ? 'bg-green-100 text-green-600' : 'bg-red-100 text-red-600'}">${targetUser.status}</span>
                                    </div>
                                </div>

                                <form action="${pageContext.request.contextPath}/admin/dashboard" method="POST" class="mt-8 pt-6 border-t border-gray-100">
                                    <input type="hidden" name="action" value="CHANGE_USER_STATUS">
                                    <input type="hidden" name="targetUserId" value="${targetUser.id}">
                                    <input type="hidden" name="newStatus" value="${targetUser.status == 'ACTIVE' ? 'INACTIVE' : 'ACTIVE'}">
                                    <button type="submit" class="w-full font-bold py-3 rounded-xl transition shadow-sm ${targetUser.status == 'ACTIVE' ? 'bg-red-50 text-red-600 hover:bg-red-500 hover:text-white' : 'bg-green-500 text-white hover:bg-green-600'}">
                                        <i class="${targetUser.status == 'ACTIVE' ? 'fa-solid fa-lock' : 'fa-solid fa-unlock'} mr-2"></i>
                                        ${targetUser.status == 'ACTIVE' ? 'Khóa Tài Khoản Này' : 'Mở Khóa Tài Khoản'}
                                    </button>
                                </form>
                            </div>
                        </div>

                        <div class="w-full lg:w-2/3 space-y-6">

                            <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                                <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-200">
                                    <p class="text-gray-500 font-bold text-xs uppercase mb-2">Đơn Hoàn Thành</p>
                                    <h3 class="text-3xl font-black text-green-500">${totalCompleted} <span class="text-sm font-medium text-gray-400">đơn</span></h3>
                                </div>
                                <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-200">
                                    <p class="text-gray-500 font-bold text-xs uppercase mb-2">Đơn Đã Hủy</p>
                                    <h3 class="text-3xl font-black text-red-500">${totalCancelled} <span class="text-sm font-medium text-gray-400">đơn</span></h3>
                                </div>
                                <div class="bg-white rounded-2xl p-6 shadow-sm border border-gray-200">
                                    <p class="text-gray-500 font-bold text-xs uppercase mb-2">
                                        ${targetUser.role == 'CUSTOMER' ? 'Tổng Đã Chi' : (targetUser.role == 'SHIPPER' ? 'Tổng Thu Nhập Ship' : 'Tổng Doanh Thu')}
                                    </p>
                                    <h3 class="text-3xl font-black text-blue-500"><fmt:formatNumber value="${totalMoney}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></h3>
                                </div>
                            </div>

                            <div class="bg-white rounded-2xl shadow-sm border border-gray-200 overflow-hidden">
                                <div class="bg-gray-50 px-6 py-4 border-b border-gray-200">
                                    <h4 class="font-bold text-gray-800"><i class="fa-solid fa-clock-rotate-left mr-2"></i>Lịch sử Giao dịch Gần đây</h4>
                                </div>
                                <div class="overflow-x-auto">
                                    <table class="w-full text-left text-sm text-gray-600">
                                        <thead class="bg-white border-b border-gray-100 text-gray-400 uppercase text-xs">
                                            <tr>
                                                <th class="px-6 py-4 font-medium">Mã Đơn / Ngày</th>
                                                <th class="px-6 py-4 font-medium">Chi tiết</th>
                                                <th class="px-6 py-4 font-medium text-right">Giá trị</th>
                                                <th class="px-6 py-4 font-medium text-center">Trạng thái</th>
                                            </tr>
                                        </thead>
                                        <tbody class="divide-y divide-gray-100">
                                            <c:forEach var="o" items="${historyOrders}">
                                                <tr class="hover:bg-gray-50 transition">
                                                    <td class="px-6 py-4">
                                                        <p class="font-bold text-blue-600">${o.orderCode}</p>
                                                        <p class="text-xs text-gray-400"><fmt:formatDate value="${o.createdAt}" pattern="dd/MM/yyyy HH:mm"/></p>
                                                    </td>
                                                    <td class="px-6 py-4">
                                                        <p class="font-medium text-gray-800 line-clamp-1 max-w-[200px]">Tới: ${o.receiverName}</p>
                                                        <p class="text-xs text-gray-400">Thanh toán: ${o.paymentMethod}</p>
                                                    </td>
                                                    <td class="px-6 py-4 text-right">
                                                        <p class="font-black text-gray-900"><fmt:formatNumber value="${o.totalAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></p>
                                                        <p class="text-xs text-orange-500 font-bold">+ <fmt:formatNumber value="${o.deliveryFee}" type="currency" currencySymbol="đ" maxFractionDigits="0"/> ship</p>
                                                    </td>
                                                    <td class="px-6 py-4 text-center">
                                                        <span class="px-3 py-1 rounded-full text-[10px] font-bold uppercase tracking-wider
                                                        ${o.orderStatus == 'DELIVERED' ? 'bg-green-100 text-green-600' :
                                                        (o.orderStatus == 'CANCELLED' ? 'bg-red-100 text-red-600' : 'bg-yellow-100 text-yellow-600')}">
                                                        ${o.orderStatus}
                                                    </span>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                        <c:if test="${empty historyOrders}">
                                            <tr><td colspan="4" class="px-6 py-8 text-center text-gray-400 font-medium">Chưa có giao dịch nào.</td></tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                    </div>
                </div>
            </main>
        </body>
    </html>