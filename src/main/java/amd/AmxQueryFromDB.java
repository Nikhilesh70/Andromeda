package amd;
import java.sql.*;
public class AmxQueryFromDB {
	public static final String url="jdbc:postgresql://localhost:5432/Andromeda";
	public static final String user="postgres";
	public static final String password="amxadmin123";
	public  String objectid;
public String executeQuery(String query) {
	StringBuilder result = new StringBuilder();
	try {
		Connection conn=DriverManager.getConnection(url,user,password);
		PreparedStatement pstmt=conn.prepareStatement(query);
		ResultSet rs=pstmt.executeQuery();
		ResultSetMetaData data=rs.getMetaData();
		while(rs.next()) {
			int count=data.getColumnCount();
			for(int i=1;i<=count;i++) {
				String key=data.getColumnName(i);
				String value=rs.getString(i);
				 result.append(key).append(": ").append(value) .append(",");	
			}
			  result.append("\n"); 
					}
	}catch(Exception e) {
		e.printStackTrace();
	}
	return result.toString();
	}
}