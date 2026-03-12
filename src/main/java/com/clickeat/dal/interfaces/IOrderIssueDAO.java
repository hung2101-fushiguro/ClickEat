/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package com.clickeat.dal.interfaces;

import com.clickeat.model.OrderIssue;
import java.util.List;

public interface IOrderIssueDAO {

    List<OrderIssue> getPendingIssues();

    boolean resolveIssue(int issueId);

    int insert(OrderIssue issue);

    List<OrderIssue> getIssuesByShipperId(long shipperId);
}
