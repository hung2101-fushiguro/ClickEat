<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
        <title>Hoàn tất hồ sơ - Click Eat</title>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">

        <style>
            /* ✅ bạn có thể copy nguyên CSS từ login.jsp để giống 100% */
            body{
                margin:0;
                min-height:100vh;
                display:flex;
                align-items:center;
                justify-content:center;
                background:#f3f4f6;
                font-family:Inter,sans-serif;
                padding:24px
            }
            .card{
                width:min(1120px,100%);
                background:#fff;
                border-radius:18px;
                overflow:hidden;
                display:grid;
                grid-template-columns:1.1fr .9fr;
                box-shadow:0 22px 60px rgba(0,0,0,.12)
            }
            .hero{
                position:relative;
                padding:28px;
                background:
                    linear-gradient(90deg, rgba(0,0,0,.65) 0%, rgba(0,0,0,.25) 55%, rgba(0,0,0,.10) 100%),
                    url("https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?auto=format&fit=crop&w=1400&q=80");
                background-size:cover;
                background-position:center;
                color:#fff
            }
            .brand{
                display:flex;
                align-items:center;
                gap:10px;
                font-weight:700
            }
            .logo{
                width:34px;
                height:34px;
                border-radius:10px;
                background:#ff7a1a;
                display:grid;
                place-items:center
            }
            .logo:before{
                content:"";
                width:14px;
                height:14px;
                background:#fff;
                border-radius:3px;
                display:block;
                clip-path: polygon(0 20%, 70% 20%, 70% 0, 100% 0, 100% 100%, 0 100%);
            }
            .hero h1{
                margin:28px 0 10px;
                font-size:52px;
                line-height:1.02;
                font-weight:800
            }
            .hero p{
                max-width:420px;
                opacity:.9;
                line-height:1.6
            }
            .formWrap{
                padding:36px 44px
            }
            .title{
                margin:0 0 8px;
                font-size:28px;
                font-weight:800
            }
            .subtitle{
                margin:0 0 18px;
                color:#6b7280
            }
            .alert{
                border-radius:12px;
                padding:12px 14px;
                border:1px solid;
                margin-bottom:14px
            }
            .alert.error{
                background:#fff1f2;
                border-color:#fecdd3;
                color:#9f1239
            }
            label{
                display:block;
                margin:12px 0 8px;
                font-weight:600;
                color:#374151;
                font-size:13px
            }
            input, textarea{
                width:100%;
                border:1px solid #e5e7eb;
                border-radius:12px;
                padding:12px 14px;
                font-size:14px;
                outline:none
            }
            textarea{
                min-height:86px;
                resize:vertical
            }
            input:focus, textarea:focus{
                border-color:rgba(255,122,26,.65);
                box-shadow:0 0 0 4px rgba(255,122,26,.16)
            }
            .btn{
                margin-top:16px;
                width:100%;
                height:46px;
                border:none;
                border-radius:14px;
                background:#ff7a1a;
                color:#fff;
                font-weight:800;
                cursor:pointer;
                box-shadow:0 14px 30px rgba(255,122,26,.32)
            }
            .row2{
                display:grid;
                grid-template-columns:1fr 1fr;
                gap:12px
            }
            @media (max-width:980px){
                .card{
                    grid-template-columns:1fr
                }
            }
        </style>
    </head>
    <body>

        <div class="card">
            <section class="hero">
                <div class="brand"><div class="logo"></div> Click Eat</div>
                <h1>Hoàn tất hồ sơ</h1>
                <p>Chỉ cần thêm một vài thông tin để Click Eat gợi ý món ăn phù hợp và giao hàng chính xác.</p>
            </section>

            <section class="formWrap">
                <h2 class="title">Thông tin bổ sung</h2>
                <p class="subtitle">Google đã xác thực email. Bạn vui lòng nhập thêm SĐT và sở thích (tùy chọn).</p>

                <c:if test="${not empty error}">
                    <div class="alert error">${error}</div>
                </c:if>

                <form action="${pageContext.request.contextPath}/google-complete" method="post">
                    <label>Email (từ Google)</label>
                    <input type="text" value="${sessionScope.GOOGLE_EMAIL}" readonly>

                    <label>Họ và tên</label>
                    <input type="text" name="full_name" value="${sessionScope.GOOGLE_NAME}" required>

                    <label>Số điện thoại</label>
                    <input type="text" name="phone" placeholder="VD: 090xxxxxxx" required>

                    <div class="row2">
                        <div>
                            <label>Mục tiêu sức khoẻ (tuỳ chọn)</label>
                            <input type="text" name="health_goal" placeholder="VD: Giảm cân / Eat clean / Tăng cơ">
                        </div>
                        <div>
                            <label>Calo mục tiêu/ngày (tuỳ chọn)</label>
                            <input type="number" name="daily_calorie_target" placeholder="VD: 1800">
                        </div>
                    </div>

                    <label>Sở thích món ăn (tuỳ chọn)</label>
                    <textarea name="food_preferences" placeholder="VD: Thích cay, thích đồ nướng, ít dầu mỡ..."></textarea>

                    <label>Dị ứng (tuỳ chọn)</label>
                    <textarea name="allergies" placeholder="VD: Dị ứng tôm, đậu phộng..."></textarea>

                    <button class="btn" type="submit">Hoàn tất</button>
                </form>
            </section>
        </div>

    </body>
</html>