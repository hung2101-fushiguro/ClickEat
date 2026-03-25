package com.clickeat.controller.shipper;

import com.clickeat.dal.impl.ShipperDAO;
import com.clickeat.dal.impl.UserDAO;
import com.clickeat.model.ShipperProfile;
import com.clickeat.model.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "ShipperProfileServlet", urlPatterns = {"/shipper/profile"})
public class ShipperProfileServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"SHIPPER".equals(account.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Lấy thông tin ShipperProfile (Chứa thông tin xe cộ)
        ShipperDAO shipperDAO = new ShipperDAO();
        ShipperProfile profile = shipperDAO.findById(account.getId());

        request.setAttribute("profile", profile);
        request.getRequestDispatcher("/views/shipper/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        com.clickeat.model.User account = (com.clickeat.model.User) request.getSession().getAttribute("account");
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Lấy dữ liệu từ form
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String vehicleType = request.getParameter("vehicleType");
        String vehicleName = request.getParameter("vehicleName");
        String licensePlate = request.getParameter("licensePlate");

        com.clickeat.dal.impl.UserDAO userDAO = new com.clickeat.dal.impl.UserDAO();

        // 1. Kiểm tra xem có bị trùng với AI KHÁC không
        if (userDAO.checkDuplicateForUpdate(phone, email, account.getId())) {
            request.getSession().setAttribute("toastError", "Số điện thoại hoặc Email đã được sử dụng!");
            response.sendRedirect(request.getContextPath() + "/shipper/profile");
            return;
        }

        // 2. Tiến hành cập nhật
        try {
            // Update thông tin User chung
            String sqlUser = "UPDATE Users SET full_name = ?, phone = ?, email = ?, updated_at = GETDATE() WHERE id = ?";
            userDAO.update(sqlUser, fullName, phone, email, account.getId());

            // Update thông tin xe của Shipper
            String sqlShipper = "UPDATE ShipperProfiles SET vehicle_type = ?, vehicle_name = ?, license_plate = ? WHERE user_id = ?";
            userDAO.update(sqlShipper, vehicleType, vehicleName, licensePlate, account.getId());

            // 3. Cập nhật thành công -> Đổi lại Session
            account.setFullName(fullName);
            account.setPhone(phone);
            account.setEmail(email);
            request.getSession().setAttribute("account", account);

            request.getSession().setAttribute("toastMsg", "Đã lưu thay đổi hồ sơ thành công!");
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("toastError", "Lỗi hệ thống khi lưu hồ sơ!");
        }

        response.sendRedirect(request.getContextPath() + "/shipper/profile");
    }
}
