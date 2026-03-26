/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.controller.auth;

import com.clickeat.dal.impl.UserDAO;
import com.clickeat.dal.impl.AddressDAO;
import com.clickeat.dal.impl.CustomerProfileDAO;
import com.clickeat.model.User;
import com.clickeat.model.Address;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "RegisterServlet", urlPatterns = {"/register"})
public class RegisterServlet extends HttpServlet {

    // Hiển thị form đăng ký
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("views/web/register.jsp").forward(request, response);
    }

    // Xử lý khi người dùng bấm nút Đăng ký
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Giữ font tiếng Việt không bị lỗi font khi lưu vào DB
        request.setCharacterEncoding("UTF-8");

        // 1. Lấy dữ liệu từ JSP và trim khoảng trắng
        String fullName = trim(request.getParameter("fullName"));
        String email = trim(request.getParameter("email"));
        String phone = trim(request.getParameter("phone"));
        String password = trim(request.getParameter("password"));
        String confirmPassword = trim(request.getParameter("confirmPassword"));

        // Thông tin địa chỉ / người nhận
        String receiverName = trim(request.getParameter("receiverName"));
        String receiverPhone = trim(request.getParameter("receiverPhone"));
        String addressLine = trim(request.getParameter("addressLine"));

        String provinceCode = trim(request.getParameter("provinceName"));
        String districtCode = trim(request.getParameter("districtName"));
        String wardCode = trim(request.getParameter("wardName"));

        String provinceName = trim(request.getParameter("provinceNameText"));
        String districtName = trim(request.getParameter("districtNameText"));
        String wardName = trim(request.getParameter("wardNameText"));

        // 2. Kiểm tra mật khẩu khớp nhau
        if (password == null || !password.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu xác nhận không khớp!");
            request.getRequestDispatcher("views/web/register.jsp").forward(request, response);
            return;
        }

        UserDAO userDAO = new UserDAO();

        // 3. Kiểm tra trùng lặp (Logic DAO bạn đã viết sẵn)
        if (userDAO.checkPhoneExist(phone)) {
            request.setAttribute("error", "Số điện thoại này đã được đăng ký!");
            request.getRequestDispatcher("views/web/register.jsp").forward(request, response);
            return;
        }

        if (userDAO.checkEmailExist(email)) {
            request.setAttribute("error", "Email này đã được đăng ký!");
            request.getRequestDispatcher("views/web/register.jsp").forward(request, response);
            return;
        }

        // 4. Tạo Object User và lưu xuống DB
        User newUser = new User();
        newUser.setFullName(fullName);
        newUser.setEmail(email);
        newUser.setPhone(phone);
        newUser.setPasswordHash(password); // Sau này nên hash
        newUser.setRole("CUSTOMER");      // Mặc định đăng ký mới là Khách hàng

        int newId = userDAO.insert(newUser);

        // 5. Kiểm tra kết quả
        if (newId <= 0) {
            request.setAttribute("error", "Lỗi hệ thống, vui lòng thử lại sau!");
            request.getRequestDispatcher("views/web/register.jsp").forward(request, response);
            return;
        }

        // 6. Tạo CustomerProfile nếu chưa có
        CustomerProfileDAO customerProfileDAO = new CustomerProfileDAO();
        customerProfileDAO.ensureExists(newId);

        // 7. Nếu người dùng có nhập địa chỉ thì lưu vào Addresses
        boolean hasAddress = notBlank(addressLine)
                && notBlank(provinceCode)
                && notBlank(districtCode)
                && notBlank(wardCode)
                && notBlank(provinceName)
                && notBlank(districtName)
                && notBlank(wardName);

        if (hasAddress) {
            AddressDAO addressDAO = new AddressDAO();

            Address address = new Address();
            address.setUserId(newId);
            address.setReceiverName(notBlank(receiverName) ? receiverName : fullName);
            address.setReceiverPhone(notBlank(receiverPhone) ? receiverPhone : phone);
            address.setAddressLine(addressLine);
            address.setProvinceCode(provinceCode);
            address.setProvinceName(provinceName);
            address.setDistrictCode(districtCode);
            address.setDistrictName(districtName);
            address.setWardCode(wardCode);
            address.setWardName(wardName);
            address.setIsDefault(true);
            address.setNote(null);

            int addressId = addressDAO.insert(address);

            if (addressId > 0) {
                customerProfileDAO.setDefaultAddressId(newId, addressId);
            }
        }

        // 8. Đăng ký thành công
        request.setAttribute("message", "Đăng ký thành công! Vui lòng đăng nhập.");
        request.getRequestDispatcher("views/web/login.jsp").forward(request, response);
    }

    private String trim(String value) {
        return value == null ? null : value.trim();
    }

    private boolean notBlank(String value) {
        return value != null && !value.isBlank();
    }
}
