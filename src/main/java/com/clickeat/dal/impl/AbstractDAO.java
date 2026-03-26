package com.clickeat.dal.impl;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.clickeat.config.DBContext;
import com.clickeat.dal.interfaces.IGenericDAO;

public abstract class AbstractDAO<T> extends DBContext implements IGenericDAO<T> {

    // Class con bắt buộc phải viết hàm này để map dữ liệu
    protected abstract T mapRow(ResultSet rs) throws SQLException;

    // Hàm SELECT chung
    public List<T> query(String sql, Object... params) {
        List<T> list = new ArrayList<>();
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            setParameter(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Hàm SELECT lấy 1 dòng
    public T queryOne(String sql, Object... params) {
        List<T> list = query(sql, params);
        return list.isEmpty() ? null : list.get(0);
    }

    // Hàm INSERT/UPDATE/DELETE chung
    public int update(String sql, Object... params) {
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            setParameter(ps, params);
            int rows = ps.executeUpdate();
            if (rows > 0 && sql.trim().toUpperCase().startsWith("INSERT")) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        int generatedKey = rs.getInt(1);
                        if (generatedKey > 0) {
                            return generatedKey;
                        }
                    }
                }
                return rows;
            }
            return rows;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    private void setParameter(PreparedStatement ps, Object... params) throws SQLException {
        for (int i = 0; i < params.length; i++) {
            ps.setObject(i + 1, params[i]);
        }
    }

    protected boolean tableExists(String tableName) {
        String sql = "SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, tableName);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            return false;
        }
    }

    protected boolean columnExists(String tableName, String columnName) {
        String sql = "SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = ? AND COLUMN_NAME = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, tableName);
            ps.setString(2, columnName);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            return false;
        }
    }
}
