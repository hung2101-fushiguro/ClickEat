package com.clickeat.controller.web;

import com.clickeat.dal.impl.AddressDAO;
import com.clickeat.dal.impl.CustomerProfileDAO;
import com.clickeat.dal.impl.UserDAO;
import com.clickeat.model.Address;
import com.clickeat.model.CustomerProfile;
import com.clickeat.model.User;
import java.io.IOException;
import java.util.regex.Pattern;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet(name = "CustomerProfileServlet", urlPatterns = {"/customer/profile"})
public class CustomerProfileServlet extends HttpServlet {

    private static final Pattern EMAIL_PATTERN
            = Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");

    private boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private String trim(String s) {
        return s == null ? null : s.trim();
    }

    private User getLoggedCustomer(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }

        User account = (User) session.getAttribute("account");
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }

        if (!"CUSTOMER".equalsIgnoreCase(account.getRole())) {
            response.sendRedirect(request.getContextPath() + "/home");
            return null;
        }

        return account;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User account = getLoggedCustomer(request, response);
        if (account == null) {
            return;
        }

        CustomerProfileDAO customerProfileDAO = new CustomerProfileDAO();
        customerProfileDAO.ensureExists(account.getId());

        CustomerProfile profile = customerProfileDAO.findByUserId(account.getId());

        AddressDAO addressDAO = new AddressDAO();
        Address defaultAddress = addressDAO.findDefaultByUserId(account.getId());

        request.setAttribute("profileUser", account);
        request.setAttribute("customerProfile", profile);
        request.setAttribute("defaultAddress", defaultAddress);
        request.getRequestDispatcher("/views/web/profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        User account = getLoggedCustomer(request, response);
        if (account == null) {
            return;
        }

        String fullName = trim(request.getParameter("fullName"));
        String email = trim(request.getParameter("email"));
        String avatarUrl = trim(request.getParameter("avatarUrl"));
        String foodPreferences = trim(request.getParameter("foodPreferences"));
        String allergies = trim(request.getParameter("allergies"));
        String healthGoal = trim(request.getParameter("healthGoal"));
        String dailyCalorieTargetRaw = trim(request.getParameter("dailyCalorieTarget"));

        String receiverName = trim(request.getParameter("receiverName"));
        String receiverPhone = trim(request.getParameter("receiverPhone"));
        String addressLine = trim(request.getParameter("addressLine"));
        String provinceName = trim(request.getParameter("provinceName"));
        String districtName = trim(request.getParameter("districtName"));
        String wardName = trim(request.getParameter("wardName"));
        String addressNote = trim(request.getParameter("addressNote"));

        String error = null;

        if (isBlank(fullName) || fullName.length() < 2 || fullName.length() > 100) {
            error = "Họ tên phải từ 2 đến 100 ký tự.";
        } else if (!fullName.matches("^[\\p{L}0-9\\s'.-]+$")) {
            error = "Họ tên chỉ được chứa chữ cái, số, khoảng trắng và ký tự cơ bản.";
        } else if (isBlank(email) || !EMAIL_PATTERN.matcher(email).matches() || email.length() > 150) {
            error = "Email không hợp lệ.";
        } else if (!isBlank(avatarUrl)
                && !(avatarUrl.startsWith("http://")
                || avatarUrl.startsWith("https://")
                || avatarUrl.startsWith("/"))) {
            error = "Ảnh đại diện phải là URL hợp lệ hoặc đường dẫn bắt đầu bằng /.";
        } else if (foodPreferences != null && foodPreferences.length() > 1000) {
            error = "Sở thích ăn uống không được vượt quá 1000 ký tự.";
        } else if (allergies != null && allergies.length() > 1000) {
            error = "Dị ứng không được vượt quá 1000 ký tự.";
        } else if (healthGoal != null && healthGoal.length() > 200) {
            error = "Mục tiêu sức khỏe không được vượt quá 200 ký tự.";
        }

        Integer dailyCalorieTarget = null;
        if (error == null && !isBlank(dailyCalorieTargetRaw)) {
            try {
                dailyCalorieTarget = Integer.valueOf(dailyCalorieTargetRaw);
                if (dailyCalorieTarget < 500 || dailyCalorieTarget > 10000) {
                    error = "Mục tiêu calo mỗi ngày phải trong khoảng 500 - 10000.";
                }
            } catch (NumberFormatException e) {
                error = "Mục tiêu calo mỗi ngày phải là số hợp lệ.";
            }
        }

        boolean hasAnyAddressField
                = !isBlank(receiverName)
                || !isBlank(receiverPhone)
                || !isBlank(addressLine)
                || !isBlank(provinceName)
                || !isBlank(districtName)
                || !isBlank(wardName)
                || !isBlank(addressNote);

        if (error == null && hasAnyAddressField) {
            if (isBlank(receiverName) || receiverName.length() < 2 || receiverName.length() > 100) {
                error = "Tên người nhận phải từ 2 đến 100 ký tự.";
            } else if (!receiverName.matches("^[\\p{L}0-9\\s'.-]+$")) {
                error = "Tên người nhận không hợp lệ.";
            } else if (isBlank(receiverPhone) || !receiverPhone.matches("^[0-9]{8,11}$")) {
                error = "Số điện thoại nhận hàng phải gồm 8 đến 11 chữ số.";
            } else if (isBlank(addressLine) || addressLine.length() < 5 || addressLine.length() > 255) {
                error = "Địa chỉ chi tiết phải từ 5 đến 255 ký tự.";
            } else if (isBlank(provinceName) || isBlank(districtName) || isBlank(wardName)) {
                error = "Vui lòng nhập đầy đủ tỉnh/thành, quận/huyện và phường/xã.";
            } else if (!isBlank(addressNote) && addressNote.length() > 255) {
                error = "Ghi chú giao hàng không được vượt quá 255 ký tự.";
            }
        }

        UserDAO userDAO = new UserDAO();
        if (error == null && userDAO.isEmailUsedByAnother(email, account.getId())) {
            error = "Email này đã được sử dụng bởi tài khoản khác.";
        }

        CustomerProfileDAO customerProfileDAO = new CustomerProfileDAO();
        customerProfileDAO.ensureExists(account.getId());

        AddressDAO addressDAO = new AddressDAO();
        Address defaultAddress = addressDAO.findDefaultByUserId(account.getId());

        if (error != null) {
            CustomerProfile profile = new CustomerProfile();
            profile.setUserId(account.getId());
            profile.setFoodPreferences(foodPreferences);
            profile.setAllergies(allergies);
            profile.setHealthGoal(healthGoal);
            profile.setDailyCalorieTarget(dailyCalorieTarget);

            account.setFullName(fullName);
            account.setEmail(email);
            account.setAvatarUrl(avatarUrl);

            Address addressView = defaultAddress != null ? defaultAddress : new Address();
            addressView.setUserId(account.getId());
            addressView.setReceiverName(receiverName);
            addressView.setReceiverPhone(receiverPhone);
            addressView.setAddressLine(addressLine);
            addressView.setProvinceName(provinceName);
            addressView.setDistrictName(districtName);
            addressView.setWardName(wardName);
            addressView.setNote(addressNote);

            request.setAttribute("error", error);
            request.setAttribute("profileUser", account);
            request.setAttribute("customerProfile", profile);
            request.setAttribute("defaultAddress", addressView);
            request.getRequestDispatcher("/views/web/profile.jsp").forward(request, response);
            return;
        }

        boolean updatedUser = userDAO.updateCustomerProfileInfo(account.getId(), fullName, email, avatarUrl);

        CustomerProfile profile = new CustomerProfile();
        profile.setUserId(account.getId());
        profile.setFoodPreferences(foodPreferences);
        profile.setAllergies(allergies);
        profile.setHealthGoal(healthGoal);
        profile.setDailyCalorieTarget(dailyCalorieTarget);

        boolean updatedProfile = customerProfileDAO.updateProfile(profile);

        boolean updatedAddress = false;
        if (hasAnyAddressField) {
            if (defaultAddress == null) {
                Address newAddress = new Address();
                newAddress.setUserId(account.getId());
                newAddress.setReceiverName(receiverName);
                newAddress.setReceiverPhone(receiverPhone);
                newAddress.setAddressLine(addressLine);
                newAddress.setProvinceCode("");
                newAddress.setProvinceName(provinceName);
                newAddress.setDistrictCode("");
                newAddress.setDistrictName(districtName);
                newAddress.setWardCode("");
                newAddress.setWardName(wardName);
                newAddress.setIsDefault(true);
                newAddress.setNote(addressNote);

                int newAddressId = addressDAO.insert(newAddress);
                if (newAddressId > 0) {
                    updatedAddress = true;
                    customerProfileDAO.setDefaultAddressId(account.getId(), newAddressId);
                    addressDAO.setDefaultAddress(account.getId(), newAddressId);
                }
            } else {
                defaultAddress.setReceiverName(receiverName);
                defaultAddress.setReceiverPhone(receiverPhone);
                defaultAddress.setAddressLine(addressLine);
                defaultAddress.setProvinceName(provinceName);
                defaultAddress.setDistrictName(districtName);
                defaultAddress.setWardName(wardName);
                defaultAddress.setNote(addressNote);

                updatedAddress = addressDAO.updateAddress(defaultAddress);
            }
        }

        if (updatedUser || updatedProfile || updatedAddress) {
            account.setFullName(fullName);
            account.setEmail(email);
            account.setAvatarUrl(avatarUrl);
            request.getSession().setAttribute("account", account);
            request.getSession().setAttribute("toastMsg", "Cập nhật thông tin thành công.");
        } else {
            request.getSession().setAttribute("toastError", "Không có thay đổi nào được lưu.");
        }

        response.sendRedirect(request.getContextPath() + "/customer/profile");
    }
}
