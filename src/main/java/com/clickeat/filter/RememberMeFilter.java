package com.clickeat.filter;

import com.clickeat.dal.impl.UserDAO;
import com.clickeat.model.User;
import com.clickeat.util.RememberMeUtil;
import com.clickeat.util.RememberMeUtil.RememberedLogin;
import java.io.IOException;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebFilter("/*")
public class RememberMeFilter implements Filter {

    private boolean isStatic(String uri) {
        if (uri == null) {
            return false;
        }
        return uri.endsWith(".css")
                || uri.endsWith(".js")
                || uri.endsWith(".png")
                || uri.endsWith(".jpg")
                || uri.endsWith(".jpeg")
                || uri.endsWith(".webp")
                || uri.endsWith(".svg")
                || uri.endsWith(".ico")
                || uri.endsWith(".woff")
                || uri.endsWith(".woff2")
                || uri.endsWith(".ttf")
                || uri.endsWith(".map");
    }

    private boolean shouldSkip(String path) {
        return path.startsWith("/assets")
                || path.startsWith("/api")
                || isStatic(path);
    }

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String contextPath = request.getContextPath();
        String uri = request.getRequestURI();
        String path = uri.startsWith(contextPath) ? uri.substring(contextPath.length()) : uri;

        if (!shouldSkip(path)) {
            HttpSession session = request.getSession(false);
            User account = (session == null) ? null : (User) session.getAttribute("account");

            if (account == null) {
                RememberedLogin rememberedLogin = RememberMeUtil.parseAndValidate(request);

                if (rememberedLogin != null) {
                    UserDAO userDAO = new UserDAO();
                    User user = userDAO.findById(rememberedLogin.userId());

                    if (user != null
                            && "ACTIVE".equalsIgnoreCase(user.getStatus())
                            && RememberMeUtil.isSignatureValid(rememberedLogin, user)) {

                        HttpSession newSession = request.getSession(true);
                        newSession.setAttribute("account", user);
                        newSession.setMaxInactiveInterval(60 * 60 * 24);

                        RememberMeUtil.createRememberMeCookie(request, response, user);
                    } else {
                        RememberMeUtil.clearRememberMeCookie(request, response);
                    }
                }
            }
        }

        chain.doFilter(req, res);
    }
}