package org.navigator;

import java.security.MessageDigest;
import java.security.SecureRandom;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.Date;
import org.json.JSONObject;
import jakarta.servlet.http.*;
import jakarta.ws.rs.*;
import jakarta.ws.rs.core.*;
import jakarta.ws.rs.core.Response.Status;
import amd.Person;
import amd.AmxSchemasrules;
@Path("/datafetchservice")
public class DataFetchService {
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

    // getinfo()
    @GET
    @Path("/info") 
    @Produces(MediaType.APPLICATION_JSON)
    public Response getInfo(@QueryParam("objectId") String id, @QueryParam("field") String field) {
        String sql = "SELECT " + field + " FROM amxcorepartdata WHERE objectid = ?";
        try (Connection conn = getConn(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Response.ok(new JSONObject().put("value", rs.getString(1)).toString()).build();
                }
                return Response.status(Status.NOT_FOUND).entity("{\"error\":\"Field not found\"}").build();
            }
        } catch (SQLException e) {
            return Response.status(Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"" + e.getMessage() + "\"}").build();
        }
    }

    // Get all part info
    @GET 
    @Path("/infos") 
    @Produces(MediaType.APPLICATION_JSON)
    public Response getAllInfo(@QueryParam("objectId") String id) {
        String sql = "SELECT * FROM amxcorepartdata WHERE objectid = ?";
        try (Connection conn = getConn(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    JSONObject obj = new JSONObject();
                    ResultSetMetaData md = rs.getMetaData();
                    for (int i = 1; i <= md.getColumnCount(); i++) {
                        obj.put(md.getColumnName(i), rs.getString(i));
                    }
                    return Response.ok(obj.toString()).build();
                }
                return Response.status(Status.NOT_FOUND).entity("{\"error\":\"Object not found\"}").build();
            }
        } catch (SQLException e) {
            return Response.status(Status.INTERNAL_SERVER_ERROR).entity("{\"error\":\"" + e.getMessage() + "\"}").build();
        }
    }

    //createPart
    @POST
    @Path("/createpartcontrol")
    @Consumes(MediaType.APPLICATION_FORM_URLENCODED)
    @Produces(MediaType.APPLICATION_JSON)
    public Response createPartControl(@FormParam("SuperType") String supertype,
                                     @FormParam("Type") String type,
                                     @FormParam("Description") String description,
                                     @FormParam("Assignee") String assignee,
                                     @Context HttpServletRequest request) {

        JSONObject resp = new JSONObject();
        HttpSession session = request.getSession(true);
        if (session == null
                || session.getAttribute("username") == null
                || session.getAttribute("emailId") == null) {
            resp.put("Status", "Failed").put("Message", "User not logged in.");
            return Response.status(Response.Status.UNAUTHORIZED).entity(resp.toString()).build();
        }

        String username = (String) session.getAttribute("username");
        String emailId = (String) session.getAttribute("emailId");

        if (supertype == null || supertype.trim().isEmpty()
                || type == null || type.trim().isEmpty()
                || description == null || description.trim().isEmpty()
                || assignee == null || assignee.trim().isEmpty()) {

            resp.put("Status", "Failed").put("Message", "Missing required fields.");
            return Response.status(Response.Status.BAD_REQUEST).entity(resp.toString()).build();
        }

        try (Connection conn = DriverManager.getConnection(url, user, db_password)) {
            // Generate objectId 
            SecureRandom random = new SecureRandom();
            byte[] bytes = new byte[8];
            random.nextBytes(bytes);
            StringBuilder objectIdBuilder = new StringBuilder();
            for (int i = 0; i < bytes.length; i += 2) {
                int part = ((bytes[i] & 0xFF) << 8) | (bytes[i + 1] & 0xFF);
                objectIdBuilder.append(String.format("%04X", part));
                if (i < bytes.length - 2) objectIdBuilder.append(".");
            }
            String objectId = objectIdBuilder.toString() +".PACO";
            String prefix = "PC-";
            int maxNum = 0;
            String selectMaxNum = "SELECT name FROM amxpartcontroldata WHERE name LIKE ?";
            try (PreparedStatement ps = conn.prepareStatement(selectMaxNum)) {
                ps.setString(1, prefix + "%");
                try (ResultSet rs = ps.executeQuery()) {
                    while (rs.next()) {
                        String existingName = rs.getString("name");
                        if (existingName.startsWith(prefix)) {
                            String numPart = existingName.substring(prefix.length());
                            try {
                                int num = Integer.parseInt(numPart);
                                if (num > maxNum) {
                                    maxNum = num;
                                }
                            } catch (NumberFormatException ignored) {
                            }
                        }
                    }
                }
            }
            int nextNum = maxNum + 1;
            String name = String.format("%s%06d", prefix, nextNum);
            String createdDate = LocalDateTime.now()
                    .format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
            String insertSQL = "INSERT INTO amxpartcontroldata " +
                    "(objectid, name, supertype, type, description, createddate, owner, email, assignee, connectionid,linkedobjectid) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?)";
            try (PreparedStatement insertPS = conn.prepareStatement(insertSQL)) {
                insertPS.setString(1, objectId);
                insertPS.setString(2, name);
                insertPS.setString(3, supertype);
                insertPS.setString(4, type);
                insertPS.setString(5, description);
                insertPS.setTimestamp(6, Timestamp.valueOf(createdDate));
                insertPS.setString(7, username);
                insertPS.setString(8, emailId != null ? emailId : "");
                insertPS.setString(9, assignee);
                insertPS.setString(10, "");
                insertPS.setString(11, "");
                insertPS.executeUpdate();
            }
            String historyMsg = "Created by " + username + " at " + createdDate;
            String hSelect = "SELECT history FROM parthistory WHERE objectid = ?";
            try (PreparedStatement hSel = conn.prepareStatement(hSelect)) {
                hSel.setString(1, objectId);
                try (ResultSet hrs = hSel.executeQuery()) {
                    if (hrs.next()) {
                        String hist = hrs.getString("history");
                        String combined = hist + " | " + historyMsg;
                        String hUpdate = "UPDATE parthistory SET history = ? WHERE objectid = ?";
                        try (PreparedStatement hUpd = conn.prepareStatement(hUpdate)) {
                            hUpd.setString(1, combined);
                            hUpd.setString(2, objectId);
                            hUpd.executeUpdate();
                        }
                    } else {
                        String hInsert = "INSERT INTO parthistory (objectid, history) VALUES (?, ?)";
                        try (PreparedStatement hIns = conn.prepareStatement(hInsert)) {
                            hIns.setString(1, objectId);
                            hIns.setString(2, historyMsg);
                            hIns.executeUpdate();
                        }
                    }
                }
            }

            JSONObject success = new JSONObject();
            success.put("Status", "Success");
            success.put("Message", "Object created successfully");
            success.put("partcontrolId", objectId);
            success.put("Name", name);

            return Response.ok(success.toString(), MediaType.APPLICATION_JSON).build();

        } catch (SQLException ex) {
            ex.printStackTrace();
            resp.put("Status", "Failed").put("Message", "Internal server error: " + ex.getMessage());
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(resp.toString()).build();
        }
    }


    
    //updatepart
    @PUT
    @Path("/updatepart/{objectid}")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response update(@PathParam("objectid") String objectId, String body) {
        JSONObject resp = new JSONObject();

        // Define your date formatter for SQL Timestamp conversion
        SimpleDateFormat sf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

        try {
            JSONObject json = new JSONObject(body);
            String description = json.optString("description", "").trim();

            // Validate input
            if (objectId == null || objectId.trim().isEmpty() || description.isEmpty()) {
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

                // History handling
                String historyMsg = "Updated description at " + updatedDate;
                try (PreparedStatement psSel = conn.prepareStatement("SELECT history FROM parthistory WHERE objectid = ?")) {
                    psSel.setString(1, objectId);
                    try (ResultSet rs = psSel.executeQuery()) {
                        if (rs.next()) {
                            String existing = rs.getString("history");
                            String updated = existing + " | " + historyMsg;
                            try (PreparedStatement psUpd = conn.prepareStatement("UPDATE parthistory SET history = ? WHERE objectid = ?")) {
                                psUpd.setString(1, updated);
                                psUpd.setString(2, objectId);
                                psUpd.executeUpdate();
                            }
                        } else {
                            try (PreparedStatement psIns = conn.prepareStatement("INSERT INTO parthistory (objectid, history) VALUES (?, ?)")) {
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

        } catch (Exception ex) {
            ex.printStackTrace();
            resp.put("Status", "Failed").put("Message", "Invalid input: " + ex.getMessage());
            return Response.status(Response.Status.BAD_REQUEST).entity(resp.toString()).build();
        }
    }

    // Delete part
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

    // Latest parts
    @GET 
    @Path("/latestparts")
    @Produces(MediaType.APPLICATION_JSON)
    public Response latestParts() {
        String sql = "SELECT * FROM amxcorepartdata ORDER BY createddate DESC LIMIT 10";
        try (Connection conn = getConn(); 
        	PreparedStatement ps = conn.prepareStatement(sql); 
        	ResultSet rs = ps.executeQuery()) {
            List<Map<String, String>> list = new ArrayList<>();
            ResultSetMetaData md = rs.getMetaData();
            while (rs.next()) {
                Map<String, String> row = new LinkedHashMap<>();
                for (int i = 1; i <= md.getColumnCount(); i++) {
                    row.put(md.getColumnName(i), rs.getString(i));
                }
                list.add(row);
            }
            return Response.ok(list).build();
        } catch (SQLException e) {
            return Response.status(Status.INTERNAL_SERVER_ERROR).entity("{\"error\":\"" + e.getMessage() + "\"}").build();
        }
    }

    //history
    @GET
    @Path("/history")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getHistory(@QueryParam("objectId") String id) {
        String sql = "SELECT history FROM parthistory WHERE objectid = ?";
        try (Connection conn = getConn(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Response.ok("{\"history\":\"" + rs.getString("history") + "\"}").build();
                }
                return Response.status(Status.NOT_FOUND).entity("{\"error\":\"No history\"}").build();
            }
        } catch (SQLException e) {
            return Response.status(Status.INTERNAL_SERVER_ERROR).entity("{\"error\":\"" + e.getMessage() + "\"}").build();
        }
    }
 

    // Persons list
    @GET
    @Path("/persons")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getPersons() {
        String query = "SELECT * FROM amxcorepersondata";        
        List<Map<String, String>> filteredPersons = new ArrayList<>();
        try (Connection conn = DriverManager.getConnection(url, user, db_password);
             PreparedStatement stmt = conn.prepareStatement(query);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Map<String, String> person = new LinkedHashMap<>();
                person.put("Username", rs.getString("username"));
                person.put("Firstname", rs.getString("firstname"));
                person.put("Lastname", rs.getString("lastname"));
                person.put("Country", rs.getString("country"));
                person.put("Email", rs.getString("email"));
                person.put("Access", rs.getString("access"));
                person.put("ObjectId", rs.getString("objectid"));
                filteredPersons.add(person);
            }
            return Response.ok(filteredPersons).build();

        } catch (Exception e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity("{\"error\":\"Failed to load persons.\"}").build();
        }
    }

    // Person infos
    @GET
    @Path("/getpersoninfos")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getPersonInfos(@QueryParam("objectid") String objectid) {
        try {
            if (objectid == null || objectid.trim().isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"error\":\"Missing or invalid objectId parameter\"}").build();
            }
            Person person = new Person(objectid);
            Map<String, String> data = person.getInfos();

            if (data == null || data.isEmpty()) {
                return Response.status(Response.Status.OK)
                        .entity("{\"error\":\"ObjectId '" + objectid + "' not found\"}").build();
            }

            return Response.ok(data).build();
        } catch (Exception e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Internal server error. Please try again later.\"}").build();
        }
    }

    @PUT
    @Path("/update/{objectId}")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response updatePart(@PathParam("objectId") String objectId, Map<String, String> updateData) {
        try {
            if (objectId == null || objectId.trim().isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"error\": \"objectId must be provided\"}").build();
            }
            Person person = new Person(objectId);
            person.updatePersonInDatabase(updateData);

            return Response.ok("{\"message\": \"Part updated successfully\"}").build();
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\": \"Error updating part: " + e.getMessage() + "\"}").build();
        }
    }

  //updatePersonAccess
    @GET
    @Path("/personaccess")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getPersonAccessOptions() {
        try {
            Map<String, List<String>> accessMap = AmxSchemasrules.PersonAccess();
            List<String> accessOptions = accessMap.get("Person Access");
            
            if (accessOptions == null || accessOptions.isEmpty()) {
                throw new RuntimeException("No access options found in database.");
            }
            return Response.ok(accessOptions).build();
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"" + e.getMessage() + "\"}").build();
        }
    }

    
 // updateperson
    @PUT
    @Path("/updatePerson/{objectId}")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response updatePerson(@PathParam("objectId") String objectId, Map<String, String> updateData) {
        try {
            Person person = new Person(objectId);
            person.updatePersonInDatabase(updateData);

            return Response.ok("{\"message\": \"Person updated successfully\"}").build();
        } catch (RuntimeException e) {
            return Response.status(Response.Status.NOT_FOUND).entity("{\"error\": \"" + e.getMessage() + "\"}").build();
        } catch (Exception e) {
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\": \"Error updating person: " + e.getMessage() + "\"}").build();
        }
    }

    @GET
    @Path("/{objectId}/access")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getAccess(@PathParam("objectId") String objectId) {
        try {
            Person person = new Person(objectId);
            String access = person.getAccess();
            return Response.ok("{\"access\": \"" + access + "\"}").build();
        } catch (Exception e) {
            return Response.status(Response.Status.NOT_FOUND)
                    .entity("{\"error\": \"" + e.getMessage() + "\"}").build();
        }
    }

    @POST
    @Path("/{objectId}/access")
    @Produces(MediaType.APPLICATION_JSON)
    public Response setAccess(@PathParam("objectId") String objectId, @QueryParam("access") String access) {
        if (access == null || access.isEmpty()) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\": \"Missing access parameter\"}").build();
        }

        try {
            Person person = new Person(objectId);
            person.setAccess(access);
            return Response.ok("{\"message\": \"Access updated successfully.\"}").build();
        } catch (Exception e) {
            return Response.status(Response.Status.BAD_REQUEST)
                    .entity("{\"error\": \"" + e.getMessage() + "\"}").build();
        }
    }

    // ID generator
    public String generateObjectId(String seed) {
        try {
            MessageDigest md = MessageDigest.getInstance("MD5");
            byte[] h = md.digest(seed.getBytes());
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < 8; i += 2) {
                sb.append(String.format("%04X", ((h[i] & 0xFF) << 8) | (h[i + 1] & 0xFF)));
                if (i < 6) sb.append(".");
            }
            return sb.toString();
        } catch (Exception e) {
            SecureRandom r = new SecureRandom();
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < 4; i++) {
                sb.append(String.format("%04X", r.nextInt(0x10000)));
                if (i < 3) sb.append(".");
            }
            return sb.toString();
        }
    }
    
    //create with connection
    @SuppressWarnings("unchecked")
	@POST
    @Path("/createWithConnection")
    @Consumes(MediaType.APPLICATION_JSON)
    @Produces(MediaType.APPLICATION_JSON)
    public Response createPartControlWithConnection(Map<String, Object> inputData) {
        try {
            if (inputData == null || !inputData.containsKey("partcontrol")) {
                return Response.status(Response.Status.BAD_REQUEST)
                    .entity(Map.of("error", "Missing required 'partcontrol' data"))
                    .build();
            }

            Object partObj = inputData.get("partcontrol");
            if (!(partObj instanceof Map)) {
                return Response.status(Response.Status.BAD_REQUEST)
                    .entity(Map.of("error", "'partcontrol' must be a JSON object"))
                    .build();
            }

            Map<String, Object> rawPartControl = (Map<String, Object>) partObj;
            Map<String, String> partControlMap = new HashMap<>();
            for (Map.Entry<String, Object> entry : rawPartControl.entrySet()) {
                partControlMap.put(entry.getKey().toLowerCase(), entry.getValue() == null ? "" : entry.getValue().toString());
            }

            String sourceObjectId = partControlMap.get("sourceobjectid");
            if (sourceObjectId == null || sourceObjectId.isEmpty()) {
                sourceObjectId = partControlMap.get("objectid");
            }

            if (sourceObjectId == null || sourceObjectId.isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                    .entity(Map.of("error", "Missing 'sourceobjectid' or 'objectid' in partcontrol data"))
                    .build();
            }

            if (isPartControlLinkedToSource(sourceObjectId)) {
                return Response.status(Response.Status.CONFLICT)
                    .entity(Map.of(
                        "error", "A PartControl linked to the sourceObjectId '" + sourceObjectId + "' already exists."
                    ))
                    .build();
            }
            String generatedName = getNextPartControlName();
            String generatedPartId = generateHexId("PACO");
            String existingConnectionId = getConnectionIdForObject(sourceObjectId);
            String connectionIdToUse = (existingConnectionId != null && !existingConnectionId.isEmpty())
                    ? existingConnectionId
                    : generateHexId("CONN");

            partControlMap.put("name", generatedName);
            partControlMap.put("objectid", generatedPartId);
            partControlMap.put("connectionid", connectionIdToUse);
            partControlMap.put("linkedobjectid", sourceObjectId);
            String insertPartControlSQL = "INSERT INTO amxpartcontroldata (objectid, name, supertype, type, description, createddate, owner, email, assignee, connectionid, linkedobjectid) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            try (Connection conn = DriverManager.getConnection(url, user, db_password);
                 PreparedStatement ps = conn.prepareStatement(insertPartControlSQL)) {
                ps.setString(1, generatedPartId);
                ps.setString(2, generatedName);
                ps.setString(3, rawPartControl.getOrDefault("supertype", "").toString());
                ps.setString(4, rawPartControl.getOrDefault("type", "").toString());
                ps.setString(5, rawPartControl.getOrDefault("description", "").toString());
                ps.setTimestamp(6, Timestamp.valueOf(LocalDateTime.now()));
                ps.setString(7, rawPartControl.getOrDefault("owner", "").toString());
                ps.setString(8, rawPartControl.getOrDefault("email", "").toString());
                ps.setString(9, rawPartControl.getOrDefault("assignee", "").toString());
                ps.setString(10, connectionIdToUse);
                ps.setString(11, sourceObjectId);
                ps.executeUpdate();
            }

            String insertConnectionDataSQL = "INSERT INTO amxcoreconnectiondata (connectionid, type, name, fromid, toid, fromname, toname, createddate) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            try (Connection conn = DriverManager.getConnection(url, user, db_password);
                 PreparedStatement ps = conn.prepareStatement(insertConnectionDataSQL)) {
                ps.setString(1, connectionIdToUse);
                ps.setString(2, rawPartControl.getOrDefault("type", "").toString());
                ps.setString(3, generatedName);
                ps.setString(4, generatedPartId);
                ps.setString(5, sourceObjectId);
                ps.setString(6, "partcontrol");
                ps.setString(7, "part");
                ps.setTimestamp(8, Timestamp.valueOf(LocalDateTime.now()));
                ps.executeUpdate();
            }

            String updatePartDataSQL = "UPDATE amxcorepartdata SET connectionid = ? WHERE objectid = ?";
            try (Connection conn = DriverManager.getConnection(url, user, db_password);
                 PreparedStatement ps = conn.prepareStatement(updatePartDataSQL)) {
                ps.setString(1, connectionIdToUse);  
                ps.setString(2, sourceObjectId);      
                ps.executeUpdate();
            }
            String historyMsg = "Created by system at " + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
            String insertHistorySQL = "INSERT INTO partcontrolhistory (objectid, history) VALUES (?, ?)";
            try (Connection conn = DriverManager.getConnection(url, user, db_password);
                 PreparedStatement ps = conn.prepareStatement(insertHistorySQL)) {
                ps.setString(1, generatedPartId);
                ps.setString(2, historyMsg);
                ps.executeUpdate();
            }

            return Response.ok(Map.of(
                "objectid", generatedPartId,
                "connectionid", connectionIdToUse,
                "name", generatedName
            )).build();

        } catch (Exception e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                .entity(Map.of("error", "Failed to create partcontrol: " + e.getMessage()))
                .build();
        }
    }

        public boolean isPartControlLinkedToSource(String sourceObjectId) {
            String sql = "SELECT COUNT(*) FROM amxpartcontroldata WHERE linkedobjectid = ?";
            try (Connection conn = DriverManager.getConnection(url, user, db_password);
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, sourceObjectId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getInt(1) > 0;
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
            return false;
        }


        public String getNextPartControlName() throws SQLException {
            String prefix = "PC-";
            String query = "SELECT name FROM amxpartcontroldata WHERE name LIKE ? ORDER BY name DESC LIMIT 1";
            String lastName = null;

            try (Connection conn = DriverManager.getConnection(url, user, db_password);
                 PreparedStatement ps = conn.prepareStatement(query)) {
                ps.setString(1, prefix + "%");
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        lastName = rs.getString("name");
                    }
                }
            }

            int nextNumber = 1;
            if (lastName != null && lastName.startsWith(prefix)) {
                String numberPart = lastName.substring(prefix.length());
                try {
                    nextNumber = Integer.parseInt(numberPart) + 1;
                } catch (NumberFormatException e) {
                    nextNumber = 1;
                }
            }

            return String.format("%s%06d", prefix, nextNumber);
        }

        public String generateHexId(String suffix) {
            SecureRandom random = new SecureRandom();
            StringBuilder sb = new StringBuilder();

            for (int i = 0; i < 4; i++) {
                String segment = Integer.toHexString(random.nextInt(0x10000)).toUpperCase();
                while (segment.length() < 4) {
                    segment = "0" + segment;
                }
                sb.append(segment);
                if (i < 3) sb.append(".");
            }

            sb.append(".").append(suffix.toUpperCase());
            return sb.toString();
        }
        public String getConnectionIdForObject(String objectId) {
            String sql = "SELECT connectionid FROM amxpartcontroldata WHERE objectid = ?";
            try (Connection conn = DriverManager.getConnection(url, user, db_password);
                 PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, objectId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        return rs.getString("connectionid");
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
            return null;
        }

    @GET
    @Path("/objectid")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getObjectId() {
        try {
            String objectId = getId();
            if (objectId == null || objectId.isEmpty()) {
                return Response.status(Response.Status.NOT_FOUND)
                    .entity(Map.of("error", "Object ID not found"))
                    .build();
            }
            return Response.ok(Map.of("objectid", objectId)).build();
        } catch (Exception e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                .entity(Map.of("error", "Failed to retrieve object ID"))
                .build();
        }
    }
    
    // update connection
    @PUT
    @Path("/connection/{connectionid}")
    @Produces(MediaType.APPLICATION_JSON)
    public Response updateConnection(@PathParam("connectionid") String sConnectionId) {
        try {
            if (sConnectionId == null || sConnectionId.isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                    .entity(Map.of("error", "Connection ID must not be empty"))
                    .build();
            }
            updateConnection(sConnectionId);
            return Response.ok(Map.of("message", "Connection updated successfully")).build();
        } catch (Exception e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                .entity(Map.of("error", "Failed to update connection"))
                .build();
        }
    }
    
        public String sNewTempObjectId; 
        public String getId() throws Exception {
            String sObjectId = "";
            try {
                if (sNewTempObjectId != null && !sNewTempObjectId.isEmpty()) {
                    sObjectId = sNewTempObjectId;
                }
            } catch (Exception e) {
               
            }
            return sObjectId;
        }
        
        //for partcontrol
        @GET
        @Path("/getconnectionids")
        @Consumes(MediaType.APPLICATION_JSON)
        @Produces(MediaType.APPLICATION_JSON)
        public Response getConnectionsForObject(
            @QueryParam("objectId") String objectId,
            @QueryParam("connectionId") String connectionId) {

            if (objectId == null || objectId.trim().isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                    .entity(Map.of("error", "Missing required query parameter 'objectId'"))
                    .build();
            }

            Map<String, Object> responseMap = new HashMap<>();
            List<String> connectionIds = new ArrayList<>();
            List<Map<String, Object>> relatedObjects = new ArrayList<>();

            try (Connection conn = DriverManager.getConnection(url, user, db_password)) {

                if (connectionId != null && !connectionId.trim().isEmpty()) {
                  
                    String checkConnSql = "SELECT 1 FROM amxpartcontroldata WHERE connectionid = ? LIMIT 1";
                    try (PreparedStatement psCheck = conn.prepareStatement(checkConnSql)) {
                        psCheck.setString(1, connectionId);
                        try (ResultSet rs = psCheck.executeQuery()) {
                            if (!rs.next()) {
                                return Response.status(Response.Status.NOT_FOUND)
                                    .entity(Map.of("error", "ConnectionId not found in amxpartcontroldata"))
                                    .build();
                            }
                        }
                    }

                    connectionIds.add(connectionId);

                    String fetchSql = "SELECT * FROM amxpartcontroldata WHERE connectionid = ?";
                    try (PreparedStatement psFetch = conn.prepareStatement(fetchSql)) {
                        psFetch.setString(1, connectionId);
                        try (ResultSet rs = psFetch.executeQuery()) {
                            ResultSetMetaData meta = rs.getMetaData();
                            int colCount = meta.getColumnCount();

                            while (rs.next()) {
                                Map<String, Object> row = new HashMap<>();
                                for (int i = 1; i <= colCount; i++) {
                                    row.put(meta.getColumnName(i), rs.getObject(i));
                                }
                                relatedObjects.add(row);
                            }
                        }
                    }

                } else {
                    String getConnsSql = "SELECT DISTINCT connectionid FROM amxpartcontroldata WHERE objectid = ?";
                    try (PreparedStatement psConns = conn.prepareStatement(getConnsSql)) {
                        psConns.setString(1, objectId);
                        try (ResultSet rs = psConns.executeQuery()) {
                            while (rs.next()) {
                                connectionIds.add(rs.getString("connectionid"));
                            }
                        }
                    }
                    String fetchSql = "SELECT * FROM amxpartcontroldata WHERE connectionid = ?";

                    for (String connId : connectionIds) {
                        try (PreparedStatement psFetch = conn.prepareStatement(fetchSql)) {
                            psFetch.setString(1, connId);
                            try (ResultSet rs = psFetch.executeQuery()) {
                                ResultSetMetaData meta = rs.getMetaData();
                                int colCount = meta.getColumnCount();

                                while (rs.next()) {
                                    Map<String, Object> row = new HashMap<>();
                                    for (int i = 1; i <= colCount; i++) {
                                        row.put(meta.getColumnName(i), rs.getObject(i));
                                    }
                                    relatedObjects.add(row);
                                }
                            }
                        }
                    }
                }

                responseMap.put("objectId", objectId);
                responseMap.put("connectionIds", connectionIds);
                responseMap.put("relatedObjects", relatedObjects);

                return Response.ok(responseMap).build();

            } catch (SQLException e) {
                e.printStackTrace();
                return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity(Map.of("error", "Database error: " + e.getMessage()))
                    .build();
            }
        }
        
        
       
        //latestpartcontrol
        @GET
        @Path("/getallpartcontrol")
        @Produces(MediaType.APPLICATION_JSON)
        public Response getAllLatestPartControl() {
            String sql = "SELECT * FROM amxpartcontroldata ORDER BY createddate DESC LIMIT 10";
            List<Map<String, String>> getLatestParts = new ArrayList<>();
            try (Connection conn = getConn(); 
                 PreparedStatement pstmt = conn.prepareStatement(sql); 
                 ResultSet rs = pstmt.executeQuery()) {
                
                ResultSetMetaData data = rs.getMetaData();
                while (rs.next()) {
                    Map<String, String> datamp = new LinkedHashMap<>();
                    int count = data.getColumnCount();
                    for (int i = 1; i <= count; i++) {
                        String columnname = data.getColumnName(i);
                        String val = rs.getString(i);
                        datamp.put(columnname, val);
                    }
                    getLatestParts.add(datamp);
                }
                return Response.ok(getLatestParts).build();

            } catch (SQLException e) {
                return Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity("{\"error\":\"" + e.getMessage() + "\"}").build();
            }
        }
        
        //getinfos of PC
        @GET 
        @Path("/getinfospc") 
        @Produces(MediaType.APPLICATION_JSON)
        public Response getInfoPC(@QueryParam("objectId") String id) {
            String sql = "SELECT * FROM amxpartcontroldata WHERE objectid = ?";
            try (Connection conn = getConn(); PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, id);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        JSONObject obj = new JSONObject();
                        ResultSetMetaData md = rs.getMetaData();
                        for (int i = 1; i <= md.getColumnCount(); i++) {
                            obj.put(md.getColumnName(i), rs.getString(i));
                        }
                        return Response.ok(obj.toString()).build();
                    }
                    return Response.status(Status.NOT_FOUND).entity("{\"error\":\"Object not found\"}").build();
                }
            } catch (SQLException e) {
                return Response.status(Status.INTERNAL_SERVER_ERROR).entity("{\"error\":\"" + e.getMessage() + "\"}").build();
            }
        }
        
        //getpartcontrolhistory
        @GET
        @Path("/partcontrolhistory")
        @Produces(MediaType.APPLICATION_JSON)
        public Response getPartControlHistory(@QueryParam("objectId") String objectId) {
            if (objectId == null || objectId.isEmpty()) {
                return Response.status(Status.BAD_REQUEST)
                               .entity("{\"error\":\"ObjectId parameter is required\"}")
                               .build();
            }

            String sql = "SELECT history FROM partcontrolhistory WHERE objectid = ?";
            try (Connection conn = getConn(); PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, objectId);
                
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                       
                        String history = rs.getString("history");
                        String jsonResponse = "{\"history\": \"" + history + "\"}";  
                        return Response.ok(jsonResponse).build();
                    } else {
                  
                        return Response.ok("{\"message\":\"No history found for objectId " + objectId + "\"}").build();
                    }
                }
            } catch (SQLException e) {
                return Response.status(Status.INTERNAL_SERVER_ERROR)
                               .entity("{\"error\":\"" + e.getMessage() + "\"}")
                               .build();
            }
        }
        
   //getCreatedpartControl
        @GET
        @Path("/getcreatedpartcontrol")
        @Produces(MediaType.APPLICATION_JSON)
        public Response getPartControlsByObjectId(@QueryParam("objectid") String objectid) {
            if (objectid == null || objectid.trim().isEmpty()) {
                return Response.status(Response.Status.BAD_REQUEST)
                        .entity("{\"error\":\"objectid query parameter is required\"}")
                        .build();
            }
            String sql = "SELECT * FROM amxpartcontroldata WHERE linkedobjectid = ? ORDER BY createddate DESC";
            List<Map<String, String>> results = new ArrayList<>();

            try (Connection conn = getConn();
                 PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setString(1, objectid.trim());

                try (ResultSet rs = pstmt.executeQuery()) {
                    ResultSetMetaData metaData = rs.getMetaData();
                    int colCount = metaData.getColumnCount();

                    while (rs.next()) {
                        Map<String, String> row = new LinkedHashMap<>();
                        for (int i = 1; i <= colCount; i++) {
                            row.put(metaData.getColumnName(i), rs.getString(i));
                        }
                        results.add(row);
                    }
                }
                if (results.isEmpty()) {
                    return Response.ok("{\"message\":\"No part controls found.\"}").build();
                }

                return Response.ok(results).build();

            } catch (SQLException e) {
                e.printStackTrace();
                return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                        .entity("{\"error\":\"" + e.getMessage() + "\"}")
                        .build();
            }
        }

    }

