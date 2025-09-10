package amd;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.*;

public class DataFetchAMD {
    public String objectId;
    public String apn;
    public String name;
    public String type;
    public String supertype;
    public String description;
    public LocalDateTime createdDate;
    public String owner;
    public String email;

    // Database connection 
    public static final String url = "jdbc:postgresql://localhost:5432/Andromeda";
    public static final String user = "postgres";
    public static final String db_password = "amxadmin123";
   
    public static final String table = "amxcorepartdata";
    public static final String htable = "parthistory";
    public String sNewTempObjectId = "";

    static {
        String createTableSQL = """
            CREATE TABLE IF NOT EXISTS amxcorepartdata (objectid VARCHAR(255) PRIMARY KEY,apn VARCHAR(255),name VARCHAR(255),
                type VARCHAR(100),supertype VARCHAR(100),description TEXT,createddate TIMESTAMP,
                owner VARCHAR(100),email VARCHAR(255),fts_document VARCHAR(500), fastenersubpart VARCHAR(225), variant VARCHAR(225),connectionid VARCHAR(255),currentstate VARCHAR(255);""";

        String createHistoryTableSQL = """
            CREATE TABLE IF NOT EXISTS parthistory (objectid VARCHAR(255) PRIMARY KEY,history TEXT);""";

        try {
            Class.forName("org.postgresql.Driver");  
            try (Connection conn = DriverManager.getConnection(url, user, db_password);
                 Statement stmt = conn.createStatement()) {
                stmt.executeUpdate(createTableSQL);
                stmt.executeUpdate(createHistoryTableSQL);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public DataFetchAMD() { }

    public DataFetchAMD(String objectId) {
        this.objectId = objectId;
        this.sNewTempObjectId=objectId;
    }

    // Create a new object in the database
    public void createObject(Map<String, String> sobjectmp) {
        String insertQuery = "INSERT INTO " + table + " (objectid, apn, name, type, supertype, description, createddate, owner, email,fts_document,fastenersubpart,variant,connectionid,currentstate) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?, ?)";

        try (Connection conn = DriverManager.getConnection(url, user, db_password);
             PreparedStatement pstmt = conn.prepareStatement(insertQuery)) {

            pstmt.setString(1, sobjectmp.get("objectid"));
            pstmt.setString(2, sobjectmp.get("apn"));
            pstmt.setString(3, sobjectmp.get("name"));
            pstmt.setString(4, sobjectmp.get("type"));
            pstmt.setString(5, sobjectmp.get("supertype"));
            pstmt.setString(6, sobjectmp.get("description"));
            pstmt.setTimestamp(7, Timestamp.valueOf(LocalDateTime.now()));
            pstmt.setString(8, sobjectmp.get("owner"));
            pstmt.setString(9, sobjectmp.get("email"));
            pstmt.setString(10,sobjectmp.get("fts_document"));
            pstmt.setString(11, sobjectmp.get("fastenersubpart"));
            pstmt.setString(12, sobjectmp.get("variant"));
            pstmt.setString(13, sobjectmp.get("connectionid"));
            pstmt.setString(14,sobjectmp.get("currentstate"));
            //System.out.println("Connection ID: " + sobjectmp.get("connectionid"));


            int rows = pstmt.executeUpdate();
            if (rows > 0) {
                setHistory(sobjectmp.get("objectid"), "Object created.");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Error creating object: " + e.getMessage());
        }
    }

    // getInfos( )
    public Map<String, String> getInfos() {
        if (objectId == null || objectId.trim().isEmpty()) {
            throw new RuntimeException("objectId is null or empty");
        }
        String selectQuery = "SELECT * FROM " + table + " WHERE objectid = ?";
        Map<String, String> result = new HashMap<>();

        try (Connection conn = DriverManager.getConnection(url, user, db_password);
             PreparedStatement pstmt = conn.prepareStatement(selectQuery)) {
            pstmt.setString(1, objectId);
            try (ResultSet rs = pstmt.executeQuery()) {
                ResultSetMetaData meta = rs.getMetaData();
                if (rs.next()) {
                    for (int i = 1; i <= meta.getColumnCount(); i++) {
                        result.put(meta.getColumnName(i), rs.getString(i));
                    }
                } else {
                    throw new ObjectIdNotFoundException("ObjectId '" + objectId + "' not found");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Error fetching info: " + e.getMessage());
        }

        return result;
    }

    //getInfo()
    public String getInfo(String columnName) {
        if (objectId == null || objectId.trim().isEmpty()) {
            throw new RuntimeException("objectId is null or empty");
        }
        String query = "SELECT " + columnName + " FROM " + table + " WHERE objectid = ?";
        try (Connection conn = DriverManager.getConnection(url, user, db_password);
             PreparedStatement pstmt = conn.prepareStatement(query)) {
            pstmt.setString(1, objectId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getString(1);
                } else {
                    throw new ObjectIdNotFoundException("ObjectId '" + objectId + "' not found");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Error fetching info: " + e.getMessage());
        }
    }

    // delete
    public void deleteObjectFromDatabase() {
        if (objectId == null || objectId.trim().isEmpty()) {
            throw new RuntimeException("ObjectId is null or empty");
        }

        String deleteQuery = "DELETE FROM " + table + " WHERE objectid = ?";

        try (Connection conn = DriverManager.getConnection(url, user, db_password);
             PreparedStatement pstmt = conn.prepareStatement(deleteQuery)) {

            pstmt.setString(1, objectId);
            int rowsDeleted = pstmt.executeUpdate();

            if (rowsDeleted == 0) {
                throw new ObjectIdNotFoundException("ObjectId '" + objectId + "' not found in database");
            } else {
                setHistory(objectId, "Object deleted.");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Error deleting object: " + e.getMessage());
        }
    }

    // Update
    public void updateObject(Map<String, String> mapData) {
        String updateQuery = "UPDATE " + table + " SET apn=?, name=?, type=?, supertype=?, description=?, createddate=?, owner=?, email=? WHERE objectid=?";

        try (Connection conn = DriverManager.getConnection(url, user, db_password);
             PreparedStatement pstmt = conn.prepareStatement(updateQuery)) {

            pstmt.setString(1, mapData.get("apn"));
            pstmt.setString(2, mapData.get("name"));
            pstmt.setString(3, mapData.get("type"));
            pstmt.setString(4, mapData.get("supertype"));
            pstmt.setString(5, mapData.get("description"));
            pstmt.setTimestamp(6, Timestamp.valueOf(LocalDateTime.now()));  
            pstmt.setString(7, mapData.get("owner"));
            pstmt.setString(8, mapData.get("email"));
            pstmt.setString(9, mapData.get("objectid"));

            int rowsUpdated = pstmt.executeUpdate();
            if (rowsUpdated > 0) {
                setHistory(mapData.get("objectid"), "Object updated.");
            } else {
                throw new ObjectIdNotFoundException("ObjectId '" + mapData.get("objectid") + "' not found for update");
            }

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Error updating object: " + e.getMessage());
        }
    }

    // Search by name 
    public List<Map<String, String>> searchByName(String name) {
        List<Map<String, String>> matchedList = new ArrayList<>();
        String query = "SELECT * FROM " + table + " WHERE LOWER(name) LIKE ?";

        try (Connection conn = DriverManager.getConnection(url, user, db_password);
             PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setString(1, "%" + name.toLowerCase() + "%");

            try (ResultSet rs = pstmt.executeQuery()) {
                ResultSetMetaData meta = rs.getMetaData();
                while (rs.next()) {
                    Map<String, String> row = new HashMap<>();
                    for (int i = 1; i <= meta.getColumnCount(); i++) {
                        row.put(meta.getColumnName(i), rs.getString(i));
                    }
                    matchedList.add(row);
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Error searching by name: " + e.getMessage());
        }

        return matchedList;
    }

    // latestpart
    public List<Map<String, String>> getLatestPartsFromDB() {
        List<Map<String, String>> latestList = new ArrayList<>();
        String query = "SELECT * FROM " + table + " ORDER BY createddate DESC LIMIT 10";

        try (Connection conn = DriverManager.getConnection(url, user, db_password);
             PreparedStatement pstmt = conn.prepareStatement(query);
             ResultSet rs = pstmt.executeQuery()) {

            ResultSetMetaData meta = rs.getMetaData();
            while (rs.next()) {
                Map<String, String> row = new HashMap<>();
                for (int i = 1; i <= meta.getColumnCount(); i++) {
                    row.put(meta.getColumnName(i), rs.getString(i));
                }
                latestList.add(row);
            }

        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Error fetching latest parts: " + e.getMessage());
        }

        return latestList;
    }

    // setHistory
    public void setHistory(String objectId, String message) {
        String selectQuery = "SELECT history FROM " + htable + " WHERE objectid = ?";
        String insertQuery = "INSERT INTO " + htable + " (objectid, history) VALUES (?, ?)";
        String updateQuery = "UPDATE " + htable + " SET history = ? WHERE objectid = ?";

        try (Connection conn = DriverManager.getConnection(url, user, db_password);
             PreparedStatement selectStmt = conn.prepareStatement(selectQuery)) {

            selectStmt.setString(1, objectId);
            try (ResultSet rs = selectStmt.executeQuery()) {
                if (rs.next()) {
                    String existing = rs.getString("history");
                    String updated = (existing == null || existing.isEmpty()) ? message : existing + " | " + message;

                    try (PreparedStatement updateStmt = conn.prepareStatement(updateQuery)) {
                        updateStmt.setString(1, updated);
                        updateStmt.setString(2, objectId);
                        updateStmt.executeUpdate();
                    }
                } else {
                    try (PreparedStatement insertStmt = conn.prepareStatement(insertQuery)) {
                        insertStmt.setString(1, objectId);
                        insertStmt.setString(2, message);
                        insertStmt.executeUpdate();
                    }
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

//getHistory
    public List<String> getHistory(String objectId) {
        List<String> historyList = new ArrayList<>();
        String query = "SELECT history FROM " + htable + " WHERE objectid = ?";

        try (Connection conn = DriverManager.getConnection(url, user, db_password);
             PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setString(1, objectId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    String history = rs.getString("history");
                    if (history != null && !history.trim().isEmpty()) {
                        historyList = Arrays.asList(history.split(" \\| "));
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Error fetching history: " + e.getMessage());
        }

        return historyList;
    }

    // Custom Exception 
    public static class ObjectIdNotFoundException extends RuntimeException {
        /**
		 * 
		 */
		private static final long serialVersionUID = 1L;

		public ObjectIdNotFoundException(String message) {
            super(message);
        }
    }
  
        public String getId() throws Exception {
            String sObjectId = "";
            try {
                if (sNewTempObjectId != null && !sNewTempObjectId.isEmpty()) {
                    sObjectId = sNewTempObjectId;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            return sObjectId;
        }
        
        @SuppressWarnings({ "rawtypes", "unchecked" })
        public List<Map> getConnectedPartControlObjects(String objectId) {
            List<Map> listOfMaps = new ArrayList<>();
            String sparticularquery = "SELECT * FROM amxpartcontroldata WHERE objectid=?";

            try (Connection conn = DriverManager.getConnection(url, user, db_password);
                 PreparedStatement pstmt = conn.prepareStatement(sparticularquery)) {
                
                pstmt.setString(1, objectId);
                try (ResultSet rs = pstmt.executeQuery()) {
                    ResultSetMetaData meta = rs.getMetaData();

                    while (rs.next()) {
                        Map resultmp = new HashMap();
                        int count = meta.getColumnCount();
                        for (int i = 1; i <= count; i++) {
                            String colName = meta.getColumnName(i);
                            String val = rs.getString(i);
                            resultmp.put(colName, val);
                        }
                        listOfMaps.add(resultmp);
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }

            return listOfMaps; 
        }

        public List<String> getConnectionIdsFromPart(String objectId) {
            List<String> connectionids = new ArrayList<>();

            try (Connection conn = DriverManager.getConnection(url, user, db_password);
                 PreparedStatement ps = conn.prepareStatement("SELECT connectionid FROM amxpartcontroldata WHERE objectid = ?")) {
                
                ps.setString(1, objectId);
                ResultSet rs = ps.executeQuery();

                while (rs.next()) {
                    connectionids.add(rs.getString("connectionid"));
                }
                rs.close();
            } catch (Exception e) {
                e.printStackTrace();
            }

            return connectionids;  
        }
        
     //lifecycle
        public String getCurrentState() {
    		String query="select currentstate from amxcorepartdata where objectid=?";
    		String currentstate="";
    		try{
    			Connection conn=DriverManager.getConnection(url,user,db_password);
    			PreparedStatement pstmt=conn.prepareStatement(query);
    			pstmt.setString(1, objectId);
    			ResultSet rs=pstmt.executeQuery();
    			if(rs.next()) {
    				currentstate=rs.getString("currentstate");
    			}
    		}catch(Exception e) {
    			e.printStackTrace();
    		}
    		return currentstate;
    	}
        
        public List<String> getAllStates(String ruleName) {
    	    List<String> values = new ArrayList<>();
    	    String query = "SELECT rulevalue FROM amxschemarules WHERE rulename = ?";
    	    try {
    	    	Connection conn = DriverManager.getConnection(url, user, db_password);
    	         PreparedStatement pstmt = conn.prepareStatement(query); 
    	        pstmt.setString(1, ruleName);
    	        try (ResultSet rs = pstmt.executeQuery()) {
    	            if (rs.next()) {
    	            	 values.add(rs.getString("rulevalue"));
    	            }
    	        }
    	    } catch (Exception e) {
    	        e.printStackTrace();
    	    }
    	    return values;
    	}
        public void updatePartState(String objectId, String newState) {
            String table = null;
            if (objectId.contains(".APN")) {
                table = "amxcorepartdata";
            } else if (objectId.contains(".PACO")) {
                table = "amxpartcontroldata";
            } else {
                //System.out.println("Unknown object ID format: " + objectId);
                return;
            }
            String query = "UPDATE " + table + " SET currentstate=? WHERE objectid=?";
            try (Connection conn = DriverManager.getConnection(url, user, db_password);
                 PreparedStatement pstmt = conn.prepareStatement(query)) {
                pstmt.setString(1, newState);
                pstmt.setString(2, objectId);
                pstmt.executeUpdate();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

}