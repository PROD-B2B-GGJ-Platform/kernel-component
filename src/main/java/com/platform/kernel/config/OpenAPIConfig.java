package com.platform.kernel.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

/**
 * OpenAPI/Swagger Configuration
 * 
 * Configures API documentation
 */
@Configuration
public class OpenAPIConfig {

    @Value("${spring.application.name}")
    private String applicationName;

    @Bean
    public OpenAPI kernelComponentOpenAPI() {
        return new OpenAPI()
            .info(new Info()
                .title("Kernel Component API")
                .description("""
                    Core object storage engine with versioning and event bus.
                    
                    Features:
                    - Universal object storage (JSONB)
                    - Complete version history
                    - Object relationships
                    - Event-driven architecture
                    - Multi-tenancy support
                    """)
                .version("10.0.0.1")
                .contact(new Contact()
                    .name("B2B Platform Team")
                    .email("b2b-platform-team@gograbjob.com"))
                .license(new License()
                    .name("Proprietary")
                    .url("https://gograbjob.com/license")))
            .servers(List.of(
                new Server()
                    .url("http://localhost:8083")
                    .description("Development Server"),
                new Server()
                    .url("https://kernel.gograbjob.com")
                    .description("Production Server")
            ));
    }
}

