package com.clickeat.filter;

import com.clickeat.dal.impl.CartDAO;
import com.clickeat.dal.impl.CartItemViewDAO;
import com.clickeat.model.Cart;
import com.clickeat.model.CartItemView;
import com.clickeat.model.User;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Collections;
import java.util.List;

@WebFilter("/*")
public class HeaderCartFilter implements Filter {

    private boolean isStatic(String uri) {
        if (uri == null) return false;
        return uri.endsWith(".css") || uri.endsWith(".js") || uri.endsWith(".png") || uri.endsWith(".jpg")
                || uri.endsWith(".jpeg") || uri.endsWith(".webp") || uri.endsWith(".svg") || uri.endsWith(".ico")
                || uri.endsWith(".woff") || uri.endsWith(".woff2") || uri.endsWith(".ttf") || uri.endsWith(".map");
    }

    private boolean shouldSkip(String path) {
        return path.startsWith("/admin")
                || path.startsWith("/login")
                || path.startsWith("/register")
                || path.startsWith("/logout")
                || path.startsWith("/google-")
                || path.startsWith("/api")
                || path.startsWith("/assets")
                || isStatic(path);
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        String ctx = request.getContextPath();
        String uri = request.getRequestURI();
        String path = uri.startsWith(ctx) ? uri.substring(ctx.length()) : uri;

        if (shouldSkip(path)) {
            chain.doFilter(req, res);
            return;
        }

        request.setAttribute("cartItems", Collections.emptyList());
        request.setAttribute("cartCount", 0);
        request.setAttribute("cartTotal", 0.0);
        request.setAttribute("lastStoreUrl", ctx + "/store");

        try {
            HttpSession session = request.getSession(false);
            if (session != null) {
                User account = (User) session.getAttribute("account");
                String guestId = (String) session.getAttribute("guestId");

                CartDAO cartDAO = new CartDAO();
                Cart cart = null;

                if (account != null) {
                    cart = cartDAO.getActiveCartByCustomerId(account.getId());
                } else if (guestId != null && !guestId.isBlank()) {
                    cart = cartDAO.getActiveCartByGuestId(guestId);
                }

                if (cart != null) {
                    CartItemViewDAO viewDAO = new CartItemViewDAO();
                    List<CartItemView> items = viewDAO.getByCartId(cart.getId());

                    int count = 0;
                    double total = 0;
                    for (CartItemView it : items) {
                        count += it.getQuantity();
                        total += it.getLineTotal();
                    }

                    request.setAttribute("cartItems", items);
                    request.setAttribute("cartCount", count);
                    request.setAttribute("cartTotal", total);

                    Integer merchantId = cart.getMerchantUserId();
                    if (merchantId != null && merchantId > 0) {
                        request.setAttribute("lastStoreUrl", ctx + "/store-detail?id=" + merchantId);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        chain.doFilter(req, res);
    }
}