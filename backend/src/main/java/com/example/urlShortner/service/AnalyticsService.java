package com.example.urlShortner.service;


import com.example.urlShortner.entity.Url;
import com.example.urlShortner.repository.UrlRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AnalyticsService {

    private final UrlRepository urlRepository;

    public Optional<Url> getAnalytics(String shortCode) {
        return urlRepository.findByShortCode(shortCode);
    }
}
