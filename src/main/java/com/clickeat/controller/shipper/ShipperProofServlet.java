/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.controller.shipper;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;

import com.clickeat.dal.impl.NotificationDAO;
import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.model.Order;
import com.clickeat.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

@WebServlet(name = "ShipperProofServlet", urlPatterns = {"/shipper/proof"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10, // 10MB
        maxRequestSize = 1024 * 1024 * 50 // 50MB
)
public class ShipperProofServlet extends HttpServlet {

    // Hiển thị trang upload ảnh
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String orderId = request.getParameter("orderId");
        request.setAttribute("orderId", orderId);
        request.getRequestDispatcher("/views/shipper/proof-of-delivery.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"SHIPPER".equals(account.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        int orderId = Integer.parseInt(request.getParameter("orderId"));

        try {
            Part filePart = request.getPart("proofImage");
            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            if (fileName == null || fileName.trim().isEmpty()) {
                request.getSession().setAttribute("toastError", "Vui lòng tải lên ảnh bằng chứng giao hàng.");
                response.sendRedirect(request.getContextPath() + "/shipper/proof?orderId=" + orderId);
                return;
            }

            String savedFileName = "proof_ord" + orderId + "_" + System.currentTimeMillis() + ".jpg";
            String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdir();
            }

            String tempFilePath = uploadPath + File.separator + savedFileName;
            filePart.write(tempFilePath);

            OrderDAO orderDAO = new OrderDAO();
            String proofUrl = "uploads/" + savedFileName;
            boolean settled = orderDAO.completeDeliveryWithProofAndSettlement(orderId, account.getId(), proofUrl);
            if (!settled) {
                request.getSession().setAttribute("toastError", "Không thể hoàn tất giao đơn. Vui lòng thử lại.");
                response.sendRedirect(request.getContextPath() + "/shipper/order-tracking?id=" + orderId);
                return;
            }

            Order deliveredOrder = orderDAO.findById(orderId);
            NotificationDAO notificationDAO = new NotificationDAO();
            if (deliveredOrder != null && deliveredOrder.getCustomerUserId() > 0) {
                notificationDAO.createForUser(deliveredOrder.getCustomerUserId(), "ORDER", "Đơn #" + deliveredOrder.getOrderCode() + " đã giao thành công.");
            }
            if (deliveredOrder != null && deliveredOrder.getMerchantId() > 0) {
                notificationDAO.createForUser(deliveredOrder.getMerchantId(), "ORDER", "Đơn #" + deliveredOrder.getOrderCode() + " đã được giao thành công.");
            }
            notificationDAO.createForUser(account.getId(), "WALLET", "Bạn vừa hoàn tất đơn giao. Số dư ví đã được cập nhật.");

            request.getSession().setAttribute("toastMsg", "Đã giao hàng, lưu ảnh và cộng tiền vào ví thành công!");
        } catch (Exception e) {
            System.out.println("Lỗi upload ảnh: " + e.getMessage());
            request.getSession().setAttribute("toastError", "Có lỗi xảy ra khi tải ảnh lên!");
        }

        response.sendRedirect(request.getContextPath() + "/shipper/dashboard");
    }
}
