package com.example.recifit.domain.member.controller;

import com.example.recifit.domain.member.dto.SignupRequestDto;
import com.example.recifit.domain.member.service.MemberService;
import com.example.recifit.domain.member.service.MemberServiceImpl;
import com.example.recifit.global.common.CommonResponseDto;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
@Tag(name = "auth", description = "회원 관리 API")
public class MemberController {

    private final MemberService memberService;
    private final MemberServiceImpl memberServiceImpl;

    public MemberController(MemberService memberService, MemberServiceImpl memberServiceImpl) {
        this.memberService = memberService;
        this.memberServiceImpl = memberServiceImpl;
    }

    // 회원가입
    @PostMapping("/signup")
    public ResponseEntity<CommonResponseDto<String>> signup(@RequestBody SignupRequestDto signupRequestDto) {
        CommonResponseDto<String> response = memberServiceImpl.signup(signupRequestDto);
        return ResponseEntity.ok(response);
    }



    // 로그인



    // 로그아웃


    // 비밀번호 변경


    // 아이디 찾기, 비밀번호 찾기




}
