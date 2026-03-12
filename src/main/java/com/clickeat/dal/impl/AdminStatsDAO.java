/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.dal.impl;

import com.clickeat.dal.interfaces.IAdminStatsDAO;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.Map;

// Ta kế thừa AbstractDAO với Object ảo vì DAO này chỉ dùng để query số liệu (Scalar)
public class AdminStatsDAO extends AbstractDAO<Object> implements IAdminStatsDAO {

    @Override
    protected Object mapRow(ResultSet rs) throws SQLException {
        return null;
    }

    @Override
    public double getTotalGMV() {
        String sql = "SELECT SUM(total_amount) as gmv FROM Orders WHERE order_status = 'DELIVERED'";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getDouble("gmv");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public int getTotalOrders() {
        String sql = "SELECT COUNT(id) as total FROM Orders";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("total");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    @Override
    public int getTotalUsersByRole(String role) {
        String sql = "SELECT COUNT(id) as total FROM Users WHERE role = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, role);
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

    @Override
    public Map<String, Double> getRevenueLast7Days() {
        Map<String, Double> map = new LinkedHashMap<>();
        LocalDate today = LocalDate.now();
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd/MM");

        // Khởi tạo 7 ngày với giá trị 0đ
        for (int i = 6; i >= 0; i--) {
            map.put(today.minusDays(i).format(formatter), 0.0);
        }

        String sql = "SELECT CAST(delivered_at AS DATE) as d_date, SUM(total_amount) as daily_gmv "
                + "FROM Orders WHERE order_status = 'DELIVERED' AND delivered_at >= DATEADD(day, -6, CAST(GETDATE() AS DATE)) "
                + "GROUP BY CAST(delivered_at AS DATE)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String dateStr = rs.getDate("d_date").toLocalDate().format(formatter);
                if (map.containsKey(dateStr)) {
                    map.put(dateStr, rs.getDouble("daily_gmv"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return map;
    }

    @Override
    public Map<String, Integer> getOrderStatusDistribution() {
        Map<String, Integer> map = new LinkedHashMap<>();
        String sql = "SELECT order_status, COUNT(id) as count FROM Orders GROUP BY order_status";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                map.put(rs.getString("order_status"), rs.getInt("count"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return map;
    }

    @Override
    public java.util.List<Object> findAll() {
        return null;
    }

    @Override
    public Object findById(int id) {
        return null;
    }

    @Override
    public int insert(Object t) {
        return 0;
    }

    @Override
    public boolean update(Object t) {
        return false;
    }

    @Override
    public boolean delete(int id) {
        return false;
    }
}
