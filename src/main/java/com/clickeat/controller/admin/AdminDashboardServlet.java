package com.clickeat.controller.admin;

import com.clickeat.dal.impl.AdminStatsDAO;
import com.clickeat.dal.impl.MerchantKYCDAO;
import com.clickeat.dal.impl.OrderIssueDAO;
import com.clickeat.dal.impl.UserDAO;
import com.clickeat.dal.impl.WithdrawalRequestDAO;
import com.clickeat.model.User;
import java.io.IOException;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "AdminDashboardServlet", urlPatterns = {"/admin/dashboard"})
public class AdminDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User account = (User) session.getAttribute("account");

        if (account == null || !"ADMIN".equals(account.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 1. Lấy danh sách KYC chờ duyệt
        MerchantKYCDAO kycDAO = new MerchantKYCDAO();
        request.setAttribute("pendingKYCs", kycDAO.getPendingKYCs());

        // 2. Lấy danh sách Yêu cầu rút tiền chờ duyệt
        WithdrawalRequestDAO withdrawDAO = new WithdrawalRequestDAO();
        request.setAttribute("pendingWithdrawals", withdrawDAO.getPendingRequests());

        // 3. Lấy danh sách Sự cố (Dispute) chờ giải quyết
        OrderIssueDAO issueDAO = new OrderIssueDAO();
        request.setAttribute("pendingIssues", issueDAO.getPendingIssues());

        // 4. Lấy dữ liệu Thống kê cho Tổng quan (Dashboard)
        AdminStatsDAO statsDAO = new AdminStatsDAO();
        request.setAttribute("totalGMV", statsDAO.getTotalGMV());
        request.setAttribute("totalOrders", statsDAO.getTotalOrders());
        request.setAttribute("totalCustomers", statsDAO.getTotalUsersByRole("CUSTOMER"));
        request.setAttribute("totalMerchants", statsDAO.getTotalUsersByRole("MERCHANT"));
        request.setAttribute("totalShippers", statsDAO.getTotalUsersByRole("SHIPPER"));

        Map<String, Double> revData = statsDAO.getRevenueLast7Days();
        request.setAttribute("revLabels", "'" + String.join("','", revData.keySet()) + "'");
        request.setAttribute("revValues", revData.values().toString().replaceAll("[\\[\\]]", ""));

        Map<String, Integer> statusData = statsDAO.getOrderStatusDistribution();
        request.setAttribute("statusLabels", "'" + String.join("','", statusData.keySet()) + "'");
        request.setAttribute("statusValues", statusData.values().toString().replaceAll("[\\[\\]]", ""));

        // 5. Lấy danh sách Người dùng để quản lý (CRUD)
        UserDAO userDAO = new UserDAO();
        request.setAttribute("listCustomers", userDAO.findByRole("CUSTOMER"));
        request.setAttribute("listMerchants", userDAO.findByRole("MERCHANT"));
        request.setAttribute("listShippers", userDAO.findByRole("SHIPPER"));

        String tab = request.getParameter("tab");
        request.setAttribute("activeTab", (tab != null) ? tab : "overview");

        request.getRequestDispatcher("/views/admin/dashboard.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User account = (User) request.getSession().getAttribute("account");
        if (account == null || !"ADMIN".equals(account.getRole())) {
            return;
        }

        String action = request.getParameter("action");
        String currentTab = "overview";

        // XỬ LÝ DUYỆT KYC QUÁN ĂN
        if ("APPROVE_KYC".equals(action) || "REJECT_KYC".equals(action)) {
            currentTab = "kyc";
            long kycId = Long.parseLong(request.getParameter("kycId"));
            long merchantId = Long.parseLong(request.getParameter("merchantId"));
            MerchantKYCDAO kycDAO = new MerchantKYCDAO();

            if ("APPROVE_KYC".equals(action)) {
                if (kycDAO.approveKYC(kycId, merchantId, account.getId())) {
                    request.getSession().setAttribute("toastMsg", "Đã DUYỆT thành công quán ăn!");
                }
            } else {
                String reason = request.getParameter("rejectReason");
                if (kycDAO.rejectKYC(kycId, merchantId, account.getId(), reason)) {
                    request.getSession().setAttribute("toastMsg", "Đã TỪ CHỐI hồ sơ quán ăn.");
                }
            }
        } // XỬ LÝ RÚT TIỀN
        else if ("APPROVE_WITHDRAW".equals(action) || "REJECT_WITHDRAW".equals(action)) {
            currentTab = "finance";
            long reqId = Long.parseLong(request.getParameter("requestId"));
            WithdrawalRequestDAO wDAO = new WithdrawalRequestDAO();

            if ("APPROVE_WITHDRAW".equals(action)) {
                long shipperId = Long.parseLong(request.getParameter("shipperId"));
                double amount = Double.parseDouble(request.getParameter("amount"));

                if (wDAO.approveRequest(reqId, shipperId, amount)) {
                    request.getSession().setAttribute("toastMsg", "Đã duyệt và trừ tiền thành công!");
                } else {
                    request.getSession().setAttribute("toastError", "Lỗi: Số dư ví không hợp lệ.");
                }
            } else {
                if (wDAO.rejectRequest(reqId)) {
                    request.getSession().setAttribute("toastMsg", "Đã TỪ CHỐI lệnh rút tiền.");
                }
            }
        } // XỬ LÝ SỰ CỐ (DISPUTE)
        else if ("RESOLVE_ISSUE".equals(action)) {
            currentTab = "dispute";
            int issueId = Integer.parseInt(request.getParameter("issueId"));
            OrderIssueDAO issueDAO = new OrderIssueDAO();

            if (issueDAO.resolveIssue(issueId)) {
                request.getSession().setAttribute("toastMsg", "Đã đóng hồ sơ sự cố thành công!");
            } else {
                request.getSession().setAttribute("toastError", "Có lỗi xảy ra khi cập nhật sự cố.");
            }
        } // XỬ LÝ KHÓA / MỞ KHÓA TÀI KHOẢN
        else if ("CHANGE_USER_STATUS".equals(action)) {
            currentTab = "users";
            int targetUserId = Integer.parseInt(request.getParameter("targetUserId"));
            String newStatus = request.getParameter("newStatus");

            UserDAO userDAO = new UserDAO();
            if (userDAO.changeUserStatus(targetUserId, newStatus)) {
                request.getSession().setAttribute("toastMsg", "Đã cập nhật trạng thái tài khoản!");
            } else {
                request.getSession().setAttribute("toastError", "Có lỗi xảy ra khi cập nhật.");
            }
        }

        response.sendRedirect(request.getContextPath() + "/admin/dashboard?tab=" + currentTab);
    }
}
