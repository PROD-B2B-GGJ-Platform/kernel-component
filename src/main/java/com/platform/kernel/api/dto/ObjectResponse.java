package com.platform.kernel.api.dto;

import com.fasterxml.jackson.databind.JsonNode;
import com.platform.kernel.domain.model.KernelObject;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

/**
 * Response DTO for object
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ObjectResponse {

    private UUID id;
    private UUID tenantId;
    private String objectTypeCode;
    private String objectCode;
    private String objectName;
    private JsonNode data;
    private Integer version;
    private String status;
    private JsonNode metadata;
    
    private LocalDateTime createdAt;
    private String createdBy;
    private LocalDateTime modifiedAt;
    private String modifiedBy;

    /**
     * Convert domain model to DTO
     */
    public static ObjectResponse from(KernelObject object) {
        return ObjectResponse.builder()
            .id(object.getId())
            .tenantId(object.getTenantId())
            .objectTypeCode(object.getObjectTypeCode())
            .objectCode(object.getObjectCode())
            .objectName(object.getObjectName())
            .data(object.getData())
            .version(object.getVersion())
            .status(object.getStatus())
            .metadata(object.getMetadata())
            .createdAt(object.getCreatedAt())
            .createdBy(object.getCreatedBy())
            .modifiedAt(object.getModifiedAt())
            .modifiedBy(object.getModifiedBy())
            .build();
    }
}

