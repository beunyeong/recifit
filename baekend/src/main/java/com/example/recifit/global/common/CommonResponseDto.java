package com.example.recifit.global.common;

import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
public class CommonResponseDto<T> {

    private final int status;
    private final String message;
    private final T data;

    public CommonResponseDto(HttpStatus status, String message, T data) {
        this.status = status.value();
        this.message = message;
        this.data = data;
    }

    public static <T> CommonResponseDto<T> success(SuccessCode successCode, T data) {
        return new CommonResponseDto<>(HttpStatus.OK, successCode.getMessage(), data);
    }

    public static <T> CommonResponseDto<T> error(HttpStatus httpStatus, String message, T data) {
        return new CommonResponseDto<>(httpStatus, message, data);
    }
}
