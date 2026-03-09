<%-- 
    Document   : profile
    Created on : Mar 6, 2026, 2:31:43 PM
    Author     : DELL
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Hồ sơ của tôi - ClickEat Shipper</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    </head>
    <body class="bg-gray-100 flex justify-center min-h-screen">

        <div class="bg-gray-50 w-full max-w-md shadow-2xl flex flex-col h-screen relative">

            <div class="bg-white px-4 py-4 flex items-center justify-between shadow-sm z-10 sticky top-0 border-b border-gray-100">
                <a href="${pageContext.request.contextPath}/shipper/dashboard" class="w-10 h-10 flex items-center justify-center text-gray-700 hover:bg-gray-100 rounded-full transition">
                    <i class="fa-solid fa-arrow-left text-xl"></i>
                </a>
                <h1 class="text-lg font-black text-gray-900">Hồ sơ tài xế</h1>
                <div class="w-10"></div>
            </div>

            <div class="flex-1 overflow-y-auto p-4 space-y-6 pb-10">

                <div class="bg-white rounded-3xl p-6 flex flex-col items-center text-center shadow-sm border border-gray-100">
                    <div class="w-24 h-24 bg-orange-100 rounded-full flex items-center justify-center mb-4 border-4 border-white shadow-md relative">
                        <i class="fa-solid fa-user-astronaut text-4xl text-orange-500"></i>
                        <div class="absolute bottom-0 right-0 w-6 h-6 bg-green-500 border-2 border-white rounded-full"></div>
                    </div>
                    <h2 class="text-2xl font-black text-gray-900">${sessionScope.account.fullName}</h2>
                    <p class="text-gray-500 font-medium">ID: SP-00${sessionScope.account.id}</p>
                    <span class="mt-2 bg-green-100 text-green-600 px-4 py-1 rounded-full text-xs font-bold uppercase tracking-wider">Đối tác chính thức</span>
                </div>

                <form action="${pageContext.request.contextPath}/shipper/profile" method="POST" class="space-y-6">

                    <div>
                        <h3 class="font-bold text-gray-900 mb-3 px-2 uppercase text-xs tracking-widest text-gray-500">Thông tin cá nhân</h3>
                        <div class="bg-white rounded-2xl p-5 shadow-sm border border-gray-100 space-y-4">
                            <div>
                                <label class="block text-xs font-bold text-gray-600 mb-1">Số điện thoại</label>
                                <input type="text" name="phone" value="${sessionScope.account.phone}" required class="w-full bg-white text-gray-900 px-4 py-3 rounded-xl border border-gray-300 focus:border-orange-500 focus:ring-2 focus:ring-orange-200 outline-none transition">
                            </div>
                            <div>
                                <label class="block text-xs font-bold text-gray-600 mb-1">Email</label>
                                <input type="email" name="email" value="${sessionScope.account.email}" required class="w-full bg-white text-gray-900 px-4 py-3 rounded-xl border border-gray-300 focus:border-orange-500 focus:ring-2 focus:ring-orange-200 outline-none transition">
                            </div>
                        </div>
                    </div>

                    <div>
                        <h3 class="font-bold text-gray-900 mb-3 px-2 uppercase text-xs tracking-widest text-gray-500">Phương tiện giao hàng</h3>
                        <div class="bg-white rounded-2xl p-5 shadow-sm border border-gray-100 space-y-4">
                            <div>
                                <label class="block text-xs font-bold text-gray-600 mb-1">Loại xe</label>
                                <select name="vehicleType" class="w-full bg-white text-gray-900 px-4 py-3 rounded-xl border border-gray-300 focus:border-orange-500 focus:ring-2 focus:ring-orange-200 outline-none transition">
                                    <option value="Xe máy" ${profile.vehicleType == 'Xe máy' ? 'selected' : ''}>Xe máy</option>
                                    <option value="Xe đạp điện" ${profile.vehicleType == 'Xe đạp điện' ? 'selected' : ''}>Xe đạp điện</option>
                                </select>
                            </div>
                            <div>
                                <label class="block text-xs font-bold text-gray-600 mb-1">Tên xe (Hãng - Dòng xe)</label>
                                <input type="text" name="vehicleName" value="${profile.vehicleName}" required class="w-full bg-white text-gray-900 px-4 py-3 rounded-xl border border-gray-300 focus:border-orange-500 focus:ring-2 focus:ring-orange-200 outline-none transition" placeholder="VD: Honda AirBlade">
                            </div>
                            <div>
                                <label class="block text-xs font-bold text-gray-600 mb-1">Biển số xe</label>
                                <input type="text" name="licensePlate" value="${profile.licensePlate}" required class="w-full bg-white text-gray-900 px-4 py-3 rounded-xl border border-gray-300 focus:border-orange-500 focus:ring-2 focus:ring-orange-200 outline-none transition uppercase" placeholder="VD: 59X1-12345">
                            </div>
                        </div>
                    </div>

                    <button type="submit" class="w-full bg-orange-500 hover:bg-orange-600 text-white font-black text-lg py-4 rounded-xl transition shadow-xl mt-4">
                        LƯU THAY ĐỔI
                    </button>
                    <a href="${pageContext.request.contextPath}/shipper/dashboard" class="block w-full text-center mt-4 text-gray-500 font-bold hover:text-orange-500 transition py-2">
                        <i class="fa-solid fa-arrow-left mr-2"></i> Quay về Bảng điều khiển
                    </a>
                </form>

            </div>
        </div>

        <c:if test="${not empty sessionScope.toastMsg}">
            <div id="toast-success" class="fixed top-5 right-5 bg-green-500 text-white px-6 py-4 rounded-xl shadow-2xl z-50 flex items-center gap-3 animate-bounce">
                <i class="fa-solid fa-circle-check text-xl"></i><span class="font-medium">${sessionScope.toastMsg}</span>
            </div>
            <c:remove var="toastMsg" scope="session" />
            <script>setTimeout(() => document.getElementById('toast-success').style.display = 'none', 3000);</script>
        </c:if>
    </body>
</html>