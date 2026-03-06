/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package com.clickeat.dal.interfaces;

import com.clickeat.model.ShipperProfile;

/**
 *
 * @author DELL
 */
public interface IShipperDAO extends IGenericDAO<ShipperProfile> {

    boolean registerShipper(String fullName, String phone, String password, String vehicleType, String vehicleName, String licensePlate);
    boolean updateOnlineStatus(int shipperId, boolean isOnline);
    public boolean checkIsOnline(int shipperId);

}
