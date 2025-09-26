package amd;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AmxSpecificationDocument {

    public static final String url = "jdbc:postgresql://localhost:5432/Andromeda";
    public static final String user = "postgres";
    public static final String db_password = "amxadmin123";

    public String filename;
    public int fileid;
    public byte[] filedata;  // added field to hold file content

    public AmxSpecificationDocument(int fileid, String filename) {
        this.fileid = fileid;
        this.filename = filename;
    }

    // New constructor to include file data
    public AmxSpecificationDocument(int fileid, String filename, byte[] filedata) {
        this.fileid = fileid;
        this.filename = filename;
        this.filedata = filedata;
    }

    public void createTable() {
        String query = """
            CREATE TABLE IF NOT EXISTS specificationdocument (objectid VARCHAR(255) PRIMARY KEY, filename VARCHAR(100),
            filedata BYTEA NOT NULL);""";
        try (Connection conn = DriverManager.getConnection(url, user, db_password);
             Statement stmt = conn.createStatement()) {
            stmt.executeUpdate(query);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    

    public static AmxSpecificationDocument insertFile(String objectid, byte[] fileBytes, String filename) throws Exception {
        try (Connection conn = DriverManager.getConnection(url, user, db_password)) {
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

    // for list of files
    public static List<AmxSpecificationDocument> getFilesByObjectId(String objectid) throws Exception {
        List<AmxSpecificationDocument> files = new ArrayList<>();
        try (Connection conn = DriverManager.getConnection(url, user, db_password)) {
            String query = "SELECT filename FROM specificationdocument WHERE objectid = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(query)) {
                pstmt.setString(1, objectid);
                try (ResultSet rs = pstmt.executeQuery()) {
                    while (rs.next()) {
                        String filename = rs.getString("filename");
                        files.add(new AmxSpecificationDocument(0, filename));
                    }
                }
            }
        }
        return files;
    }

    //for fileobjectand filename
    public static AmxSpecificationDocument getFileObjectIdAndFileName(String objectid, String filename) throws SQLException {
        String query = "SELECT filedata FROM specificationdocument WHERE objectid = ? AND filename = ?";
        try (Connection conn = DriverManager.getConnection(url, user, db_password)) {
            PreparedStatement pstmt = conn.prepareStatement(query);
            pstmt.setString(1, objectid);
            pstmt.setString(2, filename);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    byte[] fileData = rs.getBytes("filedata");
                    return new AmxSpecificationDocument(0, filename, fileData);  
                }
            }
        }
        return null;
    }
}
