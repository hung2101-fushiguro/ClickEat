package com.clickeat.filter;

import com.clickeat.model.User;
import java.io.IOException;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

// Dòng này cực kỳ quan trọng: Bắt mọi request có đường dẫn bắt đầu bằng /admin/
@WebFilter(filterName = "AdminFilter", urlPatterns = {"/admin/*"})
public class AdminFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        // Ép kiểu để sử dụng được các hàm của HTTP
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        
        // Lấy session hiện tại (không tạo mới)
        HttpSession session = req.getSession(false);

        boolean isLoggedIn = (session != null && session.getAttribute("account") != null);

        if (isLoggedIn) {
            User user = (User) session.getAttribute("account");
            
            // Kiểm tra xem có đúng là ADMIN không
            if ("ADMIN".equals(user.getRole())) {
                // Hợp lệ -> Cho phép đi tiếp vào Servlet/JSP
                chain.doFilter(request, response);
            } else {
                // Đăng nhập rồi nhưng là CUSTOMER/MERCHANT -> Báo lỗi 403 (Cấm truy cập)
                res.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập khu vực Quản trị!");
            }
        } else {
            // Chưa đăng nhập -> Bắt quay đầu về trang login
            // req.getContextPath() giúp lấy đúng tên dự án (VD: /ClickEat2/login)
            res.sendRedirect(req.getContextPath() + "/login");
        }
    }
}