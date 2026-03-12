<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>ClickEat Admin - Control Panel</title>
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
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800;900&display=swap" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        <style>body { font-family: 'Inter', sans-serif; }</style>
    </head>
    <body class="bg-gray-50 flex h-screen overflow-hidden text-gray-800">

        <aside class="w-64 bg-white text-gray-800 flex flex-col justify-between hidden md:flex z-20 shadow-xl border-r">
            <div>
                <div class="h-20 flex items-center px-6 border-b border-gray-200">
                    <div class="w-10 h-10 bg-orange-500 rounded-xl flex items-center justify-center mr-3 shadow-lg">
                        <i class="fa-solid fa-shield-halved text-white text-lg"></i>
                    </div>
                    <div>
                        <h1 class="font-black text-xl text-gray-900 leading-tight">ClickEat</h1>
                        <p class="text-xs font-bold text-orange-400 tracking-widest uppercase">Admin Panel</p>
                    </div>
                </div>

                <nav class="p-4 space-y-2 mt-4">
                    <button onclick="switchTab('overview')" id="nav-overview" class="w-full flex items-center gap-3 px-4 py-3 bg-orange-500/20 text-orange-400 rounded-xl font-bold transition-colors">
                        <i class="fa-solid fa-chart-line w-5"></i> Báo cáo tổng quan
                    </button>
                    <button onclick="switchTab('kyc')" id="nav-kyc" class="w-full flex items-center justify-between px-4 py-3 text-slate-400 hover:bg-slate-800 hover:text-white rounded-xl font-medium transition-colors">
                        <div class="flex items-center gap-3"><i class="fa-solid fa-id-card-clip w-5"></i> Duyệt Quán Ăn</div>
                        <c:if test="${not empty pendingKYCs}">
                            <span class="bg-red-500 text-white text-xs font-bold px-2 py-0.5 rounded-full">${pendingKYCs.size()}</span>
                        </c:if>
                    </button>
                    <button onclick="switchTab('finance')" id="nav-finance" class="w-full flex items-center justify-between px-4 py-3 text-slate-400 hover:bg-slate-800 hover:text-white rounded-xl font-medium transition-colors">
                        <div class="flex items-center gap-3"><i class="fa-solid fa-money-bill-transfer w-5"></i> Quản lý Rút tiền</div>
                        <c:if test="${not empty pendingWithdrawals}">
                            <span class="bg-red-500 text-white text-xs font-bold px-2 py-0.5 rounded-full">${pendingWithdrawals.size()}</span>
                        </c:if>
                    </button>
                    <button onclick="switchTab('dispute')" id="nav-dispute" class="w-full flex items-center justify-between px-4 py-3 text-slate-400 hover:bg-slate-800 hover:text-white rounded-xl font-medium transition-colors">
                        <div class="flex items-center gap-3"><i class="fa-solid fa-scale-balanced w-5"></i> Giải quyết Sự cố</div>
                        <c:if test="${not empty pendingIssues}">
                            <span class="bg-red-500 text-white text-xs font-bold px-2 py-0.5 rounded-full">${pendingIssues.size()}</span>
                        </c:if>
                    </button>
                    <button onclick="switchTab('users')" id="nav-users" class="w-full flex items-center gap-3 px-4 py-3 text-slate-400 hover:bg-slate-800 hover:text-white rounded-xl font-medium transition-colors">
                        <i class="fa-solid fa-users-gear w-5"></i> Quản lý Người dùng
                    </button>
                </nav>
            </div>
            <div class="p-6 border-t border-gray-800">
                <a href="${pageContext.request.contextPath}/logout" class="flex items-center gap-3 text-slate-400 hover:text-red-400 transition">
                    <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                </a>
            </div>
        </aside>

        <main class="flex-1 flex flex-col h-screen overflow-y-auto relative">
            <header class="h-20 bg-white flex items-center justify-between px-8 border-b border-gray-200 sticky top-0 z-10 shadow-sm">
                <h2 id="header-title" class="text-2xl font-bold text-gray-900">Báo cáo tổng quan</h2>
                <div class="flex items-center gap-4">
                    <div class="text-right">
                        <p class="text-sm font-bold text-gray-900">Super Admin</p>
                        <p class="text-xs text-green-500 font-bold"><i class="fa-solid fa-circle text-[8px] mr-1"></i>System Online</p>
                    </div>
                    <div class="w-10 h-10 bg-orange-100 rounded-full flex items-center justify-center overflow-hidden border-2 border-orange-500 text-orange-600 shadow-sm">
                        <c:choose>
                            <c:when test="${not empty sessionScope.account.avatarUrl}">
                                <img src="${sessionScope.account.avatarUrl}" class="w-full h-full object-cover">
                            </c:when>
                            <c:otherwise>
                                <i class="fa-solid fa-user-tie"></i>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </header>

            <div class="p-8 relative">

                <div id="tab-overview" class="block">
                    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
                        <div class="bg-gradient-to-br from-green-500 to-emerald-600 rounded-2xl p-6 text-white shadow-lg relative overflow-hidden">
                            <i class="fa-solid fa-sack-dollar absolute -right-4 -bottom-4 text-7xl text-white/20"></i>
                            <p class="font-bold text-green-100 mb-1">Tổng Giao Dịch (GMV)</p>
                            <h3 class="text-3xl font-black tracking-tight"><fmt:formatNumber value="${totalGMV}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></h3>
                        </div>
                        <div class="bg-white rounded-2xl p-6 border border-gray-200 shadow-sm flex items-center justify-between">
                            <div>
                                <p class="text-gray-500 font-bold text-sm mb-1">Tổng Đơn Hàng</p>
                                <h3 class="text-3xl font-black text-gray-900">${totalOrders}</h3>
                            </div>
                            <div class="w-14 h-14 bg-blue-50 text-blue-500 rounded-xl flex items-center justify-center text-2xl"><i class="fa-solid fa-boxes-stacked"></i></div>
                        </div>
                        <div class="bg-white rounded-2xl p-6 border border-gray-200 shadow-sm flex items-center justify-between">
                            <div>
                                <p class="text-gray-500 font-bold text-sm mb-1">Khách Hàng</p>
                                <h3 class="text-3xl font-black text-gray-900">${totalCustomers}</h3>
                            </div>
                            <div class="w-14 h-14 bg-purple-50 text-purple-500 rounded-xl flex items-center justify-center text-2xl"><i class="fa-solid fa-users"></i></div>
                        </div>
                        <div class="bg-white rounded-2xl p-6 border border-gray-200 shadow-sm flex items-center justify-between">
                            <div>
                                <p class="text-gray-500 font-bold text-sm mb-1">Đối Tác (Quán & Xe)</p>
                                <h3 class="text-3xl font-black text-gray-900">${totalMerchants + totalShippers}</h3>
                            </div>
                            <div class="w-14 h-14 bg-orange-50 text-orange-500 rounded-xl flex items-center justify-center text-2xl"><i class="fa-solid fa-handshake"></i></div>
                        </div>
                    </div>

                    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6 mb-8">
                        <div class="lg:col-span-2 bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
                            <h3 class="font-bold text-gray-900 mb-6 flex items-center gap-2">
                                <i class="fa-solid fa-chart-line text-blue-500"></i> BIỂU ĐỒ DOANH THU 7 NGÀY (GMV)
                            </h3>
                            <div class="relative h-72 w-full"><canvas id="adminRevenueChart"></canvas></div>
                        </div>

                        <div class="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
                            <h3 class="font-bold text-gray-900 mb-6 flex items-center gap-2">
                                <i class="fa-solid fa-chart-pie text-orange-500"></i> TRẠNG THÁI ĐƠN HÀNG
                            </h3>
                            <div class="relative h-72 w-full"><canvas id="adminStatusChart"></canvas></div>
                        </div>
                    </div>
                </div>

                <div id="tab-kyc" class="hidden">
                    <div class="mb-6 flex justify-between items-end">
                        <div>
                            <h3 class="text-xl font-bold text-gray-900 flex items-center gap-2">
                                <i class="fa-solid fa-id-card-clip text-orange-500"></i> Hồ sơ chờ duyệt (KYC)
                            </h3>
                            <p class="text-sm text-gray-500 mt-1">Kiểm tra Giấy phép kinh doanh trước khi cho phép quán hoạt động.</p>
                        </div>
                    </div>

                    <c:if test="${empty pendingKYCs}">
                        <div class="bg-white rounded-2xl border border-dashed border-gray-300 p-12 text-center">
                            <i class="fa-solid fa-clipboard-check text-5xl text-green-300 mb-4"></i>
                            <h3 class="text-lg font-bold text-gray-900">Không có hồ sơ nào</h3>
                            <p class="text-gray-500">Tất cả các đối tác mới đều đã được xử lý.</p>
                        </div>
                    </c:if>

                    <div class="grid grid-cols-1 gap-6">
                        <c:forEach var="kyc" items="${pendingKYCs}">
                            <div class="bg-white rounded-2xl border border-gray-200 shadow-sm overflow-hidden flex flex-col md:flex-row">
                                <div class="p-6 flex-1">
                                    <div class="flex items-center gap-3 mb-4">
                                        <span class="bg-yellow-100 text-yellow-700 px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wider">
                                            <i class="fa-solid fa-hourglass-half mr-1"></i> Chờ duyệt
                                        </span>
                                        <span class="text-sm text-gray-400 font-medium">Nộp lúc: <fmt:formatDate value="${kyc.submittedAt}" pattern="dd/MM/yyyy HH:mm"/></span>
                                    </div>
                                    <h4 class="text-2xl font-black text-gray-900 mb-1">${kyc.shopName}</h4>
                                    <p class="text-gray-500 font-medium mb-4"><i class="fa-solid fa-phone w-5 text-gray-400"></i> ${kyc.shopPhone}</p>

                                    <div class="bg-gray-50 rounded-xl p-4 border border-gray-100">
                                        <p class="text-sm text-gray-500 mb-1">Tên Hộ Kinh Doanh / Doanh nghiệp:</p>
                                        <p class="font-bold text-gray-900 mb-3">${kyc.businessName}</p>
                                        <p class="text-sm text-gray-500 mb-1">Mã số thuế / GPKD:</p>
                                        <p class="font-bold text-gray-900">${not empty kyc.businessLicenseNumber ? kyc.businessLicenseNumber : '<span class="text-red-400 italic">Không cung cấp</span>'}</p>
                                    </div>
                                </div>

                                <div class="bg-gray-50 w-full md:w-80 p-6 border-l border-gray-200 flex flex-col justify-center gap-3">
                                    <a href="${kyc.documentUrl}" target="_blank" class="w-full bg-white border-2 border-orange-500 text-orange-600 font-bold py-3 rounded-xl text-center hover:bg-orange-50 transition shadow-sm flex items-center justify-center gap-2">
                                        <i class="fa-solid fa-file-pdf"></i> Xem Giấy Tờ
                                    </a>
                                    <form action="${pageContext.request.contextPath}/admin/dashboard" method="POST" class="w-full">
                                        <input type="hidden" name="action" value="APPROVE_KYC">
                                        <input type="hidden" name="kycId" value="${kyc.id}">
                                        <input type="hidden" name="merchantId" value="${kyc.merchantUserId}">
                                        <button type="submit" onclick="confirmAction(event, 'Bạn chắc chắn muốn DUYỆT quán này?', this);" class="w-full bg-green-500 hover:bg-green-600 text-white font-bold py-3 rounded-xl text-center transition shadow-md flex items-center justify-center gap-2">
                                            <i class="fa-solid fa-check"></i> Duyệt Cho Phép Bán
                                        </button>
                                    </form>
                                    <button onclick="openRejectModal(${kyc.id}, ${kyc.merchantUserId})" class="w-full bg-red-100 hover:bg-red-200 text-red-600 font-bold py-3 rounded-xl text-center transition flex items-center justify-center gap-2">
                                        <i class="fa-solid fa-xmark"></i> Từ Chối Hồ Sơ
                                    </button>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <div id="tab-finance" class="hidden">
                    <div class="mb-6 flex justify-between items-end">
                        <div>
                            <h3 class="text-xl font-bold text-gray-900 flex items-center gap-2">
                                <i class="fa-solid fa-money-bill-transfer text-orange-500"></i> Lệnh Rút Tiền Chờ Xử Lý
                            </h3>
                            <p class="text-sm text-gray-500 mt-1">Admin vui lòng chuyển khoản thực tế trước khi bấm Duyệt trên hệ thống.</p>
                        </div>
                    </div>

                    <c:if test="${empty pendingWithdrawals}">
                        <div class="bg-white rounded-2xl border border-dashed border-gray-300 p-12 text-center">
                            <i class="fa-solid fa-money-bill-wave text-5xl text-green-300 mb-4"></i>
                            <h3 class="text-lg font-bold text-gray-900">Không có lệnh rút tiền nào</h3>
                            <p class="text-gray-500">Hệ thống đang ổn định.</p>
                        </div>
                    </c:if>

                    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                        <c:forEach var="req" items="${pendingWithdrawals}">
                            <div class="bg-white rounded-2xl border border-gray-200 shadow-sm p-6 relative overflow-hidden">
                                <div class="absolute left-0 top-0 bottom-0 w-1.5 bg-orange-500"></div>

                                <div class="flex justify-between items-start mb-4 border-b border-gray-100 pb-4 pl-3">
                                    <div>
                                        <h4 class="font-bold text-lg text-gray-900"><i class="fa-solid fa-motorcycle text-orange-500 mr-1"></i> ${req.shipperName}</h4>
                                        <p class="text-sm text-gray-500 mt-1"><i class="fa-solid fa-phone mr-1"></i> ${req.shipperPhone}</p>
                                    </div>
                                    <div class="text-right">
                                        <p class="text-xs font-bold text-gray-400 mb-1">Số tiền rút:</p>
                                        <p class="text-2xl font-black text-orange-500"><fmt:formatNumber value="${req.amount}" type="currency" currencySymbol="đ" maxFractionDigits="0"/></p>
                                    </div>
                                </div>

                                <div class="bg-blue-50/50 rounded-xl p-4 border border-blue-100 mb-4 ml-3">
                                    <p class="text-xs font-bold text-blue-500 uppercase tracking-wider mb-2">Thông tin chuyển khoản</p>
                                    <div class="flex justify-between items-center mb-1">
                                        <span class="text-sm text-gray-500">Ngân hàng:</span>
                                        <span class="font-bold text-gray-900">${req.bankName}</span>
                                    </div>
                                    <div class="flex justify-between items-center">
                                        <span class="text-sm text-gray-500">Số tài khoản:</span>
                                        <span class="font-bold text-gray-900 text-lg tracking-wider">${req.bankAccountNumber}</span>
                                    </div>
                                </div>

                                <div class="flex gap-3 ml-3">
                                    <form action="${pageContext.request.contextPath}/admin/dashboard" method="POST" class="flex-1">
                                        <input type="hidden" name="action" value="APPROVE_WITHDRAW">
                                        <input type="hidden" name="requestId" value="${req.id}">
                                        <input type="hidden" name="shipperId" value="${req.shipperUserId}">
                                        <input type="hidden" name="amount" value="${req.amount}">
                                        <button type="submit" onclick="confirmAction(event, 'Bạn XÁC NHẬN đã chuyển khoản và muốn trừ tiền ví tài xế?', this);" class="w-full bg-green-500 hover:bg-green-600 text-white font-bold py-2.5 rounded-xl transition flex items-center justify-center gap-2">
                                            <i class="fa-solid fa-check"></i> Đã Chuyển Tiền
                                        </button>
                                    </form>
                                    <form action="${pageContext.request.contextPath}/admin/dashboard" method="POST" class="w-1/3">
                                        <input type="hidden" name="action" value="REJECT_WITHDRAW">
                                        <input type="hidden" name="requestId" value="${req.id}">
                                        <button type="submit" onclick="confirmAction(event, 'Từ chối lệnh rút tiền này?', this);" class="w-full bg-red-100 hover:bg-red-200 text-red-600 font-bold py-2.5 rounded-xl transition flex items-center justify-center gap-2">
                                            <i class="fa-solid fa-xmark"></i> Hủy
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <div id="tab-dispute" class="hidden">
                    <div class="mb-6 flex justify-between items-end">
                        <div>
                            <h3 class="text-xl font-bold text-gray-900 flex items-center gap-2">
                                <i class="fa-solid fa-scale-balanced text-orange-500"></i> Sự cố cần xử lý
                            </h3>
                            <p class="text-sm text-gray-500 mt-1">Hỗ trợ đối tác giải quyết các vấn đề trên đường giao hàng.</p>
                        </div>
                    </div>

                    <c:if test="${empty pendingIssues}">
                        <div class="bg-white rounded-2xl border border-dashed border-gray-300 p-12 text-center">
                            <i class="fa-solid fa-shield-heart text-5xl text-green-300 mb-4"></i>
                            <h3 class="text-lg font-bold text-gray-900">Không có sự cố nào</h3>
                            <p class="text-gray-500">Mọi đơn hàng đều đang được giao suôn sẻ.</p>
                        </div>
                    </c:if>

                    <div class="grid grid-cols-1 gap-4">
                        <c:forEach var="issue" items="${pendingIssues}">
                            <div class="bg-white rounded-2xl border border-gray-200 shadow-sm p-6 relative overflow-hidden flex flex-col md:flex-row gap-6 items-center">
                                <div class="absolute left-0 top-0 bottom-0 w-1.5 bg-red-500"></div>

                                <div class="w-full md:w-1/3 border-b md:border-b-0 md:border-r border-gray-100 pb-4 md:pb-0 md:pr-6 ml-2">
                                    <span class="bg-red-100 text-red-600 px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wider mb-3 inline-block">
                                        <i class="fa-solid fa-triangle-exclamation"></i> Chờ xử lý
                                    </span>
                                    <h4 class="font-bold text-lg text-gray-900 mb-1">${issue.reporterName}</h4>
                                    <p class="text-sm text-gray-500 mb-2"><i class="fa-solid fa-phone mr-1"></i> ${issue.reporterPhone}</p>
                                    <p class="text-xs text-gray-400 font-medium"><i class="fa-solid fa-clock mr-1"></i> <fmt:formatDate value="${issue.createdAt}" pattern="dd/MM/yyyy HH:mm"/></p>
                                </div>

                                <div class="flex-1 w-full">
                                    <p class="text-sm text-gray-500 mb-1">Mã đơn hàng liên quan:</p>
                                    <p class="font-bold text-blue-600 mb-3 tracking-wider">${issue.orderCode}</p>
                                    <p class="text-sm text-gray-500 mb-1">Loại sự cố:</p>
                                    <p class="font-bold text-gray-900 mb-2">${issue.issueType}</p>
                                    <div class="bg-gray-50 rounded-xl p-3 border border-gray-200 text-sm text-gray-700 italic">
                                        "${not empty issue.description ? issue.description : 'Không có mô tả chi tiết.'}"
                                    </div>
                                </div>

                                <div class="w-full md:w-auto shrink-0">
                                    <form action="${pageContext.request.contextPath}/admin/dashboard" method="POST">
                                        <input type="hidden" name="action" value="RESOLVE_ISSUE">
                                        <input type="hidden" name="issueId" value="${issue.id}">
                                        <button type="submit" onclick="confirmAction(event, 'Bạn đã liên hệ đối tác và xác nhận đóng hồ sơ sự cố này?', this);" class="w-full md:w-auto bg-gray-800 hover:bg-black text-white font-bold py-3 px-6 rounded-xl transition flex items-center justify-center gap-2 shadow-md">
                                            <i class="fa-solid fa-check-double"></i> Đánh dấu Đã Giải Quyết
                                        </button>
                                    </form>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </div>

                <div id="tab-users" class="hidden">
                    <div class="mb-6">
                        <h3 class="text-xl font-bold text-gray-900 flex items-center gap-2">
                            <i class="fa-solid fa-users-gear text-orange-500"></i> Quản lý Tài khoản Hệ thống
                        </h3>
                        <p class="text-sm text-gray-500 mt-1">Giám sát và Khóa/Mở khóa các tài khoản vi phạm chính sách.</p>
                    </div>

                    <div class="flex flex-wrap gap-4 mb-6 border-b border-gray-200 pb-4">
                        <button onclick="switchSubTab('customers')" id="subnav-customers" class="px-6 py-2 rounded-full font-bold text-sm bg-orange-500 text-white shadow-md transition">Khách Hàng</button>
                        <button onclick="switchSubTab('merchants')" id="subnav-merchants" class="px-6 py-2 rounded-full font-bold text-sm bg-gray-100 text-gray-600 hover:bg-gray-200 transition">Nhà Hàng</button>
                        <button onclick="switchSubTab('shippers')" id="subnav-shippers" class="px-6 py-2 rounded-full font-bold text-sm bg-gray-100 text-gray-600 hover:bg-gray-200 transition">Tài Xế (Shipper)</button>
                        <button onclick="switchSubTab('appeals')" id="subnav-appeals" class="px-6 py-2 rounded-full font-bold text-sm bg-gray-100 text-gray-600 hover:bg-gray-200 transition">Đơn Kháng Cáo 
                            <c:if test="${not empty listAppeals}"><span class="bg-red-500 text-white px-2 py-0.5 rounded-full text-xs ml-1">${listAppeals.size()}</span></c:if>
                            </button>
                        </div>

                        <div class="flex flex-col md:flex-row gap-4 mb-6 bg-white p-4 rounded-2xl border border-gray-200 shadow-sm relative z-20">
                            <div class="flex-1 relative">
                                <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                                    <i class="fa-solid fa-magnifying-glass text-gray-400"></i>
                                </div>
                                <input type="text" id="user-search-input" onkeyup="handleUserSearch()" autocomplete="off" placeholder="Tìm theo tên, một phần tên hoặc số điện thoại..." class="w-full pl-11 pr-4 py-3 bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-orange-500 focus:bg-white transition font-medium text-gray-700">
                            </div>

                            <div class="w-full md:w-56 shrink-0 relative">
                                <div class="absolute inset-y-0 left-0 pl-4 flex items-center pointer-events-none">
                                    <i class="fa-solid fa-arrow-down-a-z text-gray-400"></i>
                                </div>
                                <select id="user-sort-select" onchange="handleUserSort()" class="w-full pl-11 pr-8 py-3 bg-gray-50 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-orange-500 focus:bg-white transition font-bold text-gray-700 appearance-none cursor-pointer">
                                    <option value="default">Mặc định (Mới nhất)</option>
                                    <option value="name_asc">Tên: A -> Z</option>
                                    <option value="name_desc">Tên: Z -> A</option>
                                    <option value="status_active">Trạng thái: Đang hoạt động</option>
                                    <option value="status_banned">Trạng thái: Bị khóa</option>
                                </select>
                                <div class="absolute inset-y-0 right-0 pr-4 flex items-center pointer-events-none">
                                    <i class="fa-solid fa-chevron-down text-gray-400 text-xs"></i>
                                </div>
                            </div>
                        </div>

                        <div id="subtab-customers" class="block bg-white rounded-2xl shadow-sm border border-gray-200 overflow-hidden mb-8">
                            <div class="bg-blue-50/50 px-6 py-4 border-b border-gray-200 flex justify-between items-center">
                                <h4 class="font-bold text-blue-800"><i class="fa-solid fa-users mr-2"></i>Danh sách Khách Hàng</h4>
                                <span class="bg-blue-100 text-blue-600 text-xs font-bold px-3 py-1 rounded-full">${listCustomers.size()} tài khoản</span>
                        </div>
                        <div class="overflow-x-auto">
                            <table class="w-full text-left text-sm text-gray-600">
                                <thead class="bg-white border-b border-gray-100 text-gray-400 uppercase">
                                    <tr><th class="px-6 py-4 font-medium">ID / Tên Khách</th><th class="px-6 py-4 font-medium">Liên hệ</th><th class="px-6 py-4 font-medium text-center">Trạng thái</th><th class="px-6 py-4 font-medium text-center">Hành động</th></tr>
                                </thead>
                                <tbody class="divide-y divide-gray-100">
                                    <c:forEach var="u" items="${listCustomers}">
                                        <tr class="hover:bg-gray-50 transition user-row" data-name="${u.fullName.toLowerCase()}" data-phone="${u.phone}" data-status="${u.status}">
                                            <td class="px-6 py-4">
                                                <div class="flex items-center gap-3">
                                                    <div class="w-10 h-10 rounded-full overflow-hidden border border-gray-200 bg-gray-50 flex items-center justify-center shrink-0">
                                                        <c:choose>
                                                            <c:when test="${not empty u.avatarUrl}">
                                                                <img src="${u.avatarUrl}" class="w-full h-full object-cover">
                                                            </c:when>
                                                            <c:otherwise>
                                                                <i class="fa-solid fa-user text-gray-400"></i>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                    <div>
                                                        <a href="${pageContext.request.contextPath}/admin/user-detail?id=${u.id}" class="font-bold text-blue-600 hover:text-blue-800 hover:underline transition">
                                                            ${u.fullName} <i class="fa-solid fa-arrow-up-right-from-square text-[10px] ml-1 opacity-50"></i>
                                                        </a>
                                                        <p class="text-xs text-gray-400 mt-0.5">ID: ${u.id}</p>
                                                    </div>
                                                </div>
                                            </td>
                                            <td class="px-6 py-4"><p class="font-medium text-gray-800">${u.phone}</p><p class="text-xs text-gray-400">${u.email}</p></td>
                                            <td class="px-6 py-4 text-center"><span class="px-3 py-1 rounded-full text-xs font-bold ${u.status == 'ACTIVE' ? 'bg-green-100 text-green-600' : 'bg-red-100 text-red-600'}">${u.status}</span></td>
                                            <td class="px-6 py-4 text-center">
                                                <form action="${pageContext.request.contextPath}/admin/dashboard" method="POST" class="inline">
                                                    <input type="hidden" name="action" value="CHANGE_USER_STATUS">
                                                    <input type="hidden" name="targetUserId" value="${u.id}">
                                                    <input type="hidden" name="newStatus" value="${u.status == 'ACTIVE' ? 'INACTIVE' : 'ACTIVE'}">
                                                    <button type="submit" onclick="confirmAction(event, 'Khóa/Mở khóa tài khoản này?', this);" class="w-10 h-10 rounded-lg font-bold text-white transition shadow-sm ${u.status == 'ACTIVE' ? 'bg-red-500 hover:bg-red-600' : 'bg-green-500 hover:bg-green-600'}"><i class="${u.status == 'ACTIVE' ? 'fa-solid fa-lock' : 'fa-solid fa-unlock'}"></i></button>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <div id="subtab-merchants" class="hidden bg-white rounded-2xl shadow-sm border border-gray-200 overflow-hidden mb-8">
                        <div class="bg-orange-50/50 px-6 py-4 border-b border-gray-200 flex justify-between items-center">
                            <h4 class="font-bold text-orange-800"><i class="fa-solid fa-store mr-2"></i>Danh sách Nhà Hàng</h4>
                            <span class="bg-orange-100 text-orange-600 text-xs font-bold px-3 py-1 rounded-full">${listMerchants.size()} tài khoản</span>
                        </div>
                        <div class="overflow-x-auto">
                            <table class="w-full text-left text-sm text-gray-600">
                                <thead class="bg-white border-b border-gray-100 text-gray-400 uppercase">
                                    <tr><th class="px-6 py-4 font-medium">ID / Tên Chủ Quán</th><th class="px-6 py-4 font-medium">Liên hệ</th><th class="px-6 py-4 font-medium text-center">Trạng thái</th><th class="px-6 py-4 font-medium text-center">Hành động</th></tr>
                                </thead>
                                <tbody class="divide-y divide-gray-100">
                                    <c:forEach var="u" items="${listMerchants}">
                                        <tr class="hover:bg-gray-50 transition user-row" data-name="${u.fullName.toLowerCase()}" data-phone="${u.phone}" data-status="${u.status}">
                                            <td class="px-6 py-4">
                                                <div class="flex items-center gap-3">
                                                    <div class="w-10 h-10 rounded-full overflow-hidden border border-gray-200 bg-gray-50 flex items-center justify-center shrink-0">
                                                        <c:choose>
                                                            <c:when test="${not empty u.avatarUrl}">
                                                                <img src="${u.avatarUrl}" class="w-full h-full object-cover">
                                                            </c:when>
                                                            <c:otherwise>
                                                                <i class="fa-solid fa-user text-gray-400"></i>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                    <div>
                                                        <a href="${pageContext.request.contextPath}/admin/user-detail?id=${u.id}" class="font-bold text-blue-600 hover:text-blue-800 hover:underline transition">
                                                            ${u.fullName} <i class="fa-solid fa-arrow-up-right-from-square text-[10px] ml-1 opacity-50"></i>
                                                        </a>
                                                        <p class="text-xs text-gray-400 mt-0.5">ID: ${u.id}</p>
                                                    </div>
                                                </div>
                                            </td>
                                            <td class="px-6 py-4"><p class="font-medium text-gray-800">${u.phone}</p><p class="text-xs text-gray-400">${u.email}</p></td>
                                            <td class="px-6 py-4 text-center"><span class="px-3 py-1 rounded-full text-xs font-bold ${u.status == 'ACTIVE' ? 'bg-green-100 text-green-600' : 'bg-red-100 text-red-600'}">${u.status}</span></td>
                                            <td class="px-6 py-4 text-center">
                                                <form action="${pageContext.request.contextPath}/admin/dashboard" method="POST" class="inline">
                                                    <input type="hidden" name="action" value="CHANGE_USER_STATUS">
                                                    <input type="hidden" name="targetUserId" value="${u.id}">
                                                    <input type="hidden" name="newStatus" value="${u.status == 'ACTIVE' ? 'INACTIVE' : 'ACTIVE'}">
                                                    <button type="submit" onclick="confirmAction(event, 'Khóa/Mở khóa tài khoản này?', this);" class="w-10 h-10 rounded-lg font-bold text-white transition shadow-sm ${u.status == 'ACTIVE' ? 'bg-red-500 hover:bg-red-600' : 'bg-green-500 hover:bg-green-600'}"><i class="${u.status == 'ACTIVE' ? 'fa-solid fa-lock' : 'fa-solid fa-unlock'}"></i></button>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <div id="subtab-shippers" class="hidden bg-white rounded-2xl shadow-sm border border-gray-200 overflow-hidden mb-8">
                        <div class="bg-gray-50 px-6 py-4 border-b border-gray-200 flex justify-between items-center">
                            <h4 class="font-bold text-gray-800"><i class="fa-solid fa-motorcycle mr-2"></i>Danh sách Tài Xế (Shipper)</h4>
                            <span class="bg-gray-200 text-gray-700 text-xs font-bold px-3 py-1 rounded-full">${listShippers.size()} tài khoản</span>
                        </div>
                        <div class="overflow-x-auto">
                            <table class="w-full text-left text-sm text-gray-600">
                                <thead class="bg-white border-b border-gray-100 text-gray-400 uppercase">
                                    <tr><th class="px-6 py-4 font-medium">ID / Tên Tài Xế</th><th class="px-6 py-4 font-medium">Liên hệ</th><th class="px-6 py-4 font-medium text-center">Trạng thái</th><th class="px-6 py-4 font-medium text-center">Hành động</th></tr>
                                </thead>
                                <tbody class="divide-y divide-gray-100">
                                    <c:forEach var="u" items="${listShippers}">
                                        <tr class="hover:bg-gray-50 transition user-row" data-name="${u.fullName.toLowerCase()}" data-phone="${u.phone}" data-status="${u.status}">
                                            <td class="px-6 py-4">
                                                <div class="flex items-center gap-3">
                                                    <div class="w-10 h-10 rounded-full overflow-hidden border border-gray-200 bg-gray-50 flex items-center justify-center shrink-0">
                                                        <c:choose>
                                                            <c:when test="${not empty u.avatarUrl}">
                                                                <img src="${u.avatarUrl}" class="w-full h-full object-cover">
                                                            </c:when>
                                                            <c:otherwise>
                                                                <i class="fa-solid fa-user text-gray-400"></i>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                    <div>
                                                        <a href="${pageContext.request.contextPath}/admin/user-detail?id=${u.id}" class="font-bold text-blue-600 hover:text-blue-800 hover:underline transition">
                                                            ${u.fullName} <i class="fa-solid fa-arrow-up-right-from-square text-[10px] ml-1 opacity-50"></i>
                                                        </a>
                                                        <p class="text-xs text-gray-400 mt-0.5">ID: ${u.id}</p>
                                                    </div>
                                                </div>
                                            </td>
                                            <td class="px-6 py-4"><p class="font-medium text-gray-800">${u.phone}</p><p class="text-xs text-gray-400">${u.email}</p></td>
                                            <td class="px-6 py-4 text-center"><span class="px-3 py-1 rounded-full text-xs font-bold ${u.status == 'ACTIVE' ? 'bg-green-100 text-green-600' : 'bg-red-100 text-red-600'}">${u.status}</span></td>
                                            <td class="px-6 py-4 text-center">
                                                <form action="${pageContext.request.contextPath}/admin/dashboard" method="POST" class="inline">
                                                    <input type="hidden" name="action" value="CHANGE_USER_STATUS">
                                                    <input type="hidden" name="targetUserId" value="${u.id}">
                                                    <input type="hidden" name="newStatus" value="${u.status == 'ACTIVE' ? 'INACTIVE' : 'ACTIVE'}">
                                                    <button type="submit" onclick="confirmAction(event, 'Khóa/Mở khóa tài khoản này?', this);" class="w-10 h-10 rounded-lg font-bold text-white transition shadow-sm ${u.status == 'ACTIVE' ? 'bg-red-500 hover:bg-red-600' : 'bg-green-500 hover:bg-green-600'}"><i class="${u.status == 'ACTIVE' ? 'fa-solid fa-lock' : 'fa-solid fa-unlock'}"></i></button>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <div id="subtab-appeals" class="hidden bg-white rounded-2xl shadow-sm border border-gray-200 overflow-hidden mb-8">
                        <div class="bg-red-50/50 px-6 py-4 border-b border-gray-200 flex justify-between items-center">
                            <h4 class="font-bold text-red-800"><i class="fa-solid fa-envelope-open-text mr-2"></i>Đơn xin Ân xá / Kháng cáo</h4>
                        </div>
                        <div class="p-6 grid grid-cols-1 gap-4">
                            <c:forEach var="a" items="${listAppeals}">
                                <div class="border border-gray-200 rounded-xl p-5 flex flex-col md:flex-row gap-6 relative">
                                    <div class="w-1/3 border-r border-gray-100 pr-4">
                                        <span class="text-xs font-bold text-gray-400">Người gửi:</span>
                                        <h4 class="font-black text-lg text-gray-900">${a.fullName}</h4>
                                        <p class="text-sm font-bold ${a.role == 'SHIPPER' ? 'text-orange-500' : 'text-blue-500'} mb-2">${a.role}</p>
                                        <p class="text-sm text-gray-500"><i class="fa-solid fa-phone mr-1"></i>${a.phone}</p>
                                    </div>
                                    <div class="flex-1">
                                        <span class="text-xs font-bold text-gray-400">Nội dung giải trình:</span>
                                        <p class="font-medium text-gray-800 italic bg-gray-50 p-3 rounded-lg border border-gray-100 mt-1 mb-4">"${a.reason}"</p>

                                        <form action="${pageContext.request.contextPath}/admin/dashboard" method="POST" class="flex gap-2">
                                            <input type="hidden" name="action" value="RESOLVE_APPEAL">
                                            <input type="hidden" name="appealId" value="${a.id}">
                                            <input type="hidden" name="targetUserId" value="${a.userId}">
                                            <input type="text" name="adminNote" placeholder="Ghi chú của Admin (Tùy chọn)" class="flex-1 border border-gray-300 rounded-lg px-3 outline-none focus:border-red-500 text-sm">
                                            <button type="submit" name="appealDecision" value="APPROVE" onclick="confirmAction(event, 'Chấp nhận và mở khóa tài khoản này?', this);" class="bg-green-500 hover:bg-green-600 text-white font-bold px-4 py-2 rounded-lg text-sm transition shadow"><i class="fa-solid fa-check mr-1"></i>Ân xá</button>
                                            <button type="submit" name="appealDecision" value="REJECT" onclick="confirmAction(event, 'Bác bỏ đơn kháng cáo này?', this);" class="bg-gray-800 hover:bg-black text-white font-bold px-4 py-2 rounded-lg text-sm transition shadow"><i class="fa-solid fa-xmark mr-1"></i>Bác bỏ</button>
                                        </form>
                                    </div>
                                </div>
                            </c:forEach>
                            <c:if test="${empty listAppeals}"><p class="text-center text-gray-400 font-medium py-4">Không có đơn kháng cáo nào.</p></c:if>
                            </div>
                        </div>

                    </div>
                </div>
            </main>

            <div id="reject-modal" class="fixed inset-0 bg-black/50 z-50 hidden flex items-center justify-center backdrop-blur-sm">
                <div class="bg-white rounded-2xl w-full max-w-md p-6 shadow-2xl">
                    <h3 class="text-xl font-bold text-gray-900 mb-4">Lý do từ chối hồ sơ</h3>
                    <form action="${pageContext.request.contextPath}/admin/dashboard" method="POST">
                    <input type="hidden" name="action" value="REJECT_KYC">
                    <input type="hidden" name="kycId" id="reject-kyc-id">
                    <input type="hidden" name="merchantId" id="reject-merchant-id">
                    <textarea name="rejectReason" rows="3" required placeholder="Ví dụ: GPKD bị mờ, Sai mã số thuế..." class="w-full border border-gray-300 rounded-xl p-3 focus:outline-none focus:border-red-500 focus:ring-1 focus:ring-red-500 mb-6"></textarea>
                    <div class="flex gap-3">
                        <button type="button" onclick="closeRejectModal()" class="flex-1 bg-gray-100 hover:bg-gray-200 text-gray-700 font-bold py-3 rounded-xl transition">Hủy</button>
                        <button type="submit" class="flex-1 bg-red-500 hover:bg-red-600 text-white font-bold py-3 rounded-xl transition shadow-md">Xác nhận Từ Chối</button>
                    </div>
                </form>
            </div>
        </div>

        <div id="custom-confirm-modal" class="fixed inset-0 bg-black/60 z-[100] hidden flex items-center justify-center backdrop-blur-sm transition-opacity">
            <div class="bg-white rounded-3xl w-full max-w-sm p-6 shadow-2xl relative text-center transform transition-all scale-95 opacity-0 duration-200" id="confirm-modal-content">
                <div class="w-16 h-16 bg-orange-100 text-orange-500 rounded-full flex items-center justify-center text-3xl mx-auto mb-4">
                    <i class="fa-solid fa-circle-exclamation animate-pulse"></i>
                </div>
                <h3 class="text-xl font-black text-gray-900 mb-2">Xác nhận hành động</h3>
                <p id="confirm-message" class="text-gray-500 mb-6 font-medium">Bạn có chắc chắn không?</p>

                <div class="flex gap-3">
                    <button onclick="closeConfirmModal()" type="button" class="flex-1 bg-gray-100 hover:bg-gray-200 text-gray-700 font-bold py-3 rounded-xl transition">Hủy bỏ</button>
                    <button onclick="executeConfirm()" type="button" class="flex-1 bg-orange-500 hover:bg-orange-600 text-white font-bold py-3 rounded-xl transition shadow-md">Xác nhận</button>
                </div>
            </div>
        </div>

        <c:if test="${not empty sessionScope.toastMsg}">
            <div id="toast-success" class="fixed top-5 right-5 bg-green-500 text-white px-6 py-4 rounded-xl shadow-2xl z-[100] animate-bounce flex items-center gap-2">
                <i class="fa-solid fa-circle-check text-xl"></i>
                <span class="font-medium">${sessionScope.toastMsg}</span>
            </div>
            <c:remove var="toastMsg" scope="session" />
            <script>setTimeout(() => document.getElementById('toast-success').style.display = 'none', 3000);</script>
        </c:if>

        <c:if test="${not empty sessionScope.toastError}">
            <div id="toast-error" class="fixed top-5 right-5 bg-red-500 text-white px-6 py-4 rounded-xl shadow-2xl z-[100] animate-bounce flex items-center gap-2">
                <i class="fa-solid fa-triangle-exclamation text-xl"></i>
                <span class="font-medium">${sessionScope.toastError}</span>
            </div>
            <c:remove var="toastError" scope="session" />
            <script>setTimeout(() => document.getElementById('toast-error').style.display = 'none', 4000);</script>
        </c:if>

        <script>
            function switchTab(tabName) {
                document.getElementById('tab-overview').classList.add('hidden');
                document.getElementById('tab-kyc').classList.add('hidden');
                document.getElementById('tab-finance').classList.add('hidden');
                document.getElementById('tab-dispute').classList.add('hidden');
                document.getElementById('tab-users').classList.add('hidden');

                const normalClass = "w-full flex items-center gap-3 px-4 py-3 text-gray-500 hover:bg-gray-100 hover:text-gray-900 rounded-xl font-medium transition-colors";
                const activeClass = "w-full flex items-center gap-3 px-4 py-3 bg-orange-100 text-orange-600 rounded-xl font-bold transition-colors";

                const normalClassBetween = "w-full flex items-center justify-between px-4 py-3 text-gray-500 hover:bg-gray-100 hover:text-gray-900 rounded-xl font-medium transition-colors";
                const activeClassBetween = "w-full flex items-center justify-between px-4 py-3 bg-orange-500/20 text-orange-400 rounded-xl font-bold transition-colors";

                document.getElementById('nav-overview').className = normalClass;
                document.getElementById('nav-kyc').className = normalClassBetween;
                document.getElementById('nav-finance').className = normalClassBetween;
                document.getElementById('nav-dispute').className = normalClassBetween;
                document.getElementById('nav-users').className = normalClass;

                if (tabName === 'overview') {
                    document.getElementById('tab-overview').classList.remove('hidden');
                    document.getElementById('nav-overview').className = activeClass;
                    document.getElementById('header-title').innerText = "Báo cáo tổng quan";
                } else if (tabName === 'kyc') {
                    document.getElementById('tab-kyc').classList.remove('hidden');
                    document.getElementById('nav-kyc').className = activeClassBetween;
                    document.getElementById('header-title').innerText = "Kiểm duyệt Quán ăn";
                } else if (tabName === 'finance') {
                    document.getElementById('tab-finance').classList.remove('hidden');
                    document.getElementById('nav-finance').className = activeClassBetween;
                    document.getElementById('header-title').innerText = "Quản lý Rút tiền";
                } else if (tabName === 'dispute') {
                    document.getElementById('tab-dispute').classList.remove('hidden');
                    document.getElementById('nav-dispute').className = activeClassBetween;
                    document.getElementById('header-title').innerText = "Giải quyết Sự cố";
                } else if (tabName === 'users') {
                    document.getElementById('tab-users').classList.remove('hidden');
                    document.getElementById('nav-users').className = activeClass;
                    document.getElementById('header-title').innerText = "Quản lý Người dùng";
                }
            }

            function switchSubTab(role) {
                document.getElementById('subtab-customers').classList.add('hidden');
                document.getElementById('subtab-merchants').classList.add('hidden');
                document.getElementById('subtab-shippers').classList.add('hidden');
                document.getElementById('subtab-appeals').classList.add('hidden');

                const normalClass = "px-6 py-2 rounded-full font-bold text-sm bg-gray-100 text-gray-600 hover:bg-gray-200 transition";
                const activeClass = "px-6 py-2 rounded-full font-bold text-sm bg-orange-500 text-white shadow-md transition";

                document.getElementById('subnav-customers').className = normalClass;
                document.getElementById('subnav-merchants').className = normalClass;
                document.getElementById('subnav-shippers').className = normalClass;
                document.getElementById('subnav-appeals').className = normalClass;

                document.getElementById('subtab-' + role).classList.remove('hidden');
                document.getElementById('subnav-' + role).className = activeClass;
            }

            document.addEventListener('DOMContentLoaded', function () {
                const activeTab = '${activeTab}';
                if (activeTab)
                    switchTab(activeTab);
            });

            function openRejectModal(kycId, merchantId) {
                document.getElementById('reject-kyc-id').value = kycId;
                document.getElementById('reject-merchant-id').value = merchantId;
                document.getElementById('reject-modal').classList.remove('hidden');
            }
            function closeRejectModal() {
                document.getElementById('reject-modal').classList.add('hidden');
            }
        </script>

        <script>
            document.addEventListener('DOMContentLoaded', function () {
                const revCtx = document.getElementById('adminRevenueChart');
                if (revCtx) {
                    new Chart(revCtx.getContext('2d'), {
                        type: 'line',
                        data: {
                            labels: [${revLabels}],
                            datasets: [{
                                    label: 'Tổng Giao Dịch (GMV)',
                                    data: [${revValues}],
                                    borderColor: 'rgb(59, 130, 246)',
                                    backgroundColor: 'rgba(59, 130, 246, 0.1)',
                                    borderWidth: 3,
                                    pointBackgroundColor: 'rgb(59, 130, 246)',
                                    fill: true,
                                    tension: 0.4
                                }]
                        },
                        options: {
                            responsive: true, maintainAspectRatio: false,
                            plugins: {legend: {display: false}},
                            scales: {
                                y: {beginAtZero: true, ticks: {callback: function (value) {
                                            return (value / 1000) + 'k';
                                        }}}
                            }
                        }
                    });
                }

                const statusCtx = document.getElementById('adminStatusChart');
                if (statusCtx) {
                    new Chart(statusCtx.getContext('2d'), {
                        type: 'doughnut',
                        data: {
                            labels: [${statusLabels}],
                            datasets: [{
                                    data: [${statusValues}],
                                    backgroundColor: ['#22c55e', '#ef4444', '#f97316', '#3b82f6', '#eab308', '#94a3b8'],
                                    borderWidth: 0
                                }]
                        },
                        options: {
                            responsive: true, maintainAspectRatio: false,
                            plugins: {legend: {position: 'bottom', labels: {boxWidth: 12, font: {size: 11}}}},
                            cutout: '65%'
                        }
                    });
                }
            });
        </script>

        <script>
            let targetAction = null;

            function confirmAction(event, message, element) {
                event.preventDefault();
                if (element.tagName === 'A') {
                    targetAction = {type: 'link', data: element.href};
                } else if (element.form) {
                    targetAction = {type: 'form', data: element.form};
                } else if (element.tagName === 'FORM') {
                    targetAction = {type: 'form', data: element};
                }
                document.getElementById('confirm-message').innerText = message;
                const modal = document.getElementById('custom-confirm-modal');
                const content = document.getElementById('confirm-modal-content');
                modal.classList.remove('hidden');
                setTimeout(() => {
                    content.classList.remove('scale-95', 'opacity-0');
                    content.classList.add('scale-100', 'opacity-100');
                }, 10);
            }

            function closeConfirmModal() {
                const modal = document.getElementById('custom-confirm-modal');
                const content = document.getElementById('confirm-modal-content');
                content.classList.remove('scale-100', 'opacity-100');
                content.classList.add('scale-95', 'opacity-0');
                setTimeout(() => {
                    modal.classList.add('hidden');
                    targetAction = null;
                }, 200);
            }

            function executeConfirm() {
                if (!targetAction)
                    return;
                if (targetAction.type === 'form') {
                    targetAction.data.submit();
                } else if (targetAction.type === 'link') {
                    window.location.href = targetAction.data;
                }
            }
        </script>

        <script>
            function handleUserSearch() {
                const input = document.getElementById('user-search-input').value.toLowerCase().trim();

                // Lấy cả 3 bảng để kiểm tra độc lập
                const tbodys = document.querySelectorAll('#subtab-customers tbody, #subtab-merchants tbody, #subtab-shippers tbody');

                tbodys.forEach(tbody => {
                    let hasVisibleRow = false; // Biến theo dõi xem có hàng nào khớp không
                    const rows = tbody.querySelectorAll('.user-row');

                    rows.forEach(row => {
                        const name = row.getAttribute('data-name');
                        const phone = row.getAttribute('data-phone');
                        if (name.includes(input) || phone.includes(input)) {
                            row.style.display = '';
                            hasVisibleRow = true; 
                        } else {
                            row.style.display = 'none';
                        }
                    });
                    let noResultRow = tbody.querySelector('.no-result-row');

                    if (!hasVisibleRow && rows.length > 0) {

                        if (!noResultRow) {

                            noResultRow = document.createElement('tr');
                            noResultRow.className = 'no-result-row';
                            noResultRow.innerHTML = '<td colspan="4" class="px-6 py-8 text-center text-gray-500 font-medium italic"><i class="fa-solid fa-magnifying-glass-minus text-2xl mb-2 block text-gray-300"></i>Không có thông tin phù hợp với từ khóa</td>';
                            tbody.appendChild(noResultRow);
                        }
                        noResultRow.style.display = '';
                    } else if (noResultRow) {

                        noResultRow.style.display = 'none';
                    }
                });
            }

            function handleUserSort() {
                const sortType = document.getElementById('user-sort-select').value;
                const tbodys = document.querySelectorAll('#subtab-customers tbody, #subtab-merchants tbody, #subtab-shippers tbody');

                tbodys.forEach(tbody => {
                    let rowsArray = Array.from(tbody.querySelectorAll('.user-row'));

                    rowsArray.sort((a, b) => {
                        const nameA = a.getAttribute('data-name');
                        const nameB = b.getAttribute('data-name');
                        const statusA = a.getAttribute('data-status');
                        const statusB = b.getAttribute('data-status');

                        if (sortType === 'name_asc')
                            return nameA.localeCompare(nameB);
                        if (sortType === 'name_desc')
                            return nameB.localeCompare(nameA);

                        if (sortType === 'status_active')
                            return statusA === 'ACTIVE' ? -1 : 1;
                        if (sortType === 'status_banned')
                            return statusA === 'INACTIVE' ? -1 : 1;

                        return 0; // default
                    });

                    tbody.innerHTML = '';
                    rowsArray.forEach(row => tbody.appendChild(row));
                });
            }
        </script>
    </body>
</html>