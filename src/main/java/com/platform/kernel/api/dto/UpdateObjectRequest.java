package com.platform.kernel.api.dto;

import com.fasterxml.jackson.databind.JsonNode;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request DTO for updating object
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpdateObjectRequest {

    @NotBlank(message = "Object name is required")
    private String objectName;

    @NotNull(message = "Object data is required")
    private JsonNode data;

    private String changeDescription;

    private JsonNode metadata;
}

