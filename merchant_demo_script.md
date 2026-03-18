# Merchant demo script (5-7 phút)

## 1) Đăng nhập đúng vai trò
- Mở `/login`
- Đăng nhập bằng tài khoản `MERCHANT`
- Kết quả mong đợi: vào `merchant/dashboard`

## 2) Dashboard
- Kiểm tra các card: doanh thu hôm nay / hôm qua / 7 ngày
- Kiểm tra card: số đơn hôm nay / đơn hủy / tỉ lệ hủy
- Kiểm tra chart `Số đơn theo giờ trong ngày`
- Kiểm tra chart `Tỉ lệ đơn dùng voucher vs không dùng`
- Kiểm tra khối `Top 5 món bán chạy` và click `Xem Catalog`

## 3) Orders
- Vào `merchant/orders`
- Dùng filter trạng thái + from/to datetime
- Nhận đơn `PENDING` -> chuyển `PREPARING`
- Báo `READY_FOR_PICKUP`
- Hủy một đơn với lý do -> trạng thái `CANCELLED`
- Verify badge màu: xanh (DELIVERED), cam (đang xử lý), đỏ (CANCELLED)

## 4) Catalog
- Tick nhiều món -> `Ẩn món đã chọn` (nhập lý do hết món)
- Tick nhiều món -> `Hiện món đã chọn`
- Toggle từng món, xác nhận owner-check vẫn hoạt động

## 5) Promotions
- Vào `merchant/promotions`
- Tạo voucher mới
- Kiểm tra cột: code, hiệu lực, min order, used count, status
- Toggle publish nhanh
- Xác nhận mã `DEMO15K` hiển thị nếu dữ liệu seed đã nạp

## 6) Settings & open state
- Vào `merchant/settings`
- Cập nhật `min_order_amount`
- Tắt `is_open`
- Từ tài khoản customer thử checkout -> phải bị chặn vì quán tắt
- Bật lại `is_open`, checkout lại với đơn dưới min -> bị chặn

## 7) Logout
- Bấm `Đăng xuất`
- Kết quả mong đợi: quay về `/login`
