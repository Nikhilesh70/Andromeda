package amd;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.*;
public class AmxPartSpecification {
	  public static final String URL = "jdbc:postgresql://localhost:5432/Andromeda";
	    public static final String USERNAME = "postgres";
	    public static final String PASSWORD = "amxadmin123";
		public  String objectId; 
		 AmxPartSpecification (String sobjectid){
			 this. objectId=sobjectid;
		 }
		 AmxPartSpecification (){
		 }
	public void createTable() {
			String query="create Table if not exists amxpartspecificationdata("
			+ "objectid VARCHAR(100) PRIMARY KEY,"
			+ "name VARCHAR(100),"
			+ "supertype VARCHAR(255),"
			+ "type VARCHAR(100),"
			+ "createdtime TIMESTAMP,"
			+ "modifiedtime TIMESTAMP,"
			+ "connectionid VARCHAR(100),"
			+ "owner VARCHAR(100),"
			+ "email VARCHAR(255)"
			+")"; 
		try {
			Connection conn=DriverManager.getConnection(URL,USERNAME,PASSWORD);
			PreparedStatement psmt=conn.prepareStatement(query);
			psmt.executeUpdate();
		}catch(Exception e) {
			e.printStackTrace();
			e.getMessage();
		}
	}
@SuppressWarnings("rawtypes")
public void createObject(Map datamap) {
	String query2="insert into amxpartspecificationdata(objectid,name,supertype,type,createdtime,"
			+"modifiedtime,connectionid,owner,email)values(?,?,?,?,?,?,?,?,?)";
	try {
		Connection conn=DriverManager.getConnection(URL,USERNAME,PASSWORD);
		PreparedStatement psmt=conn.prepareStatement(query2);
		psmt.setString(1,(String) datamap.get("objectid") );
		psmt.setString(2, (String) datamap.get("name"));
		psmt.setString(3, (String) datamap.get("supertype"));
		psmt.setString(4, (String) datamap.get("type"));
		psmt.setTimestamp(5,Timestamp.valueOf(LocalDateTime.now()));
		psmt.setTimestamp(6,Timestamp.valueOf(LocalDateTime.now()));
		psmt.setString(7, (String) datamap.get("connectionid"));
		psmt.setString(8,(String) datamap.get("owner") );
		psmt.setString(9, (String) datamap.get("email"));
		int rowinserted=psmt.executeUpdate();
		if(rowinserted>0) {
//			System.out.println("succesfully created database");
		}else {
//			System.out.println("filed to created ");
		}
		psmt.executeUpdate();
	}catch(Exception e) {
		e.printStackTrace();
		e.getMessage();
		throw new  RuntimeException ("objectid is duplicate" + datamap.get("objectid"));
	}
}
	public String getinfo(String columnname) {
		String sname="";
		boolean objectfound=false;
		String spsrticulardata="SELECT " + columnname + " FROM amxpartspecificationdata where objectid=?";
		try {
			Connection Conn=DriverManager.getConnection(URL, USERNAME,PASSWORD);
			PreparedStatement pstmt=Conn.prepareStatement(spsrticulardata);
			pstmt.setString(1, objectId);
			ResultSet rs=pstmt.executeQuery();
			if(rs.next()) {
				sname=rs.getString(columnname);
				objectfound=true;
			}
			rs.close();
			pstmt.close();
			Conn.close();
			if(!objectfound) {
				throw new RuntimeException("ObjectId '" + objectId + "' not found in database.");
			}
		}catch(Exception e) {
			e.printStackTrace();
		}
		return sname;
	}
		@SuppressWarnings({ "unchecked", "rawtypes" })
		public Map getInfos() {
			String selectQuery = "SELECT * FROM amxpartspecificationdata WHERE objectid = ?";
			Map result = new HashMap();

			try {
				Connection conn = DriverManager.getConnection(URL, USERNAME, PASSWORD);

				PreparedStatement pstmt = conn.prepareStatement(selectQuery);

				pstmt.setString(1, objectId);
				ResultSet rs = pstmt.executeQuery();

				ResultSetMetaData meta = rs.getMetaData();

				if (rs.next()) {
					int count = meta.getColumnCount();
					for (int i = 1; i <= count; i++) {
						String colName = meta.getColumnName(i);
						String val = rs.getString(i);
						result.put(colName, val);
					}
				}
				rs.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
			return result;
		}
		
		
		
	}
