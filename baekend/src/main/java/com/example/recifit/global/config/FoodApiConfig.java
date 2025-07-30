package com.example.recifit.global.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import org.springframework.web.reactive.function.client.WebClient;

@Configuration
public class FoodApiConfig {

    @Bean("foodWebClient")
    public WebClient foodWebClient() {
        return WebClient.builder().build();
    }
}