package com.clickeat.filter;

import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import com.clickeat.model.User;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebFilter("/*")
public class AuthFilter implements Filter {

    private static final Set<String> CUSTOMER_PROTECTED = new HashSet<>(Arrays.asList(
            "/my-orders", "/my-account", "/track-order", "/rate-order", "/checkout",
            "/customer/profile", "/customer/orders", "/customer/vouchers", "/customer/register-role"
    ));

    private static final Set<String> CUSTOMER_UI_ROUTES = new HashSet<>(Arrays.asList(
            "/home", "/menu", "/promotion", "/promotions", "/store", "/store-detail",
            "/cart", "/checkout", "/payment-success", "/guest-checkout",
            "/my-orders", "/my-account", "/track-order", "/rate-order",
            "/customer/profile", "/customer/orders", "/customer/vouchers", "/customer/register-role"
    ));

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String path = request.getServletPath();
        HttpSession session = request.getSession(false);
        User account = (session != null) ? (User) session.getAttribute("account") : null;

        if (account != null && isBackOfficeRole(account.getRole()) && isCustomerUiPath(path)) {
            response.sendRedirect(request.getContextPath() + getDashboardPathByRole(account.getRole()));
            return;
        }

        // Merchant portal (except public register page)
        if (path.startsWith("/merchant/")
                && !path.equals("/merchant/register")
                && !path.equals("/merchant/auth/google")) {
            if (account == null || !"MERCHANT".equals(account.getRole())) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
        } // Admin portal
        else if (path.startsWith("/admin/")) {
            if (account == null || !"ADMIN".equals(account.getRole())) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
        } // Shipper portal — allow public register page
        else if (path.startsWith("/shipper/") && !path.equals("/shipper/register")) {
            if (account == null || !"SHIPPER".equals(account.getRole())) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
            }
        } // Customer-only paths
        else if (CUSTOMER_PROTECTED.contains(path)) {
            if (account == null || !"CUSTOMER".equalsIgnoreCase(account.getRole())) {
                boolean isGuestCheckoutAllowed = path.equals("/checkout")
                        && session != null
                        && Boolean.TRUE.equals(session.getAttribute("guestVerified"));

                if (!isGuestCheckoutAllowed) {
                    response.sendRedirect(request.getContextPath() + "/login");
                    return;
                }
            }
        }

        chain.doFilter(req, res);
    }

    @Override
    public void init(FilterConfig fc) throws ServletException {
    }

    @Override
    public void destroy() {
    }

    private boolean isBackOfficeRole(String role) {
        return "MERCHANT".equalsIgnoreCase(role)
                || "ADMIN".equalsIgnoreCase(role)
                || "SHIPPER".equalsIgnoreCase(role);
    }

    private boolean isCustomerUiPath(String path) {
        return CUSTOMER_UI_ROUTES.contains(path) || path.startsWith("/customer/");
    }

    private String getDashboardPathByRole(String role) {
        if ("MERCHANT".equalsIgnoreCase(role)) {
            return "/merchant/dashboard";
        }
        if ("ADMIN".equalsIgnoreCase(role)) {
            return "/admin/dashboard";
        }
        if ("SHIPPER".equalsIgnoreCase(role)) {
            return "/shipper/dashboard";
        }
        return "/home";
    }
}
