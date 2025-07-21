package com.example.recifit.global.error.response;

import lombok.Getter;

@Getter
public class ErrorResponseDto {

    private final int status;
    private final String message;
    private final String errorCode;


    public ErrorResponseDto(int status, String message, String errorCode) {
        this.status = status;
        this.message = message;
        this.errorCode = errorCode;
    }


}
