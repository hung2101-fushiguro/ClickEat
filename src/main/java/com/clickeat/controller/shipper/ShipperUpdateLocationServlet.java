package com.clickeat.controller.shipper;

import com.clickeat.dal.impl.UserDAO; // Bạn có thể dùng bất kỳ DAO nào có kế thừa hàm update()
import com.clickeat.model.User;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "UpdateLocationServlet", urlPatterns = {"/shipper/update-location"})
public class ShipperUpdateLocationServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // 1. Lấy thông tin Shipper đang đăng nhập
        User account = (User) request.getSession().getAttribute("account");
        
        if (account != null) {
            try {
                // 2. Nhận tọa độ từ file dashboard.jsp gửi lên qua AJAX
                String latStr = request.getParameter("latitude");
                String lngStr = request.getParameter("longitude");
                
                if (latStr != null && lngStr != null) {
                    double lat = Double.parseDouble(latStr);
                    double lng = Double.parseDouble(lngStr);
                    
                    // 3. Lưu tọa độ vào bảng ShipperAvailability
                    UserDAO dao = new UserDAO(); 
                    String sql = "UPDATE dbo.ShipperAvailability SET current_latitude = ?, current_longitude = ?, updated_at = SYSUTCDATETIME() WHERE shipper_user_id = ?";
                    
                    dao.update(sql, lat, lng, account.getId());
                    
                    // 4. Trả về phản hồi cho AJAX biết là đã lưu thành công
                    response.setContentType("application/json");
                    response.setCharacterEncoding("UTF-8");
                    PrintWriter out = response.getWriter();
                    out.print("{\"status\":\"success\", \"message\":\"Cập nhật vị trí thành công\"}");
                    out.flush();
                    return;
                }
            } catch (Exception e) {
                System.out.println("Lỗi cập nhật vị trí Shipper: " + e.getMessage());
            }
        }
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
    }
}