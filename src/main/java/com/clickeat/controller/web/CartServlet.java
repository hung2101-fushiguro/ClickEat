package com.clickeat.controller.web;

import com.clickeat.dal.impl.CartDAO;
import com.clickeat.dal.impl.CartItemDAO;
import com.clickeat.dal.impl.FoodItemDAO;
import com.clickeat.dal.impl.GuestSessionDAO;
import com.clickeat.model.Cart;
import com.clickeat.model.CartItem;
import com.clickeat.model.FoodItem;
import com.clickeat.model.User;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "CartServlet", urlPatterns = {"/cart"})
public class CartServlet extends HttpServlet {

    private String backOrDefault(HttpServletRequest request, String fallback) {
        String ref = request.getHeader("Referer");
        return (ref != null && !ref.isBlank()) ? ref : (request.getContextPath() + fallback);
    }

    private User requireLogin(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }
        return account;
    }

    private String getOrCreateGuestId(HttpSession session, GuestSessionDAO guestSessionDAO) {
        String guestId = (String) session.getAttribute("guestId");

        if (guestId == null || guestId.isBlank()) {
            guestId = guestSessionDAO.createGuestSession();
            if (guestId != null && !guestId.isBlank()) {
                session.setAttribute("guestId", guestId);
            }
        }

        return guestId;
    }

    private Cart getOrCreateActiveCart(HttpSession session, User account,
            CartDAO cartDAO, GuestSessionDAO guestSessionDAO) {

        Cart cart = null;

        if (account != null) {
            cart = cartDAO.getActiveCartByCustomerId(account.getId());

            if (cart == null) {
                cartDAO.createNewCart(account.getId());
                cart = cartDAO.getActiveCartByCustomerId(account.getId());
            }
        } else {
            String guestId = getOrCreateGuestId(session, guestSessionDAO);
            if (guestId == null || guestId.isBlank()) {
                return null;
            }

            cart = cartDAO.getActiveCartByGuestId(guestId);

            if (cart == null) {
                cartDAO.createGuestCart(guestId);
                cart = cartDAO.getActiveCartByGuestId(guestId);
            }
        }

        return cart;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) {
            action = "view";
        }

        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");

        CartDAO cartDAO = new CartDAO();
        CartItemDAO cartItemDAO = new CartItemDAO();
        FoodItemDAO foodDAO = new FoodItemDAO();
        GuestSessionDAO guestSessionDAO = new GuestSessionDAO();

        // --------------------------------------------------------
        // ADD (GET /cart?action=add&id=FOOD_ID)
        // --------------------------------------------------------
        if ("add".equals(action)) {
            try {
                String idRaw = request.getParameter("id");
                if (idRaw == null) idRaw = request.getParameter("foodItemId");
                
                int foodId = Integer.parseInt(idRaw);
                FoodItem food = foodDAO.findById(foodId);

                if (food != null) {
                    Cart cart = getOrCreateActiveCart(session, account, cartDAO, guestSessionDAO);

                    if (cart == null) {
                        session.setAttribute("toastError", "Không thể khởi tạo giỏ hàng.");
                        response.sendRedirect(backOrDefault(request, "/home"));
                        return;
                    }

                    // Rule: single merchant
                    List<CartItem> currentItems = cartItemDAO.getItemsByCartId(cart.getId());
                    if (currentItems == null || currentItems.isEmpty()) {
                        // Nếu giỏ hàng đang trống, ta set merchant_user_id của Cart theo món mới thêm
                        cart.setMerchantUserId(food.getMerchantUserId());
                        cartDAO.update(cart);
                    } else {
                        FoodItem firstFoodInCart = foodDAO.findById(currentItems.get(0).getFoodItemId());
                        if (firstFoodInCart != null
                                && firstFoodInCart.getMerchantUserId() != food.getMerchantUserId()) {
                            session.setAttribute("toastError",
                                    "Giỏ hàng chỉ được chứa món từ 1 nhà hàng! Vui lòng xóa giỏ cũ.");
                            response.sendRedirect(backOrDefault(request, "/home"));
                            return;
                        }
                    }

                    CartItem existItem = cartItemDAO.checkItemExist(cart.getId(), foodId);
                    boolean isSuccess;

                    if (existItem != null) {
                        isSuccess = cartItemDAO.updateQuantity(existItem.getId(), existItem.getQuantity() + 1);
                    } else {
                        CartItem newItem = new CartItem();
                        newItem.setCartId(cart.getId());
                        newItem.setFoodItemId(foodId);
                        newItem.setQuantity(1);
                        newItem.setUnitPriceSnapshot(food.getPrice());
                        newItem.setNote("");
                        isSuccess = (cartItemDAO.insert(newItem) > 0);
                    }

                    if (isSuccess) {
                        session.setAttribute("toastMsg", "Đã thêm món vào giỏ hàng!");
                    } else {
                        System.err.println("CRITICAL: CartItem insert/update failed for cartId=" + cart.getId() + ", foodId=" + foodId);
                        session.setAttribute("toastError", "Lỗi CSDL: Không thể thêm món.");
                    }
                }
            } catch (Exception e) {
                System.out.println("Lỗi thêm vào giỏ: " + e.getMessage());
                e.printStackTrace();
                session.setAttribute("toastError", "Không thể thêm món vào giỏ.");
            }

            response.sendRedirect(backOrDefault(request, "/home"));
            return;
        }

        // --------------------------------------------------------
        // DELETE (GET /cart?action=delete&itemId=CART_ITEM_ID)
        // --------------------------------------------------------
        if ("delete".equals(action)) {
            try {
                Cart cart = getOrCreateActiveCart(session, account, cartDAO, guestSessionDAO);

                if (cart == null) {
                    session.setAttribute("toastError", "Không tìm thấy giỏ hàng.");
                    response.sendRedirect(request.getContextPath() + "/cart?action=view");
                    return;
                }

                int itemId = Integer.parseInt(request.getParameter("itemId"));
                CartItem target = cartItemDAO.findById(itemId);

                if (target != null && target.getCartId() == cart.getId()) {
                    boolean isSuccess = cartItemDAO.delete(itemId);

                    if (isSuccess) {
                        session.setAttribute("toastMsg", "Đã xóa món ăn khỏi giỏ!");
                    } else {
                        session.setAttribute("toastError", "Lỗi CSDL: Không thể xóa dòng này!");
                    }
                } else {
                    session.setAttribute("toastError", "Không thể xóa món không thuộc giỏ hàng hiện tại.");
                }
            } catch (Exception e) {
                System.out.println("Lỗi xóa: " + e.getMessage());
                session.setAttribute("toastError", "Không thể xóa món.");
            }

            response.sendRedirect(request.getContextPath() + "/cart?action=view");
            return;
        }

        // --------------------------------------------------------
        // VIEW (GET /cart?action=view)
        // --------------------------------------------------------
        if ("view".equals(action)) {
            Cart cart = getOrCreateActiveCart(session, account, cartDAO, guestSessionDAO);

            List<com.clickeat.model.CartItemView> cartItems = null;
            double totalMoney = 0;

            if (cart != null) {
                cartItems = new com.clickeat.dal.impl.CartItemViewDAO().getByCartId(cart.getId());

                if (cartItems != null) {
                    for (com.clickeat.model.CartItemView item : cartItems) {
                        totalMoney += item.getLineTotal();
                    }
                }
            }

            request.setAttribute("cartItems", cartItems);
            request.setAttribute("totalMoney", totalMoney);
            request.setAttribute("cartTotal", totalMoney); // Header popup uses cartTotal
            request.setAttribute("foodDAO", foodDAO);

            request.getRequestDispatcher("/views/web/cart.jsp").forward(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/cart?action=view");
    }

    // --------------------------------------------------------
    // UPDATE (POST /cart?action=update)
    // --------------------------------------------------------
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        if (action == null) {
            action = "";
        }

        if ("add".equalsIgnoreCase(action)) {
            doGet(request, response);
            return;
        }

        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");

        if (!"update".equals(action)) {
            response.sendRedirect(request.getContextPath() + "/cart?action=view");
            return;
        }

        CartDAO cartDAO = new CartDAO();
        CartItemDAO cartItemDAO = new CartItemDAO();
        GuestSessionDAO guestSessionDAO = new GuestSessionDAO();

        try {
            Cart cart = getOrCreateActiveCart(session, account, cartDAO, guestSessionDAO);
            if (cart == null) {
                response.sendRedirect(backOrDefault(request, "/home"));
                return;
            }

            // 1) Remove one item
            String removeIdRaw = request.getParameter("removeId");
            if (removeIdRaw != null && !removeIdRaw.isBlank()) {
                int cartItemId = Integer.parseInt(removeIdRaw);

                CartItem target = cartItemDAO.findById(cartItemId);
                if (target != null && target.getCartId() == cart.getId()) {
                    cartItemDAO.delete(cartItemId);
                    session.setAttribute("toastMsg", "Đã xóa món khỏi giỏ!");
                }

                response.sendRedirect(backOrDefault(request, "/home"));
                return;
            }

            // 2) Update qty_* params
            request.getParameterMap().forEach((key, val) -> {
                if (key != null && key.startsWith("qty_")) {
                    try {
                        int cartItemId = Integer.parseInt(key.substring(4));
                        int newQty = Integer.parseInt(val[0]);
                        if (newQty < 1) {
                            newQty = 1;
                        }

                        CartItem target = cartItemDAO.findById(cartItemId);
                        if (target != null && target.getCartId() == cart.getId()) {
                            cartItemDAO.updateQuantity(cartItemId, newQty);
                        }
                    } catch (Exception ignored) {
                    }
                }
            });

            session.setAttribute("toastMsg", "Đã cập nhật giỏ hàng!");
        } catch (Exception e) {
            System.out.println("Lỗi update cart: " + e.getMessage());
            session.setAttribute("toastError", "Không thể cập nhật giỏ hàng!");
        }

        response.sendRedirect(backOrDefault(request, "/home"));
    }
}