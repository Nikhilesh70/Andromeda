package amd;
import java.sql.*;
import org.json.JSONObject;
public class AmxQueryFromDB {	
    public static final String url="jdbc:postgresql://localhost:5432/Andromeda";
    public static final String user="postgres";
    public static final String password="amxadmin123";
    public String objectid;
    @SuppressWarnings("unused")
	public String executeQuery(String query) {
        StringBuilder result = new StringBuilder();
        JSONObject jsonResult = new JSONObject();//add the json object
        try (Connection conn = DriverManager.getConnection(url, user, password);
             Statement stmt = conn.createStatement()) {
            String lower = query.trim().toLowerCase();
            if (lower.startsWith("select")) {
              
                ResultSet rs = stmt.executeQuery(query);
                ResultSetMetaData metaData = rs.getMetaData();
                int columnCount = metaData.getColumnCount();
                boolean hasData = false;
                int rowNumber = 1;
                while (rs.next()) {
                    JSONObject rowObj = new JSONObject();//create json object
                    hasData = true;
                    for (int i = 1; i <= columnCount; i++) {
                        String columnName = metaData.getColumnName(i);
                        String value = rs.getString(i);
                        rowObj.put(columnName, value);
                        result.append(columnName)
                              .append(": ")
                              .append(value)
                              .append(i < columnCount ? ", " : "");
                        jsonResult.put( columnName,value);//to strore into jsonresult format
                    }
                    result.append("\n");
                   
                    rowNumber++;
                }

                if(!hasData){
                    result.append("No data found in the table.");
                    jsonResult.put("message", "No data found");//if it is no there it will be no data found 
                }
            } else if (lower.startsWith("create")) {
                stmt.executeUpdate(query);
                result.append("Table created successfully.");
                jsonResult.put("mesage","Table created successfully");//to store into json result format 
            } else if (lower.startsWith("drop")) {
                stmt.executeUpdate(query);
                result.append("Table dropped successfully.");
                jsonResult.put("mesage","Table dropped successfully");//to store into json result format 
            } else if (lower.startsWith("alter")) {
                stmt.executeUpdate(query);
                result.append("Table altered successfully.");
                jsonResult.put("mesage","Table altered successfully");//to store into json result format 
            } else if (lower.startsWith("insert") || lower.startsWith("update") || lower.startsWith("delete")) {
                int rows = stmt.executeUpdate(query);
                result.append(rows).append(" row(s) affected.");
                jsonResult.put("message", rows + " row(s) affected");//to store into json result format 
            } else if (lower.startsWith("show tables")) {
                ResultSet rs = stmt.executeQuery(
                        "SELECT table_name FROM information_schema.tables WHERE table_schema='public';");
                    int tableCount = 1;
                    boolean hasTables = false;
                    while (rs.next()) {
                        hasTables = true;
                        String tableName = rs.getString("table_name");
                        result.append(tableName).append("\n");
                        jsonResult.put("table" + tableCount, tableName); //to store into json result format 
                        tableCount++;
                    }
                    if(!hasTables){
                        result.append("No tables found.\n");
                        jsonResult.put("message","No tables found");//to store into json result format 
                    }
                
            } else {
                stmt.executeUpdate(query);
                result.append("Query executed successfully.");
                jsonResult.put("mesage"," Query executed successfully");//to store into json result format 
                
                
            }
           
        } catch (Exception e) {
            return "Error: " + e.getMessage();
        }
       
        return result.toString(); 
}
}
