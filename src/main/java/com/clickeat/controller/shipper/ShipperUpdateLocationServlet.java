package com.clickeat.controller.shipper;

import java.io.IOException; // Bạn có thể dùng bất kỳ DAO nào có kế thừa hàm update()
import java.io.PrintWriter;

import com.clickeat.dal.impl.UserDAO;
import com.clickeat.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "UpdateLocationServlet", urlPatterns = {"/shipper/update-location"})
public class ShipperUpdateLocationServlet extends HttpServlet {

    private void writeJson(HttpServletResponse response, int status, String body) throws IOException {
        response.setStatus(status);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.print(body);
            out.flush();
        }
    }

    private boolean isValidCoordinate(double latitude, double longitude) {
        return latitude >= -90.0 && latitude <= 90.0 && longitude >= -180.0 && longitude <= 180.0;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User account = (User) request.getSession().getAttribute("account");

        if (account == null || account.getRole() == null || !"SHIPPER".equalsIgnoreCase(account.getRole().trim())) {
            writeJson(response, HttpServletResponse.SC_UNAUTHORIZED, "{\"status\":\"error\",\"message\":\"Unauthorized\"}");
            return;
        }

        String latStr = request.getParameter("latitude");
        String lngStr = request.getParameter("longitude");

        if (latStr == null || lngStr == null) {
            writeJson(response, HttpServletResponse.SC_BAD_REQUEST, "{\"status\":\"error\",\"message\":\"Thiếu tọa độ\"}");
            return;
        }

        try {
            double lat = Double.parseDouble(latStr.trim());
            double lng = Double.parseDouble(lngStr.trim());

            if (!isValidCoordinate(lat, lng)) {
                writeJson(response, HttpServletResponse.SC_BAD_REQUEST, "{\"status\":\"error\",\"message\":\"Tọa độ không hợp lệ\"}");
                return;
            }

            UserDAO dao = new UserDAO();
            String updateSql = "UPDATE dbo.ShipperAvailability SET current_latitude = ?, current_longitude = ?, updated_at = SYSUTCDATETIME() WHERE shipper_user_id = ?";
            int affected = dao.update(updateSql, lat, lng, account.getId());

            if (affected <= 0) {
                String insertSql = "INSERT INTO dbo.ShipperAvailability (shipper_user_id, is_online, current_status, current_latitude, current_longitude, updated_at) VALUES (?, 1, 'AVAILABLE', ?, ?, SYSUTCDATETIME())";
                dao.update(insertSql, account.getId(), lat, lng);
            }

            writeJson(response, HttpServletResponse.SC_OK, "{\"status\":\"success\",\"message\":\"Cập nhật vị trí thành công\"}");
        } catch (NumberFormatException e) {
            writeJson(response, HttpServletResponse.SC_BAD_REQUEST, "{\"status\":\"error\",\"message\":\"Định dạng tọa độ không hợp lệ\"}");
        }
    }
}
