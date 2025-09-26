package org.navigator;

import java.security.SecureRandom;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.json.JSONArray;
import org.json.JSONObject;

import jakarta.ws.rs.Consumes;
import jakarta.ws.rs.GET;
import jakarta.ws.rs.POST;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.PathParam;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.QueryParam;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

@Path("/searchdata")
public class SearchData {
    public static final String url = "jdbc:postgresql://localhost:5432/Andromeda";
    public static final String user = "postgres";
    public static final String db_password = "amxadmin123";
    public static final SimpleDateFormat sf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

    static {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
         
        }
    }
    public Connection getConn() throws SQLException {
        return DriverManager.getConnection(url, user, db_password);
    }
    
    //searchData
    @GET
    @Path("/popupsearch")
    @Produces(MediaType.APPLICATION_JSON)
    public Response search(@QueryParam("name") String name) {
        JSONObject resp = new JSONObject();
        if (name == null || name.trim().isEmpty()) {
            resp.put("Status", "Failed").put("Message", "Search term is required.");
            return Response.status(Response.Status.BAD_REQUEST).entity(resp.toString()).build();
        }

        name = name.trim();
        JSONArray results = new JSONArray();

        try (Connection conn = DriverManager.getConnection(url, user, db_password)) {
            PreparedStatement ps;
            String sql;

            if (name.toUpperCase().matches("^(PC)[-]?[0-9]*$")) {
                //  PC-000001 
                sql = "SELECT * FROM amxpartcontroldata WHERE fts_document @@ to_tsquery(?)";
                ps = conn.prepareStatement(sql);
                ps.setString(1, name.toLowerCase() + ":*");

            } else if (name.matches("^(\\d{3})([-\\w]*)?$")) {
                //900 or 900-000
                sql = "SELECT * FROM amxcorepartdata WHERE fts_document @@ to_tsquery(?)";
                ps = conn.prepareStatement(sql);
                ps.setString(1, name.toLowerCase() + ":*");

            } else if (name.toUpperCase().startsWith("PASP")) {
                //PASP
                sql = "SELECT * FROM amxpartspecificationdata WHERE fts_document @@ to_tsquery(?)";
                ps = conn.prepareStatement(sql);
                ps.setString(1, name.toLowerCase() + ":*");

            } else {
                resp.put("Status", "Failed").put("Message", "Unsupported search pattern.");
                return Response.status(Response.Status.BAD_REQUEST).entity(resp.toString()).build();
            }

            try (ResultSet rs = ps.executeQuery()) {
                ResultSetMetaData meta = rs.getMetaData();
                while (rs.next()) {
                    JSONObject obj = new JSONObject();
                    for (int i = 1; i <= meta.getColumnCount(); i++) {
                        obj.put(meta.getColumnName(i), rs.getString(i));
                    }
                    results.put(obj);
                }
            }

            resp.put("Status", "Success").put("Results", results);
            return Response.ok(resp.toString(), MediaType.APPLICATION_JSON).build();

        } catch (SQLException e) {
            e.printStackTrace();
            resp.put("Status", "Failed").put("Message", "Database error: " + e.getMessage());
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(resp.toString()).build();
        }
    }


    
    //addexistingpart
    @POST
    @Path("/popupsearch/{sourceobjectid}")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response addPartControlWithSource(@PathParam("sourceobjectid") String sourceObjectId, 
                                             List<Map<String, Object>> partControls) {
        try {
            if (partControls == null || partControls.isEmpty()) {
                return Response.ok("error", "No part control data provided").build();
            }
            if (sourceObjectId == null || sourceObjectId.isEmpty()) {
                return Response.ok("error", "'sourceobjectid' is required").build();
            }
            String connectionId = generateConnectionId();
            String createdDate = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
            LocalDateTime localDateTime = LocalDateTime.parse(createdDate, DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
            String insertSQL = "INSERT INTO amxcoreconnectiondata (connectionid, type, name, fromid, toid, fromname, toname, createddate) "
                             + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            try (Connection conn = DriverManager.getConnection(url, user, db_password)) {
                conn.setAutoCommit(false);  
                try (PreparedStatement ps = conn.prepareStatement(insertSQL)) {
                    for (Map<String, Object> rawPartControl : partControls) {
                        Map<String, String> partControlMap = new HashMap<>();
                        for (Map.Entry<String, Object> entry : rawPartControl.entrySet()) {
                            partControlMap.put(entry.getKey().toLowerCase(), entry.getValue() == null ? "" : entry.getValue().toString());
                        }
                        String partName = partControlMap.get("name");
                        String partType = partControlMap.get("type");
                        String partId = partControlMap.get("objectid");
                        if (partName == null || partType == null || partId == null) {
                            //System.err.println("Skipping insert due to missing data in part control: " + partControlMap);
                            continue;
                        }
                        String fromName = "";
                        if ("partspecification".equalsIgnoreCase(partType)) {
                            fromName = "PartSpecification";
                        } else if ("partcontrol".equalsIgnoreCase(partType)) {
                            fromName = "PartControl";  
                        } else {
                            continue;
                        }
                        ps.setString(1, connectionId);
                        ps.setString(2, partType);
                        ps.setString(3, partName);
                        ps.setString(4, partId);
                        ps.setString(5, sourceObjectId);
                        ps.setString(6, fromName); 
                        ps.setString(7, "part");  
                        ps.setTimestamp(8, Timestamp.valueOf(localDateTime)); 
                        ps.executeUpdate();
                    }
                }

                // Update amxcorepartdata table 
                String updateSQL = "UPDATE amxcorepartdata SET connectionid = ? WHERE objectid = ?";
                try (PreparedStatement psUpdate = conn.prepareStatement(updateSQL)) {
                    psUpdate.setString(1, connectionId);
                    psUpdate.setString(2, sourceObjectId);
                    int rowsUpdated = psUpdate.executeUpdate();

                    if (rowsUpdated == 0) {
                        conn.rollback();
                        return Response.status(Response.Status.NOT_FOUND)
                                .entity(Map.of("error", "No record found for sourceObjectId: " + sourceObjectId))
                                .build();
                    }
                }
                conn.commit();

            } catch (SQLException e) {
                e.printStackTrace();
                return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                        .entity(Map.of("error", "Database error: " + e.getMessage()))
                        .build();
            }

            return Response.ok(Map.of("message", "Part controls and connections successfully added", "connectionid", connectionId)).build();

        } catch (Exception e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity(Map.of("error", "Failed to add part control: " + e.getMessage()))
                    .build();
        }
    }
    public String generateConnectionId() {
        SecureRandom random = new SecureRandom();
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < 3; i++) {
            String segment = Integer.toHexString(random.nextInt(0x10000)).toUpperCase();
            while (segment.length() < 4) {
                segment = "0" + segment;
            }
            sb.append(segment);
            if (i < 2) sb.append(".");
        }
        sb.append(".CONN");
        return sb.toString();
    }

    
}
