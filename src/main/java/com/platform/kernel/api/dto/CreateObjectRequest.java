package com.platform.kernel.api.dto;

import com.fasterxml.jackson.databind.JsonNode;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request DTO for creating new object
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateObjectRequest {

    @NotBlank(message = "Object type code is required")
    private String objectTypeCode;

    @NotBlank(message = "Object code is required")
    private String objectCode;

    @NotBlank(message = "Object name is required")
    private String objectName;

    @NotNull(message = "Object data is required")
    private JsonNode data;

    private JsonNode metadata;
}

