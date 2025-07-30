package com.example.recifit.global.client;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

import java.net.URI;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@Slf4j
@Component
@RequiredArgsConstructor
public class FoodApiClient {

    @Qualifier("foodWebClient")
    private final WebClient webClient;

    @Value("${food.api.service-key}")
    private String serviceKey;

    @Value("${food.api.base-url}")
    private String baseUrl;

    public Mono<String> getFoodXml(String foodName) {
        StringBuilder url = new StringBuilder(baseUrl);
        url.append("?serviceKey=").append(serviceKey);
        url.append("&FOOD_NM_KR=").append(URLEncoder.encode(foodName, StandardCharsets.UTF_8));
        url.append("&pageNo=1&numOfRows=50&type=xml");

        log.info("실제 요청 URL: {}", url);

        URI uri = URI.create(url.toString());

        return webClient.get()
                .uri(uri)
                .retrieve()
                .onStatus(
                        status -> status.is5xxServerError(),
                        response -> response.bodyToMono(String.class)
                                .flatMap(body -> {
                                    log.error("공공데이터포털 500에러 응답: {}", body);
                                    return Mono.error(new RuntimeException("외부 API 500: " + body));
                                })
                )
                .bodyToMono(String.class);
    }
}