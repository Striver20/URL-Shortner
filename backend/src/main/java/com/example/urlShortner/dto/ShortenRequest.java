package com.example.urlShortner.dto;


import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.time.LocalDateTime;

@Data
public class ShortenRequest {
    @NotBlank(message = "Original URL is required")
    private String url;

    private LocalDateTime expiryDate;

    private String owner;
}

