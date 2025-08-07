package com.example.recifit.domain.member.controller;

import com.example.recifit.domain.member.dto.LoginRequestDto;
import com.example.recifit.domain.member.dto.LoginResponseDto;
import com.example.recifit.domain.member.dto.SignupRequestDto;
import com.example.recifit.domain.member.service.AuthService;
import com.example.recifit.global.common.CommonResponseDto;
import com.example.recifit.global.common.SuccessCode;
import com.example.recifit.global.jwt.JwtProvider;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
@Tag(name = "Auth", description = "사용자 인증 및 토큰 발급 API")
public class AuthController {

    private final AuthService authService;
    private final JwtProvider jwtProvider;

    public AuthController(AuthService authService, JwtProvider jwtProvider) {
        this.authService = authService;
        this.jwtProvider = jwtProvider;
    }

    // 회원가입
    @PostMapping("/signup")
    public ResponseEntity<CommonResponseDto<Void>> signup(@RequestBody SignupRequestDto signupRequestDto) {
        authService.signup(signupRequestDto);

        return ResponseEntity.ok(CommonResponseDto.success(SuccessCode.SIGNUP_SUCCESS, null));
    }

    // 로그인
    @PostMapping("/login")
    public ResponseEntity<CommonResponseDto<LoginResponseDto>> login(@RequestBody LoginRequestDto loginRequestDto) {
        LoginResponseDto response = authService.login(loginRequestDto);

        return ResponseEntity.ok(CommonResponseDto.success(SuccessCode.LOGIN_SUCCESS, response));


    }

    // 로그아웃

}
