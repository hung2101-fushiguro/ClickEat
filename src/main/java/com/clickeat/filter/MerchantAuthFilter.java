package com.clickeat.filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Protects all /merchant/* routes except /merchant/login. Unauthenticated
 * requests are redirected to the login page.
 */
@WebFilter("/merchant/*")
public class MerchantAuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String uri = req.getRequestURI();
        String ctx = req.getContextPath();

        // Allow the login path through without authentication
        if (uri.equals(ctx + "/merchant/login") || uri.startsWith(ctx + "/merchant/login?")) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = req.getSession(false);
        boolean loggedIn = session != null && session.getAttribute("merchantId") != null;

        if (!loggedIn) {
            resp.sendRedirect(ctx + "/merchant/login");
            return;
        }

        chain.doFilter(request, response);
    }
}
