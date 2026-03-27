/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.dal.impl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import com.clickeat.model.ShipperReview;

public class ShipperReviewDAO extends AbstractDAO<ShipperReview> {

    @Override
    protected ShipperReview mapRow(ResultSet rs) throws SQLException {
        ShipperReview sr = new ShipperReview();
        sr.setId(rs.getInt("id"));
        sr.setOrderId(rs.getInt("order_id"));
        sr.setShipperId(rs.getInt("shipper_id"));
        sr.setCustomerId(rs.getInt("customer_id"));
        sr.setRating(rs.getInt("rating"));
        sr.setComment(rs.getString("comment"));
        sr.setCreatedAt(rs.getTimestamp("created_at"));
        return sr;
    }

    public double getAverageRating(int shipperId) {
        String sql = "SELECT AVG(CAST(rating AS FLOAT)) as avg_rating FROM ShipperReviews WHERE shipper_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, shipperId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Math.round(rs.getDouble("avg_rating") * 10.0) / 10.0;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }

    public int getTotalReviews(int shipperId) {
        String sql = "SELECT COUNT(id) as total FROM ShipperReviews WHERE shipper_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, shipperId);
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

    public boolean hasCustomerReview(int orderId, int customerId) {
        String sql = "SELECT 1 FROM ShipperReviews WHERE order_id = ? AND customer_id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            return false;
        }
    }

    public boolean insertReview(int orderId, int shipperId, int customerId, int rating, String comment) {
        String normalizedComment = comment == null ? null : comment.trim();
        if (normalizedComment != null && normalizedComment.length() > 1000) {
            normalizedComment = normalizedComment.substring(0, 1000);
        }

        String sql = "INSERT INTO ShipperReviews (order_id, shipper_id, customer_id, rating, comment, created_at) "
                + "VALUES (?, ?, ?, ?, ?, GETDATE())";
        return update(sql, orderId, shipperId, customerId, rating, normalizedComment) > 0;
    }

    @Override
    public List<ShipperReview> findAll() {
        return null;
    }

    @Override
    public ShipperReview findById(int id) {
        return null;
    }

    @Override
    public int insert(ShipperReview t) {
        return 0;
    }

    @Override
    public boolean update(ShipperReview t) {
        return false;
    }

    @Override
    public boolean delete(int id) {
        return false;
    }
}
