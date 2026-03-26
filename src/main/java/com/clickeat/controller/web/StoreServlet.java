package com.clickeat.controller.web;

import java.io.IOException;
import java.util.List;

import com.clickeat.dal.impl.MerchantProfileDAO;
import com.clickeat.model.MerchantProfile;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "StoreServlet", urlPatterns = {"/store"})
public class StoreServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String keyword = request.getParameter("keyword");
        String province = request.getParameter("province");
        String district = request.getParameter("district");
        String sort = request.getParameter("sort");

        HttpSession session = request.getSession();

        Double customerLat = parseCoordinate(request.getParameter("shippingLat"));
        Double customerLng = parseCoordinate(request.getParameter("shippingLng"));

        if (customerLat == null || customerLng == null) {
            customerLat = parseCoordinate(stringSession(session, "customer_home_latitude"));
            customerLng = parseCoordinate(stringSession(session, "customer_home_longitude"));
        }
        if (customerLat == null || customerLng == null) {
            customerLat = parseCoordinate(readCookie(request, "ce_home_lat"));
            customerLng = parseCoordinate(readCookie(request, "ce_home_lng"));
        }

        if (customerLat != null && customerLng != null) {
            session.setAttribute("customer_home_latitude", String.valueOf(customerLat));
            session.setAttribute("customer_home_longitude", String.valueOf(customerLng));
        }

        if ((sort == null || sort.isBlank()) && customerLat != null && customerLng != null) {
            sort = "near";
        }

        MerchantProfileDAO merchantDAO = new MerchantProfileDAO();

        List<String> provinces = merchantDAO.getAllApprovedProvinces();

        if (province == null || province.trim().isEmpty()) {
            province = "TP.HCM";
        }

        List<String> districts = merchantDAO.getDistrictsByProvince(province);
        List<MerchantProfile> stores = merchantDAO.searchApprovedStores(keyword, province, district, sort, customerLat, customerLng);

        request.setAttribute("stores", stores);
        request.setAttribute("provinces", provinces);
        request.setAttribute("districts", districts);
        request.setAttribute("keyword", keyword);
        request.setAttribute("province", province);
        request.setAttribute("district", district);
        request.setAttribute("sort", sort);
        request.setAttribute("customerLat", customerLat);
        request.setAttribute("customerLng", customerLng);

        request.getRequestDispatcher("/views/web/store.jsp").forward(request, response);
    }

    private String readCookie(HttpServletRequest request, String name) {
        Cookie[] cookies = request.getCookies();
        if (cookies == null || name == null) {
            return null;
        }
        for (Cookie cookie : cookies) {
            if (name.equals(cookie.getName())) {
                return cookie.getValue();
            }
        }
        return null;
    }

    private String stringSession(HttpSession session, String key) {
        Object value = session.getAttribute(key);
        return value == null ? null : value.toString();
    }

    private Double parseCoordinate(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return Double.parseDouble(value.trim());
        } catch (NumberFormatException ex) {
            return null;
        }
    }

}
