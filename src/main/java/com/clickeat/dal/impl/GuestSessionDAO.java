package com.clickeat.dal.impl;

import com.clickeat.model.GuestSession;
import java.sql.ResultSet;
import java.sql.SQLException;

public class GuestSessionDAO extends AbstractDAO<GuestSession> {

    @Override
    protected GuestSession mapRow(ResultSet rs) throws SQLException {
        GuestSession g = new GuestSession();
        g.setGuestId(rs.getString("guest_id"));
        g.setContactPhone(rs.getString("contact_phone"));
        g.setContactEmail(rs.getString("contact_email"));
        g.setCreatedAt(rs.getTimestamp("created_at"));
        g.setExpiresAt(rs.getTimestamp("expires_at"));
        return g;
    }

    @Override
    public java.util.List<GuestSession> findAll() {
        return query("SELECT * FROM GuestSessions");
    }

    @Override
    public GuestSession findById(int id) {
        return null;
    }

    public GuestSession findByGuestId(String guestId) {
        String sql = "SELECT * FROM GuestSessions WHERE guest_id = ?";
        return queryOne(sql, guestId);
    }

    public String createGuestSession() {
        String sql = """
            INSERT INTO GuestSessions (contact_phone, contact_email, expires_at)
            OUTPUT inserted.guest_id
            VALUES (NULL, NULL, DATEADD(DAY, 7, SYSUTCDATETIME()))
        """;

        try (java.sql.Connection conn = getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement(sql);
             java.sql.ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getString(1);
            }
        } catch (Exception e) {
            System.out.println("===== CREATE GUEST SESSION ERROR =====");
            e.printStackTrace();
            System.out.println("======================================");
        }

        return null;
    }

    @Override
    public int insert(GuestSession g) {
        String sql = """
            INSERT INTO GuestSessions (contact_phone, contact_email, expires_at)
            VALUES (?, ?, ?)
        """;
        return update(sql, g.getContactPhone(), g.getContactEmail(), g.getExpiresAt());
    }

    @Override
    public boolean update(GuestSession g) {
        String sql = """
            UPDATE GuestSessions
            SET contact_phone = ?, contact_email = ?, expires_at = ?
            WHERE guest_id = ?
        """;
        return update(sql,
                g.getContactPhone(),
                g.getContactEmail(),
                g.getExpiresAt(),
                g.getGuestId()) > 0;
    }

    @Override
    public boolean delete(int id) {
        return false;
    }
}