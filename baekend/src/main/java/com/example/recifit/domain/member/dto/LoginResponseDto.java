package com.example.recifit.domain.member.dto;

import lombok.Getter;

@Getter
public class LoginResponseDto {

    private final String accessToken;
    private final String refreshToken;

    public LoginResponseDto(String accessToken, String refreshToken) {
        this.accessToken = accessToken;
        this.refreshToken = refreshToken;
    }
}
