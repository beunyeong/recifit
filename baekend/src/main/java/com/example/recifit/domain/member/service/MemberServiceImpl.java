package com.example.recifit.domain.member.service;

import com.example.recifit.domain.member.dto.SignupRequestDto;
import com.example.recifit.domain.member.entity.Member;
import com.example.recifit.domain.member.enums.MemberRole;
import com.example.recifit.domain.member.repository.MemberRepository;
import com.example.recifit.global.common.CommonResponseDto;
import com.example.recifit.global.common.SuccessCode;
import com.example.recifit.global.error.errorcode.ErrorCode;
import com.example.recifit.global.error.exception.BadRequestException;
import com.example.recifit.global.jwt.JwtProvider;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Slf4j
public class MemberServiceImpl extends MemberService{

    private final MemberRepository memberRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtProvider jwtProvider;

    public MemberServiceImpl(MemberRepository memberRepository,
                         PasswordEncoder passwordEncoder,
                         JwtProvider jwtProvider) {
        this.memberRepository = memberRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtProvider = jwtProvider;
    }

    @Transactional
    public CommonResponseDto<String> signup(SignupRequestDto signupRequestDto) {
        // 중복 이메일 확인
        if(memberRepository.findByEmail(signupRequestDto.getEmail()).isPresent()) {
            throw new BadRequestException(ErrorCode.DUPLICATE_EMAIL);
        }
        // 비밀번호 암호화 후 저장
        String encodedPassword = passwordEncoder.encode(signupRequestDto.getPassword());

        // 회원 Entity 저장
        Member member = Member.builder()
                .email(signupRequestDto.getEmail())
                .password(encodedPassword)
                .memberRole(MemberRole.USER)
                .build();

        memberRepository.save(member);

        log.info("저장된 회원: {}", member.getEmail());


        // 결과 반환
        return CommonResponseDto.success(SuccessCode.SIGNUP_SUCCESS, null);
    }
}


