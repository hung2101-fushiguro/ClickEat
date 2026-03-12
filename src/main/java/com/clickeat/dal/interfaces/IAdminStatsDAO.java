/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package com.clickeat.dal.interfaces;

import java.util.Map;

public interface IAdminStatsDAO {

    double getTotalGMV();

    int getTotalOrders();

    int getTotalUsersByRole(String role);

    Map<String, Double> getRevenueLast7Days();

    Map<String, Integer> getOrderStatusDistribution();
}
