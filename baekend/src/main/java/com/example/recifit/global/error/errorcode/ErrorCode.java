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
    INVALID_EXPIRATION_DATE(HttpStatus.BAD_REQUEST, "과거 날짜는 보관일로 설정할 수 없습니다."),
    INTERNAL_FORMAT_ERROR(HttpStatus.BAD_REQUEST, "토큰 형식이 유효하지 않습니다."),
    TOKEN_ILLEGAL(HttpStatus.BAD_REQUEST, "토큰이 null이거나 비어있습니다."),

    /**
     * 401 UNAUTHORIZED
     */
    TOKEN_EXPIRED(HttpStatus.UNAUTHORIZED, "만료된 토큰입니다."),

    /**
     * 403 FORBIDDEN
     */
    NO_POST_MODIFY_PERMISSION(HttpStatus.FORBIDDEN, "본인이 작성한 게시글만 수정할 수 있습니다."),


    /**
     * 404 NOT_FOUND
     */
    MEMBER_NOT_FOUND(HttpStatus.NOT_FOUND, "멤버 정보를 찾을 수 없습니다."),
    INGREDIENT_NOT_FOUND(HttpStatus.NOT_FOUND, "재료를 찾을 수 없습니다."),
    POST_NOT_FOUND(HttpStatus.NOT_FOUND, "게시글을 찾을 수 없습니다."),

    /**
     * 500 INTERNAL_SERVER_ERROR
     */
    INTERNAL_SERVER_ERROR(HttpStatus.INTERNAL_SERVER_ERROR, "서버 오류가 발생했습니다.");


    private final HttpStatus httpStatus;

    private final String message;

    ErrorCode(HttpStatus httpStatus, String message) {
        this.httpStatus = httpStatus;
        this.message = message;
    }
}
