package com.example.recifit.global.util;

import com.example.recifit.domain.member.dto.KakaoDTO;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;


@Component
public class KakaoUtil {

    private final String clientId;

    private final String redirectUri;

    private final WebClient kakaoAuthClient;    // kauth.kakao.com (토큰 발급)

    private final WebClient kakaoApiClient;     // kapi.kakao.com (사용자 정보 조회)

    public KakaoUtil(
            @Value("${kakao.api.client-id}") String clientId,
            @Value("${kakao.api.redirect_uri}") String redirectUri,
            @Qualifier("kakaoAuthClient") WebClient kakaoAuthClient,
            @Qualifier("kakaoApiClient") WebClient kakaoApiClient
    ) {
        this.clientId = clientId;
        this.redirectUri = redirectUri;
        this.kakaoAuthClient = kakaoAuthClient;
        this.kakaoApiClient = kakaoApiClient;
    }

    /**
     * 엑세스 토큰 발급
     */
    public Mono<KakaoDTO.OAuthToken> requestToken(String code) {
        return kakaoAuthClient.post()
                .uri("/oauth/token")
                .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                .body(BodyInserters.fromFormData("grant_type", "authorization_code")
                        .with("client_id", clientId)
                        .with("redirect_uri", redirectUri)
                        .with("code", code))
                .retrieve()
                .bodyToMono(KakaoDTO.OAuthToken.class);
    }

    /**
     * 액세스 토큰으로 사용자 정보 조회
     */
    public Mono<KakaoDTO.KakaoProfile> getMemberInfo(String accessToken) {
        return kakaoApiClient.get()
                .uri("/v2/user/me")
                .headers(h -> h.setBearerAuth(accessToken))
                .retrieve()
                .bodyToMono(KakaoDTO.KakaoProfile.class);
    }

    /**
     * 리프레시 토큰으로 토큰 갱신
     * 장기 세션/추가 API 호출 시 사용 예정
     * 예) 카카오 로그아웃 처리, 앱 연결 해제, 토큰 유효성 확인 등
     */
//    public Mono<KakaoDTO.OAuthToken> refreshToken(String refreshToken) {
//        return kakaoAuthClient.post()
//                .uri("/oauth/token")
//                .contentType(MediaType.APPLICATION_FORM_URLENCODED)
//                .body(BodyInserters.fromFormData("grant_type", "refresh_token")
//                        .with("client_id", clientId)
//                        .with("refresh_token", refreshToken))
//                .retrieve()
//                .bodyToMono(KakaoDTO.OAuthToken.class);
//    }
}