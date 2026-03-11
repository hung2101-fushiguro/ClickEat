/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.controller.auth; // Điều chỉnh package cho phù hợp

import com.clickeat.dal.impl.UserDAO;
import com.clickeat.model.User;
import java.io.File;
import java.io.IOException;
import java.util.UUID;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

@WebServlet(name = "AvatarUploadServlet", urlPatterns = {"/upload-avatar"})
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, 
        maxFileSize = 1024 * 1024 * 5, 
        maxRequestSize = 1024 * 1024 * 10 
)
public class AvatarUploadServlet extends HttpServlet {

    private static final String UPLOAD_DIR = "uploads/avatars";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User account = (User) request.getSession().getAttribute("account");
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            Part filePart = request.getPart("avatarFile");
            if (filePart != null && filePart.getSize() > 0) {
                // 1. Tạo thư mục lưu ảnh (nếu chưa có)
                String applicationPath = request.getServletContext().getRealPath("");
                String uploadFilePath = applicationPath + File.separator + UPLOAD_DIR;
                File uploadFolder = new File(uploadFilePath);
                if (!uploadFolder.exists()) {
                    uploadFolder.mkdirs();
                }

                // 2. Lấy đuôi file (vd: .jpg, .png) và tạo tên file mới (chống trùng lặp)
                String fileName = getFileName(filePart);
                String fileExtension = fileName.substring(fileName.lastIndexOf("."));
                String newFileName = "user_" + account.getId() + "_" + UUID.randomUUID().toString() + fileExtension;

                // 3. Lưu file vào server
                filePart.write(uploadFilePath + File.separator + newFileName);

                // 4. Lưu đường dẫn vào Database
                String avatarUrl = request.getContextPath() + "/" + UPLOAD_DIR + "/" + newFileName;
                UserDAO userDAO = new UserDAO();
                if (userDAO.updateAvatar((int) account.getId(), avatarUrl)) {
                    // 5. Cập nhật lại Session để giao diện tự đổi ảnh
                    account.setAvatarUrl(avatarUrl);
                    request.getSession().setAttribute("account", account);
                    request.getSession().setAttribute("toastMsg", "Cập nhật ảnh đại diện thành công!");
                }
            }
        } catch (Exception e) {
            request.getSession().setAttribute("toastError", "Lỗi: File quá lớn hoặc định dạng không hỗ trợ.");
        }

        // Trở về trang trước đó (Referer)
        String referer = request.getHeader("Referer");
        response.sendRedirect(referer != null ? referer : request.getContextPath() + "/home");
    }

    // Hàm tiện ích để trích xuất tên file từ thẻ Header của Part
    private String getFileName(Part part) {
        for (String content : part.getHeader("content-disposition").split(";")) {
            if (content.trim().startsWith("filename")) {
                return content.substring(content.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return "default.jpg";
    }
}
