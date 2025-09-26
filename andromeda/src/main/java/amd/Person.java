package amd;

import java.sql.*;
import java.util.*;

public class Person {

    public String objectId;
    public String email;
    public String username;
    public String firstname;
    public String lastname;
    public String password;
    public String confirmPassword;
    public String country;
    public String access;

    // Database connection info
    public static final String url = "jdbc:postgresql://localhost:5432/Andromeda";
    public static final String user = "postgres";
    public static final String db_password = "amxadmin123";
    public static final String table = "amxcorepersondata";

    // Table creation 
    static {
        String createTableSQL = """
            CREATE TABLE IF NOT EXISTS amxcorepersondata (id SERIAL PRIMARY KEY,email VARCHAR(200) UNIQUE,
                username VARCHAR(200) UNIQUE,firstname VARCHAR(200),lastname VARCHAR(200),
                password VARCHAR(200),confirmpassword VARCHAR(200),country VARCHAR(200),
                objectid VARCHAR(255) UNIQUE,access VARCHAR(200)) """;

        try {
            Class.forName("org.postgresql.Driver");  
            try (Connection conn = DriverManager.getConnection(url, user, db_password);
                 Statement stmt = conn.createStatement()) {
                stmt.executeUpdate(createTableSQL);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public Person() {}

    public Person(String objectId) {
        this.objectId = objectId;
    }

    // Get full record
    public Map<String, String> getInfos() {
        String query = "SELECT * FROM " + table + " WHERE objectid = ?";
        Map<String, String> result = new HashMap<>();

        try (Connection conn = DriverManager.getConnection(url, user, db_password);
             PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setString(1, objectId);
            ResultSet rs = pstmt.executeQuery();
            ResultSetMetaData meta = rs.getMetaData();

            if (rs.next()) {
                for (int i = 1; i <= meta.getColumnCount(); i++) {
                    result.put(meta.getColumnName(i).toLowerCase(), rs.getString(i) != null ? rs.getString(i) : "");
                }
            } else {
                throw new RuntimeException("ObjectId '" + objectId + "' not found.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Error retrieving info", e);
        }

        return result;
    }

    // Get specific field
    public String getInfo(String columnName) {
        String query = "SELECT " + columnName + " FROM " + table + " WHERE objectid = ?";
        try (Connection conn = DriverManager.getConnection(url, user, db_password);
             PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setString(1, objectId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getString(1);
            } else {
                throw new RuntimeException("ObjectId '" + objectId + "' not found.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Error retrieving column", e);
        }
    }

    // Insert a new person
    public static void insertPerson(Map<String, String> personData) {
        String insertSQL = """
            INSERT INTO amxcorepersondata 
            (email, username, firstname, lastname, password, confirmpassword, country, objectid, access)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        """;

        try (Connection conn = DriverManager.getConnection(url, user, db_password);
             PreparedStatement pstmt = conn.prepareStatement(insertSQL)) {

            pstmt.setString(1, personData.get("email"));
            pstmt.setString(2, personData.get("username"));
            pstmt.setString(3, personData.get("firstname"));
            pstmt.setString(4, personData.get("lastname"));
            pstmt.setString(5, personData.get("password"));
            pstmt.setString(6, personData.get("confirmpassword"));
            pstmt.setString(7, personData.get("country"));
            pstmt.setString(8, personData.get("objectid"));
            pstmt.setString(9, personData.get("access"));

            pstmt.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Error inserting person", e);
        }
    }

    // Update person by objectId
    public void updatePersonInDatabase(Map<String, String> updatedFields) {
        if (updatedFields == null || updatedFields.isEmpty()) return;

        StringBuilder sql = new StringBuilder("UPDATE " + table + " SET ");
        updatedFields.forEach((k, v) -> sql.append(k).append(" = ?, "));
        sql.setLength(sql.length() - 2); // Remove trailing comma
        sql.append(" WHERE objectid = ?");

        try (Connection conn = DriverManager.getConnection(url, user, db_password);
             PreparedStatement pstmt = conn.prepareStatement(sql.toString())) {

            int index = 1;
            for (String val : updatedFields.values()) {
                pstmt.setString(index++, val);
            }
            pstmt.setString(index, objectId);

            int rows = pstmt.executeUpdate();
            if (rows == 0) {
                throw new RuntimeException("ObjectId '" + objectId + "' not found.");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Error updating person", e);
        }
    }

    // Get access
    public String getAccess() {
        return getInfo("access");
    }

    // Set access (with validation)
    public void setAccess(String newAccess) {
        if (objectId == null || objectId.isEmpty()) {
            throw new IllegalArgumentException("ObjectId is empty");
        }

        Map<String, List<String>> data = AmxSchemasrules.PersonAccess();
        List<String> validAccess = (List<String>) data.get("Person Access");

        if (validAccess == null || !validAccess.contains(newAccess)) {
            throw new RuntimeException("Access '" + newAccess + "' not allowed for objectId '" + objectId + "'");
        }

        Map<String, String> updateMap = Collections.singletonMap("access", newAccess);
        updatePersonInDatabase(updateMap);
    }

    // Fetch all persons
    public static List<Map<String, String>> getPersonsFromDB() {
        List<Map<String, String>> list = new ArrayList<>();
        String query = "SELECT * FROM " + table;

        try (Connection conn = DriverManager.getConnection(url, user, db_password);
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {

            ResultSetMetaData meta = rs.getMetaData();
            while (rs.next()) {
                Map<String, String> row = new LinkedHashMap<>();
                for (int i = 1; i <= meta.getColumnCount(); i++) {
                    row.put(meta.getColumnName(i).toLowerCase(), rs.getString(i) != null ? rs.getString(i) : "");
                }
                list.add(row);
            }

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Error retrieving persons", e);
        }

        return list;
    }
}
