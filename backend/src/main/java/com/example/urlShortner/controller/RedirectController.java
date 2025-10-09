package com.example.urlShortner.controller;

import com.example.urlShortner.entity.Url;
import com.example.urlShortner.entity.UrlClick;
import com.example.urlShortner.repository.UrlClickRepository;
import com.example.urlShortner.repository.UrlRepository;
import com.example.urlShortner.service.UrlService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import java.time.LocalDateTime;
import java.util.Optional;

@Controller
@RequiredArgsConstructor
public class RedirectController {

    private final UrlService urlService;
    private final UrlClickRepository urlClickRepository;
    private final UrlRepository urlRepository;

    @GetMapping("/{shortCode}")
    public String redirect(@PathVariable String shortCode, HttpServletRequest request) {
        Optional<Url> optionalUrl = urlService.getUrlEntity(shortCode);

        if (optionalUrl.isEmpty()) {
            return "redirect:/error";
        }

        Url urlEntity = optionalUrl.get();

        if (urlEntity.getExpiryDate() != null && urlEntity.getExpiryDate().isBefore(LocalDateTime.now())) {
            return "expired"; // Renders templates/expired.html
        }

        UrlClick click = UrlClick.builder()
                .url(urlEntity)
                .ipAddress(request.getRemoteAddr())
                .userAgent(request.getHeader(HttpHeaders.USER_AGENT))
                .referrer(request.getHeader(HttpHeaders.REFERER))
                .build();
        urlClickRepository.save(click);

        urlEntity.setClickCount(urlEntity.getClickCount() + 1);
        urlEntity.setLastAccessedAt(LocalDateTime.now());
        urlRepository.save(urlEntity);

        return "redirect:" + urlEntity.getOriginalUrl();
    }
}
