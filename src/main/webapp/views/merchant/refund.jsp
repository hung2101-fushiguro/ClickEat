<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Hoàn tiền – ClickEat Merchant</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = { theme: { extend: { colors: { primary: '#c86601' } } } };
    </script>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
    <style>
        body { font-family: 'Inter', sans-serif; }
        .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
    </style>
</head>
<body class="bg-gray-50 min-h-screen flex">

<%@ include file="_nav.jsp" %>

<div class="flex-1 flex flex-col min-h-screen pb-16 md:pb-0">

    <div class="p-4 md:p-8 max-w-2xl mx-auto flex items-center justify-center min-h-[80vh] w-full mt-4">
        <div class="bg-white w-full rounded-2xl shadow-xl border border-gray-200 overflow-hidden">
            
            <!-- Header -->
            <div class="px-6 md:px-8 py-6 border-b border-gray-100 flex justify-between items-center bg-gray-50">
                <h2 class="text-xl font-bold text-gray-900">Xử lý Hoàn tiền</h2>
                <a href="${pageContext.request.contextPath}/merchant/orders" class="text-gray-400 hover:text-gray-600 transition-colors">
                    <span class="material-symbols-outlined">close</span>
                </a>
            </div>

            <div class="p-6 md:p-8 space-y-6">

                <!-- Warning banner -->
                <div class="bg-yellow-50 border border-yellow-100 rounded-lg p-4 flex gap-3">
                    <span class="material-symbols-outlined text-yellow-600">info</span>
                    <p class="text-sm text-yellow-800">Hoàn tiền được xử lý ngay lập tức và không thể hoàn tác sau khi xác nhận.</p>
                </div>

                <!-- Items -->
                <div>
                    <h3 class="font-semibold text-sm text-gray-800 mb-3">Chọn món cần hoàn tiền</h3>
                    <div class="space-y-2" id="itemsList"></div>
                </div>

                <!-- Reason -->
                <div>
                    <label class="block text-sm font-semibold text-gray-800 mb-2">Lý do hoàn tiền</label>
                    <div class="relative">
                        <select id="refundReason"
                                class="w-full px-4 py-3 rounded-xl border border-gray-200 bg-gray-50 outline-none focus:bg-white focus:border-primary focus:ring-4 focus:ring-primary/10 transition-all font-medium appearance-none text-gray-900">
                            <option value="">Chọn lý do...</option>
                            <option value="missing">Thiếu món</option>
                            <option value="quality">Chất lượng đồ ăn kém</option>
                            <option value="wrong">Giao sai món</option>
                            <option value="customer">Khách hàng yêu cầu</option>
                        </select>
                        <span class="material-symbols-outlined absolute right-3 top-3.5 text-gray-500 pointer-events-none">expand_more</span>
                    </div>
                </div>
            </div>

            <!-- Bottom bar -->
            <div class="px-6 md:px-8 py-6 bg-gray-50 border-t border-gray-100 flex justify-between items-center flex-wrap gap-4">
                <div>
                    <p class="text-xs text-gray-500 uppercase font-semibold tracking-wider">Tổng hoàn lại</p>
                    <p class="text-2xl font-bold text-primary" id="totalDisplay">0₫</p>
                </div>
                <div class="flex gap-3">
                    <a href="${pageContext.request.contextPath}/merchant/orders"
                       class="px-6 py-2.5 rounded-lg border border-gray-300 text-gray-600 font-semibold text-sm hover:bg-white transition-colors">
                        Hủy
                    </a>
                    <button onclick="submitRefund()" id="submitRefundBtn" disabled
                            class="px-6 py-2.5 rounded-lg bg-red-500 text-white font-semibold text-sm hover:bg-red-600 shadow-md disabled:opacity-50 disabled:cursor-not-allowed transition-colors">
                        Xác nhận
                    </button>
                </div>
            </div>

        </div>
    </div>
</div>

<script>
const items = [
    { id:1, name:'Bún bò Huế', qty:2, price:45000 },
    { id:2, name:'Gỏi cuốn tôm thịt (4 cuốn)', qty:1, price:35000 },
    { id:3, name:'Trà đào cam sả', qty:2, price:25000 },
];
let selected = new Set();

function renderItems() {
    const container = document.getElementById('itemsList');
    container.innerHTML = items.map(item => {
        const isChecked = selected.has(item.id);
        const borderClass = isChecked ? 'border-primary bg-orange-50/50' : 'border-gray-200 hover:border-gray-300';
        const boxClass = isChecked ? 'bg-primary border-primary text-white' : 'border-gray-300 bg-white';
        const checkIcon = isChecked ? '<span class="material-symbols-outlined text-sm">check</span>' : '';
        const itemTotal = (item.price * item.qty).toLocaleString('vi-VN');
        
        return `
        <div onclick="toggleItem(\${item.id})"
             class="flex justify-between items-center p-4 rounded-xl border cursor-pointer transition-all \${borderClass}">
            <div class="flex items-center gap-3">
                <div class="w-5 h-5 rounded border flex items-center justify-center \${boxClass}">
                    \${checkIcon}
                </div>
                <div>
                    <p class="font-semibold text-gray-900 text-sm">\${item.qty}x \${item.name}</p>
                </div>
            </div>
            <span class="font-semibold text-gray-900">\${itemTotal}₫</span>
        </div>`;
    }).join('');
    updateTotal();
    toggleSubmitButton();
}

function toggleItem(id) {
    if(selected.has(id)) selected.delete(id);
    else selected.add(id);
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
    const total = items.filter(i=>selected.has(i.id)).reduce((s,i)=>s+i.price*i.qty,0);
    document.getElementById('totalDisplay').textContent = total.toLocaleString('vi-VN')+'₫';
}

function submitRefund() {
    if(!selected.size){ alert('Vui lòng chọn ít nhất một món cần hoàn tiền.'); return; }
    const reason = document.getElementById('refundReason').value;
    if(!reason){ alert('Vui lòng chọn lý do hoàn tiền.'); return; }
    const total = items.filter(i=>selected.has(i.id)).reduce((s,i)=>s+i.price*i.qty,0);
    const totalStr = total.toLocaleString('vi-VN');
    if(confirm(`Xác nhận hoàn tiền \${totalStr}₫ cho đơn #CE-4820?`)){
        alert('Đã gửi yêu cầu hoàn tiền thành công!');
        window.location.href = '${pageContext.request.contextPath}/merchant/orders';
    }
}

renderItems();
</script>
</body>
</html>
