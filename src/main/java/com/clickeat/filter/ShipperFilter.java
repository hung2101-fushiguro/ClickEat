package com.clickeat.filter;

import java.io.IOException;

import com.clickeat.model.User;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebFilter(filterName = "ShipperFilter", urlPatterns = {"/shipper/*"})
public class ShipperFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        String uri = req.getRequestURI();
        String ctx = req.getContextPath();

        // Allow the register page without authentication
        if (uri.equals(ctx + "/shipper/register") || uri.startsWith(ctx + "/shipper/register?")) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = req.getSession(false);
        Object accountObj = (session != null) ? session.getAttribute("account") : null;
        if (accountObj == null) {
            res.sendRedirect(ctx + "/login");
            return;
        }

        User user = (User) accountObj;
        if ("SHIPPER".equals(user.getRole())) {
            chain.doFilter(request, response);
        } else {
            res.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập khu vực Shipper!");
        }
    }
}
