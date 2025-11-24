package com.platform.kernel.api.dto;

import jakarta.validation.constraints.NotNull;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.Map;

/**
 * DTO for updating an object
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpdateObjectRequest {

    @NotNull(message = "Data is required")
    private Map<String, Object> data;

    private String changeReason;
}
