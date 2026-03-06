/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package com.clickeat.dal.interfaces;

import com.clickeat.model.ShipperWallet;

public interface IShipperWalletDAO extends IGenericDAO<ShipperWallet> {

    ShipperWallet getWalletByShipperId(int shipperId);

    boolean addBalance(int shipperId, double amount);
}
