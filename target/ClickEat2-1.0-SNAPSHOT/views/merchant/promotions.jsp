<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<jsp:useBean id="now" class="java.util.Date" />
<% request.setAttribute("currentPage", "promotions");%>
<!DOCTYPE html>
<html lang="vi">
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
            };
        </script>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet"/>
        <style>
            body { font-family: 'Inter', sans-serif; }
            .modal-active { overflow: hidden; }
        </style>
    </head>
    <body class="bg-[#f8f7f5] min-h-screen flex">

        <%@ include file="_nav.jsp" %>

        <main class="flex-1 flex flex-col h-screen overflow-y-auto">
            <header class="bg-white border-b border-gray-100 px-4 md:px-8 py-5 sticky top-0 z-10 flex justify-between items-center shadow-sm">
                <div>
                    <h1 class="text-2xl font-black text-gray-900 tracking-tight">Khuyến mãi</h1>
                    <p class="text-sm text-gray-500 font-medium mt-1">Quản lý mã code, trạng thái hoạt động, hiển thị và lưu trữ voucher</p>
                </div>
                <button onclick="openModal('createModal')" class="bg-primary hover:bg-primary-dark text-white px-5 py-2.5 rounded-xl font-bold transition-all shadow-md flex items-center gap-2">
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
                                <th class="py-4 px-5 text-xs font-bold text-gray-400 uppercase tracking-wider">Trạng thái</th>
                                <th class="py-4 px-5 text-xs font-bold text-gray-400 uppercase tracking-wider">Hiển thị</th>
                                <th class="py-4 px-5 text-xs font-bold text-gray-400 uppercase tracking-wider text-right">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-50">
                            <c:forEach var="v" items="${vouchers}">
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
                                        <c:choose>
                                            <c:when test="${v.status ne 'ACTIVE'}">
                                                <span class="px-2.5 py-1 rounded-md text-[11px] font-bold uppercase bg-gray-100 text-gray-600">Tạm dừng</span>
                                            </c:when>
                                            <c:when test="${not v.published}">
                                                <span class="px-2.5 py-1 rounded-md text-[11px] font-bold uppercase bg-slate-100 text-slate-600">Nháp</span>
                                            </c:when>
                                            <c:when test="${not empty v.startAt and v.startAt.time > now.time}">
                                                <span class="px-2.5 py-1 rounded-md text-[11px] font-bold uppercase bg-amber-100 text-amber-700">Sắp diễn ra</span>
                                            </c:when>
                                            <c:when test="${not empty v.endAt and v.endAt.time < now.time}">
                                                <span class="px-2.5 py-1 rounded-md text-[11px] font-bold uppercase bg-red-100 text-red-700">Hết hạn</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="px-2.5 py-1 rounded-md text-[11px] font-bold uppercase bg-green-100 text-green-700">Đang chạy</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="py-4 px-5">
                                        <c:choose>
                                            <c:when test="${v.published}">
                                                <span class="px-2.5 py-1 rounded-md text-[11px] font-bold uppercase bg-blue-100 text-blue-700">Hiển thị</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="px-2.5 py-1 rounded-md text-[11px] font-bold uppercase bg-gray-100 text-gray-600">Ẩn</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="py-4 px-5 text-right">
                                        <form method="POST" action="${pageContext.request.contextPath}/merchant/promotions" class="inline">
                                            <input type="hidden" name="action" value="toggleStatus"/>
                                            <input type="hidden" name="voucherId" value="${v.id}"/>
                                            <button type="submit" class="px-3 py-1.5 rounded-lg text-xs font-bold ${v.status == 'ACTIVE' ? 'bg-amber-50 text-amber-700 hover:bg-amber-100' : 'bg-emerald-50 text-emerald-700 hover:bg-emerald-100'} mr-2">
                                                ${v.status == 'ACTIVE' ? 'Tạm dừng' : 'Kích hoạt'}
                                            </button>
                                        </form>

                                        <form method="POST" action="${pageContext.request.contextPath}/merchant/promotions" class="inline">
                                            <input type="hidden" name="action" value="togglePublish"/>
                                            <input type="hidden" name="voucherId" value="${v.id}"/>
                                            <button type="submit" class="px-3 py-1.5 rounded-lg text-xs font-bold ${v.published ? 'bg-slate-100 text-slate-700 hover:bg-slate-200' : 'bg-blue-100 text-blue-700 hover:bg-blue-200'}">
                                                ${v.published ? 'Ẩn' : 'Hiển thị'}
                                            </button>
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
                <div class="flex items-center justify-between px-4 md:px-8 py-6 border-b border-gray-50">
                    <h2 class="text-xl font-black text-gray-900 tracking-tight">Tạo Voucher Mới</h2>
                    <button onclick="closeModal('createModal')" class="text-gray-400 hover:text-gray-600 p-2 hover:bg-gray-100 rounded-full transition-colors">
                        <span class="material-symbols-outlined">close</span>
                    </button>
                </div>

                <form method="POST" action="${pageContext.request.contextPath}/merchant/promotions" class="p-8 space-y-5">
                    <input type="hidden" name="action" value="create"/>
                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-2">Tên chương trình *</label>
                        <input type="text" name="title" required class="w-full px-4 py-3 rounded-xl border border-gray-100 bg-gray-50 outline-none focus:bg-white focus:border-primary font-medium transition-all shadow-sm"/>
                    </div>

                    <%-- Messages --%>
                    <c:if test="${not empty successMsg}">
                        <div class="bg-green-50 border border-green-200 text-green-700 px-4 py-3 rounded-2xl flex items-center gap-3 animate-pulse">
                            <span class="material-symbols-outlined">check_circle</span>
                            <span class="text-sm font-bold">${successMsg}</span>
                        </div>
                    </c:if>
                    <c:if test="${not empty errorMsg}">
                        <div class="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-2xl flex items-center gap-3">
                            <span class="material-symbols-outlined">error</span>
                            <span class="text-sm font-bold">${errorMsg}</span>
                        </div>
                    </c:if>

                    <%-- Voucher Grid/Table --%>
                    <div class="bg-white rounded-3xl border border-gray-100 shadow-sm overflow-hidden">
                        <div class="overflow-x-auto">
                            <table class="w-full text-left border-collapse">
                                <thead>
                                    <tr class="bg-gray-50/50 border-b border-gray-100">
                                        <th class="px-6 py-4 text-xs font-black text-gray-400 uppercase tracking-widest">Voucher</th>
                                        <th class="px-6 py-4 text-xs font-black text-gray-400 uppercase tracking-widest text-center">Loại / Giá trị</th>
                                        <th class="px-6 py-4 text-xs font-black text-gray-400 uppercase tracking-widest text-center">Sử dụng</th>
                                        <th class="px-6 py-4 text-xs font-black text-gray-400 uppercase tracking-widest">Thời hạn</th>
                                        <th class="px-6 py-4 text-xs font-black text-gray-400 uppercase tracking-widest">Trạng thái</th>
                                        <th class="px-6 py-4 text-xs font-black text-gray-400 uppercase tracking-widest text-right">Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody class="divide-y divide-gray-50">
                                    <c:choose>
                                        <c:when test="${empty vouchers}">
                                            <tr>
                                                <td colspan="6" class="px-6 py-20 text-center">
                                                    <div class="flex flex-col items-center">
                                                        <span class="material-symbols-outlined text-6xl text-gray-200 mb-4">confirmation_number</span>
                                                        <p class="text-gray-500 font-bold">Chưa có voucher nào được tạo.</p>
                                                        <p class="text-gray-400 text-sm mt-1">Hãy tạo voucher đầu tiên để bắt đầu chiến dịch của bạn.</p>
                                                    </div>
                                                </td>
                                            </tr>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach var="v" items="${vouchers}">
                                                <tr class="hover:bg-gray-50/50 transition-colors">
                                                    <td class="px-6 py-5">
                                                        <div class="flex flex-col">
                                                            <span class="text-sm font-black text-gray-900 bg-gray-100 self-start px-2 py-0.5 rounded-lg mb-1">${v.code}</span>
                                                            <span class="text-sm font-bold text-gray-600 truncate max-w-[200px]">${v.title}</span>
                                                        </div>
                                                    </td>
                                                    <td class="px-6 py-5 text-center">
                                                        <div class="flex flex-col items-center">
                                                            <span class="text-sm font-black text-primary">${v.displayDiscount}</span>
                                                            <span class="text-[10px] text-gray-400 font-bold uppercase mt-1">
                                                                Đơn từ <fmt:formatNumber value="${v.minOrderAmount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                                            </span>
                                                        </div>
                                                    </td>
                                                    <td class="px-6 py-5 text-center">
                                                        <div class="flex flex-col items-center">
                                                            <span class="text-sm font-black text-gray-900">${v.usedOrderCount} / ${v.maxUsesTotal}</span>
                                                            <div class="w-16 h-1.5 bg-gray-100 rounded-full mt-1.5 overflow-hidden">
                                                                <div class="h-full bg-primary" style="width: ${v.maxUsesTotal > 0 ? (v.usedOrderCount * 100 / v.maxUsesTotal) : 0}%"></div>
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td class="px-6 py-5">
                                                        <div class="flex flex-col text-[11px] font-bold">
                                                            <span class="text-gray-500">Bắt đầu: <fmt:formatDate value="${v.startAt}" pattern="dd/MM/yyyy"/></span>
                                                            <span class="text-gray-900">Kết thúc: <fmt:formatDate value="${v.endAt}" pattern="dd/MM/yyyy"/></span>
                                                        </div>
                                                    </td>
                                                    <td class="px-6 py-5">
                                                        <c:choose>
                                                            <c:when test="${v.status ne 'ACTIVE'}">
                                                                <span class="inline-flex px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-wider bg-gray-100 text-gray-600">Tạm dừng</span>
                                                            </c:when>
                                                            <c:when test="${not v.published}">
                                                                <span class="inline-flex px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-wider bg-slate-100 text-slate-600">Nháp</span>
                                                            </c:when>
                                                            <c:when test="${not empty v.startAt and v.startAt.time > now.time}">
                                                                <span class="inline-flex px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-wider bg-amber-100 text-amber-700">Sắp diễn ra</span>
                                                            </c:when>
                                                            <c:when test="${not empty v.endAt and v.endAt.time < now.time}">
                                                                <span class="inline-flex px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-wider bg-red-100 text-red-700">Hết hạn</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="inline-flex px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-wider bg-green-100 text-green-700">Đang chạy</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td class="px-6 py-5 text-right">
                                                        <div class="flex items-center justify-end gap-2">
                                                            <%-- Toggle Publish (Show/Hide) --%>
                                                            <form method="POST" action="${pageContext.request.contextPath}/merchant/promotions" class="inline">
                                                                <input type="hidden" name="action" value="togglePublish"/>
                                                                <input type="hidden" name="voucherId" value="${v.id}"/>
                                                                <button type="submit"
                                                                title="${v.published ? 'Ẩn khỏi khách' : 'Hiển thị cho khách'}"
                                                                class="p-2 rounded-xl border border-gray-100 hover:bg-gray-100 transition-colors ${v.published ? 'text-primary bg-primary/5' : 'text-gray-400'}">
                                                                <span class="material-symbols-outlined text-[20px]">${v.published ? 'visibility' : 'visibility_off'}</span>
                                                            </button>
                                                        </form>

                                                        <%-- Toggle Status (Play/Pause) --%>
                                                        <form method="POST" action="${pageContext.request.contextPath}/merchant/promotions" class="inline">
                                                            <input type="hidden" name="action" value="toggleStatus"/>
                                                            <input type="hidden" name="voucherId" value="${v.id}"/>
                                                            <button type="submit"
                                                            title="${v.status == 'ACTIVE' ? 'Tạm dừng' : 'Kích hoạt'}"
                                                            class="p-2 rounded-xl border border-gray-100 hover:bg-gray-100 transition-colors ${v.status == 'ACTIVE' ? 'text-green-600 bg-green-50' : 'text-orange-500 bg-orange-50'}">
                                                            <span class="material-symbols-outlined text-[20px]">${v.status == 'ACTIVE' ? 'pause_circle' : 'play_circle'}</span>
                                                        </button>
                                                    </form>

                                                    <%-- Edit --%>
                                                    <button type="button"
                                                            onclick="openEditModalFromButton(this)"
                                                            data-id="${v.id}"
                                                            data-code="${fn:escapeXml(v.code)}"
                                                            data-title="${fn:escapeXml(v.title)}"
                                                            data-discount-type="${v.discountType}"
                                                            data-discount-value="${v.discountValue}"
                                                            data-min-order="${v.minOrderAmount}"
                                                            data-max-uses="${v.maxUsesTotal}"
                                                            data-start-date="<fmt:formatDate value='${v.startAt}' pattern='yyyy-MM-dd'/>"
                                                            data-end-date="<fmt:formatDate value='${v.endAt}' pattern='yyyy-MM-dd'/>"
                                                            class="p-2 rounded-xl border border-gray-100 hover:bg-gray-100 transition-colors text-blue-600">
                                                        <span class="material-symbols-outlined text-[20px]">edit</span>
                                                    </button>

                                                    <%-- Archive (Soft Delete) --%>
                                                    <form method="POST" action="${pageContext.request.contextPath}/merchant/promotions" class="inline" onsubmit="return confirm('Bạn có chắc muốn lưu trữ (xóa tạm) voucher này?')">
                                                        <input type="hidden" name="action" value="archive"/>
                                                        <input type="hidden" name="voucherId" value="${v.id}"/>
                                                        <button type="submit" class="p-2 rounded-xl border border-gray-100 hover:bg-red-50 text-red-500 transition-colors">
                                                            <span class="material-symbols-outlined text-[20px]">archive</span>
                                                        </button>
                                                    </form>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>
</div>

<%-- Create Modal --%>
<div id="createModal" class="hidden fixed inset-0 z-[100] overflow-y-auto bg-black/50 backdrop-blur-sm flex items-center justify-center p-4">
    <div class="bg-white rounded-[2rem] w-full max-w-xl shadow-2xl overflow-hidden animate-in fade-in zoom-in duration-200">
        <div class="px-8 py-6 border-b border-gray-100 flex justify-between items-center bg-gray-50/50">
            <div>
                <h3 class="text-xl font-black text-gray-900">Tạo Voucher mới</h3>
                <p class="text-xs text-gray-500 font-bold uppercase mt-1">Cấu hình ưu đãi cho khách hàng</p>
            </div>
            <button onclick="closeModal('createModal')" class="p-2 hover:bg-gray-200 rounded-full transition-colors"><span class="material-symbols-outlined">close</span></button>
        </div>
        <form method="POST" action="${pageContext.request.contextPath}/merchant/promotions" class="p-8 space-y-5">
            <input type="hidden" name="action" value="create"/>
            <div class="grid grid-cols-2 gap-4">
                <div class="col-span-2 md:col-span-1">
                    <label class="block text-xs font-black text-gray-500 uppercase mb-2">Mã Voucher</label>
                    <input type="text" name="code" placeholder="VD: Giam10" required
                    class="w-full px-4 py-3 rounded-2xl border border-gray-100 bg-gray-50 focus:bg-white focus:outline-none focus:ring-4 focus:ring-primary/10 transition-all font-bold"/>
                </div>
                <div class="col-span-2 md:col-span-1">
                    <label class="block text-xs font-black text-gray-500 uppercase mb-2">Tiêu đề hiển thị</label>
                    <input type="text" name="title" placeholder="VD: Giảm ngay 10% cho đơn đầu" required
                    class="w-full px-4 py-3 rounded-2xl border border-gray-100 bg-gray-50 focus:bg-white focus:outline-none focus:ring-4 focus:ring-primary/10 transition-all font-bold"/>
                </div>
                <div class="col-span-2 md:col-span-1">
                    <label class="block text-xs font-black text-gray-500 uppercase mb-2">Loại giảm giá</label>
                    <select name="type" required class="w-full px-4 py-3 rounded-2xl border border-gray-100 bg-gray-50 focus:bg-white focus:outline-none focus:ring-4 focus:ring-primary/10 transition-all font-bold appearance-none">
                        <option value="PERCENT">Giảm theo %</option>
                        <option value="FIXED">Số tiền cố định (VNĐ)</option>
                    </select>
                </div>
                <div class="col-span-2 md:col-span-1">
                    <label class="block text-xs font-black text-gray-500 uppercase mb-2">Giá trị giảm</label>
                    <input type="number" name="value" placeholder="VD: 10 hoặc 20000" required
                    class="w-full px-4 py-3 rounded-2xl border border-gray-100 bg-gray-50 focus:bg-white focus:outline-none focus:ring-4 focus:ring-primary/10 transition-all font-bold"/>
                </div>
                <div class="col-span-2 md:col-span-1">
                    <label class="block text-xs font-black text-gray-500 uppercase mb-2">Đơn tối thiểu</label>
                    <input type="number" name="minOrder" placeholder="0" required
                    class="w-full px-4 py-3 rounded-2xl border border-gray-100 bg-gray-50 focus:bg-white focus:outline-none focus:ring-4 focus:ring-primary/10 transition-all font-bold"/>
                </div>
                <div class="col-span-2 md:col-span-1">
                    <label class="block text-xs font-black text-gray-500 uppercase mb-2">Tổng lượt dùng</label>
                    <input type="number" name="maxUses" placeholder="VD: 100" required
                    class="w-full px-4 py-3 rounded-2xl border border-gray-100 bg-gray-50 focus:bg-white focus:outline-none focus:ring-4 focus:ring-primary/10 transition-all font-bold"/>
                </div>
                <div class="col-span-2 md:col-span-1">
                    <label class="block text-xs font-black text-gray-500 uppercase mb-2">Ngày bắt đầu</label>
                    <input type="date" name="startDate" required
                    class="w-full px-4 py-3 rounded-2xl border border-gray-100 bg-gray-50 focus:bg-white focus:outline-none focus:ring-4 focus:ring-primary/10 transition-all font-bold"/>
                </div>
                <div class="col-span-2 md:col-span-1">
                    <label class="block text-xs font-black text-gray-500 uppercase mb-2">Ngày kết thúc</label>
                    <input type="date" name="endDate" required
                    class="w-full px-4 py-3 rounded-2xl border border-gray-100 bg-gray-50 focus:bg-white focus:outline-none focus:ring-4 focus:ring-primary/10 transition-all font-bold"/>
                </div>
            </div>
            <div class="pt-4 flex gap-3">
                <button type="button" onclick="closeModal('createModal')" class="flex-1 px-4 py-3 rounded-2xl border border-gray-200 font-bold text-gray-600 hover:bg-gray-50 transition-all">Hủy bỏ</button>
                <button type="submit" class="flex-1 px-4 py-3 rounded-2xl bg-primary text-white font-bold hover:bg-primary-dark shadow-lg shadow-primary/20 transition-all">Xác nhận tạo</button>
            </div>
        </form>
    </div>
</div>

<%-- Edit Modal --%>
<div id="editModal" class="hidden fixed inset-0 z-[100] overflow-y-auto bg-black/50 backdrop-blur-sm flex items-center justify-center p-4">
    <div class="bg-white rounded-[2rem] w-full max-w-xl shadow-2xl overflow-hidden animate-in fade-in zoom-in duration-200">
        <div class="px-8 py-6 border-b border-gray-100 flex justify-between items-center bg-gray-50/50">
            <div>
                <h3 class="text-xl font-black text-gray-900">Chỉnh sửa Voucher</h3>
                <p class="text-xs text-gray-500 font-bold uppercase mt-1">Cập nhật thông tin ưu đãi</p>
            </div>
            <button onclick="closeModal('editModal')" class="p-2 hover:bg-gray-200 rounded-full transition-colors"><span class="material-symbols-outlined">close</span></button>
        </div>
        <form id="editForm" method="POST" action="${pageContext.request.contextPath}/merchant/promotions" class="p-8 space-y-5">
            <input type="hidden" name="action" value="edit"/>
            <input type="hidden" name="voucherId" id="editVoucherId"/>
            <div class="grid grid-cols-2 gap-4">
                <%-- Same fields as create form but with IDs for JS population --%>
                <div class="col-span-2 md:col-span-1">
                    <label class="block text-xs font-black text-gray-500 uppercase mb-2">Mã Voucher</label>
                    <input type="text" name="code" id="editCode" readonly class="w-full px-4 py-3 rounded-2xl border border-gray-100 bg-gray-100 text-gray-500 font-bold cursor-not-allowed"/>
                </div>
                <div class="col-span-2 md:col-span-1">
                    <label class="block text-xs font-black text-gray-500 uppercase mb-2">Tiêu đề hiển thị</label>
                    <input type="text" name="title" id="editTitle" required class="w-full px-4 py-3 rounded-2xl border border-gray-100 bg-gray-50 focus:bg-white focus:outline-none focus:ring-4 focus:ring-primary/10 font-bold"/>
                </div>
                <div class="col-span-2 md:col-span-1">
                    <label class="block text-xs font-black text-gray-500 uppercase mb-2">Loại giảm giá</label>
                    <select name="type" id="editType" required class="w-full px-4 py-3 rounded-2xl border border-gray-100 bg-gray-50 focus:bg-white focus:outline-none focus:ring-4 focus:ring-primary/10 font-bold appearance-none">
                        <option value="PERCENT">Giảm theo %</option>
                        <option value="FIXED">Số tiền cố định (VNĐ)</option>
                    </select>
                </div>
                <div class="col-span-2 md:col-span-1">
                    <label class="block text-xs font-black text-gray-500 uppercase mb-2">Giá trị giảm</label>
                    <input type="number" name="value" id="editValue" required class="w-full px-4 py-3 rounded-2xl border border-gray-100 bg-gray-50 focus:bg-white focus:outline-none focus:ring-4 focus:ring-primary/10 font-bold"/>
                </div>
                <div class="col-span-2 md:col-span-1">
                    <label class="block text-xs font-black text-gray-500 uppercase mb-2">Đơn tối thiểu</label>
                    <input type="number" name="minOrder" id="editMinOrder" required class="w-full px-4 py-3 rounded-2xl border border-gray-100 bg-gray-50 focus:bg-white focus:outline-none focus:ring-4 focus:ring-primary/10 font-bold"/>
                </div>
                <div class="col-span-2 md:col-span-1">
                    <label class="block text-xs font-black text-gray-500 uppercase mb-2">Tổng lượt dùng</label>
                    <input type="number" name="maxUses" id="editMaxUses" required class="w-full px-4 py-3 rounded-2xl border border-gray-100 bg-gray-50 focus:bg-white focus:outline-none focus:ring-4 focus:ring-primary/10 font-bold"/>
                </div>
                <div class="col-span-2 md:col-span-1">
                    <label class="block text-xs font-black text-gray-500 uppercase mb-2">Ngày bắt đầu</label>
                    <input type="date" name="startDate" id="editStartDate" required class="w-full px-4 py-3 rounded-2xl border border-gray-100 bg-gray-50 font-bold"/>
                </div>
                <div class="col-span-2 md:col-span-1">
                    <label class="block text-xs font-black text-gray-500 uppercase mb-2">Ngày kết thúc</label>
                    <input type="date" name="endDate" id="editEndDate" required class="w-full px-4 py-3 rounded-2xl border border-gray-100 bg-gray-50 font-bold"/>
                </div>
            </div>
            <div class="pt-4 flex gap-3">
                <button type="button" onclick="closeModal('editModal')" class="flex-1 px-4 py-3 rounded-2xl border border-gray-200 font-bold text-gray-600 hover:bg-gray-50 transition-all">Quay lại</button>
                <button type="submit" class="flex-1 px-4 py-3 rounded-2xl bg-primary text-white font-bold hover:bg-primary-dark shadow-lg shadow-primary/20 transition-all">Lưu thay đổi</button>
            </div>
        </form>
    </div>
</div>

<script>
    function openModal(id) {
        document.getElementById(id).classList.remove('hidden');
        document.body.classList.add('modal-active');
    }

    function closeModal(id) {
        document.getElementById(id).classList.add('hidden');
        document.body.classList.remove('modal-active');
    }

    function openEditModal(id, code, title, discountType, discountValue, minOrder, maxUses, startDate, endDate) {
        document.getElementById('editVoucherId').value = id || '';
        document.getElementById('editCode').value = code || '';
        document.getElementById('editTitle').value = title || '';
        document.getElementById('editType').value = discountType || 'PERCENT';
        document.getElementById('editValue').value = discountValue || 0;
        document.getElementById('editMinOrder').value = minOrder || 0;
        document.getElementById('editMaxUses').value = maxUses || 0;
        document.getElementById('editStartDate').value = startDate || '';
        document.getElementById('editEndDate').value = endDate || '';
        openModal('editModal');
    }

    function openEditModalFromButton(button) {
        openEditModal(
            button.dataset.id,
            button.dataset.code,
            button.dataset.title,
            button.dataset.discountType,
            parseFloat(button.dataset.discountValue || '0'),
            parseFloat(button.dataset.minOrder || '0'),
            parseInt(button.dataset.maxUses || '0', 10),
            button.dataset.startDate,
            button.dataset.endDate
        );
    }
    
    document.getElementById('createModal').addEventListener('click', function (e) {
        if (e.target === this) {
            closeModal('createModal');
        }
    });

    document.getElementById('editModal').addEventListener('click', function (e) {
        if (e.target === this) {
            closeModal('editModal');
        }
    });
</script>
</body>
</html>