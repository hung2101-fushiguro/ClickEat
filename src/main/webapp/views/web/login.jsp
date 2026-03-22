<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>Đăng nhập - Click Eat</title>
        <link rel="icon" type="image/png" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <link rel="shortcut icon" href="${pageContext.request.contextPath}/logo-icon.png?v=2">
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">

        <style>
            :root{
                --bg: #f3f4f6;
                --card: #ffffff;
                --text: #111827;
                --muted: #6b7280;
                --line: #e5e7eb;
                --primary: #ff7a1a;
                --primary-hover:#ff6a00;
                --shadow: 0 22px 60px rgba(0,0,0,.12);
                --radius: 18px;
            }

            *{
                box-sizing:border-box;
            }
            body{
                margin:0;
                min-height:100vh;
                font-family: Inter, system-ui, -apple-system, Segoe UI, Roboto, Arial, sans-serif;
                background: radial-gradient(1200px 500px at 50% 0%, #ffffff 0%, var(--bg) 55%, #eef2f7 100%);
                display:flex;
                align-items:center;
                justify-content:center;
                padding:32px 18px;
                color:var(--text);
            }

            .frame{
                border: none;
                padding: 0;
                background: transparent;
            }

            .card{
                width:100%;
                background:var(--card);
                border-radius: var(--radius);
                box-shadow: var(--shadow);
                overflow:hidden;
                display:grid;
                grid-template-columns: 1.1fr 0.9fr;
                min-height: 560px;
            }

            /* LEFT (Hero) */
            .hero{
                position:relative;
                padding:28px;
                background:
                    linear-gradient(90deg, rgba(0,0,0,.65) 0%, rgba(0,0,0,.25) 55%, rgba(0,0,0,.10) 100%),
                    url("https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?auto=format&fit=crop&w=1400&q=80");
                background-size:cover;
                background-position:center;
            }

            .brand{
                display:flex;
                align-items:center;
                gap:10px;
                color:#fff;
                font-weight:700;
                letter-spacing:.2px;
                opacity:.95;
            }
            .brand .logo{
                width:34px;
                height:34px;
                border-radius:10px;
                background: rgba(255,122,26,.95);
                display:grid;
                place-items:center;
                box-shadow: 0 10px 24px rgba(255,122,26,.35);
            }
            .brand .logo::before{
                content:"";
                width:14px;
                height:14px;
                background:#fff;
                border-radius:3px;
                display:block;
                clip-path: polygon(0 20%, 70% 20%, 70% 0, 100% 0, 100% 100%, 0 100%);
            }

            .hero h1{
                margin:32px 0 10px;
                font-size: clamp(34px, 4.2vw, 56px);
                line-height:1.02;
                color:#fff;
                font-weight:800;
                letter-spacing:-.8px;
            }
            .hero h1 .thin{
                display:block;
                font-weight:800;
            }
            .hero p{
                margin:0;
                color: rgba(255,255,255,.86);
                max-width: 420px;
                font-size: 14px;
                line-height: 1.65;
            }

            .bullets{
                position:absolute;
                left:28px;
                bottom:26px;
                display:flex;
                flex-direction:column;
                gap:12px;
                color:#fff;
                font-size:14px;
            }
            .bullet{
                display:flex;
                align-items:center;
                gap:10px;
                color: rgba(255,255,255,.90);
                text-shadow: 0 8px 26px rgba(0,0,0,.35);
            }
            .check{
                width:18px;
                height:18px;
                border-radius:999px;
                background: rgba(255,255,255,.92);
                display:grid;
                place-items:center;
                flex: 0 0 auto;
            }
            .check::before{
                content:"";
                width:8px;
                height:4px;
                border-left:2px solid #111827;
                border-bottom:2px solid #111827;
                transform: rotate(-45deg);
                display:block;
                margin-top:-1px;
            }

            /* RIGHT (Form) */
            .formWrap{
                padding:40px 44px;
                display:flex;
                flex-direction:column;
                justify-content:center;
            }

            .title{
                font-size:30px;
                font-weight:800;
                margin:0 0 8px;
                letter-spacing:-.3px;
            }
            .subtitle{
                margin:0 0 26px;
                color:var(--muted);
                font-size:14px;
                line-height:1.6;
            }

            .alert{
                border-radius:12px;
                padding:12px 14px;
                font-size:14px;
                margin: 0 0 14px;
                border: 1px solid;
            }
            .alert.error{
                background:#fff1f2;
                border-color:#fecdd3;
                color:#9f1239;
            }
            .alert.success{
                background:#ecfdf5;
                border-color:#a7f3d0;
                color:#065f46;
            }

            .field{
                margin-bottom:14px;
            }
            label{
                display:block;
                font-size:13px;
                font-weight:600;
                color:#374151;
                margin: 0 0 8px;
            }

            .input{
                width:100%;
                height:44px;
                padding: 0 14px;
                border-radius: 12px;
                border:1px solid var(--line);
                outline:none;
                font-size:14px;
                transition: .15s ease;
                background:#fff;
            }
            .input:focus{
                border-color: rgba(255,122,26,.65);
                box-shadow: 0 0 0 4px rgba(255,122,26,.16);
            }

            .passwordWrap{
                position:relative;
            }
            .toggle{
                position:absolute;
                right:10px;
                top:50%;
                transform: translateY(-50%);
                width:34px;
                height:34px;
                border:none;
                background:transparent;
                cursor:pointer;
                border-radius:10px;
                display:grid;
                place-items:center;
                color:#6b7280;
            }
            .toggle:hover{
                background:#f3f4f6;
            }

            .row{
                margin: 10px 0 18px;
                display:flex;
                align-items:center;
                justify-content:space-between;
                gap:12px;
                font-size:13px;
            }
            .remember{
                display:flex;
                align-items:center;
                gap:8px;
                color:#374151;
                user-select:none;
            }
            .remember input{
                width:16px;
                height:16px;
                accent-color: var(--primary);
            }
            .link{
                color: var(--primary);
                text-decoration:none;
                font-weight:600;
            }
            .link:hover{
                text-decoration:underline;
            }

            .btn{
                width:100%;
                height:46px;
                border:none;
                border-radius: 14px;
                cursor:pointer;
                font-weight:700;
                font-size:15px;
                transition: .15s ease;
            }
            .btn.primary{
                background: var(--primary);
                color:#fff;
                box-shadow: 0 14px 30px rgba(255,122,26,.32);
            }
            .btn.primary:hover{
                background: var(--primary-hover);
                transform: translateY(-1px);
            }
            .btn.primary:active{
                transform: translateY(0px);
            }

            .divider{
                display:flex;
                align-items:center;
                gap:12px;
                margin: 18px 0 14px;
                color:#9ca3af;
                font-size:12px;
                font-weight:700;
                letter-spacing:.8px;
            }
            .divider::before, .divider::after{
                content:"";
                height:1px;
                background: var(--line);
                flex:1;
            }

            .btn.google{
                background:#fff;
                border:1px solid var(--line);
                color:#111827;
                font-weight:700;
                display:flex;
                align-items:center;
                justify-content:center;
                gap:10px;
            }
            .btn.google:hover{
                background:#fafafa;
                border-color:#d1d5db;
            }

            .googleIcon{
                width:18px;
                height:18px;
            }

            .footer{
                margin-top:18px;
                text-align:center;
                color:var(--muted);
                font-size:13px;
                line-height:1.7;
            }
            .footer .small{
                font-size:12px;
                color:#9ca3af;
            }

            /* Responsive */
            @media (max-width: 980px){
                .card{
                    grid-template-columns: 1fr;
                }
                .hero{
                    min-height: 360px;
                }
                .formWrap{
                    padding:32px 22px;
                }
                .bullets{
                    position:static;
                    margin-top:22px;
                }
            }
        </style>
    </head>

    <body>
        <div class="frame">
            <div class="card">
                <!-- LEFT -->
                <section class="hero">
                    <div class="brand">
                        <div class="logo" aria-hidden="true"></div>
                        <div>Click Eat</div>
                    </div>

                    <h1>
                        Ăn ngon mỗi ngày
                        <span class="thin">— giao nhanh tận nơi</span>
                    </h1>

                    <p>Đăng nhập để đặt món, theo dõi đơn và nhận ưu đãi độc quyền từ các thương hiệu hàng đầu.</p>

                    <div class="bullets">
                        <div class="bullet"><span class="check"></span> Freeship &amp; deal mỗi ngày</div>
                        <div class="bullet"><span class="check"></span> Gợi ý món theo sở thích</div>
                        <div class="bullet"><span class="check"></span> Theo dõi đơn real-time</div>
                    </div>
                </section>

                <!-- RIGHT -->
                <section class="formWrap">
                    <h2 class="title">Đăng nhập</h2>
                    <p class="subtitle">Chào mừng bạn quay lại! Vui lòng nhập thông tin.</p>

                    <c:if test="${not empty error}">
                        <div class="alert error">${error}</div>
                    </c:if>
                    <c:if test="${not empty message}">
                        <div class="alert success">✅ ${message}</div>
                    </c:if>

                    <!-- ✅ FIX 2: action dùng contextPath để không bị sai route -->
                    <form action="${pageContext.request.contextPath}/login" method="post" autocomplete="on">
                        <div class="field">
                            <label>Email hoặc Số điện thoại</label>
                            <!-- giữ name giống code cũ của bạn -->
                            <input class="input"
                                   type="text"
                                   name="username"
                                   value="${username}"
                                   placeholder="example@email.com"
                                   required>
                        </div>

                        <div class="field">
                            <label>Mật khẩu</label>
                            <div class="passwordWrap">
                                <input class="input" id="password" type="password" name="password" placeholder="••••••••" required>
                                <button class="toggle" type="button" aria-label="Hiện/ẩn mật khẩu" onclick="togglePassword()">
                                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" aria-hidden="true">
                                    <path d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7S2 12 2 12Z" stroke="currentColor" stroke-width="2"/>
                                    <path d="M12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6Z" stroke="currentColor" stroke-width="2"/>
                                    </svg>
                                </button>
                            </div>
                        </div>

                        <div class="row">
                            <label class="remember">
                                <input type="checkbox" name="remember" value="1"
                                       <c:if test="${remember}">checked</c:if>>
                                       Ghi nhớ đăng nhập
                                </label>

                                <a class="link" href="${pageContext.request.contextPath}/forgot-password">Quên mật khẩu?</a>
                        </div>

                        <button class="btn primary" type="submit">Đăng nhập</button>

                        <div class="divider">HOẶC</div>

                        <!-- Nếu bạn có OAuth Google: đổi href sang endpoint của bạn (vd: google-login) -->
                        <button class="btn google" type="button" onclick="location.href = '${pageContext.request.contextPath}/google-login'">
                            <svg class="googleIcon" viewBox="0 0 48 48" aria-hidden="true">
                            <path fill="#FFC107" d="M43.6 20.5H42V20H24v8h11.3C33.7 32.7 29.3 36 24 36c-6.6 0-12-5.4-12-12s5.4-12 12-12c3.1 0 5.9 1.2 8 3.1l5.7-5.7C34.2 6.1 29.3 4 24 4 12.9 4 4 12.9 4 24s8.9 20 20 20 20-8.9 20-20c0-1.1-.1-2.3-.4-3.5z"/>
                            <path fill="#FF3D00" d="M6.3 14.7l6.6 4.8C14.7 15.5 19 12 24 12c3.1 0 5.9 1.2 8 3.1l5.7-5.7C34.2 6.1 29.3 4 24 4 16.3 4 9.6 8.3 6.3 14.7z"/>
                            <path fill="#4CAF50" d="M24 44c5.2 0 10-2 13.6-5.2l-6.3-5.1C29.2 35.6 26.7 36 24 36c-5.3 0-9.7-3.4-11.3-8.1l-6.5 5C9.4 39.6 16.2 44 24 44z"/>
                            <path fill="#1976D2" d="M43.6 20.5H42V20H24v8h11.3c-.8 2.3-2.4 4.2-4.6 5.7l.1-.1 6.3 5.1C36.8 39 44 34 44 24c0-1.1-.1-2.3-.4-3.5z"/>
                            </svg>
                            Tiếp tục với Google
                        </button>

                        <div class="footer">
                            Chưa có tài khoản? <a class="link" href="${pageContext.request.contextPath}/register">Đăng ký</a><br/>
                            <span class="small">Bạn là đối tác? <a class="link" href="${pageContext.request.contextPath}/merchant-login">Đăng nhập Merchant</a> · <a class="link" href="${pageContext.request.contextPath}/merchant-register">Đi tới Merchant</a></span>
                        </div>
                    </form>
                </section>
            </div>
        </div>

        <script>
            function togglePassword() {
                const p = document.getElementById('password');
                p.type = (p.type === 'password') ? 'text' : 'password';
            }
        </script>
    </body>
</html>