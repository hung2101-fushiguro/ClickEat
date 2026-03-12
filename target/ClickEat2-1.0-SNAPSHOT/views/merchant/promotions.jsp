<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<% request.setAttribute("currentPage", "promotions");%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Khuyến mãi – ClickEat Merchant</title>
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

            <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 px-4 md:px-8 py-6 bg-white border-b border-gray-100 shadow-sm sticky top-0 z-20">
                <div>
                    <h1 class="text-2xl font-black text-gray-900 tracking-tight">Khuyến mãi</h1>
                    <p class="text-gray-500 mt-1">Tăng doanh số với các voucher hấp dẫn</p>
                </div>
                <button onclick="openCreate()"
                        class="w-full md:w-auto bg-primary hover:bg-primary-dark text-white px-6 py-3 rounded-xl font-bold shadow-lg shadow-primary/20 transition-all flex items-center justify-center gap-2">
                    <span class="material-symbols-outlined">add_circle</span> Tạo Khuyến mãi
                </button>
            </div>

            <div class="flex-1 px-4 md:px-8 py-8 overflow-y-auto">

                <div class="grid grid-cols-1 xl:grid-cols-2 gap-6" id="voucherGrid">
                    <c:forEach var="v" items="${vouchers}">
                        <div class="bg-white p-6 rounded-3xl border border-gray-100 shadow-sm transition-all relative overflow-hidden group hover:shadow-lg">
                            <div class="flex justify-between items-start mb-4">
                                <div class="flex gap-4 items-center">
                                    <div class="w-14 h-14 rounded-2xl bg-orange-50 flex items-center justify-center text-primary">
                                        <span class="material-symbols-outlined text-3xl">
                                            ${v.discountType == 'FIXED' ? 'payments' : 'percent'}
                                        </span>
                                    </div>
                                    <div>
                                        <h3 class="text-lg font-bold text-gray-900">${v.title}</h3>
                                        <p class="text-sm text-gray-500 mt-0.5 font-medium">Mã: 
                                            <span class="bg-gray-100 px-2 py-0.5 rounded font-mono font-bold text-gray-800">${v.code}</span>
                                        </p>
                                    </div>
                                </div>
                                <div class="px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-widest ${v.status == 'ACTIVE' ? 'bg-green-100 text-green-700' : 'bg-gray-100 text-gray-400'}">
                                    ${v.status == 'ACTIVE' ? 'Đang chạy' : 'Tạm dừng'}
                                </div>
                            </div>

                            <div class="grid grid-cols-3 gap-3 mb-6 p-4 bg-gray-50 rounded-2xl border border-gray-100">
                                <div>
                                    <p class="uppercase font-bold text-gray-400 text-[10px] tracking-wider mb-1">Giảm</p>
                                    <p class="font-black text-gray-900">
                                        <c:choose>
                                            <c:when test="${v.discountType == 'PERCENT'}">${v.discountValue}%</c:when>
                                        <c:otherwise><fmt:formatNumber value="${v.discountValue}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></c:otherwise>
                                    </c:choose>
                                    </p>
                                </div>
                                <div>
                                    <p class="uppercase font-bold text-gray-400 text-[10px] tracking-wider mb-1">Đơn tối thiểu</p>
                                    <p class="font-bold text-gray-900"><fmt:formatNumber value="${v.minOrderAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></p>
                                </div>
                                <div>
                                    <p class="uppercase font-bold text-gray-400 text-[10px] tracking-wider mb-1">Hết hạn</p>
                                    <p class="font-bold text-gray-900"><fmt:formatDate value="${v.endAt}" pattern="dd/MM/yyyy"/></p>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>

                <c:if test="${empty vouchers}">
                    <div id="emptyVouchers" class="flex flex-col items-center justify-center py-24 text-gray-400">
                        <span class="material-symbols-outlined text-6xl mb-3 opacity-20">sell</span>
                        <p class="font-bold text-lg">Chưa có chương trình khuyến mãi nào</p>
                        <p class="text-sm mt-1">Bấm "Tạo Khuyến mãi" để thu hút khách hàng ngay hôm nay</p>
                    </div>
                </c:if>
            </div>
        </div>

        <div id="createModal" class="fixed inset-0 z-[60] hidden flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm">
            <div class="bg-white w-full max-w-lg rounded-[2rem] shadow-2xl overflow-hidden relative">
                <div class="flex items-center justify-between px-8 py-6 border-b border-gray-50">
                    <h2 class="text-xl font-black text-gray-900 tracking-tight">Tạo Khuyến Mãi Mới</h2>
                    <button onclick="closeCreate()" class="text-gray-400 hover:text-gray-600 p-2 hover:bg-gray-100 rounded-full transition-colors">
                        <span class="material-symbols-outlined">close</span>
                    </button>
                </div>

                <form method="POST" action="${pageContext.request.contextPath}/merchant/promotions" class="p-8 space-y-5">
                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-2">Tên chương trình *</label>
                        <input type="text" name="title" required placeholder="VD: Khuyến mãi cuối tuần"
                               class="w-full px-4 py-3 rounded-xl border border-gray-100 bg-gray-50 outline-none focus:bg-white focus:border-primary font-medium transition-all shadow-sm"/>
                    </div>

                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <label class="block text-sm font-bold text-gray-700 mb-2">Loại giảm giá</label>
                            <select name="type" class="w-full px-4 py-3 rounded-xl border border-gray-100 bg-gray-50 outline-none focus:bg-white focus:border-primary font-bold appearance-none transition-all shadow-sm">
                                <option value="percent">Giảm theo %</option>
                                <option value="fixed">Số tiền cố định (đ)</option>
                            </select>
                        </div>
                        <div>
                            <label class="block text-sm font-bold text-gray-700 mb-2">Giá trị *</label>
                            <input type="number" name="value" required placeholder="15"
                                   class="w-full px-4 py-3 rounded-xl border border-gray-100 bg-gray-50 outline-none focus:bg-white focus:border-primary font-black transition-all shadow-sm"/>
                        </div>
                    </div>

                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-2">Mã Voucher (Code) *</label>
                        <input type="text" name="code" required placeholder="SUMMER2026" oninput="this.value=this.value.toUpperCase()"
                               class="w-full px-4 py-3 rounded-xl border border-gray-100 bg-gray-50 outline-none focus:bg-white focus:border-primary font-mono font-bold transition-all shadow-sm"/>
                    </div>

                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <label class="block text-sm font-bold text-gray-700 mb-2">Đơn tối thiểu (đ)</label>
                            <input type="number" name="minOrder" value="0"
                                   class="w-full px-4 py-3 rounded-xl border border-gray-100 bg-gray-50 outline-none focus:bg-white focus:border-primary font-bold transition-all shadow-sm"/>
                        </div>
                        <div>
                            <label class="block text-sm font-bold text-gray-700 mb-2">Tổng lượt dùng</label>
                            <input type="number" name="maxUses" value="100"
                                   class="w-full px-4 py-3 rounded-xl border border-gray-100 bg-gray-50 outline-none focus:bg-white focus:border-primary font-bold transition-all shadow-sm"/>
                        </div>
                    </div>

                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <label class="block text-sm font-bold text-gray-700 mb-2">Ngày bắt đầu</label>
                            <input type="date" name="startDate" required class="w-full px-4 py-3 rounded-xl border border-gray-100 bg-gray-50 outline-none focus:bg-white focus:border-primary font-bold shadow-sm transition-all"/>
                        </div>
                        <div>
                            <label class="block text-sm font-bold text-gray-700 mb-2">Ngày kết thúc</label>
                            <input type="date" name="endDate" required class="w-full px-4 py-3 rounded-xl border border-gray-100 bg-gray-50 outline-none focus:bg-white focus:border-primary font-bold shadow-sm transition-all"/>
                        </div>
                    </div>

                    <div class="pt-4 flex gap-3">
                        <button type="button" onclick="closeCreate()" class="flex-1 px-6 py-3.5 rounded-xl border-2 border-gray-100 font-bold text-gray-400 hover:bg-gray-50 transition-all">Hủy</button>
                        <button type="submit" class="flex-[2] bg-primary hover:bg-primary-dark text-white font-black py-3.5 rounded-xl shadow-lg shadow-primary/20 transition-all">Tạo chiến dịch</button>
                    </div>
                </form>
            </div>
        </div>

        <script>
            function openCreate() {
                const m = document.getElementById('createModal');
                m.classList.remove('hidden');
            }
            function closeCreate() {
                const m = document.getElementById('createModal');
                m.classList.add('hidden');
            }
            // Đóng khi click ra ngoài
            document.getElementById('createModal').addEventListener('click', function (e) {
                if (e.target === this)
                    closeCreate();
            });
        </script>
    </body>
</html>