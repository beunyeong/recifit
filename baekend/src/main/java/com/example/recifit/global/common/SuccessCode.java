package com.example.recifit.global.common;

import lombok.Getter;

@Getter
public enum SuccessCode {

    SIGNUP_SUCCESS("회원가입이 완료되었습니다."),
    SUCCESS_STATUS("요청에 성공했습니다.");


    private final String message;

    SuccessCode(String message) {
        this.message = message;
    }
}
