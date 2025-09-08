package amd;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.*;

public class AMXPartControl {

    public static final String url = "jdbc:postgresql://localhost:5432/Andromeda";
    public static final String user = "postgres";
    public static final String db_password = "amxadmin123";
    public static String table="amxpartcontroldata";

    public static String objectid;
    public static String sNewTempObjectId ="";

    public final static String OBJECT_ID = "objectid";
    public final static String SUPER_TYPE = "supertype";
    public final static String TYPE = "type";
    public final static String NAME = "name";
    public final static String DESCRIPTION = "description";
    public final static String CREATED_DATE = "createddate";
    public final static String OWNER = "owner";
    public final static String EMAIL = "email";
    public final static String ASSIGNEE = "assignee";
    public final static String CONNECTION_ID = "connectionid";
    public final static String CURRENTSTATE="currentstate";

    public AMXPartControl() {}

    public AMXPartControl(String objectid) {
        AMXPartControl.objectid = objectid;
        AMXPartControl.sNewTempObjectId = objectid;
    }
    
    static {
    	String createTableSQL="""
    			CREATE TABLE IF NOT EXISTS amxpartcontroldata(objectid VARCHAR(100) PRIMARY KEY,name VARCHAR(100),
    		    supertype VARCHAR(100),type VARCHAR(100),description TEXT,
    		    createddate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,owner VARCHAR(100),
    		    email VARCHAR(100),assignee VARCHAR(100),connectionid VARCHAR(100),currentstate VARCHAR(255))""";
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
    
    /**
     * Create a new object (part control) in the database.
     */
    public void createPartControlObject(Map<String, String> dataMap) {
        String insertSQL = "INSERT INTO amxpartcontroldata (" +
                "objectid, name, supertype, type, description, createddate, owner, email, assignee, connectionid,currentstate) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?)";
        try (
            Connection conn = DriverManager.getConnection(url, user, db_password);
            PreparedStatement pstmt = conn.prepareStatement(insertSQL)
        ) {
            pstmt.setString(1, dataMap.getOrDefault("objectid", ""));
            pstmt.setString(2, dataMap.getOrDefault("name", ""));
            pstmt.setString(3, dataMap.getOrDefault("supertype", ""));
            pstmt.setString(4, dataMap.getOrDefault("type", ""));
            pstmt.setString(5, dataMap.getOrDefault("description", ""));
            pstmt.setTimestamp(6, Timestamp.valueOf(LocalDateTime.now()));
            pstmt.setString(7, dataMap.getOrDefault("owner", ""));
            pstmt.setString(8, dataMap.getOrDefault("email", ""));
            pstmt.setString(9, dataMap.getOrDefault("assignee", ""));
            pstmt.setString(10, dataMap.getOrDefault("connectionid", ""));
            pstmt.setString(11, dataMap.getOrDefault("currentstate",""));
            pstmt.executeUpdate();
            
           // int result = pstmt.executeUpdate();
//            if (result > 0) {
//               // System.out.println("Successfully created.");
//            } else {
//               // System.out.println("Failed to insert.");
//            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * Get info( )
     */
    public String getInfo(String column) {
        String query = "SELECT " + column + " FROM amxpartcontroldata WHERE objectid = ?";
        String result = null;

        try (
            Connection conn = DriverManager.getConnection(url, user, db_password);
            PreparedStatement pstmt = conn.prepareStatement(query)
        ) {
            pstmt.setString(1, objectid);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    result = rs.getString(column);
                } else {
                    throw new RuntimeException("ObjectId " + objectid + " not found in database.");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return result;
    }

    /**
     * Get infos()
     */
    public Map<String, String> getInfos() {
        String query = "SELECT * FROM amxpartcontroldata WHERE objectid = ?";
        Map<String, String> result = new LinkedHashMap<>();

        try (
            Connection conn = DriverManager.getConnection(url, user, db_password);
            PreparedStatement pstmt = conn.prepareStatement(query)
        ) {
            pstmt.setString(1, objectid);
            try (ResultSet rs = pstmt.executeQuery()) {
                ResultSetMetaData metaData = rs.getMetaData();
                if (rs.next()) {
                    int columnCount = metaData.getColumnCount();
                    for (int i = 1; i <= columnCount; i++) {
                        String column = metaData.getColumnName(i);
                        String value = rs.getString(i);
                        result.put(column, value);
                    }
                } else {
                    throw new RuntimeException("ObjectId " + objectid + " not found.");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return result;
    }

    public String getType() {
        return getInfo(TYPE);
    }

    public String getName() {
        return getInfo(NAME);
    }

    public String getDescription() {
        return getInfo(DESCRIPTION);
    }

    public String getCreatedDate() {
        return getInfo(CREATED_DATE);
    }

    public String getOwner() {
        return getInfo(OWNER);
    }

    public String getEmail() {
        return getInfo(EMAIL);
    }

    public String getSuperType() {
        return getInfo(SUPER_TYPE);
    }

    public String getAssignee() {
        return getInfo(ASSIGNEE);
    }

    public String getConnectionId() {
        return getInfo(CONNECTION_ID);
    }

    /**
     * Generates the nextpart
     */
    public String generateNextPartName() {
        String query = "SELECT name FROM amxpartcontroldata WHERE name LIKE 'PC-%'";
        int maxNumber = 0;

        try (
            Connection conn = DriverManager.getConnection(url, user, db_password);
            PreparedStatement pstmt = conn.prepareStatement(query);
            ResultSet rs = pstmt.executeQuery()
        ) {
            while (rs.next()) {
                String name = rs.getString("name");
                if (name != null && name.startsWith("PC-")) {
                    try {
                        int number = Integer.parseInt(name.substring(3));
                        maxNumber = Math.max(maxNumber, number);
                    } catch (NumberFormatException ignored) {}
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }

        return String.format("PC-%06d", maxNumber + 1);
    }

    // Custom exception if needed
    public static class ObjectNotFoundException extends RuntimeException {
        /**
		 * 
		 */
		private static final long serialVersionUID = 1L;

		public ObjectNotFoundException(String message) {
            super(message);
        }
    }
    @SuppressWarnings("unchecked")
	public void createPartControlFromPart(Map mpData) throws Exception {
		String sPartId = "";
		String sPartControlId = "";
		String sConnectionId = "";
		Map mpConnectionMap = (Map) mpData.get("connection");
		Map mpPartControlMap = (Map) mpData.get("partcontrol");
		String sGlobalPartId = objectid;
		DataFetchAMD dfamd=new 	DataFetchAMD ();
		dfamd.objectId = this.objectid; 
		sPartId=dfamd.getId();
		AMXPartControl amx = new    AMXPartControl ();
		amx.createPartControlObject(mpPartControlMap);
		amx.getId();
		AmxConnectionManagement amxConn = new AmxConnectionManagement();
		amxConn.createConnection(mpConnectionMap);
		amx.getId();
	}
    public String getId() throws Exception {
		String sObjectId = "";
		try {
			if(!sNewTempObjectId.isEmpty() && sNewTempObjectId!=null) {
				sObjectId = sNewTempObjectId;
			}
		} catch (Exception e) {

		}
		return sObjectId;
	}
    //update connection
    public void updateConnection(String sConnectionId) throws Exception {
   	 
	    String existingConnection = getInfo("connectionid"); 
	    String newConnection;

	    if(existingConnection == null || existingConnection.isEmpty()) {
	        newConnection = sConnectionId;
	    } else {
	      
	        newConnection = existingConnection + "|" + sConnectionId;
	    }

	    String updateQuery = "UPDATE amxpartcontroldata SET connectionid=? WHERE objectid=?";
	    try (Connection conn = DriverManager.getConnection(url, user, db_password);
	         PreparedStatement pstmt = conn.prepareStatement(updateQuery)) {
	        pstmt.setString(1, newConnection);
	        pstmt.setString(2, objectid); 
	        pstmt.executeUpdate();
	      
	    }
	}
  
    //partcontrolconnection
    public boolean isPartControlConnection(String connectionId) {
        boolean isThere = false;
        String query = "SELECT 1 FROM amxpartcontroldata WHERE connectionid = ?";
        try (Connection conn = DriverManager.getConnection(url, user, db_password);
             PreparedStatement pstmt = conn.prepareStatement(query)) {
             
            pstmt.setString(1, connectionId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    isThere = true;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            // Optionally log e.getMessage() if using logging framework
        }
        return isThere;
    }

    //getPartControlObjects
    @SuppressWarnings({ "rawtypes", "unchecked" })
    public List<Map> getPartControlObjectsFromConnectionId(String connectionId) {
        List<Map> listOfMaps = new ArrayList<>();
        
        // Check if connection exists before querying (optional, you may skip this for performance)
        if (!isPartControlConnection(connectionId)) {
            return listOfMaps;
        }

        String query = "SELECT * FROM amxpartcontroldata WHERE connectionid = ?";

        try (Connection conn = DriverManager.getConnection(url, user, db_password);
             PreparedStatement pstmt = conn.prepareStatement(query)) {

            pstmt.setString(1, connectionId);
            try (ResultSet rs = pstmt.executeQuery()) {
                ResultSetMetaData meta = rs.getMetaData();
                int colCount = meta.getColumnCount();

                while (rs.next()) {
                    Map rowMap = new HashMap<>();
                    for (int i = 1; i <= colCount; i++) {
                        String colName = meta.getColumnName(i);
                        String val = rs.getString(i);
                        rowMap.put(colName, val);
                    }
                    listOfMaps.add(rowMap);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return listOfMaps;
    }

}
