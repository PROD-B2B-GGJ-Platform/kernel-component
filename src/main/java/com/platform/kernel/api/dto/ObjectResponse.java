package com.platform.kernel.api.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;

/**
 * DTO for object response
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
    private Map<String, Object> data;
    private String status;
    private Integer version;
    private Boolean isDeleted;
    private LocalDateTime createdAt;
    private String createdBy;
    private LocalDateTime modifiedAt;
    private String modifiedBy;
    private Map<String, Object> metadata;
}
