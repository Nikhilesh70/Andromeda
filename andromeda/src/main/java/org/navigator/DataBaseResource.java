package org.navigator;

import jakarta.ws.rs.*;
import jakarta.ws.rs.core.MediaType;
import jakarta.ws.rs.core.Response;

import java.sql.*;
import java.util.*;

@Path("/db")
public class DataBaseResource {

    public static final String url = "jdbc:postgresql://localhost:5432/Andromeda";
    public static final String user = "postgres";
    public static final String db_password = "amxadmin123";

    static {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            e.printStackTrace();
        }
        String createSupertypeTable = """
            CREATE TABLE IF NOT EXISTS supertype (id SERIAL PRIMARY KEY,name VARCHAR(100) NOT NULL UNIQUE);
            """;
        String createTypeTable = """
            CREATE TABLE IF NOT EXISTS type (id SERIAL PRIMARY KEY,partname VARCHAR(100),amxcontrol VARCHAR(100),
                supertype_id INTEGER REFERENCES supertype(id) ON DELETE CASCADE);
            """;
        String createSubtypeTable = """
            CREATE TABLE IF NOT EXISTS subtype (id SERIAL PRIMARY KEY,partname VARCHAR(100),subpart VARCHAR(255),
                apn VARCHAR(50),type_id INTEGER REFERENCES type(id) ON DELETE CASCADE);
            """;
        String createFastenerSubtypeTable="""
        		CREATE TABLE IF NOT EXISTS fastenersubtypes(id SERIAL PRIMARY KEY,partname VARCHAR(100),subpart VARCHAR(10000),
        		apn VARCHAR(1000),variant VARCHAR(100), type_id INTEGER REFERENCES type(id) ON DELETE CASCADE);        		
        		""";

        try (Connection conn = DriverManager.getConnection(url, user, db_password);
             Statement stmt = conn.createStatement()) {

            stmt.executeUpdate(createSupertypeTable);
            stmt.executeUpdate(createTypeTable);
            stmt.executeUpdate(createSubtypeTable);
            stmt.executeUpdate(createFastenerSubtypeTable);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    @GET
    @Path("/dropdowns")
    @Produces(MediaType.APPLICATION_JSON)
    public Response getAllDropdowns() {
        Map<String, Object> responseMap = new HashMap<>();

        try (Connection conn = getConnection()) {

            // 1) Fetch all supertypes
            List<String> superTypes = new ArrayList<>();
            String sqlSuper = "SELECT name FROM supertype ORDER BY name";
            try (PreparedStatement ps = conn.prepareStatement(sqlSuper);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    superTypes.add(rs.getString("name"));
                }
            }
            if (!superTypes.contains("AmxControl")) {
                superTypes.add(0, "AmxControl");
            }
            responseMap.put("superTypes", superTypes);

            // 2) Fetch types grouped by supertype
            Map<String, List<String>> typesMap = new HashMap<>();
            for (String superType : superTypes) {
                List<String> typeNames = new ArrayList<>();

                if ("Document".equals(superType)) {
                    String sqlDocumentTypes = "SELECT DISTINCT document FROM type WHERE document IS NOT NULL AND document <> '' ORDER BY document";
                    try (PreparedStatement ps = conn.prepareStatement(sqlDocumentTypes);
                         ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            typeNames.add(rs.getString("document"));
                        }
                    }
                } else if (!"AmxControl".equals(superType)) {
                    String sqlType = "SELECT partname FROM type WHERE supertype_id = (SELECT id FROM supertype WHERE name = ?) ORDER BY partname";
                    try (PreparedStatement ps = conn.prepareStatement(sqlType)) {
                        ps.setString(1, superType);
                        try (ResultSet rs = ps.executeQuery()) {
                            while (rs.next()) {
                                String partname = rs.getString("partname");
                                if (partname != null && !partname.trim().isEmpty()) {
                                    typeNames.add(partname.trim());
                                }
                            }
                        }
                    }
                }

                typesMap.put(superType, typeNames);
            }


            // 3) Fetch distinct amxcontrol values for "AmxControl" type
            List<String> amxControlTypes = new ArrayList<>();
            String sqlAmxControl = "SELECT DISTINCT amxcontrol FROM type WHERE amxcontrol IS NOT NULL AND amxcontrol <> '' ORDER BY amxcontrol";
            try (PreparedStatement ps = conn.prepareStatement(sqlAmxControl);
                 ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String amxcontrol = rs.getString("amxcontrol");
                    if (amxcontrol != null && !amxcontrol.trim().isEmpty()) {
                        amxControlTypes.add(amxcontrol.trim());
                    }
                }
            }
            typesMap.put("AmxControl", amxControlTypes);

            responseMap.put("types", typesMap);

            // 4) Fetch subtypes and APN grouped by type.partname (Standard Subtypes)
            Map<String, List<String>> subTypeMap = new HashMap<>();
            Map<String, List<String>> apnMap = new HashMap<>();

            String sqlSub = """
                    SELECT type.partname, subtype.subpart, subtype.apn 
                    FROM subtype 
                    JOIN type ON subtype.type_id = type.id
                    ORDER BY type.partname, subtype.subpart
                    """;

            try (PreparedStatement ps = conn.prepareStatement(sqlSub);
                 ResultSet rs = ps.executeQuery()) {

                String currentPartName = null;
                List<String> subParts = new ArrayList<>();
                List<String> apns = new ArrayList<>();

                while (rs.next()) {
                    String partName = rs.getString("partname");
                    String subPart = rs.getString("subpart");
                    String apn = rs.getString("apn");

                    if (currentPartName == null || !currentPartName.equalsIgnoreCase(partName)) {
                        if (currentPartName != null) {
                            subTypeMap.put(currentPartName.toLowerCase(), new ArrayList<>(subParts));
                            apnMap.put(currentPartName.toLowerCase(), new ArrayList<>(apns));
                        }
                        currentPartName = partName;
                        subParts.clear();
                        apns.clear();
                    }

                    // Add all subparts as a single string (optional)
                    subParts.add(subPart);

                    // Split APN and subpart comma separated lists and pair them
                    String[] apnArr = apn.split(",");
                    String[] subPartArr = subPart.split(",");

                    for (int i = 0; i < apnArr.length && i < subPartArr.length; i++) {
                        apns.add(apnArr[i].trim() + "-" + subPartArr[i].trim());
                    }
                }
                if (currentPartName != null) {
                    subTypeMap.put(currentPartName.toLowerCase(), subParts);
                    apnMap.put(currentPartName.toLowerCase(), apns);
                }
            }

            responseMap.put("subtypes", subTypeMap);
            responseMap.put("apn", apnMap);

            // 5) Fetch data from fastenersubtypes (for Fastener-related APN and Subtypes)
            Map<String, List<String>> fastenerSubtypesMap = new HashMap<>();
            Map<String, List<String>> fastenerVariantMap = new HashMap<>();

            String sqlFastenerSubtypes = """
                    SELECT fastenersubtypes.partname, fastenersubtypes.subpart, fastenersubtypes.apn, fastenersubtypes.variant
                    FROM fastenersubtypes 
                    ORDER BY fastenersubtypes.partname, fastenersubtypes.subpart
                    """;

            try (PreparedStatement ps = conn.prepareStatement(sqlFastenerSubtypes);
                 ResultSet rs = ps.executeQuery()) {

                String currentFastenerPart = null;
                List<String> fastenerSubparts = new ArrayList<>();
                List<String> fastenerVariants = new ArrayList<>();
                List<String> fastenerApns = new ArrayList<>();

                while (rs.next()) {
                    String fastenerPart = rs.getString("partname");
                    String fastenerSubpart = rs.getString("subpart");
                    String fastenerApn = rs.getString("apn");
                    String variant = rs.getString("variant");

                    if (currentFastenerPart == null || !currentFastenerPart.equalsIgnoreCase(fastenerPart)) {
                        if (currentFastenerPart != null) {
                            fastenerSubtypesMap.put(currentFastenerPart.toLowerCase(), new ArrayList<>(fastenerSubparts));
                            fastenerVariantMap.put(currentFastenerPart.toLowerCase(), new ArrayList<>(fastenerVariants));
                        }
                        currentFastenerPart = fastenerPart;
                        fastenerSubparts.clear();
                        fastenerVariants.clear();
                        fastenerApns.clear();
                    }

                    fastenerSubparts.add(fastenerSubpart);
                    fastenerApns.add(fastenerApn);

                    if (variant != null && !variant.trim().isEmpty()) {
                        fastenerVariants.add(variant.trim());
                    }
                }

                if (currentFastenerPart != null) {
                    fastenerSubtypesMap.put(currentFastenerPart.toLowerCase(), fastenerSubparts);
                    fastenerVariantMap.put(currentFastenerPart.toLowerCase(), fastenerVariants);
                }

            }

            responseMap.put("fastenerSubtypes", fastenerSubtypesMap);
            responseMap.put("fastenerVariants", fastenerVariantMap);

            return Response.ok(responseMap).build();

        } catch (SQLException e) {
            e.printStackTrace();
            return Response.status(Response.Status.INTERNAL_SERVER_ERROR)
                    .entity("{\"error\":\"Database error: " + e.getMessage() + "\"}")
                    .build();
        }
    }


    public Connection getConnection() throws SQLException {
        return DriverManager.getConnection(url, user, db_password);
    }
    
    
}
