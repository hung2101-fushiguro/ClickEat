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
        boolean isInsert = sql != null && sql.trim().toUpperCase().startsWith("INSERT");
        int generatedKeyMode = isInsert ? Statement.RETURN_GENERATED_KEYS : Statement.NO_GENERATED_KEYS;

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql, generatedKeyMode)) {
            setParameter(ps, params);

            if (isInsert) {
                /*
                 * Dùng executeUpdate() thay vì execute() cho INSERT.
                 *
                 * Lý do: SQL Server trigger (VD: TR_CartItems_EnforceSingleMerchant)
                 * sinh thêm result sets phụ sau khi INSERT. Nếu dùng execute() + vòng
                 * getMoreResults(CLOSE_CURRENT_RESULT), tất cả result sets (kể cả kênh
                 * generated keys) bị đóng trước khi getGeneratedKeys() được gọi → crash
                 * SQLServerException: "The statement must be executed before any results
                 * can be obtained."
                 *
                 * executeUpdate() bỏ qua result sets phụ của trigger và cho phép gọi
                 * getGeneratedKeys() ngay sau đó một cách an toàn.
                 */
                int rows = ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        int generatedKey = rs.getInt(1);
                        if (generatedKey > 0) {
                            return generatedKey;
                        }
                    }
                }
                return rows; // Fallback: trả số dòng bị ảnh hưởng nếu không có generated key
            } else {
                // Với UPDATE / DELETE: dùng execute() + lặp multi-result như cũ
                boolean hasResultSet = ps.execute();
                int affectedRows = 0;
                Integer firstNumericResult = null;

                while (true) {
                    if (hasResultSet) {
                        try (ResultSet rs = ps.getResultSet()) {
                            if (firstNumericResult == null && rs != null && rs.next()) {
                                Object firstCol = rs.getObject(1);
                                if (firstCol instanceof Number) {
                                    firstNumericResult = ((Number) firstCol).intValue();
                                }
                            }
                        }
                    } else {
                        int count = ps.getUpdateCount();
                        if (count == -1) {
                            break;
                        }
                        affectedRows += Math.max(0, count);
                    }

                    hasResultSet = ps.getMoreResults(Statement.CLOSE_CURRENT_RESULT);
                    if (!hasResultSet && ps.getUpdateCount() == -1) {
                        break;
                    }
                }

                if (firstNumericResult != null && firstNumericResult > 0) {
                    return firstNumericResult;
                }
                return affectedRows;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    // Overload dùng chung transaction từ bên ngoài (không tự đóng Connection)
    public int update(Connection conn, String sql, Object... params) throws SQLException {
        boolean isInsert = sql != null && sql.trim().toUpperCase().startsWith("INSERT");
        int generatedKeyMode = isInsert ? Statement.RETURN_GENERATED_KEYS : Statement.NO_GENERATED_KEYS;

        try (PreparedStatement ps = conn.prepareStatement(sql, generatedKeyMode)) {
            setParameter(ps, params);

            if (isInsert) {
                int rows = ps.executeUpdate();
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

            boolean hasResultSet = ps.execute();
            int affectedRows = 0;

            while (true) {
                if (hasResultSet) {
                    try (ResultSet rs = ps.getResultSet()) {
                        // Ignore result sets for non-INSERT DML.
                    }
                } else {
                    int count = ps.getUpdateCount();
                    if (count == -1) {
                        break;
                    }
                    affectedRows += Math.max(0, count);
                }

                hasResultSet = ps.getMoreResults(Statement.CLOSE_CURRENT_RESULT);
                if (!hasResultSet && ps.getUpdateCount() == -1) {
                    break;
                }
            }

            return affectedRows;
        }
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
