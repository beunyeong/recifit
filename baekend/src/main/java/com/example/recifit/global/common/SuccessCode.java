package com.example.recifit.global.common;

import lombok.Getter;

@Getter
public enum SuccessCode {

    /**
     * Auth 관련 Code
     */
    SIGNUP_SUCCESS("회원가입이 완료되었습니다."),
    LOGIN_SUCCESS("로그인이 완료되었습니다."),

    /**
     * INGREDIENT 관련 Code
     */
    ADD_INGREDIENT_SUCCESS("재료가 등록되었습니다.");


    private final String message;

    SuccessCode(String message) {
        this.message = message;
    }
}
