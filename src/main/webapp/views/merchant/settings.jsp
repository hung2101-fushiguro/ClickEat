<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
    <%-- activeTab: restored after POST so JS can re-open the correct tab --%>
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Cài đặt – ClickEat Merchant</title>
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
            
            /* ── Reliable toggle switch (works with injected HTML) ── */
            .tog {
                position:relative;
                display:inline-flex;
                flex-shrink:0;
                width:2.75rem;
                height:1.5rem;
                cursor:pointer;
            }
            .tog input            {
                position:absolute;
                opacity:0;
                width:0;
                height:0;
            }
            .tog-track            {
                position:absolute;
                inset:0;
                border-radius:9999px;
                background:#e5e7eb;
                transition:background .2s ease;
            }
            .tog-thumb            {
                position:absolute;
                top:2px;
                left:2px;
                width:1.25rem;
                height:1.25rem;
                background:white;
                border-radius:50%;
                box-shadow:0 1px 2px rgba(0,0,0,.2);
                border: 1px solid #d1d5db;
                transition:transform .2s ease;
            }
            .tog input:checked ~ .tog-track {
                background:#22c55e;
            } /* green-500 */
            .tog input:checked ~ .tog-thumb {
                transform:translateX(1.25rem);
                border-color: white;
            }
            .tog input:focus-visible ~ .tog-track {
                outline:2px solid #22c55e;
                outline-offset:2px;
            }
        </style>
    </head>
    <body class="bg-gray-50 min-h-screen flex">

        <%@ include file="_nav.jsp" %>

        <div class="flex-1 flex flex-col min-h-screen pb-16 md:pb-0">

            <div class="flex-1 overflow-y-auto">
                <div class="p-4 md:p-8 max-w-4xl mx-auto">

                    <h1 class="text-3xl font-bold text-gray-900 tracking-tight mb-6">Cài đặt</h1>

                    <c:if test="${not empty dbMerchantStatus}">
                        <div class="mb-5 px-4 py-3 rounded-xl border ${dbMerchantStatus == 'APPROVED' ? 'bg-green-50 border-green-200 text-green-700' : (dbMerchantStatus == 'PENDING' ? 'bg-amber-50 border-amber-200 text-amber-700' : 'bg-red-50 border-red-200 text-red-700')} text-sm font-semibold">
                            Trạng thái cửa hàng: ${dbMerchantStatus}
                            <c:if test="${dbMerchantStatus == 'PENDING'}"> - Hồ sơ đang được duyệt, vui lòng liên hệ support nếu cần gấp.</c:if>
                                <c:if test="${dbMerchantStatus == 'REJECTED' and not empty dbRejectionReason}"> - Lý do: ${dbRejectionReason}</c:if>
                                </div>
                            </c:if>

                            <!-- Tabs -->
                            <div class="flex gap-4 md:gap-8 border-b border-gray-200 mb-8 overflow-x-auto no-scrollbar">
                                <button class="tab-btn active pb-4 text-sm font-semibold transition-colors border-b-2 whitespace-nowrap border-primary text-primary" onclick="switchTab('store', this)">Cửa hàng</button>
                                <button class="tab-btn pb-4 text-sm font-semibold transition-colors border-b-2 whitespace-nowrap border-transparent text-gray-500 hover:text-gray-800" onclick="switchTab('hours', this)">Giờ mở cửa</button>
                                <button class="tab-btn pb-4 text-sm font-semibold transition-colors border-b-2 whitespace-nowrap border-transparent text-gray-500 hover:text-gray-800" onclick="switchTab('notify', this)">Thông báo</button>
                                <button class="tab-btn pb-4 text-sm font-semibold transition-colors border-b-2 whitespace-nowrap border-transparent text-gray-500 hover:text-gray-800" onclick="switchTab('security', this)">Bảo mật</button>
                            </div>

                            <!-- Success message -->
                            <c:if test="${not empty successMsg}">
                                <div class="mb-4 px-4 py-3 bg-green-50 border border-green-200 rounded-xl text-sm text-green-700 flex items-center gap-2">
                                    <span class="material-symbols-outlined text-green-600 text-[18px]">check_circle</span>
                                    ${successMsg}
                                </div>
                            </c:if>

                            <div class="bg-white border border-gray-200 rounded-2xl p-6 md:p-8 shadow-sm">
                                <!-- ===== Store Tab ===== -->
                                <div id="tab-store" class="tab-content space-y-6">
                                    <div class="flex flex-col md:flex-row items-center gap-6">
                                        <div class="relative group shrink-0">
                                            <input type="file" id="avatarFile" accept="image/*" class="hidden" onchange="previewAvatar(event)"/>
                                            <button type="button" onclick="document.getElementById('avatarFile').click()" class="w-24 h-24 rounded-full overflow-hidden border-2 border-dashed border-gray-300 hover:border-primary transition-colors relative block" title="Đổi ảnh đại diện">
                                                <span id="avatarPlaceholder" class="w-full h-full flex items-center justify-center bg-gray-100">
                                                    <span class="material-symbols-outlined text-gray-400 text-3xl">storefront</span>
                                                </span>
                                                <img id="avatarPreview" src="" alt="Avatar" class="w-full h-full object-cover hidden absolute inset-0"/>
                                                <span class="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center rounded-full">
                                                    <span class="material-symbols-outlined text-white">photo_camera</span>
                                                </span>
                                            </button>
                                            <canvas id="avatarCanvas" class="hidden"></canvas>
                                        </div>
                                        <div class="text-center md:text-left">
                                            <h3 class="font-semibold text-lg">${not empty dbShopName ? dbShopName : 'Cửa hàng'}</h3>
                                            <p class="text-sm text-gray-500">Shop Email</p>
                                            <p class="text-xs mt-1 font-semibold text-green-600">● Đang hoạt động</p>
                                            <p class="text-[11px] text-gray-400 mt-1">Nhấn vào ảnh để thay đổi (tối đa 5MB)</p>
                                        </div>
                                    </div>

                                    <form method="POST" action="${pageContext.request.contextPath}/merchant/settings" id="storeForm" class="space-y-6">
                                        <input type="hidden" name="tab" value="store"/>
                                        <input type="hidden" name="avatarData" id="avatarDataInput"/>
                                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                                            <div class="md:col-span-2">
                                                <label class="block text-sm font-semibold text-gray-800 mb-2">Tên Cửa hàng</label>
                                                <input type="text" name="shopName" id="shopName" value="${dbShopName}" class="w-full px-4 py-2.5 rounded-lg border border-gray-200 bg-gray-50 focus:bg-white focus:border-primary focus:ring-4 focus:ring-primary/10 outline-none transition-all text-gray-900 font-medium" />
                                            </div>
                                            <div>
                                                <label class="block text-sm font-semibold text-gray-800 mb-2">Số điện thoại</label>
                                                <input type="tel" name="shopPhone" id="shopPhone" value="${dbShopPhone}" class="w-full px-4 py-2.5 rounded-lg border border-gray-200 bg-gray-50 focus:bg-white focus:border-primary focus:ring-4 focus:ring-primary/10 outline-none transition-all text-gray-900 font-medium" />
                                            </div>
                                            <div>
                                                <label class="block text-sm font-semibold text-gray-800 mb-2">Email</label>
                                                <input type="email" disabled value="" class="w-full px-4 py-2.5 rounded-lg border border-gray-200 bg-gray-100 text-gray-500 font-medium outline-none cursor-not-allowed" />
                                            </div>
                                            <div class="md:col-span-2">
                                                <label class="block text-sm font-semibold text-gray-800 mb-2">Địa chỉ</label>
                                                <input type="text" name="shopAddress" id="shopAddress" value="${dbShopAddress}" class="w-full px-4 py-2.5 rounded-lg border border-gray-200 bg-gray-50 focus:bg-white focus:border-primary focus:ring-4 focus:ring-primary/10 outline-none transition-all text-gray-900 font-medium" />
                                            </div>
                                            <div class="md:col-span-2 hidden">
                                                <label class="block text-sm font-semibold text-gray-800 mb-2">Mô tả cửa hàng</label>
                                                <textarea name="shopDesc" id="shopDesc" rows="2" class="w-full px-4 py-2.5 rounded-lg border border-gray-200 bg-gray-50 outline-none transition-all text-gray-900 font-medium resize-none"></textarea>
                                            </div>
                                            <div>
                                                <label class="block text-sm font-semibold text-gray-800 mb-2">Giá trị đơn tối thiểu (đ)</label>
                                                <input type="number" min="0" step="1000" name="minOrderAmount" value="${dbMinOrderAmount}" class="w-full px-4 py-2.5 rounded-lg border border-gray-200 bg-gray-50 focus:bg-white focus:border-primary focus:ring-4 focus:ring-primary/10 outline-none transition-all text-gray-900 font-medium" />
                                            </div>
                                            <div class="flex items-end pb-1">
                                                <label class="tog">
                                                    <input type="checkbox" name="isOpen" ${dbIsOpen == null || dbIsOpen ? 'checked' : ''}/>
                                                    <span class="tog-track"></span>
                                                    <span class="tog-thumb"></span>
                                                </label>
                                                <span class="ml-3 text-sm font-semibold text-gray-700">Bật nhận đơn (is_open)</span>
                                            </div>
                                        </div>

                                        <div class="flex justify-end pt-4">
                                            <button type="submit" class="bg-primary text-white px-6 py-3 rounded-lg font-semibold hover:bg-orange-600 shadow-md min-w-[140px] flex justify-center disabled:opacity-60">
                                                Lưu thay đổi
                                            </button>
                                        </div>
                                    </form>
                                </div>

                                <!-- ===== Hours Tab ===== -->
                                <div id="tab-hours" class="tab-content hidden space-y-3">
                                    <p class="text-sm text-gray-500 mb-4">Cấu hình giờ hoạt động của cửa hàng. Tắt toggle để đánh dấu ngày nghỉ.</p>
                                    <div class="space-y-3" id="hoursRows"></div>

                                    <div class="flex flex-wrap gap-2 pt-2 mb-4">
                                        <span class="text-xs text-gray-400 self-center mr-1">Điền nhanh:</span>
                                        <button type="button" onclick="fillAll('09:00', '22:00')" class="text-xs px-3 py-1 rounded-full border border-gray-200 bg-gray-50 hover:bg-primary/10 hover:border-primary/40 hover:text-primary font-medium transition-colors">09:00 – 22:00</button>
                                        <button type="button" onclick="fillAll('08:00', '21:00')" class="text-xs px-3 py-1 rounded-full border border-gray-200 bg-gray-50 hover:bg-primary/10 hover:border-primary/40 hover:text-primary font-medium transition-colors">08:00 – 21:00</button>
                                        <button type="button" onclick="fillAll('10:00', '23:00')" class="text-xs px-3 py-1 rounded-full border border-gray-200 bg-gray-50 hover:bg-primary/10 hover:border-primary/40 hover:text-primary font-medium transition-colors">10:00 – 23:00</button>
                                    </div>

                                    <div class="flex justify-end pt-2">
                                        <button onclick="saveHours()" class="bg-primary text-white px-6 py-3 rounded-lg font-semibold hover:bg-orange-600 shadow-md min-w-[160px] flex justify-center">
                                            Lưu giờ mở cửa
                                        </button>
                                    </div>
                                </div>

                                <!-- ===== Notifications Tab ===== -->
                                <div id="tab-notify" class="tab-content hidden space-y-6">
                                    <div id="notifyRows"></div>
                                </div>

                                <!-- ===== Security Tab ===== -->
                                <div id="tab-security" class="tab-content hidden space-y-6">
                                    <form method="POST" action="${pageContext.request.contextPath}/merchant/settings" onsubmit="return validatePwForm()">
                                        <input type="hidden" name="tab" value="security"/>

                                        <div class="space-y-6">
                                            <div>
                                                <label class="block text-sm font-semibold text-gray-800 mb-2">Mật khẩu hiện tại</label>
                                                <div class="relative">
                                                    <input type="password" name="currentPw" id="currentPw" required class="w-full px-4 py-2.5 rounded-lg border border-gray-200 bg-gray-50 outline-none focus:border-primary focus:ring-4 focus:ring-primary/10 transition-all" placeholder="••••••••"/>
                                                    <button type="button" onclick="togglePw('currentPw', this)" class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600">
                                                        <span class="material-symbols-outlined text-[20px]">visibility_off</span>
                                                    </button>
                                                </div>
                                            </div>
                                            <div>
                                                <label class="block text-sm font-semibold text-gray-800 mb-2">Mật khẩu mới</label>
                                                <div class="relative">
                                                    <input type="password" name="newPw" id="newPw" required minlength="6" class="w-full px-4 py-2.5 rounded-lg border border-gray-200 bg-gray-50 outline-none focus:border-primary focus:ring-4 focus:ring-primary/10 transition-all" placeholder="••••••••"/>
                                                    <button type="button" onclick="togglePw('newPw', this)" class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600">
                                                        <span class="material-symbols-outlined text-[20px]">visibility_off</span>
                                                    </button>
                                                </div>
                                            </div>
                                            <div>
                                                <label class="block text-sm font-semibold text-gray-800 mb-2">Xác nhận mật khẩu mới</label>
                                                <div class="relative">
                                                    <input type="password" id="confirmPw" required class="w-full px-4 py-2.5 rounded-lg border border-gray-200 bg-gray-50 outline-none focus:border-primary focus:ring-4 focus:ring-primary/10 transition-all" placeholder="••••••••"/>
                                                    <button type="button" onclick="togglePw('confirmPw', this)" class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600">
                                                        <span class="material-symbols-outlined text-[20px]">visibility_off</span>
                                                    </button>
                                                </div>
                                            </div>

                                            <div id="pwError" class="hidden px-4 py-3 bg-red-50 border border-red-200 rounded-xl text-sm text-red-600 font-medium"></div>

                                            <c:if test="${not empty sessionScope.errorMsg}">
                                                <div class="px-4 py-3 bg-red-50 border border-red-200 rounded-xl text-sm text-red-600 font-medium">
                                                    ${sessionScope.errorMsg}
                                                </div>
                                                <c:remove var="errorMsg" scope="session"/>
                                            </c:if>

                                            <div class="flex justify-end pt-4">
                                                <button type="submit" class="bg-gray-900 text-white px-6 py-3 rounded-lg font-bold hover:bg-black shadow-md transition-colors">Cập nhật mật khẩu</button>
                                            </div>
                                        </div>
                                    </form>
                                </div>

                            </div>
                        </div>
                    </div>
                </div>

                <%-- Must be BEFORE main script so getElementById('dbInitHours') resolves --%>
                <script type="application/json" id="dbInitHours"><c:out value="${dbBusinessHours}" default="" escapeXml="false"/></script>
                <%-- Hidden form for business hours POST --%>
                <form method="POST" id="hoursForm" action="${pageContext.request.contextPath}/merchant/settings">
                    <input type="hidden" name="tab" value="hours"/>
                    <input type="hidden" name="businessHours" id="businessHoursInput"/>
                </form>

                <script>
                    // ---- Tabs ----
                    function switchTab(name, btn) {
                        document.querySelectorAll('.tab-content').forEach(el => el.classList.add('hidden'));
                        document.getElementById('tab-' + name).classList.remove('hidden');
                        document.querySelectorAll('.tab-btn').forEach(b => {
                            b.classList.remove('active');
                            b.classList.remove('border-primary');
                            b.classList.remove('text-primary');
                            b.classList.add('border-transparent');
                            b.classList.add('text-gray-500');
                        });
                        btn.classList.add('active');
                        btn.classList.remove('text-gray-500');
                        btn.classList.remove('border-transparent');
                        btn.classList.add('text-primary');
                        btn.classList.add('border-primary');
                    }
                    
                    // ---- Avatar ----
                    (function () {
                        var saved = '${dbShopAvatar}';
                        if (saved && saved.length > 10) {
                            document.getElementById('avatarPreview').src = saved;
                            document.getElementById('avatarPreview').classList.remove('hidden');
                            document.getElementById('avatarPlaceholder').classList.add('hidden');
                        }
                    })();
                    
                    function previewAvatar(e) {
                        const file = e.target.files[0];
                        if (!file)
                        return;
                        const reader = new FileReader();
                        reader.onload = function (ev) {
                            const img = new Image();
                            img.onload = function () {
                                const canvas = document.getElementById('avatarCanvas');
                                canvas.width = 256;
                                canvas.height = 256;
                                const ctx = canvas.getContext('2d');
                                // crop center square
                                const size = Math.min(img.width, img.height);
                                const sx = (img.width - size) / 2;
                                const sy = (img.height - size) / 2;
                                ctx.drawImage(img, sx, sy, size, size, 0, 0, 256, 256);
                                const dataUrl = canvas.toDataURL('image/jpeg', 0.8);
                                document.getElementById('avatarPreview').src = dataUrl;
                                document.getElementById('avatarPreview').classList.remove('hidden');
                                document.getElementById('avatarPlaceholder').classList.add('hidden');
                                document.getElementById('avatarDataInput').value = dataUrl;
                            };
                            img.src = ev.target.result;
                        };
                        reader.readAsDataURL(file);
                    }
                    
                    function saveStore() {
                        showToast('Đã lưu thông tin cửa hàng!');
                    }
                    
                    // ---- Hours ----
                    const days = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'];
                    const hoursData = days.map(d => ({day: d, open: true, from: '09:00', to: '22:00'}));
                    // Load saved hours from DB
                    try {
                        const dbHoursEl = document.getElementById('dbInitHours');
                        if (dbHoursEl && dbHoursEl.textContent.trim()) {
                            const parsed = JSON.parse(dbHoursEl.textContent);
                            if (Array.isArray(parsed) && parsed.length >= 7) {
                                parsed.forEach((item, i) => {
                                    if (i < hoursData.length) {
                                        hoursData[i].open = item.open !== false;
                                        hoursData[i].from = item.from || '09:00';
                                        hoursData[i].to = item.to || '22:00';
                                    }
                                });
                            }
                        }
                        } catch (err) {
                        }
                        
                        function renderHours() {
                            const container = document.getElementById('hoursRows');
                            container.innerHTML = hoursData.map((item, i) => {
                                const checked = item.open ? 'checked' : '';
                                const bgClass = item.open ? 'bg-white border-gray-200' : 'bg-gray-50 border-gray-100';
                                const txtClass = item.open ? 'text-gray-900' : 'text-gray-400 line-through';
                                const timeInputsOpacity = item.open ? '' : 'opacity-40 pointer-events-none';
                                
                                return `
                                <div class="flex flex-col sm:flex-row items-center justify-between p-4 border rounded-xl gap-3 transition-colors \${bgClass}">
                                <div class="flex items-center gap-3 w-full sm:w-auto">
                                <label class="tog mt-1">
                                <input type="checkbox" \${checked} onchange="hoursData[\${i}].open=this.checked;renderHours()"/>
                                <span class="tog-track"></span>
                                <span class="tog-thumb"></span>
                                </label>
                                <span class="font-semibold w-24 \${txtClass}">\${item.day}</span>
                                \${!item.open ? '<span class="text-xs font-medium text-red-400 bg-red-50 px-2 py-0.5 rounded-full">Nghỉ</span>' : ''}
                                </div>
                                
                                <div class="flex items-center gap-2 w-full sm:w-auto justify-end transition-opacity \${timeInputsOpacity}">
                                <div class="flex flex-col items-center">
                                <span class="text-[10px] text-gray-400 mb-0.5">Mở cửa</span>
                                <input type="time" value="\${item.from}" onchange="hoursData[\${i}].from=this.value" class="bg-white border border-gray-200 rounded-lg px-3 py-1.5 text-sm font-medium outline-none focus:border-primary focus:ring-2 focus:ring-primary/20 transition-all"/>
                                </div>
                                <span class="text-gray-400 mt-4 font-bold">→</span>
                                <div class="flex flex-col items-center">
                                <span class="text-[10px] text-gray-400 mb-0.5">Đóng cửa</span>
                                <input type="time" value="\${item.to}" onchange="hoursData[\${i}].to=this.value" class="bg-white border border-gray-200 rounded-lg px-3 py-1.5 text-sm font-medium outline-none focus:border-primary focus:ring-2 focus:ring-primary/20 transition-all"/>
                                </div>
                                </div>
                                </div>`;
                            }).join('');
                        }
                        renderHours();
                        
                        function fillAll(from, to) {
                            hoursData.forEach(d => {
                                d.open = true;
                                d.from = from;
                                d.to = to;
                            });
                            renderHours();
                        }
                        function saveHours() {
                            document.getElementById('businessHoursInput').value = JSON.stringify(hoursData);
                            document.getElementById('hoursForm').submit();
                        }
                        
                        // ---- Notifications ----
                        const notifItems = [
                        {key: 'new_order', label: 'Đơn hàng mới', desc: 'Nhận thông báo khi có đơn hàng mới.', checked: true},
                        {key: 'order_cancel', label: 'Đơn hàng bị huỷ', desc: 'Nhận thông báo khi khách huỷ đơn.', checked: true},
                        {key: 'new_review', label: 'Đánh giá mới', desc: 'Nhận thông báo khi có đánh giá mới.', checked: false},
                        {key: 'payment', label: 'Thanh toán thành công', desc: 'Nhận thông báo khi có tiền vào ví.', checked: true},
                        ];
                        const notifyContainer = document.getElementById('notifyRows');
                        notifItems.forEach((item, i) => {
                            const checked = item.checked ? 'checked' : '';
                            notifyContainer.innerHTML += `
                            <div class="flex items-center justify-between py-4 border-b border-gray-100 last:border-0">
                            <div>
                            <p class="font-semibold text-gray-900">\${item.label}</p>
                            <p class="text-sm text-gray-500">\${item.desc}</p>
                            </div>
                            <label class="tog">
                            <input type="checkbox" \${checked} id="notif-\${item.key}"/>
                            <span class="tog-track"></span>
                            <span class="tog-thumb"></span>
                            </label>
                            </div>`;
                        });
                        
                        // ---- Security ----
                        function togglePw(id, btn) {
                            const input = document.getElementById(id);
                            const isHidden = input.type === 'password';
                            input.type = isHidden ? 'text' : 'password';
                            btn.querySelector('.material-symbols-outlined').textContent = isHidden ? 'visibility' : 'visibility_off';
                        }
                        function changePw() {
                            const cur = document.getElementById('currentPw').value;
                            const nw = document.getElementById('newPw').value;
                            const conf = document.getElementById('confirmPw').value;
                            const err = document.getElementById('pwError');
                            if (!cur || !nw || !conf) {
                                err.textContent = 'Vui lòng điền đầy đủ mật khẩu.';
                                err.classList.remove('hidden');
                                return;
                            }
                            if (nw !== conf) {
                                err.textContent = 'Mật khẩu mới không khớp.';
                                err.classList.remove('hidden');
                                return;
                            }
                            if (nw.length < 6) {
                                err.textContent = 'Mật khẩu mới phải có ít nhất 6 ký tự.';
                                err.classList.remove('hidden');
                                return;
                            }
                            err.classList.add('hidden');
                            showToast('Đã đổi mật khẩu thành công!');
                            ['currentPw', 'newPw', 'confirmPw'].forEach(id => {
                                document.getElementById(id).value = '';
                            });
                        }
                        
                        // ---- Toast ----
                        function showToast(msg) {
                            let t = document.getElementById('toast');
                            if (!t) {
                                t = document.createElement('div');
                                t.id = 'toast';
                                t.className = 'fixed bottom-20 md:bottom-6 left-1/2 -translate-x-1/2 bg-gray-900 text-white text-sm font-medium px-5 py-3 rounded-xl shadow-lg z-[100] transition-all duration-300 opacity-0';
                                document.body.appendChild(t);
                            }
                            t.textContent = msg;
                            t.classList.remove('opacity-0');
                            t.classList.add('opacity-100');
                            setTimeout(() => {
                                t.classList.remove('opacity-100');
                                t.classList.add('opacity-0');
                            }, 2500);
                        }
                        // Restore active tab after POST
                        (function () {
                            const active = '${activeTab}';
                            if (active && active !== 'store') {
                                const btn = document.querySelector('[onclick*="switchTab(\'' + active + '\'"]');
                                if (btn)
                                switchTab(active, btn);
                            }
                        })();
                    </script>
                    <script>
                        // Kiểm tra mật khẩu khớp nhau trước khi cho phép gửi form
                        function validatePwForm() {
                            const nw = document.getElementById('newPw').value;
                            const conf = document.getElementById('confirmPw').value;
                            const err = document.getElementById('pwError');
                            
                            if (nw !== conf) {
                                err.textContent = 'Mật khẩu xác nhận không khớp!';
                                err.classList.remove('hidden');
                                return false;
                            }
                            err.classList.add('hidden');
                            return true;
                        }
                    </script>
                </body>
            </html>
