<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="cartMode" value="${param.cartMode}" />

<c:choose>

    <%-- =========================
         MODE 1: POPUP DÙNG TRONG HEADER
       ========================= --%>
    <c:when test="${cartMode == 'popup'}">

        <!-- Overlay -->
        <div id="cartOverlay" class="fixed inset-0 bg-black/35 hidden z-50"></div>

        <!-- Modal wrapper -->
        <div id="cartModalWrap" class="fixed inset-0 hidden z-50">
            <div class="w-full h-full flex items-center justify-center p-4">
                <div id="cartModal"
                     class="w-full max-w-[860px] bg-white rounded-2xl shadow-2xl overflow-hidden">

                    <!-- Modal header -->
                    <div class="flex items-center justify-between px-6 h-16 border-b">
                        <div class="flex items-center gap-3">
                            <h3 class="text-2xl font-extrabold text-gray-900">Giỏ hàng của bạn</h3>
                            <span class="bg-orange-50 text-orange-500 font-extrabold text-sm px-3 py-1 rounded-full">
                                <c:out value="${cartCount != null ? cartCount : 0}" /> món
                            </span>
                        </div>

                        <button type="button" id="cartClose"
                                class="w-10 h-10 rounded-full hover:bg-gray-100 flex items-center justify-center"
                                aria-label="Đóng">
                            <i class="fa-solid fa-xmark text-gray-700 text-lg"></i>
                        </button>
                    </div>

                    <!-- Modal body -->
                    <div class="p-6 overflow-auto" style="max-height: calc(100vh - 64px - 170px);">
                        <c:choose>
                            <c:when test="${empty cartItems}">
                                <div class="min-h-[260px] flex items-center justify-center text-center px-10">
                                    <p class="text-gray-600 font-semibold">
                                        Giỏ hàng đang trống, bạn hãy tiếp tục mua sắm
                                    </p>
                                </div>
                            </c:when>

                            <c:otherwise>
                                <form id="cartUpdateForm" action="${ctx}/cart?action=update" method="post">
                                    <input type="hidden" name="action" value="update" />
                                    <input type="hidden" name="removeId" id="removeId" value="" />

                                    <div class="space-y-5">
                                        <c:forEach var="it" items="${cartItems}">
                                            <c:set var="itemId" value="${it.cartItemId}" />

                                            <div class="flex gap-4 border-b pb-5">
                                                <c:choose>
                                                    <c:when test="${not empty it.imageUrl}">
                                                        <img src="${it.imageUrl}"
                                                             onerror="this.onerror=null;this.src='${ctx}/assets/images/food-placeholder.png';"
                                                             class="w-20 h-20 rounded-full object-cover shadow"
                                                             alt="${it.name}" />
                                                    </c:when>
                                                    <c:otherwise>
                                                        <img src="${ctx}/assets/images/food-placeholder.png"
                                                             class="w-20 h-20 rounded-full object-cover shadow"
                                                             alt="${it.name}" />
                                                    </c:otherwise>
                                                </c:choose>

                                                <div class="flex-1">
                                                    <div class="flex items-start justify-between gap-3">
                                                        <div>
                                                            <div class="text-lg font-extrabold text-gray-900">${it.name}</div>
                                                            <div class="text-orange-500 font-extrabold text-lg">
                                                                <fmt:formatNumber value="${it.unitPrice}" type="number" />đ
                                                            </div>
                                                        </div>

                                                        <button type="button"
                                                                class="text-gray-500 hover:text-red-500"
                                                                onclick="removeItem('${itemId}')"
                                                                aria-label="Xóa">
                                                            <i class="fa-regular fa-trash-can text-xl"></i>
                                                        </button>
                                                    </div>

                                                    <div class="mt-3 flex flex-col sm:flex-row sm:items-center gap-3 sm:gap-4">
                                                        <div class="inline-flex items-center rounded-full border bg-gray-50 px-2 py-1 w-fit">
                                                            <button type="button"
                                                                    class="w-10 h-10 rounded-full hover:bg-white text-gray-700 text-xl flex items-center justify-center"
                                                                    onclick="changeQty('${itemId}', -1)">
                                                                −
                                                            </button>

                                                            <input type="number"
                                                                   class="w-16 text-center bg-transparent font-extrabold text-gray-900 outline-none"
                                                                   name="qty_${itemId}"
                                                                   id="qty_${itemId}"
                                                                   min="1"
                                                                   value="${it.quantity}"
                                                                   data-original="${it.quantity}"
                                                                   oninput="markDirty()" />

                                                            <button type="button"
                                                                    class="w-10 h-10 rounded-full hover:bg-white text-gray-700 text-xl flex items-center justify-center"
                                                                    onclick="changeQty('${itemId}', 1)">
                                                                +
                                                            </button>
                                                        </div>

                                                        <div class="text-sm font-semibold text-gray-500">
                                                            Tạm tính:
                                                            <span class="font-extrabold text-gray-900">
                                                                <fmt:formatNumber value="${it.unitPrice * it.quantity}" type="number" />đ
                                                            </span>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </c:forEach>
                                    </div>
                                </form>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <!-- Modal footer -->
                    <div class="px-6 py-5 border-t bg-white">
                        <div class="flex items-center justify-between mb-4">
                            <span class="text-gray-700 font-semibold">Tổng</span>
                            <span class="text-gray-900 font-extrabold text-lg">
                                <fmt:formatNumber value="${cartTotal}" type="number" />đ
                            </span>
                        </div>

                        <div class="flex flex-col sm:flex-row sm:items-center gap-3">
                            <a href="${empty cartItems ? ctx.concat('/store') : lastStoreUrl}"
                               class="h-12 px-6 rounded-full border border-gray-200 font-extrabold text-gray-900 hover:bg-gray-50 flex items-center justify-center whitespace-nowrap leading-none">
                                Tiếp tục mua sắm
                            </a>

                            <div class="flex gap-3 sm:ml-auto w-full sm:w-auto">
                                <button type="button"
                                        id="btnUpdateCart"
                                        class="h-12 px-6 rounded-full font-extrabold text-white bg-gray-300 cursor-not-allowed transition flex-1 sm:flex-none flex items-center justify-center whitespace-nowrap leading-none"
                                        disabled
                                        onclick="submitCartUpdate()">
                                    Cập nhật giỏ hàng
                                </button>

                                <a href="${ctx}/checkout"
                                   class="h-12 px-7 rounded-full font-extrabold text-white bg-orange-500 hover:bg-orange-600 shadow flex-1 sm:flex-none flex items-center justify-center whitespace-nowrap leading-none">
                                    Thanh toán
                                </a>
                            </div>
                        </div>
                    </div>

                </div>
            </div>
        </div>

        <script>
            (function () {
                const cartBtn = document.getElementById('cartBtn');
                const cartOverlay = document.getElementById('cartOverlay');
                const cartModalWrap = document.getElementById('cartModalWrap');
                const cartClose = document.getElementById('cartClose');

                const btnUpdate = document.getElementById('btnUpdateCart');
                const updateForm = document.getElementById('cartUpdateForm');

                function openCart() {
                    if (!cartOverlay || !cartModalWrap)
                        return;
                    cartOverlay.classList.remove('hidden');
                    cartModalWrap.classList.remove('hidden');
                    document.body.style.overflow = 'hidden';
                    markDirty();
                }

                function closeCart() {
                    if (!cartOverlay || !cartModalWrap)
                        return;
                    cartOverlay.classList.add('hidden');
                    cartModalWrap.classList.add('hidden');
                    document.body.style.overflow = '';
                }

                function markDirty() {
                    if (!btnUpdate || !cartModalWrap)
                        return;

                    const inputs = cartModalWrap.querySelectorAll('input[id^="qty_"]');
                    let dirty = false;

                    inputs.forEach(function (inp) {
                        const original = inp.getAttribute('data-original');
                        if (original != null && inp.value !== original) {
                            dirty = true;
                        }
                    });

                    if (dirty) {
                        btnUpdate.disabled = false;
                        btnUpdate.classList.remove('bg-gray-300', 'cursor-not-allowed');
                        btnUpdate.classList.add('bg-orange-500', 'hover:bg-orange-600');
                    } else {
                        btnUpdate.disabled = true;
                        btnUpdate.classList.add('bg-gray-300', 'cursor-not-allowed');
                        btnUpdate.classList.remove('bg-orange-500', 'hover:bg-orange-600');
                    }
                }

                function changeQty(cartItemId, delta) {
                    const inp = document.getElementById('qty_' + cartItemId);
                    if (!inp)
                        return;

                    let v = parseInt(inp.value || '1', 10);
                    if (isNaN(v))
                        v = 1;

                    v += delta;
                    if (v < 1)
                        v = 1;

                    inp.value = v;
                    markDirty();
                }

                function submitCartUpdate() {
                    if (!updateForm || !btnUpdate || btnUpdate.disabled)
                        return;
                    updateForm.submit();
                }

                function removeItem(cartItemId) {
                    if (!updateForm)
                        return;
                    const removeId = document.getElementById('removeId');
                    if (removeId) {
                        removeId.value = cartItemId;
                    }
                    updateForm.submit();
                }

                cartBtn?.addEventListener('click', openCart);
                cartClose?.addEventListener('click', closeCart);
                cartOverlay?.addEventListener('click', closeCart);

                document.addEventListener('keydown', function (e) {
                    if (e.key === 'Escape')
                        closeCart();
                });

                window.changeQty = changeQty;
                window.submitCartUpdate = submitCartUpdate;
                window.removeItem = removeItem;
                window.markDirty = markDirty;
            })();
        </script>
    </c:when>

    <%-- =========================
         MODE 2: TRANG CART RIÊNG
       ========================= --%>
    <c:otherwise>
        <!DOCTYPE html>
        <html lang="vi">
            <head>
                <meta charset="UTF-8">
                <title>Giỏ hàng của bạn - ClickEat</title>
                <script src="https://cdn.tailwindcss.com"></script>
                <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
            </head>
            <body class="bg-gray-50 flex flex-col min-h-screen">

                <jsp:include page="header.jsp">
                    <jsp:param name="activePage" value="cart" />
                </jsp:include>

                <main class="flex-grow max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-10 w-full">
                    <h1 class="text-3xl font-bold text-gray-900 mb-8">Giỏ hàng của bạn</h1>

                    <c:choose>
                        <c:when test="${empty cartItems}">
                            <div class="bg-white p-10 rounded-2xl shadow-sm text-center border border-gray-100">
                                <i class="fa-solid fa-cart-shopping text-6xl text-gray-200 mb-4"></i>
                                <h2 class="text-xl font-medium text-gray-600 mb-4">Giỏ hàng đang trống</h2>
                                <a href="${ctx}/home" class="inline-block bg-orange-500 text-white px-6 py-3 rounded-lg font-medium hover:bg-orange-600 transition">
                                    Khám phá thực đơn ngay
                                </a>
                            </div>
                        </c:when>

                        <c:otherwise>
                            <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
                                <div class="lg:col-span-2 space-y-4">
                                    <c:forEach var="item" items="${cartItems}">
                                        <div class="bg-white p-4 rounded-2xl shadow-sm border border-gray-100 flex items-center gap-4">
                                            <c:choose>
                                                <c:when test="${not empty item.imageUrl}">
                                                    <img src="${item.imageUrl}"
                                                         alt="${item.name}"
                                                         class="w-20 h-20 object-cover rounded-xl bg-gray-100"
                                                         onerror="this.onerror=null;this.src='${ctx}/assets/images/food-placeholder.png';">
                                                </c:when>
                                                <c:otherwise>
                                                    <img src="${ctx}/assets/images/food-placeholder.png"
                                                         alt="${item.name}"
                                                         class="w-20 h-20 object-cover rounded-xl bg-gray-100">
                                                </c:otherwise>
                                            </c:choose>

                                            <div class="flex-grow">
                                                <h3 class="text-lg font-bold text-gray-900">${item.name}</h3>
                                                <p class="text-orange-500 font-bold">
                                                    <fmt:formatNumber value="${item.unitPrice}" type="number" />đ
                                                </p>
                                            </div>

                                            <div class="flex items-center gap-3 bg-gray-50 px-3 py-1 rounded-lg border border-gray-200">
                                                <span class="font-medium text-gray-700">SL: ${item.quantity}</span>
                                            </div>

                                            <a href="${ctx}/cart?action=delete&itemId=${item.cartItemId}"
                                               class="p-2 text-red-500 hover:bg-red-50 rounded-lg transition-colors ml-2"
                                               onclick="return confirm('Bạn có chắc chắn muốn xóa món này không?');">
                                                <i class="fa-solid fa-trash"></i>
                                            </a>
                                        </div>
                                    </c:forEach>
                                </div>

                                <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 h-fit sticky top-24">
                                    <h3 class="text-xl font-bold text-gray-900 mb-4">Tổng cộng</h3>

                                    <div class="flex justify-between items-center mb-4 text-gray-600">
                                        <span>Tạm tính:</span>
                                        <span class="font-bold text-gray-900">
                                            <fmt:formatNumber value="${totalMoney}" type="number" />đ
                                        </span>
                                    </div>

                                    <div class="border-t border-gray-100 pt-4 mb-6">
                                        <div class="flex justify-between items-center">
                                            <span class="font-bold text-gray-900">Thành tiền:</span>
                                            <span class="font-black text-2xl text-orange-500">
                                                <fmt:formatNumber value="${totalMoney}" type="number" />đ
                                            </span>
                                        </div>
                                    </div>

                                    <a href="${ctx}/checkout"
                                       class="block w-full text-center bg-gray-900 text-white py-3 rounded-xl font-bold hover:bg-gray-800 transition-colors">
                                        Tiến hành Thanh toán
                                    </a>
                                </div>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </main>
                <jsp:include page="footer.jsp" />
            </body>
        </html>
    </c:otherwise>
</c:choose>