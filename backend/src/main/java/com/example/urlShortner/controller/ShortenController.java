package com.example.urlShortner.controller;

import com.example.urlShortner.dto.ShortenRequest;
import com.example.urlShortner.dto.ShortenResponse;
import com.example.urlShortner.entity.Url;
import com.example.urlShortner.service.UrlService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/shorten")
@RequiredArgsConstructor
public class ShortenController {

    private final UrlService urlService;

    @Value("${app.base-url:http://localhost:8080}") // fallback to localhost
    private String baseUrl;

    @PostMapping
    public ShortenResponse createShortUrl(@Valid @RequestBody ShortenRequest request) {
        Url url = urlService.createShortUrl(
                request.getUrl(),
                request.getExpiryDate(),
                request.getOwner()
        );

        String shortUrl = baseUrl + "/" + url.getShortCode();

        return new ShortenResponse(
                url.getId(),
                url.getShortCode(),
                shortUrl,
                url.getOriginalUrl(),
                url.getOwner(),
                url.getExpiryDate(),
                url.getClickCount(),
                url.getCreatedAt()
        );
    }
}

