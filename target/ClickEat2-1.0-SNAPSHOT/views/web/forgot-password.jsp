<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ClickEat - Quên mật khẩu</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css">
</head>
<body class="min-h-screen bg-[#f4f5f7] text-gray-900">
    <c:set var="ctx" value="${pageContext.request.contextPath}" />

    <div class="min-h-screen flex items-center justify-center px-4 py-10">
        <div class="w-full max-w-2xl bg-white rounded-[32px] border border-gray-200 shadow-[0_10px_30px_rgba(15,23,42,.06)] overflow-hidden">
            <div class="px-8 md:px-10 pt-8 md:pt-10 pb-6 border-b border-gray-100 bg-gradient-to-r from-orange-50 to-white">
                <a href="${ctx}/login" class="inline-flex items-center gap-2 text-sm font-bold text-orange-500 hover:text-orange-600">
                    <i class="fa-solid fa-arrow-left"></i>
                    Quay lại đăng nhập
                </a>
                <h1 class="mt-4 text-4xl font-black tracking-tight">Quên mật khẩu</h1>
                <p class="mt-3 text-gray-500 text-lg">
                    Nhập email, xác minh mã OTP và tạo mật khẩu mới cho tài khoản ClickEat của bạn.
                </p>
            </div>

            <div class="px-8 md:px-10 py-8">
                <c:if test="${not empty error}">
                    <div class="mb-6 rounded-2xl border border-red-200 bg-red-50 text-red-700 px-5 py-4 font-semibold">
                        ${error}
                    </div>
                </c:if>

                <c:if test="${not empty success}">
                    <div class="mb-6 rounded-2xl border border-green-200 bg-green-50 text-green-700 px-5 py-4 font-semibold">
                        ${success}
                    </div>
                </c:if>

                <!-- STEP 1 -->
                <form id="sendCodeForm" action="${ctx}/forgot-password" method="post" class="space-y-5">
                    <input type="hidden" name="action" value="send-code" />

                    <div>
                        <label class="block text-sm font-bold text-gray-800 mb-2">Địa chỉ email</label>
                        <input type="email"
                               id="emailInput"
                               name="email"
                               value="${email}"
                               maxlength="150"
                               required
                               ${showResetSection ? 'disabled' : ''}
                               class="w-full h-12 px-4 rounded-2xl border border-gray-200 bg-white text-gray-900 outline-none focus:ring-4 focus:ring-orange-100 focus:border-orange-400 transition disabled:bg-gray-100 disabled:text-gray-500"
                               placeholder="Nhập email tài khoản của bạn">
                    </div>

                    <div class="flex justify-start">
                        <button type="submit"
                                id="sendCodeBtn"
                                ${showResetSection ? 'disabled' : ''}
                                class="inline-flex items-center gap-2 h-12 px-6 rounded-full bg-orange-500 text-white font-extrabold hover:bg-orange-600 transition shadow disabled:bg-gray-300 disabled:text-white disabled:cursor-not-allowed">
                            <i class="fa-regular fa-paper-plane"></i>
                            <span id="sendCodeBtnText">Gửi mã</span>
                        </button>
                    </div>
                </form>

                <!-- STEP 2 -->
                <c:if test="${showVerifySection}">
                    <div class="mt-8 pt-8 border-t border-gray-100">
                        <h2 class="text-2xl font-black">Nhập mã xác minh</h2>
                        <p class="mt-2 text-gray-500">
                            Mã OTP đã được gửi đến:
                            <span class="font-bold text-gray-800">${email}</span>
                        </p>

                        <div class="mt-4 inline-flex items-center gap-2 rounded-full bg-orange-50 text-orange-600 px-4 py-2 font-extrabold">
                            <i class="fa-regular fa-clock"></i>
                            Còn lại: <span id="countdown">60</span>s
                        </div>

                        <form id="verifyOtpForm" action="${ctx}/forgot-password" method="post" class="mt-6 space-y-5">
                            <input type="hidden" name="action" value="verify-code" />

                            <div>
                                <label class="block text-sm font-bold text-gray-800 mb-2">Mã xác minh 6 số</label>
                                <input type="text"
                                       name="otpCode"
                                       id="otpCode"
                                       maxlength="6"
                                       inputmode="numeric"
                                       autocomplete="one-time-code"
                                       required
                                       ${showResetSection ? 'disabled' : ''}
                                       class="w-full h-12 px-4 rounded-2xl border border-gray-200 bg-white text-gray-900 outline-none focus:ring-4 focus:ring-orange-100 focus:border-orange-400 transition tracking-[0.35em] text-center font-black text-xl disabled:bg-gray-100 disabled:text-gray-500"
                                       placeholder="000000">
                            </div>

                            <div id="otpClientError"
                                 class="hidden rounded-2xl border border-red-200 bg-red-50 text-red-700 px-5 py-4 font-semibold"></div>

                            <div class="flex justify-start">
                                <button type="submit"
                                        id="verifyOtpBtn"
                                        ${showResetSection ? 'disabled' : ''}
                                        class="inline-flex items-center gap-2 h-12 px-6 rounded-full bg-gray-900 text-white font-extrabold hover:bg-black transition disabled:bg-gray-300 disabled:text-white disabled:cursor-not-allowed">
                                    <i class="fa-solid fa-check"></i>
                                    Xác minh mã
                                </button>
                            </div>
                        </form>
                    </div>
                </c:if>

                <!-- STEP 3 -->
                <c:if test="${showResetSection}">
                    <div class="mt-8 pt-8 border-t border-gray-100">
                        <h2 class="text-2xl font-black">Tạo mật khẩu mới</h2>
                        <p class="mt-2 text-gray-500">
                            Hãy nhập mật khẩu mới cho tài khoản của bạn.
                        </p>

                        <form id="resetPasswordForm" action="${ctx}/forgot-password" method="post" class="mt-6 space-y-5">
                            <input type="hidden" name="action" value="save-password" />

                            <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
                                <div>
                                    <label class="block text-sm font-bold text-gray-800 mb-2">Mật khẩu mới</label>
                                    <input type="password"
                                           name="newPassword"
                                           id="newPassword"
                                           minlength="6"
                                           maxlength="100"
                                           required
                                           class="w-full h-12 px-4 rounded-2xl border border-gray-200 bg-white text-gray-900 outline-none focus:ring-4 focus:ring-orange-100 focus:border-orange-400 transition"
                                           placeholder="Nhập mật khẩu mới">
                                    <div id="newPasswordHint" class="mt-2 text-sm text-gray-500">
                                        Mật khẩu phải từ 6 đến 100 ký tự.
                                    </div>
                                </div>

                                <div>
                                    <label class="block text-sm font-bold text-gray-800 mb-2">Xác nhận mật khẩu mới</label>
                                    <input type="password"
                                           name="confirmPassword"
                                           id="confirmPassword"
                                           minlength="6"
                                           maxlength="100"
                                           required
                                           class="w-full h-12 px-4 rounded-2xl border border-gray-200 bg-white text-gray-900 outline-none focus:ring-4 focus:ring-orange-100 focus:border-orange-400 transition"
                                           placeholder="Nhập lại mật khẩu mới">
                                    <div id="confirmPasswordHint" class="mt-2 text-sm text-gray-500">
                                        Nhập lại chính xác mật khẩu mới.
                                    </div>
                                </div>
                            </div>

                            <div id="clientError"
                                 class="hidden rounded-2xl border border-red-200 bg-red-50 text-red-700 px-5 py-4 font-semibold"></div>

                            <div class="flex justify-end">
                                <button type="submit"
                                        id="savePasswordBtn"
                                        class="inline-flex items-center gap-2 h-12 px-6 rounded-full bg-orange-500 text-white font-extrabold hover:bg-orange-600 transition shadow disabled:bg-gray-300 disabled:cursor-not-allowed">
                                    <i class="fa-regular fa-floppy-disk"></i>
                                    Lưu mật khẩu
                                </button>
                            </div>
                        </form>
                    </div>
                </c:if>
            </div>
        </div>
    </div>

    <script>
        (() => {
            const expiresAt = ${expiresAt != null ? expiresAt : 0};
            const isResetSectionVisible = ${showResetSection ? 'true' : 'false'};

            const sendCodeBtn = document.getElementById('sendCodeBtn');
            const sendCodeBtnText = document.getElementById('sendCodeBtnText');
            const verifyOtpBtn = document.getElementById('verifyOtpBtn');
            const otpInput = document.getElementById('otpCode');
            const otpClientError = document.getElementById('otpClientError');
            const countdownEl = document.getElementById('countdown');

            const newPassword = document.getElementById('newPassword');
            const confirmPassword = document.getElementById('confirmPassword');
            const newPasswordHint = document.getElementById('newPasswordHint');
            const confirmPasswordHint = document.getElementById('confirmPasswordHint');
            const savePasswordBtn = document.getElementById('savePasswordBtn');
            const clientError = document.getElementById('clientError');
            const resetPasswordForm = document.getElementById('resetPasswordForm');

            function setSendButtonDisabled(disabled, text) {
                if (!sendCodeBtn) return;
                sendCodeBtn.disabled = disabled;
                if (sendCodeBtnText && text) {
                    sendCodeBtnText.textContent = text;
                }
            }

            function setVerifyButtonDisabled(disabled) {
                if (!verifyOtpBtn) return;
                verifyOtpBtn.disabled = disabled;
            }

            function setTextState(el, ok, message) {
                if (!el) return;
                el.textContent = message;
                el.classList.remove('text-gray-500', 'text-red-600', 'text-green-600');
                el.classList.add(ok ? 'text-green-600' : 'text-red-600');
            }

            function setNeutralText(el, message) {
                if (!el) return;
                el.textContent = message;
                el.classList.remove('text-red-600', 'text-green-600');
                el.classList.add('text-gray-500');
            }

            function validatePasswordRealtime() {
                if (!newPassword || !confirmPassword || !savePasswordBtn) return true;

                const newPass = newPassword.value;
                const confirmPass = confirmPassword.value;

                let valid = true;

                if (newPass.length === 0) {
                    setNeutralText(newPasswordHint, 'Mật khẩu phải từ 6 đến 100 ký tự.');
                    valid = false;
                } else if (newPass.length < 6 || newPass.length > 100) {
                    setTextState(newPasswordHint, false, 'Mật khẩu mới phải từ 6 đến 100 ký tự.');
                    valid = false;
                } else {
                    setTextState(newPasswordHint, true, 'Mật khẩu mới hợp lệ.');
                }

                if (confirmPass.length === 0) {
                    setNeutralText(confirmPasswordHint, 'Nhập lại chính xác mật khẩu mới.');
                    valid = false;
                } else if (newPass !== confirmPass) {
                    setTextState(confirmPasswordHint, false, 'Xác nhận mật khẩu không khớp.');
                    valid = false;
                } else {
                    setTextState(confirmPasswordHint, true, 'Xác nhận mật khẩu khớp.');
                }

                savePasswordBtn.disabled = !valid;
                return valid;
            }

            if (otpInput) {
                otpInput.addEventListener('input', function () {
                    this.value = this.value.replace(/\D/g, '').slice(0, 6);
                });
            }

            if (isResetSectionVisible) {
                setSendButtonDisabled(true, 'Đã xác minh');
                setVerifyButtonDisabled(true);
                if (otpInput) {
                    otpInput.disabled = true;
                }
            } else if (countdownEl && expiresAt > 0) {
                function tick() {
                    const remainMs = expiresAt - Date.now();
                    const remainSec = Math.max(0, Math.ceil(remainMs / 1000));
                    countdownEl.textContent = remainSec;

                    if (remainSec > 0) {
                        setSendButtonDisabled(true, 'Đã gửi mã');
                        setVerifyButtonDisabled(false);
                        setTimeout(tick, 250);
                    } else {
                        countdownEl.textContent = '0';
                        setSendButtonDisabled(false, 'Gửi lại mã');
                        setVerifyButtonDisabled(true);

                        if (otpClientError) {
                            otpClientError.textContent = 'Mã xác minh đã hết hạn. Vui lòng bấm Gửi lại mã.';
                            otpClientError.classList.remove('hidden');
                        }
                    }
                }
                tick();
            } else {
                setSendButtonDisabled(false, 'Gửi mã');
            }

            const verifyForm = document.getElementById('verifyOtpForm');
            if (verifyForm) {
                verifyForm.addEventListener('submit', function (e) {
                    if (isResetSectionVisible) {
                        e.preventDefault();
                        return;
                    }

                    if (!otpInput) return;

                    const code = otpInput.value.replace(/\D/g, '');

                    if (countdownEl && countdownEl.textContent === '0') {
                        e.preventDefault();
                        if (otpClientError) {
                            otpClientError.textContent = 'Mã xác minh đã hết hạn. Vui lòng bấm Gửi lại mã.';
                            otpClientError.classList.remove('hidden');
                        }
                        return;
                    }

                    if (!/^\d{6}$/.test(code)) {
                        e.preventDefault();
                        if (otpClientError) {
                            otpClientError.textContent = 'Mã xác minh phải gồm đúng 6 chữ số.';
                            otpClientError.classList.remove('hidden');
                        }
                        return;
                    }

                    otpInput.value = code;
                    if (otpClientError) {
                        otpClientError.classList.add('hidden');
                    }
                });
            }

            if (newPassword) {
                newPassword.addEventListener('input', validatePasswordRealtime);
            }

            if (confirmPassword) {
                confirmPassword.addEventListener('input', validatePasswordRealtime);
            }

            if (resetPasswordForm && clientError) {
                validatePasswordRealtime();

                resetPasswordForm.addEventListener('submit', function (e) {
                    const valid = validatePasswordRealtime();

                    if (!valid) {
                        e.preventDefault();
                        clientError.textContent = 'Vui lòng kiểm tra lại mật khẩu mới và xác nhận mật khẩu.';
                        clientError.classList.remove('hidden');
                        return;
                    }

                    clientError.classList.add('hidden');
                });
            }
        })();
    </script>
</body>
</html>