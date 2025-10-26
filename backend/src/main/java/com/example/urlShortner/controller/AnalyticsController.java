package com.example.urlShortner.controller;

import com.example.urlShortner.dto.AnalyticsResponse;
import com.example.urlShortner.entity.Url;
import com.example.urlShortner.service.AnalyticsService;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/v1/urls")
@RequiredArgsConstructor
public class AnalyticsController {

    private final AnalyticsService analyticsService;

    @Value("${app.base-url:http://localhost:8080}")
    private String baseUrl;

    @GetMapping("/{shortCode}/analytics")
    public Object getAnalytics(@PathVariable String shortCode) {

        Url url = analyticsService.getAnalytics(shortCode)
                .orElseThrow(() -> new RuntimeException("Short URL not found"));

        if (url.getExpiryDate() != null && url.getExpiryDate().isBefore(LocalDateTime.now())) {
            // Instead of throwing generic RuntimeException (which backend turns into 400)
            // we directly return an error response that frontend can parse.
            return new java.util.HashMap<String, Object>() {{
                put("error", "This short URL has expired.");
                put("timestamp", LocalDateTime.now());
            }};
        }

        List<AnalyticsResponse.ClickDetail> clickDetails = url.getClicks().stream()
                .map(c -> new AnalyticsResponse.ClickDetail(
                        c.getClickedAt(),
                        c.getIpAddress(),
                        c.getUserAgent(),
                        c.getReferrer()
                ))
                .toList();

        return new AnalyticsResponse(
                url.getShortCode(),
                baseUrl + "/" + url.getShortCode(),
                url.getOriginalUrl(),
                url.getClickCount(),
                url.getCreatedAt(),
                url.getLastAccessedAt(),
                url.getExpiryDate(),
                url.getOwner(),
                clickDetails
        );
    }
}
