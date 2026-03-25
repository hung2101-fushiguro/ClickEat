package com.clickeat.config;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBContext {
    private static final String DRIVER = "com.microsoft.sqlserver.jdbc.SQLServerDriver";

    // Local SQL Server (port 1433)
    private static final String URL =
            "jdbc:sqlserver://localhost:1433;"
          + "database=ClickEat;"
          + "encrypt=true;"
          + "trustServerCertificate=true;"
          + "loginTimeout=10;";

    private static final String USER = "sa";
    private static final String PASS = "11012004";

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName(DRIVER);
        } catch (ClassNotFoundException e) {
            throw new SQLException("Thiếu JDBC Driver (mssql-jdbc). Kiểm tra Libraries/Maven dependency.", e);
        }
        return DriverManager.getConnection(URL, USER, PASS);
    }

    public static void main(String[] args) {
        try (Connection con = getConnection()) {
            System.out.println("✅ Connect to ClickEat Success: " + con.getCatalog());
        } catch (SQLException e) {
            System.err.println("❌ Connect FAIL: " + e.getMessage());
            e.printStackTrace();
        }
    }
}