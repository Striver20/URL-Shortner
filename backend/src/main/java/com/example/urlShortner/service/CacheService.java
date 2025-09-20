package com.example.urlShortner.service;


import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.util.concurrent.TimeUnit;

@Service
@RequiredArgsConstructor
public class CacheService {

    private final RedisTemplate<String, String> redisTemplate;

    private static final String URL_KEY_PREFIX = "short:";  // short:abc123 -> https://example.com

    public void saveUrl(String shortCode, String originalUrl, long ttlInMinutes) {
        redisTemplate.opsForValue().set(URL_KEY_PREFIX + shortCode, originalUrl, ttlInMinutes, TimeUnit.MINUTES);
    }

    public String getUrl(String shortCode) {
        return redisTemplate.opsForValue().get(URL_KEY_PREFIX + shortCode);
    }

    public void deleteUrl(String shortCode) {
        redisTemplate.delete(URL_KEY_PREFIX + shortCode);
    }
}

