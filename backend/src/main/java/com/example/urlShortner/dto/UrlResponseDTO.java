package com.example.urlShortner.dto;

import lombok.Builder;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@Builder
public class UrlResponseDTO {
    private Long id;
    private String shortCode;
    private String shortUrl;
    private String originalUrl;
    private String owner;
    private LocalDateTime expiryDate;
    private Long clickCount;
    private LocalDateTime createdAt;
}
