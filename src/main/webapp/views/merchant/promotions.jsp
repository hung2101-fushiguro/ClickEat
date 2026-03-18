<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<% request.setAttribute("currentPage", "promotions");%>
<!DOCTYPE html>
<html lang="vi" class="h-full">
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Khuyến mãi – ClickEat Merchant</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <script>
            tailwind.config = {
                theme: {
                    extend: {
                        fontFamily: {sans: ['Inter', 'sans-serif']},
                        colors: {primary: '#c86601', 'primary-dark': '#a05201'}
                    }
                }
            }
        </script>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
        <style>
            body {
                font-family: 'Inter', sans-serif;
            }
        </style>
    </head>
    <body class="h-full bg-[#f8f7f5] text-gray-800 flex overflow-hidden">

        <jsp:useBean id="now" class="java.util.Date" />

        <jsp:include page="_nav.jsp" />

        <main class="flex-1 flex flex-col h-screen overflow-y-auto">
            <header class="bg-white border-b border-gray-100 px-8 py-5 sticky top-0 z-10 flex justify-between items-center shadow-sm">
                <div>
                    <h1 class="text-2xl font-black text-gray-900 tracking-tight">Khuyến mãi</h1>
                    <p class="text-sm text-gray-500 font-medium mt-1">Quản lý mã code, thời gian hiệu lực và trạng thái publish</p>
                </div>
                <button onclick="openCreate()" class="bg-primary hover:bg-primary-dark text-white px-5 py-2.5 rounded-xl font-bold transition-all shadow-md flex items-center gap-2">
                    <span class="material-symbols-outlined text-[20px]">add</span>Tạo voucher
                </button>
            </header>

            <div class="p-8 max-w-7xl mx-auto w-full">
                <c:if test="${not empty successMsg}">
                    <div class="mb-4 px-4 py-3 bg-green-50 border border-green-200 rounded-xl text-sm text-green-700 font-semibold">${successMsg}</div>
                </c:if>
                <c:if test="${not empty errorMsg}">
                    <div class="mb-4 px-4 py-3 bg-red-50 border border-red-200 rounded-xl text-sm text-red-700 font-semibold">${errorMsg}</div>
                </c:if>

                <div class="bg-white rounded-3xl shadow-[0_8px_30px_rgb(0,0,0,0.04)] border border-gray-50 overflow-hidden">
                    <table class="w-full text-left border-collapse">
                        <thead>
                            <tr class="bg-gray-50/60 border-b border-gray-100">
                                <th class="py-4 px-5 text-xs font-bold text-gray-400 uppercase tracking-wider">Code</th>
                                <th class="py-4 px-5 text-xs font-bold text-gray-400 uppercase tracking-wider">Hiệu lực</th>
                                <th class="py-4 px-5 text-xs font-bold text-gray-400 uppercase tracking-wider">Đơn tối thiểu</th>
                                <th class="py-4 px-5 text-xs font-bold text-gray-400 uppercase tracking-wider">Đã dùng</th>
                                <th class="py-4 px-5 text-xs font-bold text-gray-400 uppercase tracking-wider">Status</th>
                                <th class="py-4 px-5 text-xs font-bold text-gray-400 uppercase tracking-wider">Publish</th>
                                <th class="py-4 px-5 text-xs font-bold text-gray-400 uppercase tracking-wider text-right">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-50">
                            <c:forEach var="v" items="${vouchers}">
                                <c:set var="computedStatus" value="ACTIVE"/>
                                <c:if test="${v.status != 'ACTIVE'}"><c:set var="computedStatus" value="INACTIVE"/></c:if>
                                    <c:if test="${v.status == 'ACTIVE' and not v.published}"><c:set var="computedStatus" value="PAUSED"/></c:if>
                                        <c:if test="${v.status == 'ACTIVE' and v.published and v.startAt.time > now.time}"><c:set var="computedStatus" value="UPCOMING"/></c:if>
                                            <c:if test="${v.status == 'ACTIVE' and v.published and v.endAt.time < now.time}"><c:set var="computedStatus" value="EXPIRED"/></c:if>
                                                <tr class="hover:bg-gray-50/40 transition-colors">
                                                    <td class="py-4 px-5">
                                                        <p class="font-bold text-gray-900">${v.code}</p>
                                                        <p class="text-xs text-gray-500 mt-0.5">${v.title}</p>
                                                    </td>
                                                    <td class="py-4 px-5 text-sm font-medium text-gray-700">
                                                        <fmt:formatDate value="${v.startAt}" pattern="dd/MM/yyyy"/> - <fmt:formatDate value="${v.endAt}" pattern="dd/MM/yyyy"/>
                                                    </td>
                                                    <td class="py-4 px-5 text-sm font-bold text-gray-900">
                                                        <fmt:formatNumber value="${v.minOrderAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                                    </td>
                                                    <td class="py-4 px-5 text-sm font-bold text-gray-900">
                                                        ${empty v.usedOrderCount ? 0 : v.usedOrderCount} đơn
                                                    </td>
                                                    <td class="py-4 px-5">
                                                        <span class="px-2.5 py-1 rounded-md text-[11px] font-bold uppercase
                                                        ${computedStatus == 'ACTIVE' ? 'bg-green-100 text-green-700' :
                                                        computedStatus == 'UPCOMING' ? 'bg-blue-100 text-blue-700' :
                                                        computedStatus == 'EXPIRED' ? 'bg-amber-100 text-amber-700' :
                                                        computedStatus == 'PAUSED' ? 'bg-purple-100 text-purple-700' :
                                                        'bg-gray-100 text-gray-500'}">${computedStatus}</span>
                                                    </td>
                                                    <td class="py-4 px-5">
                                                        <form method="POST" action="${pageContext.request.contextPath}/merchant/promotions" class="inline">
                                                            <input type="hidden" name="action" value="togglePublish"/>
                                                            <input type="hidden" name="voucherId" value="${v.id}"/>
                                                            <input type="hidden" name="publish" value="${not v.published}"/>
                                                            <button type="submit" class="px-3 py-1.5 rounded-lg text-xs font-bold ${v.published ? 'bg-blue-100 text-blue-700 hover:bg-blue-200' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}">
                                                                ${v.published ? 'Đang publish' : 'Chưa publish'}
                                                            </button>
                                                        </form>
                                                    </td>
                                                    <td class="py-4 px-5 text-right">
                                                        <form method="POST" action="${pageContext.request.contextPath}/merchant/promotions" class="inline" onsubmit="return confirm('Ẩn voucher này khỏi hoạt động?')">
                                                            <input type="hidden" name="action" value="delete"/>
                                                            <input type="hidden" name="voucherId" value="${v.id}"/>
                                                            <button type="submit" class="px-3 py-1.5 rounded-lg text-xs font-bold bg-red-50 text-red-600 hover:bg-red-100">Ẩn</button>
                                                        </form>
                                                    </td>
                                                </tr>
                                            </c:forEach>

                                            <c:if test="${empty vouchers}">
                                                <tr>
                                                    <td colspan="7" class="py-12 text-center text-gray-400 font-medium">Chưa có voucher nào cho cửa hàng.</td>
                                                </tr>
                                            </c:if>
                                        </tbody>
                                    </table>
                                </div>

                                <c:if test="${not empty vouchers}">
                                    <c:forEach var="v" items="${vouchers}">
                                        <c:if test="${v.code == 'DEMO15K'}">
                                            <div class="mt-4 px-4 py-3 bg-amber-50 border border-amber-200 rounded-xl text-sm text-amber-700 font-semibold">
                                                Seed voucher DEMO15K đang hiển thị và có thể thao tác như voucher thường.
                                            </div>
                                        </c:if>
                                    </c:forEach>
                                </c:if>
                            </div>
                        </main>

                        <div id="createModal" class="fixed inset-0 z-[60] hidden flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm">
                            <div class="bg-white w-full max-w-lg rounded-[2rem] shadow-2xl overflow-hidden relative">
                                <div class="flex items-center justify-between px-8 py-6 border-b border-gray-50">
                                    <h2 class="text-xl font-black text-gray-900 tracking-tight">Tạo Voucher Mới</h2>
                                    <button onclick="closeCreate()" class="text-gray-400 hover:text-gray-600 p-2 hover:bg-gray-100 rounded-full transition-colors">
                                        <span class="material-symbols-outlined">close</span>
                                    </button>
                                </div>

                                <form method="POST" action="${pageContext.request.contextPath}/merchant/promotions" class="p-8 space-y-5">
                                    <div>
                                        <label class="block text-sm font-bold text-gray-700 mb-2">Tên chương trình *</label>
                                        <input type="text" name="title" required class="w-full px-4 py-3 rounded-xl border border-gray-100 bg-gray-50 outline-none focus:bg-white focus:border-primary font-medium transition-all shadow-sm"/>
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
                                            <input type="number" name="value" required class="w-full px-4 py-3 rounded-xl border border-gray-100 bg-gray-50 outline-none focus:bg-white focus:border-primary font-black transition-all shadow-sm"/>
                                        </div>
                                    </div>

                                    <div>
                                        <label class="block text-sm font-bold text-gray-700 mb-2">Mã Voucher *</label>
                                        <input type="text" name="code" required oninput="this.value=this.value.toUpperCase()" class="w-full px-4 py-3 rounded-xl border border-gray-100 bg-gray-50 outline-none focus:bg-white focus:border-primary font-mono font-bold transition-all shadow-sm"/>
                                    </div>

                                    <div class="grid grid-cols-2 gap-4">
                                        <div>
                                            <label class="block text-sm font-bold text-gray-700 mb-2">Đơn tối thiểu (đ)</label>
                                            <input type="number" name="minOrder" value="0" class="w-full px-4 py-3 rounded-xl border border-gray-100 bg-gray-50 outline-none focus:bg-white focus:border-primary font-bold transition-all shadow-sm"/>
                                        </div>
                                        <div>
                                            <label class="block text-sm font-bold text-gray-700 mb-2">Tổng lượt dùng</label>
                                            <input type="number" name="maxUses" value="100" class="w-full px-4 py-3 rounded-xl border border-gray-100 bg-gray-50 outline-none focus:bg-white focus:border-primary font-bold transition-all shadow-sm"/>
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
                                        <button type="submit" class="flex-[2] bg-primary hover:bg-primary-dark text-white font-black py-3.5 rounded-xl shadow-lg shadow-primary/20 transition-all">Tạo voucher</button>
                                    </div>
                                </form>
                            </div>
                        </div>

                        <script>
                            function openCreate() {
                                document.getElementById('createModal').classList.remove('hidden');
                            }
                            function closeCreate() {
                                document.getElementById('createModal').classList.add('hidden');
                            }
                            document.getElementById('createModal').addEventListener('click', function (e) {
                                if (e.target === this)
                                closeCreate();
                            });
                        </script>
                    </body>
                </html>