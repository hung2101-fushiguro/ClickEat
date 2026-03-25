package com.clickeat.dal.impl;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

import com.clickeat.config.DBContext;
import com.clickeat.dal.interfaces.IGenericDAO;

public abstract class AbstractDAO<T> extends DBContext implements IGenericDAO<T> {

    private static final int DEFAULT_QUERY_TIMEOUT_SECONDS = 8;

    // Class con bắt buộc phải viết hàm này để map dữ liệu
    protected abstract T mapRow(ResultSet rs) throws SQLException;

    // Hàm SELECT chung
    public List<T> query(String sql, Object... params) {
        List<T> list = new ArrayList<>();
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setQueryTimeout(DEFAULT_QUERY_TIMEOUT_SECONDS);
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
            ps.setQueryTimeout(DEFAULT_QUERY_TIMEOUT_SECONDS);
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
        String normalizedSql = sql == null ? "" : sql.trim().toUpperCase();
        boolean isInsert = normalizedSql.startsWith("INSERT");

        try (Connection conn = getConnection(); PreparedStatement ps = isInsert
                ? conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)
                : conn.prepareStatement(sql)) {
            ps.setQueryTimeout(DEFAULT_QUERY_TIMEOUT_SECONDS);
            setParameter(ps, params);
            int rows = ps.executeUpdate();
            if (rows > 0 && isInsert) {
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

    protected boolean tableExists(String tableName) {
        if (tableName == null || tableName.trim().isEmpty()) {
            return false;
        }

        try (Connection conn = getConnection()) {
            DatabaseMetaData meta = conn.getMetaData();
            String catalog = conn.getCatalog();
            if (existsTable(meta, catalog, tableName)) {
                return true;
            }
            if (existsTable(meta, catalog, tableName.toLowerCase())) {
                return true;
            }
            return existsTable(meta, catalog, tableName.toUpperCase());
        } catch (SQLException e) {
            return false;
        }
    }

    protected boolean columnExists(String tableName, String columnName) {
        if (tableName == null || columnName == null
                || tableName.trim().isEmpty() || columnName.trim().isEmpty()) {
            return false;
        }

        try (Connection conn = getConnection()) {
            DatabaseMetaData meta = conn.getMetaData();
            String catalog = conn.getCatalog();
            if (existsColumn(meta, catalog, tableName, columnName)) {
                return true;
            }
            if (existsColumn(meta, catalog, tableName.toLowerCase(), columnName.toLowerCase())) {
                return true;
            }
            return existsColumn(meta, catalog, tableName.toUpperCase(), columnName.toUpperCase());
        } catch (SQLException e) {
            return false;
        }
    }

    private boolean existsTable(DatabaseMetaData meta, String catalog, String tableName) throws SQLException {
        try (ResultSet rs = meta.getTables(catalog, null, tableName, new String[]{"TABLE"})) {
            return rs.next();
        }
    }

    private boolean existsColumn(DatabaseMetaData meta, String catalog, String tableName, String columnName) throws SQLException {
        try (ResultSet rs = meta.getColumns(catalog, null, tableName, columnName)) {
            return rs.next();
        }
    }
}
