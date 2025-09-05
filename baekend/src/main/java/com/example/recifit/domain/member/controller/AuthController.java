package com.example.recifit.domain.member.controller;

import com.example.recifit.domain.member.dto.LoginRequestDto;
import com.example.recifit.domain.member.dto.LoginResponseDto;
import com.example.recifit.domain.member.dto.SignupRequestDto;
import com.example.recifit.domain.member.service.AuthService;
import com.example.recifit.global.common.CommonResponseDto;
import com.example.recifit.global.common.SuccessCode;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;


@RestController
@RequestMapping("/api/auth")
@Tag(name = "Auth", description = "사용자 인증 및 토큰 발급 API")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/login/kakao")
    public ResponseEntity<CommonResponseDto<LoginResponseDto>> kakaoLogin(@RequestParam("code") String code) {
        LoginResponseDto loginResponseDto = authService.oAuthLogin(code);

        return ResponseEntity.ok(CommonResponseDto.success(SuccessCode.LOGIN_SUCCESS, loginResponseDto));
    }

    // 회원가입
    @PostMapping("/signup")
    public ResponseEntity<CommonResponseDto<Void>> signup(@Valid @RequestBody SignupRequestDto signupRequestDto) {
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
