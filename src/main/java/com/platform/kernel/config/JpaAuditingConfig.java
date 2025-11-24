package com.platform.kernel.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.domain.AuditorAware;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;

import java.util.Optional;

/**
 * JPA Auditing Configuration
 * 
 * Provides automatic population of audit fields:
 * - createdBy, createdAt
 * - modifiedBy, modifiedAt
 */
@Configuration
@EnableJpaAuditing
public class JpaAuditingConfig {

    /**
     * Provides the current auditor (user)
     * 
     * In production, this should extract user from SecurityContext
     * For now, returns "system" as default
     */
    @Bean
    public AuditorAware<String> auditorProvider() {
        return () -> {
            // TODO: Extract from SecurityContext in production
            // SecurityContext context = SecurityContextHolder.getContext();
            // Authentication auth = context.getAuthentication();
            // return Optional.ofNullable(auth.getName());
            
            return Optional.of("system");
        };
    }
}

