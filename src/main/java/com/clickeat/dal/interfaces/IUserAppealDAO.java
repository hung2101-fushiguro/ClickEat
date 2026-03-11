/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Interface.java to edit this template
 */
package com.clickeat.dal.interfaces;

import com.clickeat.model.UserAppeal;
import java.util.List;

/**
 *
 * @author DELL
 */
public interface IUserAppealDAO {

    public boolean createAppeal(int userId, String reason);

    public List<UserAppeal> getPendingAppeals();

    public boolean resolveAppeal(long appealId, String status, String adminNote);

    public UserAppeal getLatestAppeal(int userId);
}
