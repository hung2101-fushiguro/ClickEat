# Checklist tối ưu nhánh Merchant (10 ngày)

## 1. Vận hành đơn hàng
- [ ] Chuẩn hóa danh sách trạng thái đơn (PENDING / CONFIRMED / PREPARING / READY_FOR_PICKUP / DELIVERING / DELIVERED / CANCELLED)
- [ ] Đảm bảo OrderStatusHistory ghi đầy đủ thay đổi trạng thái + thời gian + người thao tác
- [ ] Cập nhật MerchantOrderServlet / MerchantOrderDetailServlet chỉ cho phép các chuyển trạng thái hợp lệ
- [ ] Thêm filter theo trạng thái, ngày/giờ trên màn hình Orders
- [ ] Thêm badge màu cho từng trạng thái (xanh = hoàn tất, cam = đang xử lý, đỏ = hủy)
- [ ] Đảm bảo AuthFilter chặn đúng: merchant chưa đăng nhập bị redirect về /login

## 2. Catalog & menu
- [ ] Thêm cờ “Hết món hôm nay” hoặc tái sử dụng is_available với lý do rõ ràng trong UI
- [ ] Thêm thao tác bulk (tick nhiều món) để Ẩn/Hiện món nhanh
- [ ] Đảm bảo tất cả thao tác toggle trạng thái món đều kiểm tra đúng merchant_owner
- [ ] Bổ sung trường mô tả ngắn hiển thị trên danh sách món (nếu cần tách khỏi mô tả dài)

## 3. Khuyến mãi (Voucher)
- [ ] Tạo màn hình quản lý voucher cho merchant: danh sách code, ngày hiệu lực, min_order_amount, status
- [ ] Thêm cột hiển thị số đơn đã dùng mỗi voucher (tính từ Orders)
- [ ] Cho phép merchant bật/tắt publish voucher nhanh (toggle)
- [ ] Kiểm tra seed DEMO15K hoạt động đúng và hiển thị trong UI

## 4. Dashboard & Analytics
- [ ] Dashboard hiển thị: Doanh thu hôm nay / hôm qua / 7 ngày
- [ ] Dashboard hiển thị: Số đơn hôm nay / đơn hủy / tỉ lệ hủy
- [ ] Hoàn thiện danh sách “Món bán chạy” (top 5 theo số lượng hoặc doanh thu) có link sang Catalog
- [ ] Thêm biểu đồ số đơn theo giờ trong ngày (từ created_at)
- [ ] Thêm biểu đồ tỉ lệ đơn dùng voucher vs không dùng

## 5. Onboarding & trạng thái cửa hàng
- [ ] Trong Settings hoặc Dashboard, hiển thị rõ MerchantProfiles.status (PENDING / APPROVED / REJECTED / SUSPENDED)
- [ ] Nếu status = PENDING: hiển thị message đang duyệt + contact support
- [ ] Nếu status = REJECTED: hiển thị lý do (thêm cột reason trong bảng nếu chưa có)
- [ ] Hoàn thiện trang đăng ký merchant (register.jsp) theo flow 3 bước + trạng thái sau khi gửi hồ sơ

## 6. Cấu hình cửa hàng (Settings)
- [ ] Thêm field cấu hình min_order_amount cho mỗi merchant
- [ ] Thêm form cấu hình giờ mở cửa cơ bản (ví dụ: Thứ 2–CN: 9:00–22:00) lưu vào business_hours (JSON)
- [ ] Thêm switch Bật/Tắt quán (is_open) và phản ánh lên merchant _nav.jsp
- [ ] Đảm bảo khi quán tắt, không nhận thêm đơn mới từ phía customer

## 7. UI/UX chung
- [ ] Rà soát typography: dùng thống nhất font-size, font-weight cho heading, subheading, body
- [ ] Chuẩn hóa hệ màu: primary / success / danger / warning, tránh dùng mã màu rời rạc
- [ ] Thêm loading state (skeleton / spinner) cho Dashboard, Orders, Catalog
- [ ] Thêm empty state rõ ràng cho Orders, Catalog, Reviews khi chưa có dữ liệu
- [ ] Đảm bảo responsive tốt trên laptop 13" và tablet (tránh bảng tràn ngang quá nhiều)

## 8. Đăng nhập & phân quyền
- [ ] Dùng chung LoginServlet (/login) cho tất cả vai trò (ADMIN / MERCHANT / SHIPPER / CUSTOMER)
- [ ] Đảm bảo tất cả link “Đăng nhập” trong merchant trỏ về /login (không dùng /merchant/login)
- [ ] Kiểm tra lại AuthFilter: đường dẫn /merchant/*, /admin/*, /shipper/* đều redirect về /login nếu chưa có session account
- [ ] Kiểm tra Logout của merchant trả về /login (web) thay vì trang riêng

## 9. Performance & DB
- [ ] Thêm index các cột thường lọc: Orders(merchant_user_id, order_status, created_at)
- [ ] Thêm index cho Ratings(merchant_user_id, created_at)
- [ ] Rà lại các DAO để tránh N+1 query, ưu tiên JOIN + LIMIT/PAGE
- [ ] Chạy EXPLAIN cho các query nặng trên Dashboard/Analytics và tối ưu nếu cần

## 10. Kiểm thử & demo
- [ ] Dùng full_demo_seed_1week.sql để kiểm thử các màn merchant (đơn, review, voucher, wallet)
- [ ] Test flow đầy đủ: Login (theo role) → Dashboard → Orders → Catalog → Settings → Logout
- [ ] Viết một kịch bản demo ngắn (script) cho merchant để trình bày sản phẩm
