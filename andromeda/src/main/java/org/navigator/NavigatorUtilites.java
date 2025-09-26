package org.navigator;

import jakarta.ws.rs.*;
import jakarta.ws.rs.core.*;
import jakarta.servlet.http.*;
import org.json.JSONArray;
import org.json.JSONObject;

import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.security.SecureRandom;

@Path("/navigatorutilites")
public class NavigatorUtilites {

    public static final String url = "jdbc:postgresql://localhost:5432/Andromeda";
    public static final String user = "postgres";
    public static final String db_password = "amxadmin123";

    public static final SimpleDateFormat sf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    
    static {
        try {
            Class.forName("org.postgresql.Driver");
//            System.out.println("PostgreSQL JDBC Driver Registered!");
        } catch (ClassNotFoundException e) {
//            System.err.println("PostgreSQL JDBC Driver not found. Include it in your library path!");
            e.printStackTrace();
        }
    }
    
 //login
    @POST
    @Path("/login")
    @Consumes(MediaType.APPLICATION_FORM_URLENCODED)
    @Produces(MediaType.APPLICATION_JSON)
    public Response login( @FormParam("username") String username, @Context HttpServletRequest request) {

        JSONObject resp = new JSONObject();
        if (username == null || username.trim().isEmpty()) {
            resp.put("Status", "Failed").put("Message", "Username is required.");
            return Response.status(Response.Status.BAD_REQUEST).entity(resp.toString()).build();
        }
        request.getSession(true).setAttribute("username", username);
        resp.put("Status", "Success").put("Message", "User logged in.").put("Username", username);
        return Response.ok(resp.toString(), MediaType.APPLICATION_JSON).build();
    }

    //create
    @POST
    @Path("/create")
    @Consumes(MediaType.APPLICATION_FORM_URLENCODED)
    @Produces(MediaType.APPLICATION_JSON)
    public Response createPart(@FormParam("SuperType") String supertype,@FormParam("Type") String type,@FormParam("APN") String apn,
                 @FormParam("Description") String description,@FormParam("FastenerSubPart") String fastenerSubPart,
              @FormParam("Variant") String variant,@Context HttpServletRequest request) {
        JSONObject resp = new JSONObject();
        HttpSession session = request.getSession(false);
        String username = (session != null) ? (String) session.getAttribute("username") : null;
        if (username == null) {
            resp.put("Status", "Failed").put("Message", "User not logged in.");
            return Response.status(Response.Status.UNAUTHORIZED).entity(resp.toString()).build();
        }

        boolean isFastener = "Fastener".equalsIgnoreCase(type);

        if (supertype == null || type == null || apn == null || description == null ||
                supertype.trim().isEmpty() || type.trim().isEmpty() || apn.trim().isEmpty() || description.trim().isEmpty()) {
            resp.put("Status", "Failed").put("Message", "Missing required fields.");
            return Response.status(Response.Status.BAD_REQUEST).entity(resp.toString()).build();
        }

        if (isFastener) {
            if (fastenerSubPart == null || fastenerSubPart.trim().isEmpty() || variant == null || variant.trim().isEmpty()) {
                resp.put("Status", "Failed").put("Message", "FastenerSubPart and Variant are required when Type is Fastener.");
                return Response.status(Response.Status.BAD_REQUEST).entity(resp.toString()).build();
            }
        } else {
            if (fastenerSubPart == null) fastenerSubPart = "";
            if (variant == null) variant = "";
        }

        try (Connection conn = DriverManager.getConnection(url, user, db_password)) {
            String firstState = "InWork"; 
            try (PreparedStatement psState = conn.prepareStatement("SELECT rulevalue FROM amxschemarules WHERE rulename = 'PartStates'")) {
                ResultSet rsState = psState.executeQuery();
                if (rsState.next()) {
                    String states = rsState.getString("rulevalue");
                    if (states != null && !states.isEmpty()) {
                        firstState = states.split("\\|")[0]; 
                    }
                }
                rsState.close();
            }

            String[] apnParts = apn.split("-");
            if (apnParts.length != 2) {
                resp.put("Status", "Failed").put("Message", "APN format should be like '500-Engine'");
                return Response.status(Response.Status.BAD_REQUEST).entity(resp.toString()).build();
            }
            String prefix = apnParts[0];
            String suffix = apnParts[1];

            String query = "SELECT name FROM amxcorepartdata WHERE apn = ?";
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setString(1, apn);
            ResultSet rs = ps.executeQuery();

            int maxNum = 0;
            while (rs.next()) {
                String existingName = rs.getString("name");
                String[] parts = existingName.split("-");
                if (parts.length == 3 && parts[0].equals(prefix) && parts[2].equals(suffix)) {
                    try {
                        int num = Integer.parseInt(parts[1]);
                        if (num > maxNum) maxNum = num;
                    } catch (NumberFormatException ignored) {}
                }
            }
            rs.close();
            ps.close();

            int newNum = maxNum + 1;
            String name = String.format("%s-%03d-%s", prefix, newNum, suffix);

            SecureRandom random = new SecureRandom();
            StringBuilder objectIdBuilder = new StringBuilder();
            for (int i = 0; i < 4; i++) {
                objectIdBuilder.append(String.format("%04X", random.nextInt(0x10000)));
                if (i < 3) objectIdBuilder.append(".");
            }
            String objectId = objectIdBuilder.toString() + ".APN";

            String createdDate = sf.format(new java.util.Date());

            String insertSQL = "INSERT INTO amxcorepartdata(objectid, apn, name, type, supertype, description, createddate, owner, email, fastenersubpart, variant, connectionid, currentstate) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            try (PreparedStatement insertPS = conn.prepareStatement(insertSQL)) {
                insertPS.setString(1, objectId);
                insertPS.setString(2, apn);
                insertPS.setString(3, name);
                insertPS.setString(4, type);
                insertPS.setString(5, supertype);
                insertPS.setString(6, description);
                insertPS.setTimestamp(7, Timestamp.valueOf(createdDate));
                insertPS.setString(8, username);
                insertPS.setString(9, username + "@apn.com");
                insertPS.setString(10, fastenerSubPart);
                insertPS.setString(11, variant);
                insertPS.setString(12, "");
                insertPS.setString(13, firstState); 
                insertPS.executeUpdate();
            }

            String historyMsg = "Created by " + username + " at " + createdDate;
            try (PreparedStatement hSel = conn.prepareStatement("SELECT history FROM parthistory WHERE objectid = ?")) {
                hSel.setString(1, objectId);
                ResultSet hRs = hSel.executeQuery();
                if (hRs.next()) {
                    String existing = hRs.getString("history");
                    String updated = existing + " | " + historyMsg;
                    try (PreparedStatement hUpd = conn.prepareStatement("UPDATE parthistory SET history = ? WHERE objectid = ?")) {
                        hUpd.setString(1, updated);
                        hUpd.setString(2, objectId);
                        hUpd.executeUpdate();
                    }
                } else {
                    try (PreparedStatement hIns = conn.prepareStatement("INSERT INTO parthistory (objectid, history) VALUES (?, ?)")) {
                        hIns.setString(1, objectId);
                        hIns.setString(2, historyMsg);
                        hIns.executeUpdate();
                    }
                }
            }

            resp.put("Status", "Success")
                    .put("ObjectId", objectId)
                    .put("Name", name)
                    .put("CreatedDate", createdDate)
                    .put("Owner", username)
                    .put("FastenerSubPart", fastenerSubPart)
                    .put("Variant", variant)
                    .put("CurrentState", firstState);  

            return Response.ok(resp.toString(), MediaType.APPLICATION_JSON).build();

        } catch (SQLException e) {
            e.printStackTrace();
            resp.put("Status", "Failed").put("Message", "Database error: " + e.getMessage());
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(resp.toString()).build();
        }
    }
    
//loadall
    @POST
    @Path("/loadAll")
    @Produces(MediaType.APPLICATION_JSON)
    public Response loadAllTypes() {
        JSONObject resp = new JSONObject();
        Set<String> superTypes = new HashSet<>();
        Set<String> types = new HashSet<>();

        try (Connection conn = DriverManager.getConnection(url, user, db_password);
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery("SELECT DISTINCT supertype, type FROM amxcorepartdata")) {

            while (rs.next()) {
                String st = rs.getString("supertype");
                String t  = rs.getString("type");
                if (st != null && !st.trim().isEmpty()) superTypes.add(st);
                if (t  != null && !t.trim().isEmpty()) types.add(t);
            }
            resp.put("SuperType", new JSONArray(superTypes));
            resp.put("Type", new JSONArray(types));
            return Response.ok(resp.toString(), MediaType.APPLICATION_JSON).build();
        } catch (SQLException e) {
            e.printStackTrace();
            resp.put("Status", "Failed").put("Message", "Database error: " + e.getMessage());
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(resp.toString()).build();
        }
    }
    
//search
    @GET
    @Path("/amxfullsearch")
    @Produces(MediaType.APPLICATION_JSON)
    public Response search(@QueryParam("name") String name, @QueryParam("filter") String filter) {
        JSONObject resp = new JSONObject();

        if (filter == null || filter.trim().isEmpty()) {
            filter = "all";
        }
        try (Connection conn = DriverManager.getConnection(url, user, db_password)) {
            JSONArray results = new JSONArray();
            if ("byparts".equalsIgnoreCase(filter)) {
                if (name == null || name.trim().isEmpty()) {
                    resp.put("Status", "Failed").put("Message", "Part name is required for 'byParts'.");
                    return Response.status(Response.Status.BAD_REQUEST).entity(resp.toString()).build();
                }
                String sql = "SELECT * FROM amxcorepartdata WHERE fts_document @@ to_tsquery(?)";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, name.toLowerCase() + ":*");
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
                }
            } else if ("bypersons".equalsIgnoreCase(filter)) {
                if (name == null || name.trim().isEmpty()) {
                    resp.put("Status", "Failed").put("Message", "Person name is required for 'byPersons'.");
                    return Response.status(Response.Status.BAD_REQUEST).entity(resp.toString()).build();
                }
                String sql = "SELECT * FROM amxcorepersondata WHERE fts_document @@ to_tsquery(?)";
                try (PreparedStatement ps = conn.prepareStatement(sql)) {
                    ps.setString(1, name.toLowerCase() + ":*");
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
                }
            } else if ("all".equalsIgnoreCase(filter)) {
                if (name == null || name.trim().isEmpty()) {
                    resp.put("Status", "Failed").put("Message", "Search term is required for 'all'.");
                    return Response.status(Response.Status.BAD_REQUEST).entity(resp.toString()).build();
                }

                String searchTerm = name.trim().toLowerCase();

                // Updated pattern for numeric part numbers like 900, 900-001
                if (searchTerm.matches("^[0-9]+(-[0-9]*)?$")) {
                    String sql = "SELECT * FROM amxcorepartdata WHERE fts_document @@ to_tsquery(?)";
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setString(1, searchTerm + ":*");
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
                    }
                } else {
                	String[] parts = searchTerm.split("[^a-zA-Z0-9]+");
                	List<String> tsParts = new ArrayList<>();
                	for (String part : parts) {
                	    if (!part.trim().isEmpty()) {
                	        tsParts.add(part + ":*");
                	    }
                	}
                	String tsQuery = String.join(" & ", tsParts);
                    String sql = "SELECT * FROM amxpartcontroldata WHERE fts_document @@ to_tsquery(?)";
                    try (PreparedStatement ps = conn.prepareStatement(sql)) {
                        ps.setString(1, tsQuery);
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
                    }
                }
            }

            else {
                resp.put("Status", "Failed").put("Message", "Invalid filter value.");
                return Response.status(Response.Status.BAD_REQUEST).entity(resp.toString()).build();
            }
            resp.put("Status", "Success").put("Results", results);
            return Response.ok(resp.toString(), MediaType.APPLICATION_JSON).build();

        } catch (SQLException e) {
            e.printStackTrace();
            resp.put("Status", "Failed").put("Message", "Database error: " + e.getMessage());
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(resp.toString()).build();
        }
    }
//latestpart
    @POST
    @Path("/latest")
    @Produces(MediaType.APPLICATION_JSON)
    public Response latest() {
        JSONObject resp = new JSONObject();

        try (Connection conn = DriverManager.getConnection(url, user, db_password);
             PreparedStatement ps = conn.prepareStatement(
                     "SELECT * FROM amxcorepartdata ORDER BY createddate DESC LIMIT 10");
             ResultSet rs = ps.executeQuery()) {

            JSONArray arr = new JSONArray();
            ResultSetMetaData meta = rs.getMetaData();
            while (rs.next()) {
                JSONObject obj = new JSONObject();
                for (int i = 1; i <= meta.getColumnCount(); i++) {
                    obj.put(meta.getColumnName(i), rs.getString(i));
                }
                arr.put(obj);
            }

            resp.put("Status", "Success").put("LatestParts", arr);
            return Response.ok(resp.toString(), MediaType.APPLICATION_JSON).build();

        } catch (SQLException e) {
            e.printStackTrace();
            resp.put("Status", "Failed").put("Message", "Database error: " + e.getMessage());
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(resp.toString()).build();
        }
    }
//update
    @POST
    @Path("/update")
    @Consumes(MediaType.APPLICATION_FORM_URLENCODED)
    @Produces(MediaType.APPLICATION_JSON)
    public Response update(@FormParam("objectid") String objectId,@FormParam("Description") String description) {
        JSONObject resp = new JSONObject();
        if (objectId == null || objectId.trim().isEmpty()
                || description == null || description.trim().isEmpty()) {
            resp.put("Status", "Failed").put("Message", "objectid and description are required.");
            return Response.status(Response.Status.BAD_REQUEST).entity(resp.toString()).build();
        }
        String updatedDate = sf.format(new Date());
        try (Connection conn = DriverManager.getConnection(url, user, db_password);
             PreparedStatement ps = conn.prepareStatement(
                     "UPDATE amxcorepartdata SET description = ?, createddate = ? WHERE objectid = ?")) {
            ps.setString(1, description);
            ps.setTimestamp(2, Timestamp.valueOf(updatedDate));
            ps.setString(3, objectId);
            int count = ps.executeUpdate();
            if (count == 0) {
                resp.put("Status", "Failed").put("Message", "objectid not found.");
                return Response.status(Response.Status.NOT_FOUND).entity(resp.toString()).build();
            }
//add history
            String historyMsg = "Updated description at " + updatedDate;
            try (PreparedStatement psSel = conn.prepareStatement("SELECT history FROM part_history WHERE objectid = ?")) {
                psSel.setString(1, objectId);
                try (ResultSet rs = psSel.executeQuery()) {
                    if (rs.next()) {
                        String existing = rs.getString("history");
                        String updated = existing + " | " + historyMsg;
                        try (PreparedStatement psUpd = conn.prepareStatement("UPDATE part_history SET history = ? WHERE objectid = ?")) {
                            psUpd.setString(1, updated);
                            psUpd.setString(2, objectId);
                            psUpd.executeUpdate();
                        }
                    } else {
                        try (PreparedStatement psIns = conn.prepareStatement("INSERT INTO part_history (objectid, history) VALUES (?, ?)")) {
                            psIns.setString(1, objectId);
                            psIns.setString(2, historyMsg);
                            psIns.executeUpdate();
                        }
                    }
                }
            }

            resp.put("Status", "Success").put("Message", "Part updated.");
            return Response.ok(resp.toString(), MediaType.APPLICATION_JSON).build();

        } catch (SQLException e) {
            e.printStackTrace();
            resp.put("Status", "Failed").put("Message", "Database error: " + e.getMessage());
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(resp.toString()).build();
        }
    }

    //delete
    @POST
    @Path("/delete")
    @Consumes(MediaType.APPLICATION_FORM_URLENCODED)
    @Produces(MediaType.APPLICATION_JSON)
    public Response delete(@FormParam("objectid") String objectId) {
        JSONObject resp = new JSONObject();
        if (objectId == null || objectId.trim().isEmpty()) {
            resp.put("Status", "Failed").put("Message", "objectid is required.");
            return Response.status(Response.Status.BAD_REQUEST).entity(resp.toString()).build();
        }

        try (Connection conn = DriverManager.getConnection(url, user, db_password);
             PreparedStatement ps = conn.prepareStatement("DELETE FROM amxcorepartdata WHERE objectid = ?")) {
            ps.setString(1, objectId);
            int count = ps.executeUpdate();

            if (count == 0) {
                resp.put("Status", "Failed").put("Message", "objectid not found.");
                return Response.status(Response.Status.NOT_FOUND).entity(resp.toString()).build();
            }

            String deletedDate = sf.format(new Date());
            String historyMsg = "Deleted at " + deletedDate;
            try (PreparedStatement psSel = conn.prepareStatement("SELECT history FROM part_history WHERE objectid = ?")) {
                psSel.setString(1, objectId);
                try (ResultSet rs = psSel.executeQuery()) {
                    if (rs.next()) {
                        String existing = rs.getString("history");
                        String updated = existing + " | " + historyMsg;
                        try (PreparedStatement psUpd = conn.prepareStatement("UPDATE part_history SET history = ? WHERE objectid = ?")) {
                            psUpd.setString(1, updated);
                            psUpd.setString(2, objectId);
                            psUpd.executeUpdate();
                        }
                    } else {
                        try (PreparedStatement psIns = conn.prepareStatement("INSERT INTO part_history (objectid, history) VALUES (?, ?)")) {
                            psIns.setString(1, objectId);
                            psIns.setString(2, historyMsg);
                            psIns.executeUpdate();
                        }
                    }
                }
            }

            resp.put("Status", "Success").put("Message", "Part deleted.");
            return Response.ok(resp.toString(), MediaType.APPLICATION_JSON).build();

        } catch (SQLException e) {
            e.printStackTrace();
            resp.put("Status", "Failed").put("Message", "Database error: " + e.getMessage());
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(resp.toString()).build();
        }
    }

    //history 
    @GET
    @Path("/partcontrolhistory")
    @Produces(MediaType.APPLICATION_JSON)
    public Response partControlHistory(@QueryParam("objectid") String objectId) {
        JSONObject resp = new JSONObject();
        if (objectId == null || objectId.trim().isEmpty()) {
            resp.put("Status", "Failed").put("Message", "objectid is required.");
            return Response.status(Response.Status.BAD_REQUEST).entity(resp.toString()).build();
        }

        String sql = "SELECT history FROM partcontrolhistory WHERE objectid = ?";

        try (Connection conn = DriverManager.getConnection(url, user, db_password);
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, objectId);
            
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String history = rs.getString("history");
                    String[] entries = history != null ? history.split(" \\| ") : new String[0];
                    resp.put("Status", "Success").put("History", new JSONArray(entries));
                } else {
                    resp.put("Status", "Failed").put("Message", "No history found.");
                }
            }
            return Response.ok(resp.toString(), MediaType.APPLICATION_JSON).build();

        } catch (SQLException e) {
            e.printStackTrace();
            resp.put("Status", "Failed").put("Message", "Database error: " + e.getMessage());
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(resp.toString()).build();
        }
    }

}
