<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<% request.setAttribute("currentPage", "catalog"); %>
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
</head>
<body class="h-full bg-[#f8f7f5] font-sans">
<div class="flex h-full">
    <%@ include file="_nav.jsp" %>

    <main class="flex-1 overflow-y-auto pb-20 md:pb-0">
        <!-- Header -->
        <div class="sticky top-0 bg-white/90 backdrop-blur-sm border-b border-gray-100 px-6 py-4 z-10 flex items-center justify-between">
            <h1 class="font-bold text-gray-900 text-lg">Thực đơn</h1>
            <button onclick="document.getElementById('addModal').classList.remove('hidden')"
                    class="flex items-center gap-1.5 px-4 py-2 bg-primary text-white text-sm font-semibold rounded-xl hover:bg-primary-dark transition-all">
                <span class="material-symbols-outlined text-base">add</span>
                Thêm món
            </button>
        </div>

        <div class="p-4 md:p-6 max-w-7xl mx-auto space-y-5">

            <!-- Category tabs -->
            <div class="flex gap-2 overflow-x-auto pb-4 mb-4 mt-2" style="scrollbar-width: none;">
                <a href="${pageContext.request.contextPath}/merchant/catalog"
                   class="px-5 py-2.5 rounded-xl text-sm font-semibold whitespace-nowrap transition-all border 
                   ${empty param.categoryId ? 'bg-primary text-white shadow-md border-transparent' : 'bg-white text-gray-500 hover:bg-gray-100 border-gray-200'}">
                    Tất cả
                </a>
                <c:forEach var="cat" items="${categories}">
                    <a href="?categoryId=${cat.id}"
                       class="px-5 py-2.5 rounded-xl text-sm font-semibold whitespace-nowrap transition-all border 
                       ${param.categoryId == cat.id ? 'bg-primary text-white shadow-md border-transparent' : 'bg-white text-gray-500 hover:bg-gray-100 border-gray-200'}">
                        ${cat.name}
                    </a>
                </c:forEach>
            </div>

            <!-- Stats bar & Quick Search -->
            <div class="flex flex-col sm:flex-row justify-between items-center bg-white p-4 rounded-2xl border border-gray-200 gap-4">
                <div class="flex items-center gap-6 text-sm text-gray-600">
                    <span class="flex items-center gap-2"><span class="w-2 h-2 rounded-full bg-blue-500"></span><strong class="text-gray-900">${totalItems}</strong> món</span>
                    <span class="flex items-center gap-2"><span class="w-2 h-2 rounded-full bg-green-500"></span><strong class="text-green-600">${availableItems}</strong> đang bán</span>
                    <span class="flex items-center gap-2"><span class="w-2 h-2 rounded-full bg-gray-400"></span><strong class="text-gray-400">${unavailableItems}</strong> tạm ẩn</span>
                </div>
                <div class="relative w-full sm:w-64">
                    <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-[18px]">search</span>
                    <input type="text" id="searchInput" placeholder="Tìm tên món..." onkeyup="filterItems()"
                           class="w-full h-10 pl-9 pr-4 rounded-xl border border-gray-200 bg-gray-50 text-sm outline-none focus:bg-white focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all"/>
                </div>
            </div>

            <!-- Food items grid -->
            <c:if test="${empty foodItems}">
                <div class="bg-white rounded-2xl border border-gray-200 p-16 text-center">
                    <span class="material-symbols-outlined text-5xl text-gray-200">menu_book</span>
                    <p class="text-gray-400 mt-3 font-medium">Chưa có món ăn nào</p>
                    <button onclick="document.getElementById('addModal').classList.remove('hidden')"
                            class="mt-4 px-5 py-2.5 bg-primary text-white text-sm font-semibold rounded-xl hover:bg-primary-dark transition-all">
                        Thêm món đầu tiên
                    </button>
                </div>
            </c:if>

            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4" id="itemsGrid">
                <c:forEach var="item" items="${foodItems}">
                    <div class="food-card bg-white rounded-2xl border border-gray-200 overflow-hidden hover:shadow-xl hover:border-primary/20 transition-all group relative">
                        <!-- Image -->
                        <div class="relative h-48 bg-gray-100 overflow-hidden">
                            <c:choose>
                                <c:when test="${not empty item.imageUrl}">
                                    <img id="img-${item.id}" src="${item.imageUrl}" alt="${item.name}"
                                         class="w-full h-full object-cover transition-transform duration-700 group-hover:scale-110 ${!item.available ? 'grayscale opacity-75' : ''}"/>
                                </c:when>
                                <c:otherwise>
                                    <div id="img-${item.id}" class="w-full h-full flex items-center justify-center transition-transform duration-700 group-hover:scale-110 ${!item.available ? 'grayscale opacity-75' : ''}">
                                        <span class="material-symbols-outlined text-5xl text-gray-300">restaurant</span>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                            
                            <!-- Hết hàng Overlay -->
                            <div id="overlay-${item.id}" class="absolute inset-0 bg-black/40 flex items-center justify-center backdrop-blur-[1px] ${item.available ? 'hidden' : ''}">
                                <span class="bg-white/95 px-3 py-1 rounded-full text-xs font-semibold uppercase shadow-sm text-gray-800">Hết hàng</span>
                            </div>

                            <!-- Category badge top left -->
                            <c:set var="catName" value=""/>
                            <c:forEach var="c" items="${categories}">
                                <c:if test="${c.id == item.categoryId}"><c:set var="catName" value="${c.name}"/></c:if>
                            </c:forEach>
                            <div class="absolute top-2 left-2">
                                <span class="bg-black/50 backdrop-blur-md text-white text-[10px] font-semibold px-2 py-1 rounded-lg uppercase tracking-wide border border-white/10">${catName}</span>
                            </div>

                            <!-- Floating Action Buttons -->
                            <div class="absolute top-2 right-2 flex gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                                <button type="button"
                                        onclick="openEditModal(this)"
                                        data-id="${item.id}"
                                        data-name="${item.name}"
                                        data-price="${item.price}"
                                        data-desc="${item.description}"
                                        data-img="${item.imageUrl}"
                                        data-cat="${item.categoryId}"
                                        class="p-2 bg-white/90 rounded-lg hover:text-primary backdrop-blur-sm shadow-sm hover:scale-110 transition-transform">
                                    <span class="material-symbols-outlined text-sm">edit</span>
                                </button>
                                <form method="POST" action="${pageContext.request.contextPath}/merchant/catalog" class="inline-block" onsubmit="return confirm('Xóa món ${item.name}?')">
                                    <input type="hidden" name="action" value="delete"/>
                                    <input type="hidden" name="itemId" value="${item.id}"/>
                                    <button type="submit" class="p-2 bg-white/90 rounded-lg hover:text-red-500 backdrop-blur-sm shadow-sm hover:scale-110 transition-transform">
                                        <span class="material-symbols-outlined text-sm">delete</span>
                                    </button>
                                </form>
                            </div>
                        </div>

                        <!-- Info -->
                        <div class="p-5">
                            <h4 class="font-semibold text-gray-900 line-clamp-2 leading-tight text-base group-hover:text-primary transition-colors item-name">${item.name}</h4>
                            <p class="text-xs text-gray-400 mt-1 line-clamp-1 h-4">${item.description}</p>
                            <p class="font-bold text-gray-900 text-lg mt-3">
                                <fmt:formatNumber value="${item.price}" type="number" groupingUsed="true"/>đ
                            </p>
                            <!-- AJAX toggle switch -->
                            <div class="flex items-center justify-between pt-4 mt-4 border-t border-gray-100">
                                <div class="flex items-center gap-2">
                                    <span id="dot-${item.id}" class="w-2 h-2 rounded-full ${item.available ? 'bg-green-500' : 'bg-gray-300'}"></span>
                                    <span id="text-${item.id}" class="text-xs font-semibold uppercase ${item.available ? 'text-green-700' : 'text-gray-400'}">${item.available ? 'Đang bán' : 'Tạm ngưng'}</span>
                                </div>
                                <label class="relative inline-flex items-center cursor-pointer">
                                    <input type="checkbox" class="sr-only peer"
                                           <c:if test="${item.available}">checked</c:if>
                                           onchange="toggleItem(${item.id}, this)"/>
                                    <div class="w-9 h-5 bg-gray-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-4 after:w-4 after:transition-all peer-checked:bg-primary shadow-inner"></div>
                                </label>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </div>
    </main>
</div>

<!-- Add item modal -->
<div id="addModal" class="hidden fixed inset-0 bg-black/40 z-50 flex items-end sm:items-center justify-center p-4">
    <div class="bg-white rounded-3xl shadow-2xl w-full max-w-lg p-6 space-y-4">
        <div class="flex items-center justify-between">
            <h2 class="text-lg font-bold text-gray-900">Thêm món mới</h2>
            <button onclick="document.getElementById('addModal').classList.add('hidden')"
                    class="w-8 h-8 flex items-center justify-center rounded-xl hover:bg-gray-100 transition-colors">
                <span class="material-symbols-outlined text-gray-500">close</span>
            </button>
        </div>
        <form method="POST" action="${pageContext.request.contextPath}/merchant/catalog" class="space-y-4">
            <input type="hidden" name="action" value="add"/>
            <div class="grid grid-cols-2 gap-4">
                <div class="col-span-2">
                    <label class="text-sm font-semibold text-gray-700 mb-1 block">Tên món *</label>
                    <input type="text" name="name" required placeholder="Ví dụ: Cơm tấm sườn"
                           class="w-full h-10 px-3 rounded-xl border border-gray-200 text-sm outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"/>
                </div>
                <div>
                    <label class="text-sm font-semibold text-gray-700 mb-1 block">Giá (đ) *</label>
                    <input type="number" name="price" required min="0" placeholder="35000"
                           class="w-full h-10 px-3 rounded-xl border border-gray-200 text-sm outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"/>
                </div>
                <div>
                    <label class="text-sm font-semibold text-gray-700 mb-1 block">Danh mục</label>
                    <select name="categoryId"
                            class="w-full h-10 px-3 rounded-xl border border-gray-200 text-sm outline-none focus:ring-2 focus:ring-primary/20">
                        <option value="">-- Chọn --</option>
                        <c:forEach var="cat" items="${categories}">
                            <option value="${cat.id}">${cat.name}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-span-2">
                    <label class="text-sm font-semibold text-gray-700 mb-1 block">Mô tả</label>
                    <textarea name="description" rows="2" placeholder="Mô tả ngắn về món ăn"
                              class="w-full px-3 py-2 rounded-xl border border-gray-200 text-sm outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary resize-none"></textarea>
                </div>
                <div class="col-span-2">
                    <label class="text-sm font-semibold text-gray-700 mb-1 block">URL hình ảnh</label>
                    <input type="url" name="imageUrl" placeholder="https://..."
                           class="w-full h-10 px-3 rounded-xl border border-gray-200 text-sm outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"/>
                </div>
            </div>
            <div class="flex gap-3 pt-2">
                <button type="button" onclick="document.getElementById('addModal').classList.add('hidden')"
                        class="flex-1 h-11 border border-gray-200 rounded-xl text-sm font-semibold text-gray-600 hover:bg-gray-50 transition-all">
                    Hủy
                </button>
                <button type="submit"
                        class="flex-1 h-11 bg-primary text-white rounded-xl text-sm font-semibold hover:bg-primary-dark transition-all">
                    Thêm món
                </button>
            </div>
        </form>
    </div>
</div>

<!-- Edit item modal -->
<div id="editModal" class="hidden fixed inset-0 bg-black/40 z-50 flex items-end sm:items-center justify-center p-4">
    <div class="bg-white rounded-3xl shadow-2xl w-full max-w-lg p-6 space-y-4">
        <div class="flex items-center justify-between">
            <div class="flex items-center gap-2">
                <span class="material-symbols-outlined text-primary">edit</span>
                <h2 class="text-lg font-bold text-gray-900">Sửa món ăn</h2>
            </div>
            <button onclick="document.getElementById('editModal').classList.add('hidden')"
                    class="w-8 h-8 flex items-center justify-center rounded-xl hover:bg-gray-100 transition-colors">
                <span class="material-symbols-outlined text-gray-500">close</span>
            </button>
        </div>
        <form method="POST" action="${pageContext.request.contextPath}/merchant/catalog" class="space-y-4">
            <input type="hidden" name="action" value="edit"/>
            <input type="hidden" name="itemId" id="editItemId"/>
            <div class="grid grid-cols-2 gap-4">
                <div class="col-span-2">
                    <label class="text-sm font-semibold text-gray-700 mb-1 block">Tên món *</label>
                    <input type="text" name="name" id="editName" required placeholder="Tên món ăn"
                           class="w-full h-10 px-3 rounded-xl border border-gray-200 text-sm outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"/>
                </div>
                <div>
                    <label class="text-sm font-semibold text-gray-700 mb-1 block">Giá (đ) *</label>
                    <input type="number" name="price" id="editPrice" required min="0"
                           class="w-full h-10 px-3 rounded-xl border border-gray-200 text-sm outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"/>
                </div>
                <div>
                    <label class="text-sm font-semibold text-gray-700 mb-1 block">Danh mục</label>
                    <select name="categoryId" id="editCategoryId"
                            class="w-full h-10 px-3 rounded-xl border border-gray-200 text-sm outline-none focus:ring-2 focus:ring-primary/20">
                        <option value="">-- Chọn --</option>
                        <c:forEach var="cat" items="${categories}">
                            <option value="${cat.id}">${cat.name}</option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-span-2">
                    <label class="text-sm font-semibold text-gray-700 mb-1 block">Mô tả</label>
                    <textarea name="description" id="editDesc" rows="2"
                              class="w-full px-3 py-2 rounded-xl border border-gray-200 text-sm outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary resize-none"></textarea>
                </div>
                <div class="col-span-2">
                    <label class="text-sm font-semibold text-gray-700 mb-1 block">URL hình ảnh</label>
                    <input type="url" name="imageUrl" id="editImageUrl" placeholder="https://..."
                           class="w-full h-10 px-3 rounded-xl border border-gray-200 text-sm outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary"/>
                </div>
            </div>
            <div class="flex gap-3 pt-2">
                <button type="button" onclick="document.getElementById('editModal').classList.add('hidden')"
                        class="flex-1 h-11 border border-gray-200 rounded-xl text-sm font-semibold text-gray-600 hover:bg-gray-50 transition-all">
                    Hủy
                </button>
                <button type="submit"
                        class="flex-1 h-11 bg-primary text-white rounded-xl text-sm font-semibold hover:bg-primary-dark transition-all">
                    Lưu thay đổi
                </button>
            </div>
        </form>
    </div>
</div>

<script>
    const _catalogUrl = '${pageContext.request.contextPath}/merchant/catalog';

    function filterItems() {
        const q = document.getElementById('searchInput').value.toLowerCase();
        document.querySelectorAll('.food-card').forEach(card => {
            const name = card.querySelector('.item-name').textContent.toLowerCase();
            card.style.display = name.includes(q) ? '' : 'none';
        });
    }

    // ─── Edit Modal ──────────────────────────────────────────────────────
    function openEditModal(btn) {
        document.getElementById('editItemId').value    = btn.dataset.id;
        document.getElementById('editName').value      = btn.dataset.name;
        document.getElementById('editPrice').value     = btn.dataset.price;
        document.getElementById('editDesc').value      = btn.dataset.desc || '';
        document.getElementById('editImageUrl').value  = btn.dataset.img  || '';
        const catSel = document.getElementById('editCategoryId');
        catSel.value = btn.dataset.cat || '';
        document.getElementById('editModal').classList.remove('hidden');
        document.getElementById('editName').focus();
    }

    // ─── AJAX Toggle ────────────────────────────────────────────────────
    function toggleItem(itemId, cb) {
        const dot  = document.getElementById('dot-'  + itemId);
        const text = document.getElementById('text-' + itemId);
        const newChecked = cb.checked;
        const setUI = (on) => {
            if (dot)  dot.className  = 'w-2 h-2 rounded-full ' + (on ? 'bg-green-500' : 'bg-gray-300');
            if (text) { text.className = 'text-xs font-semibold uppercase ' + (on ? 'text-green-700' : 'text-gray-400'); text.textContent = on ? 'Đang bán' : 'Tạm ngưng'; }
        };
        setUI(newChecked);
        fetch(_catalogUrl, {
            method: 'POST',
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
            body: 'action=toggle&itemId=' + itemId + '&xhr=1'
        }).catch(() => {
            // Rollback on error
            cb.checked = !newChecked;
            setUI(!newChecked);
        });
    }

    // Show add modal if there's an add error
    <c:if test="${not empty addError}">
    document.getElementById('addModal').classList.remove('hidden');
    </c:if>
</script>
</body>
</html>
