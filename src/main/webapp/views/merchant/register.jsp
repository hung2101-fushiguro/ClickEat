<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>ClickEat – Đăng ký cửa hàng</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://accounts.google.com/gsi/client" async defer></script>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0&display=swap" rel="stylesheet"/>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/vendor/leaflet/leaflet.css"/>
    <script src="${pageContext.request.contextPath}/assets/vendor/leaflet/leaflet.js"></script>
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
        body { font-family: 'Inter', sans-serif; }
        .material-symbols-outlined { font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24; }
        /* File upload drag zone */
        .upload-zone:hover { border-color: #c86601; background: #fff7ed; }
        .upload-zone:hover .upload-icon { color: #c86601; }
        #leafletMap { height: 280px; border-radius: 0.75rem; }
    </style>
</head>
<body class="min-h-screen bg-gray-50 font-sans">

    <!-- Fixed top header -->
    <header class="fixed top-0 left-0 right-0 h-16 bg-white border-b border-gray-200 flex items-center justify-between px-6 md:px-8 z-50 shadow-sm">
        <div class="flex items-center gap-2.5 text-primary">
            <span class="material-symbols-outlined text-3xl">restaurant</span>
            <span class="text-xl font-bold text-gray-900">ClickEat <span class="text-primary">Merchant</span></span>
        </div>
          <a href="${pageContext.request.contextPath}/login"
              class="flex items-center gap-1.5 text-sm font-semibold text-gray-600 hover:text-gray-900 transition-colors">
            <span class="material-symbols-outlined text-base">arrow_back</span>
            Về trang đăng nhập
        </a>
    </header>

    <div class="pt-16 flex min-h-screen">

        <!-- Left step sidebar (hidden on mobile) -->
        <aside class="hidden lg:flex flex-col fixed left-0 top-16 bottom-0 w-72 bg-white border-r border-gray-200 p-8">
            <div class="mb-8">
                <h2 class="text-xl font-bold text-gray-900 mb-1">Phát triển cùng ClickEat</h2>
                <p class="text-sm text-primary font-medium">Trở thành đối tác ngay hôm nay</p>
            </div>

            <div class="space-y-3" id="sidebarSteps">
                <!-- Step items rendered by JS -->
            </div>

            <!-- Benefits section -->
            <div class="mt-auto pt-8 border-t border-gray-100 space-y-3">
                <p class="text-xs font-semibold text-gray-400 uppercase tracking-wider">Quyền lợi đối tác</p>
                <div class="flex items-start gap-3 text-sm text-gray-600">
                    <span class="material-symbols-outlined text-primary text-base mt-0.5">trending_up</span>
                    <span>Tiếp cận hàng nghìn khách hàng mỗi ngày</span>
                </div>
                <div class="flex items-start gap-3 text-sm text-gray-600">
                    <span class="material-symbols-outlined text-primary text-base mt-0.5">analytics</span>
                    <span>Báo cáo doanh thu chi tiết theo ngày</span>
                </div>
                <div class="flex items-start gap-3 text-sm text-gray-600">
                    <span class="material-symbols-outlined text-primary text-base mt-0.5">support_agent</span>
                    <span>Hỗ trợ 24/7 từ đội ngũ ClickEat</span>
                </div>
            </div>
        </aside>

        <!-- Main content area -->
        <main class="flex-1 lg:ml-72 flex justify-center p-4 md:p-8 lg:p-12">
            <div class="w-full max-w-2xl">

                <!-- Step progress bar (mobile only) -->
                <div class="flex gap-2 mb-6 lg:hidden">
                    <div id="mob-step1-bar" class="h-1.5 flex-1 rounded-full bg-primary transition-all"></div>
                    <div id="mob-step2-bar" class="h-1.5 flex-1 rounded-full bg-gray-200 transition-all"></div>
                    <div id="mob-step3-bar" class="h-1.5 flex-1 rounded-full bg-gray-200 transition-all"></div>
                </div>

                <!-- Error banner (server-side) -->
                <c:if test="${not empty error}">
                    <div class="mb-6 px-4 py-3 bg-red-50 border border-red-200 rounded-xl text-sm text-red-700 flex items-center gap-2">
                        <span class="material-symbols-outlined text-red-500 text-[18px]">error</span>
                        ${error}
                    </div>
                </c:if>
                <c:if test="${not empty sessionScope.googleError}">
                    <div class="mb-6 px-4 py-3 bg-red-50 border border-red-200 rounded-xl text-sm text-red-700 flex items-center gap-2">
                        <span class="material-symbols-outlined text-red-500 text-[18px]">error</span>
                        ${sessionScope.googleError}
                    </div>
                    <c:remove var="googleError" scope="session"/>
                </c:if>

                <!-- ===== STEP 1: Thông tin cơ bản ===== -->
                <div id="step1" class="bg-white rounded-2xl shadow-sm border border-gray-200 p-6 md:p-8 space-y-6">
                    <div>
                        <h2 class="text-3xl font-bold text-gray-900">Thông tin cơ bản</h2>
                        <p class="text-gray-500 text-sm mt-1">Bước 1 / 3 — Chủ cửa hàng & tài khoản đăng nhập</p>
                    </div>

                    <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                        <!-- Owner name -->
                        <div>
                            <label class="block text-sm font-semibold text-gray-800 mb-2">Họ tên chủ cửa hàng *</label>
                            <input type="text" id="ownerName" placeholder="Nguyễn Văn A"
                                   value="${sessionScope.googleSignup_name}"
                                   class="w-full h-12 px-4 rounded-xl border border-gray-200 bg-gray-50 text-gray-900 focus:bg-white focus:ring-4 focus:ring-orange-100 focus:border-primary outline-none transition-all placeholder:text-gray-400"/>
                        </div>
                        <!-- Shop name -->
                        <div>
                            <label class="block text-sm font-semibold text-gray-800 mb-2">Tên nhà hàng / quán ăn *</label>
                            <input type="text" id="shopName" placeholder="Phở Ngon Gia Truyền"
                                   class="w-full h-12 px-4 rounded-xl border border-gray-200 bg-gray-50 text-gray-900 focus:bg-white focus:ring-4 focus:ring-orange-100 focus:border-primary outline-none transition-all placeholder:text-gray-400"/>
                        </div>
                        <!-- Email -->
                        <div class="md:col-span-2">
                            <label class="block text-sm font-semibold text-gray-800 mb-2">Email *</label>
                            <div class="relative">
                                <input type="email" id="regEmail" placeholder="email@example.com"
                                       value="${sessionScope.googleSignup_email}"
                                       <c:if test="${not empty sessionScope.googleSignup_sub}">readonly</c:if>
                                       class="w-full h-12 px-4 pr-12 rounded-xl border <c:choose><c:when test="${not empty sessionScope.googleSignup_sub}">border-green-300 bg-green-50</c:when><c:otherwise>border-gray-200 bg-gray-50</c:otherwise></c:choose> text-gray-900 focus:ring-4 focus:ring-orange-100 focus:border-primary outline-none transition-all placeholder:text-gray-400"/>
                                <c:if test="${not empty sessionScope.googleSignup_sub}">
                                    <span class="absolute right-3 top-1/2 -translate-y-1/2 material-symbols-outlined text-green-500" style="font-size:20px;font-variation-settings:'FILL' 1,'wght' 400,'GRAD' 0,'opsz' 24">verified</span>
                                </c:if>
                            </div>
                        </div>
                        <!-- Phone -->
                        <div>
                            <label class="block text-sm font-semibold text-gray-800 mb-2">Số điện thoại *</label>
                            <input type="tel" id="regPhone" placeholder="0901234567"
                                   class="w-full h-12 px-4 rounded-xl border border-gray-200 bg-gray-50 text-gray-900 focus:bg-white focus:ring-4 focus:ring-orange-100 focus:border-primary outline-none transition-all placeholder:text-gray-400"/>
                        </div>
                        <!-- Business type -->
                        <div>
                            <label class="block text-sm font-semibold text-gray-800 mb-2">Loại hình kinh doanh</label>
                            <select id="businessType"
                                    class="w-full h-12 px-4 rounded-xl border border-gray-200 bg-gray-50 text-gray-900 focus:bg-white focus:ring-4 focus:ring-orange-100 focus:border-primary outline-none transition-all">
                                <option value="">Chọn loại hình...</option>
                                <option value="fastfood">Đồ ăn nhanh</option>
                                <option value="restaurant">Nhà hàng</option>
                                <option value="cafe">Quán Cafe / Trà sữa</option>
                                <option value="snack">Quán ăn vặt</option>
                                <option value="other">Khác</option>
                            </select>
                        </div>
                        <div>
                            <label class="block text-sm font-semibold text-gray-800 mb-2">Đang bán trên nền tảng</label>
                            <select id="sourcePlatform"
                                    class="w-full h-12 px-4 rounded-xl border border-gray-200 bg-gray-50 text-gray-900 focus:bg-white focus:ring-4 focus:ring-orange-100 focus:border-primary outline-none transition-all">
                                <option value="NONE">Chưa bán trên nền tảng khác</option>
                                <option value="GRABFOOD">GrabFood</option>
                                <option value="SHOPEEFOOD">ShopeeFood</option>
                                <option value="OTHER">Nền tảng khác</option>
                            </select>
                        </div>
                        <c:choose>
                        <c:when test="${not empty sessionScope.googleSignup_sub}">
                        <!-- Google sign-up — no password needed (spans 2 cols) -->
                        <div class="md:col-span-2">
                            <div class="flex items-center gap-3 px-4 py-3 bg-blue-50 border border-blue-100 rounded-xl">
                                <svg class="w-5 h-5 flex-shrink-0" viewBox="0 0 24 24"><path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/><path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/><path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/><path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/></svg>
                                <p class="text-sm text-blue-800 font-medium">Đăng ký qua Google — không cần mật khẩu. Bạn sẽ đăng nhập bằng tài khoản Google này.</p>
                            </div>
                        </div>
                        </c:when>
                        <c:otherwise>
                        <!-- Password -->
                        <div>
                            <label class="block text-sm font-semibold text-gray-800 mb-2">Mật khẩu *</label>
                            <div class="relative">
                                <input type="password" id="regPassword" placeholder="Ít nhất 6 ký tự"
                                        form="step3"
                                       class="w-full h-12 px-4 pr-12 rounded-xl border border-gray-200 bg-gray-50 text-gray-900 focus:bg-white focus:ring-4 focus:ring-orange-100 focus:border-primary outline-none transition-all placeholder:text-gray-400"/>
                                <button type="button" onclick="togglePw('regPassword','eye1')" tabindex="-1"
                                        class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-700 transition-colors">
                                    <span class="material-symbols-outlined text-xl" id="eye1">visibility</span>
                                </button>
                            </div>
                        </div>
                        <!-- Confirm password -->
                        <div>
                            <label class="block text-sm font-semibold text-gray-800 mb-2">Xác nhận mật khẩu *</label>
                            <div class="relative">
                                <input type="password" id="regConfirm" placeholder="Nhập lại mật khẩu"
                                        form="step3"
                                       class="w-full h-12 px-4 pr-12 rounded-xl border border-gray-200 bg-gray-50 text-gray-900 focus:bg-white focus:ring-4 focus:ring-orange-100 focus:border-primary outline-none transition-all placeholder:text-gray-400"/>
                                <button type="button" onclick="togglePw('regConfirm','eye2')" tabindex="-1"
                                        class="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-700 transition-colors">
                                    <span class="material-symbols-outlined text-xl" id="eye2">visibility</span>
                                </button>
                            </div>
                        </div>
                        </c:otherwise>
                        </c:choose>
                    </div>

                    <div id="step1Error" class="hidden text-red-500 text-sm font-medium flex items-center gap-1.5">
                        <span class="material-symbols-outlined text-sm">error</span>
                        <span id="step1ErrorMsg"></span>
                    </div>

                    <button type="button" onclick="goStep2()"
                            class="w-full h-14 bg-primary hover:bg-primary-dark text-white font-semibold rounded-xl shadow-lg shadow-orange-200 transition-all text-base flex items-center justify-center gap-2 group">
                        <span>Tiếp tục</span>
                        <span class="material-symbols-outlined group-hover:translate-x-1 transition-transform">arrow_forward</span>
                    </button>

                    <!-- Divider -->
                    <div class="relative flex items-center gap-3">
                        <div class="flex-1 h-px bg-gray-200"></div>
                        <span class="text-xs font-medium text-gray-400">hoặc đăng ký nhanh</span>
                        <div class="flex-1 h-px bg-gray-200"></div>
                    </div>

                    <!-- Google Sign-Up -->
                    <!-- Hidden form — JS fills credential then submits -->
                    <form id="googleAuthForm" method="POST" action="${pageContext.request.contextPath}/merchant/auth/google">
                        <input type="hidden" id="googleCredential" name="credential"/>
                        <input type="hidden" name="mode" value="register"/>
                    </form>
                    <div id="googleBtnContainer" class="flex justify-center"></div>

                    <p class="text-center text-gray-500 text-sm">
                        Đã có tài khoản?
                        <a href="${pageContext.request.contextPath}/login" class="text-primary font-semibold hover:underline">Đăng nhập</a>
                    </p>
                </div>

                <!-- ===== STEP 2: Chi tiết cửa hàng ===== -->
                <div id="step2" class="hidden bg-white rounded-2xl shadow-sm border border-gray-200 p-6 md:p-8 space-y-6">
                    <div>
                        <h2 class="text-3xl font-bold text-gray-900">Chi tiết cửa hàng</h2>
                        <p class="text-gray-500 text-sm mt-1">Bước 2 / 3 — Thông tin cửa hàng của bạn</p>
                    </div>

                    <!-- Shop description -->
                    <div>
                        <label class="block text-sm font-semibold text-gray-800 mb-2">Mô tả cửa hàng</label>
                        <textarea id="shopDesc" rows="3" placeholder="Mô tả ngắn về cửa hàng của bạn…"
                                  class="w-full px-4 py-3 rounded-xl border border-gray-200 bg-gray-50 text-gray-900 focus:bg-white focus:ring-4 focus:ring-orange-100 focus:border-primary outline-none transition-all placeholder:text-gray-400 resize-none"></textarea>
                    </div>

                    <!-- Address -->
                    <div>
                        <label class="block text-sm font-semibold text-gray-800 mb-2">Địa chỉ cửa hàng *</label>
                        <div class="relative flex gap-2">
                            <div class="flex-1 relative">
                                <input type="text" id="shopAddress" placeholder="Số nhà, đường, phường/xã, quận/huyện, thành phố"
                                       autocomplete="off"
                                       class="w-full h-12 px-4 rounded-xl border border-gray-200 bg-gray-50 text-gray-900 focus:bg-white focus:ring-4 focus:ring-orange-100 focus:border-primary outline-none transition-all placeholder:text-gray-400"/>
                                <div id="addressSuggestBox" class="hidden absolute z-20 left-0 right-0 mt-1 bg-white border border-gray-200 rounded-xl shadow-lg max-h-56 overflow-auto"></div>
                            </div>
                            <button type="button" id="searchAddressBtn"
                                    class="h-12 px-4 bg-primary hover:bg-primary-dark text-white rounded-xl font-semibold transition-all whitespace-nowrap">
                                Tìm trên bản đồ
                            </button>
                        </div>
                        <p class="text-xs text-gray-400 mt-2">Gõ địa chỉ để hiện gợi ý ngay, hoặc bấm “Tìm trên bản đồ”, hoặc kéo thả ghim để chỉnh chính xác vị trí.</p>
                        <div id="leafletMap" class="w-full mt-3 border border-gray-200"></div>
                    </div>

                    <!-- Shop phone -->
                    <div>
                        <label class="block text-sm font-semibold text-gray-800 mb-2">Số điện thoại cửa hàng</label>
                        <input type="tel" id="shopPhone" placeholder="Số hotline hiển thị với khách hàng"
                               class="w-full h-12 px-4 rounded-xl border border-gray-200 bg-gray-50 text-gray-900 focus:bg-white focus:ring-4 focus:ring-orange-100 focus:border-primary outline-none transition-all placeholder:text-gray-400"/>
                    </div>

                    <!-- Operating hours -->
                    <div>
                        <label class="block text-sm font-semibold text-gray-800 mb-3">Giờ mở cửa (mặc định)</label>
                        <div class="grid grid-cols-2 gap-3">
                            <div class="p-4 bg-gray-50 rounded-xl border border-gray-200 flex items-center justify-between">
                                <div>
                                    <p class="text-xs text-gray-500 font-medium mb-0.5">Thứ 2 – Thứ 6</p>
                                    <p class="text-sm font-semibold text-gray-800">09:00 – 22:00</p>
                                </div>
                                <span class="material-symbols-outlined text-primary">schedule</span>
                            </div>
                            <div class="p-4 bg-gray-50 rounded-xl border border-gray-200 flex items-center justify-between">
                                <div>
                                    <p class="text-xs text-gray-500 font-medium mb-0.5">Thứ 7 – Chủ nhật</p>
                                    <p class="text-sm font-semibold text-gray-800">09:00 – 22:00</p>
                                </div>
                                <span class="material-symbols-outlined text-primary">schedule</span>
                            </div>
                        </div>
                        <p class="text-xs text-gray-400 mt-2">Bạn có thể chỉnh sửa giờ mở cửa chi tiết sau khi đăng ký.</p>
                    </div>

                    <div id="step2Error" class="hidden text-red-500 text-sm font-medium flex items-center gap-1.5">
                        <span class="material-symbols-outlined text-sm">error</span>
                        <span id="step2ErrorMsg"></span>
                    </div>

                    <div class="flex gap-3">
                        <button type="button" onclick="goStep(1)"
                                class="flex-1 h-14 border border-gray-200 bg-white hover:bg-gray-50 text-gray-700 font-semibold rounded-xl transition-all flex items-center justify-center gap-2">
                            <span class="material-symbols-outlined">arrow_back</span>
                            Quay lại
                        </button>
                        <button type="button" onclick="goStep3()"
                                class="flex-[2] h-14 bg-primary hover:bg-primary-dark text-white font-semibold rounded-xl shadow-lg shadow-orange-200 transition-all flex items-center justify-center gap-2 group">
                            <span>Tiếp tục</span>
                            <span class="material-symbols-outlined group-hover:translate-x-1 transition-transform">arrow_forward</span>
                        </button>
                    </div>
                </div>

                <!-- ===== STEP 3: Giấy tờ pháp lý + Submit ===== -->
                <form id="step3" method="POST" action="${pageContext.request.contextPath}/merchant/register"
                      class="hidden bg-white rounded-2xl shadow-sm border border-gray-200 p-6 md:p-8 space-y-6"
                      onsubmit="return prepareSubmit(this)">

                    <div>
                        <h2 class="text-3xl font-bold text-gray-900">Giấy tờ pháp lý</h2>
                        <p class="text-gray-500 text-sm mt-1">Bước 3 / 3 — Hoàn tất hồ sơ đăng ký</p>
                    </div>

                    <!-- Hidden fields populated by JS before submit -->
                    <input type="hidden" name="ownerName" id="fOwnerName"/>
                    <input type="hidden" name="shopName"  id="fShopName"/>
                    <input type="hidden" name="email"     id="fEmail"/>
                    <input type="hidden" name="phone"     id="fPhone"/>
                    <input type="hidden" name="shopPhone" id="fShopPhone"/>
                    <input type="hidden" name="shopAddress" id="fShopAddress"/>
                    <input type="hidden" name="password"  id="fPassword"/>
                    <input type="hidden" name="businessType" id="fBusinessType"/>
                    <input type="hidden" name="sourcePlatform" id="fSourcePlatform"/>
                    <input type="hidden" name="viaGoogle"   id="fViaGoogle"/>
                    <input type="hidden" name="latitude" id="fLatitude"/>
                    <input type="hidden" name="longitude" id="fLongitude"/>
                    <input type="hidden" name="provinceCode" id="fProvinceCode"/>
                    <input type="hidden" name="provinceName" id="fProvinceName"/>
                    <input type="hidden" name="districtCode" id="fDistrictCode"/>
                    <input type="hidden" name="districtName" id="fDistrictName"/>
                    <input type="hidden" name="wardCode" id="fWardCode"/>
                    <input type="hidden" name="wardName" id="fWardName"/>

                    <!-- Info summary card -->
                    <div class="bg-orange-50 border border-orange-100 rounded-xl p-4 space-y-2">
                        <p class="text-xs font-semibold text-primary uppercase tracking-wider mb-3">Thông tin đã nhập</p>
                        <div class="grid grid-cols-2 gap-x-4 gap-y-1.5 text-sm">
                            <span class="text-gray-500">Chủ cửa hàng</span>
                            <span class="font-semibold text-gray-900 truncate" id="sumOwner">—</span>
                            <span class="text-gray-500">Tên quán</span>
                            <span class="font-semibold text-gray-900 truncate" id="sumShop">—</span>
                            <span class="text-gray-500">Email</span>
                            <span class="font-semibold text-gray-900 truncate" id="sumEmail">—</span>
                            <span class="text-gray-500">Địa chỉ</span>
                            <span class="font-semibold text-gray-900 truncate" id="sumAddr">—</span>
                            <span class="text-gray-500">Nền tảng tham chiếu</span>
                            <span class="font-semibold text-gray-900 truncate" id="sumPlatform">—</span>
                        </div>
                    </div>

                    <!-- Document upload zones -->
                    <div>
                        <label class="block text-sm font-semibold text-gray-800 mb-3">Tài liệu (tùy chọn)</label>
                        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                            <c:forEach items="${docTypes}" var="doc">
                                <!-- dynamic from servlet (optional) -->
                            </c:forEach>
                            <label class="upload-zone flex flex-col items-center justify-center gap-2 border-2 border-dashed border-gray-200 rounded-xl p-6 bg-gray-50 cursor-pointer transition-all">
                                <span class="material-symbols-outlined text-3xl text-gray-400 upload-icon transition-colors">upload_file</span>
                                <span class="text-sm font-semibold text-gray-600">Giấy phép kinh doanh</span>
                                <span class="text-xs text-gray-400">JPG, PNG hoặc PDF</span>
                                <input type="file" accept=".jpg,.jpeg,.png,.pdf" class="hidden"/>
                            </label>
                            <label class="upload-zone flex flex-col items-center justify-center gap-2 border-2 border-dashed border-gray-200 rounded-xl p-6 bg-gray-50 cursor-pointer transition-all">
                                <span class="material-symbols-outlined text-3xl text-gray-400 upload-icon transition-colors">upload_file</span>
                                <span class="text-sm font-semibold text-gray-600">Chứng nhận ATVSTP</span>
                                <span class="text-xs text-gray-400">JPG, PNG hoặc PDF</span>
                                <input type="file" accept=".jpg,.jpeg,.png,.pdf" class="hidden"/>
                            </label>
                            <label class="upload-zone flex flex-col items-center justify-center gap-2 border-2 border-dashed border-gray-200 rounded-xl p-6 bg-gray-50 cursor-pointer transition-all">
                                <span class="material-symbols-outlined text-3xl text-gray-400 upload-icon transition-colors">upload_file</span>
                                <span class="text-sm font-semibold text-gray-600">CCCD / Hộ chiếu</span>
                                <span class="text-xs text-gray-400">JPG, PNG hoặc PDF</span>
                                <input type="file" accept=".jpg,.jpeg,.png,.pdf" class="hidden"/>
                            </label>
                            <label class="upload-zone flex flex-col items-center justify-center gap-2 border-2 border-dashed border-gray-200 rounded-xl p-6 bg-gray-50 cursor-pointer transition-all">
                                <span class="material-symbols-outlined text-3xl text-gray-400 upload-icon transition-colors">upload_file</span>
                                <span class="text-sm font-semibold text-gray-600">Thông tin ngân hàng</span>
                                <span class="text-xs text-gray-400">JPG, PNG hoặc PDF</span>
                                <input type="file" accept=".jpg,.jpeg,.png,.pdf" class="hidden"/>
                            </label>
                        </div>
                        <p class="text-xs text-gray-400 mt-3">Tải lên trong vòng 7 ngày kể từ khi đăng ký nếu chưa có sẵn.</p>
                    </div>

                    <!-- Terms checkbox -->
                    <label class="flex items-start gap-3 cursor-pointer group">
                        <input type="checkbox" id="agreeTerms" required class="mt-0.5 w-4.5 h-4.5 accent-primary cursor-pointer flex-shrink-0"/>
                        <span class="text-sm text-gray-600">
                            Tôi đồng ý với
                            <a href="#" class="text-primary font-semibold hover:underline">Điều khoản dịch vụ</a>
                            và
                            <a href="#" class="text-primary font-semibold hover:underline">Chính sách bảo mật</a>
                            của ClickEat.
                        </span>
                    </label>

                    <div class="flex gap-3">
                        <button type="button" onclick="goStep(2)"
                                class="flex-1 h-14 border border-gray-200 bg-white hover:bg-gray-50 text-gray-700 font-semibold rounded-xl transition-all flex items-center justify-center gap-2">
                            <span class="material-symbols-outlined">arrow_back</span>
                            Quay lại
                        </button>
                        <button type="submit" id="submitBtn"
                                class="flex-[2] h-14 bg-primary hover:bg-primary-dark disabled:opacity-60 text-white font-semibold rounded-xl shadow-lg shadow-orange-200 transition-all flex items-center justify-center gap-2 group">
                            <span class="material-symbols-outlined group-hover:scale-110 transition-transform">send</span>
                            Gửi hồ sơ đăng ký
                        </button>
                    </div>
                </form>

                <!-- ===== SUCCESS SCREEN ===== -->
                <div id="successScreen" class="hidden text-center space-y-6 max-w-md mx-auto py-16">
                    <div class="w-24 h-24 bg-green-100 rounded-full flex items-center justify-center mx-auto">
                        <span class="material-symbols-outlined text-5xl text-green-600" style="font-variation-settings:'FILL' 1,'wght' 400,'GRAD' 0,'opsz' 24">check_circle</span>
                    </div>
                    <div>
                        <h2 class="text-4xl font-bold text-gray-900">Đã nhận hồ sơ!</h2>
                        <p class="text-gray-500 text-lg mt-2">Cảm ơn bạn đã đăng ký. Đội ngũ chúng tôi sẽ xem xét hồ sơ trong vòng 24–48 giờ.</p>
                    </div>
                    <div class="bg-blue-50 border border-blue-100 rounded-xl p-4 text-left space-y-2">
                        <p class="text-sm font-semibold text-blue-800 flex items-center gap-2">
                            <span class="material-symbols-outlined text-base">info</span>
                            Bước tiếp theo
                        </p>
                        <ul class="text-sm text-blue-700 space-y-1 pl-2">
                            <li>• Kiểm tra email để xác nhận tài khoản</li>
                            <li>• Đội ngũ sẽ liên hệ qua số điện thoại đã đăng ký</li>
                            <li>• Sau khi duyệt, bạn có thể đăng nhập và thiết lập cửa hàng</li>
                        </ul>
                    </div>
                    <a href="${pageContext.request.contextPath}/login"
                       class="block w-full h-14 bg-primary hover:bg-primary-dark text-white font-semibold rounded-xl shadow-lg shadow-orange-200 transition-all flex items-center justify-center gap-2">
                        Quay lại Đăng nhập
                    </a>
                </div>

            </div>
        </main>
    </div>

<script>
    // ── Step definitions ────────────────────────────────────────────
    const REGISTER_DRAFT_KEY = 'merchant_register_draft_v1';
    let currentStep = 1;
    const IS_GOOGLE_SIGNUP = ${not empty sessionScope.googleSignup_sub};
    let leafletMap = null;
    let leafletMarker = null;
    let selectedLat = 0;
    let selectedLng = 0;
    let selectedAddressParts = {
        provinceCode: 'N/A', provinceName: 'N/A',
        districtCode: 'N/A', districtName: 'N/A',
        wardCode: 'N/A', wardName: 'N/A'
    };
    let addressSuggestTimer = null;
    let addressSuggestSeq = 0;

    function saveRegisterDraft() {
        try {
            const draft = {
                step: currentStep,
                ownerName: (document.getElementById('ownerName') || {}).value || '',
                shopName: (document.getElementById('shopName') || {}).value || '',
                regEmail: (document.getElementById('regEmail') || {}).value || '',
                regPhone: (document.getElementById('regPhone') || {}).value || '',
                regPassword: (document.getElementById('regPassword') || {}).value || '',
                regConfirm: (document.getElementById('regConfirm') || {}).value || '',
                shopAddress: (document.getElementById('shopAddress') || {}).value || '',
                shopPhone: (document.getElementById('shopPhone') || {}).value || '',
                businessType: (document.getElementById('businessType') || {}).value || '',
                sourcePlatform: (document.getElementById('sourcePlatform') || {}).value || 'NONE',
                agreeTerms: !!((document.getElementById('agreeTerms') || {}).checked),
                selectedLat: selectedLat || 0,
                selectedLng: selectedLng || 0,
                selectedAddressParts: selectedAddressParts
            };
            sessionStorage.setItem(REGISTER_DRAFT_KEY, JSON.stringify(draft));
        } catch (e) {
            // ignore storage errors
        }
    }

    function clearRegisterDraft() {
        try {
            sessionStorage.removeItem(REGISTER_DRAFT_KEY);
        } catch (e) {
            // ignore storage errors
        }
    }

    function restoreRegisterDraft() {
        try {
            const raw = sessionStorage.getItem(REGISTER_DRAFT_KEY);
            if (!raw) return;
            const draft = JSON.parse(raw);
            if (!draft || typeof draft !== 'object') return;

            const setValue = function(id, value) {
                const el = document.getElementById(id);
                if (!el || value === undefined || value === null) return;
                el.value = String(value);
            };

            setValue('ownerName', draft.ownerName);
            setValue('shopName', draft.shopName);
            setValue('regEmail', draft.regEmail);
            setValue('regPhone', draft.regPhone);
            if (!IS_GOOGLE_SIGNUP) {
                setValue('regPassword', draft.regPassword);
                setValue('regConfirm', draft.regConfirm);
            }
            setValue('shopAddress', draft.shopAddress);
            setValue('shopPhone', draft.shopPhone);
            setValue('businessType', draft.businessType);
            setValue('sourcePlatform', draft.sourcePlatform || 'NONE');

            const agreeTerms = document.getElementById('agreeTerms');
            if (agreeTerms) agreeTerms.checked = !!draft.agreeTerms;

            selectedLat = Number(draft.selectedLat || 0);
            selectedLng = Number(draft.selectedLng || 0);
            if (draft.selectedAddressParts && typeof draft.selectedAddressParts === 'object') {
                selectedAddressParts = {
                    provinceCode: draft.selectedAddressParts.provinceCode || 'N/A',
                    provinceName: draft.selectedAddressParts.provinceName || 'N/A',
                    districtCode: draft.selectedAddressParts.districtCode || 'N/A',
                    districtName: draft.selectedAddressParts.districtName || 'N/A',
                    wardCode: draft.selectedAddressParts.wardCode || 'N/A',
                    wardName: draft.selectedAddressParts.wardName || 'N/A'
                };
            }

            if (selectedLat && selectedLng) {
                const shopAddress = (document.getElementById('shopAddress') || {}).value || 'Vị trí đã chọn';
                updateMapMarker(selectedLat, selectedLng, shopAddress, selectedAddressParts);
            }

            const restoredStep = Number(draft.step || 1);
            if (restoredStep >= 1 && restoredStep <= 3) {
                goStep(restoredStep);
                if (restoredStep >= 3) {
                    populateStep3Summary();
                }
            }
        } catch (e) {
            // ignore broken draft
        }
    }

    function bindDraftAutoSave() {
        const ids = [
            'ownerName', 'shopName', 'regEmail', 'regPhone', 'regPassword', 'regConfirm',
            'shopAddress', 'shopPhone', 'businessType', 'sourcePlatform', 'agreeTerms'
        ];
        ids.forEach(function(id) {
            const el = document.getElementById(id);
            if (!el) return;
            const eventName = (el.type === 'checkbox' || el.tagName === 'SELECT') ? 'change' : 'input';
            el.addEventListener(eventName, saveRegisterDraft);
        });
    }

    function populateStep3Summary() {
        const addr = (document.getElementById('shopAddress') || {}).value || '';
        const owner = ((document.getElementById('ownerName') || {}).value || '').trim();
        const shop = ((document.getElementById('shopName') || {}).value || '').trim();
        const email = ((document.getElementById('regEmail') || {}).value || '').trim();

        document.getElementById('sumOwner').textContent = owner || '—';
        document.getElementById('sumShop').textContent = shop || '—';
        document.getElementById('sumEmail').textContent = email || '—';
        document.getElementById('sumAddr').textContent = addr.trim() || '—';

        const platformMap = {
            NONE: 'Chưa có',
            GRABFOOD: 'GrabFood',
            SHOPEEFOOD: 'ShopeeFood',
            OTHER: 'Khác'
        };
        const selectedPlatform = (document.getElementById('sourcePlatform') || {}).value || 'NONE';
        document.getElementById('sumPlatform').textContent = platformMap[selectedPlatform] || 'Chưa có';
    }

    function firstNonEmpty() {
        for (let i = 0; i < arguments.length; i++) {
            const value = String(arguments[i] || '').trim();
            if (value) return value;
        }
        return '';
    }

    function normalizeAddressToken(value) {
        return String(value || '')
            .replace(/\s+/g, ' ')
            .replace(/^(Vietnam|Viet Nam|Việt Nam)$/i, '')
            .trim();
    }

    function makeFallbackCode(name) {
        const normalized = normalizeAddressToken(name)
            .normalize('NFD')
            .replace(/[\u0300-\u036f]/g, '')
            .replace(/đ/g, 'd')
            .replace(/Đ/g, 'D')
            .replace(/[^A-Za-z0-9]+/g, '_')
            .replace(/^_+|_+$/g, '')
            .toUpperCase();
        return normalized || 'N/A';
    }

    function parseDisplayNameFallback(displayName) {
        const parts = String(displayName || '')
            .split(',')
            .map(normalizeAddressToken)
            .filter(Boolean)
            .filter(function(part) { return !/^(Vietnam|Viet Nam|Việt Nam)$/i.test(part); });

        if (parts.length === 0) {
            return { provinceName: 'N/A', districtName: 'N/A', wardName: 'N/A' };
        }

        const lowerParts = parts.map(function(part) { return part.toLowerCase(); });

        const wardIndex = lowerParts.findIndex(function(part) {
            return /\b(ward|phường|xã|xã|thị trấn|thị trấn|quarter|neighbourhood|village|hamlet)\b/.test(part);
        });

        const districtIndex = lowerParts.findIndex(function(part) {
            return /\b(district|quận|huyện|thị xã|city district|city_district|county)\b/.test(part);
        });

        let provinceName = parts.length >= 1 ? parts[parts.length - 1] : 'N/A';
        let districtName = districtIndex >= 0 ? parts[districtIndex] : (parts.length >= 2 ? parts[parts.length - 2] : 'N/A');
        let wardName = wardIndex >= 0 ? parts[wardIndex] : (parts.length >= 3 ? parts[parts.length - 3] : 'N/A');

        if (districtName === provinceName) {
            districtName = 'N/A';
        }
        if (wardName === districtName || wardName === provinceName) {
            wardName = 'N/A';
        }

        return {
            provinceName: normalizeAddressToken(provinceName) || 'N/A',
            districtName: normalizeAddressToken(districtName) || 'N/A',
            wardName: normalizeAddressToken(wardName) || 'N/A'
        };
    }

    function extractAddressParts(item) {
        const address = item && item.address ? item.address : {};
        const fallback = parseDisplayNameFallback(item && item.display_name ? item.display_name : '');

        const provinceName = normalizeAddressToken(firstNonEmpty(
            address.state,
            address.province,
            address.region,
            address.state_district,
            address.city,
            fallback.provinceName,
            'N/A'
        )) || 'N/A';

        const districtName = normalizeAddressToken(firstNonEmpty(
            address.city_district,
            address.district,
            address.county,
            address.municipality,
            address.town,
            address.suburb,
            fallback.districtName,
            'N/A'
        )) || 'N/A';

        const wardName = normalizeAddressToken(firstNonEmpty(
            address.city_block,
            address.quarter,
            address.neighbourhood,
            address.village,
            address.hamlet,
            address.suburb,
            fallback.wardName,
            'N/A'
        )) || 'N/A';

        return {
            provinceCode: makeFallbackCode(provinceName),
            provinceName: provinceName,
            districtCode: makeFallbackCode(districtName),
            districtName: districtName,
            wardCode: makeFallbackCode(wardName),
            wardName: wardName
        };
    }

    // ── Check for server-side success (redirect after POST) ─────────
    <c:if test="${param.success == 'true'}">
    window.addEventListener('DOMContentLoaded', function() { showSuccess(); });
    </c:if>

    // ── Sidebar render ───────────────────────────────────────────────
    function renderSidebar() {
        const steps = [
            { label: 'Thông tin cơ bản', icon: 'person' },
            { label: 'Chi tiết cửa hàng', icon: 'storefront' },
            { label: 'Giấy tờ pháp lý', icon: 'description' },
        ];
        const el = document.getElementById('sidebarSteps');
        el.innerHTML = steps.map((s, i) => {
            const n = i + 1;
            const active = n === currentStep;
            const done   = n < currentStep;
            const baseClass = 'flex items-center gap-4 p-3 rounded-xl transition-all';
            const wrapClass = active ? baseClass + ' bg-primary/10 border border-primary/20' : done ? baseClass + ' text-green-700' : baseClass + ' text-gray-400';
            const iconWrap  = active ? 'bg-primary text-white' : done ? 'bg-green-100 text-green-600' : 'bg-gray-100 text-gray-400';
            const iconName  = done ? 'check' : s.icon;
            const labelClass = active ? 'text-sm font-semibold text-gray-900' : done ? 'text-sm font-semibold text-green-700' : 'text-sm font-medium';
            return '<div class="' + wrapClass + '">'
                + '<div class="w-8 h-8 rounded-lg flex items-center justify-center flex-shrink-0 ' + iconWrap + '">'
                + '<span class="material-symbols-outlined text-sm">' + iconName + '</span>'
                + '</div>'
                + '<p class="' + labelClass + '">' + s.label + '</p>'
                + '</div>';
        }).join('');
    }

    // ── Mobile progress bars ─────────────────────────────────────────
    function updateMobileBars() {
        [1, 2, 3].forEach(n => {
            const bar = document.getElementById('mob-step' + n + '-bar');
            if (bar) bar.className = 'h-1.5 flex-1 rounded-full transition-all ' + (n <= currentStep ? 'bg-primary' : 'bg-gray-200');
        });
    }

    // ── Navigate to a step ───────────────────────────────────────────
    function goStep(n) {
        ['step1', 'step2', 'step3', 'successScreen'].forEach(id => {
            document.getElementById(id).classList.add('hidden');
        });
        const el = document.getElementById('step' + n);
        if (el) {
            el.classList.remove('hidden');
            el.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }
        currentStep = n;
        saveRegisterDraft();
        renderSidebar();
        updateMobileBars();
        if (n === 2 && leafletMap) {
            setTimeout(function() { leafletMap.invalidateSize(); }, 80);
        }
    }

    // ── Step 1 validation ────────────────────────────────────────────
    function goStep2() {
        const ownerName = document.getElementById('ownerName').value.trim();
        const shopName  = document.getElementById('shopName').value.trim();
        const email     = document.getElementById('regEmail').value.trim();
        const phone     = document.getElementById('regPhone').value.trim();
        const pwEl      = document.getElementById('regPassword');
        const cnfEl     = document.getElementById('regConfirm');
        const password  = pwEl  ? pwEl.value  : '';
        const confirm   = cnfEl ? cnfEl.value : '';
        const errEl     = document.getElementById('step1Error');
        const errMsg    = document.getElementById('step1ErrorMsg');

        const showErr = (msg) => {
            errMsg.textContent = msg;
            errEl.classList.remove('hidden');
        };
        errEl.classList.add('hidden');

        if (!ownerName)    return showErr('Vui lòng nhập họ tên chủ cửa hàng.');
        if (!shopName)     return showErr('Vui lòng nhập tên nhà hàng / quán ăn.');
        if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) return showErr('Vui lòng nhập email hợp lệ.');
        if (!phone || phone.length < 9)  return showErr('Vui lòng nhập số điện thoại hợp lệ.');
        if (!IS_GOOGLE_SIGNUP) {
            if (!password || password.length < 6) return showErr('Mật khẩu phải có ít nhất 6 ký tự.');
            if (password !== confirm) return showErr('Mật khẩu xác nhận không khớp.');
        }

        goStep(2);
        // Pre-fill shop phone with owner phone as default
        const spEl = document.getElementById('shopPhone');
        if (!spEl.value) spEl.value = phone;
    }

    // ── Step 2 validation ────────────────────────────────────────────
    async function goStep3() {
        const addr   = document.getElementById('shopAddress').value.trim();
        const errEl  = document.getElementById('step2Error');
        const errMsg = document.getElementById('step2ErrorMsg');

        errEl.classList.add('hidden');
        if (!addr) {
            errMsg.textContent = 'Vui lòng nhập địa chỉ cửa hàng.';
            errEl.classList.remove('hidden');
            return;
        }

        if (!selectedLat || !selectedLng || selectedAddressParts.provinceName === 'N/A') {
            try {
                const fallbackResults = await fetchAddressResults(addr, 1);
                if (Array.isArray(fallbackResults) && fallbackResults.length > 0) {
                    const first = fallbackResults[0];
                    const lat = Number.parseFloat(first.lat);
                    const lng = Number.parseFloat(first.lon);
                    if (!Number.isNaN(lat) && !Number.isNaN(lng)) {
                        selectedAddressParts = extractAddressParts(first);
                        updateMapMarker(lat, lng, first.display_name || addr, selectedAddressParts);
                    }
                }
            } catch (e) {
                // giữ nguyên dữ liệu đã nhập tay
            }
        }

        // Populate summary
        populateStep3Summary();

        goStep(3);
    }

    async function searchAddressOnMap() {
        const input = document.getElementById('shopAddress');
        const query = input.value.trim();
        if (!query) return;

        const btn = document.getElementById('searchAddressBtn');
        const prev = btn.textContent;
        btn.disabled = true;
        btn.textContent = 'Đang tìm...';

        try {
            const data = await fetchAddressResults(query, 1);
            if (!Array.isArray(data) || data.length === 0) {
                alert('Không tìm thấy địa chỉ phù hợp. Bạn thử nhập chi tiết hơn nhé.');
                return;
            }
            const first = data[0];
            const lat = parseFloat(first.lat);
            const lng = parseFloat(first.lon);
            if (Number.isNaN(lat) || Number.isNaN(lng)) {
                alert('Không lấy được tọa độ từ kết quả tìm kiếm.');
                return;
            }
            selectedLat = lat;
            selectedLng = lng;
            selectedAddressParts = extractAddressParts(first);
            if (first.display_name) {
                input.value = first.display_name;
            }
            updateMapMarker(lat, lng, input.value || query, selectedAddressParts);
        } catch (e) {
            alert('Không thể tìm địa chỉ lúc này. Vui lòng thử lại.');
        } finally {
            btn.disabled = false;
            btn.textContent = prev;
        }
    }

    async function fetchAddressResults(query, limit) {
        const url = 'https://nominatim.openstreetmap.org/search?format=jsonv2&addressdetails=1&limit=' + encodeURIComponent(String(limit || 1)) + '&q=' + encodeURIComponent(query);
        const res = await fetch(url, {
            headers: { 'Accept': 'application/json' }
        });
        return res.json();
    }

    function hideAddressSuggestions() {
        const box = document.getElementById('addressSuggestBox');
        if (!box) return;
        box.classList.add('hidden');
        box.innerHTML = '';
    }

    function renderAddressSuggestions(items) {
        const box = document.getElementById('addressSuggestBox');
        if (!box) return;
        if (!Array.isArray(items) || items.length === 0) {
            hideAddressSuggestions();
            return;
        }

        box.innerHTML = items.map(function(item, index) {
            const lat = Number.parseFloat(item.lat);
            const lng = Number.parseFloat(item.lon);
            if (Number.isNaN(lat) || Number.isNaN(lng)) return '';
            const label = (item.display_name || '').replace(/"/g, '&quot;');
            return '<button type="button" class="w-full text-left px-3 py-2.5 text-sm text-gray-700 hover:bg-orange-50 border-b border-gray-100 last:border-b-0" '
                + 'data-idx="' + index + '" data-lat="' + lat + '" data-lng="' + lng + '" data-label="' + label + '">'
                + label
                + '</button>';
        }).join('');

        if (!box.innerHTML.trim()) {
            hideAddressSuggestions();
            return;
        }

        box.classList.remove('hidden');
        box.querySelectorAll('button[data-lat][data-lng]').forEach(function(btn) {
            btn.addEventListener('click', function() {
                const lat = Number.parseFloat(btn.getAttribute('data-lat'));
                const lng = Number.parseFloat(btn.getAttribute('data-lng'));
                const label = btn.getAttribute('data-label') || '';
                const index = Number.parseInt(btn.getAttribute('data-idx'), 10);
                const rawItem = Number.isNaN(index) ? null : items[index];
                if (Number.isNaN(lat) || Number.isNaN(lng)) return;
                const addressInput = document.getElementById('shopAddress');
                addressInput.value = label;
                selectedAddressParts = extractAddressParts(rawItem);
                updateMapMarker(lat, lng, label, selectedAddressParts);
                hideAddressSuggestions();
            });
        });
    }

    function bindAddressAutocomplete() {
        const input = document.getElementById('shopAddress');
        if (!input) return;

        input.addEventListener('input', function() {
            const query = input.value.trim();
            if (addressSuggestTimer) clearTimeout(addressSuggestTimer);
            if (query.length < 3) {
                hideAddressSuggestions();
                return;
            }

            addressSuggestTimer = setTimeout(async function() {
                const seq = ++addressSuggestSeq;
                try {
                    const results = await fetchAddressResults(query, 5);
                    if (seq !== addressSuggestSeq) return;
                    renderAddressSuggestions(results);
                } catch (e) {
                    if (seq !== addressSuggestSeq) return;
                    hideAddressSuggestions();
                }
            }, 350);
        });

        input.addEventListener('focus', function() {
            if (input.value.trim().length >= 3) {
                input.dispatchEvent(new Event('input'));
            }
        });

        input.addEventListener('blur', function() {
            setTimeout(hideAddressSuggestions, 150);
        });
    }

    function updateMapMarker(lat, lng, label, addressParts) {
        if (!leafletMap) return;
        if (!leafletMarker) {
            leafletMarker = L.marker([lat, lng], { draggable: true }).addTo(leafletMap);
            leafletMarker.on('dragend', function(evt) {
                const point = evt.target.getLatLng();
                selectedLat = point.lat;
                selectedLng = point.lng;
            });
        } else {
            leafletMarker.setLatLng([lat, lng]);
        }
        selectedLat = lat;
        selectedLng = lng;
        if (addressParts && typeof addressParts === 'object') {
            selectedAddressParts = {
                provinceCode: addressParts.provinceCode || 'N/A',
                provinceName: addressParts.provinceName || 'N/A',
                districtCode: addressParts.districtCode || 'N/A',
                districtName: addressParts.districtName || 'N/A',
                wardCode: addressParts.wardCode || 'N/A',
                wardName: addressParts.wardName || 'N/A'
            };
        }
        leafletMap.setView([lat, lng], 16);
        if (label) {
            leafletMarker.bindPopup(label).openPopup();
        }
    }

    function initLeafletMap() {
        const mapEl = document.getElementById('leafletMap');
        if (!mapEl || leafletMap) return;

        leafletMap = L.map('leafletMap');
        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
            maxZoom: 19,
            attribution: '&copy; OpenStreetMap contributors'
        }).addTo(leafletMap);

        leafletMap.setView([10.762622, 106.660172], 13);
        setTimeout(function() { leafletMap.invalidateSize(); }, 50);

        leafletMap.on('click', function(e) {
            updateMapMarker(e.latlng.lat, e.latlng.lng, 'Vị trí đã chọn');
        });

        const searchBtn = document.getElementById('searchAddressBtn');
        const addressInput = document.getElementById('shopAddress');
        if (searchBtn) {
            searchBtn.addEventListener('click', searchAddressOnMap);
        }
        if (addressInput) {
            addressInput.addEventListener('keydown', function(e) {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    searchAddressOnMap();
                }
            });
        }
        bindAddressAutocomplete();
    }

    // ── Prepare hidden fields before final submit ────────────────────
    function prepareSubmit(form) {
        if (!document.getElementById('agreeTerms').checked) {
            alert('Vui lòng đồng ý với điều khoản dịch vụ để tiếp tục.');
            return false;
        }
        document.getElementById('fOwnerName').value    = document.getElementById('ownerName').value.trim();
        document.getElementById('fShopName').value     = document.getElementById('shopName').value.trim();
        document.getElementById('fEmail').value        = document.getElementById('regEmail').value.trim();
        document.getElementById('fPhone').value        = document.getElementById('regPhone').value.trim();
        document.getElementById('fShopPhone').value    = document.getElementById('shopPhone').value.trim();
        document.getElementById('fShopAddress').value  = document.getElementById('shopAddress').value.trim();
        const pwInput = document.getElementById('regPassword');
        document.getElementById('fPassword').value     = pwInput ? pwInput.value : '';
        document.getElementById('fBusinessType').value = document.getElementById('businessType').value;
        document.getElementById('fSourcePlatform').value = document.getElementById('sourcePlatform').value;
        document.getElementById('fViaGoogle').value    = IS_GOOGLE_SIGNUP ? 'true' : '';
        document.getElementById('fLatitude').value     = String(selectedLat || 0);
        document.getElementById('fLongitude').value    = String(selectedLng || 0);
        document.getElementById('fProvinceCode').value = selectedAddressParts.provinceCode || 'N/A';
        document.getElementById('fProvinceName').value = selectedAddressParts.provinceName || 'N/A';
        document.getElementById('fDistrictCode').value = selectedAddressParts.districtCode || 'N/A';
        document.getElementById('fDistrictName').value = selectedAddressParts.districtName || 'N/A';
        document.getElementById('fWardCode').value     = selectedAddressParts.wardCode || 'N/A';
        document.getElementById('fWardName').value     = selectedAddressParts.wardName || 'N/A';

        // Show loading state
        const btn = document.getElementById('submitBtn');
        btn.disabled = true;
        btn.innerHTML = '<span class="material-symbols-outlined animate-spin text-xl">progress_activity</span><span>Đang gửi...</span>';
        saveRegisterDraft();
        return true;
    }

    // ── Show success screen ──────────────────────────────────────────
    function showSuccess() {
        clearRegisterDraft();
        ['step1','step2','step3'].forEach(id => document.getElementById(id).classList.add('hidden'));
        document.getElementById('successScreen').classList.remove('hidden');
        currentStep = 4;
        renderSidebar();
        updateMobileBars();
    }

    // ── Password toggle ──────────────────────────────────────────────
    function togglePw(inputId, eyeId) {
        const input = document.getElementById(inputId);
        const eye   = document.getElementById(eyeId);
        if (input.type === 'password') {
            input.type = 'text';
            eye.textContent = 'visibility_off';
        } else {
            input.type = 'password';
            eye.textContent = 'visibility';
        }
    }

    // ── File upload feedback ─────────────────────────────────────────
    document.querySelectorAll('.upload-zone input[type=file]').forEach(function(inp) {
        inp.addEventListener('change', function() {
            const zone  = inp.closest('.upload-zone');
            const label = zone.querySelector('span.text-sm');
            const icon  = zone.querySelector('.upload-icon');
            if (inp.files && inp.files[0]) {
                label.textContent = inp.files[0].name;
                icon.textContent  = 'check_circle';
                icon.style.color  = '#22c55e';
                zone.style.borderColor = '#22c55e';
                zone.style.background  = '#f0fdf4';
            }
        });
    });

    // ── Init ─────────────────────────────────────────────────────────
    renderSidebar();
    updateMobileBars();
    initLeafletMap();
    bindDraftAutoSave();
    if (!new URLSearchParams(window.location.search).has('success')) {
        restoreRegisterDraft();
    }

    // ── Google Sign-In (Step 1 quick-register) ────────────────────
    function handleGoogleSignIn(response) {
        document.getElementById('googleCredential').value = response.credential;
        document.getElementById('googleAuthForm').submit();
    }

    window.addEventListener('load', function () {
        const clientId = '${initParam["google.client.id"]}';
        if (!clientId || clientId.startsWith('YOUR_')) return; // not configured yet
        google.accounts.id.initialize({
            client_id: clientId,
            callback: handleGoogleSignIn,
            ux_mode: 'popup'
        });
        google.accounts.id.renderButton(
            document.getElementById('googleBtnContainer'),
            { theme: 'outline', size: 'large', width: 480, text: 'signup_with', shape: 'rectangular', logo_alignment: 'left' }
        );
    });
</script>
</body>
</html>
