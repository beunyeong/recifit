package com.example.recifit.global.jwt;

import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import jakarta.servlet.http.HttpServletRequest;
import lombok.Getter;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;

@Component
public class JwtProvider {

    /**
     * JWT 서명에 사용할 key
     */
    private final SecretKey key;

    @Getter
    private final long accessTokenExpiry;

    @Getter
    private final long refreshTokenExpiry;


    public JwtProvider(
            @Value("${jwt.secret-key}") String secret,
            @Value(("${jwt.expiry-millis}")) long accessTokenExpiry,
            @Value(("${jwt.refresh-expiry-millis}")) long refreshTokenExpiry
    ) {
        this.key = Keys.hmacShaKeyFor(secret.getBytes(StandardCharsets.UTF_8));
        this.accessTokenExpiry = accessTokenExpiry;
        this.refreshTokenExpiry = refreshTokenExpiry;
    }

    /**
     * 1-1 토큰 생성 - AccessToken
     */
    public String generateAccessToken(String email) {
        return generateToken(email, accessTokenExpiry);
    }

    /**
     * 1-2 토큰 생성 - RefreshToken
     */
    public String generateRefreshToken(String email) {
        return generateToken(email, refreshTokenExpiry);
    }


    /**
     * 1-3 토큰 생성 - 공통
     */
    public String generateToken(String email, Long expiryTime) {
        Date now = new Date();
        Date expiry = new Date(now.getTime() + expiryTime);

        return Jwts.builder()
                .subject(email)         // subject에 사용자 email 저장
                .issuedAt(now)          // 발급 시간
                .expiration(expiry)     // 만료 시간
                .signWith(key)          // 서명
                .compact();             // 토큰 문자열 생성
    }

    /**
     * 2. 토큰 유효성 검사
     */
    public boolean validateToken(String token) {
        try {
            Jwts.parser().setSigningKey(key).build().parseClaimsJws(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }

    /**
     * 3. 토큰에서 사용자 정보 꺼내기 - email
     */
    public String getEmailFromToken(String token) {
        return Jwts.parser()
                .setSigningKey(key)
                .build()
                .parseClaimsJws(token)
                .getBody()
                .getSubject();
    }

    /**
     * 4. HTTP 요청에서 JWT 토큰 꺼내기
     */
    public static final String AUTHORIZATION_HEADER = "Authorization";
    public static final String BEARER_PREFIX = "Bearer ";

    public String resolveToken(HttpServletRequest httpServletRequest) {
        String bearerToken = httpServletRequest.getHeader(AUTHORIZATION_HEADER);
        if (bearerToken != null && bearerToken.startsWith(BEARER_PREFIX)) {
            return bearerToken.substring(7);
        }
        return null;
    }
}