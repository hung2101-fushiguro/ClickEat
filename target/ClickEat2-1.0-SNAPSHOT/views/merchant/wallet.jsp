<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<% request.setAttribute("currentPage", "wallet");%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Ví tiền – ClickEat Merchant</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <script>
            tailwind.config = {theme: {extend: {colors: {primary: '#c86601', 'primary-dark': '#a05201'}}}};
        </script>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
        <style>
            body {
                font-family: 'Inter', sans-serif;
            }
            .material-symbols-outlined {
                font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
            }
        </style>
    </head>
    <body class="bg-[#f8f7f5] min-h-screen flex">

        <%@ include file="_nav.jsp" %>

        <div class="flex-1 flex flex-col min-h-screen pb-16 md:pb-0">

            <div class="flex flex-col gap-1 px-4 md:px-8 py-6 sticky top-0 z-30 bg-white border-b border-gray-100 shadow-sm">
                <h1 class="text-2xl font-black text-gray-900 tracking-tight">Ví tiền</h1>
                <p class="text-sm text-gray-500 font-medium mt-1">Quản lý thu nhập và yêu cầu rút tiền</p>
            </div>

            <div class="flex-1 px-4 md:px-8 py-8 space-y-6 overflow-y-auto max-w-7xl mx-auto w-full">

                <c:if test="${not empty sessionScope.msg}">
                    <div class="bg-green-50 border border-green-200 text-green-700 px-6 py-4 rounded-xl flex items-center gap-3">
                        <span class="material-symbols-outlined">check_circle</span>
                        <p class="font-bold">${sessionScope.msg}</p>
                    </div>
                    <c:remove var="msg" scope="session"/>
                </c:if>
                <c:if test="${not empty sessionScope.error}">
                    <div class="bg-red-50 border border-red-200 text-red-600 px-6 py-4 rounded-xl flex items-center gap-3">
                        <span class="material-symbols-outlined">error</span>
                        <p class="font-bold">${sessionScope.error}</p>
                    </div>
                    <c:remove var="error" scope="session"/>
                </c:if>

                <div class="relative overflow-hidden rounded-[2rem] bg-gradient-to-br from-primary to-orange-500 text-white p-8 md:p-10 shadow-xl group">
                    <span class="material-symbols-outlined absolute -right-10 -top-10 text-[180px] md:text-[240px] opacity-10 group-hover:scale-110 transition-transform duration-700">account_balance_wallet</span>
                    <div class="relative z-10">
                        <p class="text-white/80 font-semibold text-lg uppercase tracking-wider">Số dư khả dụng</p>
                        <h2 class="text-4xl md:text-6xl font-black mt-2 mb-6" id="balanceDisplay">
                            <c:choose>
                                <c:when test="${not empty wallet}">
                                    <fmt:formatNumber value="${wallet.balance}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                </c:when>
                                <c:otherwise>0 đ</c:otherwise>
                            </c:choose>
                        </h2>

                        <div class="flex flex-wrap gap-3">
                            <button onclick="openWithdraw()" class="bg-white text-primary hover:bg-gray-50 px-8 py-3.5 rounded-xl font-bold shadow-lg transition-all flex items-center gap-2">
                                <span class="material-symbols-outlined text-xl">payments</span> Rút tiền về Ngân hàng
                            </button>
                        </div>
                    </div>
                </div>

                <div class="bg-white rounded-[2rem] border border-gray-100 shadow-[0_8px_30px_rgb(0,0,0,0.04)] overflow-hidden">
                    <div class="px-8 py-6 border-b border-gray-100 flex items-center justify-between">
                        <h3 class="font-bold text-gray-900 text-lg flex items-center gap-2">
                            <span class="material-symbols-outlined text-primary">history</span> Lịch sử rút tiền
                        </h3>
                    </div>
                    <div class="overflow-x-auto">
                        <table class="w-full text-left min-w-[600px]">
                            <thead class="bg-gray-50/50 text-gray-400 text-xs uppercase font-bold tracking-wider">
                                <tr>
                                    <th class="px-8 py-4">Ngày yêu cầu</th>
                                    <th class="px-8 py-4">Ngân hàng</th>
                                    <th class="px-8 py-4">Số tài khoản</th>
                                    <th class="px-8 py-4">Số tiền rút</th>
                                    <th class="px-8 py-4">Trạng thái</th>
                                </tr>
                            </thead>
                            <tbody class="divide-y divide-gray-50 text-sm font-medium">
                                <c:forEach var="w" items="${withdrawHistory}">
                                    <tr class="hover:bg-gray-50/50 transition-colors">
                                        <td class="px-8 py-4 text-gray-500"><fmt:formatDate value="${w.createdAt}" pattern="HH:mm - dd/MM/yyyy"/></td>
                                        <td class="px-8 py-4 text-gray-900 font-bold">${w.bankName}</td>
                                        <td class="px-8 py-4 text-gray-500 font-mono">${w.bankAccountNumber}</td>
                                        <td class="px-8 py-4 font-black text-gray-900">
                                            <fmt:formatNumber value="${w.amount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                        </td>
                                        <td class="px-8 py-4">
                                            <span class="px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest
                                                  ${w.status == 'PENDING' ? 'bg-yellow-100 text-yellow-700' :
                                                    w.status == 'APPROVED' ? 'bg-green-100 text-green-700' : 'bg-red-100 text-red-700'}">
                                                      ${w.status == 'PENDING' ? 'Đang xử lý' : w.status == 'APPROVED' ? 'Thành công' : 'Từ chối'}
                                                  </span>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                    <c:if test="${empty withdrawHistory}">
                                        <tr>
                                            <td colspan="5" class="px-8 py-12 text-center text-gray-400 font-medium">
                                                Bạn chưa có lịch sử rút tiền nào.
                                            </td>
                                        </tr>
                                    </c:if>
                                </tbody>
                            </table>
                        </div>
                    </div>

                </div>
            </div>

            <div id="withdrawModal" class="fixed inset-0 bg-black/60 z-50 hidden items-center justify-center p-4 backdrop-blur-sm">
                <div class="bg-white w-full max-w-md rounded-[2rem] shadow-2xl overflow-hidden relative">

                    <div class="flex items-center justify-between px-8 py-6 border-b border-gray-50">
                        <h3 class="text-xl font-black text-gray-900 flex items-center gap-2">
                            <span class="material-symbols-outlined text-primary">account_balance</span> Rút tiền
                        </h3>
                        <button onclick="closeWithdraw()" class="p-2 rounded-full hover:bg-gray-100 text-gray-400 hover:text-gray-600 transition-colors">
                            <span class="material-symbols-outlined">close</span>
                        </button>
                    </div>

                    <div class="mx-8 mt-6 mb-2 bg-orange-50 border border-orange-100 rounded-xl px-5 py-4 flex items-center justify-between">
                        <span class="text-sm text-orange-800 font-bold">Số dư hiện tại</span>
                        <span class="text-primary font-black text-xl">
                            <c:choose>
                                <c:when test="${not empty wallet}">
                                    <fmt:formatNumber value="${wallet.balance}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                </c:when>
                                <c:otherwise>0 đ</c:otherwise>
                            </c:choose>
                        </span>
                    </div>

                    <form method="POST" action="${pageContext.request.contextPath}/merchant/wallet" class="px-8 pb-8 space-y-5 pt-2">
                        <div>
                            <label class="block text-sm font-bold text-gray-700 mb-2">Số tiền muốn rút <span class="text-red-500">*</span></label>
                            <div class="relative">
                                <input type="number" name="amount" id="withdrawAmount" placeholder="VD: 500000" min="50000" required
                                       class="w-full px-4 py-3.5 pr-10 rounded-xl border border-gray-200 bg-gray-50 focus:bg-white focus:border-primary outline-none transition-all font-black text-lg shadow-sm"/>
                                <span class="absolute right-4 top-1/2 -translate-y-1/2 text-gray-400 text-lg font-bold">đ</span>
                            </div>
                            <div class="flex gap-2 mt-3 flex-wrap">
                                <button type="button" onclick="setAmount(500000)" class="text-xs px-3 py-1.5 rounded-full border border-gray-200 text-gray-600 font-bold hover:bg-orange-50 hover:text-primary transition-all">500,000đ</button>
                                <button type="button" onclick="setAmount(1000000)" class="text-xs px-3 py-1.5 rounded-full border border-gray-200 text-gray-600 font-bold hover:bg-orange-50 hover:text-primary transition-all">1,000,000đ</button>
                                <button type="button" onclick="setAmount(2000000)" class="text-xs px-3 py-1.5 rounded-full border border-gray-200 text-gray-600 font-bold hover:bg-orange-50 hover:text-primary transition-all">2,000,000đ</button>
                            </div>
                        </div>

                        <div>
                            <label class="block text-sm font-bold text-gray-700 mb-2">Ngân hàng <span class="text-red-500">*</span></label>
                            <select name="bankName" required class="w-full px-4 py-3.5 rounded-xl border border-gray-200 bg-gray-50 focus:bg-white focus:border-primary font-bold shadow-sm outline-none transition-all">
                                <option value="">-- Chọn ngân hàng --</option>
                                <option value="Vietcombank">Vietcombank</option>
                                <option value="VietinBank">VietinBank</option>
                                <option value="BIDV">BIDV</option>
                                <option value="Agribank">Agribank</option>
                                <option value="Techcombank">Techcombank</option>
                                <option value="MB Bank">MB Bank</option>
                                <option value="ACB">ACB</option>
                            </select>
                        </div>

                        <div>
                            <label class="block text-sm font-bold text-gray-700 mb-2">Số tài khoản <span class="text-red-500">*</span></label>
                            <input type="text" name="accNum" required placeholder="Nhập chính xác số tài khoản"
                                   class="w-full px-4 py-3.5 rounded-xl border border-gray-200 bg-gray-50 focus:bg-white focus:border-primary font-bold shadow-sm outline-none transition-all"/>
                        </div>

                        <div class="flex gap-3 pt-4">
                            <button type="button" onclick="closeWithdraw()" class="flex-1 py-3.5 rounded-xl border-2 border-gray-100 text-gray-500 font-bold hover:bg-gray-50 transition-colors">Hủy</button>
                            <button type="submit" class="flex-[2] py-3.5 rounded-xl bg-gray-900 text-white font-black hover:bg-black shadow-lg transition-all">Tạo lệnh rút tiền</button>
                        </div>
                    </form>
                </div>
            </div>

            <script>
                function openWithdraw() {
                    document.getElementById('withdrawModal').classList.remove('hidden');
                    document.getElementById('withdrawModal').classList.add('flex');
                }
                function closeWithdraw() {
                    document.getElementById('withdrawModal').classList.add('hidden');
                    document.getElementById('withdrawModal').classList.remove('flex');
                }
                function setAmount(v) {
                    document.getElementById('withdrawAmount').value = v;
                }

                // Đóng modal khi click ra ngoài
                document.getElementById('withdrawModal').addEventListener('click', function (e) {
                    if (e.target === this)
                        closeWithdraw();
                });
            </script>
        </body>
    </html>