/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.dal.impl;

import com.clickeat.dal.interfaces.IMerchantKYCDAO;
import com.clickeat.model.MerchantKYC;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class MerchantKYCDAO extends AbstractDAO<MerchantKYC> implements IMerchantKYCDAO {

    @Override
    protected MerchantKYC mapRow(ResultSet rs) throws SQLException {
        MerchantKYC kyc = new MerchantKYC();
        kyc.setId(rs.getLong("id"));
        kyc.setMerchantUserId(rs.getLong("merchant_user_id"));
        kyc.setBusinessName(rs.getString("business_name"));
        kyc.setBusinessLicenseNumber(rs.getString("business_license_number"));
        kyc.setDocumentUrl(rs.getString("document_url"));
        kyc.setSubmittedAt(rs.getTimestamp("submitted_at"));

        // Cột này có thể NULL nên cần check
        long adminId = rs.getLong("reviewed_by_admin_id");
        if (!rs.wasNull()) {
            kyc.setReviewedByAdminId(adminId);
        }

        kyc.setReviewStatus(rs.getString("review_status"));
        kyc.setReviewNote(rs.getString("review_note"));

        // Map thêm các cột lấy từ JOIN
        try {
            kyc.setShopName(rs.getString("shop_name"));
            kyc.setShopPhone(rs.getString("shop_phone"));
        } catch (SQLException e) {
            /* Bỏ qua nếu câu query không có JOIN */ }

        return kyc;
    }

    // 1. Lấy danh sách hồ sơ đang chờ duyệt
    @Override
    public List<MerchantKYC> getPendingKYCs() {
        String sql = "SELECT k.*, m.shop_name, m.shop_phone "
                + "FROM MerchantKYC k "
                + "JOIN MerchantProfiles m ON k.merchant_user_id = m.user_id "
                + "WHERE k.review_status IN ('SUBMITTED', 'UNDER_REVIEW') "
                + "ORDER BY k.submitted_at ASC";
        return query(sql);
    }

    // 2. Hàm DUYỆT hồ sơ (Bao gồm Transaction: Update KYC và Update Profile Quán)
    @Override
    public boolean approveKYC(long kycId, long merchantId, long adminId) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false); // Bắt đầu Transaction

            // Bước 1: Update bảng KYC thành APPROVED
            String sqlKYC = "UPDATE MerchantKYC SET review_status = 'APPROVED', reviewed_by_admin_id = ? WHERE id = ?";
            try (PreparedStatement ps1 = conn.prepareStatement(sqlKYC)) {
                ps1.setLong(1, adminId);
                ps1.setLong(2, kycId);
                ps1.executeUpdate();
            }

            // Bước 2: Update bảng MerchantProfiles cho phép Quán hoạt động
            String sqlProfile = "UPDATE MerchantProfiles SET status = 'APPROVED' WHERE user_id = ?";
            try (PreparedStatement ps2 = conn.prepareStatement(sqlProfile)) {
                ps2.setLong(1, merchantId);
                ps2.executeUpdate();
            }

            conn.commit(); // Thành công cả 2 thì Lưu
            return true;
        } catch (SQLException e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
            } // Lỗi thì Rollback
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                }
            } catch (SQLException ex) {
            }
        }
    }

    // 3. Hàm TỪ CHỐI hồ sơ
    @Override
    public boolean rejectKYC(long kycId, long merchantId, long adminId, String reason) {
        Connection conn = null;
        try {
            conn = getConnection();
            conn.setAutoCommit(false);

            String sqlKYC = "UPDATE MerchantKYC SET review_status = 'REJECTED', reviewed_by_admin_id = ?, review_note = ? WHERE id = ?";
            try (PreparedStatement ps1 = conn.prepareStatement(sqlKYC)) {
                ps1.setLong(1, adminId);
                ps1.setString(2, reason);
                ps1.setLong(3, kycId);
                ps1.executeUpdate();
            }

            String sqlProfile = "UPDATE MerchantProfiles SET status = 'REJECTED' WHERE user_id = ?";
            try (PreparedStatement ps2 = conn.prepareStatement(sqlProfile)) {
                ps2.setLong(1, merchantId);
                ps2.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
            }
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (conn != null) {
                    conn.setAutoCommit(true);
                }
            } catch (SQLException ex) {
            }
        }
    }

    @Override
    public List<MerchantKYC> findAll() {
        return null;
    }

    @Override
    public MerchantKYC findById(int id) {
        return null;
    }

    @Override
    public int insert(MerchantKYC t) {
        return 0;
    }

    @Override
    public boolean update(MerchantKYC t) {
        return false;
    }

    @Override
    public boolean delete(int id) {
        return false;
    }
}
