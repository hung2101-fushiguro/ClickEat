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

            <!-- Search + filter -->
            <div class="flex flex-col sm:flex-row gap-3">
                <div class="relative flex-1">
                    <span class="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 text-[18px]">search</span>
                    <input type="text" id="searchInput" placeholder="Tìm kiếm món ăn..."
                           onkeyup="filterItems()"
                           class="w-full h-10 pl-9 pr-4 rounded-xl border border-gray-200 bg-white text-sm outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all"/>
                </div>
                <form method="GET" class="flex gap-2">
                    <select name="categoryId" onchange="this.form.submit()"
                            class="h-10 px-3 rounded-xl border border-gray-200 bg-white text-sm text-gray-700 outline-none focus:ring-2 focus:ring-primary/20">
                        <option value="">Tất cả danh mục</option>
                        <c:forEach var="cat" items="${categories}">
                            <option value="${cat.id}" ${param.categoryId == cat.id ? 'selected' : ''}>${cat.name}</option>
                        </c:forEach>
                    </select>
                </form>
            </div>

            <!-- Stats bar -->
            <div class="flex items-center gap-4 text-sm text-gray-500">
                <span><strong class="text-gray-900">${totalItems}</strong> món</span>
                <span><strong class="text-green-600">${availableItems}</strong> đang bán</span>
                <span><strong class="text-gray-400">${unavailableItems}</strong> tạm ẩn</span>
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
                    <div class="food-card bg-white rounded-2xl border border-gray-200 overflow-hidden hover:shadow-md transition-shadow">
                        <!-- Image -->
                        <div class="relative h-44 bg-gray-100 overflow-hidden">
                            <c:choose>
                                <c:when test="${not empty item.imageUrl}">
                                    <img src="${item.imageUrl}" alt="${item.name}"
                                         class="w-full h-full object-cover"/>
                                </c:when>
                                <c:otherwise>
                                    <div class="w-full h-full flex items-center justify-center">
                                        <span class="material-symbols-outlined text-5xl text-gray-300">fastfood</span>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                            <!-- Available toggle -->
                            <form method="POST" action="${pageContext.request.contextPath}/merchant/catalog"
                                  class="absolute top-2 right-2">
                                <input type="hidden" name="action" value="toggle"/>
                                <input type="hidden" name="itemId" value="${item.id}"/>
                                <button type="submit"
                                        class="px-2 py-1 rounded-full text-xs font-semibold shadow ${item.available ? 'bg-green-500 text-white' : 'bg-gray-200 text-gray-600'}">
                                    ${item.available ? 'Đang bán' : 'Ẩn'}
                                </button>
                            </form>
                        </div>

                        <!-- Info -->
                        <div class="p-4">
                            <p class="font-semibold text-gray-900 truncate item-name">${item.name}</p>
                            <p class="text-xs text-gray-400 mt-0.5 truncate">${item.description}</p>
                            <div class="flex items-center justify-between mt-3">
                                <p class="font-bold text-primary">
                                    <fmt:formatNumber value="${item.price}" type="number" groupingUsed="true"/>đ
                                </p>
                                <div class="flex gap-1">
                                    <a href="${pageContext.request.contextPath}/merchant/catalog/edit?id=${item.id}"
                                       class="w-8 h-8 flex items-center justify-center rounded-xl border border-gray-200 hover:bg-gray-50 transition-colors">
                                        <span class="material-symbols-outlined text-base text-gray-500">edit</span>
                                    </a>
                                    <form method="POST" action="${pageContext.request.contextPath}/merchant/catalog"
                                          onsubmit="return confirm('Xóa món ${item.name}?')">
                                        <input type="hidden" name="action" value="delete"/>
                                        <input type="hidden" name="itemId" value="${item.id}"/>
                                        <button type="submit"
                                                class="w-8 h-8 flex items-center justify-center rounded-xl border border-gray-200 hover:bg-red-50 hover:border-red-200 transition-colors">
                                            <span class="material-symbols-outlined text-base text-gray-500 hover:text-red-500">delete</span>
                                        </button>
                                    </form>
                                </div>
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

<script>
    function filterItems() {
        const q = document.getElementById('searchInput').value.toLowerCase();
        document.querySelectorAll('.food-card').forEach(card => {
            const name = card.querySelector('.item-name').textContent.toLowerCase();
            card.style.display = name.includes(q) ? '' : 'none';
        });
    }
    // Show modal if there's an add error
    <c:if test="${not empty addError}">
    document.getElementById('addModal').classList.remove('hidden');
    </c:if>
</script>
</body>
</html>
