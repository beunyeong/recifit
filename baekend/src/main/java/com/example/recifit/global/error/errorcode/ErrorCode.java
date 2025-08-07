package com.example.recifit.global.error.errorcode;

import lombok.Getter;
import org.springframework.http.HttpStatus;

@Getter
public enum ErrorCode {

    /**
     * 400 BAD_REQUEST
     */
    DUPLICATE_EMAIL(HttpStatus.BAD_REQUEST, "중복된 이메일입니다."),
    DUPLICATE_NICKNAME(HttpStatus.BAD_REQUEST, "중복된 닉네임입니다."),
    INVALID_LOGIN(HttpStatus.BAD_REQUEST, "이메일 또는 비밀번호가 일치하지 않습니다."),
    INVALID_STORAGE_DATE(HttpStatus.BAD_REQUEST, "미래 날짜는 보관일로 설정할 수 없습니다."),

    /**
     * 404 NOT_FOUND
     */
    MEMBER_NOT_FOUND(HttpStatus.NOT_FOUND, "멤버 정보를 찾을 수 없습니다.");




//    ERROR_STATUS(HttpStatus.BAD_REQUEST, "잘못된 요청입니다."),
//    FAIL_STATUS(HttpStatus.BAD_REQUEST, "요청에 실패 했습니다."),

    private final HttpStatus httpStatus;

    private final String message;

    ErrorCode(HttpStatus httpStatus, String message) {
        this.httpStatus = httpStatus;
        this.message = message;
    }
}
