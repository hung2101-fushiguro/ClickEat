package com.clickeat.controller.web;

import com.clickeat.dal.impl.CartDAO;
import com.clickeat.dal.impl.CartItemDAO;
import com.clickeat.dal.impl.FoodItemDAO;
import com.clickeat.dal.impl.MerchantProfileDAO;
import com.clickeat.model.Cart;
import com.clickeat.model.CartItem;
import com.clickeat.model.FoodItem;
import com.clickeat.model.MerchantProfile;
import com.clickeat.model.User;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;

@WebServlet(name = "HomeServlet", urlPatterns = {"/home"})
public class HomeServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // 1. Lấy thông tin User từ Session
        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");

        // 2. Nếu chưa đăng nhập -> Đẩy về trang Login ngay
        if (account == null) {
            response.sendRedirect("login");
            return;
        }

        // 3. (Sau này) Gọi FoodDAO để lấy danh sách món ăn hiển thị
        FoodItemDAO foodDAO = new FoodItemDAO();
        List<FoodItem> topFoods = foodDAO.getTopFoods(6); // Lấy 6 món
        int cartCount = 0;

        if (account != null) {
            CartDAO cartDAO = new CartDAO();
            CartItemDAO cartItemDAO = new CartItemDAO();

            Cart cart = cartDAO.getActiveCartByCustomerId(account.getId());
            if (cart != null) {
                // Đếm xem trong giỏ đang có bao nhiêu món (Dựa vào số dòng trong CartItems)
                List<CartItem> items = cartItemDAO.getItemsByCartId(cart.getId());
                if (items != null) {
                    cartCount = items.size();
                }
            }
        }

        // Gửi con số này sang JSP để Header hiển thị
        request.setAttribute("cartCount", cartCount);

        // Gắn vào request
        request.setAttribute("foods", topFoods);

        // Load danh sách nhà hàng đã được duyệt
        MerchantProfileDAO merchantDAO = new MerchantProfileDAO();
        request.setAttribute("merchants", merchantDAO.getAllApprovedWithStats());

        // 4. Chuyển sang giao diện Home
        request.getRequestDispatcher("views/web/home.jsp").forward(request, response);
    }
}
