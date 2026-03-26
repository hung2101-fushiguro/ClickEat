package com.clickeat.dal.impl;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Base64;
import java.util.List;

import com.clickeat.dal.interfaces.IUserDAO;
import com.clickeat.model.User;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

public class UserDAO extends AbstractDAO<User> implements IUserDAO {

    @Override
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
        String sql = "SELECT * FROM Users WHERE (phone = ? OR email = ?)";
        User user = queryOne(sql, username, username);

        if (user == null) {
            return null;
        }

        String storedHash = user.getPasswordHash();
        if (storedHash == null || storedHash.isBlank()) {
            return null;
        }

        boolean matched;
        if (storedHash.contains(":")) {
            matched = verifyPassword(password, storedHash);
        } else {
            matched = storedHash.equals(password); // hỗ trợ tài khoản cũ lưu plain text
        }

        if (!matched) {
            return null;
        }

        return user;
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
        return update(sql, newPasswordHash, userId) > 0;
    }

    @Override
    public boolean changeUserStatus(int userId, String newStatus) {
        String sql = "UPDATE Users SET status = ?, updated_at = GETDATE() WHERE id = ?";
        return update(sql, newStatus, userId) > 0;
    }

    @Override
    public boolean updateAvatar(int userId, String avatarUrl) {
        String sql = "UPDATE Users SET avatar_url = ?, updated_at = GETDATE() WHERE id = ?";
        return update(sql, avatarUrl, userId) > 0;
    }

    public boolean updateCustomerProfileInfo(int userId, String fullName, String email, String avatarUrl) {
        String sql = """
        UPDATE Users
        SET full_name = ?,
            email = ?,
            avatar_url = ?,
            updated_at = GETDATE()
        WHERE id = ?
    """;
        return update(sql, fullName, email, avatarUrl, userId) > 0;
    }

    public boolean isEmailUsedByAnother(String email, int currentUserId) {
        String sql = "SELECT 1 FROM Users WHERE email = ? AND id <> ?";
        try (java.sql.Connection conn = getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setInt(2, currentUserId);

            try (java.sql.ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    @Override
    public boolean checkDuplicateForUpdate(String phone, String email, int currentUserId) {
        String sql = "SELECT 1 FROM Users WHERE (phone = ? OR email = ?) AND id != ?";
        try {
            java.sql.Connection conn = getConnection();
            java.sql.PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, phone);
            ps.setString(2, email);
            ps.setInt(3, currentUserId);
            java.sql.ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return true;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
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
        String sql = "UPDATE Users SET full_name = ?, email = ?, phone = ? WHERE id = ?";
        return update(sql, user.getFullName(), user.getEmail(), user.getPhone(), user.getId()) > 0;
    }

    @Override
    public boolean delete(int id) {
        String sql = "UPDATE Users SET status = 'INACTIVE', updated_at = GETDATE() WHERE id = ?";
        return update(sql, id) > 0;
    }

    public User findByEmail(String email) {
        String sql = "SELECT * FROM Users WHERE email = ? AND status = 'ACTIVE'";
        return queryOne(sql, email);
    }

    public User findByPhoneAnyStatus(String phone) {
        String sql = "SELECT * FROM Users WHERE phone = ?";
        return queryOne(sql, phone);
    }

    public User findByEmailAnyStatus(String email) {
        String sql = "SELECT * FROM Users WHERE email = ?";
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

    // Dùng cho GoogleCompleteServlet mới
    public long createGoogleUserReturnId(String fullName, String email, String phone, String passwordHash) {
        String sql = """
            INSERT INTO Users(full_name, email, phone, password_hash, role, status, created_at, updated_at)
            OUTPUT INSERTED.id
            VALUES(?, ?, ?, ?, 'CUSTOMER', 'ACTIVE', SYSUTCDATETIME(), SYSUTCDATETIME())
        """;

        try (java.sql.Connection conn = getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, fullName);
            ps.setString(2, email);
            ps.setString(3, phone);
            ps.setString(4, passwordHash);

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

    // Giữ lại nếu chỗ khác còn gọi hàm cũ
    public long createGoogleUserReturnId(String fullName, String email, String phone) {
        return createGoogleUserReturnId(fullName, email, phone, null);
    }

    public void createCustomerProfile(long userId, String food, String allergies, String goal, Integer dailyCal) {
        String sql = "INSERT INTO CustomerProfiles(user_id, food_preferences, allergies, health_goal, daily_calorie_target) VALUES(?, ?, ?, ?, ?)";
        update(sql, userId, food, allergies, goal, dailyCal);
    }

    public boolean reactivateMerchantForReapply(int userId, String fullName, String email, String phone, String passwordHash) {
        String sql = "UPDATE Users SET full_name = ?, email = ?, phone = ?, password_hash = ?, role = 'MERCHANT', status = 'ACTIVE', updated_at = GETDATE() WHERE id = ?";
        return update(sql, fullName, email, phone, passwordHash, userId) > 0;
    }

    public boolean deleteHard(int userId) {
        String sql = "DELETE FROM Users WHERE id = ?";
        return update(sql, userId) > 0;
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

    private boolean verifyPassword(String rawPassword, String storedPasswordHash) {
        try {
            String[] parts = storedPasswordHash.split(":");
            if (parts.length != 2) {
                return false;
            }

            byte[] salt = Base64.getDecoder().decode(parts[0]);
            byte[] expectedHash = Base64.getDecoder().decode(parts[1]);

            PBEKeySpec spec = new PBEKeySpec(rawPassword.toCharArray(), salt, 65536, 256);
            SecretKeyFactory skf = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
            byte[] actualHash = skf.generateSecret(spec).getEncoded();

            return slowEquals(expectedHash, actualHash);
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean isSameAsCurrentPassword(int userId, String rawPassword) {
        String sql = "SELECT password_hash FROM Users WHERE id = ?";
        try (java.sql.Connection conn = getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);

            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String storedHash = rs.getString("password_hash");

                    if (storedHash == null || storedHash.isBlank()) {
                        return false;
                    }

                    if (storedHash.contains(":")) {
                        return verifyPassword(rawPassword, storedHash);
                    } else {
                        return storedHash.equals(rawPassword);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    private boolean slowEquals(byte[] a, byte[] b) {
        if (a == null || b == null || a.length != b.length) {
            return false;
        }

        int diff = 0;
        for (int i = 0; i < a.length; i++) {
            diff |= a[i] ^ b[i];
        }
        return diff == 0;
    }
}
