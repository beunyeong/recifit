package com.example.recifit.domain.member.dto;

import com.example.recifit.domain.member.entity.Member;
import com.example.recifit.domain.member.enums.CookingLevel;
import com.example.recifit.domain.member.enums.MemberRole;
import com.example.recifit.domain.member.enums.MemberType;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Getter;

import static com.example.recifit.global.util.ValidationPatterns.*;

@Getter
public class SignupRequestDto {

    @Email(message = "유효한 이메일 주소를 입력해주세요")
    @NotBlank(message = "이메일은 필수 입력값입니다.")
    private String email;

    @NotBlank(message = "비밀번호는 필수 입력값입니다.")
    @Pattern(regexp = PASSWORD_PATTERN,
            message = "비밀번호는 영문 소문자, 숫자, 특수문자를 포함한 8~12자여야 합니다.")
    private String password;

    public SignupRequestDto(String email, String password) {
        this.email = email;
        this.password = password;
    }

    public Member toEntity(String encodedPassword, MemberRole memberRole) {
        return Member.builder()
                .email(email)
                .password(encodedPassword)
                .memberRole(memberRole)
                .memberType(MemberType.SINGLE)
                .cookingLevel(CookingLevel.BEGINNER)
                .build();
    }
}
