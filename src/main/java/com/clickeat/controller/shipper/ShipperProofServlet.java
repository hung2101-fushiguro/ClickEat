/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.controller.shipper;

import com.clickeat.dal.impl.OrderDAO;
import com.clickeat.dal.impl.ShipperWalletDAO;
import com.clickeat.model.Order;
import com.clickeat.model.User;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

@WebServlet(name = "ShipperProofServlet", urlPatterns = {"/shipper/proof"})
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 10,       // 10MB
    maxRequestSize = 1024 * 1024 * 50     // 50MB
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
        int orderId = Integer.parseInt(request.getParameter("orderId"));
        
        try {
            Part filePart = request.getPart("proofImage");
            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            
            
            String savedFileName = "";
            if (fileName != null && !fileName.isEmpty()) {
                
                savedFileName = "proof_ord" + orderId + "_" + System.currentTimeMillis() + ".jpg";
                String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdir();
                
                String tempFilePath = uploadPath + File.separator + savedFileName;
                filePart.write(tempFilePath);
                
                // Copy file lưu vĩnh viễn vào source code
                try {
                    String projectSourcePath = "e:" + File.separator + "Tải xuống" + File.separator + "ClickEat-main" 
                            + File.separator + "src" + File.separator + "main" + File.separator + "webapp" 
                            + File.separator + "uploads";
                    File sourceUploadFolder = new File(projectSourcePath);
                    if (!sourceUploadFolder.exists()) {
                        sourceUploadFolder.mkdirs();
                    }
                    
                    Path sourceFile = Paths.get(projectSourcePath, savedFileName);
                    Path tempFile = Paths.get(tempFilePath);
                    Files.copy(tempFile, sourceFile, StandardCopyOption.REPLACE_EXISTING);
                } catch(Exception ex) {
                    System.out.println("Could not copy file to source directory: " + ex.getMessage());
                }
            }

            OrderDAO orderDAO = new OrderDAO();
            orderDAO.updateOrderStatus(orderId, "DELIVERED");
            
            
         
            String sqlUpdateImage = "UPDATE Orders SET proof_image_url = ? WHERE id = ?";
            orderDAO.update(sqlUpdateImage, "uploads/" + savedFileName, orderId);
            Order completedOrder = orderDAO.findById(orderId);
            if (completedOrder != null) {
                ShipperWalletDAO walletDAO = new ShipperWalletDAO();
                walletDAO.addBalance(account.getId(), completedOrder.getDeliveryFee());
            }

            request.getSession().setAttribute("toastMsg", "Đã giao hàng, lưu ảnh và cộng tiền vào ví thành công!");            
        } catch (Exception e) {
            System.out.println("Lỗi upload ảnh: " + e.getMessage());
            request.getSession().setAttribute("toastError", "Có lỗi xảy ra khi tải ảnh lên!");
        }

        response.sendRedirect(request.getContextPath() + "/shipper/dashboard");
    }
}
