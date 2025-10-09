package com.example.urlShortner.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class StaticPageController {

    @GetMapping("/expired")
    public String showExpiredPage() {
        // looks for templates/expired.html
        return "expired";
    }
}
