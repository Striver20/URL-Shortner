package com.example.urlShortner.repository;

import com.example.urlShortner.entity.UrlClick;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UrlClickRepository extends JpaRepository<UrlClick, Long> {
}
