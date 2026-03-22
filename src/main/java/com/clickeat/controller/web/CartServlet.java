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
        if (action == null || action.isBlank()) {
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
                String foodIdRaw = request.getParameter("id");
                if (foodIdRaw == null || foodIdRaw.isBlank()) {
                    session.setAttribute("toastError", "Không xác định được món ăn cần thêm.");
                    response.sendRedirect(backOrDefault(request, "/home"));
                    return;
                }

                int foodId = Integer.parseInt(foodIdRaw);
                FoodItem food = foodDAO.findById(foodId);

                if (food == null) {
                    session.setAttribute("toastError", "Món ăn không tồn tại.");
                    response.sendRedirect(backOrDefault(request, "/home"));
                    return;
                }

                if (!food.isAvailable()) {
                    session.setAttribute("toastError", "Món ăn hiện đang tạm ngừng bán.");
                    response.sendRedirect(backOrDefault(request, "/home"));
                    return;
                }

                Cart cart = getOrCreateActiveCart(session, account, cartDAO, guestSessionDAO);

                if (cart == null) {
                    session.setAttribute("toastError", "Không thể khởi tạo giỏ hàng.");
                    response.sendRedirect(backOrDefault(request, "/home"));
                    return;
                }

                // Nếu cart đang rỗng thì chủ động gán merchant cho cart
                List<CartItem> currentItems = cartItemDAO.getItemsByCartId(cart.getId());
                boolean cartIsEmpty = (currentItems == null || currentItems.isEmpty());

                if (cartIsEmpty) {
                    try {
                        Integer currentMerchant = cart.getMerchantUserId();
                        if (currentMerchant == null || currentMerchant <= 0) {
                            cart.setMerchantUserId(food.getMerchantUserId());
                            cartDAO.update(cart);
                        }
                    } catch (Exception e) {
                        System.out.println("Không thể cập nhật merchant cho cart: " + e.getMessage());
                    }
                } else {
                    // Rule: single merchant
                    FoodItem firstFoodInCart = foodDAO.findById(currentItems.get(0).getFoodItemId());
                    if (firstFoodInCart != null
                            && firstFoodInCart.getMerchantUserId() != food.getMerchantUserId()) {
                        session.setAttribute("toastError",
                                "Giỏ hàng chỉ được chứa món từ 1 nhà hàng. Vui lòng xóa giỏ cũ trước.");
                        response.sendRedirect(backOrDefault(request, "/home"));
                        return;
                    }
                }

                CartItem existItem = cartItemDAO.checkItemExist(cart.getId(), foodId);
                boolean isSuccess;

                if (existItem != null) {
                    int newQty = existItem.getQuantity() + 1;
                    isSuccess = cartItemDAO.updateQuantity(existItem.getId(), newQty);
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
                    session.setAttribute("toastError", "Không thể thêm món vào giỏ hàng.");
                }

            } catch (NumberFormatException e) {
                session.setAttribute("toastError", "Mã món ăn không hợp lệ.");
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

                String itemIdRaw = request.getParameter("itemId");
                if (itemIdRaw == null || itemIdRaw.isBlank()) {
                    session.setAttribute("toastError", "Thiếu mã dòng sản phẩm.");
                    response.sendRedirect(request.getContextPath() + "/cart?action=view");
                    return;
                }

                int itemId = Integer.parseInt(itemIdRaw);
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
                e.printStackTrace();
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

            List<CartItem> cartItems = null;
            double totalMoney = 0;

            if (cart != null) {
                cartItems = cartItemDAO.getItemsByCartId(cart.getId());

                if (cartItems != null) {
                    for (CartItem item : cartItems) {
                        totalMoney += (item.getQuantity() * item.getUnitPriceSnapshot());
                    }
                }
            }

            request.setAttribute("cartItems", cartItems);
            request.setAttribute("totalMoney", totalMoney);
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
                } else {
                    session.setAttribute("toastError", "Không thể xóa món không thuộc giỏ hiện tại.");
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
            e.printStackTrace();
            session.setAttribute("toastError", "Không thể cập nhật giỏ hàng!");
        }

        response.sendRedirect(backOrDefault(request, "/home"));
    }
}