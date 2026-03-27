package com.clickeat.controller.web;

import com.clickeat.dal.impl.AddressDAO;
import com.clickeat.model.Address;
import com.clickeat.model.User;
import com.clickeat.util.MapRoutingUtil;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.json.JSONObject;

@WebServlet(name = "UpdateDeliveryLocationServlet", urlPatterns = {"/update-delivery-location"})
public class UpdateDeliveryLocationServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");

        JSONObject json = new JSONObject();
        PrintWriter out = response.getWriter();

        try {
            String latRaw = request.getParameter("latitude");
            String lngRaw = request.getParameter("longitude");

            if (latRaw == null || lngRaw == null || latRaw.isBlank() || lngRaw.isBlank()) {
                json.put("success", false);
                json.put("message", "Thiếu tọa độ vị trí.");
                out.print(json.toString());
                return;
            }

            double latitude = Double.parseDouble(latRaw);
            double longitude = Double.parseDouble(lngRaw);

            String resolvedAddress = MapRoutingUtil.reverseGeocode(latitude, longitude);
            if (resolvedAddress == null || resolvedAddress.isBlank()) {
                resolvedAddress = "Vị trí hiện tại";
            }

            HttpSession session = request.getSession();
            session.setAttribute("currentDeliveryLat", latitude);
            session.setAttribute("currentDeliveryLng", longitude);
            session.setAttribute("currentDeliveryAddress", resolvedAddress);
            session.setAttribute("currentDeliverySource", "GPS");

            User account = (User) session.getAttribute("account");
            if (account != null && "CUSTOMER".equalsIgnoreCase(account.getRole())) {
                AddressDAO addressDAO = new AddressDAO();
                Address defaultAddress = addressDAO.findDefaultByUserId(account.getId());

                // Phase hiện tại: chỉ lưu vị trí giao hiện tại vào session
                // Không tự ghi đè địa chỉ mặc định trong DB
                if (defaultAddress != null) {
                    // chưa update DB ở phase này
                }
            }

            json.put("success", true);
            json.put("message", "Đã cập nhật vị trí giao hàng.");
            json.put("address", resolvedAddress);
            json.put("latitude", latitude);
            json.put("longitude", longitude);
            json.put("source", "GPS");

            out.print(json.toString());

        } catch (Exception e) {
            json.put("success", false);
            json.put("message", "Không thể cập nhật vị trí: " + e.getMessage());
            out.print(json.toString());
        }
    }
}