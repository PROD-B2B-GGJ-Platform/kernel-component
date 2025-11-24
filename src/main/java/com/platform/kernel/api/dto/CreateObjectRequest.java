package com.platform.kernel.api.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;
import java.util.UUID;

/**
 * DTO for creating a new object
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateObjectRequest {

    @NotNull(message = "Tenant ID is required")
    private UUID tenantId;

    @NotBlank(message = "Object type code is required")
    private String objectTypeCode;

    @NotBlank(message = "Object code is required")
    private String objectCode;

    @NotNull(message = "Data is required")
    private Map<String, Object> data;

    private Map<String, Object> metadata;
}
