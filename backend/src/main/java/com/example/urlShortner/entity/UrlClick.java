package com.example.urlShortner.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "url_clicks")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UrlClick {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private LocalDateTime clickedAt;

    @Column(length = 1024)
    private String userAgent;

    @Column(length = 1024)
    private String referrer;

    @Column(length = 45)
    private String ipAddress;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "url_id", nullable = false)
    private Url url;

    @PrePersist
    public void prePersist() {
        this.clickedAt = LocalDateTime.now();
    }
}
