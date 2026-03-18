package com.clickeat.dal.impl;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import com.clickeat.dal.interfaces.IUserDAO;
import com.clickeat.model.User;

public class UserDAO extends AbstractDAO<User> implements IUserDAO {

    @Override //day la ham map du lieu tu 1 dong trong database sang object java
    protected User mapRow(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setFullName(rs.getString("full_name"));
        user.setEmail(rs.getString("email"));
        user.setPhone(rs.getString("phone"));
        user.setPasswordHash(rs.getString("password_hash"));
        user.setRole(rs.getString("role"));
        user.setStatus(rs.getString("status"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        user.setAvatarUrl(rs.getString("avatar_url"));
        return user;
    }

    @Override
    public User checkLogin(String username, String password) {
        String normalizedUsername = username == null ? "" : username.trim();
        String normalizedPhone = normalizedUsername.replace(" ", "").replace("-", "").replace(".", "");
        String normalizedEmail = normalizedUsername.toLowerCase();

        String sql = "SELECT TOP 1 * FROM Users "
                + "WHERE (REPLACE(REPLACE(REPLACE(ISNULL(phone,''), ' ', ''), '-', ''), '.', '') = ? "
                + "OR LOWER(LTRIM(RTRIM(ISNULL(email,'')))) = ?) "
                + "AND LTRIM(RTRIM(ISNULL(password_hash,''))) = ? "
                + "AND status = 'ACTIVE' "
                + "ORDER BY id DESC";
        return queryOne(sql, normalizedPhone, normalizedEmail, password);
    }

    public User findByCredentialsAnyStatus(String username, String password) {
        String normalizedUsername = username == null ? "" : username.trim();
        String normalizedPhone = normalizedUsername.replace(" ", "").replace("-", "").replace(".", "");
        String normalizedEmail = normalizedUsername.toLowerCase();

        String sql = "SELECT TOP 1 * FROM Users "
                + "WHERE (REPLACE(REPLACE(REPLACE(ISNULL(phone,''), ' ', ''), '-', ''), '.', '') = ? "
                + "OR LOWER(LTRIM(RTRIM(ISNULL(email,'')))) = ?) "
                + "AND LTRIM(RTRIM(ISNULL(password_hash,''))) = ? "
                + "ORDER BY id DESC";
        return queryOne(sql, normalizedPhone, normalizedEmail, password);
    }

    @Override
    public boolean checkPhoneExist(String phone) {
        String sql = "SELECT * FROM Users WHERE phone = ?";
        List<User> list = query(sql, phone);
        return !list.isEmpty();
    }

    @Override
    public boolean checkEmailExist(String email) {
        String sql = "SELECT * FROM Users WHERE email = ?";
        List<User> list = query(sql, email);
        return !list.isEmpty();
    }

    @Override
    public List<User> findByRole(String role) {
        String sql = "SELECT * FROM Users WHERE role = ? ORDER BY created_at DESC";
        return query(sql, role);
    }

    @Override
    public List<User> searchUsers(String keyword) {
        String searchPattern = "%" + keyword + "%";
        String sql = "SELECT * FROM Users WHERE full_name LIKE ? OR email LIKE ? OR phone LIKE ?";
        return query(sql, searchPattern, searchPattern, searchPattern);
    }

    @Override
    public boolean changePassword(int userId, String newPasswordHash) {
        String sql = "UPDATE Users SET password_hash = ?, updated_at = GETDATE() WHERE id = ?";
        // update() trả về số dòng ảnh hưởng, > 0 nghĩa là thành công
        return update(sql, newPasswordHash, userId) > 0;
    }

    @Override
    public boolean changeUserStatus(int userId, String newStatus) {
        String sql = "UPDATE Users SET status = ?, updated_at = GETDATE() WHERE id = ?";
        // Giả định hàm update() của IGenericDAO trả về int (số dòng bị ảnh hưởng)
        return update(sql, newStatus, userId) > 0;
    }

    @Override
    public boolean updateAvatar(int userId, String avatarUrl) {
        String sql = "UPDATE Users SET avatar_url = ?, updated_at = GETDATE() WHERE id = ?";
        return update(sql, avatarUrl, userId) > 0;
    }

    @Override
    public boolean checkDuplicateForUpdate(String phone, String email, int currentUserId) {
        String sql = "SELECT 1 FROM Users WHERE (phone = ? OR email = ?) AND id != ?";
        try {
            java.sql.Connection conn = getConnection();
            java.sql.PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, phone);
            ps.setString(2, email);
            ps.setInt(3, currentUserId); // Dùng setInt vì ID trong Model của bạn là int
            java.sql.ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return true; // Trùng với người khác
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false; // An toàn
    }

    @Override
    public List<User> findAll() {
        String sql = "SELECT * FROM Users";
        return query(sql);
    }

    @Override
    public User findById(int id) {
        String sql = "SELECT * FROM Users WHERE id = ?";
        return queryOne(sql, id);
    }

    @Override
    public int insert(User user) {
        // Insert user mới (Đăng ký)
        // status mặc định là ACTIVE
        String sql = "INSERT INTO Users (full_name, email, phone, password_hash, role, status, created_at) VALUES (?, ?, ?, ?, ?, ?, GETDATE())";
        return update(sql,
                user.getFullName(),
                user.getEmail(),
                user.getPhone(),
                user.getPasswordHash(),
                user.getRole(),
                "ACTIVE");
    }

    @Override
    public boolean update(User user) {
        // Đã xóa bỏ updated_at để tránh lỗi Silent Fail
        String sql = "UPDATE Users SET full_name = ?, email = ?, phone = ? WHERE id = ?";
        return update(sql, user.getFullName(), user.getEmail(), user.getPhone(), user.getId()) > 0;
    }

    @Override
    public boolean delete(int id) {
        // Xóa mềm (Soft Delete) - Chỉ đổi trạng thái sang INACTIVE chứ không xóa mất dữ liệu
        String sql = "UPDATE Users SET status = 'INACTIVE', updated_at = GETDATE() WHERE id = ?";
        return update(sql, id) > 0;
    }

    public User findByEmail(String email) {
        String sql = "SELECT * FROM Users WHERE email = ? AND status = 'ACTIVE'";
        return queryOne(sql, email);
    }

    public User findByGoogleSub(String sub) {
        String sql = "SELECT u.* FROM Users u JOIN UserAuthProviders p ON p.user_id = u.id WHERE p.provider = 'GOOGLE' AND p.provider_user_id = ? AND u.status = 'ACTIVE'";
        return queryOne(sql, sub);
    }

    public void linkGoogleProvider(int userId, String sub) {
        String check = "SELECT COUNT(*) AS c FROM UserAuthProviders WHERE provider='GOOGLE' AND provider_user_id=?";
        Integer existed = queryInt(check, sub);
        if (existed != null && existed > 0) {
            return;
        }
        String sql = "INSERT INTO UserAuthProviders(user_id, provider, provider_user_id) VALUES(?, 'GOOGLE', ?)";
        update(sql, userId, sub);
    }

    public long createGoogleUserReturnId(String fullName, String email, String phone) {
        String sql = "INSERT INTO Users(full_name, email, phone, password_hash, role, status, created_at, updated_at) OUTPUT INSERTED.id VALUES(?, ?, ?, NULL, 'CUSTOMER', 'ACTIVE', SYSUTCDATETIME(), SYSUTCDATETIME())";
        try (java.sql.Connection conn = getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, phone);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getLong(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    public void createCustomerProfile(long userId, String food, String allergies, String goal, Integer dailyCal) {
        String sql = "INSERT INTO CustomerProfiles(user_id, food_preferences, allergies, health_goal, daily_calorie_target) VALUES(?, ?, ?, ?, ?)";
        update(sql, userId, food, allergies, goal, dailyCal);
    }

    private Integer queryInt(String sql, Object... params) {
        try (java.sql.Connection conn = getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            if (params != null) {
                for (int i = 0; i < params.length; i++) {
                    ps.setObject(i + 1, params[i]);
                }
            }
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
