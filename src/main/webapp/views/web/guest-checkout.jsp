<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Đặt hàng nhanh - ClickEat</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
    </head>
    <body class="bg-[#f7f5f3] text-gray-900 min-h-screen flex flex-col">

        <jsp:include page="header.jsp" />

        <main class="flex-grow max-w-7xl mx-auto w-full px-6 py-8">
            <a href="javascript:history.back()"
               class="inline-flex items-center gap-2 text-[#8e6d57] font-bold mb-6 hover:text-orange-500 transition">
                <i class="fa-solid fa-arrow-left"></i> Quay lại
            </a>

            <div class="mb-8">
                <div class="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-orange-100 text-orange-600 text-sm font-extrabold">
                    <i class="fa-solid fa-bolt"></i>
                    Đặt hàng nhanh
                </div>
                <h1 class="mt-4 text-4xl font-black tracking-tight">Thông tin giao hàng</h1>
                <p class="mt-2 text-gray-500 text-lg">
                    Nhập thông tin cần thiết và xác thực OTP để tiếp tục thanh toán mà không cần đăng nhập.
                </p>
            </div>

            <div class="grid grid-cols-1 lg:grid-cols-2 bg-white rounded-[32px] overflow-hidden border border-[#eee4dc] shadow-[0_18px_45px_rgba(15,23,42,.08)]">
                <div class="relative min-h-[640px] bg-[#fff3eb]">
                    <img src="${pageContext.request.contextPath}/assets/images/guest-food-banner.jpg"
                         alt="Đặt hàng nhanh"
                         class="absolute inset-0 w-full h-full object-cover"
                         onerror="this.onerror=null;this.src='${pageContext.request.contextPath}/assets/images/default-store-cover.jpg';">
                    <div class="absolute inset-0 bg-gradient-to-t from-black/55 via-black/15 to-transparent"></div>
                    <div class="absolute left-8 right-8 bottom-8 text-white">
                        <div class="inline-flex items-center justify-center w-16 h-16 rounded-full bg-white/20 backdrop-blur text-3xl mb-5">
                            <i class="fa-solid fa-bag-shopping"></i>
                        </div>
                        <h2 class="text-4xl font-black">Đặt món cực nhanh</h2>
                        <p class="mt-3 text-lg text-white/90 leading-relaxed">
                            Chỉ cần xác thực số điện thoại, hoàn tất thông tin giao hàng và tiếp tục thanh toán với giỏ hàng hiện tại.
                        </p>
                    </div>
                </div>

                <div class="p-8 md:p-10">
                    <c:if test="${not empty message}">
                        <div class="mb-4 rounded-2xl border border-green-200 bg-green-50 text-green-700 px-4 py-3 font-semibold">
                            ${message}
                        </div>
                    </c:if>

                    <c:if test="${not empty error and not otpSent}">
                        <div class="mb-4 rounded-2xl border border-red-200 bg-red-50 text-red-700 px-4 py-3 font-semibold">
                            ${error}
                        </div>
                    </c:if>

                    <c:if test="${not empty debugError}">
                        <div class="mb-4 rounded-2xl border border-yellow-300 bg-yellow-50 text-yellow-800 px-4 py-3">
                            <div><strong>Debug:</strong> ${debugError}</div>
                            <div class="mt-1"><strong>SĐT chuẩn hoá:</strong> ${normalizedPhone}</div>
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/guest-send-otp" method="post" class="space-y-4" id="sendOtpForm">
                        <div>
                            <label class="block text-sm font-bold text-gray-800 mb-2">Họ và tên</label>
                            <input type="text" name="fullName" value="${fullName}" required
                                   class="w-full h-12 px-4 rounded-2xl border border-gray-200 bg-white outline-none focus:ring-4 focus:ring-orange-100 focus:border-orange-400">
                        </div>

                        <div>
                            <label class="block text-sm font-bold text-gray-800 mb-2">Email</label>
                            <input type="email" name="email" value="${email}" required
                                   class="w-full h-12 px-4 rounded-2xl border border-gray-200 bg-white outline-none focus:ring-4 focus:ring-orange-100 focus:border-orange-400">
                        </div>

                        <div>
                            <label class="block text-sm font-bold text-gray-800 mb-2">Số điện thoại</label>
                            <input type="text" name="phone" value="${phone}" required placeholder="VD: 0900000012"
                                   class="w-full h-12 px-4 rounded-2xl border border-gray-200 bg-white outline-none focus:ring-4 focus:ring-orange-100 focus:border-orange-400">
                        </div>

                        <div>
                            <label class="block text-sm font-bold text-gray-800 mb-2">Địa chỉ giao hàng</label>
                            <textarea name="addressLine" required rows="4"
                                      class="w-full px-4 py-3 rounded-2xl border border-gray-200 bg-white outline-none focus:ring-4 focus:ring-orange-100 focus:border-orange-400 resize-none">${addressLine}</textarea>
                        </div>

                        <button type="submit" id="sendOtpBtn"
                                class="w-full h-12 rounded-full bg-orange-500 hover:bg-orange-600 text-white font-black shadow transition disabled:opacity-60 disabled:cursor-not-allowed">
                            <c:choose>
                                <c:when test="${otpSent}">Đã gửi mã OTP</c:when>
                                <c:when test="${canResendOtp}">Gửi lại mã OTP</c:when>
                                <c:otherwise>Gửi mã OTP</c:otherwise>
                            </c:choose>
                        </button>
                    </form>

                    <c:if test="${otpSent}">
                        <div class="mt-8 border-t border-gray-100 pt-6">
                            <h3 class="text-3xl md:text-4xl leading-tight font-black text-[#111827]">Nhập mã xác minh</h3>

                            <p class="mt-3 text-base md:text-lg text-gray-500">
                                Mã OTP đã được gửi đến:
                                <span class="font-black text-[#1f2937]">${phone}</span>
                            </p>

                            <div id="otpTimerBox"
                                 class="mt-4 inline-flex items-center gap-2 px-4 py-3 rounded-full bg-[#fff3eb] text-[#ea580c] font-black text-lg md:text-xl">
                                <i class="fa-regular fa-clock text-lg md:text-xl"></i>
                                <span>Còn lại: <span id="otpCountdown">02:00</span></span>
                            </div>

                            <form action="${pageContext.request.contextPath}/guest-verify-otp" method="post"
                                  id="verifyOtpForm"
                                  class="mt-6 space-y-4">
                                <input type="hidden" name="fullName" value="${not empty fullName ? fullName : guestFullName}">
                                <input type="hidden" name="email" value="${not empty email ? email : guestEmail}">
                                <input type="hidden" name="phone" value="${not empty phone ? phone : guestPhone}">
                                <input type="hidden" name="addressLine" value="${not empty addressLine ? addressLine : guestAddress}">

                                <div>
                                    <label class="block text-base md:text-lg font-black text-[#1f2937] mb-3">Mã xác minh 6 số</label>

                                    <input type="text"
                                           name="otpCode"
                                           id="otpCode"
                                           maxlength="6"
                                           inputmode="numeric"
                                           autocomplete="one-time-code"
                                           placeholder="000000"
                                           class="w-full h-16 md:h-[72px] px-4 rounded-[24px] border-2 border-orange-200 bg-[#fffaf5]
                                           text-center text-3xl md:text-4xl font-black tracking-[0.22em] text-[#111827]
                                           outline-none focus:ring-4 focus:ring-orange-100 focus:border-orange-400
                                           placeholder:text-gray-400">

                                    <p id="otpInlineError"
                                       class="mt-2 text-sm font-semibold text-red-600 ${not empty error and otpSent ? '' : 'hidden'}">
                                        <c:if test="${not empty error and otpSent}">${error}</c:if>
                                        </p>

                                        <p class="mt-2 text-sm text-gray-500">
                                            Mã OTP chỉ có hiệu lực trong 2 phút.
                                        </p>
                                    </div>

                                    <button type="submit"
                                            id="verifyOtpBtn"
                                            class="w-full h-12 rounded-full bg-[#0f172a] hover:bg-black text-white text-base md:text-lg font-black shadow transition disabled:opacity-60 disabled:cursor-not-allowed">
                                        Tiếp tục thanh toán
                                    </button>
                                </form>
                            </div>
                    </c:if>
                </div>
            </div>
        </main>

        <jsp:include page="footer.jsp" />

        <c:if test="${otpSent and not empty otpExpiresAt}">
            <script>
                window.otpExpiresAt = ${otpExpiresAt};
            </script>
        </c:if>

        <script>
            document.addEventListener("DOMContentLoaded", function () {
                const sendBtn = document.getElementById("sendOtpBtn");
                const verifyBtn = document.getElementById("verifyOtpBtn");
                const otpInput = document.getElementById("otpCode");
                const countdownEl = document.getElementById("otpCountdown");
                const inlineError = document.getElementById("otpInlineError");
                const verifyForm = document.getElementById("verifyOtpForm");

            <c:if test="${otpSent}">
                if (sendBtn) {
                    sendBtn.disabled = true;
                }
            </c:if>

                if (otpInput) {
                    otpInput.addEventListener("input", function () {
                        this.value = this.value.replace(/\D/g, "").slice(0, 6);

                        if (inlineError) {
                            inlineError.textContent = "";
                            inlineError.classList.add("hidden");
                        }
                    });

                    otpInput.addEventListener("paste", function (e) {
                        e.preventDefault();
                        const pasted = (e.clipboardData || window.clipboardData).getData("text");
                        this.value = pasted.replace(/\D/g, "").slice(0, 6);

                        if (inlineError) {
                            inlineError.textContent = "";
                            inlineError.classList.add("hidden");
                        }
                    });
                }

                if (verifyForm) {
                    verifyForm.addEventListener("submit", async function (e) {
                        e.preventDefault();

                        if (inlineError) {
                            inlineError.textContent = "";
                            inlineError.classList.add("hidden");
                        }

                        const otpValue = otpInput ? otpInput.value.trim() : "";

                        if (!otpValue) {
                            showInlineError("Vui lòng nhập mã OTP.");
                            return;
                        }

                        if (!/^\d{6}$/.test(otpValue)) {
                            showInlineError("Mã OTP phải gồm đúng 6 chữ số.");
                            return;
                        }

                        if (verifyBtn) {
                            verifyBtn.disabled = true;
                        }

                        try {
                            const formData = new FormData(verifyForm);

                            const response = await fetch(verifyForm.action, {
                                method: "POST",
                                body: formData,
                                headers: {
                                    "X-Requested-With": "XMLHttpRequest"
                                }
                            });

                            const data = await response.json();

                            if (data.success) {
                                window.location.href = data.redirect;
                                return;
                            }

                            if (data.message) {
                                showInlineError(data.message);
                            }

                            if (data.expired) {
                                if (otpInput) {
                                    otpInput.disabled = true;
                                    otpInput.value = "";
                                    otpInput.placeholder = "000000";
                                    otpInput.classList.add("opacity-60", "cursor-not-allowed");
                                }

                                if (verifyBtn) {
                                    verifyBtn.disabled = true;
                                }

                                if (sendBtn) {
                                    sendBtn.disabled = false;
                                    sendBtn.textContent = "Gửi lại mã OTP";
                                    sendBtn.classList.remove("opacity-60", "cursor-not-allowed");
                                }
                            }
                        } catch (err) {
                            showInlineError("Có lỗi xảy ra khi xác thực OTP. Vui lòng thử lại.");
                        } finally {
                            if (verifyBtn && !(otpInput && otpInput.disabled)) {
                                verifyBtn.disabled = false;
                            }
                        }
                    });
                }

                if (window.otpExpiresAt && countdownEl) {
                    const timer = setInterval(() => {
                        const remain = window.otpExpiresAt - Date.now();

                        if (remain <= 0) {
                            clearInterval(timer);
                            countdownEl.textContent = "00:00";

                            if (otpInput) {
                                otpInput.disabled = true;
                                otpInput.value = "";
                                otpInput.placeholder = "000000";
                                otpInput.classList.add("opacity-60", "cursor-not-allowed");
                            }

                            if (verifyBtn) {
                                verifyBtn.disabled = true;
                            }

                            if (sendBtn) {
                                sendBtn.disabled = false;
                                sendBtn.textContent = "Gửi lại mã OTP";
                                sendBtn.classList.remove("opacity-60", "cursor-not-allowed");
                            }

                            if (inlineError) {
                                inlineError.textContent = "Mã xác minh đã hết hạn. Vui lòng bấm Gửi lại mã OTP.";
                                inlineError.classList.remove("hidden");
                            }
                            return;
                        }

                        const totalSeconds = Math.floor(remain / 1000);
                        const minutes = String(Math.floor(totalSeconds / 60)).padStart(2, "0");
                        const seconds = String(totalSeconds % 60).padStart(2, "0");
                        countdownEl.textContent = minutes + ":" + seconds;
                    }, 1000);
                }

                function showInlineError(message) {
                    if (inlineError) {
                        inlineError.textContent = message;
                        inlineError.classList.remove("hidden");
                    }
                }
            });
        </script>
    </body>
</html>