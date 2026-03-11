/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package com.clickeat.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DBContext {

    public static String driverName = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
    // Reads env vars so Docker can override without recompiling.
    // Fallback values keep local dev working unchanged.
    public static String dbURL = getEnv("DB_URL", "jdbc:sqlserver://localhost:1433;databaseName=ClickEat;encrypt=true;trustServerCertificate=true;");
    public static String userDB = getEnv("DB_USER", "sa");
    public static String passDB = getEnv("DB_PASS", "11012004");

    private static String getEnv(String key, String fallback) {
        String v = System.getenv(key);
        return (v != null && !v.isBlank()) ? v : fallback;
    }

    public static Connection getConnection() {
        Connection con = null;
        try {
            Class.forName(driverName);
            con = DriverManager.getConnection(dbURL, userDB, passDB);
            return con;
        } catch (ClassNotFoundException | SQLException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }

    public static void main(String[] args) {
        try (Connection con = getConnection()) {
            if (con != null) {
                System.out.println(" Connect to ClickEat Success");
            }
        } catch (SQLException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}
