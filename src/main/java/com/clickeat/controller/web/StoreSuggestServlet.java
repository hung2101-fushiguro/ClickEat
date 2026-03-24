package com.clickeat.controller.web;

import com.clickeat.dal.impl.MerchantProfileDAO;
import com.clickeat.model.MerchantProfile;
import com.google.gson.Gson;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/store-suggest")
public class StoreSuggestServlet extends HttpServlet {

    private final MerchantProfileDAO merchantProfileDAO = new MerchantProfileDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String province = req.getParameter("province");
        String keyword = req.getParameter("keyword");

        if (keyword != null) {
            keyword = keyword.trim();
        }

        System.out.println("=== STORE SUGGEST START ===");
        System.out.println("province = [" + province + "]");
        System.out.println("keyword = [" + keyword + "]");

        resp.setContentType("application/json;charset=UTF-8");

        if (keyword == null || keyword.isEmpty()) {
            resp.getWriter().write("[]");
            System.out.println("keyword empty -> return []");
            System.out.println("=== STORE SUGGEST END ===");
            return;
        }

        List<MerchantProfile> stores = merchantProfileDAO.suggestStoresByName(province, keyword, 8);

        System.out.println("stores size = " + stores.size());
        for (MerchantProfile s : stores) {
            System.out.println("-> " + s.getUserId() + " | " + s.getShopName());
        }

        String json = gson.toJson(stores);
        System.out.println("json = " + json);

        resp.getWriter().write(json);
        System.out.println("=== STORE SUGGEST END ===");
    }
}
