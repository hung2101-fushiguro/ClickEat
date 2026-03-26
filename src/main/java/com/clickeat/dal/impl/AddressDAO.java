package com.clickeat.dal.impl;

import com.clickeat.model.Address;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class AddressDAO extends AbstractDAO<Address> {

    @Override
    protected Address mapRow(ResultSet rs) throws SQLException {
        Address a = new Address();
        a.setId(rs.getInt("id"));
        a.setUserId(rs.getInt("user_id"));
        a.setReceiverName(rs.getString("receiver_name"));
        a.setReceiverPhone(rs.getString("receiver_phone"));
        a.setAddressLine(rs.getString("address_line"));
        a.setProvinceCode(rs.getString("province_code"));
        a.setProvinceName(rs.getString("province_name"));
        a.setDistrictCode(rs.getString("district_code"));
        a.setDistrictName(rs.getString("district_name"));
        a.setWardCode(rs.getString("ward_code"));
        a.setWardName(rs.getString("ward_name"));

        Object lat = rs.getObject("latitude");
        if (lat != null) {
            a.setLatitude(rs.getDouble("latitude"));
        }

        Object lng = rs.getObject("longitude");
        if (lng != null) {
            a.setLongitude(rs.getDouble("longitude"));
        }

        a.setIsDefault(rs.getBoolean("is_default"));
        a.setNote(rs.getString("note"));
        a.setCreatedAt(rs.getTimestamp("created_at"));
        a.setUpdatedAt(rs.getTimestamp("updated_at"));
        return a;
    }

    public Address findDefaultByUserId(int userId) {
        String sql = """
            SELECT TOP 1 *
            FROM Addresses
            WHERE user_id = ? AND is_default = 1
            ORDER BY id DESC
        """;
        return queryOne(sql, userId);
    }

    public List<Address> findByUserId(int userId) {
        String sql = """
            SELECT *
            FROM Addresses
            WHERE user_id = ?
            ORDER BY is_default DESC, id DESC
        """;
        return query(sql, userId);
    }

    @Override
    public int insert(Address a) {
        String sql = """
        INSERT INTO Addresses(
            user_id, receiver_name, receiver_phone, address_line,
            province_code, province_name,
            district_code, district_name,
            ward_code, ward_name,
            latitude, longitude, is_default, note,
            created_at, updated_at
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, SYSUTCDATETIME(), SYSUTCDATETIME())
    """;

        try (java.sql.Connection conn = getConnection(); java.sql.PreparedStatement ps = conn.prepareStatement(sql, java.sql.Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, a.getUserId());
            ps.setString(2, a.getReceiverName());
            ps.setString(3, a.getReceiverPhone());
            ps.setString(4, a.getAddressLine());
            ps.setString(5, a.getProvinceCode());
            ps.setString(6, a.getProvinceName());
            ps.setString(7, a.getDistrictCode());
            ps.setString(8, a.getDistrictName());
            ps.setString(9, a.getWardCode());
            ps.setString(10, a.getWardName());

            if (a.getLatitude() == 0) {
                ps.setNull(11, java.sql.Types.DECIMAL);
            } else {
                ps.setDouble(11, a.getLatitude());
            }

            if (a.getLongitude() == 0) {
                ps.setNull(12, java.sql.Types.DECIMAL);
            } else {
                ps.setDouble(12, a.getLongitude());
            }

            ps.setBoolean(13, a.getIsDefault() != null ? a.getIsDefault() : false);
            ps.setString(14, a.getNote());

            int affectedRows = ps.executeUpdate();

            if (affectedRows > 0) {
                try (java.sql.ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        return rs.getInt(1);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return 0;
    }

    public boolean setAllNonDefault(int userId) {
        String sql = """
            UPDATE Addresses
            SET is_default = 0,
                updated_at = SYSUTCDATETIME()
            WHERE user_id = ?
        """;
        return update(sql, userId) >= 0;
    }

    public boolean setDefaultAddress(int userId, int addressId) {
        setAllNonDefault(userId);

        String sql = """
            UPDATE Addresses
            SET is_default = 1,
                updated_at = SYSUTCDATETIME()
            WHERE id = ? AND user_id = ?
        """;
        return update(sql, addressId, userId) > 0;
    }

    public boolean updateAddress(Address a) {
        String sql = """
            UPDATE Addresses
            SET receiver_name = ?,
                receiver_phone = ?,
                address_line = ?,
                province_code = ?,
                province_name = ?,
                district_code = ?,
                district_name = ?,
                ward_code = ?,
                ward_name = ?,
                note = ?,
                updated_at = SYSUTCDATETIME()
            WHERE id = ? AND user_id = ?
        """;
        return update(sql,
                a.getReceiverName(),
                a.getReceiverPhone(),
                a.getAddressLine(),
                a.getProvinceCode(),
                a.getProvinceName(),
                a.getDistrictCode(),
                a.getDistrictName(),
                a.getWardCode(),
                a.getWardName(),
                a.getNote(),
                a.getId(),
                a.getUserId()) > 0;
    }

    @Override
    public List<Address> findAll() {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    @Override
    public boolean update(Address t) {
        return updateAddress(t);
    }

    @Override
    public boolean delete(int id) {
        throw new UnsupportedOperationException("Not supported yet.");
    }

    @Override
    public Address findById(int id) {
        String sql = "SELECT * FROM Addresses WHERE id = ?";
        return queryOne(sql, id);
    }
}
