package com.example.urlShortner.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class AnalyticsResponse {
    private String shortCode;
    private String shortUrl;
    private String originalUrl;
    private Long clickCount;
    private LocalDateTime createdAt;
    private LocalDateTime lastAccessedAt;
    private LocalDateTime expiryDate;
    private String owner;
    private List<ClickDetail> clickDetails;

    @Data
    @Builder
    @AllArgsConstructor   // 👈 generates a public constructor
    @NoArgsConstructor
    public static class ClickDetail {
        private LocalDateTime clickedAt;
        private String ipAddress;
        private String userAgent;
        private String referrer;
    }
}
