package com.example.urlShortner.service;


import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CounterService {

    private final RedisTemplate<String, String> redisTemplate;
    private static final String COUNTER_KEY_PREFIX = "cnt:"; // cnt:abc123 -> 45

    public void incrementCounter(String shortCode) {
        redisTemplate.opsForValue().increment(COUNTER_KEY_PREFIX + shortCode);
    }

    public long getCounter(String shortCode) {
        String value = redisTemplate.opsForValue().get(COUNTER_KEY_PREFIX + shortCode);
        return value == null ? 0 : Long.parseLong(value);
    }

    public void resetCounter(String shortCode) {
        redisTemplate.delete(COUNTER_KEY_PREFIX + shortCode);
    }
}
