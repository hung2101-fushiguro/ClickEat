<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Khuyến mãi – ClickEat Merchant</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <script>
            tailwind.config = { theme: { extend: { colors: { primary: '#c86601' } } } };
        </script>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
        <style>
            body { font-family: 'Inter', sans-serif; }
            .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
            .toggle-cb:checked + .toggle-track { background-color: #c86601; }
            .toggle-cb:checked + .toggle-track .toggle-thumb { transform: translateX(20px); }
        </style>
    </head>
    <body class="bg-gray-50 min-h-screen flex">

        <%@ include file="_nav.jsp" %>

        <div class="flex-1 flex flex-col min-h-screen pb-16 md:pb-0">

            <!-- Header -->
            <div class="flex flex-col md:flex-row justify-between items-start md:items-center gap-4 px-4 md:px-8 py-4">
                <div>
                    <h1 class="text-3xl font-bold text-gray-900 tracking-tight">Khuyến mãi</h1>
                    <p class="text-gray-500 mt-1">Tăng doanh số với các voucher hấp dẫn</p>
                </div>
                <button onclick="openCreate()"
                class="w-full md:w-auto bg-primary hover:bg-orange-600 text-white px-6 py-3 rounded-xl font-semibold shadow-lg shadow-primary/20 transition-all flex items-center justify-center gap-2">
                <span class="material-symbols-outlined">add_circle</span> Tạo Khuyến mãi
            </button>
        </div>

        <div class="flex-1 px-4 md:px-8 py-2 overflow-y-auto">
            <div class="grid grid-cols-1 xl:grid-cols-2 gap-6" id="voucherGrid"></div>
            <div id="emptyVouchers" class="hidden flex-col items-center justify-center py-16 text-gray-400">
                <span class="material-symbols-outlined text-6xl mb-3">sell</span>
                <p class="font-semibold text-lg">Chưa có khuyến mãi nào</p>
                <p class="text-sm mt-1">Bấm "Tạo Khuyến mãi" để bắt đầu</p>
            </div>
        </div>
    </div>

    <div id="createModal" class="fixed inset-0 z-[60] hidden flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm">
        <div class="absolute inset-0" onclick="closeCreate()"></div>
        <div class="relative bg-white w-full max-w-lg rounded-2xl shadow-2xl overflow-hidden z-10">
            <div class="flex items-center justify-between px-6 py-4 border-b border-gray-100">
                <h2 class="text-xl font-semibold text-gray-900">Tạo Khuyến Mãi Mới</h2>
                <button onclick="closeCreate()" class="text-gray-400 hover:text-gray-600 p-1 hover:bg-gray-100 rounded-lg">
                    <span class="material-symbols-outlined">close</span>
                </button>
            </div>
            <div class="p-6 space-y-4 max-h-[70vh] overflow-y-auto">
                <div>
                    <label class="block text-sm font-semibold text-gray-800 mb-2">Tên chương trình *</label>
                    <input type="text" id="v_title" placeholder="VD: Chào Hè Rực Rỡ"
                    class="w-full px-4 py-3 rounded-xl border border-gray-200 bg-gray-50 outline-none focus:bg-white focus:border-primary font-medium placeholder:text-gray-400"/>
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="block text-sm font-semibold text-gray-800 mb-2">Loại giảm giá</label>
                        <select id="v_type" class="w-full px-4 py-3 rounded-xl border border-gray-200 bg-gray-50 outline-none focus:bg-white focus:border-primary font-medium appearance-none">
                            <option value="percent">Giảm theo %</option>
                            <option value="fixed">Số tiền cố định</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-sm font-semibold text-gray-800 mb-2">Giá trị</label>
                        <input type="number" id="v_value" placeholder="15"
                        class="w-full px-4 py-3 rounded-xl border border-gray-200 bg-gray-50 outline-none focus:bg-white focus:border-primary font-medium placeholder:text-gray-400"/>
                    </div>
                </div>
                <div>
                    <label class="block text-sm font-semibold text-gray-800 mb-2">Mã Code *</label>
                    <input type="text" id="v_code" placeholder="SUMMER2026" oninput="this.value=this.value.toUpperCase()"
                    class="w-full px-4 py-3 rounded-xl border border-gray-200 bg-gray-50 outline-none focus:bg-white focus:border-primary font-mono placeholder:font-sans placeholder:text-gray-400"/>
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="block text-sm font-semibold text-gray-800 mb-2">Đơn tối thiểu (đ)</label>
                        <input type="number" id="v_minOrder" placeholder="50000"
                        class="w-full px-4 py-3 rounded-xl border border-gray-200 bg-gray-50 outline-none focus:bg-white focus:border-primary font-medium placeholder:text-gray-400"/>
                    </div>
                    <div>
                        <label class="block text-sm font-semibold text-gray-800 mb-2">Giới hạn lượt dùng</label>
                        <input type="number" id="v_maxUses" placeholder="100"
                        class="w-full px-4 py-3 rounded-xl border border-gray-200 bg-gray-50 outline-none focus:bg-white focus:border-primary font-medium placeholder:text-gray-400"/>
                    </div>
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="block text-sm font-semibold text-gray-800 mb-2">Ngày bắt đầu</label>
                        <input type="date" id="v_startDate"
                        class="w-full px-4 py-3 rounded-xl border border-gray-200 bg-gray-50 outline-none focus:bg-white focus:border-primary font-medium"/>
                    </div>
                    <div>
                        <label class="block text-sm font-semibold text-gray-800 mb-2">Ngày kết thúc</label>
                        <input type="date" id="v_endDate"
                        class="w-full px-4 py-3 rounded-xl border border-gray-200 bg-gray-50 outline-none focus:bg-white focus:border-primary font-medium"/>
                    </div>
                </div>
            </div>
            <div class="px-6 py-4 bg-gray-50 border-t border-gray-100 flex justify-end gap-3">
                <button onclick="closeCreate()" class="px-6 py-2.5 rounded-xl border border-gray-200 font-semibold text-sm text-gray-600 hover:bg-white">Hủy</button>
                <button onclick="saveVoucher()" class="px-6 py-2.5 rounded-xl bg-primary text-white font-semibold text-sm hover:bg-orange-600 shadow-lg shadow-primary/20 flex items-center gap-2">Tạo ngay</button>
            </div>
        </div>
    </div>

    <script>
        let vouchers = [
        { id:1, title:'Giảm 20% đơn đầu tiên', type:'percent', value:20, code:'FIRST20', minOrder:50000, used:34, maxUses:100, start:'01/07/2025', end:'31/07/2025', active:true  },
        { id:2, title:'Free ship cuối tuần',    type:'fixed',   value:15000, code:'FREESHIP', minOrder:80000, used:82, maxUses:200, start:'01/07/2025', end:'31/07/2025', active:true  },
        { id:3, title:'Giảm 50k cho đơn 200k',  type:'fixed',   value:50000, code:'MEGA50K',  minOrder:200000,used:10, maxUses:50,  start:'15/06/2025', end:'15/07/2025', active:false },
        ];
        let nextId = 4;
        
        function fmtDiscount(v) { return v.type==='percent'? v.value+'%' : v.value.toLocaleString('vi-VN')+'₫'; }
        
        function renderVouchers() {
            const grid = document.getElementById('voucherGrid');
            const empty = document.getElementById('emptyVouchers');
            if(!vouchers.length) { grid.innerHTML=''; empty.classList.remove('hidden'); empty.classList.add('flex'); return; }
            empty.classList.add('hidden');
            empty.classList.remove('flex');
            grid.innerHTML = vouchers.map(v => {
                const discount = fmtDiscount(v);
                const isActive = v.active;
                const statusCls = isActive ? 'bg-primary' : 'bg-gray-300';
                const statusThumbUrl = isActive ? 'right-1' : 'left-1';
                
                return `
                <div class="bg-white p-6 rounded-2xl border border-gray-200 shadow-sm transition-all relative overflow-hidden group \${!isActive ? 'opacity-60 grayscale' : 'hover:shadow-lg'}">
                <div class="flex justify-between items-start mb-4">
                <div class="flex gap-3 items-center">
                <div class="w-14 h-14 rounded-2xl bg-orange-50 flex items-center justify-center text-primary">
                <span class="material-symbols-outlined text-3xl">\${v.type === 'fixed' ? 'attach_money' : 'percent'}</span>
                </div>
                <div>
                <h3 class="text-lg font-bold">\${v.title}</h3>
                <p class="text-sm text-gray-500 mt-0.5">Mã: <span class="bg-gray-100 px-2 py-0.5 rounded font-mono font-semibold text-gray-800">\${v.code}</span></p>
                </div>
                </div>
                <div class="relative w-11 h-6 rounded-full cursor-pointer transition-colors shrink-0 \${statusCls}" onclick="toggleVoucher(\${v.id}, \${!isActive})">
                <div class="absolute top-1 w-4 h-4 bg-white rounded-full shadow-sm transition-all \${statusThumbUrl}"></div>
                </div>
                </div>
                <div class="grid grid-cols-3 gap-3 mb-4 text-xs">
                <div>
                <p class="uppercase font-semibold text-gray-400 tracking-wider mb-1">Giảm</p>
                <p class="font-bold text-gray-900">\${discount}</p>
                </div>
                <div>
                <p class="uppercase font-semibold text-gray-400 tracking-wider mb-1">Đã dùng</p>
                <p class="font-bold text-gray-900">\${v.used} / \${v.maxUses}</p>
                </div>
                <div>
                <p class="uppercase font-semibold text-gray-400 tracking-wider mb-1">Hết hạn</p>
                <p class="font-bold text-gray-900">\${v.end}</p>
                </div>
                </div>
                <div class="flex gap-2 pt-4 border-t border-gray-100">
                <button class="flex-1 py-2 rounded-lg text-xs font-semibold border transition-colors \${v.isPublished ? 'border-primary text-primary bg-orange-50' : 'border-gray-200 text-gray-600 hover:bg-gray-50'}">
                \${v.isPublished ? '✓ Đã hiện' : 'Hiện với KH'}
                </button>
                <button onclick="deleteVoucher(\${v.id})" class="py-2 px-3 rounded-lg border border-red-100 text-red-500 hover:bg-red-50 text-xs font-semibold transition-colors">
                <span class="material-symbols-outlined text-sm">delete</span>
                </button>
                </div>
                </div>`;
            }).join('');
        }
        
        function toggleVoucher(id, val) {
            vouchers = vouchers.map(v => v.id===id?{...v,active:val}:v);
            renderVouchers();
        }
        
        function deleteVoucher(id) {
            if(!confirm('Bạn có chắc muốn xoá khuyến mãi này?')) return;
            vouchers = vouchers.filter(v => v.id!==id);
            renderVouchers();
        }
        
        function openCreate() { document.getElementById('createModal').style.display='flex'; }
        function closeCreate() { document.getElementById('createModal').style.display='none'; }
        
        function saveVoucher() {
            const title    = document.getElementById('v_title').value.trim();
            const type     = document.getElementById('v_type').value;
            const value    = parseFloat(document.getElementById('v_value').value)||0;
            const code     = document.getElementById('v_code').value.trim().toUpperCase();
            const minOrder = parseFloat(document.getElementById('v_minOrder').value)||0;
            const maxUses  = parseInt(document.getElementById('v_maxUses').value)||100;
            const start    = document.getElementById('v_startDate').value;
            const end      = document.getElementById('v_endDate').value;
            if(!title||!code||!value) { alert('Vui lòng điền đầy đủ thông tin.'); return; }
            vouchers.push({ id: nextId++, title, type, value, code, minOrder, used:0, maxUses,
            start: start||'--', end: end||'--', active:true });
            renderVouchers();
            closeCreate();
            ['v_title','v_value','v_code','v_minOrder','v_maxUses','v_startDate','v_endDate'].forEach(id=>{ document.getElementById(id).value=''; });
        }
        
        renderVouchers();
    </script>
</body>
</html>
