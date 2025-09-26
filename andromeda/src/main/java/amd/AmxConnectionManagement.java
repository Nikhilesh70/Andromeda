package amd;

import java.sql.*;
import java.time.Instant;
import java.util.Map;

public class AmxConnectionManagement {

    public static final String url = "jdbc:postgresql://localhost:5432/Andromeda";
    public static final String user = "postgres";
    public static final String db_password= "amxadmin123";
    public static final String connectionid = "connetionid";
    public void createTable() {
        String createQuery = """
        		CREATE TABLE IF NOT EXISTS amxcoreconnectiondata (
        	    connectionid VARCHAR(100) PRIMARY KEY,type VARCHAR(100),name VARCHAR(100),fromid VARCHAR(100),
        	    toid VARCHAR(100),fromname VARCHAR(100),toname VARCHAR(100),creationtime TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        	)""";
        try (Connection conn = DriverManager.getConnection(url, user, db_password);
             PreparedStatement pstmt = conn.prepareStatement(createQuery)) {
            pstmt.executeUpdate();
            System.out.println("Table created or already exists.");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }


    @SuppressWarnings("rawtypes")
	public void createConnection(Map datamap) {
    	
//    	System.out.println(datamap);
//    	System.out.println("datamap=================");
        String checkQuery = "SELECT 1 FROM amxcoreconnectiondata WHERE connectionid = ?";
        String insertQuery = "INSERT INTO amxcoreconnectiondata "
                + "(connectionid, type, name, fromid, toid, fromname, toname, creationtime) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DriverManager.getConnection(url, user, db_password)) {

           
            try (PreparedStatement checkobjid = conn.prepareStatement(checkQuery)) {
            	checkobjid.setString(1, (String) datamap.get("connectionid"));
                try (ResultSet rs = checkobjid.executeQuery()) {
                    if (rs.next()) {
                        throw new DuplicateKeyException("Connection Id duplicate.Please check with admin ");
                    } 
                }
            }

        
            try (PreparedStatement insertStmt = conn.prepareStatement(insertQuery)) {
                insertStmt.setString(1, (String) datamap.get("connectionid"));
                insertStmt.setString(2, (String) datamap.get("type"));
                insertStmt.setString(3, (String) datamap.get("name"));
                insertStmt.setString(4, (String) datamap.get("fromid"));
                insertStmt.setString(5, (String) datamap.get("toid"));
                insertStmt.setString(6, (String) datamap.get("fromname"));
                insertStmt.setString(7, (String) datamap.get("toname"));
                insertStmt.setTimestamp(8, Timestamp.from(Instant.now()));
                insertStmt.executeUpdate();
//                int rowsInserted = insertStmt.executeUpdate();
//                if (rowsInserted > 0) {
//                    System.out.println("Successfully Created");
//                } else {
//                    System.out.println("Failed to Insert");
//                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            e.getMessage();
        }
    }

    public static class DuplicateKeyException extends Exception {
        /**
		 * 
		 */
		private static final long serialVersionUID = 1L;

		public DuplicateKeyException(String message) {
            super(message);
        }
    }
}
