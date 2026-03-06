package com.clickeat.controller.shipper;

import com.clickeat.dal.impl.ShipperDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "ShipperRegisterServlet", urlPatterns = {"/shipper/register"})
public class ShipperRegisterServlet extends HttpServlet {

    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/views/shipper/register.jsp").forward(request, response);
    }

    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
       
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String password = request.getParameter("password");
        String vehicleType = request.getParameter("vehicleType"); // MOTORBIKE hoặc BIKE
        String vehicleName = request.getParameter("vehicleName");
        String licensePlate = request.getParameter("licensePlate");

        ShipperDAO shipperDAO = new ShipperDAO();
        boolean isSuccess = shipperDAO.registerShipper(fullName, phone, password, vehicleType, vehicleName, licensePlate);

        if (isSuccess) {
            request.getSession().setAttribute("toastMsg", "Đăng ký thành công! Vui lòng đăng nhập.");
            response.sendRedirect(request.getContextPath() + "/login");
        } else {
            request.setAttribute("errorMsg", "Số điện thoại đã tồn tại hoặc có lỗi xảy ra!");
            request.getRequestDispatcher("/views/shipper/register.jsp").forward(request, response);
        }
    }
}