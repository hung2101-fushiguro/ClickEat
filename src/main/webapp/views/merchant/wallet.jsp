<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Ví tiền – ClickEat Merchant</title>
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

            <!-- Header -->
            <div class="flex flex-col gap-1 px-4 md:px-8 py-4 sticky top-0 z-30 bg-gray-50">
                <h1 class="text-3xl md:text-4xl font-bold text-gray-900 tracking-tight">Ví tiền</h1>
                <p class="text-gray-500">Quản lý thu nhập và rút tiền</p>
            </div>

            <div class="flex-1 px-4 md:px-8 py-6 space-y-6 overflow-y-auto max-w-7xl mx-auto w-full">

                <!-- Balance Hero Card -->
                <div class="relative overflow-hidden rounded-2xl bg-primary text-white p-6 md:p-10 shadow-xl group">
                    <span class="material-symbols-outlined absolute -right-10 -top-10 text-[180px] md:text-[240px] opacity-10 group-hover:scale-110 transition-transform duration-700">account_balance_wallet</span>
                    <div class="relative z-10">
                        <p class="text-white/80 font-medium text-lg">Số dư khả dụng</p>
                        <h2 class="text-4xl md:text-6xl font-bold mt-2 mb-2" id="balanceDisplay">${availableBalance}</h2>
                        <p class="text-white/60 text-sm mb-6">Sau phí nền tảng 10% · ${deliveredCount} đơn hoàn thành</p>
                        <div class="flex flex-wrap gap-3">
                            <button onclick="openWithdraw()"
                            class="bg-white text-primary px-6 md:px-8 py-3 rounded-xl font-bold shadow-lg hover:bg-gray-50 transition-colors flex items-center gap-2">
                            <span class="material-symbols-outlined text-xl">payments</span> Rút tiền
                        </button>
                    </div>
                </div>
            </div>

            <!-- Stats grid -->
            <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div class="bg-white p-6 rounded-xl border border-gray-200 shadow-sm">
                    <p class="text-gray-400 text-xs font-semibold uppercase tracking-wider mb-2">Tổng thu nhập</p>
                    <div class="flex items-baseline gap-2">
                        <h3 class="text-2xl md:text-3xl font-semibold">${totalIncome}</h3>
                    </div>
                </div>
                <div class="bg-white p-6 rounded-xl border border-gray-200 shadow-sm">
                    <p class="text-gray-400 text-xs font-semibold uppercase tracking-wider mb-2">Tháng này</p>
                    <div class="flex items-baseline gap-2">
                        <h3 class="text-2xl md:text-3xl font-semibold">${monthlyIncome}</h3>
                    </div>
                </div>
                <div class="bg-white p-6 rounded-xl border border-gray-200 shadow-sm">
                    <p class="text-gray-400 text-xs font-semibold uppercase tracking-wider mb-2">Đang xử lý</p>
                    <div class="flex items-baseline gap-2">
                        <h3 class="text-2xl md:text-3xl font-semibold">${pendingAmount}</h3>
                        <span class="text-gray-500 text-xs font-semibold bg-gray-100 px-2 py-0.5 rounded">Chờ giao</span>
                    </div>
                </div>
            </div>

            <!-- Withdrawal History -->
            <div class="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden">
                <div class="px-6 py-4 border-b border-gray-100 flex items-center justify-between">
                    <h3 class="font-semibold text-lg">Lịch sử rút tiền</h3>
                    <button onclick="openWithdraw()" class="text-primary text-sm font-semibold hover:underline flex items-center gap-1">
                        <span class="material-symbols-outlined text-base">add</span>Yêu cầu mới
                    </button>
                </div>
                <div class="overflow-x-auto">
                    <table class="w-full text-left min-w-[600px]">
                        <thead class="bg-gray-50 text-gray-500 text-xs uppercase font-semibold">
                            <tr>
                                <th class="px-6 py-3">Ngày yêu cầu</th>
                                <th class="px-6 py-3">Ngân hàng</th>
                                <th class="px-6 py-3">Số tài khoản</th>
                                <th class="px-6 py-3">Số tiền</th>
                                <th class="px-6 py-3">Trạng thái</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100 text-sm" id="withdrawTable"></tbody>
                    </table>
                </div>
            </div>

            <!-- Recent Transactions -->
            <div class="bg-white rounded-xl border border-gray-200 shadow-sm overflow-hidden">
                <div class="px-6 py-4 border-b border-gray-100">
                    <h3 class="font-semibold text-lg">Lịch sử đơn hàng gần đây</h3>
                </div>
                <div class="overflow-x-auto">
                    <table class="w-full text-left min-w-[500px]">
                        <thead class="bg-gray-50 text-gray-500 text-xs uppercase font-semibold">
                            <tr>
                                <th class="px-6 py-3">Ngày</th>
                                <th class="px-6 py-3">Mã đơn</th>
                                <th class="px-6 py-3">Trạng thái</th>
                                <th class="px-6 py-3">Số tiền</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-100 text-sm" id="txTable"></tbody>
                    </table>
                </div>
            </div>

        </div>
    </div>

    <!-- Withdrawal Modal -->
    <div id="withdrawModal" class="fixed inset-0 bg-black/60 z-50 hidden items-center justify-center p-4">
        <div class="absolute inset-0" onclick="closeWithdraw()"></div>
        <div class="relative bg-white rounded-2xl w-full max-w-md shadow-2xl overflow-hidden z-10">
            <!-- Header -->
            <div class="flex items-center justify-between px-6 py-4 border-b border-gray-100">
                <div class="flex items-center gap-2">
                    <span class="material-symbols-outlined text-primary">payments</span>
                    <h3 class="text-lg font-bold text-gray-900">Yêu cầu rút tiền</h3>
                </div>
                <button onclick="closeWithdraw()" class="p-1 rounded-lg hover:bg-gray-100 text-gray-400 hover:text-gray-600 transition-colors">
                    <span class="material-symbols-outlined">close</span>
                </button>
            </div>

            <!-- Balance hint -->
            <div class="mx-6 mt-4 mb-2 bg-primary/5 border border-primary/20 rounded-xl px-4 py-3 flex items-center justify-between">
                <span class="text-sm text-gray-600 font-medium">Số dư khả dụng</span>
                <span class="text-primary font-bold text-lg">${availableBalance}</span>
            </div>

            <div class="px-6 pb-6 space-y-4 pt-2">
                <div id="withdrawError" class="hidden mb-4 bg-red-50 border border-red-200 rounded-lg px-4 py-2.5 flex items-center gap-2 text-red-600 text-sm font-medium"></div>
                <!-- Amount -->
                <div>
                    <label class="block text-sm font-semibold text-gray-800 mb-1.5">Số tiền muốn rút <span class="text-red-500">*</span></label>
                    <div class="relative">
                        <input type="number" id="withdrawAmount" placeholder="VD: 1000000" min="100000" step="50000"
                        class="w-full px-4 py-2.5 pr-10 rounded-lg border border-gray-200 bg-gray-50 focus:bg-white focus:border-primary focus:ring-4 focus:ring-primary/10 outline-none transition-all font-medium"/>
                        <span class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 text-sm font-semibold">đ</span>
                    </div>
                    <div class="flex gap-2 mt-2 flex-wrap">
                        <button type="button" onclick="setAmount(500000)" class="text-xs px-2.5 py-1 rounded-full border border-gray-200 bg-gray-50 hover:bg-primary/10 hover:border-primary/40 hover:text-primary font-medium transition-colors">500,000đ</button>
                        <button type="button" onclick="setAmount(1000000)" class="text-xs px-2.5 py-1 rounded-full border border-gray-200 bg-gray-50 hover:bg-primary/10 hover:border-primary/40 hover:text-primary font-medium transition-colors">1,000,000đ</button>
                        <button type="button" onclick="setAmount(2000000)" class="text-xs px-2.5 py-1 rounded-full border border-gray-200 bg-gray-50 hover:bg-primary/10 hover:border-primary/40 hover:text-primary font-medium transition-colors">2,000,000đ</button>
                        <button type="button" onclick="setAmount(5000000)" class="text-xs px-2.5 py-1 rounded-full border border-gray-200 bg-gray-50 hover:bg-primary/10 hover:border-primary/40 hover:text-primary font-medium transition-colors">5,000,000đ</button>
                    </div>
                </div>
                <!-- Bank -->
                <div>
                    <label class="block text-sm font-semibold text-gray-800 mb-1.5">Ngân hàng <span class="text-red-500">*</span></label>
                    <select id="withdrawBank" class="w-full px-4 py-2.5 rounded-lg border border-gray-200 bg-gray-50 focus:bg-white focus:border-primary focus:ring-4 focus:ring-primary/10 outline-none transition-all font-medium">
                        <option value="">-- Chọn ngân hàng --</option>
                        <option value="Vietcombank">Vietcombank</option>
                        <option value="VietinBank">VietinBank</option>
                        <option value="BIDV">BIDV</option>
                        <option value="Agribank">Agribank</option>
                        <option value="Techcombank">Techcombank</option>
                        <option value="MB Bank">MB Bank</option>
                        <option value="ACB">ACB</option>
                        <option value="VPBank">VPBank</option>
                        <option value="TPBank">TPBank</option>
                        <option value="Sacombank">Sacombank</option>
                        <option value="HDBank">HDBank</option>
                        <option value="OCB">OCB</option>
                    </select>
                </div>
                <!-- Account number -->
                <div>
                    <label class="block text-sm font-semibold text-gray-800 mb-1.5">Số tài khoản <span class="text-red-500">*</span></label>
                    <input type="text" id="withdrawAccNum" placeholder="VD: 1234567890"
                    class="w-full px-4 py-2.5 rounded-lg border border-gray-200 bg-gray-50 focus:bg-white focus:border-primary focus:ring-4 focus:ring-primary/10 outline-none transition-all font-medium"/>
                </div>
                <!-- Account holder -->
                <div>
                    <label class="block text-sm font-semibold text-gray-800 mb-1.5">Tên chủ tài khoản <span class="text-red-500">*</span></label>
                    <input type="text" id="withdrawAccName" placeholder="VD: NGUYEN VAN A" oninput="this.value=this.value.toUpperCase()"
                    class="w-full px-4 py-2.5 rounded-lg border border-gray-200 bg-gray-50 focus:bg-white focus:border-primary focus:ring-4 focus:ring-primary/10 outline-none transition-all font-medium uppercase"/>
                    <p class="text-[11px] text-gray-400 mt-1">Nhập IN HOA đúng với tên trên thẻ ngân hàng</p>
                </div>
                <div class="flex gap-3 pt-1">
                    <button onclick="closeWithdraw()" class="flex-1 py-2.5 rounded-xl border border-gray-200 text-gray-600 font-semibold hover:bg-gray-50 transition-colors">Huỷ</button>
                    <button onclick="submitWithdraw()" id="btnConfirmWithdraw" class="flex-1 py-2.5 rounded-xl bg-primary text-white font-bold hover:bg-orange-600 shadow-md shadow-primary/20 transition-all flex items-center justify-center gap-2">
                        <span class="material-symbols-outlined text-base">send_money</span>Xác nhận rút
                    </button>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Withdrawal history — no withdrawal table yet
        document.getElementById('withdrawTable').innerHTML =
        '<tr><td colspan="5" class="px-5 py-8 text-center text-gray-400 text-sm">Chưa có lịch sử rút tiền</td></tr>';
        
        // Recent delivered orders from server
        (function() {
            const tbl = document.getElementById('txTable');
            const rows = [];
            <c:forEach var="row" items="${recentOrders}">
            rows.push(['${row[0]}', '${row[2]}', '${row[1]}']);
            </c:forEach>
            if (rows.length === 0) {
                tbl.innerHTML = '<tr><td colspan="4" class="px-5 py-8 text-center text-gray-400 text-sm">Chưa có giao dịch nào</td></tr>';
                } else {
                    rows.forEach(function(r) {
                        tbl.innerHTML += '<tr class="hover:bg-gray-50 transition-colors">' +
                        '<td class="px-5 py-3.5 text-gray-600">' + r[1] + '</td>' +
                        '<td class="px-5 py-3.5 font-mono text-primary font-medium">' + r[0] + '</td>' +
                        '<td class="px-5 py-3.5"><span class="px-2.5 py-1 rounded-full text-xs font-semibold bg-green-100 text-green-700">Ho\u00e0n th\u00e0nh</span></td>' +
                        '<td class="px-5 py-3.5 text-right font-bold text-green-600">+' + r[2] + '</td>' +
                        '</tr>';
                    });
                }
            })();
            
            function openWithdraw() {
                document.getElementById('withdrawModal').style.display='flex';
            }
            function closeWithdraw() {
                document.getElementById('withdrawModal').style.display='none';
                document.getElementById('withdrawError').classList.add('hidden');
            }
            function setAmount(v) {
                document.getElementById('withdrawAmount').value = v;
            }
            function submitWithdraw() {
                const amt = parseInt(document.getElementById('withdrawAmount').value)||0;
                const bank = document.getElementById('withdrawBank').value;
                const acc  = document.getElementById('withdrawAccNum').value.trim();
                const name = document.getElementById('withdrawAccName').value.trim();
                const errEl = document.getElementById('withdrawError');
                if(!amt||amt<50000){ errEl.textContent='Số tiền rút tối thiểu là 50,000₫'; errEl.classList.remove('hidden'); return; }
                if(!bank){ errEl.textContent='Vui lòng chọn ngân hàng.'; errEl.classList.remove('hidden'); return; }
                if(!acc){ errEl.textContent='Vui lòng nhập số tài khoản.'; errEl.classList.remove('hidden'); return; }
                if(!name){ errEl.textContent='Vui lòng nhập tên chủ tài khoản.'; errEl.classList.remove('hidden'); return; }
                closeWithdraw();
                alert('Đã gửi yêu cầu rút '+amt.toLocaleString('vi-VN')+'₫. Sẽ xử lý trong 1-2 ngày làm việc.');
            }
        </script>
    </body>
</html>