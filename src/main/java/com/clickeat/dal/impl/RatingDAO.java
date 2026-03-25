package com.clickeat.dal.impl;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import com.clickeat.model.Rating;

public class RatingDAO extends AbstractDAO<Rating> {

    @Override
    protected Rating mapRow(ResultSet rs) throws SQLException {
        Rating r = new Rating();
        r.setId(rs.getLong("id"));
        r.setOrderId(rs.getLong("order_id"));
        r.setRaterCustomerId(rs.getObject("rater_customer_id") != null ? rs.getLong("rater_customer_id") : null);
        r.setRaterGuestId(rs.getString("rater_guest_id"));
        r.setTargetType(rs.getString("target_type"));
        r.setTargetUserId(rs.getLong("target_user_id"));
        r.setStars(rs.getInt("stars"));
        r.setComment(rs.getString("comment"));
        r.setCreatedAt(rs.getTimestamp("created_at"));

        // Cột mới thêm để lưu câu trả lời
        try {
            r.setReplyComment(rs.getString("reply_comment"));
        } catch (SQLException e) {
        }

        try {
            r.setCustomerName(rs.getString("full_name"));
        } catch (SQLException e) {
        }
        try {
            r.setOrderCode(rs.getString("order_code"));
        } catch (SQLException e) {
        }

        return r;
    }

    // Lấy danh sách đánh giá có kèm Filter (Tất cả, Chưa trả lời, Tiêu cực)
    public List<Rating> getReviewsForMerchant(int merchantId, String filter) {
        return getReviewsForMerchant(merchantId, filter, 1, 10);
    }

    public List<Rating> getReviewsForMerchant(int merchantId, String filter, int page, int pageSize) {
        String sql = "SELECT r.*, u.full_name, o.order_code "
                + "FROM Ratings r "
                + "LEFT JOIN Users u ON r.rater_customer_id = u.id "
                + "LEFT JOIN Orders o ON r.order_id = o.id "
                + "WHERE r.target_type = 'MERCHANT' AND r.target_user_id = ? ";

        java.util.List<Object> params = new java.util.ArrayList<>();
        params.add(merchantId);

        if ("unanswered".equals(filter)) {
            sql += " AND r.reply_comment IS NULL ";
        } else if ("negative".equals(filter)) {
            sql += " AND r.stars <= 3 ";
        }

        int safePage = Math.max(1, page);
        int safePageSize = Math.max(1, Math.min(pageSize, 100));
        int offset = (safePage - 1) * safePageSize;

        sql += " ORDER BY r.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY";
        params.add(offset);
        params.add(safePageSize);

        return query(sql, params.toArray());
    }

    public int countReviewsForMerchant(int merchantId, String filter) {
        String sql = "SELECT COUNT(*) AS total "
                + "FROM Ratings r "
                + "WHERE r.target_type = 'MERCHANT' AND r.target_user_id = ? ";

        java.util.List<Object> params = new java.util.ArrayList<>();
        params.add(merchantId);

        if ("unanswered".equals(filter)) {
            sql += " AND r.reply_comment IS NULL ";
        } else if ("negative".equals(filter)) {
            sql += " AND r.stars <= 3 ";
        }

        java.util.List<Object[]> rows = queryRaw(sql, params.toArray());
        if (rows.isEmpty() || rows.get(0).length == 0 || rows.get(0)[0] == null) {
            return 0;
        }
        return ((Number) rows.get(0)[0]).intValue();
    }

    // Tính điểm trung bình (Trả về Double để dễ làm tròn)
    public double getAverageRating(int merchantId) {
        String sql = "SELECT AVG(CAST(stars AS FLOAT)) as avg_rating FROM Ratings WHERE target_type = 'MERCHANT' AND target_user_id = ?";
        try (java.sql.Connection conn = getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, merchantId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("avg_rating");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Lấy tổng số đánh giá
    public int getTotalCount(int merchantId) {
        String sql = "SELECT COUNT(*) as total FROM Ratings WHERE target_type = 'MERCHANT' AND target_user_id = ?";
        try (java.sql.Connection conn = getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, merchantId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Lấy số đánh giá tích cực (4 hoặc 5 sao)
    public int getPositiveCount(int merchantId) {
        String sql = "SELECT COUNT(*) as positive FROM Ratings WHERE target_type = 'MERCHANT' AND target_user_id = ? AND stars >= 4";
        try (java.sql.Connection conn = getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, merchantId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("positive");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Hàm lưu câu trả lời của Merchant
    public boolean updateReply(long ratingId, int merchantId, String replyText) {
        String sql = "UPDATE Ratings SET reply_comment = ? WHERE id = ? AND target_type = 'MERCHANT' AND target_user_id = ?";
        return update(sql, replyText, ratingId, merchantId) > 0;
    }

    public boolean hasRatedOrder(int orderId, long customerId, String targetType) {
        String sql = "SELECT 1 FROM Ratings WHERE order_id = ? AND rater_customer_id = ? AND target_type = ?";
        try (java.sql.Connection conn = getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setLong(2, customerId);
            ps.setString(3, targetType);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean submitRating(int orderId, long customerId, long targetUserId, String targetType, int stars, String comment) {
        String sql = "INSERT INTO Ratings (order_id, rater_customer_id, target_type, target_user_id, stars, comment, created_at) "
                + "VALUES (?, ?, ?, ?, ?, ?, GETDATE())";
        return update(sql, orderId, customerId, targetType, targetUserId, stars, comment) > 0;
    }

    public List<Rating> getLatestReviewsForRestaurant(int merchantId, int limit) {
        String sql = "SELECT TOP (?) r.*, u.full_name, o.order_code "
                + "FROM Ratings r "
                + "LEFT JOIN Users u ON r.rater_customer_id = u.id "
                + "LEFT JOIN Orders o ON r.order_id = o.id "
                + "WHERE r.target_type = 'MERCHANT' AND r.target_user_id = ? "
                + "ORDER BY r.created_at DESC";
        return query(sql, limit, merchantId);
    }

    @Override
    public List<Rating> findAll() {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public int insert(Rating t) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public boolean update(Rating t) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public boolean delete(int id) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public Rating findById(int id) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }
}
