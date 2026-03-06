package com.clickeat.controller.auth;

import com.clickeat.dal.impl.UserDAO;
import com.clickeat.model.User;
import java.io.IOException;
import jakarta.servlet.ServletException; // Chú ý: JAKARTA
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {

    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("views/web/login.jsp").forward(request, response);
    }

    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        
        String userRaw = request.getParameter("username"); 
        String passRaw = request.getParameter("password"); 

        
        UserDAO userDAO = new UserDAO();
        User user = userDAO.checkLogin(userRaw, passRaw);

        if (user != null) {
            
            HttpSession session = request.getSession();
            session.setAttribute("account", user); 

            
            if ("ADMIN".equals(user.getRole())) {
                response.sendRedirect("admin/dashboard"); 
            } else if("SHIPPER".equals(user.getRole())) {
                response.sendRedirect("shipper/dashboard"); 
            }else{
                response.sendRedirect("home");
            }
        } else {
            request.setAttribute("error", "Sai tài khoản hoặc mật khẩu!");
            request.getRequestDispatcher("views/web/login.jsp").forward(request, response);
        }
    }
}