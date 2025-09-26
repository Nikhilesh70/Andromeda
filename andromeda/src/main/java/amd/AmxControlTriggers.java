package amd;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.*;

public class AmxControlTriggers {
    public static final String url = "jdbc:postgresql://localhost:5432/Andromeda";
    public static final String user = "postgres";
    public static final String db_password = "amxadmin123";
    String objectid;
	public String connectionid;
    public AmxControlTriggers(String objectid){
    	this.objectid=objectid;
    }
    public AmxControlTriggers(){
    }
    public void createTable() {
        String createQuery = "CREATE TABLE IF NOT EXISTS amxRoute ("
                + "objectid VARCHAR(100) PRIMARY KEY,"
                + "name VARCHAR(100) ,"
                + "supertype VARCHAR(100) ,"
                + "type VARCHAR(100),"
                + "createddate TIMESTAMP,"
                + "owner VARCHAR(100) ,"
                + "connectionid VARCHAR(100)"
                + ")";
        try (Connection conn = DriverManager.getConnection(url, user, db_password);
             PreparedStatement pstmt = conn.prepareStatement(createQuery)) {
            pstmt.executeUpdate();
            System.out.println("Table created or already exists.");
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    
    public void createObject(Map datamap) {
		String query2="insert into amxRoute(objectid,name,supertype,type,createddate,"
				+"owner,connectionid)values(?,?,?,?,?,?,?)";
		try {
			Connection conn=DriverManager.getConnection(url,user,db_password);
			PreparedStatement psmt=conn.prepareStatement(query2);
			psmt.setString(1,(String) datamap.get("objectid") );
			psmt.setString(2, (String) datamap.get("name"));
			psmt.setString(3, (String) datamap.get("supertype"));
			psmt.setString(4, (String) datamap.get("type"));
			psmt.setTimestamp(5,Timestamp.valueOf(LocalDateTime.now()));
			psmt.setString(6,(String) datamap.get("owner") );
			psmt.setString(7, (String) datamap.get("connectionid"));
			psmt.executeUpdate();
//			int rowinserted=
//					psmt.executeUpdate();
//			if(rowinserted>0) {
//							System.out.println("succesfully created database");
//			}else {
//							System.out.println("filed to created ");
//			}

		}catch(Exception e) {
			e.printStackTrace();
			e.getMessage();
			throw new  RuntimeException ("objectid is duplicate" + datamap.get("objectid"));
		}
	}
    public String  getinfos(String seletable) {
    	String columname="";
    	String query="select " + seletable + " from amxRoute where objectid=?";
    	try {
    		Connection conn=DriverManager.getConnection(url,user,db_password);
    		PreparedStatement pstmt=conn.prepareStatement(query);
    		pstmt.setString(1,"objectid");
    		ResultSet rs=pstmt.executeQuery();
    		if(rs.next()) {
    			columname=rs.getString("seletable");
    		}
    	}catch(Exception e) {
    		e.printStackTrace();
    	}
		return columname;
    	
    }
    public String promoteBlock(String objectid) {
        String currentState = "";
        String nextState = "";

        try (Connection conn = DriverManager.getConnection(url, user, db_password)) {

        	String linkedQuery = "SELECT COUNT(*) FROM amxpartcontroldata WHERE linkedobjectid=?";
        	boolean isLinked = false;
        	try (PreparedStatement linkedStmt = conn.prepareStatement(linkedQuery)) {
        	    linkedStmt.setString(1, objectid);
        	    ResultSet linkedRs = linkedStmt.executeQuery();
        	    if (linkedRs.next() && linkedRs.getInt(1) > 0) {
        	        isLinked = true; 
        	        return null; 
        	    }
        	}
            if (!isLinked) {
               // System.out.println("No PartControl is connected.Please connect some part control and try to promote it	");
               
            }

           
            String query1 = "SELECT currentstate FROM amxcorepartdata WHERE objectid=?";
            try (PreparedStatement pstmt1 = conn.prepareStatement(query1)) {
                pstmt1.setString(1, objectid);
                ResultSet rs1 = pstmt1.executeQuery();
                if (rs1.next()) {
                    currentState = rs1.getString("currentstate").trim();
                }
            }

            
            String query2 = "SELECT rulevalue FROM amxschemarules WHERE rulename=?";
            try (PreparedStatement pstmt2 = conn.prepareStatement(query2)) {
                pstmt2.setString(1, "PartStates");  
                ResultSet rs2 = pstmt2.executeQuery();
                if (rs2.next()) {
                    String ruleValue = rs2.getString("rulevalue"); 
                    String[] states = ruleValue.split("\\|");
                    for (int i = 0; i < states.length; i++) {
                        states[i] = states[i].trim();
                        if (states[i].equalsIgnoreCase(currentState) && i < states.length - 1) {
                            nextState = states[i + 1].trim();
                            break;
                        }
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
		return nextState;

    }
    
    
    	
    public String releaseBlock(String objectid) {
        @SuppressWarnings("unused")
		String currentState = "";
        String linkedObjectId = "";

        try (Connection conn = DriverManager.getConnection(url, user, db_password)) {

           
            String query = "SELECT currentstate, linkedobjectid FROM amxpartcontroldata WHERE objectid=?";
            try (PreparedStatement pstmt = conn.prepareStatement(query)) {
                pstmt.setString(1, objectid);
                ResultSet rs = pstmt.executeQuery();
                if (rs.next()) {
                    currentState = rs.getString("currentstate");
                    linkedObjectId = rs.getString("linkedobjectid");
                }
            }
            if (linkedObjectId != null && !linkedObjectId.isEmpty()) {
                String checkQuery = "SELECT 1 FROM amxcorepartdata WHERE objectid=?";
                try (PreparedStatement pstmt2 = conn.prepareStatement(checkQuery)) {
                    pstmt2.setString(1, linkedObjectId);
                    ResultSet rs2 = pstmt2.executeQuery();
                    if (rs2.next()) {
                        
                        return "Released";
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return "" ; 
    }
    @SuppressWarnings({ })
    public List<Map<String, String>> getConnectedRoute() throws Exception {
        List<Map<String, String>> resultList = new ArrayList<>();
        String query1 = "SELECT connectionid FROM amxpartcontroldata WHERE objectid=?";
        String query2 = "SELECT toid FROM amxcoreconnectiondata WHERE connectionid=?";
        String queryRoute = "SELECT * FROM amxroute WHERE objectid=?";

        try (Connection conn = DriverManager.getConnection(url, user, db_password);
             PreparedStatement pstmt1 = conn.prepareStatement(query1);
             PreparedStatement pstmt2 = conn.prepareStatement(query2);
             PreparedStatement pstmtRoute = conn.prepareStatement(queryRoute)) {

            pstmt1.setString(1, objectid);
            ResultSet rs1 = pstmt1.executeQuery();

            while (rs1.next()) {
                String connectionId = rs1.getString("connectionid");
                pstmt2.setString(1, connectionId);
                ResultSet rs2 = pstmt2.executeQuery();

                while (rs2.next()) {
                    String toid = rs2.getString("toid").trim();
                    if (toid.endsWith("ROUT")) {
                        pstmtRoute.setString(1, toid);
                        ResultSet rsRoute = pstmtRoute.executeQuery();

                        if (rsRoute.next()) {
                            Map<String, String> dataMap = new HashMap<>();
                            ResultSetMetaData getData = rsRoute.getMetaData();
                            int columnCount = getData.getColumnCount();

                            for (int i = 1; i <= columnCount; i++) {
                                String key = getData.getColumnName(i);
                                String value = rsRoute.getString(i);
                                dataMap.put(key, value);
                            }

                            resultList.add(dataMap);
                        } else {
                            throw new Exception(toid + " not found in amxroute table");
                        }
                    }
                }
            }
        } catch (Exception e) {
            throw e;
        }
        return resultList;
    }
    public boolean partControlAssignee(String objectid, String loginUser) {
        String query = "SELECT assignee FROM amxpartcontroldata WHERE objectid=?";
        
        try (
            Connection conn = DriverManager.getConnection(url, user, db_password);
            PreparedStatement pstmt = conn.prepareStatement(query)
        ) {
            pstmt.setString(1, objectid);
            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                String value = rs.getString("assignee");

                // Use equalsIgnoreCase and null check
                if (value != null && value.equalsIgnoreCase(loginUser)) {
                    return true;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return false;
    }


}

