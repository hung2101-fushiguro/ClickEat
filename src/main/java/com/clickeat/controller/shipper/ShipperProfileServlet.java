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

        User account = (User) request.getSession().getAttribute("account");

        // 1. Lấy dữ liệu từ Form
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String vehicleType = request.getParameter("vehicleType");
        String vehicleName = request.getParameter("vehicleName");
        String licensePlate = request.getParameter("licensePlate");

        boolean isSuccess = true;

        // 2. Cập nhật thông tin CÁ NHÂN (Bảng Users)
        if (phone != null && email != null) {
            account.setPhone(phone);
            account.setEmail(email);

            UserDAO userDAO = new UserDAO();
            if (!userDAO.update(account)) {
                isSuccess = false;
            } else {
                // Cập nhật lại session để góc phải màn hình đổi theo
                request.getSession().setAttribute("account", account);
            }
        }

        // 3. Cập nhật thông tin PHƯƠNG TIỆN (Bảng ShipperProfiles)
        ShipperDAO shipperDAO = new ShipperDAO();
        ShipperProfile profile = shipperDAO.findById(account.getId());

        if (profile != null) {
            profile.setVehicleType(vehicleType);
            profile.setVehicleName(vehicleName);
            profile.setLicensePlate(licensePlate);

            if (!shipperDAO.update(profile)) {
                isSuccess = false;
            }
        }

        // 4. Thông báo kết quả
        if (isSuccess) {
            request.getSession().setAttribute("toastMsg", "Cập nhật hồ sơ thành công!");
        } else {
            request.getSession().setAttribute("toastError", "Cập nhật thất bại, vui lòng kiểm tra lại (có thể trùng SĐT).");
        }

        // Tải lại trang Profile
        response.sendRedirect(request.getContextPath() + "/shipper/profile");
    }
}
