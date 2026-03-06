/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.model;

import java.sql.Timestamp;

public class ShipperWallet {

    private int shipperUserId;
    private double balance;
    private Timestamp updatedAt;

    public ShipperWallet() {
    }

    public int getShipperUserId() {
        return shipperUserId;
    }

    public void setShipperUserId(int shipperUserId) {
        this.shipperUserId = shipperUserId;
    }

    public double getBalance() {
        return balance;
    }

    public void setBalance(double balance) {
        this.balance = balance;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
}
