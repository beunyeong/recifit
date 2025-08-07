package com.example.recifit.domain.member.dto;

import com.example.recifit.global.util.ValidationPatterns;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Getter;

@Getter
public class LoginRequestDto {

    @Email(message = "유효한 이메일 형식이 아닙니다.")
    @NotBlank
    private String email;

    @NotBlank(message = "비밀번호는 필수 입력입니다.")
    @Pattern(regexp = ValidationPatterns.PASSWORD_PATTERN,
            message = "비밀번호는 영문 소문자, 숫자, 특수문자를 포함한 8~12자여야 합니다.")
    private String password;

    public LoginRequestDto(String email, String password) {
        this.email = email;
        this.password = password;
    }
}
