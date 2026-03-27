/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package com.clickeat.dal.interfaces;

import com.clickeat.model.Order;
import java.util.List;
import java.util.Map;

/**
 *
 * @author DELL
 */
public interface IOrderDAO extends IGenericDAO<Order> {

    List<Order> getAvailableOrdersForShipper();

    boolean claimOrder(int orderId, int shipperId);

    public List<Order> getCurrentOrdersForShipper(int shipperId);

    public boolean yieldOrder(int orderId, int shipperId);

    public boolean updateOrderStatus(int orderId, String newStatus);

    public int countDeliveredOrdersToday(int shipperId);

    public Map<String, Double> getLast7DaysIncome(int shipperId);
    
    public List<Order> getHistoryOrdersForShipper(int shipperId);
    
    public List<Order> getOrderHistoryByUser(int userId, String role);
}
