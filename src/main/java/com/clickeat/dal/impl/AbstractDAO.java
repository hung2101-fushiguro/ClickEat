package com.clickeat.dal.impl;

import com.clickeat.config.DBContext;
import com.clickeat.dal.interfaces.IGenericDAO;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

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

    protected List<Object[]> queryRaw(String sql, Object... params) {
        List<Object[]> rows = new ArrayList<>();
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            setParameter(ps, params);
            try (ResultSet rs = ps.executeQuery()) {
                ResultSetMetaData metaData = rs.getMetaData();
                int columnCount = metaData.getColumnCount();
                while (rs.next()) {
                    Object[] row = new Object[columnCount];
                    for (int i = 0; i < columnCount; i++) {
                        row[i] = rs.getObject(i + 1);
                    }
                    rows.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return rows;
    }

    // Hàm INSERT/UPDATE/DELETE chung
    public int update(String sql, Object... params) {
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            setParameter(ps, params);
            int rows = ps.executeUpdate();
            if (rows > 0 && sql.trim().toUpperCase().startsWith("INSERT")) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
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
}
