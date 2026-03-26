<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<% request.setAttribute("currentPage", "catalog");%>
<!DOCTYPE html>
<html lang="vi" class="h-full">
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Thực đơn – ClickEat Merchant</title>
        <script src="https://cdn.tailwindcss.com"></script>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet"/>
        <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
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
        <style>
            body {
                font-family: 'Inter', sans-serif;
            }
            .material-symbols-outlined {
                font-variation-settings: 'FILL' 1, 'wght' 400, 'GRAD' 0, 'opsz' 24;
            }
            .toggle-cb:checked + .toggle-track {
                background-color: #22c55e;
            }
            .toggle-cb:checked + .toggle-track + .toggle-dot {
                transform: translateX(1.25rem);
                border-color: #fff;
            }
        </style>
    </head>
    <body class="h-full bg-[#f8f7f5] text-gray-800 flex overflow-hidden">

        <jsp:include page="_nav.jsp" />

        <main class="flex-1 flex flex-col h-screen overflow-y-auto">
            <header class="bg-white border-b border-gray-100 px-4 md:px-8 py-5 sticky top-0 z-10 flex justify-between items-center shadow-sm">
                <div>
                    <h1 class="text-2xl font-black text-gray-900 tracking-tight">Thực đơn</h1>
                    <p class="text-sm text-gray-500 font-medium mt-1">Quản lý món ăn và danh mục của nhà hàng</p>
                </div>
                <button onclick="document.getElementById('addModal').classList.remove('hidden')" class="bg-primary hover:bg-primary-dark text-white px-5 py-2.5 rounded-xl font-bold transition-all shadow-md hover:shadow-lg flex items-center gap-2">
                    <span class="material-symbols-outlined text-[20px]">add</span>Thêm món mới
                </button>
            </header>

            <div class="p-8 max-w-7xl mx-auto w-full">

                <c:if test="${not empty successMsg}">
                    <div class="mb-4 px-4 py-3 bg-green-50 border border-green-200 rounded-xl text-sm text-green-700 font-semibold">${successMsg}</div>
                </c:if>
                <c:if test="${not empty errorMsg}">
                    <div class="mb-4 px-4 py-3 bg-red-50 border border-red-200 rounded-xl text-sm text-red-700 font-semibold">${errorMsg}</div>
                </c:if>

                <form id="bulkForm" method="POST" action="${pageContext.request.contextPath}/merchant/catalog" class="mb-4 flex flex-wrap items-center gap-2">
                    <input type="hidden" name="action" value="bulk-toggle"/>
                    <input type="hidden" name="isAvailable" id="bulkIsAvailable" value="true"/>
                    <input type="hidden" name="reason" id="bulkReason" value=""/>
                    <button type="button" onclick="submitBulkToggle(true)" class="px-4 py-2 rounded-lg border border-green-200 bg-green-50 text-green-700 text-sm font-bold hover:bg-green-100 transition-colors">Hiện món đã chọn</button>
                    <button type="button" onclick="submitBulkToggle(false)" class="px-4 py-2 rounded-lg border border-red-200 bg-red-50 text-red-700 text-sm font-bold hover:bg-red-100 transition-colors">Ẩn món đã chọn</button>
                    <span class="text-xs text-gray-500 font-medium">Tick nhiều món để thao tác nhanh.</span>
                </form>

                <div class="mb-6 flex gap-2 overflow-x-auto pb-2 scrollbar-hide">
                    <button class="px-5 py-2.5 bg-gray-900 text-white text-sm font-bold rounded-xl whitespace-nowrap shadow-sm">Tất cả món</button>

                    <c:forEach var="cat" items="${categories}">
                        <button class="px-5 py-2.5 bg-white text-gray-600 hover:bg-gray-50 text-sm font-bold rounded-xl border border-gray-200 whitespace-nowrap transition-colors">${cat.name}</button>
                    </c:forEach>

                    <button type="button" onclick="document.getElementById('addCategoryModal').classList.remove('hidden')" class="px-4 py-2.5 bg-primary/10 text-primary hover:bg-primary/20 text-sm font-bold rounded-xl border border-primary/20 whitespace-nowrap transition-colors flex items-center gap-1.5">
                        <span class="material-symbols-outlined text-[18px]">add</span>
                        Thêm danh mục
                    </button>
                </div>

                <div class="bg-white rounded-3xl shadow-[0_8px_30px_rgb(0,0,0,0.04)] border border-gray-50 overflow-hidden">
                    <table class="w-full text-left border-collapse">
                        <thead>
                            <tr class="bg-gray-50/50 border-b border-gray-100">
                                <th class="py-4 px-6 text-xs font-bold text-gray-400 uppercase tracking-wider w-10 text-center">
                                    <input type="checkbox" id="checkAll" onclick="toggleAllRows(this)" class="w-4 h-4 rounded border-gray-300"/>
                                </th>
                                <th class="py-4 px-6 text-xs font-bold text-gray-400 uppercase tracking-wider w-16 text-center">STT</th>
                                <th class="py-4 px-6 text-xs font-bold text-gray-400 uppercase tracking-wider">Món ăn</th>
                                <th class="py-4 px-6 text-xs font-bold text-gray-400 uppercase tracking-wider">Giá bán</th>
                                <th class="py-4 px-6 text-xs font-bold text-gray-400 uppercase tracking-wider">Trạng thái</th>
                                <th class="py-4 px-6 text-xs font-bold text-gray-400 uppercase tracking-wider text-right">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody class="divide-y divide-gray-50">
                            <c:forEach var="f" items="${foodItems}" varStatus="loop">
                                <tr class="hover:bg-gray-50/50 transition-colors group">
                                    <td class="py-4 px-6 text-center">
                                        <input type="checkbox" class="row-check w-4 h-4 rounded border-gray-300" value="${f.id}"/>
                                    </td>
                                    <td class="py-4 px-6 text-sm font-semibold text-gray-400 text-center">${loop.index + 1}</td>
                                    <td class="py-4 px-6">
                                        <div class="flex items-center gap-4">
                                            <img src="${not empty f.imageUrl ? f.imageUrl : 'https://placehold.co/100x100?text=Food'}" class="w-14 h-14 rounded-xl object-cover border border-gray-100 shadow-sm" alt="${f.name}">
                                            <div>
                                                <p class="font-bold text-gray-900">${f.name}</p>
                                                <p class="text-xs text-gray-500 mt-0.5 max-w-[200px] truncate">${f.description}</p>
                                                <c:if test="${not empty f.sizeOptions}">
                                                    <p class="text-[11px] text-blue-600 font-semibold mt-1">Size: ${f.sizeOptions}</p>
                                                </c:if>
                                                <c:if test="${not empty f.toppingOptions}">
                                                    <p class="text-[11px] text-amber-600 font-semibold mt-1">Topping: ${f.toppingOptions}</p>
                                                </c:if>
                                                <c:if test="${not f.available and not empty f.outOfStockReason}">
                                                    <p class="text-[11px] text-red-500 font-semibold mt-1">Lý do tạm ngưng: ${f.outOfStockReason}</p>
                                                </c:if>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="py-4 px-6 font-bold text-gray-900">
                                        <fmt:formatNumber value="${f.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                    </td>
                                    <td class="py-4 px-6">
                                        <label class="flex items-center cursor-pointer">
                                            <div class="relative">
                                                <input type="checkbox" class="sr-only toggle-cb" onchange="toggleItem(${f.id}, this)" ${f.available ? 'checked' : ''}>
                                                <div class="toggle-track w-11 h-6 bg-gray-200 rounded-full transition-colors duration-300"></div>
                                                <div class="toggle-dot absolute left-1 top-1 bg-white w-4 h-4 rounded-full transition-transform duration-300 border border-gray-300 shadow-sm"></div>
                                            </div>
                                            <div class="ml-3">
                                                <div id="dot-${f.id}" class="w-2 h-2 rounded-full mb-1 ${f.available ? 'bg-green-500' : 'bg-gray-300'}"></div>
                                                <span id="text-${f.id}" class="text-[10px] font-bold uppercase tracking-wider ${f.available ? 'text-green-600' : 'text-gray-400'}">
                                                    ${f.available ? 'Đang bán' : 'Tạm ngưng'}
                                                </span>
                                            </div>
                                        </label>
                                    </td>
                                    <td class="py-4 px-6 text-right">
                                        <button onclick="openEditModal(this)"
                                        data-id="${f.id}" data-name="${f.name}" data-price="${f.price}" data-desc="${f.description}" data-cat="${f.categoryId}" data-img="${f.imageUrl}" data-size-options="${fn:escapeXml(f.sizeOptions)}" data-topping-options="${fn:escapeXml(f.toppingOptions)}"
                                        class="w-10 h-10 rounded-xl bg-gray-50 text-gray-500 hover:bg-orange-50 hover:text-primary transition-colors flex items-center justify-center inline-flex">
                                        <span class="material-symbols-outlined text-[20px]">edit</span>
                                    </button>
                                </td>
                            </tr>
                        </c:forEach>

                        <c:if test="${empty foodItems}">
                            <tr>
                                <td colspan="6" class="py-12 text-center text-gray-400 font-medium">Bạn chưa có món ăn nào trong thực đơn.</td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </main>

    <div id="addModal" class="fixed inset-0 bg-gray-900/60 z-50 hidden flex items-center justify-center backdrop-blur-sm">
        <div class="bg-white rounded-[2rem] p-8 w-full max-w-lg shadow-2xl relative">
            <button onclick="document.getElementById('addModal').classList.add('hidden')" class="absolute top-6 right-6 w-8 h-8 flex items-center justify-center rounded-full bg-gray-100 text-gray-500 hover:bg-gray-200 transition-colors">
                <span class="material-symbols-outlined text-[20px]">close</span>
            </button>
            <h2 class="text-2xl font-black text-gray-900 mb-6 tracking-tight">Thêm món mới</h2>
            <form action="${pageContext.request.contextPath}/merchant/catalog" method="POST" class="space-y-5">
                <input type="hidden" name="action" value="add">
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-1">Tên món ăn <span class="text-red-500">*</span></label>
                    <input type="text" name="name" required class="w-full border border-gray-200 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-colors font-medium">
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-1">Giá bán (VNĐ) <span class="text-red-500">*</span></label>
                        <input type="number" name="price" required class="w-full border border-gray-200 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-colors font-medium">
                    </div>
                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-1">Danh mục <span class="text-red-500">*</span></label>
                        <select name="categoryId" required class="w-full border border-gray-200 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-colors font-medium appearance-none">
                            <c:forEach var="cat" items="${categories}">
                                <option value="${cat.id}">${cat.name}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-1">Mô tả ngắn</label>
                    <textarea name="description" rows="2" class="w-full border border-gray-200 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-colors font-medium"></textarea>
                </div>
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-1">Link Ảnh minh họa (Tạm thời)</label>
                    <input type="text" name="imageUrl" class="w-full border border-gray-200 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-colors font-medium">
                </div>
                <div class="grid grid-cols-1 gap-4">
                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-1">Cấu hình Size (tuỳ chọn)</label>
                        <input type="text" name="sizeOptions" placeholder="VD: S:0;M:5000;L:10000" class="w-full border border-gray-200 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-colors font-medium">
                        <p class="mt-1 text-xs text-gray-400">Định dạng TênSize:PhụThu, ngăn cách bằng dấu ;</p>
                    </div>
                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-1">Cấu hình Topping (tuỳ chọn)</label>
                        <input type="text" name="toppingOptions" placeholder="VD: Trân châu:5000;Phô mai:7000" class="w-full border border-gray-200 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-colors font-medium">
                        <p class="mt-1 text-xs text-gray-400">Mỗi topping sẽ cộng thêm vào giá món.</p>
                    </div>
                </div>
                <div class="pt-2">
                    <button type="submit" class="w-full bg-primary hover:bg-primary-dark text-white font-bold py-3.5 rounded-xl transition-all shadow-md">Thêm món ăn</button>
                </div>
            </form>
        </div>
    </div>

    <div id="editModal" class="fixed inset-0 bg-gray-900/60 z-50 hidden flex items-center justify-center backdrop-blur-sm">
        <div class="bg-white rounded-[2rem] p-8 w-full max-w-lg shadow-2xl relative">
            <button onclick="document.getElementById('editModal').classList.add('hidden')" class="absolute top-6 right-6 w-8 h-8 flex items-center justify-center rounded-full bg-gray-100 text-gray-500 hover:bg-gray-200 transition-colors">
                <span class="material-symbols-outlined text-[20px]">close</span>
            </button>
            <h2 class="text-2xl font-black text-gray-900 mb-6 tracking-tight">Sửa thông tin món</h2>
            <form action="${pageContext.request.contextPath}/merchant/catalog" method="POST" class="space-y-5">
                <input type="hidden" name="action" value="edit">
                <input type="hidden" name="id" id="editId">
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-1">Tên món ăn <span class="text-red-500">*</span></label>
                    <input type="text" name="name" id="editName" required class="w-full border border-gray-200 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-colors font-medium">
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-1">Giá bán (VNĐ) <span class="text-red-500">*</span></label>
                        <input type="number" name="price" id="editPrice" required class="w-full border border-gray-200 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-colors font-medium">
                    </div>
                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-1">Danh mục <span class="text-red-500">*</span></label>
                        <select name="categoryId" id="editCategoryId" required class="w-full border border-gray-200 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-colors font-medium appearance-none">
                            <c:forEach var="cat" items="${categories}">
                                <option value="${cat.id}">${cat.name}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-1">Mô tả ngắn</label>
                    <textarea name="description" id="editDescription" rows="2" class="w-full border border-gray-200 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-colors font-medium"></textarea>
                </div>
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-1">Link Ảnh minh họa (Tạm thời)</label>
                    <input type="text" name="imageUrl" id="editImageUrl" class="w-full border border-gray-200 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-colors font-medium">
                </div>
                <div class="grid grid-cols-1 gap-4">
                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-1">Cấu hình Size (tuỳ chọn)</label>
                        <input type="text" name="sizeOptions" id="editSizeOptions" placeholder="VD: S:0;M:5000;L:10000" class="w-full border border-gray-200 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-colors font-medium">
                    </div>
                    <div>
                        <label class="block text-sm font-bold text-gray-700 mb-1">Cấu hình Topping (tuỳ chọn)</label>
                        <input type="text" name="toppingOptions" id="editToppingOptions" placeholder="VD: Trân châu:5000;Phô mai:7000" class="w-full border border-gray-200 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-colors font-medium">
                    </div>
                </div>
                <div class="pt-2">
                    <button type="submit" class="w-full bg-gray-900 hover:bg-black text-white font-bold py-3.5 rounded-xl transition-all shadow-md">Lưu thay đổi</button>
                </div>
            </form>
        </div>
    </div>

    <div id="addCategoryModal" class="fixed inset-0 bg-gray-900/60 z-50 hidden flex items-center justify-center backdrop-blur-sm">
        <div class="bg-white rounded-[2rem] p-8 w-full max-w-md shadow-2xl relative">
            <button type="button" onclick="document.getElementById('addCategoryModal').classList.add('hidden')" class="absolute top-6 right-6 w-8 h-8 flex items-center justify-center rounded-full bg-gray-100 text-gray-500 hover:bg-gray-200 transition-colors">
                <span class="material-symbols-outlined text-[20px]">close</span>
            </button>
            <h2 class="text-2xl font-black text-gray-900 mb-6 tracking-tight">Thêm danh mục mới</h2>
            <form action="${pageContext.request.contextPath}/merchant/catalog" method="POST" class="space-y-5">
                <input type="hidden" name="action" value="add-category"/>
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-1">Tên danh mục <span class="text-red-500">*</span></label>
                    <input type="text" name="categoryName" required class="w-full border border-gray-200 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-colors font-medium" placeholder="VD: Món chính"/>
                </div>
                <div class="pt-2">
                    <button type="submit" class="w-full bg-gray-900 hover:bg-black text-white font-bold py-3.5 rounded-xl transition-all shadow-md">Lưu danh mục</button>
                </div>
            </form>
        </div>
    </div>

    <div id="addCategoryModal" class="fixed inset-0 bg-gray-900/60 z-50 hidden flex items-center justify-center backdrop-blur-sm">
        <div class="bg-white rounded-[2rem] p-8 w-full max-w-md shadow-2xl relative">
            <button type="button" onclick="document.getElementById('addCategoryModal').classList.add('hidden')" class="absolute top-6 right-6 w-8 h-8 flex items-center justify-center rounded-full bg-gray-100 text-gray-500 hover:bg-gray-200 transition-colors">
                <span class="material-symbols-outlined text-[20px]">close</span>
            </button>
            <h2 class="text-2xl font-black text-gray-900 mb-6 tracking-tight">Thêm danh mục mới</h2>
            <form action="${pageContext.request.contextPath}/merchant/catalog" method="POST" class="space-y-5">
                <input type="hidden" name="action" value="add-category"/>
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-1">Tên danh mục <span class="text-red-500">*</span></label>
                    <input type="text" name="categoryName" required class="w-full border border-gray-200 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-colors font-medium" placeholder="VD: Món chính"/>
                </div>
                <div class="pt-2">
                    <button type="submit" class="w-full bg-gray-900 hover:bg-black text-white font-bold py-3.5 rounded-xl transition-all shadow-md">Lưu danh mục</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        // Mở modal Edit và điền sẵn thông tin cũ
        function openEditModal(btn) {
            document.getElementById('editId').value = btn.dataset.id;
            document.getElementById('editName').value = btn.dataset.name;
            document.getElementById('editPrice').value = btn.dataset.price;
            document.getElementById('editDescription').value = btn.dataset.desc;
            document.getElementById('editCategoryId').value = btn.dataset.cat;
            document.getElementById('editImageUrl').value = btn.dataset.img;
            document.getElementById('editSizeOptions').value = btn.dataset.sizeOptions || '';
            document.getElementById('editToppingOptions').value = btn.dataset.toppingOptions || '';
            document.getElementById('editModal').classList.remove('hidden');
        }
        
        // Gọi AJAX để Bật/Tắt trạng thái "Đang bán" cực mượt mà
        function toggleItem(itemId, checkbox) {
            const previousState = !checkbox.checked;
            const isAvailable = checkbox.checked;
            let reason = '';
            if (!isAvailable) {
                const prompted = prompt('Nhập lý do hết món hôm nay (không bắt buộc):', 'Hết món hôm nay');
                if (prompted === null) {
                    checkbox.checked = previousState;
                    return;
                }
                reason = prompted;
            }
            updateToggleVisual(itemId, isAvailable);
            
            // Gửi dữ liệu ngầm lên Servlet
            fetch('${pageContext.request.contextPath}/merchant/catalog', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: 'action=toggle&itemId=' + itemId + '&isAvailable=' + isAvailable + '&reason=' + encodeURIComponent(reason)
                }).then(response => {
                    if (!response.ok) {
                        throw new Error('HTTP ' + response.status);
                    }
                    }).catch(error => {
                        checkbox.checked = previousState;
                        updateToggleVisual(itemId, previousState);
                        console.error("Lỗi cập nhật trạng thái", error);
                    });
                }
                
                function updateToggleVisual(itemId, isAvailable) {
                    const dot = document.getElementById('dot-' + itemId);
                    const text = document.getElementById('text-' + itemId);
                    if (isAvailable) {
                        dot.className = 'w-2 h-2 rounded-full mb-1 bg-green-500';
                        text.className = 'text-[10px] font-bold uppercase tracking-wider text-green-600';
                        text.innerText = 'Đang bán';
                        } else {
                            dot.className = 'w-2 h-2 rounded-full mb-1 bg-gray-300';
                            text.className = 'text-[10px] font-bold uppercase tracking-wider text-gray-400';
                            text.innerText = 'Tạm ngưng';
                        }
                    }
                    
                    function toggleAllRows(master) {
                        document.querySelectorAll('.row-check').forEach(cb => cb.checked = master.checked);
                    }
                    
                    function submitBulkToggle(isAvailable) {
                        const selected = Array.from(document.querySelectorAll('.row-check:checked'));
                        if (!selected.length) {
                            alert('Vui lòng chọn ít nhất 1 món.');
                            return;
                        }
                        
                        let reason = '';
                        if (!isAvailable) {
                            reason = prompt('Nhập lý do hết món cho các món đã chọn (không bắt buộc):', 'Hết món hôm nay') || '';
                        }
                        
                        const form = document.getElementById('bulkForm');
                        document.getElementById('bulkIsAvailable').value = isAvailable;
                        document.getElementById('bulkReason').value = reason;
                        
                        form.querySelectorAll('input[name="itemIds"]').forEach(el => el.remove());
                        selected.forEach(cb => {
                            const input = document.createElement('input');
                            input.type = 'hidden';
                            input.name = 'itemIds';
                            input.value = cb.value;
                            form.appendChild(input);
                        });
                        form.submit();
                    }
                </script>
            </body>
        </html>