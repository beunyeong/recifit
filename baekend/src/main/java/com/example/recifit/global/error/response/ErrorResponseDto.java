package com.example.recifit.global.error.response;

import com.example.recifit.global.error.errorcode.ErrorCode;
import com.example.recifit.global.error.exception.CustomException;
import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.servlet.http.HttpServletRequest;
import lombok.Getter;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.time.LocalDateTime;

@Getter
public class ErrorResponseDto {

    private final int status;
    private final String errorCode;
    private final String message;
    private final String path;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd'T'HH:mm:ss")
    private final LocalDateTime timestamp;

    public ErrorResponseDto(ErrorCode errorCode, String path) {
        this.status = errorCode.getHttpStatus().value();
        this.errorCode = errorCode.name();
        this.message = errorCode.getMessage();
        this.path = path;
        this.timestamp = LocalDateTime.now();
    }

    public static ResponseEntity<ErrorResponseDto> toResponseEntity(CustomException e, HttpServletRequest request) {
        return ResponseEntity
                .status(e.getErrorCode().getHttpStatus())
                .body(new ErrorResponseDto(e.getErrorCode(), request.getRequestURI()));
    }
}
