<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<% request.setAttribute("currentPage", "orders");%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Hoàn tiền – ClickEat Merchant</title>
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

            <div class="p-4 md:p-8 max-w-2xl mx-auto flex items-center justify-center min-h-[80vh] w-full mt-4">
                <div class="bg-white w-full rounded-[2rem] shadow-xl border border-gray-100 overflow-hidden">

                    <div class="px-6 md:px-8 py-6 border-b border-gray-100 flex justify-between items-center bg-white">
                        <h2 class="text-xl font-black text-gray-900 tracking-tight">Xử lý Hoàn tiền <c:if test="${not empty order}">#${order.id}</c:if></h2>
                        <a href="${pageContext.request.contextPath}/merchant/orders" class="text-gray-400 hover:text-gray-900 bg-gray-50 hover:bg-gray-100 p-2 rounded-full transition-colors flex items-center justify-center">
                            <span class="material-symbols-outlined">close</span>
                        </a>
                    </div>

                    <form method="POST" action="${pageContext.request.contextPath}/merchant/refund" id="refundForm">
                        <input type="hidden" name="orderId" value="${order.id}">
                        <input type="hidden" name="totalRefund" id="hiddenTotalRefund" value="0">
                        <input type="hidden" name="reason" id="hiddenReason" value="">

                        <div class="p-6 md:p-8 space-y-6">

                            <div class="bg-orange-50 border border-orange-100 rounded-xl p-4 flex gap-3">
                                <span class="material-symbols-outlined text-primary mt-0.5">info</span>
                                <p class="text-sm text-orange-900 font-medium leading-relaxed">Hoàn tiền được xử lý ngay lập tức về ví hoặc thẻ của khách hàng và <span class="font-bold text-red-600">không thể hoàn tác</span> sau khi xác nhận.</p>
                            </div>

                            <div>
                                <h3 class="font-bold text-sm text-gray-900 mb-3 uppercase tracking-wider">Chọn món cần hoàn tiền</h3>
                                <div class="space-y-3" id="itemsList"></div>
                            </div>

                            <div>
                                <label class="block text-sm font-bold text-gray-900 mb-2 uppercase tracking-wider">Lý do hoàn tiền</label>
                                <div class="relative">
                                    <select id="refundReason" required
                                            class="w-full px-4 py-3.5 rounded-xl border border-gray-200 bg-gray-50 outline-none focus:bg-white focus:border-primary font-bold appearance-none text-gray-900 transition-all shadow-sm">
                                        <option value="">-- Vui lòng chọn lý do --</option>
                                        <option value="missing">Thiếu món / Quên giao</option>
                                        <option value="quality">Chất lượng đồ ăn không đảm bảo</option>
                                        <option value="wrong">Giao sai món</option>
                                        <option value="customer">Khách hàng yêu cầu hoàn</option>
                                    </select>
                                    <span class="material-symbols-outlined absolute right-3 top-3.5 text-gray-400 pointer-events-none">expand_more</span>
                                </div>
                            </div>
                        </div>

                        <div class="px-6 md:px-8 py-6 bg-gray-50 border-t border-gray-100 flex justify-between items-center flex-wrap gap-4">
                            <div>
                                <p class="text-[10px] text-gray-400 uppercase font-black tracking-widest mb-1">Tổng tiền hoàn lại</p>
                                <p class="text-3xl font-black text-primary" id="totalDisplay">0₫</p>
                            </div>
                            <div class="flex gap-3">
                                <a href="${pageContext.request.contextPath}/merchant/orders"
                                   class="px-6 py-3 rounded-xl border-2 border-gray-200 text-gray-500 font-bold hover:bg-gray-100 transition-colors">
                                    Hủy bỏ
                                </a>
                                <button type="button" onclick="submitRefund()" id="submitRefundBtn" disabled
                                        class="px-6 py-3 rounded-xl bg-gray-900 text-white font-black hover:bg-black shadow-lg disabled:opacity-50 disabled:cursor-not-allowed transition-all flex items-center gap-2">
                                    <span class="material-symbols-outlined text-sm">payments</span> Xác nhận hoàn
                                </button>
                            </div>
                        </div>
                    </form>

                </div>
            </div>
        </div>

        <script>
        // Chuyển dữ liệu JSTL thành mảng Javascript (Đã cập nhật theo OrderItem.java)
            const items = [
            <c:forEach var="it" items="${items}">
                {id: ${it.id}, name: '${it.itemNameSnapshot}', qty: ${it.quantity}, price: ${it.unitPriceSnapshot}},
            </c:forEach>
            ];

            let selected = new Set();

            function renderItems() {
                const container = document.getElementById('itemsList');

                if (items.length === 0) {
                    container.innerHTML = '<p class="text-sm text-gray-500 italic">Không tìm thấy món ăn nào trong đơn hàng này.</p>';
                    return;
                }

                container.innerHTML = items.map(item => {
                    const isChecked = selected.has(item.id);
                    const borderClass = isChecked ? 'border-primary bg-orange-50/30' : 'border-gray-200 hover:border-gray-300 hover:bg-gray-50/50';
                    const boxClass = isChecked ? 'bg-primary border-primary text-white' : 'border-gray-300 bg-white';
                    const checkIcon = isChecked ? '<span class="material-symbols-outlined text-sm font-bold">check</span>' : '';
                    const itemTotal = (item.price * item.qty).toLocaleString('vi-VN');

                    return `
                <div onclick="toggleItem(\${item.id})"
                     class="flex justify-between items-center p-4 rounded-xl border-2 cursor-pointer transition-all \${borderClass}">
                    <div class="flex items-center gap-4">
                        <div class="w-5 h-5 rounded-md border-2 flex items-center justify-center transition-colors \${boxClass}">
                            \${checkIcon}
                        </div>
                        <div>
                            <p class="font-bold text-gray-900 text-sm">\${item.qty}x \${item.name}</p>
                            <p class="text-xs text-gray-500 font-medium mt-0.5">Đơn giá: \${item.price.toLocaleString('vi-VN')}₫</p>
                        </div>
                    </div>
                    <span class="font-black text-gray-900">\${itemTotal}₫</span>
                </div>`;
                }).join('');

                updateTotal();
                toggleSubmitButton();
            }

            function toggleItem(id) {
                if (selected.has(id))
                    selected.delete(id);
                else
                    selected.add(id);
                renderItems();
            }

            function toggleSubmitButton() {
                const btn = document.getElementById('submitRefundBtn');
                const reason = document.getElementById('refundReason').value;
                if (btn) {
                    btn.disabled = selected.size === 0 || !reason;
                }
            }

            document.getElementById('refundReason').addEventListener('change', toggleSubmitButton);

            function updateTotal() {
                const total = items.filter(i => selected.has(i.id)).reduce((s, i) => s + i.price * i.qty, 0);
                document.getElementById('totalDisplay').textContent = total.toLocaleString('vi-VN') + '₫';
            }

            function submitRefund() {
                if (!selected.size) {
                    alert('Vui lòng chọn ít nhất một món cần hoàn tiền.');
                    return;
                }

                const reason = document.getElementById('refundReason').value;
                if (!reason) {
                    alert('Vui lòng chọn lý do hoàn tiền.');
                    return;
                }

                const total = items.filter(i => selected.has(i.id)).reduce((s, i) => s + i.price * i.qty, 0);
                const totalStr = total.toLocaleString('vi-VN');

                // Hiện popup xác nhận
                if (confirm(`Bạn có chắc chắn muốn hoàn lại \${totalStr}₫ cho đơn hàng #${order.id}?`)) {
                    // Gắn dữ liệu vào thẻ hidden
                    document.getElementById('hiddenReason').value = reason;
                    document.getElementById('hiddenTotalRefund').value = total;

                    // Submit form về Servlet
                    document.getElementById('refundForm').submit();
                }
            }

        // Khởi chạy khi load trang
            renderItems();
        </script>
    </body>
</html>