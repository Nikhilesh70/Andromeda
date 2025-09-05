package org.navigator;

import java.sql.Connection;
import java.sql.DriverManager;

public class DataBaseConnection {
    public static final String url = "jdbc:postgresql://localhost:5432/Andromeda";
    public static final String user = "postgres";
    public static final String db_password= "amxadmin123";

    public static Connection getConnection() throws Exception {
        Class.forName("org.postgresql.Driver");
        return DriverManager.getConnection(url, user, db_password);
        
    }
}

