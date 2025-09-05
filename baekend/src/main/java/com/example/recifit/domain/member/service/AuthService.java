package com.example.recifit.domain.member.service;

import com.example.recifit.domain.member.dto.LoginRequestDto;
import com.example.recifit.domain.member.dto.LoginResponseDto;
import com.example.recifit.domain.member.dto.SignupRequestDto;
import com.example.recifit.domain.member.entity.Member;
import com.example.recifit.domain.member.enums.MemberRole;
import com.example.recifit.domain.member.repository.MemberRepository;
import com.example.recifit.global.common.CommonResponseDto;
import com.example.recifit.global.common.SuccessCode;
import com.example.recifit.global.error.errorcode.ErrorCode;
import com.example.recifit.global.error.exception.CustomException;
import com.example.recifit.global.jwt.JwtProvider;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Slf4j
public class AuthService {

    private final MemberRepository memberRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtProvider jwtProvider;

    public AuthService(MemberRepository memberRepository,
                       PasswordEncoder passwordEncoder,
                       JwtProvider jwtProvider) {
        this.memberRepository = memberRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtProvider = jwtProvider;
    }

    @Transactional
    public CommonResponseDto<String> signup(SignupRequestDto signupRequestDto) {
        // 중복 이메일 확인
        if (memberRepository.findByEmail(signupRequestDto.getEmail()).isPresent()) {
            throw new CustomException(ErrorCode.DUPLICATE_EMAIL);
        }

        // 닉네임 중복 확인
        if (memberRepository.findByNickname(signupRequestDto.getNickname()).isPresent()) {
            throw new CustomException(ErrorCode.DUPLICATE_NICKNAME);
        }

        // 비밀번호 암호화 후 저장
        String encodedPassword = passwordEncoder.encode(signupRequestDto.getPassword());

        // 회원 Entity 저장
        Member member = Member.builder()
                .email(signupRequestDto.getEmail())
                .password(encodedPassword)
                .nickname(signupRequestDto.getNickname())
                .memberRole(MemberRole.USER)
                .build();

        memberRepository.save(member);

        log.info("저장된 회원: {}", member.getEmail());
        log.info("저장된 닉네임: {}", member.getNickname());

        // 결과 반환
        return CommonResponseDto.success(SuccessCode.SIGNUP_SUCCESS, null);
    }

    public LoginResponseDto login(LoginRequestDto loginRequestDto) {
        // 이메일이 있는지 확인
        Member member = memberRepository.findByEmail(loginRequestDto.getEmail())
                .orElseThrow(() -> new CustomException(ErrorCode.INVALID_LOGIN));

        // 비밀번호가 맞는지 확인
        if (!passwordEncoder.matches(loginRequestDto.getPassword(), member.getPassword())) {
            throw new CustomException(ErrorCode.INVALID_LOGIN);
        }

        // 위 조건이 모두 만족 한다면
        // jwtProvider에서 member에서 가져온 email을 통해서 accessToken, refreshToken 생성
        String accessToken = jwtProvider.generateAccessToken(member.getEmail());
        String refreshToken = jwtProvider.generateRefreshToken(member.getEmail());

        return new LoginResponseDto(accessToken, refreshToken);
    }
}



