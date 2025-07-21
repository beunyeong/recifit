package com.example.recifit.global.error.exception;

import com.example.recifit.global.error.errorcode.ErrorCode;

public class UnAuthorizedException extends CustomException {

    public UnAuthorizedException(ErrorCode errorCode) {
        super(errorCode);
    }

    public UnAuthorizedException(ErrorCode errorCode, String message) {
        super(errorCode, message);
    }
}