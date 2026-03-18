<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<%@taglib prefix="fmt" uri="jakarta.tags.fmt" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ClickEat - Trang chủ</title>

        <script>
            const originalWarn = console.warn;
            console.warn = function() {
                if (arguments[0] && typeof arguments[0] === 'string' && arguments[0].includes('cdn.tailwindcss.com should not be used in production')) return;
                originalWarn.apply(console, arguments);
            };
        </script>
        <script src="https://cdn.tailwindcss.com"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css" crossorigin="anonymous" referrerpolicy="no-referrer">

        <style>
            :root{
                --bg:#f4f5f7;
                --card:#ffffff;
                --text:#111827;
                --muted:#6b7280;
                --line:#e5e7eb;
                --primary:#ff7a1a;
                --primary-hover:#f26c00;
                --shadow:0 10px 30px rgba(15,23,42,.06);
                --shadow-hover:0 18px 40px rgba(15,23,42,.10);
                --radius:28px;
            }

            *{
                box-sizing:border-box;
            }

            html{
                scroll-behavior:smooth;
            }

            body{
                margin:0;
                font-family:Inter,system-ui,-apple-system,Segoe UI,Roboto,Arial,sans-serif;
                background:var(--bg);
                color:var(--text);
            }

            .container-click{
                width:min(1280px, calc(100% - 56px));
                margin:0 auto;
            }

            .shadow-soft{
                box-shadow:var(--shadow);
            }

            .card-hover{
                transition:transform .22s ease, box-shadow .22s ease;
            }

            .card-hover:hover{
                transform:translateY(-5px);
                box-shadow:var(--shadow-hover);
            }

            .section-title{
                font-size:34px;
                line-height:1.05;
                font-weight:900;
                letter-spacing:-.03em;
                color:#131313;
            }

            .section-link{
                color:var(--primary);
                font-weight:800;
                font-size:16px;
                display:inline-flex;
                align-items:center;
                gap:10px;
                transition:.2s ease;
            }

            .section-link:hover{
                color:var(--primary-hover);
            }

            .line-clamp-1{
                display:-webkit-box;
                -webkit-line-clamp:1;
                -webkit-box-orient:vertical;
                overflow:hidden;
            }

            .line-clamp-2{
                display:-webkit-box;
                -webkit-line-clamp:2;
                -webkit-box-orient:vertical;
                overflow:hidden;
            }

            .hero-wrap{
                display:grid;
                grid-template-columns:minmax(0,1.45fr) minmax(320px,.7fr);
                gap:28px;
                align-items:stretch;
            }

            .hero-main{
                position:relative;
                min-height:520px;
                border-radius:34px;
                overflow:hidden;
                box-shadow:0 18px 50px rgba(0,0,0,.08);
            }

            .hero-main img{
                position:absolute;
                inset:0;
                width:100%;
                height:100%;
                object-fit:cover;
            }

            .hero-main::after{
                content:"";
                position:absolute;
                inset:0;
                background:
                    linear-gradient(90deg, rgba(0,0,0,.58) 0%, rgba(0,0,0,.36) 38%, rgba(0,0,0,.12) 100%);
            }

            .hero-content{
                position:relative;
                z-index:2;
                height:100%;
                padding:56px 42px 48px;
                display:flex;
                flex-direction:column;
                justify-content:center;
            }

            .hero-badge{
                display:inline-flex;
                align-items:center;
                justify-content:center;
                width:max-content;
                min-height:48px;
                padding:0 26px;
                border-radius:999px;
                background:var(--primary);
                color:#fff;
                font-weight:900;
                font-size:14px;
                letter-spacing:.02em;
                margin-bottom:24px;
                box-shadow:0 10px 24px rgba(255,122,26,.28);
            }

            .hero-title{
                margin:0;
                max-width:820px;
                color:#fff;
                font-size:68px;
                line-height:.95;
                letter-spacing:-.05em;
                font-weight:950;
            }

            .hero-title .accent{
                color:var(--primary);
            }

            .hero-desc{
                margin:26px 0 0;
                max-width:640px;
                color:rgba(255,255,255,.92);
                font-size:22px;
                line-height:1.55;
                font-weight:500;
            }

            .hero-actions{
                display:flex;
                flex-wrap:wrap;
                gap:16px;
                margin-top:34px;
            }

            .hero-btn-primary,
            .hero-btn-secondary{
                min-width:280px;
                height:64px;
                padding:0 30px;
                border-radius:999px;
                display:inline-flex;
                align-items:center;
                justify-content:center;
                font-size:18px;
                font-weight:900;
                transition:.22s ease;
            }

            .hero-btn-primary{
                background:var(--primary);
                color:#fff;
                box-shadow:0 12px 26px rgba(255,122,26,.22);
            }

            .hero-btn-primary:hover{
                background:var(--primary-hover);
                transform:translateY(-1px);
            }

            .hero-btn-secondary{
                background:rgba(255,255,255,.14);
                color:#fff;
                border:1.5px solid rgba(255,255,255,.36);
                backdrop-filter:blur(8px);
            }

            .hero-btn-secondary:hover{
                background:rgba(255,255,255,.22);
                transform:translateY(-1px);
            }

            .hero-side{
                display:grid;
                grid-template-rows:1fr 1fr;
                gap:22px;
            }

            .hero-mini{
                border-radius:32px;
                padding:38px 34px;
                box-shadow:var(--shadow);
                position:relative;
                overflow:hidden;
                min-height:248px;
                display:flex;
                flex-direction:column;
                justify-content:space-between;
            }

            .hero-mini.orange{
                background:#ff6f0f;
                color:#fff;
            }

            .hero-mini.white{
                background:#fff;
                color:#182033;
            }

            .hero-mini-icon{
                position:absolute;
                right:-4px;
                bottom:-8px;
                font-size:138px;
                opacity:.10;
                pointer-events:none;
            }

            .hero-mini-shop{
                font-size:13px;
                font-weight:900;
                text-transform:uppercase;
                letter-spacing:.06em;
                opacity:.92;
            }

            .hero-mini-title{
                margin-top:6px;
                font-size:38px;
                line-height:1;
                font-weight:950;
                letter-spacing:-.04em;
            }

            .hero-mini-desc{
                margin-top:14px;
                font-size:18px;
                line-height:1.45;
                font-weight:600;
                opacity:.94;
                max-width:290px;
            }

            .hero-mini-code{
                margin-top:18px;
                font-size:17px;
                font-weight:900;
            }

            .hero-mini-btn{
                margin-top:22px;
                display:inline-flex;
                align-items:center;
                gap:10px;
                font-size:18px;
                font-weight:900;
                color:inherit;
            }

            .voucher-grid{
                display:grid;
                grid-template-columns:repeat(4, minmax(0, 1fr));
                gap:22px;
            }

            .voucher-modern{
                background:#fff;
                border-radius:28px;
                overflow:hidden;
                box-shadow:var(--shadow);
                border:1px solid rgba(226,232,240,.65);
                transition:transform .22s ease, box-shadow .22s ease;
            }

            .voucher-modern:hover{
                transform:translateY(-4px);
                box-shadow:var(--shadow-hover);
            }

            .voucher-top{
                min-height:180px;
                padding:26px 30px 30px;
                display:flex;
                flex-direction:column;
                justify-content:space-between;
                position:relative;
            }

            .voucher-style-1 .voucher-top{
                background:#dff3f0;
                color:#0f766e;
            }

            .voucher-style-2 .voucher-top{
                background:#f7e6f2;
                color:#c02674;
            }

            .voucher-style-3 .voucher-top{
                background:#f4eed6;
                color:#b45309;
            }

            .voucher-style-4 .voucher-top{
                background:#e6eefc;
                color:#2563eb;
            }

            .voucher-style-1 .voucher-icon{
                color:#2cb9a7;
            }
            .voucher-style-2 .voucher-icon{
                color:#ec4899;
            }
            .voucher-style-3 .voucher-icon{
                color:#eab308;
            }
            .voucher-style-4 .voucher-icon{
                color:#3b82f6;
            }

            .voucher-pill{
                display:inline-flex;
                align-items:center;
                justify-content:center;
                min-height:34px;
                width:max-content;
                padding:0 14px;
                border-radius:11px;
                color:#fff;
                font-size:11px;
                font-weight:900;
                text-transform:uppercase;
            }

            .voucher-style-1 .voucher-pill{
                background:#1fb8a9;
            }
            .voucher-style-2 .voucher-pill{
                background:#e24795;
            }
            .voucher-style-3 .voucher-pill{
                background:#f2a50c;
            }
            .voucher-style-4 .voucher-pill{
                background:#3b82f6;
            }

            .voucher-code-row{
                display:flex;
                align-items:flex-end;
                justify-content:space-between;
                gap:10px;
                margin-top:24px;
            }

            .voucher-code{
                font-size:30px;
                line-height:1;
                font-weight:950;
                letter-spacing:-.04em;
            }

            .voucher-copy{
                font-size:14px;
                font-weight:700;
                display:inline-flex;
                align-items:center;
                gap:7px;
                opacity:.95;
                margin-top:10px;
            }

            .voucher-icon{
                font-size:42px;
                opacity:.95;
                flex-shrink:0;
            }

            .voucher-bottom{
                padding:24px 30px 20px;
            }

            .voucher-bottom-title{
                font-size:18px;
                line-height:1.2;
                font-weight:950;
                color:#182033;
                letter-spacing:-.03em;
                margin:0;
            }

            .voucher-bottom-desc{
                margin:10px 0 0;
                color:#6b7280;
                font-size:13px;
                line-height:1.42;
                font-weight:500;
                min-height:0;
            }

            .voucher-expire{
                margin-top:16px;
                color:#9ca3af;
                font-size:11px;
                font-weight:800;
            }

            .voucher-action{
                margin-top:16px;
                display:flex;
                justify-content:flex-end;
            }

            .voucher-save-btn{
                min-width:122px;
                height:40px;
                padding:0 18px;
                border-radius:999px;
                background:var(--primary);
                color:#fff;
                display:inline-flex;
                align-items:center;
                justify-content:center;
                font-size:14px;
                font-weight:800;
                transition:.2s ease;
                box-shadow:0 10px 20px rgba(255,122,26,.16);
            }

            .voucher-save-btn:hover{
                background:var(--primary-hover);
                transform:translateY(-1px);
            }

            .pill{
                display:inline-flex;
                align-items:center;
                justify-content:center;
                padding:8px 14px;
                border-radius:999px;
                font-size:12px;
                font-weight:800;
                line-height:1;
                white-space:nowrap;
            }

            .pill-orange{
                background:#fff1e8;
                color:var(--primary);
            }

            .pill-green{
                background:#e9f8ee;
                color:#16a34a;
            }

            .pill-red{
                background:#fee2e2;
                color:#dc2626;
            }

            .soft-icon-box{
                width:98px;
                height:98px;
                border-radius:28px;
                display:flex;
                align-items:center;
                justify-content:center;
                box-shadow:0 14px 34px rgba(0,0,0,.07);
                margin:0 auto 18px;
            }

            .add-cart-btn{
                width:48px;
                height:48px;
                border-radius:999px;
                border:none;
                background:#fff3eb;
                color:var(--primary);
                display:flex;
                align-items:center;
                justify-content:center;
                font-size:18px;
                transition:.18s ease;
                flex-shrink:0;
            }

            .add-cart-btn:hover{
                background:var(--primary);
                color:#fff;
                transform:translateY(-1px);
            }

            .restaurant-card img,
            .food-card img{
                transition:.35s ease;
            }

            .restaurant-card:hover img,
            .food-card:hover img{
                transform:scale(1.05);
            }

            .deal-badge{
                background:#ef4444;
                color:#fff;
                font-size:12px;
                font-weight:800;
                border-radius:999px;
                padding:9px 14px;
                display:inline-flex;
                align-items:center;
                gap:6px;
                box-shadow:0 10px 22px rgba(239,68,68,.20);
            }

            .food-card{
                border-radius:30px;
            }

            .food-card .food-body{
                padding:24px 24px 22px;
            }

            .food-card .food-name{
                font-size:21px;
                font-weight:900;
                line-height:1.18;
                letter-spacing:-.02em;
                color:#111827;
            }

            .food-card .food-desc{
                color:#8b95a7;
                font-size:15px;
                line-height:1.6;
                min-height:25px;
            }

            .price-now{
                font-size:24px;
                font-weight:950;
                color:var(--primary);
                line-height:1;
                letter-spacing:-.03em;
            }

            .price-old{
                color:#9ca3af;
                text-decoration:line-through;
                font-size:14px;
                margin-top:8px;
                font-weight:700;
            }

            .restaurant-card{
                border-radius:30px;
            }

            .empty-box{
                background:#fff;
                border-radius:30px;
                border:1px dashed #d9dee7;
                padding:64px 24px;
                text-align:center;
                box-shadow:var(--shadow);
            }

            @media (max-width: 1400px){
                .voucher-grid{
                    grid-template-columns:repeat(4, minmax(0, 1fr));
                }
            }

            @media (max-width: 1200px){
                .voucher-grid{
                    grid-template-columns:repeat(2, minmax(0, 1fr));
                }
            }

            @media (max-width: 1024px){
                .container-click{
                    width:min(100% - 28px, 1280px);
                }

                .hero-wrap{
                    grid-template-columns:1fr;
                }

                .hero-side{
                    grid-template-columns:1fr 1fr;
                    grid-template-rows:auto;
                }

                .hero-title{
                    font-size:54px;
                }
            }

            @media (max-width: 768px){
                .section-title{
                    font-size:26px;
                }

                .hero-content{
                    padding:34px 24px 32px;
                }

                .hero-main{
                    min-height:460px;
                }

                .hero-title{
                    font-size:42px;
                }

                .hero-desc{
                    font-size:18px;
                    line-height:1.6;
                }

                .hero-btn-primary,
                .hero-btn-secondary{
                    width:100%;
                    min-width:unset;
                    height:56px;
                    font-size:17px;
                }

                .hero-side{
                    grid-template-columns:1fr;
                }

                .voucher-grid{
                    grid-template-columns:1fr;
                }

                .voucher-code{
                    font-size:30px;
                }

                .voucher-bottom-title{
                    font-size:20px;
                }

                .voucher-save-btn{
                    height:58px;
                    font-size:18px;
                }
            }
        </style>
    </head>
    <body>

        <c:set var="ctx" value="${pageContext.request.contextPath}" />

        <jsp:include page="header.jsp">
            <jsp:param name="activePage" value="home" />
        </jsp:include>

        <main class="pb-20">

            <!-- HERO -->
            <section class="pt-7">
                <div class="container-click">
                    <div class="hero-wrap">
                        <div class="hero-main">
                            <img
                                src="https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=1600&auto=format&fit=crop"
                                alt="Hero banner"
                                >

                            <div class="hero-content">
                                <div class="hero-badge">MỚI NHẤT</div>

                                <h1 class="hero-title">
                                    Ăn ngon mỗi ngày –
                                    <span class="accent">giao nhanh</span>
                                    tận nơi
                                </h1>

                                <p class="hero-desc">
                                    Khám phá món ngon, voucher hấp dẫn và gợi ý phù hợp ngay trên ClickEat.
                                </p>

                                <div class="hero-actions">
                                    <a href="${ctx}/menu" class="hero-btn-primary">
                                        Khám phá thực đơn
                                    </a>
                                    <a href="${ctx}/ai" class="hero-btn-secondary">
                                        Hỏi AI gợi ý
                                    </a>
                                </div>
                            </div>
                        </div>

                        <div class="hero-side">
                            <c:choose>
                                <c:when test="${not empty vouchers}">
                                    <c:forEach var="v" items="${vouchers}" begin="0" end="1" varStatus="s">
                                        <div class="hero-mini ${s.index == 0 ? 'orange' : 'white'}">
                                            <div>
                                                <div class="hero-mini-shop">${v.merchantName}</div>
                                                <div class="hero-mini-title">${v.displayDiscount}</div>
                                                <div class="hero-mini-desc line-clamp-2">
                                                    ${v.description}
                                                </div>
                                                <div class="hero-mini-code">Mã: ${v.code}</div>
                                            </div>

                                            <a href="#voucher-list" class="hero-mini-btn">
                                                Lấy mã ngay <i class="fa-solid fa-arrow-right"></i>
                                            </a>

                                            <div class="hero-mini-icon">
                                                <c:choose>
                                                    <c:when test="${s.index == 0}">
                                                        <i class="fa-solid fa-tags"></i>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <i class="fa-solid fa-truck-fast"></i>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </div>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <div class="hero-mini orange">
                                        <div>
                                            <div class="hero-mini-shop">Ưu đãi mới</div>
                                            <div class="hero-mini-title">DEAL HỜI CUỐI TUẦN</div>
                                            <div class="hero-mini-desc">Giảm sâu cho các đơn hàng hot trong hôm nay.</div>
                                        </div>
                                        <a href="#voucher-list" class="hero-mini-btn">
                                            Lấy mã ngay <i class="fa-solid fa-arrow-right"></i>
                                        </a>
                                        <div class="hero-mini-icon">
                                            <i class="fa-solid fa-tags"></i>
                                        </div>
                                    </div>

                                    <div class="hero-mini white">
                                        <div>
                                            <div class="hero-mini-shop">Ưu đãi giao hàng</div>
                                            <div class="hero-mini-title">FREESHIP EXTRA</div>
                                            <div class="hero-mini-desc">Miễn phí giao hàng cho nhiều quán đang mở bán.</div>
                                        </div>
                                        <a href="#voucher-list" class="hero-mini-btn">
                                            Xem danh sách quán <i class="fa-solid fa-arrow-right"></i>
                                        </a>
                                        <div class="hero-mini-icon">
                                            <i class="fa-solid fa-truck-fast"></i>
                                        </div>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
            </section>

            <!-- VOUCHERS -->
            <section id="voucher-list" class="pt-24">
                <div class="container-click">
                    <div class="flex flex-wrap items-center justify-between gap-4 mb-10">
                        <h2 class="section-title">VOUCHER NỔI BẬT</h2>
                        <a href="${ctx}/menu" class="section-link">
                            Xem thêm ưu đãi <i class="fa-solid fa-angle-right text-[12px]"></i>
                        </a>
                    </div>

                    <c:if test="${empty vouchers}">
                        <div class="empty-box">
                            <i class="fa-solid fa-ticket text-5xl text-gray-300 mb-4"></i>
                            <p class="text-gray-500 text-lg font-medium">
                                Hiện chưa có voucher khả dụng.
                            </p>
                        </div>
                    </c:if>

                    <c:if test="${not empty vouchers}">
                        <div class="voucher-grid">
                            <c:forEach var="v" items="${vouchers}" begin="0" end="3" varStatus="loop">
                                <c:set var="voucherStyle" value="voucher-style-1" />
                                <c:set var="voucherLabel" value="FREESHIP" />
                                <c:set var="voucherIcon" value="fa-truck-fast" />

                                <c:if test="${loop.index % 4 == 1}">
                                    <c:set var="voucherStyle" value="voucher-style-2" />
                                    <c:set var="voucherLabel" value="% GIẢM" />
                                    <c:set var="voucherIcon" value="fa-percent" />
                                </c:if>

                                <c:if test="${loop.index % 4 == 2}">
                                    <c:set var="voucherStyle" value="voucher-style-3" />
                                    <c:set var="voucherLabel" value="GIẢM TIỀN" />
                                    <c:set var="voucherIcon" value="fa-money-bill-wave" />
                                </c:if>

                                <c:if test="${loop.index % 4 == 3}">
                                    <c:set var="voucherStyle" value="voucher-style-4" />
                                    <c:set var="voucherLabel" value="HOT DEAL" />
                                    <c:set var="voucherIcon" value="fa-tags" />
                                </c:if>

                                <article class="voucher-modern ${voucherStyle}">
                                    <div class="voucher-top">
                                        <div class="voucher-pill">${voucherLabel}</div>

                                        <div class="voucher-code-row">
                                            <div>
                                                <div class="voucher-code">${v.code}</div>
                                                <div class="voucher-copy">
                                                    Sao chép mã <i class="fa-regular fa-copy"></i>
                                                </div>
                                            </div>

                                            <i class="voucher-icon fa-solid ${voucherIcon}"></i>
                                        </div>
                                    </div>

                                    <div class="voucher-bottom">
                                        <h3 class="voucher-bottom-title line-clamp-2">
                                            <c:choose>
                                                <c:when test="${not empty v.title}">
                                                    ${v.title}
                                                </c:when>
                                                <c:otherwise>
                                                    ${v.displayDiscount}
                                                </c:otherwise>
                                            </c:choose>
                                        </h3>

                                        <p class="voucher-bottom-desc line-clamp-2">
                                            <c:choose>
                                                <c:when test="${not empty v.description}">
                                                    ${v.description}
                                                </c:when>
                                                <c:otherwise>
                                                    Ưu đãi hấp dẫn cho đơn hàng trên ClickEat.
                                                </c:otherwise>
                                            </c:choose>
                                        </p>

                                        <div class="voucher-expire">
                                            HSD:
                                            <c:choose>
                                                <c:when test="${not empty v.endAt}">
                                                    <fmt:formatDate value="${v.endAt}" pattern="dd/MM/yyyy" />
                                                </c:when>
                                                <c:otherwise>
                                                    Còn hiệu lực
                                                </c:otherwise>
                                            </c:choose>
                                        </div>

                                        <div class="voucher-action">
                                            <a href="${ctx}/menu" class="voucher-save-btn">
                                                Lưu mã
                                            </a>
                                        </div>
                                    </div>
                                </article>
                            </c:forEach>
                        </div>
                    </c:if>
                </div>
            </section>

            <!-- DANH MỤC -->
            <section class="pt-24">
                <div class="container-click">
                    <h2 class="section-title text-center md:text-left mb-12">DANH MỤC PHỔ BIẾN</h2>

                    <div class="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-y-10 gap-x-6">
                        <a href="${ctx}/menu" class="text-center group">
                            <div class="soft-icon-box bg-orange-50 text-orange-500 group-hover:-translate-y-1 transition">
                                <i class="fa-solid fa-bowl-rice text-[42px]"></i>
                            </div>
                            <div class="text-[17px] font-extrabold text-slate-600">Cơm trưa</div>
                        </a>

                        <a href="${ctx}/menu" class="text-center group">
                            <div class="soft-icon-box bg-blue-50 text-blue-500 group-hover:-translate-y-1 transition">
                                <i class="fa-solid fa-bowl-food text-[42px]"></i>
                            </div>
                            <div class="text-[17px] font-extrabold text-slate-600">Bún/Phở</div>
                        </a>

                        <a href="${ctx}/menu" class="text-center group">
                            <div class="soft-icon-box bg-red-50 text-red-400 group-hover:-translate-y-1 transition">
                                <i class="fa-solid fa-pizza-slice text-[42px]"></i>
                            </div>
                            <div class="text-[17px] font-extrabold text-slate-600">Pizza</div>
                        </a>

                        <a href="${ctx}/menu" class="text-center group">
                            <div class="soft-icon-box bg-pink-50 text-pink-500 group-hover:-translate-y-1 transition">
                                <i class="fa-solid fa-mug-hot text-[42px]"></i>
                            </div>
                            <div class="text-[17px] font-extrabold text-slate-600">Trà sữa</div>
                        </a>

                        <a href="${ctx}/menu" class="text-center group">
                            <div class="soft-icon-box bg-amber-50 text-amber-500 group-hover:-translate-y-1 transition">
                                <i class="fa-solid fa-burger text-[42px]"></i>
                            </div>
                            <div class="text-[17px] font-extrabold text-slate-600">Burger</div>
                        </a>

                        <a href="${ctx}/menu" class="text-center group">
                            <div class="soft-icon-box bg-purple-50 text-purple-500 group-hover:-translate-y-1 transition">
                                <i class="fa-solid fa-ice-cream text-[42px]"></i>
                            </div>
                            <div class="text-[17px] font-extrabold text-slate-600">Đồ ngọt</div>
                        </a>
                    </div>
                </div>
            </section>

            <!-- DEAL HOT / FOODS -->
            <section id="deal-hot" class="pt-24">
                <div class="container-click">
                    <div class="flex flex-wrap items-center justify-between gap-4 mb-8">
                        <div class="flex items-center gap-4 flex-wrap">
                            <h2 class="section-title">DEAL HOT CHO BẠN</h2>
                            <span class="pill pill-red text-[13px] px-4 py-3">
                                <i class="fa-regular fa-clock"></i> Hot trong hôm nay
                            </span>
                        </div>

                        <a href="${ctx}/menu" class="section-link">
                            Xem tất cả món <i class="fa-solid fa-angle-right text-[12px]"></i>
                        </a>
                    </div>
                    <c:if test="${empty foods}">
                        <div class="empty-box">
                            <i class="fa-solid fa-box-open text-5xl text-gray-300 mb-4"></i>
                            <p class="text-gray-500 text-lg font-medium">
                                Chưa có món ăn nào trong hệ thống để hiển thị.
                            </p>
                        </div>
                    </c:if>
                    <c:if test="${not empty foods}">
                        <div class="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-7">
                            <c:forEach var="f" items="${foods}">
                                <div class="food-card bg-white overflow-hidden border border-gray-100 shadow-soft card-hover flex flex-col">
                                    <div class="relative h-[230px] overflow-hidden bg-gray-100">
                                        <c:choose>
                                            <c:when test="${not empty f.imageUrl}">
                                                <img src="${f.imageUrl}" alt="${f.name}" class="w-full h-full object-cover">
                                            </c:when>
                                            <c:otherwise>
                                                <img src="https://placehold.co/600x400/orange/white?text=ClickEat" alt="${f.name}" class="w-full h-full object-cover">
                                            </c:otherwise>
                                        </c:choose>

                                        <span class="absolute left-4 top-4 deal-badge">
                                            -${f.discountPercent}% GIẢM
                                        </span>
                                    </div>

                                    <div class="food-body flex flex-col flex-1">
                                        <div class="text-[12px] uppercase font-black tracking-[.08em] text-orange-500 mb-3">
                                            ${f.merchantName}
                                        </div>

                                        <h3 class="food-name line-clamp-1">
                                            ${f.name}
                                        </h3>

                                        <p class="food-desc mt-3 line-clamp-2">
                                            ${f.description}
                                        </p>

                                        <div class="flex flex-wrap gap-2 mt-4">
                                            <span class="pill pill-orange">${f.categoryName}</span>
                                            <c:if test="${f.fried}">
                                                <span class="pill pill-green">MÓN CHIÊN</span>
                                            </c:if>
                                        </div>

                                        <div class="mt-auto pt-6 flex items-end justify-between gap-3">
                                            <div>
                                                <div class="price-now">
                                                    <fmt:formatNumber value="${f.price}" type="number" groupingUsed="true" maxFractionDigits="0" />đ
                                                </div>
                                                <div class="price-old">
                                                    <fmt:formatNumber value="${f.originalPrice}" type="number" groupingUsed="true" maxFractionDigits="0" />đ
                                                </div>
                                            </div>

                                            <a href="${ctx}/cart?action=add&id=${f.id}" class="add-cart-btn" title="Thêm vào giỏ hàng">
                                                <i class="fa-solid fa-cart-plus"></i>
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:if>  
                </div>
            </section>

            <!-- NHÀ HÀNG NỔI BẬT -->
            <section class="pt-24">
                <div class="container-click">
                    <div class="flex flex-wrap items-center justify-between gap-4 mb-8">
                        <h2 class="section-title">NHÀ HÀNG NỔI BẬT</h2>
                        <a href="${ctx}/store" class="section-link">
                            Khám phá thêm quán <i class="fa-solid fa-angle-right text-[12px]"></i>
                        </a>
                    </div>

                    <c:if test="${empty merchants}">
                        <div class="empty-box">
                            <i class="fa-solid fa-store text-5xl text-gray-300 mb-4"></i>
                            <p class="text-gray-500 text-lg font-medium">
                                Hiện chưa có quán nổi bật để hiển thị.
                            </p>
                        </div>
                    </c:if>

                    <div class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-8">
                        <c:forEach var="m" items="${merchants}">
                            <article class="restaurant-card bg-white overflow-hidden border border-gray-100 shadow-soft card-hover">
                                <div class="relative h-[240px] overflow-hidden">
                                    <img src="${m.shopAvatar}" alt="${m.shopName}" class="w-full h-full object-cover">
                                    <span class="absolute top-4 right-4 pill bg-orange-50 text-orange-500">NỔI BẬT</span>
                                </div>
                                <div class="p-7">
                                    <h3 class="text-[22px] font-black text-gray-900 leading-tight line-clamp-1">${m.shopName}</h3>

                                    <div class="flex items-center gap-5 text-[15px] text-gray-500 mt-4 font-semibold flex-wrap">
                                        <span><i class="fa-solid fa-location-dot text-orange-500 mr-1"></i> ${m.districtName}</span>
                                        <span><i class="fa-solid fa-map text-orange-500 mr-1"></i> ${m.provinceName}</span>
                                    </div>

                                    <div class="flex items-center justify-between gap-4 mt-6 flex-wrap">
                                        <div class="flex flex-wrap gap-2">
                                            <span class="pill pill-orange">Cửa hàng</span>
                                        </div>
                                        <span class="pill bg-orange-50 text-orange-500">
                                            <i class="fa-solid fa-star mr-1"></i>
                                            <fmt:formatNumber value="${m.avgRating}" type="number" minFractionDigits="1" maxFractionDigits="1" />
                                        </span>
                                    </div>
                                </div>
                            </article>
                        </c:forEach>
                    </div>
                </div>
            </section>

            <!-- AI BANNER -->
            <section class="pt-24">
                <div class="container-click">
                    <div class="rounded-[40px] bg-orange-500 min-h-[420px] overflow-hidden shadow-soft px-8 md:px-14 py-12 md:py-16 grid grid-cols-1 lg:grid-cols-[1fr_.9fr] gap-10 items-center">
                        <div class="text-white">
                            <h2 class="font-black tracking-[-0.03em] leading-[1.02] text-[42px] md:text-[58px] max-w-[620px]">
                                ClickEat — Trợ lý ẩm thực AI cá nhân
                            </h2>

                            <p class="mt-8 text-[20px] leading-9 text-white/92 max-w-[620px]">
                                AI giúp bạn chọn món phù hợp theo khẩu vị, nhu cầu và ngân sách chỉ trong vài giây.
                            </p>

                            <a href="${ctx}/aichat" class="mt-10 inline-flex items-center justify-center gap-3 h-[58px] px-10 rounded-full bg-white text-orange-500 font-black text-[18px] hover:translate-y-[-1px] transition">
                                TRẢI NGHIỆM AI NGAY
                                <i class="fa-solid fa-wand-magic-sparkles text-[14px]"></i>
                            </a>
                        </div>

                        <div class="flex justify-center lg:justify-end">
                            <div class="w-full max-w-[470px] rounded-[30px] border-[8px] border-orange-400/55 overflow-hidden shadow-[0_18px_40px_rgba(0,0,0,.18)]">
                                <img
                                    src="https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=1400&auto=format&fit=crop"
                                    alt="AI food suggestion"
                                    class="w-full h-[290px] md:h-[320px] object-cover"
                                    >
                            </div>
                        </div>
                    </div>
                </div>
            </section>

        </main>

        <jsp:include page="footer.jsp" />

    </body>
</html>