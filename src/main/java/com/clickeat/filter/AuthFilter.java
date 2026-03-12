package com.clickeat.filter;

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
import java.io.IOException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

@WebFilter("/*")
public class AuthFilter implements Filter {

    private static final Set<String> CUSTOMER_PROTECTED = new HashSet<>(Arrays.asList(
            "/my-orders", "/my-account", "/track-order", "/rate-order", "/checkout"
    ));

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String path = request.getServletPath();
        HttpSession session = request.getSession(false);
        User account = (session != null) ? (User) session.getAttribute("account") : null;

        // Merchant portal (except own login/register)
        if (path.startsWith("/merchant/") && !path.equals("/merchant/login") && !path.equals("/merchant/register")) {
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
            if (account == null) {
                response.sendRedirect(request.getContextPath() + "/login");
                return;
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
}
