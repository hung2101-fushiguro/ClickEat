package com.clickeat.controller.web;

import com.clickeat.dal.impl.MerchantProfileDAO;
import com.clickeat.model.MerchantProfile;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "StoreServlet", urlPatterns = {"/store"})
public class StoreServlet extends HttpServlet {

@Override
protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

    String keyword = request.getParameter("keyword");
    String province = request.getParameter("province");
    String district = request.getParameter("district");
    String sort = request.getParameter("sort");

    MerchantProfileDAO merchantDAO = new MerchantProfileDAO();

    List<String> provinces = merchantDAO.getAllApprovedProvinces();

    if (province == null || province.trim().isEmpty()) {
        province = "TP.HCM";
    }

    List<String> districts = merchantDAO.getDistrictsByProvince(province);
    List<MerchantProfile> stores = merchantDAO.searchApprovedStores(keyword, province, district, sort);

    request.setAttribute("stores", stores);
    request.setAttribute("provinces", provinces);
    request.setAttribute("districts", districts);
    request.setAttribute("keyword", keyword);
    request.setAttribute("province", province);
    request.setAttribute("district", district);
    request.setAttribute("sort", sort);

    request.getRequestDispatcher("/views/web/store.jsp").forward(request, response);
}

}