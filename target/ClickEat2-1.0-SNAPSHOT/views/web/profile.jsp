<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ClickEat - Thông tin tài khoản</title>
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <link rel="shortcut icon" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    </head>
    <body class="bg-[#f4f5f7] text-gray-900">
        <jsp:include page="/views/web/header.jsp">
            <jsp:param name="activePage" value="profile" />
        </jsp:include>

        <main class="max-w-7xl mx-auto px-6 py-8">
            <div class="mb-8">
                <div class="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-orange-100 text-orange-600 text-sm font-extrabold">
                    <i class="fa-regular fa-user"></i>
                    Hồ sơ cá nhân
                </div>
                <h1 class="mt-4 text-4xl font-black tracking-tight">Thông tin tài khoản</h1>
                <p class="mt-2 text-gray-500 text-lg">Quản lý thông tin cá nhân, hồ sơ ăn uống và ảnh đại diện của bạn.</p>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-[280px_minmax(0,1fr)] gap-7">
                <jsp:include page="sidebar.jsp">
                    <jsp:param name="menu" value="profile" />
                </jsp:include>

                <section class="min-w-0">
                    <c:if test="${not empty error}">
                        <div class="mb-5 rounded-2xl border border-red-200 bg-red-50 text-red-700 px-5 py-4 font-semibold">
                            ${error}
                        </div>
                    </c:if>

                    <form id="profileForm"
                          action="${pageContext.request.contextPath}/customer/profile"
                          method="post"
                          class="bg-white border border-gray-200 rounded-[32px] shadow-[0_10px_30px_rgba(15,23,42,.06)] overflow-hidden">

                        <div class="p-7 md:p-8 border-b border-gray-100 flex flex-col md:flex-row md:items-center md:justify-between gap-5">
                            <div class="flex items-center gap-5">
                                <c:choose>
                                    <c:when test="${not empty profileUser.avatarUrl}">
                                        <img id="avatarPreview"
                                             src="${profileUser.avatarUrl}"
                                             alt="${profileUser.fullName}"
                                             class="w-24 h-24 rounded-full object-cover border-4 border-orange-100 shadow"
                                             onerror="this.onerror=null;this.src='https://ui-avatars.com/api/?name=${profileUser.fullName}&background=fff3e8&color=f97316&bold=true';">
                                    </c:when>
                                    <c:otherwise>
                                        <img id="avatarPreview"
                                             src="https://ui-avatars.com/api/?name=${profileUser.fullName}&background=fff3e8&color=f97316&bold=true"
                                             alt="${profileUser.fullName}"
                                             class="w-24 h-24 rounded-full object-cover border-4 border-orange-100 shadow">
                                    </c:otherwise>
                                </c:choose>

                                <div>
                                    <h2 class="text-2xl font-black text-gray-900">${profileUser.fullName}</h2>
                                    <p class="text-gray-500 mt-1">${profileUser.email}</p>
                                    <p class="text-sm text-gray-400 mt-2">
                                        Thành viên từ
                                        <fmt:formatDate value="${profileUser.createdAt}" pattern="dd/MM/yyyy HH:mm"/>
                                    </p>
                                </div>
                            </div>

                            <div class="text-sm text-gray-500">
                                <div><span class="font-bold text-gray-700">Vai trò:</span> ${profileUser.role}</div>
                                <div class="mt-1"><span class="font-bold text-gray-700">Trạng thái:</span> ${profileUser.status}</div>
                            </div>
                        </div>

                        <div class="p-7 md:p-8">
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                                <div>
                                    <label class="block text-sm font-bold text-gray-800 mb-2">Họ và tên</label>
                                    <input type="text"
                                           name="fullName"
                                           id="fullName"
                                           value="${profileUser.fullName}"
                                           maxlength="100"
                                           disabled
                                           class="profile-editable w-full h-12 px-4 rounded-2xl border border-gray-200 bg-gray-50 text-gray-900 outline-none focus:ring-4 focus:ring-orange-100 focus:border-orange-400 transition disabled:bg-gray-100 disabled:text-gray-500">
                                    <p class="mt-2 text-xs text-gray-400">Tối thiểu 2 ký tự, tối đa 100 ký tự.</p>
                                </div>

                                <div>
                                    <label class="block text-sm font-bold text-gray-800 mb-2">Email</label>
                                    <input type="email"
                                           name="email"
                                           id="email"
                                           value="${profileUser.email}"
                                           maxlength="150"
                                           disabled
                                           class="profile-editable w-full h-12 px-4 rounded-2xl border border-gray-200 bg-gray-50 text-gray-900 outline-none focus:ring-4 focus:ring-orange-100 focus:border-orange-400 transition disabled:bg-gray-100 disabled:text-gray-500">
                                </div>

                                <div>
                                    <label class="block text-sm font-bold text-gray-800 mb-2">Số điện thoại</label>
                                    <input type="text"
                                           value="${profileUser.phone}"
                                           readonly
                                           class="w-full h-12 px-4 rounded-2xl border border-gray-200 bg-gray-100 text-gray-500 cursor-not-allowed">
                                    <p class="mt-2 text-xs text-gray-400">Số điện thoại hiện chưa cho phép chỉnh sửa.</p>
                                </div>

                                <div>
                                    <label class="block text-sm font-bold text-gray-800 mb-2">Avatar URL</label>
                                    <input type="text"
                                           name="avatarUrl"
                                           id="avatarUrl"
                                           value="${profileUser.avatarUrl}"
                                           maxlength="500"
                                           disabled
                                           class="profile-editable w-full h-12 px-4 rounded-2xl border border-gray-200 bg-gray-50 text-gray-900 outline-none focus:ring-4 focus:ring-orange-100 focus:border-orange-400 transition disabled:bg-gray-100 disabled:text-gray-500">
                                    <p class="mt-2 text-xs text-gray-400">Cho phép đường dẫn bắt đầu bằng http://, https:// hoặc /</p>
                                </div>

                                <div class="md:col-span-2">
                                    <label class="block text-sm font-bold text-gray-800 mb-2">Sở thích ăn uống</label>
                                    <textarea name="foodPreferences"
                                              id="foodPreferences"
                                              rows="3"
                                              maxlength="1000"
                                              disabled
                                              class="profile-editable w-full px-4 py-3 rounded-2xl border border-gray-200 bg-gray-50 text-gray-900 outline-none focus:ring-4 focus:ring-orange-100 focus:border-orange-400 transition disabled:bg-gray-100 disabled:text-gray-500 resize-none">${customerProfile.foodPreferences}</textarea>
                                </div>

                                <div>
                                    <label class="block text-sm font-bold text-gray-800 mb-2">Dị ứng</label>
                                    <textarea name="allergies"
                                              id="allergies"
                                              rows="3"
                                              maxlength="1000"
                                              disabled
                                              class="profile-editable w-full px-4 py-3 rounded-2xl border border-gray-200 bg-gray-50 text-gray-900 outline-none focus:ring-4 focus:ring-orange-100 focus:border-orange-400 transition disabled:bg-gray-100 disabled:text-gray-500 resize-none">${customerProfile.allergies}</textarea>
                                </div>

                                <div>
                                    <label class="block text-sm font-bold text-gray-800 mb-2">Mục tiêu sức khỏe</label>
                                    <textarea name="healthGoal"
                                              id="healthGoal"
                                              rows="3"
                                              maxlength="200"
                                              disabled
                                              class="profile-editable w-full px-4 py-3 rounded-2xl border border-gray-200 bg-gray-50 text-gray-900 outline-none focus:ring-4 focus:ring-orange-100 focus:border-orange-400 transition disabled:bg-gray-100 disabled:text-gray-500 resize-none">${customerProfile.healthGoal}</textarea>
                                </div>

                                <div>
                                    <label class="block text-sm font-bold text-gray-800 mb-2">Mục tiêu calo mỗi ngày</label>
                                    <input type="number"
                                           name="dailyCalorieTarget"
                                           id="dailyCalorieTarget"
                                           value="${customerProfile.dailyCalorieTarget}"
                                           min="500"
                                           max="10000"
                                           disabled
                                           class="profile-editable w-full h-12 px-4 rounded-2xl border border-gray-200 bg-gray-50 text-gray-900 outline-none focus:ring-4 focus:ring-orange-100 focus:border-orange-400 transition disabled:bg-gray-100 disabled:text-gray-500">
                                </div>
                            </div>

                            <div id="clientError"
                                 class="hidden mt-6 rounded-2xl border border-red-200 bg-red-50 text-red-700 px-5 py-4 font-semibold"></div>

                            <div class="mt-8 flex flex-wrap items-center justify-between gap-4">
                                <button type="button"
                                        id="editBtn"
                                        class="inline-flex items-center gap-2 h-12 px-6 rounded-full bg-orange-500 text-white font-extrabold hover:bg-orange-600 transition shadow">
                                    <i class="fa-regular fa-pen-to-square"></i>
                                    Cập nhật thông tin
                                </button>

                                <button type="submit"
                                        id="saveBtn"
                                        disabled
                                        class="inline-flex items-center gap-2 h-12 px-6 rounded-full bg-gray-300 text-white font-extrabold cursor-not-allowed transition">
                                    <i class="fa-regular fa-floppy-disk"></i>
                                    Lưu
                                </button>
                            </div>
                        </div>
                    </form>
                </section>
            </div>
        </main>

        <script>
            const editBtn = document.getElementById('editBtn');
            const saveBtn = document.getElementById('saveBtn');
            const editableFields = document.querySelectorAll('.profile-editable');
            const form = document.getElementById('profileForm');
            const clientError = document.getElementById('clientError');
            const avatarUrl = document.getElementById('avatarUrl');
            const avatarPreview = document.getElementById('avatarPreview');

            let editing = false;

            function setEditingMode(enabled) {
                editing = enabled;
                editableFields.forEach(el => el.disabled = !enabled);

                if (enabled) {
                    saveBtn.disabled = false;
                    saveBtn.className = 'inline-flex items-center gap-2 h-12 px-6 rounded-full bg-gray-900 text-white font-extrabold hover:bg-black transition';
                    editBtn.innerHTML = '<i class="fa-regular fa-pen-to-square"></i> Đang chỉnh sửa';
                    editBtn.classList.remove('bg-orange-500', 'text-white', 'hover:bg-orange-600');
                    editBtn.classList.add('bg-orange-100', 'text-orange-600');
                } else {
                    saveBtn.disabled = true;
                    saveBtn.className = 'inline-flex items-center gap-2 h-12 px-6 rounded-full bg-gray-300 text-white font-extrabold cursor-not-allowed transition';
                    editBtn.innerHTML = '<i class="fa-regular fa-pen-to-square"></i> Cập nhật thông tin';
                    editBtn.classList.remove('bg-orange-100', 'text-orange-600');
                    editBtn.classList.add('bg-orange-500', 'text-white', 'hover:bg-orange-600');
                }
            }

            editBtn.addEventListener('click', () => {
                setEditingMode(true);
            });

            if (avatarUrl) {
                avatarUrl.addEventListener('input', function () {
                    const value = this.value.trim();
                    if (value) {
                        avatarPreview.src = value;
                    }
                });
            }

            form.addEventListener('submit', function (e) {
                if (!editing) {
                    e.preventDefault();
                    return;
                }

                const fullName = document.getElementById('fullName').value.trim();
                const email = document.getElementById('email').value.trim();
                const avatar = document.getElementById('avatarUrl').value.trim();
                const foodPreferences = document.getElementById('foodPreferences').value.trim();
                const allergies = document.getElementById('allergies').value.trim();
                const healthGoal = document.getElementById('healthGoal').value.trim();
                const dailyCalorieTarget = document.getElementById('dailyCalorieTarget').value.trim();

                let error = '';

                if (fullName.length < 2 || fullName.length > 100) {
                    error = 'Họ tên phải từ 2 đến 100 ký tự.';
                } else if (!/^[\p{L}0-9\s'.-]+$/u.test(fullName)) {
                    error = 'Họ tên chỉ được chứa chữ cái, số, khoảng trắng và ký tự cơ bản.';
                } else if (!/^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$/.test(email) || email.length > 150) {
                    error = 'Email không hợp lệ.';
                } else if (avatar && !(avatar.startsWith('http://') || avatar.startsWith('https://') || avatar.startsWith('/'))) {
                    error = 'Avatar URL phải bắt đầu bằng http://, https:// hoặc /.';
                } else if (foodPreferences.length > 1000) {
                    error = 'Sở thích ăn uống không được vượt quá 1000 ký tự.';
                } else if (allergies.length > 1000) {
                    error = 'Dị ứng không được vượt quá 1000 ký tự.';
                } else if (healthGoal.length > 200) {
                    error = 'Mục tiêu sức khỏe không được vượt quá 200 ký tự.';
                } else if (dailyCalorieTarget) {
                    const cal = Number(dailyCalorieTarget);
                    if (Number.isNaN(cal) || cal < 500 || cal > 10000) {
                        error = 'Mục tiêu calo mỗi ngày phải trong khoảng 500 - 10000.';
                    }
                }

                if (error) {
                    e.preventDefault();
                    clientError.textContent = error;
                    clientError.classList.remove('hidden');
                    window.scrollTo({top: clientError.offsetTop - 120, behavior: 'smooth'});
                    return;
                }

                clientError.classList.add('hidden');
            });
        </script>
    </body>
</html>