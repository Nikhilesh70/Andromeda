package org.navigator;

import java.io.IOException;
import jakarta.ws.rs.container.ContainerRequestContext;
import jakarta.ws.rs.container.ContainerResponseContext;
import jakarta.ws.rs.container.ContainerResponseFilter;
import jakarta.ws.rs.ext.Provider;

@Provider
public class CORSFilter implements ContainerResponseFilter {

    public static final String ALLOWED_ORIGIN = "http://localhost:8080"; 

    @Override
    public void filter(ContainerRequestContext requestContext,
                       ContainerResponseContext responseContext) throws IOException {
       
        String origin = requestContext.getHeaderString("Origin");

        if (origin != null && origin.equals(ALLOWED_ORIGIN)) {
            responseContext.getHeaders().add("Access-Control-Allow-Origin", origin); 
        } else {
            responseContext.getHeaders().add("Access-Control-Allow-Origin", "*"); 
        }
        responseContext.getHeaders().add("Access-Control-Allow-Credentials", "true");
        responseContext.getHeaders().add("Access-Control-Allow-Headers", "origin, content-type, accept, authorization");
        responseContext.getHeaders().add("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS, HEAD");
        if ("OPTIONS".equals(requestContext.getMethod())) {
            responseContext.setStatus(200);  
        }
    }
}
