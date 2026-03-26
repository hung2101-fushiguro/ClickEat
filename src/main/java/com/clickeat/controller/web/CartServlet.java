package com.clickeat.controller.web;

import java.io.IOException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import com.clickeat.dal.impl.CartDAO;
import com.clickeat.dal.impl.CartItemDAO;
import com.clickeat.dal.impl.CartItemViewDAO;
import com.clickeat.dal.impl.FoodItemDAO;
import com.clickeat.dal.impl.GuestSessionDAO;
import com.clickeat.model.Cart;
import com.clickeat.model.CartItem;
import com.clickeat.model.CartItemView;
import com.clickeat.model.FoodItem;
import com.clickeat.model.User;

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
            guestId = (String) session.getAttribute("guest_id");
        }

        if (guestId == null || guestId.isBlank()) {
            guestId = guestSessionDAO.createGuestSession();
            if (guestId != null && !guestId.isBlank()) {
                session.setAttribute("guestId", guestId);
                session.setAttribute("guest_id", guestId);
            }
        } else {
            session.setAttribute("guestId", guestId);
            session.setAttribute("guest_id", guestId);
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
                        if (currentMerchant == null || currentMerchant.intValue() != food.getMerchantUserId()) {
                            cart.setMerchantUserId(food.getMerchantUserId());
                            cartDAO.update(cart);
                        }
                    } catch (Exception e) {
                        System.out.println("Không thể cập nhật merchant cho cart: " + e.getMessage());
                        e.printStackTrace();
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

                FoodOptionSelection selection = resolveSelection(
                        food,
                        request.getParameter("selectedSize"),
                        request.getParameter("selectedToppings")
                );
                CartItem existItem = cartItemDAO.checkItemExist(cart.getId(), foodId, selection.signature);
                boolean isSuccess;

                if (existItem != null) {
                    int newQty = existItem.getQuantity() + 1;
                    isSuccess = cartItemDAO.updateQuantity(existItem.getId(), newQty);
                } else {
                    CartItem newItem = new CartItem();
                    newItem.setCartId(cart.getId());
                    newItem.setFoodItemId(foodId);
                    newItem.setQuantity(1);
                    newItem.setUnitPriceSnapshot(food.getPrice() + selection.extraPrice);
                    newItem.setNote("");
                    newItem.setSelectedSize(selection.selectedSize);
                    newItem.setSelectedToppings(selection.selectedToppings);
                    newItem.setOptionExtraPrice(selection.extraPrice);
                    newItem.setOptionSignature(selection.signature);
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
                        List<CartItem> remainItems = cartItemDAO.getItemsByCartId(cart.getId());
                        if (remainItems == null || remainItems.isEmpty()) {
                            cartDAO.clearMerchant(cart.getId());
                        }
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
    // POST: AJAX add / AJAX remove / update
    // --------------------------------------------------------
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        if (action == null) {
            action = "";
        }

        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");

        CartDAO cartDAO = new CartDAO();
        CartItemDAO cartItemDAO = new CartItemDAO();
        GuestSessionDAO guestSessionDAO = new GuestSessionDAO();

        // ---- AJAX: Add item (POST /cart action=ajax-add) ----
        if ("ajax-add".equals(action)) {
            response.setContentType("application/json;charset=UTF-8");
            response.setCharacterEncoding("UTF-8");
            FoodItemDAO foodDAO = new FoodItemDAO();
            boolean success = false;
            String message = "";
            Cart cart = null;
            try {
                int foodId = Integer.parseInt(request.getParameter("id").trim());
                int qty = 1;
                try {
                    qty = Math.max(1, Integer.parseInt(request.getParameter("qty")));
                } catch (Exception ignored) {
                }

                FoodItem food = foodDAO.findById(foodId);
                if (food == null) {
                    message = "Món ăn không tồn tại.";
                } else if (!food.isAvailable()) {
                    message = "Món ăn tạm ngừng bán.";
                } else {
                    cart = getOrCreateActiveCart(session, account, cartDAO, guestSessionDAO);
                    if (cart == null) {
                        message = "Không thể khởi tạo giỏ hàng.";
                    } else {
                        List<CartItem> currentItems = cartItemDAO.getItemsByCartId(cart.getId());
                        if (currentItems == null || currentItems.isEmpty()) {
                            Integer cm = cart.getMerchantUserId();
                            if (cm == null || cm.intValue() != food.getMerchantUserId()) {
                                cart.setMerchantUserId(food.getMerchantUserId());
                                cartDAO.update(cart);
                            }
                        } else {
                            FoodItem first = foodDAO.findById(currentItems.get(0).getFoodItemId());
                            if (first != null && first.getMerchantUserId() != food.getMerchantUserId()) {
                                message = "Giỏ hàng chỉ chứa món từ 1 nhà hàng. Xóa giỏ cũ trước khi thêm.";
                                cart = null;
                            }
                        }
                        if (cart != null) {
                            FoodOptionSelection selection = resolveSelection(
                                    food,
                                    request.getParameter("selectedSize"),
                                    request.getParameter("selectedToppings")
                            );
                            CartItem exist = cartItemDAO.checkItemExist(cart.getId(), foodId, selection.signature);
                            boolean ok;
                            if (exist != null) {
                                ok = cartItemDAO.updateQuantity(exist.getId(), exist.getQuantity() + qty);
                            } else {
                                CartItem ni = new CartItem();
                                ni.setCartId(cart.getId());
                                ni.setFoodItemId(foodId);
                                ni.setQuantity(qty);
                                ni.setUnitPriceSnapshot(food.getPrice() + selection.extraPrice);
                                ni.setNote("");
                                ni.setSelectedSize(selection.selectedSize);
                                ni.setSelectedToppings(selection.selectedToppings);
                                ni.setOptionExtraPrice(selection.extraPrice);
                                ni.setOptionSignature(selection.signature);
                                ok = cartItemDAO.insert(ni) > 0;
                            }
                            if (ok) {
                                success = true;
                                message = "Đã thêm vào giỏ hàng!";
                            } else {
                                message = "Lỗi cơ sở dữ liệu.";
                                cart = null;
                            }
                        }
                    }
                }
            } catch (Exception e) {
                message = "Lỗi: " + e.getMessage();
            }
            writeCartJson(response, success, message, cart);
            return;
        }

        // ---- AJAX: Remove item (POST /cart action=ajax-remove) ----
        if ("ajax-remove".equals(action)) {
            response.setContentType("application/json;charset=UTF-8");
            response.setCharacterEncoding("UTF-8");
            boolean success = false;
            String message = "";
            Cart cart = null;
            try {
                cart = getOrCreateActiveCart(session, account, cartDAO, guestSessionDAO);
                int itemId = Integer.parseInt(request.getParameter("itemId").trim());
                CartItem target = cartItemDAO.findById(itemId);
                if (target != null && cart != null && target.getCartId() == cart.getId()) {
                    if (cartItemDAO.delete(itemId)) {
                        List<CartItem> remain = cartItemDAO.getItemsByCartId(cart.getId());
                        if (remain == null || remain.isEmpty()) {
                            cartDAO.clearMerchant(cart.getId());
                        }
                        success = true;
                        message = "Đã xóa món.";
                    } else {
                        message = "Không thể xóa món.";
                    }
                } else {
                    message = "Món không thuộc giỏ hàng.";
                }
            } catch (Exception e) {
                message = "Lỗi: " + e.getMessage();
            }
            writeCartJson(response, success, message, cart);
            return;
        }

        if (!"update".equals(action)) {
            response.sendRedirect(request.getContextPath() + "/cart?action=view");
            return;
        }

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

                    List<CartItem> remainItems = cartItemDAO.getItemsByCartId(cart.getId());
                    if (remainItems == null || remainItems.isEmpty()) {
                        cartDAO.clearMerchant(cart.getId());
                    }

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

    // ---- Helpers ----
    private void writeCartJson(HttpServletResponse resp, boolean success, String message, Cart cart)
            throws IOException {
        int cartCount = 0;
        double cartTotal = 0;
        StringBuilder items = new StringBuilder("[");
        if (cart != null) {
            CartItemViewDAO civDAO = new CartItemViewDAO();
            List<CartItemView> list = civDAO.getByCartId(cart.getId());
            if (list != null) {
                boolean first = true;
                for (CartItemView iv : list) {
                    cartCount += iv.getQuantity();
                    cartTotal += iv.getLineTotal();
                    if (!first) {
                        items.append(",");
                    }
                    first = false;
                    items.append("{\"id\":").append(iv.getCartItemId())
                            .append(",\"name\":\"").append(escJson(iv.getName())).append("\"")
                            .append(",\"quantity\":").append(iv.getQuantity())
                            .append(",\"unitPrice\":").append((long) iv.getUnitPrice())
                            .append(",\"lineTotal\":").append((long) iv.getLineTotal())
                            .append(",\"optionSummary\":\"").append(escJson(iv.getOptionSummary())).append("\"")
                            .append("}");
                }
            }
        }
        items.append("]");
        resp.getWriter().print("{\"success\":" + success
                + ",\"message\":\"" + escJson(message) + "\""
                + ",\"cartCount\":" + cartCount
                + ",\"cartTotal\":" + (long) cartTotal
                + ",\"items\":" + items + "}");
    }

    private String escJson(String s) {
        if (s == null) {
            return "";
        }
        return s.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
    }

    private FoodOptionSelection resolveSelection(FoodItem food, String selectedSize, String selectedToppingsRaw) {
        FoodOptionSelection selection = new FoodOptionSelection();

        Map<String, Double> sizePriceMap = parseOptionMap(food.getSizeOptions());
        Map<String, Double> toppingPriceMap = parseOptionMap(food.getToppingOptions());

        String normalizedSize = normalizeOptionName(selectedSize);
        if (normalizedSize != null && !normalizedSize.isBlank() && sizePriceMap.containsKey(normalizedSize)) {
            selection.selectedSize = normalizedSize;
            selection.extraPrice += sizePriceMap.getOrDefault(normalizedSize, 0d);
        }

        List<String> selectedToppings = new ArrayList<>();
        if (selectedToppingsRaw != null && !selectedToppingsRaw.isBlank()) {
            String[] parts = selectedToppingsRaw.split(",");
            for (String raw : parts) {
                String normalized = normalizeOptionName(raw);
                if (normalized != null && !normalized.isBlank() && toppingPriceMap.containsKey(normalized) && !selectedToppings.contains(normalized)) {
                    selectedToppings.add(normalized);
                    selection.extraPrice += toppingPriceMap.getOrDefault(normalized, 0d);
                }
            }
        }

        if (!selectedToppings.isEmpty()) {
            selection.selectedToppings = String.join(", ", selectedToppings);
        }

        selection.signature = buildOptionSignature(selection.selectedSize, selection.selectedToppings);
        return selection;
    }

    private Map<String, Double> parseOptionMap(String optionText) {
        Map<String, Double> map = new LinkedHashMap<>();
        if (optionText == null || optionText.isBlank()) {
            return map;
        }

        String[] tokens = optionText.split(";");
        for (String token : tokens) {
            if (token == null || token.isBlank()) {
                continue;
            }
            String[] pair = token.split(":", 2);
            String name = normalizeOptionName(pair[0]);
            if (name == null || name.isBlank()) {
                continue;
            }
            double extra = 0;
            if (pair.length > 1 && pair[1] != null && !pair[1].isBlank()) {
                try {
                    extra = Double.parseDouble(pair[1].trim());
                } catch (NumberFormatException ignored) {
                }
            }
            map.put(name, Math.max(0, extra));
        }
        return map;
    }

    private String normalizeOptionName(String raw) {
        if (raw == null) {
            return null;
        }
        return raw.trim().replaceAll("\\s+", " ");
    }

    private String buildOptionSignature(String size, String toppings) {
        String normalizedSize = size == null ? "" : size.trim();
        String normalizedToppings = "";
        if (toppings != null && !toppings.isBlank()) {
            normalizedToppings = java.util.Arrays.stream(toppings.split(","))
                    .map(this::normalizeOptionName)
                    .filter(s -> s != null && !s.isBlank())
                    .sorted(String.CASE_INSENSITIVE_ORDER)
                    .collect(Collectors.joining("|"));
        }
        return "size=" + normalizedSize + ";tops=" + normalizedToppings;
    }

    private static class FoodOptionSelection {

        String selectedSize = "";
        String selectedToppings = "";
        double extraPrice = 0;
        String signature = "";
    }
}
