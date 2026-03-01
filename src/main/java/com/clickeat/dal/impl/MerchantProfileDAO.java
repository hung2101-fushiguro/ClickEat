/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.dal.impl;

import com.clickeat.dal.interfaces.IMerchantProfileDAO;
import com.clickeat.model.MerchantProfile;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

public class MerchantProfileDAO extends AbstractDAO<MerchantProfile> implements IMerchantProfileDAO {

    @Override
    protected MerchantProfile mapRow(ResultSet rs) throws SQLException {
        MerchantProfile m = new MerchantProfile();
        m.setUserId(rs.getInt("user_id"));
        m.setShopName(rs.getString("shop_name"));
        m.setShopPhone(rs.getString("shop_phone"));
        m.setShopAddressLine(rs.getString("shop_address_line"));
        m.setProvinceCode(rs.getString("province_code"));
        m.setProvinceName(rs.getString("province_name"));
        m.setDistrictCode(rs.getString("district_code"));
        m.setDistrictName(rs.getString("district_name"));
        m.setWardCode(rs.getString("ward_code"));
        m.setWardName(rs.getString("ward_name"));
        m.setLatitude(rs.getDouble("latitude"));
        m.setLongitude(rs.getDouble("longitude"));
        m.setStatus(rs.getString("status"));
        m.setCreatedAt(rs.getTimestamp("created_at"));
        m.setUpdatedAt(rs.getTimestamp("updated_at"));
        return m;
    }

    @Override
    public MerchantProfile findById(int id) {
        String sql = "SELECT * FROM MerchantProfiles WHERE user_id = ?";
        return queryOne(sql, id);
    }

    
    @Override 
    public List<MerchantProfile> findAll() { 
        return query("SELECT * FROM MerchantProfiles"); 
    }
    
    @Override 
    public int insert(MerchantProfile m) { 
        return 0; // Luồng Đăng ký Merchant sẽ lo phần này
    }
    
    @Override 
    public boolean update(MerchantProfile m) { 
        return false; // Sẽ code sau
    }
    
    @Override 
    public boolean delete(int id) { 
        return false; 
    }
}