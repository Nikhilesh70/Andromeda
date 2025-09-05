package org.navigator;

import java.util.HashSet;
import java.util.Set;

import jakarta.ws.rs.ApplicationPath;
import jakarta.ws.rs.core.Application;

@ApplicationPath("/api") 
public class MyApplication extends Application {
    // no additional code needed here
	public Set<Class<?>> getClasses() {
        Set<Class<?>> classes = new HashSet<>();
        classes.add(MyResource.class);
        classes.add(NavigatorUtilites.class); 
        classes.add(DataFetchService.class);
        classes.add(DataBaseResource.class);
        classes.add(DataBaseConnection.class);
        classes.add(SearchData.class);
        return classes;
	}
	
}
