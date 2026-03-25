<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<% request.setAttribute("currentPage", "promotions"); %>
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

        <div class="flex-1 flex flex-col min-h-screen pb-16 md:pb-0">
            <main class="flex-1 overflow-y-auto">
                <div class="p-4 md:p-8 max-w-6xl mx-auto space-y-6">
                    
                    <%-- Header Section --%>
                    <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
                        <div>
                            <h1 class="text-3xl font-black text-gray-900 tracking-tight">Voucher & Khuyến mãi</h1>
                            <p class="text-gray-500 text-sm mt-1 font-medium">Tạo mã giảm giá để thu hút khách hàng và tăng doanh thu.</p>
                        </div>
                        <button onclick="openModal('createModal')" 
                                class="flex items-center gap-2 bg-primary hover:bg-primary-dark text-white px-5 py-2.5 rounded-2xl font-bold transition-all shadow-lg shadow-primary/20">
                            <span class="material-symbols-outlined">add_circle</span>
                            Tạo Voucher mới
                        </button>
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
                                                        <span class="inline-flex px-3 py-1 rounded-full text-[10px] font-black uppercase tracking-wider ${v.merchantStatusClass}">
                                                            ${v.merchantStatusLabel}
                                                        </span>
                                                    </td>
                                                    <td class="px-6 py-5 text-right">
                                                        <div class="flex items-center justify-end gap-2">
                                                            <%-- Toggle Publish (Show/Hide) --%>
                                                            <form method="POST" action="${pageContext.request.contextPath}/merchant/promotions" class="inline">
                                                                <input type="hidden" name="action" value="togglePublish"/>
                                                                <input type="hidden" name="voucherId" value="${v.id}"/>
                                                                <button type="submit" 
                                                                        title="${v.isPublished() ? 'Ẩn khỏi khách' : 'Hiển thị cho khách'}"
                                                                        class="p-2 rounded-xl border border-gray-100 hover:bg-gray-100 transition-colors ${v.isPublished() ? 'text-primary bg-primary/5' : 'text-gray-400'}">
                                                                    <span class="material-symbols-outlined text-[20px]">${v.isPublished() ? 'visibility' : 'visibility_off'}</span>
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
                                                            <button onclick="openEditModal(${v.id}, '${v.code}', '${fn:escapeXml(v.title)}', '${v.discountType}', ${v.discountValue}, ${v.minOrderAmount}, ${v.maxUsesTotal}, '<fmt:formatDate value="${v.startAt}" pattern="yyyy-MM-dd"/>', '<fmt:formatDate value="${v.endAt}" pattern="yyyy-MM-dd"/>')"
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

            function openEditModal(id, code, title, type, value, minOrder, maxUses, start, end) {
                document.getElementById('editVoucherId').value = id;
                document.getElementById('editCode').value = code;
                document.getElementById('editTitle').value = title;
                document.getElementById('editType').value = type;
                document.getElementById('editValue').value = value;
                document.getElementById('editMinOrder').value = minOrder;
                document.getElementById('editMaxUses').value = maxUses;
                document.getElementById('editStartDate').value = start;
                document.getElementById('editEndDate').value = end;
                openModal('editModal');
            }

            // Close modal on escape
            window.addEventListener('keydown', (e) => {
                if (e.key === 'Escape') {
                    document.querySelectorAll('[id$="Modal"]').forEach(m => m.classList.add('hidden'));
                    document.body.classList.remove('modal-active');
                }
            });
        </script>
    </body>
</html>