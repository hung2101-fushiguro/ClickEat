/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package com.clickeat.dal.interfaces;

import com.clickeat.model.MerchantKYC;
import java.util.List;

public interface IMerchantKYCDAO {

    List<MerchantKYC> getPendingKYCs();

    boolean approveKYC(long kycId, long merchantId, long adminId);

    boolean rejectKYC(long kycId, long merchantId, long adminId, String reason);
}
