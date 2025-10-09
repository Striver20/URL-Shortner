package com.example.urlShortner.service;

import com.example.urlShortner.dto.AnalyticsResponse;
import com.example.urlShortner.dto.UrlResponseDTO;
import com.example.urlShortner.entity.Url;
import com.example.urlShortner.repository.UrlRepository;
import com.example.urlShortner.util.Base62;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class UrlService {

    private final UrlRepository urlRepository;
    private final CacheService cacheService;
    private final CounterService counterService;

    private static final long CACHE_TTL_MINUTES = 60 * 24 * 7; // 7 days

    public UrlResponseDTO toDto(Url url) {
        return UrlResponseDTO.builder()
                .id(url.getId())
                .shortCode(url.getShortCode())
                .shortUrl("http://localhost:8080/" + url.getShortCode()) // build shortUrl
                .originalUrl(url.getOriginalUrl())
                .owner(url.getOwner())
                .expiryDate(url.getExpiryDate())
                .clickCount(url.getClickCount())
                .createdAt(url.getCreatedAt())
                .build();
    }
    @Transactional
    public Url createShortUrl(String originalUrl, LocalDateTime expiryDate, String owner) {
        // Step 1: Save entity WITHOUT shortCode to get the generated ID
        Url url = Url.builder()
                .originalUrl(originalUrl)
                .expiryDate(expiryDate)
                .owner(owner)
                .clickCount(0L)
                .createdAt(LocalDateTime.now())
                .build();

        // insert row (shortCode = null for now)
        url = urlRepository.saveAndFlush(url);

        // Step 2: Generate shortCode using Base62 + ID
        String shortCode = Base62.encode(url.getId());
        url.setShortCode(shortCode);

        // Step 3: Update row with shortCode
        url = urlRepository.save(url);

        // Cache it
        cacheService.saveUrl(shortCode, originalUrl, CACHE_TTL_MINUTES);

        return url;
    }
    @Transactional(readOnly = true)
    public Optional<Url> getUrlEntity(String shortCode) {
        return urlRepository.findByShortCode(shortCode);
    }


    @Transactional(readOnly = true)
    public Optional<String> getOriginalUrl(String shortCode) {
        // 1. Check cache
        String cachedUrl = cacheService.getUrl(shortCode);
        if (cachedUrl != null) {
            // ⚠️ Double-check DB to ensure it's still valid (not expired)
            return urlRepository.findByShortCode(shortCode)
                    .filter(url -> url.getExpiryDate() == null || url.getExpiryDate().isAfter(LocalDateTime.now()))
                    .map(url -> {
                        counterService.incrementCounter(shortCode);
                        return cachedUrl;
                    });
        }

        // 2. Fallback DB
        return urlRepository.findByShortCode(shortCode)
                .filter(url -> url.getExpiryDate() == null || url.getExpiryDate().isAfter(LocalDateTime.now()))
                .map(url -> {
                    cacheService.saveUrl(shortCode, url.getOriginalUrl(), CACHE_TTL_MINUTES);
                    counterService.incrementCounter(shortCode);
                    return url.getOriginalUrl();
                });
    }

    @Scheduled(fixedRate = 3600000) // every 1 hour
    @Transactional
    public void deleteExpiredUrls() {
        LocalDateTime now = LocalDateTime.now();
        urlRepository.findAll().stream()
                .filter(url -> url.getExpiryDate() != null && url.getExpiryDate().isBefore(now))
                .forEach(url -> {
                    cacheService.deleteUrl(url.getShortCode());
                    urlRepository.delete(url);
                });
    }

    @Transactional(readOnly = true)
    public AnalyticsResponse getAnalytics(String shortCode) {
        return urlRepository.findByShortCode(shortCode)
                .map(url -> AnalyticsResponse.builder()
                        .shortCode(url.getShortCode())
                        .originalUrl(url.getOriginalUrl())
                        .clickCount(url.getClickCount())
                        .lastAccessedAt(url.getLastAccessedAt())
                        .createdAt(url.getCreatedAt())
                        .expiryDate(url.getExpiryDate())
                        .owner(url.getOwner())
                        .build()
                )
                .orElseThrow(() -> new RuntimeException("Short code not found: " + shortCode));
    }

    @Transactional
    public void updateAnalytics(String shortCode) {
        urlRepository.findByShortCode(shortCode).ifPresent(url -> {
            long redisCount = counterService.getCounter(shortCode);
            url.setClickCount(url.getClickCount() + redisCount);
            url.setLastAccessedAt(LocalDateTime.now());
            urlRepository.save(url);

            // Reset redis counter after syncing
            counterService.resetCounter(shortCode);
        });
    }

    @Transactional
    public Url saveUrl(Url url) {
        return urlRepository.save(url);
    }

}

