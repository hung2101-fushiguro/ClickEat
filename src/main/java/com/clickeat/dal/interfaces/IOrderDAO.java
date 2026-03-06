/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package com.clickeat.dal.interfaces;

import com.clickeat.model.Order;
import java.util.List;

/**
 *
 * @author DELL
 */
public interface IOrderDAO extends IGenericDAO<Order> {
    List<Order> getAvailableOrdersForShipper();
    boolean claimOrder(int orderId, int shipperId);
    Order getCurrentOrderForShipper(int shipperId);
    public boolean updateOrderStatus(int orderId, String newStatus);
}
