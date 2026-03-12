/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package com.clickeat.dal.interfaces;

import com.clickeat.model.WithdrawalRequest;
import java.util.List;

public interface IWithdrawalRequestDAO {

    List<WithdrawalRequest> getPendingRequests();

    boolean approveRequest(long requestId, long shipperId, double amount);

    boolean rejectRequest(long requestId);

    boolean createRequest(WithdrawalRequest req);
}
