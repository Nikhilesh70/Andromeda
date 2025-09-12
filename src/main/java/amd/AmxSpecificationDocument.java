package amd;
 
import java.sql.*;

public class AmxSpecificationDocument {
 
    public static final String url = "jdbc:postgresql://localhost:5432/Andromeda";
    public static final String user = "postgres";
    public static final String password = "amxadmin123";
 
    public String filename;
    public int fileid;
 
    public AmxSpecificationDocument(int fileid, String filename) {
        this.fileid = fileid;
        this.filename = filename;
    }
 
    public void createTable() {
        String query = """ 
        		CREATE TABLE IF NOT EXISTS specificationdocument (objectid VARCHAR(255) PRIMARY KEY,filename VARCHAR(100),filedata BYTEA NOT NULL
        	);""";
;
        try (Connection conn = DriverManager.getConnection(url, user, password);
             Statement stmt = conn.createStatement()) {
            stmt.executeUpdate(query);
//            System.out.println("Table created (if not exists).");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
 
    public static AmxSpecificationDocument insertFile(String objectid, byte[] fileBytes, String filename) throws Exception {
        try (Connection conn = DriverManager.getConnection(url, user, password)) {
           
            String query = "INSERT INTO specificationdocument (objectid, filename, filedata) VALUES (?, ?, ?)";
            try (PreparedStatement pstmt = conn.prepareStatement(query)) {
                pstmt.setString(1, objectid);
                pstmt.setString(2, filename);
                pstmt.setBytes(3, fileBytes);

                int rowsAffected = pstmt.executeUpdate();
                if (rowsAffected > 0) {
                    return new AmxSpecificationDocument(0, filename);
                } else {
                    throw new SQLException("Insert failed, no rows affected.");
                }
            }
        }
    }

 

   
}
