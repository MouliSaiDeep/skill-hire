package com.devops.skill_hire.config;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**") // Apply to all API endpoints
                // Add your exact OpenShift frontend route here
                .allowedOrigins("frontend-route-23mh1a05l8-dev.apps.rm3.7wse.p1.openshiftapps.com") 
                // Alternatively, use "*" for testing to allow all origins
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*")
                .allowCredentials(true);
    }
}