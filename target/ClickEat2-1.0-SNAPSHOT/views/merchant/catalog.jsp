<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
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
            .toggle-cb:checked + .toggle-track .toggle-dot {
                transform: translateX(100%);
                border-color: #fff;
            }
        </style>
    </head>
    <body class="h-full bg-[#f8f7f5] text-gray-800 flex overflow-hidden">

        <jsp:include page="_nav.jsp" />

        <main class="flex-1 flex flex-col h-screen overflow-y-auto">
            <header class="bg-white border-b border-gray-100 px-8 py-5 sticky top-0 z-10 flex justify-between items-center shadow-sm">
                <div>
                    <h1 class="text-2xl font-black text-gray-900 tracking-tight">Thực đơn</h1>
                    <p class="text-sm text-gray-500 font-medium mt-1">Quản lý món ăn và danh mục của nhà hàng</p>
                </div>
                <button onclick="document.getElementById('addModal').classList.remove('hidden')" class="bg-primary hover:bg-primary-dark text-white px-5 py-2.5 rounded-xl font-bold transition-all shadow-md hover:shadow-lg flex items-center gap-2">
                    <span class="material-symbols-outlined text-[20px]">add</span>Thêm món mới
                </button>
            </header>

            <div class="p-8 max-w-7xl mx-auto w-full">

                <div class="mb-6 flex gap-2 overflow-x-auto pb-2 scrollbar-hide">
                    <button class="px-5 py-2.5 bg-gray-900 text-white text-sm font-bold rounded-xl whitespace-nowrap shadow-sm">Tất cả món</button>

                    <c:forEach var="cat" items="${categories}">
                        <button class="px-5 py-2.5 bg-white text-gray-600 hover:bg-gray-50 text-sm font-bold rounded-xl border border-gray-200 whitespace-nowrap transition-colors">${cat.name}</button>
                    </c:forEach>
                </div>

                <div class="bg-white rounded-3xl shadow-[0_8px_30px_rgb(0,0,0,0.04)] border border-gray-50 overflow-hidden">
                    <table class="w-full text-left border-collapse">
                        <thead>
                            <tr class="bg-gray-50/50 border-b border-gray-100">
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
                                    <td class="py-4 px-6 text-sm font-semibold text-gray-400 text-center">${loop.index + 1}</td>
                                    <td class="py-4 px-6">
                                        <div class="flex items-center gap-4">
                                            <img src="${not empty f.imageUrl ? f.imageUrl : 'https://placehold.co/100x100?text=Food'}" class="w-14 h-14 rounded-xl object-cover border border-gray-100 shadow-sm" alt="${f.name}">
                                            <div>
                                                <p class="font-bold text-gray-900">${f.name}</p>
                                                <p class="text-xs text-gray-500 mt-0.5 max-w-[200px] truncate">${f.description}</p>
                                            </div>
                                        </div>
                                    </td>
                                    <td class="py-4 px-6 font-bold text-gray-900">
                                        <fmt:formatNumber value="${f.price}" type="currency" currencySymbol="đ" maxFractionDigits="0"/>
                                    </td>
                                    <td class="py-4 px-6">
                                        <label class="flex items-center cursor-pointer">
                                            <div class="relative">
                                                <input type="checkbox" class="sr-only toggle-cb" onchange="toggleItem(${f.id}, this)" ${f.isAvailable ? 'checked' : ''}>
                                                <div class="toggle-track w-11 h-6 bg-gray-200 rounded-full transition-colors duration-300"></div>
                                                <div class="toggle-dot absolute left-1 top-1 bg-white w-4 h-4 rounded-full transition-transform duration-300 border border-gray-300 shadow-sm"></div>
                                            </div>
                                            <div class="ml-3">
                                                <div id="dot-${f.id}" class="w-2 h-2 rounded-full mb-1 ${f.isAvailable ? 'bg-green-500' : 'bg-gray-300'}"></div>
                                                <span id="text-${f.id}" class="text-[10px] font-bold uppercase tracking-wider ${f.isAvailable ? 'text-green-600' : 'text-gray-400'}">
                                                    ${f.isAvailable ? 'Đang bán' : 'Tạm ngưng'}
                                                </span>
                                            </div>
                                        </label>
                                    </td>
                                    <td class="py-4 px-6 text-right">
                                        <button onclick="openEditModal(this)" 
                                                data-id="${f.id}" data-name="${f.name}" data-price="${f.price}" data-desc="${f.description}" data-cat="${f.categoryId}" data-img="${f.imageUrl}"
                                                class="w-10 h-10 rounded-xl bg-gray-50 text-gray-500 hover:bg-orange-50 hover:text-primary transition-colors flex items-center justify-center inline-flex">
                                            <span class="material-symbols-outlined text-[20px]">edit</span>
                                        </button>
                                    </td>
                                </tr>
                            </c:forEach>

                            <c:if test="${empty foodItems}">
                                <tr>
                                    <td colspan="5" class="py-12 text-center text-gray-400 font-medium">Bạn chưa có món ăn nào trong thực đơn.</td>
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
                    <div class="pt-2">
                        <button type="submit" class="w-full bg-gray-900 hover:bg-black text-white font-bold py-3.5 rounded-xl transition-all shadow-md">Lưu thay đổi</button>
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
                document.getElementById('editModal').classList.remove('hidden');
            }

            // Gọi AJAX để Bật/Tắt trạng thái "Đang bán" cực mượt mà
            function toggleItem(itemId, checkbox) {
                const isAvailable = checkbox.checked;

                // Đổi màu giao diện lập tức cho mượt
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

                // Gửi dữ liệu ngầm lên Servlet
                fetch('${pageContext.request.contextPath}/merchant/catalog', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                    body: 'action=toggle&itemId=' + itemId
                }).catch(error => console.error("Lỗi cập nhật trạng thái", error));
            }
        </script>
    </body>
</html>