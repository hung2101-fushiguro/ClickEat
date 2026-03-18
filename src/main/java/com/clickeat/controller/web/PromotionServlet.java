package com.clickeat.controller.web;

import com.clickeat.dal.impl.FoodItemDAO;
import com.clickeat.model.FoodItem;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet(name = "PromotionServlet", urlPatterns = {"/promotion"})
public class PromotionServlet extends HttpServlet {

    private final FoodItemDAO foodItemDAO = new FoodItemDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        List<FoodItem> promotedFoods = foodItemDAO.getPromotedFoods(12);
        request.setAttribute("promotedFoods", promotedFoods);
        
        request.getRequestDispatcher("/views/web/promotion.jsp").forward(request, response);
    }
}
